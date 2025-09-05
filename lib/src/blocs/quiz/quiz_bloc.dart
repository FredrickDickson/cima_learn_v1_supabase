import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

/// Quiz BLoC managing quiz sessions, scoring, and progress tracking
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(QuizInitial()) {
    // Register event handlers
    on<QuizLoadRequested>(_onQuizLoadRequested);
    on<QuizStartRequested>(_onQuizStartRequested);
    on<QuizQuestionAnswered>(_onQuizQuestionAnswered);
    on<QuizNextQuestionRequested>(_onQuizNextQuestionRequested);
    on<QuizPreviousQuestionRequested>(_onQuizPreviousQuestionRequested);
    on<QuizQuestionSkipped>(_onQuizQuestionSkipped);
    on<QuizSubmitRequested>(_onQuizSubmitRequested);
    on<QuizResultsRequested>(_onQuizResultsRequested);
    on<QuizRetryRequested>(_onQuizRetryRequested);
    on<QuizHistoryRequested>(_onQuizHistoryRequested);
    on<QuizTimerUpdated>(_onQuizTimerUpdated);
    on<QuizTimerExpired>(_onQuizTimerExpired);
    on<QuizPauseRequested>(_onQuizPauseRequested);
    on<QuizResumeRequested>(_onQuizResumeRequested);
    on<QuizProgressSaved>(_onQuizProgressSaved);
    on<QuizProgressLoaded>(_onQuizProgressLoaded);
    on<QuizCleared>(_onQuizCleared);
    on<QuizQuestionFlagged>(_onQuizQuestionFlagged);
  }

  Timer? _quizTimer;
  String? _currentAttemptId;

  @override
  Future<void> close() {
    _quizTimer?.cancel();
    return super.close();
  }

  /// Load quiz for a specific lesson
  Future<void> _onQuizLoadRequested(
    QuizLoadRequested event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    try {
      // Load quiz data
      final quizResponse = await supabase
          .from('quizzes')
          .select('*, quiz_questions(*)')
          .eq('lesson_id', event.lessonId)
          .single();

      final quiz = Quiz.fromJson(quizResponse);

      // Load previous attempts
      final attemptsResponse = await supabase
          .from('quiz_attempts')
          .select('*')
          .eq('quiz_id', quiz.id)
          .eq('user_id', event.userId)
          .order('started_at', ascending: false);

      final previousAttempts = attemptsResponse
          .map((data) => QuizAttempt.fromJson(data))
          .toList();

      // Check if user can retake
      final canRetake = previousAttempts.length < quiz.maxAttempts;

      emit(QuizLoaded(
        quiz: quiz,
        previousAttempts: previousAttempts,
        canRetake: canRetake,
        maxAttempts: quiz.maxAttempts,
      ));
    } catch (e) {
      emit(QuizError(message: 'Failed to load quiz: $e'));
    }
  }

  /// Start quiz session
  Future<void> _onQuizStartRequested(
    QuizStartRequested event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizLoaded) return;

    final currentState = state as QuizLoaded;

    try {
      // Create new quiz attempt
      final attemptData = {
        'quiz_id': event.quizId,
        'user_id': event.userId,
        'started_at': DateTime.now().toIso8601String(),
        'total_points': currentState.quiz.questions.fold(0, (sum, q) => sum + q.points),
        'status': 'in_progress',
      };

      final attemptResponse = await supabase
          .from('quiz_attempts')
          .insert(attemptData)
          .select()
          .single();

      _currentAttemptId = attemptResponse['id'];

      // Randomize questions if enabled
      final questions = currentState.quiz.isRandomized
          ? _shuffleQuestions(currentState.quiz.questions)
          : currentState.quiz.questions;

      final quiz = Quiz(
        id: currentState.quiz.id,
        title: currentState.quiz.title,
        description: currentState.quiz.description,
        lessonId: currentState.quiz.lessonId,
        courseId: currentState.quiz.courseId,
        questions: questions,
        timeLimit: currentState.quiz.timeLimit,
        passingScore: currentState.quiz.passingScore,
        maxAttempts: currentState.quiz.maxAttempts,
        isRandomized: currentState.quiz.isRandomized,
        showResultsImmediately: currentState.quiz.showResultsImmediately,
        instructions: currentState.quiz.instructions,
      );

      emit(QuizInProgress(
        quiz: quiz,
        currentQuestionIndex: 0,
        answers: {},
        flaggedQuestions: {},
        timeRemaining: quiz.timeLimit,
        timeSpent: Duration.zero,
      ));

      // Start quiz timer
      _startQuizTimer(quiz.timeLimit);
    } catch (e) {
      emit(QuizError(message: 'Failed to start quiz: $e'));
    }
  }

  /// Handle question answer
  Future<void> _onQuizQuestionAnswered(
    QuizQuestionAnswered event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    final updatedAnswers = Map<String, dynamic>.from(currentState.answers);
    updatedAnswers[event.questionId] = event.selectedAnswer;

    emit(currentState.copyWith(answers: updatedAnswers));

    // Auto-save progress
    if (_currentAttemptId != null) {
      add(QuizProgressSaved(
        quizId: currentState.quiz.id,
        userId: _currentAttemptId!,
        currentQuestionIndex: currentState.currentQuestionIndex,
        answers: updatedAnswers,
        timeSpent: currentState.timeSpent,
      ));
    }
  }

  /// Navigate to next question
  Future<void> _onQuizNextQuestionRequested(
    QuizNextQuestionRequested event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    if (!currentState.isLastQuestion) {
      emit(currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
      ));
    }
  }

  /// Navigate to previous question
  Future<void> _onQuizPreviousQuestionRequested(
    QuizPreviousQuestionRequested event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    if (!currentState.isFirstQuestion) {
      emit(currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex - 1,
      ));
    }
  }

  /// Skip current question
  Future<void> _onQuizQuestionSkipped(
    QuizQuestionSkipped event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    
    // Mark question as skipped in answers
    final updatedAnswers = Map<String, dynamic>.from(currentState.answers);
    updatedAnswers[event.questionId] = null;

    emit(currentState.copyWith(answers: updatedAnswers));

    // Auto-navigate to next question
    if (!currentState.isLastQuestion) {
      add(QuizNextQuestionRequested());
    }
  }

  /// Submit quiz for grading
  Future<void> _onQuizSubmitRequested(
    QuizSubmitRequested event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    emit(QuizSubmitting(quiz: currentState.quiz, answers: event.answers));

    _quizTimer?.cancel();

    try {
      // Calculate score
      final results = _calculateQuizResults(currentState.quiz, event.answers);

      // Update quiz attempt
      await supabase
          .from('quiz_attempts')
          .update({
            'completed_at': DateTime.now().toIso8601String(),
            'score': results.score,
            'time_spent_seconds': event.totalTimeSpent.inSeconds,
            'is_passed': results.isPassed,
            'status': 'completed',
            'answers': event.answers,
          })
          .eq('id', _currentAttemptId!);

      // Save detailed question results
      for (final questionResult in results.questionResults) {
        await supabase.from('quiz_question_results').insert({
          'attempt_id': _currentAttemptId,
          'question_id': questionResult.questionId,
          'user_answer': questionResult.userAnswer,
          'is_correct': questionResult.isCorrect,
          'points_earned': questionResult.earnedPoints,
        });
      }

      // Update lesson progress if quiz passed
      if (results.isPassed) {
        await supabase.from('lesson_progress').upsert({
          'user_id': event.userId,
          'lesson_id': currentState.quiz.lessonId,
          'course_id': currentState.quiz.courseId,
          'is_completed': true,
          'quiz_passed': true,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Check if user can retake
      final attemptsResponse = await supabase
          .from('quiz_attempts')
          .select('id')
          .eq('quiz_id', event.quizId)
          .eq('user_id', event.userId);

      final canRetake = attemptsResponse.length < currentState.quiz.maxAttempts;

      emit(QuizCompleted(
        results: results,
        canRetake: canRetake && !results.isPassed,
        nextAttemptAvailableAt: canRetake ? DateTime.now() : null,
      ));
    } catch (e) {
      emit(QuizError(message: 'Failed to submit quiz: $e'));
    }
  }

  /// Load quiz results
  Future<void> _onQuizResultsRequested(
    QuizResultsRequested event,
    Emitter<QuizState> emit,
  ) async {
    try {
      final attemptResponse = await supabase
          .from('quiz_attempts')
          .select('*, quiz_question_results(*)')
          .eq('id', event.attemptId)
          .eq('user_id', event.userId)
          .single();

      final attempt = QuizAttempt.fromJson(attemptResponse);
      
      // Build question results
      final questionResults = <QuestionResult>[];
      final questionResultsData = attemptResponse['quiz_question_results'] as List;
      
      for (final qr in questionResultsData) {
        questionResults.add(QuestionResult(
          questionId: qr['question_id'],
          question: 'Question', // Would need to join with questions table
          userAnswer: qr['user_answer'],
          correctAnswer: null, // Would need to join with questions table
          isCorrect: qr['is_correct'],
          points: 1, // Would need to join with questions table
          earnedPoints: qr['points_earned'],
        ));
      }

      final results = QuizResults(
        attemptId: event.attemptId,
        score: attempt.score,
        totalPoints: attempt.totalPoints,
        percentage: attempt.percentage,
        isPassed: attempt.isPassed,
        timeSpent: attempt.timeSpent,
        questionResults: questionResults,
      );

      emit(QuizCompleted(
        results: results,
        canRetake: false,
        nextAttemptAvailableAt: null,
      ));
    } catch (e) {
      emit(QuizError(message: 'Failed to load quiz results: $e'));
    }
  }

  /// Handle quiz retry
  Future<void> _onQuizRetryRequested(
    QuizRetryRequested event,
    Emitter<QuizState> emit,
  ) async {
    // Load quiz again and start new attempt
    add(QuizLoadRequested(
      lessonId: '', // Would need to pass lesson ID
      userId: event.userId,
    ));
  }

  /// Load quiz history
  Future<void> _onQuizHistoryRequested(
    QuizHistoryRequested event,
    Emitter<QuizState> emit,
  ) async {
    try {
      var query = supabase
          .from('quiz_attempts')
          .select('*')
          .eq('user_id', event.userId);

      if (event.courseId != null) {
        query = query.eq('course_id', event.courseId!);
      }

      final response = await query.order('started_at', ascending: false);

      final attempts = response
          .map((data) => QuizAttempt.fromJson(data))
          .toList();

      emit(QuizHistoryLoaded(attempts: attempts));
    } catch (e) {
      emit(QuizError(message: 'Failed to load quiz history: $e'));
    }
  }

  /// Update quiz timer
  Future<void> _onQuizTimerUpdated(
    QuizTimerUpdated event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    
    if (event.remainingTime.inSeconds <= 0) {
      add(QuizTimerExpired());
      return;
    }

    emit(currentState.copyWith(
      timeRemaining: event.remainingTime,
      timeSpent: currentState.quiz.timeLimit - event.remainingTime,
    ));
  }

  /// Handle timer expiration
  Future<void> _onQuizTimerExpired(
    QuizTimerExpired event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    _quizTimer?.cancel();

    // Auto-submit quiz
    if (_currentAttemptId != null) {
      add(QuizSubmitRequested(
        quizId: currentState.quiz.id,
        userId: _currentAttemptId!,
        answers: currentState.answers,
        totalTimeSpent: currentState.timeSpent,
      ));
    } else {
      emit(QuizTimeExpired(
        quiz: currentState.quiz,
        answers: currentState.answers,
        autoSubmitted: false,
      ));
    }
  }

  /// Pause quiz
  Future<void> _onQuizPauseRequested(
    QuizPauseRequested event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    _quizTimer?.cancel();
    
    emit(currentState.copyWith(isPaused: true));
  }

  /// Resume quiz
  Future<void> _onQuizResumeRequested(
    QuizResumeRequested event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    emit(currentState.copyWith(isPaused: false));
    
    _startQuizTimer(currentState.timeRemaining);
  }

  /// Save quiz progress
  Future<void> _onQuizProgressSaved(
    QuizProgressSaved event,
    Emitter<QuizState> emit,
  ) async {
    try {
      await supabase
          .from('quiz_attempts')
          .update({
            'current_question_index': event.currentQuestionIndex,
            'answers': event.answers,
            'time_spent_seconds': event.timeSpent.inSeconds,
          })
          .eq('id', event.userId);
    } catch (e) {
      // Silent failure for progress saving
      print('Failed to save quiz progress: $e');
    }
  }

  /// Load saved progress
  Future<void> _onQuizProgressLoaded(
    QuizProgressLoaded event,
    Emitter<QuizState> emit,
  ) async {
    // Implementation would load saved progress from database
  }

  /// Clear quiz state
  Future<void> _onQuizCleared(
    QuizCleared event,
    Emitter<QuizState> emit,
  ) async {
    _quizTimer?.cancel();
    _currentAttemptId = null;
    emit(QuizInitial());
  }

  /// Flag question for review
  Future<void> _onQuizQuestionFlagged(
    QuizQuestionFlagged event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizInProgress) return;

    final currentState = state as QuizInProgress;
    final updatedFlags = Set<String>.from(currentState.flaggedQuestions);
    
    if (event.isFlagged) {
      updatedFlags.add(event.questionId);
    } else {
      updatedFlags.remove(event.questionId);
    }

    emit(currentState.copyWith(flaggedQuestions: updatedFlags));
  }

  /// Start quiz timer
  void _startQuizTimer(Duration timeLimit) {
    _quizTimer?.cancel();
    
    const tickInterval = Duration(seconds: 1);
    var remaining = timeLimit;

    _quizTimer = Timer.periodic(tickInterval, (timer) {
      remaining = remaining - tickInterval;
      
      if (remaining.inSeconds <= 0) {
        timer.cancel();
        add(QuizTimerExpired());
      } else {
        add(QuizTimerUpdated(remainingTime: remaining));
      }
    });
  }

  /// Shuffle questions for randomization
  List<QuizQuestion> _shuffleQuestions(List<QuizQuestion> questions) {
    final shuffled = List<QuizQuestion>.from(questions);
    shuffled.shuffle(Random());
    return shuffled;
  }

  /// Calculate quiz results and scoring
  QuizResults _calculateQuizResults(Quiz quiz, Map<String, dynamic> answers) {
    final questionResults = <QuestionResult>[];
    int totalScore = 0;
    int totalPoints = 0;

    for (final question in quiz.questions) {
      totalPoints += question.points;
      final userAnswer = answers[question.id];
      final isCorrect = _isAnswerCorrect(question, userAnswer);
      final earnedPoints = isCorrect ? question.points : 0;
      
      totalScore += earnedPoints;

      questionResults.add(QuestionResult(
        questionId: question.id,
        question: question.question,
        userAnswer: userAnswer,
        correctAnswer: question.correctAnswer,
        isCorrect: isCorrect,
        points: question.points,
        earnedPoints: earnedPoints,
        explanation: question.explanation,
      ));
    }

    final percentage = totalPoints > 0 ? (totalScore / totalPoints) * 100 : 0.0;
    final isPassed = percentage >= quiz.passingScore;

    return QuizResults(
      attemptId: _currentAttemptId ?? '',
      score: totalScore,
      totalPoints: totalPoints,
      percentage: percentage,
      isPassed: isPassed,
      timeSpent: Duration.zero, // Would be calculated from timer
      questionResults: questionResults,
      feedback: _generateFeedback(percentage, isPassed),
    );
  }

  /// Check if answer is correct
  bool _isAnswerCorrect(QuizQuestion question, dynamic userAnswer) {
    if (userAnswer == null) return false;

    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
      case QuestionType.fillInTheBlank:
        return userAnswer == question.correctAnswer;
      
      case QuestionType.multipleSelect:
        final userAnswers = Set.from(userAnswer as List);
        final correctAnswers = Set.from(question.correctAnswer as List);
        return userAnswers.length == correctAnswers.length &&
               userAnswers.every(correctAnswers.contains);
      
      case QuestionType.essay:
        // Essay questions require manual grading
        return false;
      
      case QuestionType.matching:
        // Would implement matching logic
        return false;
    }
  }

  /// Generate feedback based on performance
  String _generateFeedback(double percentage, bool isPassed) {
    if (percentage >= 90) {
      return 'Excellent work! You have mastered this material.';
    } else if (percentage >= 80) {
      return 'Great job! You have a solid understanding of the concepts.';
    } else if (percentage >= 70) {
      return 'Good work! You passed, but consider reviewing some topics.';
    } else if (percentage >= 60) {
      return 'You need to study more. Review the lesson materials and try again.';
    } else {
      return 'Please review the lesson carefully and try again when ready.';
    }
  }
}