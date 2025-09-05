import 'package:equatable/equatable.dart';

/// Payment events for the PaymentBloc
sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize payment process
class PaymentInitializeRequested extends PaymentEvent {
  const PaymentInitializeRequested({
    required this.courseId,
    required this.userId,
    required this.amount,
    required this.currency,
    this.email,
  });

  final String courseId;
  final String userId;
  final double amount;
  final String currency;
  final String? email;

  @override
  List<Object?> get props => [courseId, userId, amount, currency, email];
}

/// Event to process payment with Paystack
class PaymentProcessRequested extends PaymentEvent {
  const PaymentProcessRequested({
    required this.reference,
    required this.accessCode,
    this.metadata,
  });

  final String reference;
  final String accessCode;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [reference, accessCode, metadata];
}

/// Event to verify payment status
class PaymentVerificationRequested extends PaymentEvent {
  const PaymentVerificationRequested({required this.reference});

  final String reference;

  @override
  List<Object> get props => [reference];
}

/// Event when payment is successful
class PaymentSucceeded extends PaymentEvent {
  const PaymentSucceeded({
    required this.reference,
    required this.transactionId,
    required this.amount,
    this.enrollmentId,
  });

  final String reference;
  final String transactionId;
  final double amount;
  final String? enrollmentId;

  @override
  List<Object?> get props => [reference, transactionId, amount, enrollmentId];
}

/// Event when payment fails
class PaymentFailed extends PaymentEvent {
  const PaymentFailed({
    required this.reference,
    required this.error,
  });

  final String reference;
  final String error;

  @override
  List<Object> get props => [reference, error];
}

/// Event to cancel payment
class PaymentCancelled extends PaymentEvent {
  const PaymentCancelled({required this.reference});

  final String reference;

  @override
  List<Object> get props => [reference];
}

/// Event to load payment history
class PaymentHistoryRequested extends PaymentEvent {
  const PaymentHistoryRequested({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to retry failed payment
class PaymentRetryRequested extends PaymentEvent {
  const PaymentRetryRequested({required this.originalReference});

  final String originalReference;

  @override
  List<Object> get props => [originalReference];
}

/// Event to refund payment
class PaymentRefundRequested extends PaymentEvent {
  const PaymentRefundRequested({
    required this.transactionId,
    required this.amount,
    required this.reason,
  });

  final String transactionId;
  final double amount;
  final String reason;

  @override
  List<Object> get props => [transactionId, amount, reason];
}

/// Event to apply discount/coupon
class PaymentDiscountApplied extends PaymentEvent {
  const PaymentDiscountApplied({
    required this.couponCode,
    required this.originalAmount,
  });

  final String couponCode;
  final double originalAmount;

  @override
  List<Object> get props => [couponCode, originalAmount];
}