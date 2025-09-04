import 'package:flutter/material.dart';
import 'dart:async';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../utils/responsive.dart';

class QuizWidget extends StatefulWidget {
  final Quiz quiz;
  final VoidCallback? onQuizCompleted;

  const QuizWidget({
    Key? key,
    required this.quiz,
    this.onQuizCompleted,
  }) : super(key: key);

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  final QuizService _quizService = QuizService();
  final PageController _pageController = PageController();
  
  String? _attemptId;
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _answers = {};
  Timer? _timer;
  int _timeRemaining = 0; // in seconds
  bool _isSubmitting = false;
  bool _isQuizCompleted = false;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _startQuiz() async {
    try {
      _attemptId = await _quizService.startQuizAttempt(widget.quiz.id);
      
      if (_attemptId != null) {
        _timeRemaining = widget.quiz.timeLimit * 60; // Convert minutes to seconds
        _startTimer();
      }
    } catch (e) {
      _showErrorDialog('Failed to start quiz: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _submitQuiz();
        }
      });
    });
  }

  String get _timeDisplay {
    final minutes = _timeRemaining ~/ 60;
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _answerQuestion(String questionId, dynamic answer) {
    setState(() {
      _answers[questionId] = answer;
    });
    
    // Auto-save progress
    if (_attemptId != null) {
      _quizService.saveQuizProgress(
        attemptId: _attemptId!,
        answers: _answers,
      );
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting || _attemptId == null) return;

    setState(() {
      _isSubmitting = true;
    });

    _timer?.cancel();

    try {
      final result = await _quizService.submitQuizAttempt(
        attemptId: _attemptId!,
        quizId: widget.quiz.id,
        answers: _answers,
      );

      setState(() {
        _isQuizCompleted = true;
      });

      _showResultDialog(result);
    } catch (e) {
      _showErrorDialog('Failed to submit quiz: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showResultDialog(QuizAttempt result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.isPassed ? Icons.check_circle : Icons.cancel,
              color: result.isPassed ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(result.isPassed ? 'Congratulations!' : 'Quiz Completed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.isPassed 
                  ? 'You have successfully passed this quiz!'
                  : 'You did not meet the passing score this time.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildScoreDisplay(result),
            if (!result.isPassed && result.attemptNumber < widget.quiz.maxAttempts) ...[
              const SizedBox(height: 16),
              Text(
                'You have ${widget.quiz.maxAttempts - result.attemptNumber} attempts remaining.',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ],
          ],
        ),
        actions: [
          if (!result.isPassed && result.attemptNumber < widget.quiz.maxAttempts)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _retakeQuiz();
              },
              child: const Text('Try Again'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onQuizCompleted?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _retakeQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _isQuizCompleted = false;
      _attemptId = null;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _startQuiz();
  }

  Widget _buildScoreDisplay(QuizAttempt result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Score:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${result.score}/${result.totalPoints}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Percentage:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${result.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: result.isPassed ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grade:', style: TextStyle(fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: result.isPassed ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result.grade,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (result.timeTaken != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time Taken:', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('${result.timeTaken!.inMinutes}:${(result.timeTaken!.inSeconds % 60).toString().padLeft(2, '0')}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isQuizCompleted) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _timeDisplay,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
                ),
              ],
            ),
          ),
          
          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemCount: widget.quiz.questions.length,
              itemBuilder: (context, index) {
                final question = widget.quiz.questions[index];
                return _buildQuestionWidget(question);
              },
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _nextQuestion,
                    icon: _isSubmitting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_currentQuestionIndex == widget.quiz.questions.length - 1
                            ? Icons.check
                            : Icons.arrow_forward),
                    label: Text(
                      _currentQuestionIndex == widget.quiz.questions.length - 1
                          ? 'Submit Quiz'
                          : 'Next',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(QuizQuestion question) {
    return SingleChildScrollView(
      padding: ResponsivePadding.all(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            question.question,
            style: TextStyle(
              fontSize: ResponsiveFontSize.heading4(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${question.points} point${question.points == 1 ? '' : 's'}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Answer options
          _buildAnswerOptions(question),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(QuizQuestion question) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceOptions(question);
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(question);
      case QuestionType.trueFalse:
        return _buildTrueFalseOptions(question);
      case QuestionType.shortAnswer:
        return _buildShortAnswerInput(question);
      default:
        return const Text('Question type not supported');
    }
  }

  Widget _buildSingleChoiceOptions(QuizQuestion question) {
    final currentAnswer = _answers[question.id] as String?;
    
    return Column(
      children: question.options.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: RadioListTile<String>(
            title: Text(option.text),
            value: option.id,
            groupValue: currentAnswer,
            onChanged: (value) {
              if (value != null) {
                _answerQuestion(question.id, value);
              }
            },
            activeColor: const Color(0xFFB71C1C),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions(QuizQuestion question) {
    final currentAnswers = (_answers[question.id] as List<String>?) ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select all that apply:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ...question.options.map((option) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: CheckboxListTile(
              title: Text(option.text),
              value: currentAnswers.contains(option.id),
              onChanged: (checked) {
                List<String> newAnswers = List.from(currentAnswers);
                if (checked == true) {
                  newAnswers.add(option.id);
                } else {
                  newAnswers.remove(option.id);
                }
                _answerQuestion(question.id, newAnswers);
              },
              activeColor: const Color(0xFFB71C1C),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTrueFalseOptions(QuizQuestion question) {
    final currentAnswer = _answers[question.id] as String?;
    
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('True'),
          value: 'true',
          groupValue: currentAnswer,
          onChanged: (value) {
            if (value != null) {
              _answerQuestion(question.id, value);
            }
          },
          activeColor: const Color(0xFFB71C1C),
        ),
        RadioListTile<String>(
          title: const Text('False'),
          value: 'false',
          groupValue: currentAnswer,
          onChanged: (value) {
            if (value != null) {
              _answerQuestion(question.id, value);
            }
          },
          activeColor: const Color(0xFFB71C1C),
        ),
      ],
    );
  }

  Widget _buildShortAnswerInput(QuizQuestion question) {
    return TextFormField(
      initialValue: _answers[question.id]?.toString() ?? '',
      decoration: const InputDecoration(
        hintText: 'Enter your answer...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) => _answerQuestion(question.id, value),
    );
  }
}