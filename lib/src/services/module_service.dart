import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_module.dart';

class ModuleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all modules for a course
  Future<List<CourseModule>> getCourseModules(String courseId) async {
    try {
      final response = await _supabase
          .from('course_modules')
          .select()
          .eq('course_id', courseId)
          .order('order_index', ascending: true);

      return response.map((json) => CourseModule.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch course modules: $e');
    }
  }

  // Get module content for specific language
  Future<Map<String, String>> getModuleContent(String moduleId, String languageCode) async {
    try {
      final response = await _supabase
          .from('module_content')
          .select()
          .eq('module_id', moduleId)
          .eq('language_code', languageCode);

      final contentMap = <String, String>{};
      for (final item in response) {
        if (item['content_url'] != null) {
          contentMap[item['content_type']] = item['content_url'];
        }
      }

      return contentMap;
    } catch (e) {
      throw Exception('Failed to fetch module content: $e');
    }
  }

  // Create sample modules for testing (this would be admin functionality)
  Future<void> createSampleModules() async {
    try {
      // Create sample modules for CIMA-001 course
      final modules = [
        {
          'course_id': 'cima-001',
          'title': 'Introduction to International Arbitration',
          'description': 'Overview of international arbitration principles and history',
          'order_index': 1,
          'module_type': 'video',
          'estimated_duration_minutes': 45,
          'is_required': true,
        },
        {
          'course_id': 'cima-001',
          'title': 'UNCITRAL Model Law Fundamentals',
          'description': 'Deep dive into UNCITRAL Model Law provisions',
          'order_index': 2,
          'module_type': 'video',
          'estimated_duration_minutes': 60,
          'is_required': true,
        },
        {
          'course_id': 'cima-001',
          'title': 'Arbitration Agreement Drafting',
          'description': 'Best practices for drafting arbitration clauses',
          'order_index': 3,
          'module_type': 'document',
          'estimated_duration_minutes': 30,
          'is_required': true,
        },
        {
          'course_id': 'cima-001',
          'title': 'Module Assessment',
          'description': 'Test your knowledge of arbitration fundamentals',
          'order_index': 4,
          'module_type': 'quiz',
          'estimated_duration_minutes': 20,
          'is_required': true,
        },
      ];

      await _supabase.from('course_modules').insert(modules);

      // Add sample content URLs
      // This would be populated with real video URLs in production
      final moduleIds = await _supabase
          .from('course_modules')
          .select('id')
          .eq('course_id', 'cima-001')
          .order('order_index', ascending: true);

      if (moduleIds.isNotEmpty) {
        final contentData = [
          // Video content for first module in multiple languages
          {
            'module_id': moduleIds[0]['id'],
            'language_code': 'en',
            'content_type': 'video_url',
            'content_url': 'https://example.com/videos/intro-arbitration-en.mp4',
          },
          {
            'module_id': moduleIds[0]['id'],
            'language_code': 'fr',
            'content_type': 'video_url',
            'content_url': 'https://example.com/videos/intro-arbitration-fr.mp4',
          },
          {
            'module_id': moduleIds[0]['id'],
            'language_code': 'es',
            'content_type': 'video_url',
            'content_url': 'https://example.com/videos/intro-arbitration-es.mp4',
          },
        ];

        await _supabase.from('module_content').insert(contentData);
      }
    } catch (e) {
      throw Exception('Failed to create sample modules: $e');
    }
  }

  // Update user video progress
  Future<void> updateVideoProgress({
    required String userId,
    required String moduleId,
    required int watchTimeSeconds,
    required double completionPercentage,
    int? lastPositionSeconds,
    String languageCode = 'en',
  }) async {
    try {
      final data = {
        'user_id': userId,
        'module_id': moduleId,
        'watch_time_seconds': watchTimeSeconds,
        'completion_percentage': completionPercentage,
        'last_position_seconds': lastPositionSeconds ?? 0,
        'language_watched': languageCode,
        'last_watched_at': DateTime.now().toIso8601String(),
        'is_completed': completionPercentage >= 90, // Consider 90% as completed
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (completionPercentage >= 90) {
        data['completed_at'] = DateTime.now().toIso8601String();
      }

      await _supabase.from('user_video_progress').upsert(data);
    } catch (e) {
      throw Exception('Failed to update video progress: $e');
    }
  }

  // Get user's progress for a specific module
  Future<Map<String, dynamic>?> getUserModuleProgress(String userId, String moduleId) async {
    try {
      final response = await _supabase
          .from('user_video_progress')
          .select()
          .eq('user_id', userId)
          .eq('module_id', moduleId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch user module progress: $e');
    }
  }

  // Get all user's progress for a course
  Future<List<Map<String, dynamic>>> getUserCourseProgress(String userId, String courseId) async {
    try {
      final response = await _supabase
          .from('user_video_progress')
          .select('''
            *,
            course_modules!inner(course_id, title, module_type)
          ''')
          .eq('user_id', userId)
          .eq('course_modules.course_id', courseId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch user course progress: $e');
    }
  }

  // Save user language preference
  Future<void> saveUserLanguagePreference({
    required String userId,
    required String preferredLanguage,
    String? subtitleLanguage,
    String? interfaceLanguage,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'preferred_language': preferredLanguage,
        'subtitle_language': subtitleLanguage ?? preferredLanguage,
        'interface_language': interfaceLanguage ?? preferredLanguage,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('user_language_preferences').upsert(data);
    } catch (e) {
      throw Exception('Failed to save language preference: $e');
    }
  }

  // Get user language preference
  Future<Map<String, dynamic>?> getUserLanguagePreference(String userId) async {
    try {
      final response = await _supabase
          .from('user_language_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch language preference: $e');
    }
  }
}