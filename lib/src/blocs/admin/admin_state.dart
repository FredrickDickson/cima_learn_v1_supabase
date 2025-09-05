import 'package:equatable/equatable.dart';
import '../../models/course.dart';
import '../../models/user_profile.dart';

/// Admin states for the AdminBloc
sealed class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class AdminInitial extends AdminState {}

/// State when admin data is being loaded
class AdminLoading extends AdminState {}

/// State when admin dashboard is loaded
class AdminDashboardLoaded extends AdminState {
  const AdminDashboardLoaded({
    required this.overview,
    required this.recentActivity,
    required this.systemHealth,
  });

  final AdminOverview overview;
  final List<AdminActivity> recentActivity;
  final SystemHealth systemHealth;

  @override
  List<Object> get props => [overview, recentActivity, systemHealth];
}

/// State when platform analytics are loaded
class AdminAnalyticsLoaded extends AdminState {
  const AdminAnalyticsLoaded({
    required this.analytics,
    required this.period,
  });

  final PlatformAnalytics analytics;
  final String period;

  @override
  List<Object> get props => [analytics, period];
}

/// State when users list is loaded
class AdminUsersLoaded extends AdminState {
  const AdminUsersLoaded({
    required this.users,
    required this.totalUsers,
    required this.currentPage,
    required this.totalPages,
    this.filters,
  });

  final List<UserProfile> users;
  final int totalUsers;
  final int currentPage;
  final int totalPages;
  final Map<String, String>? filters;

  @override
  List<Object?> get props => [users, totalUsers, currentPage, totalPages, filters];
}

/// State when user management operation is successful
class AdminUserManageSuccess extends AdminState {
  const AdminUserManageSuccess({
    required this.message,
    required this.userId,
    required this.action,
  });

  final String message;
  final String userId;
  final String action;

  @override
  List<Object> get props => [message, userId, action];
}

/// State when courses list is loaded
class AdminCoursesLoaded extends AdminState {
  const AdminCoursesLoaded({
    required this.courses,
    required this.totalCourses,
    required this.currentPage,
    required this.totalPages,
    this.filters,
  });

  final List<Course> courses;
  final int totalCourses;
  final int currentPage;
  final int totalPages;
  final Map<String, String>? filters;

  @override
  List<Object?> get props => [courses, totalCourses, currentPage, totalPages, filters];
}

/// State when course management operation is successful
class AdminCourseManageSuccess extends AdminState {
  const AdminCourseManageSuccess({
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

/// State when instructor applications are loaded
class AdminInstructorApplicationsLoaded extends AdminState {
  const AdminInstructorApplicationsLoaded({
    required this.applications,
    this.statusFilter,
  });

  final List<InstructorApplication> applications;
  final String? statusFilter;

  @override
  List<Object?> get props => [applications, statusFilter];
}

/// State when application processing is successful
class AdminApplicationProcessSuccess extends AdminState {
  const AdminApplicationProcessSuccess({
    required this.message,
    required this.applicationId,
    required this.action,
  });

  final String message;
  final String applicationId;
  final String action;

  @override
  List<Object> get props => [message, applicationId, action];
}

/// State when content reports are loaded
class AdminContentReportsLoaded extends AdminState {
  const AdminContentReportsLoaded({
    required this.reports,
    this.statusFilter,
  });

  final List<ContentReport> reports;
  final String? statusFilter;

  @override
  List<Object?> get props => [reports, statusFilter];
}

/// State when financial reports are loaded
class AdminFinancialReportsLoaded extends AdminState {
  const AdminFinancialReportsLoaded({
    required this.financialData,
    required this.period,
    required this.reportType,
  });

  final FinancialData financialData;
  final String period;
  final String reportType;

  @override
  List<Object> get props => [financialData, period, reportType];
}

/// State when platform settings are updated
class AdminSettingsUpdated extends AdminState {
  const AdminSettingsUpdated({
    required this.message,
    required this.updatedSettings,
  });

  final String message;
  final Map<String, dynamic> updatedSettings;

  @override
  List<Object> get props => [message, updatedSettings];
}

/// State when notifications are loaded
class AdminNotificationsLoaded extends AdminState {
  const AdminNotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  final List<AdminNotification> notifications;
  final int unreadCount;

  @override
  List<Object> get props => [notifications, unreadCount];
}

/// State when announcement is sent
class AdminAnnouncementSent extends AdminState {
  const AdminAnnouncementSent({
    required this.message,
    required this.recipientCount,
  });

  final String message;
  final int recipientCount;

  @override
  List<Object> get props => [message, recipientCount];
}

/// State when system logs are loaded
class AdminLogsLoaded extends AdminState {
  const AdminLogsLoaded({
    required this.logs,
    required this.filters,
  });

  final List<SystemLog> logs;
  final Map<String, String?> filters;

  @override
  List<Object> get props => [logs, filters];
}

/// State when backup is in progress
class AdminBackupInProgress extends AdminState {
  const AdminBackupInProgress({
    required this.backupType,
    required this.progress,
  });

  final String backupType;
  final double progress;

  @override
  List<Object> get props => [backupType, progress];
}

/// State when backup is completed
class AdminBackupCompleted extends AdminState {
  const AdminBackupCompleted({
    required this.backupId,
    required this.backupType,
    required this.filePath,
  });

  final String backupId;
  final String backupType;
  final String filePath;

  @override
  List<Object> get props => [backupId, backupType, filePath];
}

/// State when admin operation fails
class AdminError extends AdminState {
  const AdminError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// Admin overview model
class AdminOverview extends Equatable {
  const AdminOverview({
    required this.totalUsers,
    required this.totalCourses,
    required this.totalRevenue,
    required this.activeInstructors,
    required this.pendingApprovals,
    required this.systemAlerts,
    required this.growthRate,
  });

  final int totalUsers;
  final int totalCourses;
  final double totalRevenue;
  final int activeInstructors;
  final int pendingApprovals;
  final int systemAlerts;
  final double growthRate;

  @override
  List<Object> get props => [
    totalUsers, totalCourses, totalRevenue, activeInstructors,
    pendingApprovals, systemAlerts, growthRate
  ];
}

/// Admin activity model
class AdminActivity extends Equatable {
  const AdminActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.severity,
    this.relatedUserId,
    this.relatedCourseId,
  });

  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String severity; // low, medium, high, critical
  final String? relatedUserId;
  final String? relatedCourseId;

  @override
  List<Object?> get props => [
    id, type, description, timestamp, severity, relatedUserId, relatedCourseId
  ];
}

/// System health model
class SystemHealth extends Equatable {
  const SystemHealth({
    required this.overallStatus,
    required this.databaseStatus,
    required this.storageStatus,
    required this.paymentStatus,
    required this.authStatus,
    required this.lastCheckTime,
  });

  final String overallStatus; // healthy, warning, critical
  final String databaseStatus;
  final String storageStatus;
  final String paymentStatus;
  final String authStatus;
  final DateTime lastCheckTime;

  @override
  List<Object> get props => [
    overallStatus, databaseStatus, storageStatus,
    paymentStatus, authStatus, lastCheckTime
  ];
}

/// Platform analytics model
class PlatformAnalytics extends Equatable {
  const PlatformAnalytics({
    required this.userGrowth,
    required this.courseGrowth,
    required this.revenueGrowth,
    required this.engagementMetrics,
    required this.topCourses,
    required this.topInstructors,
  });

  final GrowthMetrics userGrowth;
  final GrowthMetrics courseGrowth;
  final GrowthMetrics revenueGrowth;
  final EngagementMetrics engagementMetrics;
  final List<CourseMetrics> topCourses;
  final List<InstructorMetrics> topInstructors;

  @override
  List<Object> get props => [
    userGrowth, courseGrowth, revenueGrowth,
    engagementMetrics, topCourses, topInstructors
  ];
}

/// Growth metrics model
class GrowthMetrics extends Equatable {
  const GrowthMetrics({
    required this.current,
    required this.previous,
    required this.growthRate,
    required this.trend,
  });

  final double current;
  final double previous;
  final double growthRate;
  final String trend; // up, down, stable

  @override
  List<Object> get props => [current, previous, growthRate, trend];
}

/// Engagement metrics model
class EngagementMetrics extends Equatable {
  const EngagementMetrics({
    required this.averageSessionDuration,
    required this.courseCompletionRate,
    required this.userRetentionRate,
    required this.activeUsersDaily,
    required this.activeUsersMonthly,
  });

  final Duration averageSessionDuration;
  final double courseCompletionRate;
  final double userRetentionRate;
  final int activeUsersDaily;
  final int activeUsersMonthly;

  @override
  List<Object> get props => [
    averageSessionDuration, courseCompletionRate, userRetentionRate,
    activeUsersDaily, activeUsersMonthly
  ];
}

/// Course metrics model
class CourseMetrics extends Equatable {
  const CourseMetrics({
    required this.courseId,
    required this.title,
    required this.enrollments,
    required this.revenue,
    required this.rating,
    required this.completionRate,
  });

  final String courseId;
  final String title;
  final int enrollments;
  final double revenue;
  final double rating;
  final double completionRate;

  @override
  List<Object> get props => [courseId, title, enrollments, revenue, rating, completionRate];
}

/// Instructor metrics model
class InstructorMetrics extends Equatable {
  const InstructorMetrics({
    required this.instructorId,
    required this.name,
    required this.totalCourses,
    required this.totalStudents,
    required this.totalRevenue,
    required this.averageRating,
  });

  final String instructorId;
  final String name;
  final int totalCourses;
  final int totalStudents;
  final double totalRevenue;
  final double averageRating;

  @override
  List<Object> get props => [
    instructorId, name, totalCourses, totalStudents, totalRevenue, averageRating
  ];
}

/// Instructor application model
class InstructorApplication extends Equatable {
  const InstructorApplication({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.applicationData,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.feedback,
  });

  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final Map<String, dynamic> applicationData;
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? feedback;

  @override
  List<Object?> get props => [
    id, userId, userName, userEmail, applicationData, status,
    submittedAt, reviewedAt, reviewedBy, feedback
  ];
}

/// Content report model
class ContentReport extends Equatable {
  const ContentReport({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.contentType,
    required this.contentId,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNotes,
  });

  final String id;
  final String reporterId;
  final String reporterName;
  final String contentType; // course, lesson, comment, review
  final String contentId;
  final String reason;
  final String description;
  final String status; // pending, resolved, dismissed
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolutionNotes;

  @override
  List<Object?> get props => [
    id, reporterId, reporterName, contentType, contentId, reason,
    description, status, createdAt, resolvedAt, resolvedBy, resolutionNotes
  ];
}

/// Financial data model
class FinancialData extends Equatable {
  const FinancialData({
    required this.totalRevenue,
    required this.instructorPayouts,
    required this.platformCommission,
    required this.refunds,
    required this.netRevenue,
    required this.periodData,
  });

  final double totalRevenue;
  final double instructorPayouts;
  final double platformCommission;
  final double refunds;
  final double netRevenue;
  final List<PeriodFinancialData> periodData;

  @override
  List<Object> get props => [
    totalRevenue, instructorPayouts, platformCommission,
    refunds, netRevenue, periodData
  ];
}

/// Period financial data model
class PeriodFinancialData extends Equatable {
  const PeriodFinancialData({
    required this.period,
    required this.revenue,
    required this.transactions,
    required this.averageOrderValue,
  });

  final DateTime period;
  final double revenue;
  final int transactions;
  final double averageOrderValue;

  @override
  List<Object> get props => [period, revenue, transactions, averageOrderValue];
}

/// Admin notification model
class AdminNotification extends Equatable {
  const AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    required this.createdAt,
    required this.isRead,
    this.actionUrl,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final String priority; // low, medium, high, urgent
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  @override
  List<Object?> get props => [
    id, type, title, message, priority, createdAt, isRead, actionUrl
  ];
}

/// System log model
class SystemLog extends Equatable {
  const SystemLog({
    required this.id,
    required this.level,
    required this.module,
    required this.message,
    required this.timestamp,
    this.userId,
    this.metadata,
  });

  final String id;
  final String level;
  final String module;
  final String message;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [id, level, module, message, timestamp, userId, metadata];
}