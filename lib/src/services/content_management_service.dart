import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_module.dart';
import '../models/course.dart';
import '../../config/supabase_config.dart';

class ContentManagementService {
  final SupabaseClient _supabase = supabase;

  // CRUD Operations for Course Modules
  Future<List<CourseModule>> getCourseModules(String courseId) async {
    try {
      final response = await _supabase
          .from('course_modules')
          .select('*, course_content(*)')
          .eq('course_id', courseId)
          .order('order_index');

      return (response as List)
          .map((json) => CourseModule.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch course modules: $e');
    }
  }

  Future<CourseModule> createModule(CourseModule module) async {
    try {
      final response = await _supabase
          .from('course_modules')
          .insert(module.toJson())
          .select()
          .single();

      return CourseModule.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create module: $e');
    }
  }

  Future<CourseModule> updateModule(CourseModule module) async {
    try {
      final response = await _supabase
          .from('course_modules')
          .update(module.toJson())
          .eq('id', module.id)
          .select()
          .single();

      return CourseModule.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update module: $e');
    }
  }

  Future<void> deleteModule(String moduleId) async {
    try {
      await _supabase.from('course_modules').delete().eq('id', moduleId);
    } catch (e) {
      throw Exception('Failed to delete module: $e');
    }
  }

  // CRUD Operations for Course Content
  Future<List<CourseContent>> getModuleContent(String moduleId) async {
    try {
      final response = await _supabase
          .from('course_content')
          .select()
          .eq('module_id', moduleId)
          .order('order_index');

      return (response as List)
          .map((json) => CourseContent.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch module content: $e');
    }
  }

  Future<CourseContent> createContent(CourseContent content) async {
    try {
      final response = await _supabase
          .from('course_content')
          .insert(content.toJson())
          .select()
          .single();

      return CourseContent.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create content: $e');
    }
  }

  Future<CourseContent> updateContent(CourseContent content) async {
    try {
      final response = await _supabase
          .from('course_content')
          .update(content.toJson())
          .eq('id', content.id)
          .select()
          .single();

      return CourseContent.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update content: $e');
    }
  }

  Future<void> deleteContent(String contentId) async {
    try {
      await _supabase.from('course_content').delete().eq('id', contentId);
    } catch (e) {
      throw Exception('Failed to delete content: $e');
    }
  }

  // File Upload Operations
  Future<String> uploadVideo(String fileName, List<int> fileBytes, String courseId, String moduleId) async {
    try {
      final path = 'courses/$courseId/modules/$moduleId/videos/$fileName';
      
      await _supabase.storage
          .from('course-content')
          .uploadBinary(path, fileBytes);

      final url = _supabase.storage
          .from('course-content')
          .getPublicUrl(path);

      return url;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  Future<String> uploadFile(String fileName, List<int> fileBytes, String courseId, String moduleId, String fileType) async {
    try {
      final path = 'courses/$courseId/modules/$moduleId/$fileType/$fileName';
      
      await _supabase.storage
          .from('course-content')
          .uploadBinary(path, fileBytes);

      final url = _supabase.storage
          .from('course-content')
          .getPublicUrl(path);

      return url;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      await _supabase.storage
          .from('course-content')
          .remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Progress Tracking
  Future<UserProgress?> getUserProgress(String userId, String contentId) async {
    try {
      final response = await _supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('content_id', contentId)
          .maybeSingle();

      if (response != null) {
        return UserProgress.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user progress: $e');
    }
  }

  Future<UserProgress> updateProgress(UserProgress progress) async {
    try {
      final response = await _supabase
          .from('user_progress')
          .upsert(progress.toJson())
          .select()
          .single();

      return UserProgress.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  Future<List<UserProgress>> getCourseProgress(String userId, String courseId) async {
    try {
      final response = await _supabase
          .rpc('get_course_progress', params: {
            'p_user_id': userId,
            'p_course_id': courseId,
          });

      return (response as List)
          .map((json) => UserProgress.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch course progress: $e');
    }
  }

  // Content Publishing & Approval
  Future<void> publishContent(String contentId) async {
    try {
      await _supabase
          .from('course_content')
          .update({'status': 'published', 'published_at': DateTime.now().toIso8601String()})
          .eq('id', contentId);
    } catch (e) {
      throw Exception('Failed to publish content: $e');
    }
  }

  Future<void> unpublishContent(String contentId) async {
    try {
      await _supabase
          .from('course_content')
          .update({'status': 'draft', 'published_at': null})
          .eq('id', contentId);
    } catch (e) {
      throw Exception('Failed to unpublish content: $e');
    }
  }

  // Bulk Operations
  Future<void> reorderModules(String courseId, List<String> moduleIds) async {
    try {
      for (int i = 0; i < moduleIds.length; i++) {
        await _supabase
            .from('course_modules')
            .update({'order_index': i})
            .eq('id', moduleIds[i]);
      }
    } catch (e) {
      throw Exception('Failed to reorder modules: $e');
    }
  }

  Future<void> reorderContent(String moduleId, List<String> contentIds) async {
    try {
      for (int i = 0; i < contentIds.length; i++) {
        await _supabase
            .from('course_content')
            .update({'order_index': i})
            .eq('id', contentIds[i]);
      }
    } catch (e) {
      throw Exception('Failed to reorder content: $e');
    }
  }

  // Analytics and Reporting
  Future<Map<String, dynamic>> getContentAnalytics(String contentId) async {
    try {
      final response = await _supabase
          .rpc('get_content_analytics', params: {'p_content_id': contentId});

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch content analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getCourseAnalytics(String courseId) async {
    try {
      final response = await _supabase
          .rpc('get_course_analytics', params: {'p_course_id': courseId});

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch course analytics: $e');
    }
  }

  // Search and Filtering
  Future<List<CourseContent>> searchContent(String query, {
    ContentType? contentType,
    String? courseId,
    String? moduleId,
  }) async {
    try {
      var queryBuilder = _supabase.from('course_content').select();

      if (query.isNotEmpty) {
        queryBuilder = queryBuilder.textSearch('title', query);
      }

      if (contentType != null) {
        queryBuilder = queryBuilder.eq('content_type', contentType.name);
      }

      if (courseId != null) {
        queryBuilder = queryBuilder.eq('course_id', courseId);
      }

      if (moduleId != null) {
        queryBuilder = queryBuilder.eq('module_id', moduleId);
      }

      final response = await queryBuilder;

      return (response as List)
          .map((json) => CourseContent.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search content: $e');
    }
  }
}