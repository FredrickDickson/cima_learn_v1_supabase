import 'package:equatable/equatable.dart';

/// Admin events for the AdminBloc
sealed class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load admin dashboard
class AdminDashboardRequested extends AdminEvent {}

/// Event to load platform analytics
class AdminAnalyticsRequested extends AdminEvent {
  const AdminAnalyticsRequested({this.period});

  final String? period; // daily, weekly, monthly, yearly

  @override
  List<Object?> get props => [period];
}

/// Event to load all users
class AdminUsersRequested extends AdminEvent {
  const AdminUsersRequested({
    this.role,
    this.status,
    this.searchQuery,
    this.page = 1,
  });

  final String? role; // student, instructor, admin
  final String? status; // active, suspended, pending
  final String? searchQuery;
  final int page;

  @override
  List<Object?> get props => [role, status, searchQuery, page];
}

/// Event to manage user status
class AdminUserManageRequested extends AdminEvent {
  const AdminUserManageRequested({
    required this.userId,
    required this.action,
    this.reason,
  });

  final String userId;
  final UserAction action;
  final String? reason;

  @override
  List<Object?> get props => [userId, action, reason];
}

/// Event to load all courses
class AdminCoursesRequested extends AdminEvent {
  const AdminCoursesRequested({
    this.status,
    this.category,
    this.instructorId,
    this.page = 1,
  });

  final String? status; // draft, pending, published, rejected
  final String? category;
  final String? instructorId;
  final int page;

  @override
  List<Object?> get props => [status, category, instructorId, page];
}

/// Event to manage course approval
class AdminCourseManageRequested extends AdminEvent {
  const AdminCourseManageRequested({
    required this.courseId,
    required this.action,
    this.feedback,
  });

  final String courseId;
  final CourseAction action;
  final String? feedback;

  @override
  List<Object?> get props => [courseId, action, feedback];
}

/// Event to load instructor applications
class AdminInstructorApplicationsRequested extends AdminEvent {
  const AdminInstructorApplicationsRequested({this.status});

  final String? status; // pending, approved, rejected

  @override
  List<Object?> get props => [status];
}

/// Event to process instructor application
class AdminInstructorApplicationProcessRequested extends AdminEvent {
  const AdminInstructorApplicationProcessRequested({
    required this.applicationId,
    required this.action,
    this.feedback,
  });

  final String applicationId;
  final ApplicationAction action;
  final String? feedback;

  @override
  List<Object?> get props => [applicationId, action, feedback];
}

/// Event to load platform content reports
class AdminContentReportsRequested extends AdminEvent {
  const AdminContentReportsRequested({this.status});

  final String? status; // pending, resolved, dismissed

  @override
  List<Object?> get props => [status];
}

/// Event to process content report
class AdminContentReportProcessRequested extends AdminEvent {
  const AdminContentReportProcessRequested({
    required this.reportId,
    required this.action,
    this.notes,
  });

  final String reportId;
  final ReportAction action;
  final String? notes;

  @override
  List<Object?> get props => [reportId, action, notes];
}

/// Event to load financial reports
class AdminFinancialReportsRequested extends AdminEvent {
  const AdminFinancialReportsRequested({
    this.period,
    this.reportType,
  });

  final String? period;
  final String? reportType; // revenue, payouts, refunds

  @override
  List<Object?> get props => [period, reportType];
}

/// Event to manage platform settings
class AdminSettingsUpdateRequested extends AdminEvent {
  const AdminSettingsUpdateRequested({
    required this.settingsData,
  });

  final Map<String, dynamic> settingsData;

  @override
  List<Object> get props => [settingsData];
}

/// Event to load system notifications
class AdminNotificationsRequested extends AdminEvent {}

/// Event to send platform announcement
class AdminAnnouncementSendRequested extends AdminEvent {
  const AdminAnnouncementSendRequested({
    required this.title,
    required this.message,
    required this.targetAudience,
    this.scheduledAt,
  });

  final String title;
  final String message;
  final String targetAudience; // all, students, instructors
  final DateTime? scheduledAt;

  @override
  List<Object?> get props => [title, message, targetAudience, scheduledAt];
}

/// Event to load platform logs
class AdminLogsRequested extends AdminEvent {
  const AdminLogsRequested({
    this.level,
    this.module,
    this.startDate,
    this.endDate,
  });

  final String? level; // error, warning, info, debug
  final String? module; // auth, payment, course, user
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [level, module, startDate, endDate];
}

/// Event to backup platform data
class AdminBackupRequested extends AdminEvent {
  const AdminBackupRequested({required this.backupType});

  final String backupType; // full, incremental, users, courses

  @override
  List<Object> get props => [backupType];
}

/// Event to restore platform data
class AdminRestoreRequested extends AdminEvent {
  const AdminRestoreRequested({
    required this.backupId,
    required this.restoreOptions,
  });

  final String backupId;
  final Map<String, bool> restoreOptions;

  @override
  List<Object> get props => [backupId, restoreOptions];
}

/// User management actions
enum UserAction {
  activate,
  suspend,
  delete,
  promoteToInstructor,
  promoteToAdmin,
  demoteToStudent,
  resetPassword,
  sendMessage,
}

/// Course management actions
enum CourseAction {
  approve,
  reject,
  suspend,
  feature,
  unfeature,
  delete,
}

/// Application processing actions
enum ApplicationAction {
  approve,
  reject,
  requestMoreInfo,
}

/// Content report actions
enum ReportAction {
  resolve,
  dismiss,
  escalate,
  removeContent,
  suspendUser,
}