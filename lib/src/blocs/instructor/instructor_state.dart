import 'package:equatable/equatable.dart';
import '../../models/course.dart';

/// Instructor states for the InstructorBloc
sealed class InstructorState extends Equatable {
  const InstructorState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class InstructorInitial extends InstructorState {}

/// State when instructor data is being loaded
class InstructorLoading extends InstructorState {}

/// State when instructor dashboard is loaded
class InstructorDashboardLoaded extends InstructorState {
  const InstructorDashboardLoaded({
    required this.overview,
    required this.recentActivity,
    required this.upcomingTasks,
  });

  final InstructorOverview overview;
  final List<ActivityItem> recentActivity;
  final List<TaskItem> upcomingTasks;

  @override
  List<Object> get props => [overview, recentActivity, upcomingTasks];
}

/// State when instructor courses are loaded
class InstructorCoursesLoaded extends InstructorState {
  const InstructorCoursesLoaded({
    required this.courses,
    required this.totalCourses,
    this.filter,
  });

  final List<Course> courses;
  final int totalCourses;
  final String? filter;

  @override
  List<Object?> get props => [courses, totalCourses, filter];
}

/// State when course is being created/updated
class InstructorCourseProcessing extends InstructorState {
  const InstructorCourseProcessing({
    required this.action,
    this.courseId,
  });

  final String action; // creating, updating, deleting, submitting
  final String? courseId;

  @override
  List<Object?> get props => [action, courseId];
}

/// State when course operation is successful
class InstructorCourseSuccess extends InstructorState {
  const InstructorCourseSuccess({
    required this.message,
    required this.courseId,
    required this.action,
  });

  final String message;
  final String courseId;
  final String action;

  @override
  List<Object> get props => [message, courseId, action];
}

/// State when analytics data is loaded
class InstructorAnalyticsLoaded extends InstructorState {
  const InstructorAnalyticsLoaded({
    required this.analytics,
    required this.courseAnalytics,
    required this.period,
  });

  final InstructorAnalytics analytics;
  final Map<String, CourseAnalytics> courseAnalytics;
  final String period;

  @override
  List<Object> get props => [analytics, courseAnalytics, period];
}

/// State when students data is loaded
class InstructorStudentsLoaded extends InstructorState {
  const InstructorStudentsLoaded({
    required this.students,
    required this.totalStudents,
    this.courseFilter,
  });

  final List<StudentEnrollment> students;
  final int totalStudents;
  final String? courseFilter;

  @override
  List<Object?> get props => [students, totalStudents, courseFilter];
}

/// State when reviews are loaded
class InstructorReviewsLoaded extends InstructorState {
  const InstructorReviewsLoaded({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  final List<CourseReview> reviews;
  final double averageRating;
  final int totalReviews;

  @override
  List<Object> get props => [reviews, averageRating, totalReviews];
}

/// State when content is being uploaded
class InstructorContentUploading extends InstructorState {
  const InstructorContentUploading({
    required this.progress,
    required this.contentType,
  });

  final double progress;
  final String contentType;

  @override
  List<Object> get props => [progress, contentType];
}

/// State when content upload is successful
class InstructorContentUploaded extends InstructorState {
  const InstructorContentUploaded({
    required this.contentUrl,
    required this.contentType,
    required this.message,
  });

  final String contentUrl;
  final String contentType;
  final String message;

  @override
  List<Object> get props => [contentUrl, contentType, message];
}

/// State when earnings data is loaded
class InstructorEarningsLoaded extends InstructorState {
  const InstructorEarningsLoaded({
    required this.earnings,
    required this.paymentHistory,
    required this.period,
  });

  final InstructorEarnings earnings;
  final List<PaymentRecord> paymentHistory;
  final String period;

  @override
  List<Object> get props => [earnings, paymentHistory, period];
}

/// State when notifications are loaded
class InstructorNotificationsLoaded extends InstructorState {
  const InstructorNotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  final List<InstructorNotification> notifications;
  final int unreadCount;

  @override
  List<Object> get props => [notifications, unreadCount];
}

/// State when report is generated
class InstructorReportGenerated extends InstructorState {
  const InstructorReportGenerated({
    required this.reportUrl,
    required this.reportType,
    required this.generatedAt,
  });

  final String reportUrl;
  final String reportType;
  final DateTime generatedAt;

  @override
  List<Object> get props => [reportUrl, reportType, generatedAt];
}

/// State when instructor operation fails
class InstructorError extends InstructorState {
  const InstructorError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// Instructor overview model
class InstructorOverview extends Equatable {
  const InstructorOverview({
    required this.totalCourses,
    required this.totalStudents,
    required this.totalEarnings,
    required this.averageRating,
    required this.coursesPublished,
    required this.coursesPending,
    required this.newEnrollmentsThisMonth,
    required this.completionRate,
  });

  final int totalCourses;
  final int totalStudents;
  final double totalEarnings;
  final double averageRating;
  final int coursesPublished;
  final int coursesPending;
  final int newEnrollmentsThisMonth;
  final double completionRate;

  @override
  List<Object> get props => [
    totalCourses, totalStudents, totalEarnings, averageRating,
    coursesPublished, coursesPending, newEnrollmentsThisMonth, completionRate
  ];
}

/// Activity item model
class ActivityItem extends Equatable {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.courseId,
    this.studentId,
  });

  final String id;
  final String type; // enrollment, review, completion, message
  final String description;
  final DateTime timestamp;
  final String? courseId;
  final String? studentId;

  @override
  List<Object?> get props => [id, type, description, timestamp, courseId, studentId];
}

/// Task item model
class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; // high, medium, low
  final String status; // pending, in_progress, completed

  @override
  List<Object> get props => [id, title, description, dueDate, priority, status];
}

/// Instructor analytics model
class InstructorAnalytics extends Equatable {
  const InstructorAnalytics({
    required this.totalRevenue,
    required this.totalEnrollments,
    required this.averageRating,
    required this.completionRate,
    required this.engagementRate,
    required this.refundRate,
    required this.monthlyData,
  });

  final double totalRevenue;
  final int totalEnrollments;
  final double averageRating;
  final double completionRate;
  final double engagementRate;
  final double refundRate;
  final List<MonthlyData> monthlyData;

  @override
  List<Object> get props => [
    totalRevenue, totalEnrollments, averageRating, completionRate,
    engagementRate, refundRate, monthlyData
  ];
}

/// Course analytics model
class CourseAnalytics extends Equatable {
  const CourseAnalytics({
    required this.courseId,
    required this.courseName,
    required this.enrollments,
    required this.revenue,
    required this.averageRating,
    required this.completionRate,
    required this.watchTime,
    required this.dropOffPoints,
  });

  final String courseId;
  final String courseName;
  final int enrollments;
  final double revenue;
  final double averageRating;
  final double completionRate;
  final Duration watchTime;
  final List<DropOffPoint> dropOffPoints;

  @override
  List<Object> get props => [
    courseId, courseName, enrollments, revenue, averageRating,
    completionRate, watchTime, dropOffPoints
  ];
}

/// Monthly data model
class MonthlyData extends Equatable {
  const MonthlyData({
    required this.month,
    required this.revenue,
    required this.enrollments,
    required this.completions,
  });

  final DateTime month;
  final double revenue;
  final int enrollments;
  final int completions;

  @override
  List<Object> get props => [month, revenue, enrollments, completions];
}

/// Drop-off point model
class DropOffPoint extends Equatable {
  const DropOffPoint({
    required this.lessonId,
    required this.lessonTitle,
    required this.dropOffRate,
    required this.averageWatchTime,
  });

  final String lessonId;
  final String lessonTitle;
  final double dropOffRate;
  final Duration averageWatchTime;

  @override
  List<Object> get props => [lessonId, lessonTitle, dropOffRate, averageWatchTime];
}

/// Student enrollment model
class StudentEnrollment extends Equatable {
  const StudentEnrollment({
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseName,
    required this.enrolledAt,
    required this.progress,
    required this.lastActive,
    this.completedAt,
  });

  final String studentId;
  final String studentName;
  final String courseId;
  final String courseName;
  final DateTime enrolledAt;
  final double progress;
  final DateTime lastActive;
  final DateTime? completedAt;

  @override
  List<Object?> get props => [
    studentId, studentName, courseId, courseName,
    enrolledAt, progress, lastActive, completedAt
  ];
}

/// Course review model
class CourseReview extends Equatable {
  const CourseReview({
    required this.id,
    required this.courseId,
    required this.studentId,
    required this.studentName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String courseId;
  final String studentId;
  final String studentName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object> get props => [
    id, courseId, studentId, studentName, rating, comment, createdAt
  ];
}

/// Instructor earnings model
class InstructorEarnings extends Equatable {
  const InstructorEarnings({
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.paidEarnings,
    required this.commissionRate,
    required this.nextPayoutDate,
    required this.thisMonthEarnings,
  });

  final double totalEarnings;
  final double pendingEarnings;
  final double paidEarnings;
  final double commissionRate;
  final DateTime nextPayoutDate;
  final double thisMonthEarnings;

  @override
  List<Object> get props => [
    totalEarnings, pendingEarnings, paidEarnings,
    commissionRate, nextPayoutDate, thisMonthEarnings
  ];
}

/// Payment record model
class PaymentRecord extends Equatable {
  const PaymentRecord({
    required this.id,
    required this.amount,
    required this.payoutDate,
    required this.status,
    required this.coursesSold,
  });

  final String id;
  final double amount;
  final DateTime payoutDate;
  final String status;
  final int coursesSold;

  @override
  List<Object> get props => [id, amount, payoutDate, status, coursesSold];
}

/// Instructor notification model
class InstructorNotification extends Equatable {
  const InstructorNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.actionUrl,
  });

  final String id;
  final String type; // enrollment, review, message, system
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  @override
  List<Object?> get props => [id, type, title, message, createdAt, isRead, actionUrl];
}