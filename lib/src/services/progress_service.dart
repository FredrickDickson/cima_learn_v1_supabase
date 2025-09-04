import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_progress.dart';
import '../models/course.dart';

class ProgressService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Enroll user in a course
  Future<CourseProgress> enrollInCourse({
    required String userId,
    required Course course,
  }) async {
    try {
      // Check if already enrolled
      final existingEnrollment = await _supabase
          .from('course_progress')
          .select()
          .eq('user_id', userId)
          .eq('course_id', course.id)
          .maybeSingle();

      if (existingEnrollment != null) {
        return CourseProgress.fromJson(existingEnrollment);
      }

      // Create new enrollment
      final progressData = {
        'user_id': userId,
        'course_id': course.id,
        'course_title': course.title,
        'progress_percentage': 0.0,
        'completed_modules': 0,
        'total_modules': 10, // Default module count
        'enrollment_date': DateTime.now().toIso8601String(),
        'last_accessed_at': DateTime.now().toIso8601String(),
        'status': 'enrolled',
      };

      final response = await _supabase
          .from('course_progress')
          .insert(progressData)
          .select()
          .single();

      return CourseProgress.fromJson(response);
    } catch (e) {
      throw Exception('Failed to enroll in course: $e');
    }
  }

  // Get user's course progress
  Future<List<CourseProgress>> getUserCourseProgress(String userId) async {
    try {
      final response = await _supabase
          .from('course_progress')
          .select()
          .eq('user_id', userId)
          .order('last_accessed_at', ascending: false);

      return response.map((json) => CourseProgress.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch course progress: $e');
    }
  }

  // Get specific course progress
  Future<CourseProgress?> getCourseProgress({
    required String userId,
    required String courseId,
  }) async {
    try {
      final response = await _supabase
          .from('course_progress')
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();

      return response != null ? CourseProgress.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to fetch course progress: $e');
    }
  }

  // Update course progress
  Future<CourseProgress> updateProgress({
    required String userId,
    required String courseId,
    double? progressPercentage,
    int? completedModules,
    List<ModuleProgress>? moduleProgress,
    double? overallScore,
  }) async {
    try {
      final updateData = {
        'last_accessed_at': DateTime.now().toIso8601String(),
      };

      if (progressPercentage != null) {
        updateData['progress_percentage'] = progressPercentage;
        
        // Update status based on progress
        if (progressPercentage >= 100) {
          updateData['status'] = 'completed';
          updateData['completion_date'] = DateTime.now().toIso8601String();
        } else if (progressPercentage > 0) {
          updateData['status'] = 'in_progress';
        }
      }

      if (completedModules != null) {
        updateData['completed_modules'] = completedModules;
      }

      if (moduleProgress != null) {
        updateData['module_progress'] = moduleProgress.map((e) => e.toJson()).toList();
      }

      if (overallScore != null) {
        updateData['overall_score'] = overallScore;
      }

      await _supabase
          .from('course_progress')
          .update(updateData)
          .eq('user_id', userId)
          .eq('course_id', courseId);

      // Fetch updated progress
      final updatedProgress = await getCourseProgress(
        userId: userId,
        courseId: courseId,
      );

      if (updatedProgress == null) {
        throw Exception('Failed to fetch updated progress');
      }

      return updatedProgress;
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  // Complete a module
  Future<void> completeModule({
    required String userId,
    required String courseId,
    required String moduleId,
    required String moduleTitle,
    double? score,
    Duration? timeSpent,
  }) async {
    try {
      // Get current progress
      final currentProgress = await getCourseProgress(
        userId: userId,
        courseId: courseId,
      );

      if (currentProgress == null) {
        throw Exception('Course progress not found');
      }

      // Update module progress
      final updatedModuleProgress = List<ModuleProgress>.from(currentProgress.moduleProgress);
      final moduleIndex = updatedModuleProgress.indexWhere((m) => m.moduleId == moduleId);

      final completedModule = ModuleProgress(
        moduleId: moduleId,
        moduleTitle: moduleTitle,
        isCompleted: true,
        score: score,
        timeSpent: timeSpent ?? Duration.zero,
        completedAt: DateTime.now(),
      );

      if (moduleIndex >= 0) {
        updatedModuleProgress[moduleIndex] = completedModule;
      } else {
        updatedModuleProgress.add(completedModule);
      }

      // Calculate new progress percentage
      final completedCount = updatedModuleProgress.where((m) => m.isCompleted).length;
      final progressPercentage = (completedCount / currentProgress.totalModules * 100).clamp(0.0, 100.0);

      // Update progress
      await updateProgress(
        userId: userId,
        courseId: courseId,
        progressPercentage: progressPercentage,
        completedModules: completedCount,
        moduleProgress: updatedModuleProgress,
      );
    } catch (e) {
      throw Exception('Failed to complete module: $e');
    }
  }

  // Get user learning statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final progressList = await getUserCourseProgress(userId);
      
      final totalCourses = progressList.length;
      final completedCourses = progressList.where((p) => p.isCompleted).length;
      final inProgressCourses = progressList.where((p) => p.isInProgress).length;
      
      final totalProgress = progressList.isEmpty 
          ? 0.0 
          : progressList.map((p) => p.progressPercentage).reduce((a, b) => a + b) / totalCourses;
      
      final averageScore = progressList
          .where((p) => p.overallScore != null)
          .map((p) => p.overallScore!)
          .isEmpty 
            ? 0.0 
            : progressList
                .where((p) => p.overallScore != null)
                .map((p) => p.overallScore!)
                .reduce((a, b) => a + b) / 
              progressList.where((p) => p.overallScore != null).length;

      final totalTimeSpent = progressList
          .expand((p) => p.moduleProgress)
          .map((m) => m.timeSpent)
          .fold(Duration.zero, (a, b) => a + b);

      return {
        'totalCourses': totalCourses,
        'completedCourses': completedCourses,
        'inProgressCourses': inProgressCourses,
        'averageProgress': totalProgress,
        'averageScore': averageScore,
        'totalTimeSpent': totalTimeSpent,
        'completionRate': totalCourses > 0 ? (completedCourses / totalCourses * 100) : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to fetch user statistics: $e');
    }
  }
}