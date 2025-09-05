import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'enhanced_auth_service.dart';
import '../../config/app_config.dart';
import '../utils/validators.dart';

class PaystackService {
  static final PaystackService _instance = PaystackService._internal();
  factory PaystackService() => _instance;
  PaystackService._internal();

  final String _baseUrl = 'https://api.paystack.co';
  // Use centralized configuration
  String get _secretKey => AppConfig.paystackSecretKey;
  String get _publicKey => AppConfig.paystackPublicKey;
  
  final SupabaseClient _supabase = Supabase.instance.client;
  final EnhancedAuthService _authService = EnhancedAuthService();

  // Initialize payment for course enrollment
  Future<PaymentResult> initializePayment({
    required String courseId,
    required String courseName,
    required double amount,
    required String currency,
    required String userEmail,
    Map<String, dynamic>? metadata,
  }) async {
    // Comprehensive input validation
    if (!Validators.isValidCourseId(courseId)) {
      return PaymentResult.error('Invalid course ID format');
    }

    if (!Validators.isValidCourseTitle(courseName)) {
      return PaymentResult.error('Invalid course name format');
    }

    if (!Validators.isValidEmail(userEmail)) {
      return PaymentResult.error('Invalid email address');
    }

    if (!Validators.isValidAmount(amount)) {
      return PaymentResult.error('Invalid payment amount');
    }

    if (!Validators.isValidCurrency(currency)) {
      return PaymentResult.error('Invalid currency code');
    }

    if (_secretKey.isEmpty) {
      return PaymentResult.error('Payment service not configured');
    }

    // Check for security patterns in inputs
    if (SecurityUtils.containsSqlInjectionPattern(courseName) ||
        SecurityUtils.containsXssPattern(courseName)) {
      return PaymentResult.error('Invalid course name');
    }

    try {
      // Convert amount to kobo (Paystack uses kobo for NGN)
      final int amountInKobo = (amount * 100).round();

      final response = await http.post(
        Uri.parse('$_baseUrl/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': userEmail.trim().toLowerCase(),
          'amount': amountInKobo,
          'currency': currency.toUpperCase(),
          'reference': _generateReference(courseId),
          'callback_url': AppConfig.getPaymentCallbackUrl(),
          'metadata': {
            'course_id': courseId,
            'course_name': courseName,
            'user_id': _authService.userId,
            'payment_type': 'course_enrollment',
            'amount_original': amount,
            'timestamp': DateTime.now().toIso8601String(),
            ...?metadata,
          },
          'channels': ['card', 'bank', 'ussd', 'qr', 'mobile_money', 'bank_transfer'],
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final data = responseData['data'];
        
        // Store payment record in database
        await _createPaymentRecord(
          reference: data['reference'],
          courseId: courseId,
          amount: amount,
          currency: currency,
          status: 'pending',
        );

        return PaymentResult.success(
          reference: data['reference'],
          authorizationUrl: data['authorization_url'],
          accessCode: data['access_code'],
        );
      } else {
        return PaymentResult.error(
          responseData['message'] ?? 'Payment initialization failed',
        );
      }
    } catch (e) {
      debugPrint('Payment initialization error: $e');
      return PaymentResult.error('Failed to initialize payment: $e');
    }
  }

  // Initialize bulk payment for multiple courses
  Future<PaymentResult> initializeBulkPayment({
    required List<String> courseIds,
    required List<String> courseNames,
    required double totalAmount,
    required String currency,
    required String userEmail,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Convert amount to kobo (Paystack uses kobo for NGN)
      final int amountInKobo = (totalAmount * 100).round();
      final bulkReference = _generateBulkReference(courseIds);

      final response = await http.post(
        Uri.parse('$_baseUrl/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': userEmail,
          'amount': amountInKobo,
          'currency': currency.toUpperCase(),
          'reference': bulkReference,
          'callback_url': AppConfig.getPaymentCallbackUrl(),
          'metadata': {
            'course_ids': courseIds.join(','),
            'course_names': courseNames.join(', '),
            'user_id': _authService.userId,
            'payment_type': 'bulk_enrollment',
            'course_count': courseIds.length,
            ...?metadata,
          },
          'channels': ['card', 'bank', 'ussd', 'qr', 'mobile_money', 'bank_transfer'],
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final data = responseData['data'];
        
        // Store bulk payment record in database
        await _createBulkPaymentRecord(
          reference: data['reference'],
          courseIds: courseIds,
          totalAmount: totalAmount,
          currency: currency,
          status: 'pending',
        );

        // Auto-enroll after successful payment simulation (for demo)
        await _processBulkEnrollment(courseIds);

        return PaymentResult.success(
          reference: data['reference'],
          authorizationUrl: data['authorization_url'],
          accessCode: data['access_code'],
        );
      } else {
        return PaymentResult.error(
          responseData['message'] ?? 'Failed to initialize bulk payment',
        );
      }
    } catch (e) {
      debugPrint('Paystack bulk payment error: $e');
      return PaymentResult.error('Failed to initialize bulk payment: $e');
    }
  }

  // Verify payment status
  Future<PaymentVerificationResult> verifyPayment(String reference) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transaction/verify/$reference'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final data = responseData['data'];
        final status = data['status'] as String;

        // Update payment record in database
        await _updatePaymentRecord(
          reference: reference,
          status: status,
          paystackData: data,
        );

        if (status == 'success') {
          // Process successful enrollment
          await _processSuccessfulPayment(data);
          
          return PaymentVerificationResult.success(
            amount: (data['amount'] as int) / 100, // Convert from kobo
            currency: data['currency'],
            status: status,
            paidAt: DateTime.parse(data['paid_at']),
          );
        } else {
          return PaymentVerificationResult.failed(
            status: status,
            message: data['gateway_response'] ?? 'Payment verification failed',
          );
        }
      } else {
        return PaymentVerificationResult.failed(
          status: 'failed',
          message: responseData['message'] ?? 'Payment verification failed',
        );
      }
    } catch (e) {
      debugPrint('Payment verification error: $e');
      return PaymentVerificationResult.failed(
        status: 'error',
        message: 'Failed to verify payment: $e',
      );
    }
  }

  // Process successful payment
  Future<void> _processSuccessfulPayment(Map<String, dynamic> paymentData) async {
    try {
      final metadata = paymentData['metadata'] as Map<String, dynamic>;
      final courseId = metadata['course_id'] as String;
      final userId = metadata['user_id'] as String;

      // Create enrollment record
      await _supabase.from('enrollments').insert({
        'user_id': userId,
        'course_id': courseId,
        'enrolled_at': DateTime.now().toIso8601String(),
        'payment_reference': paymentData['reference'],
        'amount_paid': (paymentData['amount'] as int) / 100,
        'currency': paymentData['currency'],
      });

      // Update payment record status
      await _supabase
          .from('payments')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('reference', paymentData['reference']);

      debugPrint('Course enrollment processed successfully');
    } catch (e) {
      debugPrint('Error processing successful payment: $e');
      rethrow;
    }
  }

  // Create payment record in database
  Future<void> _createPaymentRecord({
    required String reference,
    required String courseId,
    required double amount,
    required String currency,
    required String status,
  }) async {
    try {
      await _supabase.from('payments').insert({
        'reference': reference,
        'user_id': _authService.userId,
        'course_id': courseId,
        'amount': amount,
        'currency': currency,
        'status': status,
        'payment_method': 'paystack',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating payment record: $e');
    }
  }

  // Update payment record
  Future<void> _updatePaymentRecord({
    required String reference,
    required String status,
    Map<String, dynamic>? paystackData,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (paystackData != null) {
        updateData['paystack_data'] = paystackData as dynamic;
        if (status == 'success') {
          updateData['completed_at'] = DateTime.now().toIso8601String();
        }
      }

      await _supabase
          .from('payments')
          .update(updateData)
          .eq('reference', reference);
    } catch (e) {
      debugPrint('Error updating payment record: $e');
    }
  }

  // Generate unique payment reference
  String _generateReference(String courseId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = _authService.userId;
    final userPrefix = userId.isNotEmpty && userId.length >= 8 ? userId.substring(0, 8) : userId;
    return 'CIMA_${courseId}_${userPrefix}_$timestamp';
  }

  String _generateBulkReference(List<String> courseIds) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = _authService.userId;
    final userPrefix = userId.isNotEmpty && userId.length >= 8 ? userId.substring(0, 8) : userId;
    final courseHash = courseIds.join('_').hashCode.abs();
    return 'BULK_CIMA_${courseHash}_${userPrefix}_$timestamp';
  }

  Future<void> _createBulkPaymentRecord({
    required String reference,
    required List<String> courseIds,
    required double totalAmount,
    required String currency,
    required String status,
  }) async {
    try {
      await _supabase.from('payments').insert({
        'reference': reference,
        'user_id': _authService.userId,
        'course_ids': courseIds,
        'amount': totalAmount,
        'currency': currency,
        'status': status,
        'payment_type': 'bulk_enrollment',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating bulk payment record: $e');
      rethrow;
    }
  }

  Future<void> _processBulkEnrollment(List<String> courseIds) async {
    try {
      final userId = _authService.userId;
      if (userId == null) throw Exception('User not authenticated');

      // Enroll in all courses
      for (final courseId in courseIds) {
        await _supabase.from('enrollments').upsert({
          'user_id': userId,
          'course_id': courseId,
          'enrolled_at': DateTime.now().toIso8601String(),
          'status': 'active',
          'payment_status': 'completed',
        });
      }

      debugPrint('Bulk enrollment completed for ${courseIds.length} courses');
    } catch (e) {
      debugPrint('Error processing bulk enrollment: $e');
      rethrow;
    }
  }

  // Get user's payment history
  Future<List<Map<String, dynamic>>> getUserPaymentHistory() async {
    try {
      if (!_authService.isAuthenticated) return [];

      final response = await _supabase
          .from('payments')
          .select('''
            *,
            courses(title, instructor, image)
          ''')
          .eq('user_id', _authService.userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching payment history: $e');
      return [];
    }
  }

  // Check if user has paid for a course
  Future<bool> hasUserPaidForCourse(String courseId) async {
    try {
      if (!_authService.isAuthenticated) return false;

      final response = await _supabase
          .from('payments')
          .select()
          .eq('user_id', _authService.userId)
          .eq('course_id', courseId)
          .eq('status', 'completed')
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking course payment: $e');
      return false;
    }
  }

  // Get course payment details
  Future<Map<String, dynamic>?> getCoursePaymentDetails(String courseId) async {
    try {
      if (!_authService.isAuthenticated) return null;

      final response = await _supabase
          .from('payments')
          .select()
          .eq('user_id', _authService.userId)
          .eq('course_id', courseId)
          .eq('status', 'completed')
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching payment details: $e');
      return null;
    }
  }
}

// Payment result classes
class PaymentResult {
  final bool isSuccess;
  final String message;
  final String? reference;
  final String? authorizationUrl;
  final String? accessCode;

  PaymentResult._({
    required this.isSuccess,
    required this.message,
    this.reference,
    this.authorizationUrl,
    this.accessCode,
  });

  factory PaymentResult.success({
    required String reference,
    required String authorizationUrl,
    required String accessCode,
  }) =>
      PaymentResult._(
        isSuccess: true,
        message: 'Payment initialized successfully',
        reference: reference,
        authorizationUrl: authorizationUrl,
        accessCode: accessCode,
      );

  factory PaymentResult.error(String message) => PaymentResult._(
        isSuccess: false,
        message: message,
      );
}

class PaymentVerificationResult {
  final bool isSuccess;
  final String status;
  final String message;
  final double? amount;
  final String? currency;
  final DateTime? paidAt;

  PaymentVerificationResult._({
    required this.isSuccess,
    required this.status,
    required this.message,
    this.amount,
    this.currency,
    this.paidAt,
  });

  factory PaymentVerificationResult.success({
    required double amount,
    required String currency,
    required String status,
    required DateTime paidAt,
  }) =>
      PaymentVerificationResult._(
        isSuccess: true,
        status: status,
        message: 'Payment verified successfully',
        amount: amount,
        currency: currency,
        paidAt: paidAt,
      );

  factory PaymentVerificationResult.failed({
    required String status,
    required String message,
  }) =>
      PaymentVerificationResult._(
        isSuccess: false,
        status: status,
        message: message,
      );
}