import 'package:equatable/equatable.dart';

/// Quiz events for the QuizBloc
sealed class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load quiz for a specific lesson
class QuizLoadRequested extends QuizEvent {
  const QuizLoadRequested({
    required this.lessonId,
    required this.userId,
  });

  final String lessonId;
  final String userId;

  @override
  List<Object> get props => [lessonId, userId];
}

/// Event to start quiz session
class QuizStartRequested extends QuizEvent {
  const QuizStartRequested({
    required this.quizId,
    required this.userId,
  });

  final String quizId;
  final String userId;

  @override
  List<Object> get props => [quizId, userId];
}

/// Event to answer a question
class QuizQuestionAnswered extends QuizEvent {
  const QuizQuestionAnswered({
    required this.questionId,
    required this.selectedAnswer,
    this.timeSpent,
  });

  final String questionId;
  final dynamic selectedAnswer; // Can be String, List<String>, etc.
  final Duration? timeSpent;

  @override
  List<Object?> get props => [questionId, selectedAnswer, timeSpent];
}

/// Event to navigate to next question
class QuizNextQuestionRequested extends QuizEvent {}

/// Event to navigate to previous question
class QuizPreviousQuestionRequested extends QuizEvent {}

/// Event to skip current question
class QuizQuestionSkipped extends QuizEvent {
  const QuizQuestionSkipped({required this.questionId});

  final String questionId;

  @override
  List<Object> get props => [questionId];
}

/// Event to submit quiz for grading
class QuizSubmitRequested extends QuizEvent {
  const QuizSubmitRequested({
    required this.quizId,
    required this.userId,
    required this.answers,
    required this.totalTimeSpent,
  });

  final String quizId;
  final String userId;
  final Map<String, dynamic> answers;
  final Duration totalTimeSpent;

  @override
  List<Object> get props => [quizId, userId, answers, totalTimeSpent];
}

/// Event to load quiz results
class QuizResultsRequested extends QuizEvent {
  const QuizResultsRequested({
    required this.attemptId,
    required this.userId,
  });

  final String attemptId;
  final String userId;

  @override
  List<Object> get props => [attemptId, userId];
}

/// Event to retry quiz
class QuizRetryRequested extends QuizEvent {
  const QuizRetryRequested({
    required this.quizId,
    required this.userId,
  });

  final String quizId;
  final String userId;

  @override
  List<Object> get props => [quizId, userId];
}

/// Event to load quiz history/attempts
class QuizHistoryRequested extends QuizEvent {
  const QuizHistoryRequested({
    required this.userId,
    this.courseId,
  });

  final String userId;
  final String? courseId;

  @override
  List<Object?> get props => [userId, courseId];
}

/// Event to update quiz timer
class QuizTimerUpdated extends QuizEvent {
  const QuizTimerUpdated({required this.remainingTime});

  final Duration remainingTime;

  @override
  List<Object> get props => [remainingTime];
}

/// Event when quiz timer expires
class QuizTimerExpired extends QuizEvent {}

/// Event to pause quiz
class QuizPauseRequested extends QuizEvent {}

/// Event to resume quiz
class QuizResumeRequested extends QuizEvent {}

/// Event to save quiz progress
class QuizProgressSaved extends QuizEvent {
  const QuizProgressSaved({
    required this.quizId,
    required this.userId,
    required this.currentQuestionIndex,
    required this.answers,
    required this.timeSpent,
  });

  final String quizId;
  final String userId;
  final int currentQuestionIndex;
  final Map<String, dynamic> answers;
  final Duration timeSpent;

  @override
  List<Object> get props => [quizId, userId, currentQuestionIndex, answers, timeSpent];
}

/// Event to load saved quiz progress
class QuizProgressLoaded extends QuizEvent {
  const QuizProgressLoaded({
    required this.quizId,
    required this.userId,
  });

  final String quizId;
  final String userId;

  @override
  List<Object> get props => [quizId, userId];
}

/// Event to clear quiz state
class QuizCleared extends QuizEvent {}

/// Event to flag question for review
class QuizQuestionFlagged extends QuizEvent {
  const QuizQuestionFlagged({
    required this.questionId,
    required this.isFlagged,
  });

  final String questionId;
  final bool isFlagged;

  @override
  List<Object> get props => [questionId, isFlagged];
}