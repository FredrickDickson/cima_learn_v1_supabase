import 'package:equatable/equatable.dart';

/// Quiz states for the QuizBloc
sealed class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class QuizInitial extends QuizState {}

/// State when quiz is being loaded
class QuizLoading extends QuizState {}

/// State when quiz is loaded and ready to start
class QuizLoaded extends QuizState {
  const QuizLoaded({
    required this.quiz,
    required this.previousAttempts,
    required this.canRetake,
    required this.maxAttempts,
  });

  final Quiz quiz;
  final List<QuizAttempt> previousAttempts;
  final bool canRetake;
  final int maxAttempts;

  @override
  List<Object> get props => [quiz, previousAttempts, canRetake, maxAttempts];
}

/// State when quiz is in progress
class QuizInProgress extends QuizState {
  const QuizInProgress({
    required this.quiz,
    required this.currentQuestionIndex,
    required this.answers,
    required this.flaggedQuestions,
    required this.timeRemaining,
    required this.timeSpent,
    this.isPaused = false,
  });

  final Quiz quiz;
  final int currentQuestionIndex;
  final Map<String, dynamic> answers;
  final Set<String> flaggedQuestions;
  final Duration timeRemaining;
  final Duration timeSpent;
  final bool isPaused;

  QuizQuestion get currentQuestion => quiz.questions[currentQuestionIndex];
  bool get isFirstQuestion => currentQuestionIndex == 0;
  bool get isLastQuestion => currentQuestionIndex == quiz.questions.length - 1;
  int get totalQuestions => quiz.questions.length;
  int get answeredQuestions => answers.length;
  double get progressPercentage => answeredQuestions / totalQuestions;

  @override
  List<Object> get props => [
    quiz, currentQuestionIndex, answers, flaggedQuestions, 
    timeRemaining, timeSpent, isPaused
  ];

  QuizInProgress copyWith({
    int? currentQuestionIndex,
    Map<String, dynamic>? answers,
    Set<String>? flaggedQuestions,
    Duration? timeRemaining,
    Duration? timeSpent,
    bool? isPaused,
  }) {
    return QuizInProgress(
      quiz: quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      flaggedQuestions: flaggedQuestions ?? this.flaggedQuestions,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      timeSpent: timeSpent ?? this.timeSpent,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

/// State when quiz is being submitted
class QuizSubmitting extends QuizState {
  const QuizSubmitting({
    required this.quiz,
    required this.answers,
  });

  final Quiz quiz;
  final Map<String, dynamic> answers;

  @override
  List<Object> get props => [quiz, answers];
}

/// State when quiz results are available
class QuizCompleted extends QuizState {
  const QuizCompleted({
    required this.results,
    required this.canRetake,
    required this.nextAttemptAvailableAt,
  });

  final QuizResults results;
  final bool canRetake;
  final DateTime? nextAttemptAvailableAt;

  @override
  List<Object?> get props => [results, canRetake, nextAttemptAvailableAt];
}

/// State when quiz history is loaded
class QuizHistoryLoaded extends QuizState {
  const QuizHistoryLoaded({required this.attempts});

  final List<QuizAttempt> attempts;

  @override
  List<Object> get props => [attempts];
}

/// State when quiz encounters an error
class QuizError extends QuizState {
  const QuizError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// State when quiz time expires
class QuizTimeExpired extends QuizState {
  const QuizTimeExpired({
    required this.quiz,
    required this.answers,
    required this.autoSubmitted,
  });

  final Quiz quiz;
  final Map<String, dynamic> answers;
  final bool autoSubmitted;

  @override
  List<Object> get props => [quiz, answers, autoSubmitted];
}

/// Quiz model
class Quiz extends Equatable {
  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonId,
    required this.courseId,
    required this.questions,
    required this.timeLimit,
    required this.passingScore,
    required this.maxAttempts,
    required this.isRandomized,
    required this.showResultsImmediately,
    this.instructions,
  });

  final String id;
  final String title;
  final String description;
  final String lessonId;
  final String courseId;
  final List<QuizQuestion> questions;
  final Duration timeLimit;
  final double passingScore;
  final int maxAttempts;
  final bool isRandomized;
  final bool showResultsImmediately;
  final String? instructions;

  @override
  List<Object?> get props => [
    id, title, description, lessonId, courseId, questions, timeLimit,
    passingScore, maxAttempts, isRandomized, showResultsImmediately, instructions
  ];

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      lessonId: json['lesson_id'],
      courseId: json['course_id'],
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      timeLimit: Duration(minutes: json['time_limit_minutes'] ?? 30),
      passingScore: (json['passing_score'] as num?)?.toDouble() ?? 70.0,
      maxAttempts: json['max_attempts'] ?? 3,
      isRandomized: json['is_randomized'] ?? false,
      showResultsImmediately: json['show_results_immediately'] ?? true,
      instructions: json['instructions'],
    );
  }
}

/// Quiz question model
class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.points,
    this.explanation,
    this.imageUrl,
  });

  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final dynamic correctAnswer;
  final int points;
  final String? explanation;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    id, question, type, options, correctAnswer, points, explanation, imageUrl
  ];

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      type: QuestionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'],
      points: json['points'] ?? 1,
      explanation: json['explanation'],
      imageUrl: json['image_url'],
    );
  }
}

/// Question types
enum QuestionType {
  multipleChoice,
  multipleSelect,
  trueFalse,
  fillInTheBlank,
  essay,
  matching,
}

/// Quiz attempt model
class QuizAttempt extends Equatable {
  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalPoints,
    required this.timeSpent,
    required this.startedAt,
    required this.completedAt,
    required this.isPassed,
  });

  final String id;
  final String quizId;
  final String userId;
  final int score;
  final int totalPoints;
  final Duration timeSpent;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isPassed;

  double get percentage => (score / totalPoints) * 100;

  @override
  List<Object?> get props => [
    id, quizId, userId, score, totalPoints, timeSpent, 
    startedAt, completedAt, isPassed
  ];

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      quizId: json['quiz_id'],
      userId: json['user_id'],
      score: json['score'],
      totalPoints: json['total_points'],
      timeSpent: Duration(seconds: json['time_spent_seconds']),
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      isPassed: json['is_passed'] ?? false,
    );
  }
}

/// Quiz results model
class QuizResults extends Equatable {
  const QuizResults({
    required this.attemptId,
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.isPassed,
    required this.timeSpent,
    required this.questionResults,
    this.feedback,
  });

  final String attemptId;
  final int score;
  final int totalPoints;
  final double percentage;
  final bool isPassed;
  final Duration timeSpent;
  final List<QuestionResult> questionResults;
  final String? feedback;

  @override
  List<Object?> get props => [
    attemptId, score, totalPoints, percentage, isPassed, 
    timeSpent, questionResults, feedback
  ];
}

/// Individual question result
class QuestionResult extends Equatable {
  const QuestionResult({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.points,
    required this.earnedPoints,
    this.explanation,
  });

  final String questionId;
  final String question;
  final dynamic userAnswer;
  final dynamic correctAnswer;
  final bool isCorrect;
  final int points;
  final int earnedPoints;
  final String? explanation;

  @override
  List<Object?> get props => [
    questionId, question, userAnswer, correctAnswer, 
    isCorrect, points, earnedPoints, explanation
  ];
}