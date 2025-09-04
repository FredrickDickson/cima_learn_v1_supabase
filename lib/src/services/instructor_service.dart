import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';

class InstructorService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Course> _myCourses = [];
  Map<String, dynamic>? _analytics;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Course> get myCourses => _myCourses;
  Map<String, dynamic>? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get instructor's courses
  Future<void> loadMyCourses(String instructorId) async {
    _setLoading(true);
    try {
      final response = await _supabase
          .from('courses')
          .select('*')
          .eq('instructor_id', instructorId);

      _myCourses = response.map((data) => Course.fromJson(data)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load courses: $e';
      debugPrint('Error loading instructor courses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new course
  Future<String?> createCourse(Map<String, dynamic> courseData) async {
    _setLoading(true);
    try {
      final response = await _supabase
          .from('courses')
          .insert({
            ...courseData,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final newCourse = Course.fromJson(response);
      _myCourses.insert(0, newCourse);
      _errorMessage = null;
      notifyListeners();
      return newCourse.id;
    } catch (e) {
      _errorMessage = 'Failed to create course: $e';
      debugPrint('Error creating course: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update course
  Future<bool> updateCourse(String courseId, Map<String, dynamic> updates) async {
    _setLoading(true);
    try {
      await _supabase
          .from('courses')
          .update({
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', courseId);

      // Update local course data
      final courseIndex = _myCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final updatedData = {..._myCourses[courseIndex].toJson(), ...updates};
        _myCourses[courseIndex] = Course.fromJson(updatedData);
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update course: $e';
      debugPrint('Error updating course: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete course
  Future<bool> deleteCourse(String courseId) async {
    _setLoading(true);
    try {
      await _supabase
          .from('courses')
          .delete()
          .eq('id', courseId);

      _myCourses.removeWhere((course) => course.id == courseId);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete course: $e';
      debugPrint('Error deleting course: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get course analytics
  Future<void> loadCourseAnalytics(String instructorId) async {
    _setLoading(true);
    try {
      // Get enrollment stats  
      final courseIds = _myCourses.map((c) => c.id).toList();
      final enrollmentsResponse = courseIds.isNotEmpty
          ? await _supabase
              .from('enrollments')
              .select('course_id, created_at, payment_reference')
              .filter('course_id', 'in', '(${courseIds.map((id) => "'$id'").join(',')})')
          : <Map<String, dynamic>>[];

      // Get payment stats
      final paymentsResponse = courseIds.isNotEmpty
          ? await _supabase
              .from('payments')
              .select('amount, status, created_at')
              .eq('status', 'completed')
              .filter('course_id', 'in', '(${courseIds.map((id) => "'$id'").join(',')})')
          : <Map<String, dynamic>>[];

      // Calculate analytics
      final totalEnrollments = enrollmentsResponse.length;
      final totalRevenue = paymentsResponse
          .fold<double>(0, (sum, payment) => sum + (payment['amount'] as num).toDouble());

      final thisMonthEnrollments = enrollmentsResponse.where((enrollment) {
        final enrollmentDate = DateTime.parse(enrollment['created_at']);
        final now = DateTime.now();
        return enrollmentDate.year == now.year && enrollmentDate.month == now.month;
      }).length;

      final thisMonthRevenue = paymentsResponse.where((payment) {
        final paymentDate = DateTime.parse(payment['created_at']);
        final now = DateTime.now();
        return paymentDate.year == now.year && paymentDate.month == now.month;
      }).fold<double>(0, (sum, payment) => sum + (payment['amount'] as num).toDouble());

      _analytics = {
        'totalCourses': _myCourses.length,
        'totalEnrollments': totalEnrollments,
        'totalRevenue': totalRevenue,
        'thisMonthEnrollments': thisMonthEnrollments,
        'thisMonthRevenue': thisMonthRevenue,
        'averageEnrollmentsPerCourse': _myCourses.isNotEmpty ? totalEnrollments / _myCourses.length : 0,
        'averageRevenuePerCourse': _myCourses.isNotEmpty ? totalRevenue / _myCourses.length : 0,
      };

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load analytics: $e';
      debugPrint('Error loading analytics: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get student feedback for instructor's courses
  Future<List<Map<String, dynamic>>> getStudentFeedback(String instructorId) async {
    try {
      final response = await _supabase
          .from('content_reviews')
          .select('''
            *,
            courses!inner(instructor_id),
            profiles!inner(full_name, display_name)
          ''')
          .eq('courses.instructor_id', instructorId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error loading student feedback: $e');
      return [];
    }
  }

  // Submit course for approval (if needed)
  Future<bool> submitCourseForApproval(String courseId) async {
    try {
      await _supabase
          .from('courses')
          .update({
            'status': 'pending_approval',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', courseId);

      // Update local course status
      final courseIndex = _myCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final updatedData = {..._myCourses[courseIndex].toJson(), 'status': 'pending_approval'};
        _myCourses[courseIndex] = Course.fromJson(updatedData);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error submitting course for approval: $e');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}