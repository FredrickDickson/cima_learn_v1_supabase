import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../../config/app_config.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// Payment BLoC managing Paystack payments and transaction history
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    // Register event handlers
    on<PaymentInitializeRequested>(_onPaymentInitializeRequested);
    on<PaymentProcessRequested>(_onPaymentProcessRequested);
    on<PaymentVerificationRequested>(_onPaymentVerificationRequested);
    on<PaymentSucceeded>(_onPaymentSucceeded);
    on<PaymentFailed>(_onPaymentFailed);
    on<PaymentCancelled>(_onPaymentCancelled);
    on<PaymentHistoryRequested>(_onPaymentHistoryRequested);
    on<PaymentRetryRequested>(_onPaymentRetryRequested);
    on<PaymentRefundRequested>(_onPaymentRefundRequested);
    on<PaymentDiscountApplied>(_onPaymentDiscountApplied);
  }

  /// Initialize payment process
  Future<void> _onPaymentInitializeRequested(
    PaymentInitializeRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentInitializing());

    try {
      // Generate unique payment reference
      final reference = _generatePaymentReference(event.userId);

      // Create payment record in database
      final paymentData = {
        'reference': reference,
        'user_id': event.userId,
        'course_id': event.courseId,
        'amount': event.amount,
        'currency': event.currency,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('payments').insert(paymentData);

      // Initialize with Paystack (simulate API call)
      final accessCode = _generateAccessCode(reference);

      emit(PaymentReady(
        reference: reference,
        accessCode: accessCode,
        amount: event.amount,
        currency: event.currency,
        courseId: event.courseId,
        publicKey: AppConfig.paystackPublicKey,
        email: event.email,
      ));
    } catch (e) {
      emit(PaymentError(message: 'Failed to initialize payment: $e'));
    }
  }

  /// Process payment with Paystack
  Future<void> _onPaymentProcessRequested(
    PaymentProcessRequested event,
    Emitter<PaymentState> emit,
  ) async {
    if (state is! PaymentReady) return;

    final currentState = state as PaymentReady;
    emit(PaymentProcessing(
      reference: event.reference,
      amount: currentState.finalAmount,
    ));

    try {
      // Update payment status to processing
      await supabase
          .from('payments')
          .update({
            'status': 'processing',
            'access_code': event.accessCode,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('reference', event.reference);

      // Simulate payment processing (in real app, this would trigger Paystack)
      await Future.delayed(const Duration(seconds: 2));

      // Auto-verify payment
      add(PaymentVerificationRequested(reference: event.reference));
    } catch (e) {
      add(PaymentFailed(
        reference: event.reference,
        error: 'Payment processing failed: $e',
      ));
    }
  }

  /// Verify payment status with Paystack
  Future<void> _onPaymentVerificationRequested(
    PaymentVerificationRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentVerifying(reference: event.reference));

    try {
      // Get payment record
      final paymentResponse = await supabase
          .from('payments')
          .select('*, courses!payments_course_id_fkey(title)')
          .eq('reference', event.reference)
          .single();

      // Simulate Paystack verification (would be actual API call)
      final isSuccessful = _simulatePaymentVerification();

      if (isSuccessful) {
        final transactionId = _generateTransactionId();
        
        add(PaymentSucceeded(
          reference: event.reference,
          transactionId: transactionId,
          amount: (paymentResponse['amount'] as num).toDouble(),
        ));
      } else {
        add(PaymentFailed(
          reference: event.reference,
          error: 'Payment verification failed',
        ));
      }
    } catch (e) {
      add(PaymentFailed(
        reference: event.reference,
        error: 'Verification failed: $e',
      ));
    }
  }

  /// Handle successful payment
  Future<void> _onPaymentSucceeded(
    PaymentSucceeded event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // Update payment record
      await supabase
          .from('payments')
          .update({
            'status': 'completed',
            'transaction_id': event.transactionId,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('reference', event.reference);

      // Get payment details for enrollment
      final paymentResponse = await supabase
          .from('payments')
          .select('user_id, course_id, courses!payments_course_id_fkey(title)')
          .eq('reference', event.reference)
          .single();

      // Create enrollment
      final enrollmentData = {
        'user_id': paymentResponse['user_id'],
        'course_id': paymentResponse['course_id'],
        'enrolled_at': DateTime.now().toIso8601String(),
        'status': 'active',
        'progress': 0.0,
        'payment_reference': event.reference,
      };

      final enrollmentResponse = await supabase
          .from('enrollments')
          .insert(enrollmentData)
          .select()
          .single();

      // Update course enrollment count
      await supabase.rpc('increment_enrollment_count', params: {
        'course_id': paymentResponse['course_id'],
      });

      emit(PaymentSuccess(
        reference: event.reference,
        transactionId: event.transactionId,
        amount: event.amount,
        courseId: paymentResponse['course_id'],
        enrollmentId: enrollmentResponse['id'],
        message: 'Payment successful! You are now enrolled in the course.',
      ));
    } catch (e) {
      emit(PaymentError(message: 'Failed to complete enrollment: $e'));
    }
  }

  /// Handle failed payment
  Future<void> _onPaymentFailed(
    PaymentFailed event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // Update payment record
      await supabase
          .from('payments')
          .update({
            'status': 'failed',
            'error_message': event.error,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('reference', event.reference);

      emit(PaymentFailure(
        reference: event.reference,
        error: event.error,
        isRetryable: _isRetryableError(event.error),
      ));
    } catch (e) {
      emit(PaymentError(message: 'Failed to update payment status: $e'));
    }
  }

  /// Handle cancelled payment
  Future<void> _onPaymentCancelled(
    PaymentCancelled event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      await supabase
          .from('payments')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('reference', event.reference);

      emit(PaymentCancelled(
        reference: event.reference,
        message: 'Payment was cancelled by user',
      ));
    } catch (e) {
      emit(PaymentError(message: 'Failed to cancel payment: $e'));
    }
  }

  /// Load payment history
  Future<void> _onPaymentHistoryRequested(
    PaymentHistoryRequested event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      final response = await supabase
          .from('payments')
          .select('*, courses!payments_course_id_fkey(title)')
          .eq('user_id', event.userId)
          .order('created_at', ascending: false);

      final payments = response.map((data) {
        return PaymentRecord.fromJson({
          ...data,
          'course_name': data['courses']?['title'] ?? 'Unknown Course',
        });
      }).toList();

      emit(PaymentHistoryLoaded(payments: payments));
    } catch (e) {
      emit(PaymentError(message: 'Failed to load payment history: $e'));
    }
  }

  /// Retry failed payment
  Future<void> _onPaymentRetryRequested(
    PaymentRetryRequested event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // Get original payment details
      final originalPayment = await supabase
          .from('payments')
          .select('*')
          .eq('reference', event.originalReference)
          .single();

      // Create new payment with same details
      add(PaymentInitializeRequested(
        courseId: originalPayment['course_id'],
        userId: originalPayment['user_id'],
        amount: (originalPayment['amount'] as num).toDouble(),
        currency: originalPayment['currency'],
      ));
    } catch (e) {
      emit(PaymentError(message: 'Failed to retry payment: $e'));
    }
  }

  /// Process refund request
  Future<void> _onPaymentRefundRequested(
    PaymentRefundRequested event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // Create refund record
      final refundData = {
        'transaction_id': event.transactionId,
        'amount': event.amount,
        'reason': event.reason,
        'status': 'pending',
        'requested_at': DateTime.now().toIso8601String(),
      };

      final refundResponse = await supabase
          .from('refunds')
          .insert(refundData)
          .select()
          .single();

      // Simulate refund processing
      await Future.delayed(const Duration(seconds: 1));

      emit(PaymentRefunded(
        transactionId: event.transactionId,
        refundId: refundResponse['id'],
        amount: event.amount,
        message: 'Refund request submitted successfully',
      ));
    } catch (e) {
      emit(PaymentError(message: 'Failed to process refund: $e'));
    }
  }

  /// Apply discount/coupon
  Future<void> _onPaymentDiscountApplied(
    PaymentDiscountApplied event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // Validate coupon code
      final couponResponse = await supabase
          .from('coupons')
          .select('*')
          .eq('code', event.couponCode)
          .eq('is_active', true)
          .gte('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      if (couponResponse == null) {
        emit(PaymentError(message: 'Invalid or expired coupon code'));
        return;
      }

      final discountPercentage = (couponResponse['discount_percentage'] as num).toDouble();
      final discountAmount = event.originalAmount * (discountPercentage / 100);
      final finalAmount = event.originalAmount - discountAmount;

      emit(PaymentDiscountApplied(
        couponCode: event.couponCode,
        discountAmount: discountAmount,
        discountPercentage: discountPercentage,
        originalAmount: event.originalAmount,
        finalAmount: finalAmount,
      ));
    } catch (e) {
      emit(PaymentError(message: 'Failed to apply discount: $e'));
    }
  }

  /// Generate unique payment reference
  String _generatePaymentReference(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    final userSuffix = userId.length > 4 ? userId.substring(0, 4) : userId;
    return 'CIMA_${timestamp}_${userSuffix}_$random';
  }

  /// Generate access code for Paystack
  String _generateAccessCode(String reference) {
    // In real implementation, this would come from Paystack API
    return 'ac_${reference.toLowerCase().replaceAll('_', '')}'.substring(0, 20);
  }

  /// Generate transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'TXN_$timestamp$random';
  }

  /// Simulate payment verification (replace with actual Paystack API)
  bool _simulatePaymentVerification() {
    // 90% success rate for simulation
    return Random().nextDouble() > 0.1;
  }

  /// Check if error is retryable
  bool _isRetryableError(String error) {
    const retryableErrors = [
      'network',
      'timeout',
      'connection',
      'temporary',
      'service unavailable',
    ];

    return retryableErrors.any((keyword) => 
      error.toLowerCase().contains(keyword));
  }
}