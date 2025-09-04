class Quiz {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int timeLimit; // in minutes
  final int passingScore; // percentage
  final bool isRequired;
  final int maxAttempts;
  final DateTime? availableFrom;
  final DateTime? availableUntil;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.questions,
    this.timeLimit = 30,
    this.passingScore = 70,
    this.isRequired = false,
    this.maxAttempts = 3,
    this.availableFrom,
    this.availableUntil,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      timeLimit: json['time_limit'] ?? 30,
      passingScore: json['passing_score'] ?? 70,
      isRequired: json['is_required'] ?? false,
      maxAttempts: json['max_attempts'] ?? 3,
      availableFrom: json['available_from'] != null 
          ? DateTime.parse(json['available_from']) 
          : null,
      availableUntil: json['available_until'] != null 
          ? DateTime.parse(json['available_until']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'time_limit': timeLimit,
      'passing_score': passingScore,
      'is_required': isRequired,
      'max_attempts': maxAttempts,
      'available_from': availableFrom?.toIso8601String(),
      'available_until': availableUntil?.toIso8601String(),
    };
  }

  int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);
  
  bool get isAvailable {
    final now = DateTime.now();
    if (availableFrom != null && now.isBefore(availableFrom!)) return false;
    if (availableUntil != null && now.isAfter(availableUntil!)) return false;
    return true;
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<QuestionOption> options;
  final String? correctAnswer;
  final List<String> correctAnswers; // For multiple choice
  final String? explanation;
  final int points;
  final bool isRequired;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    this.correctAnswer,
    this.correctAnswers = const [],
    this.explanation,
    this.points = 1,
    this.isRequired = true,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      type: QuestionType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => QuestionType.singleChoice,
      ),
      options: (json['options'] as List)
          .map((o) => QuestionOption.fromJson(o))
          .toList(),
      correctAnswer: json['correct_answer'],
      correctAnswers: List<String>.from(json['correct_answers'] ?? []),
      explanation: json['explanation'],
      points: json['points'] ?? 1,
      isRequired: json['is_required'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type.toString().split('.').last,
      'options': options.map((o) => o.toJson()).toList(),
      'correct_answer': correctAnswer,
      'correct_answers': correctAnswers,
      'explanation': explanation,
      'points': points,
      'is_required': isRequired,
    };
  }

  bool isAnswerCorrect(dynamic userAnswer) {
    switch (type) {
      case QuestionType.singleChoice:
        return correctAnswer == userAnswer;
      case QuestionType.multipleChoice:
        if (userAnswer is! List<String>) return false;
        final userSet = Set<String>.from(userAnswer);
        final correctSet = Set<String>.from(correctAnswers);
        return userSet.length == correctSet.length &&
               userSet.containsAll(correctSet);
      case QuestionType.trueFalse:
        return correctAnswer == userAnswer.toString();
      case QuestionType.shortAnswer:
        return correctAnswer?.toLowerCase().trim() == 
               userAnswer?.toString().toLowerCase().trim();
      default:
        return false;
    }
  }
}

class QuestionOption {
  final String id;
  final String text;
  final bool isCorrect;

  QuestionOption({
    required this.id,
    required this.text,
    this.isCorrect = false,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_correct': isCorrect,
    };
  }
}

class QuizAttempt {
  final String id;
  final String quizId;
  final String userId;
  final Map<String, dynamic> answers;
  final int score;
  final int totalPoints;
  final double percentage;
  final bool isPassed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Duration? timeTaken;
  final int attemptNumber;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.answers,
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.isPassed,
    required this.startedAt,
    this.completedAt,
    this.timeTaken,
    required this.attemptNumber,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      quizId: json['quiz_id'],
      userId: json['user_id'],
      answers: Map<String, dynamic>.from(json['answers'] ?? {}),
      score: json['score'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      isPassed: json['is_passed'] ?? false,
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      timeTaken: json['time_taken'] != null 
          ? Duration(seconds: json['time_taken']) 
          : null,
      attemptNumber: json['attempt_number'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'answers': answers,
      'score': score,
      'total_points': totalPoints,
      'percentage': percentage,
      'is_passed': isPassed,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'time_taken': timeTaken?.inSeconds,
      'attempt_number': attemptNumber,
    };
  }

  String get grade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  bool get isCompleted => completedAt != null;
}

enum QuestionType {
  singleChoice,
  multipleChoice,
  trueFalse,
  shortAnswer,
  essay,
}