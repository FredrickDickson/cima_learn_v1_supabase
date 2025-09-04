import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import '../models/enrollment_model.dart';
import 'payment_service.dart';

class EnrollmentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PaymentService _paymentService = PaymentService();

  // Enroll user in a course
  Future<EnrollmentModel?> enrollInCourse({
    required String userId,
    required String courseId,
    required double amount,
  }) async {
    try {
      // Check if user is already enrolled
      final existingEnrollment = await _supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();

      if (existingEnrollment != null) {
        throw Exception('User is already enrolled in this course');
      }

      // Process payment (using mock payment for demo)
      final paymentSuccessful = await _paymentService.processMockPayment(
        amount: amount,
        courseId: courseId,
        userId: userId,
      );

      if (!paymentSuccessful) {
        throw Exception('Payment failed');
      }

      // Create enrollment record
      final enrollment = {
        'user_id': userId,
        'course_id': courseId,
        'enrolled_at': DateTime.now().toIso8601String(),
        'progress': 0.0,
        'completed': false,
        'payment_status': 'completed',
        'amount': amount,
      };

      final response = await _supabase
          .from('enrollments')
          .insert(enrollment)
          .select()
          .single();

      return EnrollmentModel.fromJson(response);
    } catch (e) {
      print('Enrollment error: $e');
      rethrow;
    }
  }

  // Get user enrollments
  Future<List<EnrollmentModel>> getUserEnrollments(String userId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId);

      return response.map((json) => EnrollmentModel.fromJson(json)).toList();
    } catch (e) {
      print('Get enrollments error: $e');
      return [];
    }
  }

  // Check if user is enrolled in a course
  Future<bool> isUserEnrolled({
    required String userId,
    required String courseId,
  }) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Check enrollment error: $e');
      return false;
    }
  }

  // Update course progress
  Future<void> updateProgress({
    required String userId,
    required String courseId,
    required double progress,
  }) async {
    try {
      await _supabase
          .from('enrollments')
          .update({
            'progress': progress,
            'completed': progress >= 1.0,
          })
          .eq('user_id', userId)
          .eq('course_id', courseId);
    } catch (e) {
      print('Update progress error: $e');
      rethrow;
    }
  }

  // Get enrolled courses with course details
  Future<List<Course>> getEnrolledCoursesWithDetails(String userId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select('*, courses(*)')
          .eq('user_id', userId);

      return response
          .map((item) => Course.fromJson(item['courses']))
          .toList();
    } catch (e) {
      print('Get enrolled courses error: $e');
      return [];
    }
  }
}