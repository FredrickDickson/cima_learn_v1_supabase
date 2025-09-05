import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import '../models/video_lesson.dart';
import '../models/course_module.dart' as course_module;
import '../../config/supabase_config.dart';
import 'video_service.dart';

class CourseService {
  final VideoService _videoService = VideoService();
  
  // Add offline mode support
  bool get isOfflineMode => false; // Set to false for now, can be configured later
  // Fetch all courses filtered by category from Supabase or use mock data
  Future<List<Course>> getFilteredCourses(String category) async {
    try {
      // Check if we're in offline mode and return mock data
      if (isOfflineMode) {
        print('Running in offline mode - using mock data');
        return _getMockCourses(category);
      }

      print('Connecting to Supabase with URL: $supabaseUrl');
      print('Supabase key available: ${supabaseAnonKey.isNotEmpty}');

      final response = await Supabase.instance.client
          .from('courses')
          .select()
          .order('title', ascending: true);

      final List<Course> courses = (response as List).map((data) {
        return Course(
          id: data['id'] as String,
          title: data['title'] as String,
          category: data['category'] as String,
          level: data['level'] as String? ?? 'Beginner',
          instructor: data['instructor'] as String,
          rating: (data['rating'] as num).toDouble(),
          reviewCount: data['review_count'] as int,
          studentCount: data['student_count'] as int,
          duration: data['duration'] as String,
          price: (data['price'] as num).toDouble(),
          originalPrice: data['original_price'] != null ? (data['original_price'] as num).toDouble() : null,
          isBestseller: data['is_bestseller'] as bool,
          isPopular: data['is_popular'] as bool,
          image: data['image'] as String,
          description: data['description'] as String? ?? '',
        );
      }).toList();

      if (category == 'all') return courses;
      return courses.where((course) => course.category == category).toList();
    } catch (e) {
      // Fallback to mock data on any error
      return _getMockCourses(category);
    }
  }

  // Mock data for demo purposes
  List<Course> _getMockCourses(String category) {
    final allCourses = [
      Course(
        id: '1',
        title: 'International Commercial Arbitration Fundamentals',
        instructor: 'Dr. Sarah Mitchell',
        rating: 4.8,
        reviewCount: 156,
        duration: '8 hours',
        studentCount: 1200,
        price: 299.0,
        originalPrice: 399.0,
        category: 'arbitration',
        level: 'Beginner',
        image: 'assets/images/arbitration-london.jpg',
        isPopular: true,
        isBestseller: false,
        description: 'Learn the fundamentals of international commercial arbitration.',
      ),
      Course(
        id: '2',
        title: 'Advanced Mediation Techniques',
        instructor: 'Prof. James Chen',
        rating: 4.9,
        reviewCount: 89,
        duration: '12 hours',
        studentCount: 845,
        price: 349.0,
        category: 'mediation',
        level: 'Advanced',
        image: 'assets/images/advanced-mediation.jpg',
        isPopular: false,
        isBestseller: true,
        description: 'Master advanced mediation techniques for complex disputes.',
      ),
      Course(
        id: '3',
        title: 'DIAC Arbitration Rules: A Comprehensive Guide',
        instructor: 'Maria Rodriguez',
        rating: 4.7,
        reviewCount: 234,
        duration: '6 hours',
        studentCount: 987,
        price: 199.0,
        originalPrice: 249.0,
        category: 'arbitration',
        level: 'Intermediate',
        image: 'assets/images/diac-rules.jpg',
        isPopular: true,
        isBestseller: false,
        description: 'Comprehensive guide to DIAC arbitration rules and procedures.',
      ),
      Course(
        id: '4',
        title: 'Commercial Law Essentials for Dispute Resolution',
        instructor: 'Robert Wilson',
        rating: 4.6,
        reviewCount: 178,
        duration: '10 hours',
        studentCount: 1456,
        price: 279.0,
        category: 'commercial-law',
        level: 'Beginner',
        image: 'assets/images/commercial-law.jpg',
        isPopular: false,
        isBestseller: false,
        description: 'Essential commercial law principles for dispute resolution.',
      ),
      Course(
        id: '5',
        title: 'Investment Treaty Arbitration',
        instructor: 'Dr. Elena Vasquez',
        rating: 4.9,
        reviewCount: 67,
        duration: '15 hours',
        studentCount: 432,
        price: 449.0,
        originalPrice: 599.0,
        category: 'arbitration',
        level: 'Advanced',
        image: 'assets/images/investment-arbitration.jpg',
        isPopular: false,
        isBestseller: true,
        description: 'Specialized course on investment treaty arbitration.',
      ),
      Course(
        id: '6',
        title: 'Construction Dispute Resolution',
        instructor: 'Michael Thompson',
        rating: 4.5,
        reviewCount: 123,
        duration: '9 hours',
        studentCount: 678,
        price: 329.0,
        category: 'arbitration',
        level: 'Intermediate',
        image: 'assets/images/construction-dispute.jpg',
        isPopular: true,
        isBestseller: false,
        description: 'Specialized training in construction dispute resolution.',
      ),
      Course(
        id: '7',
        title: 'Compliance and Risk Management',
        instructor: 'Lisa Park',
        rating: 4.7,
        reviewCount: 198,
        duration: '7 hours',
        studentCount: 1034,
        price: 249.0,
        category: 'compliance',
        level: 'Beginner',
        image: 'assets/images/compliance-risk.jpg',
        isPopular: false,
        isBestseller: false,
        description: 'Comprehensive compliance and risk management strategies.',
      ),
      Course(
        id: '8',
        title: 'Ethics in International Arbitration',
        instructor: 'Prof. David Kumar',
        rating: 4.8,
        reviewCount: 145,
        duration: '5 hours',
        studentCount: 756,
        price: 179.0,
        originalPrice: 229.0,
        category: 'arbitration',
        level: 'Intermediate',
        image: 'assets/images/ethics-arbitration.jpg',
        isPopular: true,
        isBestseller: true,
        description: 'Essential ethical principles in international arbitration.',
      ),
    ];

    if (category == 'all') return allCourses;
    return allCourses.where((course) => course.category == category).toList();
  }

  // Enroll a user in a course
  Future<void> enrollCourse(String courseId) async {
    try {
      if (isOfflineMode) {
        // In offline mode, just simulate enrollment
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        return; // Success in demo mode
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      await Supabase.instance.client.from('enrollments').insert({
        'user_id': user.id,
        'course_id': courseId,
      });
    } catch (e) {
      // In demo mode, enrollment always succeeds
      if (isOfflineMode) return;
      rethrow;
    }
  }

  // Fetch enrolled courses for the current user
  Future<List<Course>> getEnrolledCourses() async {
    try {
      if (isOfflineMode) {
        // In offline mode, return a sample of enrolled courses
        final mockCourses = _getMockCourses('all');
        return mockCourses.take(3).toList(); // Return first 3 as "enrolled"
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return [];
      }

      final response = await Supabase.instance.client
          .from('enrollments')
          .select('course_id')
          .eq('user_id', user.id);

      final enrolledCourseIds = response.map((e) => e['course_id'] as String).toList();
      final allCourses = await getFilteredCourses('all');
      return allCourses.where((course) => enrolledCourseIds.contains(course.id)).toList();
    } catch (e) {
      // Fallback to mock enrolled courses
      final mockCourses = _getMockCourses('all');
      return mockCourses.take(2).toList();
    }
  }

  // =====================================================================================
  // VIDEO COURSE FUNCTIONALITY
  // =====================================================================================

  /// Get course with video lessons and user progress
  Future<Map<String, dynamic>?> getCourseWithVideoContent(String courseId, String userId) async {
    try {
      // Get basic course information
      final courseResponse = await Supabase.instance.client
          .from('courses')
          .select('''
            *,
            course_modules(
              *,
              video_lessons(*)
            )
          ''')
          .eq('id', courseId)
          .single();

      if (courseResponse == null) return null;

      // Get user's video progress for this course
      final videoProgress = await _videoService.getCourseVideoProgress(courseId, userId);
      
      // Calculate course completion statistics
      final modules = courseResponse['course_modules'] as List;
      int totalLessons = 0;
      int completedLessons = 0;
      double totalWatchTime = 0;

      for (final module in modules) {
        final lessons = module['video_lessons'] as List;
        totalLessons += lessons.length;
        
        for (final lesson in lessons) {
          final progress = videoProgress.firstWhere(
            (p) => p.lessonId == lesson['id'],
            orElse: () => VideoProgress(
              id: 'temp',
              userId: userId,
              lessonId: lesson['id'], 
              lastWatchedAt: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          
          if (progress.isCompleted) {
            completedLessons++;
          }
          totalWatchTime += progress.watchTimeSeconds;
        }
      }

      return {
        'course': courseResponse,
        'video_progress': videoProgress,
        'statistics': {
          'total_lessons': totalLessons,
          'completed_lessons': completedLessons,
          'completion_percentage': totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0,
          'total_watch_time_seconds': totalWatchTime,
          'total_watch_time_formatted': _formatWatchTime(totalWatchTime.round()),
        },
      };
    } catch (e) {
      print('Error fetching course with video content: $e');
      return null;
    }
  }

  /// Get course modules with video lessons
  Future<List<course_module.CourseModule>> getCourseModulesWithVideos(String courseId, String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('course_modules')
          .select('''
            *,
            video_lessons(*)
          ''')
          .eq('course_id', courseId)
          .order('order_index');

      final modules = <course_module.CourseModule>[];
      
      for (final moduleData in response) {
        // Get video lessons for this module
        final videoLessons = await _videoService.getModuleVideoLessons(
          moduleData['id'],
          userId,
        );

        // Convert to CourseModule with video data
        final module = course_module.CourseModule.fromJson({
          ...moduleData,
          'video_lessons': videoLessons.map((lesson) => lesson.toJson()).toList(),
        });

        modules.add(module);
      }

      return modules;
    } catch (e) {
      print('Error fetching course modules with videos: $e');
      return [];
    }
  }

  /// Create new video lesson in a course module
  Future<String?> createVideoLesson({
    required String courseId,
    required String moduleId,
    required String title,
    required String description,
  }) async {
    try {
      // Get next order index for the module
      final orderResponse = await Supabase.instance.client
          .from('video_lessons')
          .select('order_index')
          .eq('module_id', moduleId)
          .order('order_index', ascending: false)
          .limit(1);

      int nextOrder = 1;
      if (orderResponse.isNotEmpty) {
        nextOrder = (orderResponse.first['order_index'] as int) + 1;
      }

      // Create the video lesson
      return await _videoService.createVideoLesson(
        moduleId: moduleId,
        courseId: courseId,
        title: title,
        description: description,
        orderIndex: nextOrder,
      );
    } catch (e) {
      print('Error creating video lesson: $e');
      return null;
    }
  }

  /// Get course learning analytics for instructors
  Future<Map<String, dynamic>> getCourseAnalytics(String courseId) async {
    try {
      // Get video engagement analytics
      final videoAnalytics = await _videoService.getVideoEngagementAnalytics(courseId);
      
      // Get enrollment analytics
      final enrollmentResponse = await Supabase.instance.client
          .from('enrollments')
          .select('created_at, status')
          .eq('course_id', courseId);

      // Calculate enrollment trends
      int totalEnrollments = enrollmentResponse.length;
      int activeEnrollments = enrollmentResponse
          .where((e) => e['status'] == 'active')
          .length;

      // Get recent enrollments (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      int recentEnrollments = enrollmentResponse
          .where((e) => DateTime.parse(e['created_at']).isAfter(thirtyDaysAgo))
          .length;

      return {
        'video_analytics': videoAnalytics,
        'enrollment_analytics': {
          'total_enrollments': totalEnrollments,
          'active_enrollments': activeEnrollments,
          'recent_enrollments': recentEnrollments,
          'conversion_rate': totalEnrollments > 0 
              ? (activeEnrollments / totalEnrollments) * 100 
              : 0,
        },
        'course_id': courseId,
      };
    } catch (e) {
      print('Error fetching course analytics: $e');
      return {};
    }
  }

  /// Check if user has video access to course
  Future<bool> hasVideoAccessToCourse(String courseId, String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('enrollments')
          .select('status')
          .eq('course_id', courseId)
          .eq('user_id', userId)
          .single();

      return response != null && response['status'] == 'active';
    } catch (e) {
      print('Error checking video access: $e');
      return false;
    }
  }

  /// Get next recommended video based on user progress
  Future<VideoLesson?> getNextRecommendedVideo(String userId, String courseId) async {
    try {
      // Get user's progress in this course
      final progress = await _videoService.getCourseVideoProgress(courseId, userId);
      
      // Find the next incomplete video lesson
      final response = await Supabase.instance.client
          .from('video_lessons')
          .select('''
            *,
            course_modules!inner(order_index)
          ''')
          .eq('course_id', courseId)
          .order('course_modules.order_index')
          .order('order_index');

      for (final lessonData in response) {
        final lessonId = lessonData['id'] as String;
        final userProgress = progress.firstWhere(
          (p) => p.lessonId == lessonId,
          orElse: () => VideoProgress(
            id: 'temp',
            userId: userId,
            lessonId: lessonId,
            lastWatchedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Return first incomplete lesson
        if (!userProgress.isCompleted) {
          return await _videoService.getVideoLesson(lessonId, userId);
        }
      }

      return null; // All lessons completed
    } catch (e) {
      print('Error getting next recommended video: $e');
      return null;
    }
  }

  /// Get user's recent video activity
  Future<List<Map<String, dynamic>>> getRecentVideoActivity(String userId, {int limit = 10}) async {
    try {
      final response = await Supabase.instance.client
          .from('video_progress')
          .select('''
            *,
            video_lessons!inner(
              title,
              course_id,
              courses!inner(title)
            )
          ''')
          .eq('user_id', userId)
          .order('last_watched_at', ascending: false)
          .limit(limit);

      return response.map<Map<String, dynamic>>((record) => {
        'lesson_title': record['video_lessons']['title'],
        'course_title': record['video_lessons']['courses']['title'],
        'completion_percentage': record['completion_percentage'],
        'last_watched_at': DateTime.parse(record['last_watched_at']),
        'lesson_id': record['lesson_id'],
        'course_id': record['video_lessons']['course_id'],
      }).toList();
    } catch (e) {
      print('Error fetching recent video activity: $e');
      return [];
    }
  }

  /// Update course with video-specific metadata
  Future<bool> updateCourseVideoMetadata(String courseId, Map<String, dynamic> metadata) async {
    try {
      await Supabase.instance.client
          .from('courses')
          .update({
            'video_metadata': metadata,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', courseId);

      return true;
    } catch (e) {
      print('Error updating course video metadata: $e');
      return false;
    }
  }

  /// Get course trailer/preview video
  Future<VideoLesson?> getCourseTrailer(String courseId) async {
    try {
      final response = await Supabase.instance.client
          .from('video_lessons')
          .select('*')
          .eq('course_id', courseId)
          .eq('is_preview', true)
          .single();

      if (response != null) {
        return VideoLesson.fromJson(response);
      }

      return null;
    } catch (e) {
      print('Error fetching course trailer: $e');
      return null;
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
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
}