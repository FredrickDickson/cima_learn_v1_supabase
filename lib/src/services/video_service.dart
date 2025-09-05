import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_lesson.dart';
import 'storage_service.dart';
import 'dart:async';

/// Service for managing video lessons, progress tracking, and video operations
/// Handles video CRUD operations, progress synchronization, and analytics
class VideoService {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService.instance;

  // =====================================================================================
  // VIDEO LESSON MANAGEMENT
  // =====================================================================================

  /// Get video lesson by ID with user progress
  Future<VideoLesson?> getVideoLesson(String lessonId, String userId) async {
    try {
      // Get video lesson data
      final response = await _supabase
          .from('video_lessons')
          .select('''
            *,
            video_content,
            subtitles,
            metadata
          ''')
          .eq('id', lessonId)
          .single();

      if (response == null) return null;

      // Get user progress
      VideoProgress? progress;
      try {
        final progressResponse = await _supabase
            .from('video_progress')
            .select('*')
            .eq('lesson_id', lessonId)
            .eq('user_id', userId)
            .single();

        if (progressResponse != null) {
          progress = VideoProgress.fromJson(progressResponse);
        }
      } catch (e) {
        // Progress doesn't exist yet, which is fine
      }

      // Create video lesson with progress
      final videoLesson = VideoLesson.fromJson(response);
      
      return progress != null 
          ? videoLesson.copyWithProgress(progress)
          : videoLesson;

    } catch (e) {
      print('Error fetching video lesson: $e');
      return null;
    }
  }

  /// Get all video lessons for a course module
  Future<List<VideoLesson>> getModuleVideoLessons(String moduleId, String userId) async {
    try {
      final response = await _supabase
          .from('video_lessons')
          .select('''
            *,
            video_content,
            subtitles,
            metadata
          ''')
          .eq('module_id', moduleId)
          .order('order_index');

      final lessons = <VideoLesson>[];
      
      for (final lessonData in response) {
        // Get user progress for each lesson
        VideoProgress? progress;
        try {
          final progressResponse = await _supabase
              .from('video_progress')
              .select('*')
              .eq('lesson_id', lessonData['id'])
              .eq('user_id', userId)
              .single();

          if (progressResponse != null) {
            progress = VideoProgress.fromJson(progressResponse);
          }
        } catch (e) {
          // Progress doesn't exist, which is fine
        }

        final videoLesson = VideoLesson.fromJson(lessonData);
        lessons.add(progress != null 
            ? videoLesson.copyWithProgress(progress)
            : videoLesson);
      }

      return lessons;
    } catch (e) {
      print('Error fetching module video lessons: $e');
      return [];
    }
  }

  /// Create new video lesson
  Future<String?> createVideoLesson({
    required String moduleId,
    required String courseId,
    required String title,
    required String description,
    required int orderIndex,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final response = await _supabase
          .from('video_lessons')
          .insert({
            'module_id': moduleId,
            'course_id': courseId,
            'title': title,
            'description': description,
            'order_index': orderIndex,
            'video_content': {},
            'subtitles': {},
            'processing_status': VideoProcessingStatus.pending.value,
            'metadata': metadata,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error creating video lesson: $e');
      return null;
    }
  }

  /// Update video lesson
  Future<bool> updateVideoLesson(String lessonId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await _supabase
          .from('video_lessons')
          .update(updates)
          .eq('id', lessonId);

      return true;
    } catch (e) {
      print('Error updating video lesson: $e');
      return false;
    }
  }

  /// Delete video lesson
  Future<bool> deleteVideoLesson(String lessonId) async {
    try {
      // Delete associated video files from storage
      // This would typically be done via database triggers in production
      
      // Delete progress records
      await _supabase
          .from('video_progress')
          .delete()
          .eq('lesson_id', lessonId);

      // Delete the lesson
      await _supabase
          .from('video_lessons')
          .delete()
          .eq('id', lessonId);

      return true;
    } catch (e) {
      print('Error deleting video lesson: $e');
      return false;
    }
  }

  // =====================================================================================
  // VIDEO PROGRESS TRACKING
  // =====================================================================================

  /// Update or create video progress
  Future<bool> updateVideoProgress(VideoProgress progress) async {
    try {
      await _supabase
          .from('video_progress')
          .upsert(progress.toJson())
          .eq('lesson_id', progress.lessonId)
          .eq('user_id', progress.userId);

      return true;
    } catch (e) {
      print('Error updating video progress: $e');
      return false;
    }
  }

  /// Get user's video progress for a course
  Future<List<VideoProgress>> getCourseVideoProgress(String courseId, String userId) async {
    try {
      final response = await _supabase
          .from('video_progress')
          .select('''
            *,
            video_lessons!inner(course_id)
          ''')
          .eq('user_id', userId)
          .eq('video_lessons.course_id', courseId);

      return response.map<VideoProgress>((data) => VideoProgress.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching course video progress: $e');
      return [];
    }
  }

  /// Get user's overall learning analytics
  Future<Map<String, dynamic>> getUserVideoAnalytics(String userId) async {
    try {
      final response = await _supabase
          .from('video_progress')
          .select('''
            watch_time_seconds,
            completion_percentage,
            is_completed,
            lesson_id,
            video_lessons!inner(duration_seconds, course_id)
          ''')
          .eq('user_id', userId);

      int totalWatchTime = 0;
      int completedLessons = 0;
      double averageCompletion = 0.0;
      Set<String> coursesAccessed = {};

      for (final record in response) {
        totalWatchTime += record['watch_time_seconds'] as int;
        if (record['is_completed'] as bool) {
          completedLessons++;
        }
        averageCompletion += record['completion_percentage'] as double;
        coursesAccessed.add(record['video_lessons']['course_id'] as String);
      }

      if (response.isNotEmpty) {
        averageCompletion /= response.length;
      }

      return {
        'total_watch_time_seconds': totalWatchTime,
        'completed_lessons': completedLessons,
        'total_lessons_started': response.length,
        'average_completion_percentage': averageCompletion,
        'courses_accessed': coursesAccessed.length,
        'total_watch_time_formatted': _formatWatchTime(totalWatchTime),
      };
    } catch (e) {
      print('Error fetching user video analytics: $e');
      return {};
    }
  }

  // =====================================================================================
  // VIDEO UPLOAD AND PROCESSING
  // =====================================================================================

  /// Upload video for a lesson
  Future<String?> uploadVideoForLesson({
    required String lessonId,
    required String courseId,
    required String instructorId,
    Function(UploadProgress)? onProgress,
  }) async {
    try {
      // Upload video using storage service
      final videoUrl = await _storageService.uploadVideo(
        courseId: courseId,
        lessonId: lessonId,
        instructorId: instructorId,
        onProgress: onProgress,
      );

      if (videoUrl != null) {
        // Update lesson with video URL
        await updateVideoLesson(lessonId, {
          'processing_status': VideoProcessingStatus.processing.value,
        });

        // Add video content to lesson
        await _addVideoContentToLesson(lessonId, 'en', videoUrl);
      }

      return videoUrl;
    } catch (e) {
      print('Error uploading video for lesson: $e');
      return null;
    }
  }

  /// Add video content for a specific language
  Future<bool> _addVideoContentToLesson(String lessonId, String language, String videoUrl) async {
    try {
      // Get current video content
      final response = await _supabase
          .from('video_lessons')
          .select('video_content')
          .eq('id', lessonId)
          .single();

      final currentContent = response['video_content'] as Map<String, dynamic>? ?? {};
      
      // Add new video content
      currentContent[language] = {
        'raw_video_url': videoUrl,
        'hls_url': null, // Will be set after processing
        'dash_url': null,
        'qualities': {},
        'format': 'mp4',
        'bitrate': 0,
        'resolution': '720p',
        'file_size': 0.0,
      };

      // Update the lesson
      await updateVideoLesson(lessonId, {
        'video_content': currentContent,
      });

      return true;
    } catch (e) {
      print('Error adding video content to lesson: $e');
      return false;
    }
  }

  /// Update video processing status
  Future<bool> updateVideoProcessingStatus(String lessonId, VideoProcessingStatus status) async {
    return await updateVideoLesson(lessonId, {
      'processing_status': status.value,
    });
  }

  // =====================================================================================
  // VIDEO ANALYTICS AND INSIGHTS
  // =====================================================================================

  /// Get video engagement analytics for instructors
  Future<Map<String, dynamic>> getVideoEngagementAnalytics(String courseId) async {
    try {
      final response = await _supabase
          .from('video_progress')
          .select('''
            *,
            video_lessons!inner(course_id, title, duration_seconds)
          ''')
          .eq('video_lessons.course_id', courseId);

      final lessonAnalytics = <String, Map<String, dynamic>>{};
      
      for (final record in response) {
        final lessonId = record['lesson_id'] as String;
        final lessonTitle = record['video_lessons']['title'] as String;
        final duration = record['video_lessons']['duration_seconds'] as int;
        
        if (!lessonAnalytics.containsKey(lessonId)) {
          lessonAnalytics[lessonId] = {
            'title': lessonTitle,
            'duration': duration,
            'total_views': 0,
            'total_watch_time': 0,
            'completion_rate': 0.0,
            'average_progress': 0.0,
            'completions': 0,
          };
        }
        
        final analytics = lessonAnalytics[lessonId]!;
        analytics['total_views'] = (analytics['total_views'] as int) + 1;
        analytics['total_watch_time'] = (analytics['total_watch_time'] as int) + 
                                       (record['watch_time_seconds'] as int);
        
        if (record['is_completed'] as bool) {
          analytics['completions'] = (analytics['completions'] as int) + 1;
        }
      }

      // Calculate rates and averages
      for (final analytics in lessonAnalytics.values) {
        final totalViews = analytics['total_views'] as int;
        final completions = analytics['completions'] as int;
        
        if (totalViews > 0) {
          analytics['completion_rate'] = (completions / totalViews) * 100;
        }
      }

      return {
        'lesson_analytics': lessonAnalytics,
        'total_lessons': lessonAnalytics.length,
        'course_id': courseId,
      };
    } catch (e) {
      print('Error fetching video engagement analytics: $e');
      return {};
    }
  }

  /// Get popular video content
  Future<List<VideoLesson>> getPopularVideos({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('video_progress')
          .select('''
            lesson_id,
            count(*) as view_count,
            avg(completion_percentage) as avg_completion,
            video_lessons!inner(*)
          ''')
          .order('view_count', ascending: false)
          .limit(limit);

      final lessons = <VideoLesson>[];
      for (final record in response) {
        final lessonData = record['video_lessons'];
        lessons.add(VideoLesson.fromJson(lessonData));
      }

      return lessons;
    } catch (e) {
      print('Error fetching popular videos: $e');
      return [];
    }
  }

  // =====================================================================================
  // OFFLINE VIDEO MANAGEMENT
  // =====================================================================================

  /// Mark video as downloaded offline
  Future<bool> markVideoAsDownloaded(String lessonId, String userId, String downloadPath) async {
    try {
      await _supabase
          .from('offline_videos')
          .upsert({
            'lesson_id': lessonId,
            'user_id': userId,
            'download_path': downloadPath,
            'downloaded_at': DateTime.now().toIso8601String(),
            'file_size': 0, // Would be set with actual file size
          });

      return true;
    } catch (e) {
      print('Error marking video as downloaded: $e');
      return false;
    }
  }

  /// Get user's downloaded videos
  Future<List<String>> getUserDownloadedVideos(String userId) async {
    try {
      final response = await _supabase
          .from('offline_videos')
          .select('lesson_id')
          .eq('user_id', userId);

      return response.map<String>((record) => record['lesson_id'] as String).toList();
    } catch (e) {
      print('Error fetching downloaded videos: $e');
      return [];
    }
  }

  /// Remove offline video
  Future<bool> removeOfflineVideo(String lessonId, String userId) async {
    try {
      await _supabase
          .from('offline_videos')
          .delete()
          .eq('lesson_id', lessonId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error removing offline video: $e');
      return false;
    }
  }

  // =====================================================================================
  // UTILITY METHODS
  // =====================================================================================

  /// Format watch time for display
  String _formatWatchTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  /// Check if user has access to video lesson
  Future<bool> hasAccessToVideoLesson(String lessonId, String userId) async {
    try {
      // Check if user is enrolled in the course containing this lesson
      final response = await _supabase
          .from('video_lessons')
          .select('''
            course_id,
            courses!inner(
              enrollments!inner(user_id, status)
            )
          ''')
          .eq('id', lessonId)
          .eq('courses.enrollments.user_id', userId)
          .eq('courses.enrollments.status', 'active')
          .single();

      return response != null;
    } catch (e) {
      print('Error checking video lesson access: $e');
      return false;
    }
  }

  /// Stream video progress updates for real-time sync
  Stream<VideoProgress> streamVideoProgress(String lessonId, String userId) {
    return _supabase
        .from('video_progress')
        .stream(primaryKey: ['lesson_id', 'user_id'])
        .asyncMap((data) async {
          // Filter data based on the parameters
          final filteredData = data.where((item) => 
            item['lesson_id'].toString() == lessonId && 
            item['user_id'].toString() == userId
          ).toList();
          
          return filteredData.isNotEmpty 
            ? VideoProgress.fromJson(filteredData.first) 
            : VideoProgress(
                id: 'temp',
                userId: userId,
                lessonId: lessonId,
                lastWatchedAt: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
        });
  }

  /// Get next video lesson in sequence
  Future<VideoLesson?> getNextVideoLesson(String currentLessonId, String userId) async {
    try {
      // Get current lesson info
      final currentLesson = await _supabase
          .from('video_lessons')
          .select('module_id, order_index')
          .eq('id', currentLessonId)
          .single();

      if (currentLesson == null) return null;

      // Find next lesson in the same module
      final nextLesson = await _supabase
          .from('video_lessons')
          .select('*')
          .eq('module_id', currentLesson['module_id'])
          .gt('order_index', currentLesson['order_index'])
          .order('order_index')
          .limit(1)
          .single();

      if (nextLesson != null) {
        return await getVideoLesson(nextLesson['id'], userId);
      }

      return null;
    } catch (e) {
      print('Error getting next video lesson: $e');
      return null;
    }
  }

  /// Get previous video lesson in sequence
  Future<VideoLesson?> getPreviousVideoLesson(String currentLessonId, String userId) async {
    try {
      // Get current lesson info
      final currentLesson = await _supabase
          .from('video_lessons')
          .select('module_id, order_index')
          .eq('id', currentLessonId)
          .single();

      if (currentLesson == null) return null;

      // Find previous lesson in the same module
      final previousLesson = await _supabase
          .from('video_lessons')
          .select('*')
          .eq('module_id', currentLesson['module_id'])
          .lt('order_index', currentLesson['order_index'])
          .order('order_index', ascending: false)
          .limit(1)
          .single();

      if (previousLesson != null) {
        return await getVideoLesson(previousLesson['id'], userId);
      }

      return null;
    } catch (e) {
      print('Error getting previous video lesson: $e');
      return null;
    }
  }
}