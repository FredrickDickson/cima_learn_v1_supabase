import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz.dart';
import 'enhanced_auth_service.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final EnhancedAuthService _authService = EnhancedAuthService();

  // Get all quizzes for a course
  Future<List<Quiz>> getCourseQuizzes(String courseId) async {
    try {
      final response = await _supabase
          .from('quizzes')
          .select()
          .eq('course_id', courseId)
          .order('created_at');

      return response.map((quiz) => Quiz.fromJson(quiz)).toList();
    } catch (e) {
      debugPrint('Error fetching course quizzes: $e');
      return [];
    }
  }

  // Get a specific quiz
  Future<Quiz?> getQuiz(String quizId) async {
    try {
      final response = await _supabase
          .from('quizzes')
          .select()
          .eq('id', quizId)
          .single();

      return Quiz.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching quiz: $e');
      return null;
    }
  }

  // Get user's quiz attempts
  Future<List<QuizAttempt>> getUserQuizAttempts(String quizId) async {
    if (!_authService.isAuthenticated) return [];

    try {
      final response = await _supabase
          .from('quiz_attempts')
          .select()
          .eq('quiz_id', quizId)
          .eq('user_id', _authService.userId)
          .order('attempt_number', ascending: false);

      return response.map((attempt) => QuizAttempt.fromJson(attempt)).toList();
    } catch (e) {
      debugPrint('Error fetching quiz attempts: $e');
      return [];
    }
  }

  // Get user's best attempt for a quiz
  Future<QuizAttempt?> getUserBestAttempt(String quizId) async {
    if (!_authService.isAuthenticated) return null;

    try {
      final response = await _supabase
          .from('quiz_attempts')
          .select()
          .eq('quiz_id', quizId)
          .eq('user_id', _authService.userId)
          .order('percentage', ascending: false)
          .limit(1)
          .maybeSingle();

      return response != null ? QuizAttempt.fromJson(response) : null;
    } catch (e) {
      debugPrint('Error fetching best attempt: $e');
      return null;
    }
  }

  // Start a new quiz attempt
  Future<String?> startQuizAttempt(String quizId) async {
    if (!_authService.isAuthenticated) {
      throw Exception('User must be authenticated to start quiz');
    }

    try {
      // Check if user has exceeded max attempts
      final attempts = await getUserQuizAttempts(quizId);
      final quiz = await getQuiz(quizId);
      
      if (quiz != null && attempts.length >= quiz.maxAttempts) {
        throw Exception('Maximum attempts exceeded for this quiz');
      }

      // Create new attempt record
      final attemptId = _generateAttemptId();
      final attemptNumber = attempts.length + 1;

      await _supabase.from('quiz_attempts').insert({
        'id': attemptId,
        'quiz_id': quizId,
        'user_id': _authService.userId,
        'attempt_number': attemptNumber,
        'started_at': DateTime.now().toIso8601String(),
        'answers': <String, dynamic>{},
        'score': 0,
        'total_points': quiz?.totalPoints ?? 0,
        'percentage': 0.0,
        'is_passed': false,
      });

      return attemptId;
    } catch (e) {
      debugPrint('Error starting quiz attempt: $e');
      rethrow;
    }
  }

  // Submit quiz answers
  Future<QuizAttempt> submitQuizAttempt({
    required String attemptId,
    required String quizId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final quiz = await getQuiz(quizId);
      if (quiz == null) {
        throw Exception('Quiz not found');
      }

      // Calculate score
      int score = 0;
      int totalPoints = quiz.totalPoints;

      for (var question in quiz.questions) {
        final userAnswer = answers[question.id];
        if (userAnswer != null && question.isAnswerCorrect(userAnswer)) {
          score += question.points;
        }
      }

      final percentage = totalPoints > 0 ? (score / totalPoints) * 100 : 0.0;
      final isPassed = percentage >= quiz.passingScore;

      // Update attempt record
      final updateData = {
        'answers': answers,
        'score': score,
        'total_points': totalPoints,
        'percentage': percentage,
        'is_passed': isPassed,
        'completed_at': DateTime.now().toIso8601String(),
      };

      // Calculate time taken
      final attemptResponse = await _supabase
          .from('quiz_attempts')
          .select('started_at')
          .eq('id', attemptId)
          .single();

      final startedAt = DateTime.parse(attemptResponse['started_at']);
      final timeTaken = DateTime.now().difference(startedAt);
      updateData['time_taken'] = timeTaken.inSeconds;

      await _supabase
          .from('quiz_attempts')
          .update(updateData)
          .eq('id', attemptId);

      // Return updated attempt
      final updatedResponse = await _supabase
          .from('quiz_attempts')
          .select()
          .eq('id', attemptId)
          .single();

      return QuizAttempt.fromJson(updatedResponse);
    } catch (e) {
      debugPrint('Error submitting quiz attempt: $e');
      rethrow;
    }
  }

  // Save quiz progress (for partial saves)
  Future<void> saveQuizProgress({
    required String attemptId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      await _supabase
          .from('quiz_attempts')
          .update({
            'answers': answers,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', attemptId);
    } catch (e) {
      debugPrint('Error saving quiz progress: $e');
    }
  }

  // Check if user can take quiz
  Future<bool> canUserTakeQuiz(String quizId) async {
    if (!_authService.isAuthenticated) return false;

    try {
      final quiz = await getQuiz(quizId);
      if (quiz == null) return false;

      // Check if quiz is available
      if (!quiz.isAvailable) return false;

      // Check if user is enrolled in the course
      final isEnrolled = await _authService.isEnrolledInCourse(quiz.courseId);
      if (!isEnrolled) return false;

      // Check max attempts
      final attempts = await getUserQuizAttempts(quizId);
      if (attempts.length >= quiz.maxAttempts) {
        // Check if user has already passed
        final bestAttempt = await getUserBestAttempt(quizId);
        return bestAttempt?.isPassed != true;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking quiz eligibility: $e');
      return false;
    }
  }

  // Get quiz statistics for a course
  Future<Map<String, dynamic>> getCourseQuizStatistics(String courseId) async {
    if (!_authService.isAuthenticated) return {};

    try {
      final response = await _supabase
          .from('quiz_attempts')
          .select('''
            quiz_id,
            is_passed,
            percentage,
            completed_at,
            quizzes!inner(course_id)
          ''')
          .eq('user_id', _authService.userId)
          .eq('quizzes.course_id', courseId)
          .not('completed_at', 'is', null);

      final attempts = response as List;
      
      if (attempts.isEmpty) {
        return {
          'total_quizzes': 0,
          'completed_quizzes': 0,
          'passed_quizzes': 0,
          'average_score': 0.0,
          'completion_percentage': 0.0,
        };
      }

      // Get unique quizzes and their best attempts
      final Map<String, Map<String, dynamic>> bestAttempts = {};
      
      for (var attempt in attempts) {
        final quizId = attempt['quiz_id'];
        final percentage = (attempt['percentage'] ?? 0.0).toDouble();
        
        if (!bestAttempts.containsKey(quizId) || 
            percentage > (bestAttempts[quizId]!['percentage'] ?? 0.0)) {
          bestAttempts[quizId] = attempt;
        }
      }

      final completedQuizzes = bestAttempts.length;
      final passedQuizzes = bestAttempts.values
          .where((attempt) => attempt['is_passed'] == true)
          .length;
      
      final averageScore = bestAttempts.values
          .map((attempt) => (attempt['percentage'] ?? 0.0).toDouble())
          .fold(0.0, (sum, score) => sum + score) / completedQuizzes;

      // Get total quizzes for the course
      final totalQuizzesResponse = await _supabase
          .from('quizzes')
          .select('id')
          .eq('course_id', courseId);
      
      final totalQuizzes = totalQuizzesResponse.length;
      final completionPercentage = totalQuizzes > 0 
          ? (completedQuizzes / totalQuizzes) * 100 
          : 0.0;

      return {
        'total_quizzes': totalQuizzes,
        'completed_quizzes': completedQuizzes,
        'passed_quizzes': passedQuizzes,
        'average_score': averageScore,
        'completion_percentage': completionPercentage,
      };
    } catch (e) {
      debugPrint('Error fetching quiz statistics: $e');
      return {};
    }
  }

  // Generate unique attempt ID
  String _generateAttemptId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = _authService.userId.substring(0, 8);
    return 'attempt_${userId}_$timestamp';
  }

  // Create sample quiz data for a course
  Future<void> createSampleQuiz(String courseId, String courseTitle) async {
    try {
      final quizId = 'quiz_${courseId}_assessment';
      
      // Sample quiz questions based on CIMA/arbitration content
      final sampleQuiz = Quiz(
        id: quizId,
        courseId: courseId,
        title: '$courseTitle - Assessment Quiz',
        description: 'Test your understanding of the key concepts covered in this course.',
        timeLimit: 30,
        passingScore: 70,
        isRequired: true,
        maxAttempts: 3,
        questions: [
          QuizQuestion(
            id: '${quizId}_q1',
            question: 'What is the primary role of an arbitrator in dispute resolution?',
            type: QuestionType.singleChoice,
            points: 2,
            options: [
              QuestionOption(id: 'a', text: 'To mediate between parties', isCorrect: false),
              QuestionOption(id: 'b', text: 'To make binding decisions on disputes', isCorrect: true),
              QuestionOption(id: 'c', text: 'To provide legal advice to both parties', isCorrect: false),
              QuestionOption(id: 'd', text: 'To facilitate negotiations only', isCorrect: false),
            ],
            correctAnswer: 'b',
            explanation: 'An arbitrator acts as a private judge who makes binding decisions on disputes after hearing evidence and arguments from all parties.',
          ),
          QuizQuestion(
            id: '${quizId}_q2',
            question: 'Which of the following are key principles of mediation? (Select all that apply)',
            type: QuestionType.multipleChoice,
            points: 3,
            options: [
              QuestionOption(id: 'a', text: 'Voluntary participation', isCorrect: true),
              QuestionOption(id: 'b', text: 'Confidentiality', isCorrect: true),
              QuestionOption(id: 'c', text: 'Public hearings', isCorrect: false),
              QuestionOption(id: 'd', text: 'Neutral third party', isCorrect: true),
            ],
            correctAnswers: ['a', 'b', 'd'],
            explanation: 'Mediation is based on voluntary participation, confidentiality, and the involvement of a neutral third party. Hearings are typically private, not public.',
          ),
          QuizQuestion(
            id: '${quizId}_q3',
            question: 'The UNCITRAL Arbitration Rules are internationally recognized.',
            type: QuestionType.trueFalse,
            points: 1,
            options: [
              QuestionOption(id: 'true', text: 'True', isCorrect: true),
              QuestionOption(id: 'false', text: 'False', isCorrect: false),
            ],
            correctAnswer: 'true',
            explanation: 'The UNCITRAL Arbitration Rules are widely recognized and used internationally for commercial arbitration.',
          ),
        ],
      );

      // Insert quiz into database
      await _supabase.from('quizzes').upsert(sampleQuiz.toJson());
      
      debugPrint('Sample quiz created for course: $courseTitle');
    } catch (e) {
      debugPrint('Error creating sample quiz: $e');
    }
  }
}