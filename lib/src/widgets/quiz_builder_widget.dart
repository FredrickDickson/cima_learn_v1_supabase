import 'package:flutter/material.dart';

class QuizBuilderWidget extends StatefulWidget {
  final List<Map<String, dynamic>> initialQuestions;
  final Function(List<Map<String, dynamic>>) onQuestionsChanged;

  const QuizBuilderWidget({
    Key? key,
    this.initialQuestions = const [],
    required this.onQuestionsChanged,
  }) : super(key: key);

  @override
  State<QuizBuilderWidget> createState() => _QuizBuilderWidgetState();
}

class _QuizBuilderWidgetState extends State<QuizBuilderWidget> {
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.initialQuestions);
    if (_questions.isEmpty) {
      _addQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quiz Builder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: ListView.builder(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildQuestionCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Text(
                'Question ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: question['type'] ?? 'multiple_choice',
                items: const [
                  DropdownMenuItem(
                    value: 'multiple_choice',
                    child: Text('Multiple Choice'),
                  ),
                  DropdownMenuItem(
                    value: 'true_false',
                    child: Text('True/False'),
                  ),
                  DropdownMenuItem(
                    value: 'short_answer',
                    child: Text('Short Answer'),
                  ),
                  DropdownMenuItem(
                    value: 'essay',
                    child: Text('Essay'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    question['type'] = value;
                    if (value == 'true_false') {
                      question['options'] = ['True', 'False'];
                    } else if (value == 'multiple_choice' && question['options'] == null) {
                      question['options'] = ['', '', '', ''];
                    }
                  });
                  _notifyChanges();
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _deleteQuestion(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Question Text
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Question',
              border: OutlineInputBorder(),
            ),
            initialValue: question['question'] ?? '',
            maxLines: 3,
            onChanged: (value) {
              question['question'] = value;
              _notifyChanges();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Question Options
          if (question['type'] == 'multiple_choice') 
            _buildMultipleChoiceOptions(question)
          else if (question['type'] == 'true_false')
            _buildTrueFalseOptions(question)
          else if (question['type'] == 'short_answer')
            _buildShortAnswerOptions(question)
          else if (question['type'] == 'essay')
            _buildEssayOptions(question),
          
          const SizedBox(height: 16),
          
          // Additional Settings
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Points',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: question['points']?.toString() ?? '1',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    question['points'] = int.tryParse(value) ?? 1;
                    _notifyChanges();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Required'),
                  value: question['required'] ?? true,
                  onChanged: (value) {
                    setState(() {
                      question['required'] = value;
                    });
                    _notifyChanges();
                  },
                  activeColor: const Color(0xFFB71C1C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(Map<String, dynamic> question) {
    final options = question['options'] as List<String>? ?? ['', '', '', ''];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Answer Options',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue: question['correctAnswer'],
                  onChanged: (value) {
                    setState(() {
                      question['correctAnswer'] = value;
                    });
                    _notifyChanges();
                  },
                  activeColor: const Color(0xFFB71C1C),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Option ${String.fromCharCode(65 + index)}',
                      border: const OutlineInputBorder(),
                    ),
                    initialValue: option,
                    onChanged: (value) {
                      options[index] = value;
                      question['options'] = options;
                      _notifyChanges();
                    },
                  ),
                ),
                if (options.length > 2)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        options.removeAt(index);
                        question['options'] = options;
                      });
                      _notifyChanges();
                    },
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
              ],
            ),
          );
        }).toList(),
        
        // Add option button
        if (options.length < 6)
          TextButton.icon(
            onPressed: () {
              setState(() {
                options.add('');
                question['options'] = options;
              });
              _notifyChanges();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Option'),
          ),
      ],
    );
  }

  Widget _buildTrueFalseOptions(Map<String, dynamic> question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correct Answer',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: question['correctAnswer'],
              onChanged: (value) {
                setState(() {
                  question['correctAnswer'] = value;
                });
                _notifyChanges();
              },
              activeColor: const Color(0xFFB71C1C),
            ),
            const Text('True'),
            const SizedBox(width: 24),
            Radio<bool>(
              value: false,
              groupValue: question['correctAnswer'],
              onChanged: (value) {
                setState(() {
                  question['correctAnswer'] = value;
                });
                _notifyChanges();
              },
              activeColor: const Color(0xFFB71C1C),
            ),
            const Text('False'),
          ],
        ),
      ],
    );
  }

  Widget _buildShortAnswerOptions(Map<String, dynamic> question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Sample/Expected Answer',
            border: OutlineInputBorder(),
            helperText: 'Provide a sample answer or keywords to look for',
          ),
          initialValue: question['correctAnswer'] ?? '',
          onChanged: (value) {
            question['correctAnswer'] = value;
            _notifyChanges();
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Max Characters',
                  border: OutlineInputBorder(),
                ),
                initialValue: question['maxLength']?.toString() ?? '100',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  question['maxLength'] = int.tryParse(value) ?? 100;
                  _notifyChanges();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SwitchListTile(
                title: const Text('Case Sensitive'),
                value: question['caseSensitive'] ?? false,
                onChanged: (value) {
                  setState(() {
                    question['caseSensitive'] = value;
                  });
                  _notifyChanges();
                },
                activeColor: const Color(0xFFB71C1C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEssayOptions(Map<String, dynamic> question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Grading Rubric/Guidelines',
            border: OutlineInputBorder(),
            helperText: 'Provide guidelines for manual grading',
          ),
          initialValue: question['rubric'] ?? '',
          maxLines: 3,
          onChanged: (value) {
            question['rubric'] = value;
            _notifyChanges();
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Min Words',
                  border: OutlineInputBorder(),
                ),
                initialValue: question['minWords']?.toString() ?? '50',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  question['minWords'] = int.tryParse(value) ?? 50;
                  _notifyChanges();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Max Words',
                  border: OutlineInputBorder(),
                ),
                initialValue: question['maxWords']?.toString() ?? '500',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  question['maxWords'] = int.tryParse(value) ?? 500;
                  _notifyChanges();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'type': 'multiple_choice',
        'question': '',
        'options': ['', '', '', ''],
        'correctAnswer': null,
        'points': 1,
        'required': true,
      });
    });
    _notifyChanges();
  }

  void _deleteQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
      });
      _notifyChanges();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz must have at least one question')),
      );
    }
  }

  void _notifyChanges() {
    widget.onQuestionsChanged(_questions);
  }
}