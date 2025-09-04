class EnrollmentModel {
  final String id;
  final String userId;
  final String courseId;
  final DateTime enrolledAt;
  final double progress;
  final bool completed;
  final String paymentStatus;
  final double amount;

  EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    this.progress = 0.0,
    this.completed = false,
    required this.paymentStatus,
    required this.amount,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      completed: json['completed'] as bool? ?? false,
      paymentStatus: json['payment_status'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'enrolled_at': enrolledAt.toIso8601String(),
      'progress': progress,
      'completed': completed,
      'payment_status': paymentStatus,
      'amount': amount,
    };
  }
}