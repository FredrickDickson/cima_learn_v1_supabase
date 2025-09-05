import 'package:equatable/equatable.dart';

/// Payment states for the PaymentBloc
sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class PaymentInitial extends PaymentState {}

/// State when payment is being initialized
class PaymentInitializing extends PaymentState {}

/// State when payment form is ready
class PaymentReady extends PaymentState {
  const PaymentReady({
    required this.reference,
    required this.accessCode,
    required this.amount,
    required this.currency,
    required this.courseId,
    this.publicKey,
    this.email,
    this.discountApplied = false,
    this.discountAmount = 0.0,
  });

  final String reference;
  final String accessCode;
  final double amount;
  final String currency;
  final String courseId;
  final String? publicKey;
  final String? email;
  final bool discountApplied;
  final double discountAmount;

  double get finalAmount => amount - discountAmount;

  @override
  List<Object?> get props => [
    reference, accessCode, amount, currency, courseId, 
    publicKey, email, discountApplied, discountAmount
  ];
}

/// State when payment is being processed
class PaymentProcessing extends PaymentState {
  const PaymentProcessing({
    required this.reference,
    required this.amount,
  });

  final String reference;
  final double amount;

  @override
  List<Object> get props => [reference, amount];
}

/// State when payment verification is in progress
class PaymentVerifying extends PaymentState {
  const PaymentVerifying({required this.reference});

  final String reference;

  @override
  List<Object> get props => [reference];
}

/// State when payment is successful
class PaymentSuccess extends PaymentState {
  const PaymentSuccess({
    required this.reference,
    required this.transactionId,
    required this.amount,
    required this.courseId,
    required this.enrollmentId,
    required this.message,
  });

  final String reference;
  final String transactionId;
  final double amount;
  final String courseId;
  final String enrollmentId;
  final String message;

  @override
  List<Object> get props => [
    reference, transactionId, amount, courseId, enrollmentId, message
  ];
}

/// State when payment fails
class PaymentFailure extends PaymentState {
  const PaymentFailure({
    required this.reference,
    required this.error,
    this.isRetryable = false,
  });

  final String reference;
  final String error;
  final bool isRetryable;

  @override
  List<Object> get props => [reference, error, isRetryable];
}

/// State when payment is cancelled
class PaymentCancelled extends PaymentState {
  const PaymentCancelled({
    required this.reference,
    required this.message,
  });

  final String reference;
  final String message;

  @override
  List<Object> get props => [reference, message];
}

/// State when payment history is loaded
class PaymentHistoryLoaded extends PaymentState {
  const PaymentHistoryLoaded({required this.payments});

  final List<PaymentRecord> payments;

  @override
  List<Object> get props => [payments];
}

/// State when payment refund is processed
class PaymentRefunded extends PaymentState {
  const PaymentRefunded({
    required this.transactionId,
    required this.refundId,
    required this.amount,
    required this.message,
  });

  final String transactionId;
  final String refundId;
  final double amount;
  final String message;

  @override
  List<Object> get props => [transactionId, refundId, amount, message];
}

/// State when discount is applied
class PaymentDiscountApplied extends PaymentState {
  const PaymentDiscountApplied({
    required this.couponCode,
    required this.discountAmount,
    required this.discountPercentage,
    required this.originalAmount,
    required this.finalAmount,
  });

  final String couponCode;
  final double discountAmount;
  final double discountPercentage;
  final double originalAmount;
  final double finalAmount;

  @override
  List<Object> get props => [
    couponCode, discountAmount, discountPercentage, originalAmount, finalAmount
  ];
}

/// State when payment operation encounters an error
class PaymentError extends PaymentState {
  const PaymentError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// Payment record model for history
class PaymentRecord extends Equatable {
  const PaymentRecord({
    required this.id,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.status,
    required this.courseId,
    required this.courseName,
    required this.createdAt,
    this.transactionId,
    this.gatewayResponse,
  });

  final String id;
  final String reference;
  final double amount;
  final String currency;
  final String status;
  final String courseId;
  final String courseName;
  final DateTime createdAt;
  final String? transactionId;
  final Map<String, dynamic>? gatewayResponse;

  @override
  List<Object?> get props => [
    id, reference, amount, currency, status, courseId, 
    courseName, createdAt, transactionId, gatewayResponse
  ];

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'],
      reference: json['reference'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'NGN',
      status: json['status'],
      courseId: json['course_id'],
      courseName: json['course_name'] ?? 'Unknown Course',
      createdAt: DateTime.parse(json['created_at']),
      transactionId: json['transaction_id'],
      gatewayResponse: json['gateway_response'],
    );
  }
}