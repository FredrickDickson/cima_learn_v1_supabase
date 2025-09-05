import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import 'admin_event.dart';
import 'admin_state.dart';

/// Admin BLoC managing platform administration and oversight
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(AdminInitial()) {
    // Register event handlers
    on<AdminDashboardRequested>(_onAdminDashboardRequested);
    on<AdminAnalyticsRequested>(_onAdminAnalyticsRequested);
    on<AdminUsersRequested>(_onAdminUsersRequested);
    on<AdminUserManageRequested>(_onAdminUserManageRequested);
    on<AdminCoursesRequested>(_onAdminCoursesRequested);
    on<AdminCourseManageRequested>(_onAdminCourseManageRequested);
    on<AdminInstructorApplicationsRequested>(_onAdminInstructorApplicationsRequested);
    on<AdminInstructorApplicationProcessRequested>(_onAdminInstructorApplicationProcessRequested);
    on<AdminContentReportsRequested>(_onAdminContentReportsRequested);
    on<AdminContentReportProcessRequested>(_onAdminContentReportProcessRequested);
    on<AdminFinancialReportsRequested>(_onAdminFinancialReportsRequested);
    on<AdminSettingsUpdateRequested>(_onAdminSettingsUpdateRequested);
    on<AdminNotificationsRequested>(_onAdminNotificationsRequested);
    on<AdminAnnouncementSendRequested>(_onAdminAnnouncementSendRequested);
    on<AdminLogsRequested>(_onAdminLogsRequested);
    on<AdminBackupRequested>(_onAdminBackupRequested);
  }

  /// Load admin dashboard
  Future<void> _onAdminDashboardRequested(
    AdminDashboardRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    try {
      // Load platform overview
      final usersCount = await supabase.from('user_profiles').select('id', count: CountOption.exact);
      final coursesCount = await supabase.from('courses').select('id', count: CountOption.exact);
      final paymentsSum = await supabase.from('payments').select('amount').eq('status', 'completed');
      
      final totalRevenue = paymentsSum.fold<double>(0, (sum, payment) => sum + (payment['amount'] as num).toDouble());

      final overview = AdminOverview(
        totalUsers: usersCount.count ?? 0,
        totalCourses: coursesCount.count ?? 0,
        totalRevenue: totalRevenue,
        activeInstructors: 45, // Would query instructors with courses
        pendingApprovals: 12, // Would query pending items
        systemAlerts: 3, // Would query system issues
        growthRate: 15.2, // Would calculate month-over-month
      );

      // Load recent activity
      final recentActivity = <AdminActivity>[
        AdminActivity(
          id: '1',
          type: 'user_registration',
          description: 'New user registered: john.doe@example.com',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          severity: 'low',
        ),
        AdminActivity(
          id: '2',
          type: 'course_submission',
          description: 'Course submitted for review: Advanced Contract Law',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          severity: 'medium',
        ),
      ];

      // Load system health
      final systemHealth = SystemHealth(
        overallStatus: 'healthy',
        databaseStatus: 'healthy',
        storageStatus: 'healthy',
        paymentStatus: 'healthy',
        authStatus: 'healthy',
        lastCheckTime: DateTime.now(),
      );

      emit(AdminDashboardLoaded(
        overview: overview,
        recentActivity: recentActivity,
        systemHealth: systemHealth,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to load admin dashboard: $e'));
    }
  }

  /// Load platform analytics
  Future<void> _onAdminAnalyticsRequested(
    AdminAnalyticsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    try {
      // Simplified analytics implementation
      final userGrowth = GrowthMetrics(
        current: 1250,
        previous: 1180,
        growthRate: 5.9,
        trend: 'up',
      );

      final courseGrowth = GrowthMetrics(
        current: 89,
        previous: 85,
        growthRate: 4.7,
        trend: 'up',
      );

      final revenueGrowth = GrowthMetrics(
        current: 15420.00,
        previous: 14200.00,
        growthRate: 8.6,
        trend: 'up',
      );

      final engagementMetrics = EngagementMetrics(
        averageSessionDuration: const Duration(minutes: 45),
        courseCompletionRate: 0.73,
        userRetentionRate: 0.85,
        activeUsersDaily: 342,
        activeUsersMonthly: 1156,
      );

      final analytics = PlatformAnalytics(
        userGrowth: userGrowth,
        courseGrowth: courseGrowth,
        revenueGrowth: revenueGrowth,
        engagementMetrics: engagementMetrics,
        topCourses: [],
        topInstructors: [],
      );

      emit(AdminAnalyticsLoaded(
        analytics: analytics,
        period: event.period ?? 'monthly',
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to load analytics: $e'));
    }
  }

  /// Load users list
  Future<void> _onAdminUsersRequested(
    AdminUsersRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    try {
      var query = supabase.from('user_profiles').select('*');

      // Apply filters
      if (event.role != null) {
        query = query.eq('role', event.role!);
      }

      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        query = query.or('full_name.ilike.%${event.searchQuery}%,email.ilike.%${event.searchQuery}%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range((event.page - 1) * 20, event.page * 20 - 1);

      // Get total count
      final countResponse = await supabase
          .from('user_profiles')
          .select('id', count: CountOption.exact);

      final users = response.map((data) => UserProfile.fromJson(data)).toList();
      final totalUsers = countResponse.count ?? 0;
      final totalPages = (totalUsers / 20).ceil();

      emit(AdminUsersLoaded(
        users: users,
        totalUsers: totalUsers,
        currentPage: event.page,
        totalPages: totalPages,
        filters: {
          if (event.role != null) 'role': event.role!,
          if (event.status != null) 'status': event.status!,
          if (event.searchQuery != null) 'search': event.searchQuery!,
        },
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to load users: $e'));
    }
  }

  /// Manage user status
  Future<void> _onAdminUserManageRequested(
    AdminUserManageRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      String message = '';
      
      switch (event.action) {
        case UserAction.activate:
          await supabase
              .from('user_profiles')
              .update({'status': 'active'})
              .eq('id', event.userId);
          message = 'User activated successfully';
          break;

        case UserAction.suspend:
          await supabase
              .from('user_profiles')
              .update({'status': 'suspended'})
              .eq('id', event.userId);
          message = 'User suspended successfully';
          break;

        case UserAction.promoteToInstructor:
          await supabase
              .from('user_profiles')
              .update({'role': 'instructor'})
              .eq('id', event.userId);
          message = 'User promoted to instructor';
          break;

        case UserAction.promoteToAdmin:
          await supabase
              .from('user_profiles')
              .update({'role': 'admin'})
              .eq('id', event.userId);
          message = 'User promoted to admin';
          break;

        case UserAction.demoteToStudent:
          await supabase
              .from('user_profiles')
              .update({'role': 'student'})
              .eq('id', event.userId);
          message = 'User demoted to student';
          break;

        default:
          message = 'Action completed';
      }

      emit(AdminUserManageSuccess(
        message: message,
        userId: event.userId,
        action: event.action.name,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to manage user: $e'));
    }
  }

  /// Load courses list
  Future<void> _onAdminCoursesRequested(
    AdminCoursesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    try {
      var query = supabase.from('courses').select('*');

      // Apply filters
      if (event.status != null) {
        query = query.eq('status', event.status!);
      }

      if (event.category != null) {
        query = query.eq('category', event.category!);
      }

      if (event.instructorId != null) {
        query = query.eq('instructor_id', event.instructorId!);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range((event.page - 1) * 20, event.page * 20 - 1);

      final courses = response.map((data) => Course.fromJson(data)).toList();

      emit(AdminCoursesLoaded(
        courses: courses,
        totalCourses: courses.length,
        currentPage: event.page,
        totalPages: 1, // Would calculate based on total count
        filters: {
          if (event.status != null) 'status': event.status!,
          if (event.category != null) 'category': event.category!,
        },
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to load courses: $e'));
    }
  }

  /// Manage course approval
  Future<void> _onAdminCourseManageRequested(
    AdminCourseManageRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      String newStatus = '';
      String message = '';

      switch (event.action) {
        case CourseAction.approve:
          newStatus = 'published';
          message = 'Course approved and published';
          break;
        case CourseAction.reject:
          newStatus = 'rejected';
          message = 'Course rejected';
          break;
        case CourseAction.suspend:
          newStatus = 'suspended';
          message = 'Course suspended';
          break;
        case CourseAction.feature:
          await supabase
              .from('courses')
              .update({'is_featured': true})
              .eq('id', event.courseId);
          message = 'Course featured';
          break;
        case CourseAction.unfeature:
          await supabase
              .from('courses')
              .update({'is_featured': false})
              .eq('id', event.courseId);
          message = 'Course unfeatured';
          break;
        case CourseAction.delete:
          await supabase
              .from('courses')
              .delete()
              .eq('id', event.courseId);
          message = 'Course deleted';
          break;
      }

      if (newStatus.isNotEmpty) {
        await supabase
            .from('courses')
            .update({
              'status': newStatus,
              'reviewed_at': DateTime.now().toIso8601String(),
              'review_feedback': event.feedback,
            })
            .eq('id', event.courseId);
      }

      emit(AdminCourseManageSuccess(
        message: message,
        courseId: event.courseId,
        action: event.action.name,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to manage course: $e'));
    }
  }

  /// Load instructor applications
  Future<void> _onAdminInstructorApplicationsRequested(
    AdminInstructorApplicationsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    try {
      var query = supabase
          .from('instructor_applications')
          .select('*, user_profiles!instructor_applications_user_id_fkey(full_name, email)');

      if (event.status != null) {
        query = query.eq('status', event.status!);
      }

      final response = await query.order('submitted_at', ascending: false);

      final applications = response.map((data) => InstructorApplication(
        id: data['id'],
        userId: data['user_id'],
        userName: data['user_profiles']['full_name'] ?? 'Unknown',
        userEmail: data['user_profiles']['email'] ?? 'Unknown',
        applicationData: data['application_data'] ?? {},
        status: data['status'],
        submittedAt: DateTime.parse(data['submitted_at']),
        reviewedAt: data['reviewed_at'] != null ? DateTime.parse(data['reviewed_at']) : null,
        reviewedBy: data['reviewed_by'],
        feedback: data['feedback'],
      )).toList();

      emit(AdminInstructorApplicationsLoaded(
        applications: applications,
        statusFilter: event.status,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to load instructor applications: $e'));
    }
  }

  /// Process instructor application
  Future<void> _onAdminInstructorApplicationProcessRequested(
    AdminInstructorApplicationProcessRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      String newStatus = '';
      String message = '';

      switch (event.action) {
        case ApplicationAction.approve:
          newStatus = 'approved';
          message = 'Application approved';
          
          // Promote user to instructor
          final applicationData = await supabase
              .from('instructor_applications')
              .select('user_id')
              .eq('id', event.applicationId)
              .single();

          await supabase
              .from('user_profiles')
              .update({'role': 'instructor'})
              .eq('id', applicationData['user_id']);
          break;

        case ApplicationAction.reject:
          newStatus = 'rejected';
          message = 'Application rejected';
          break;

        case ApplicationAction.requestMoreInfo:
          newStatus = 'pending_info';
          message = 'More information requested';
          break;
      }

      await supabase
          .from('instructor_applications')
          .update({
            'status': newStatus,
            'reviewed_at': DateTime.now().toIso8601String(),
            'feedback': event.feedback,
          })
          .eq('id', event.applicationId);

      emit(AdminApplicationProcessSuccess(
        message: message,
        applicationId: event.applicationId,
        action: event.action.name,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to process application: $e'));
    }
  }

  /// Load content reports
  Future<void> _onAdminContentReportsRequested(
    AdminContentReportsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    try {
      // Simplified implementation
      final reports = <ContentReport>[
        ContentReport(
          id: '1',
          reporterId: 'user1',
          reporterName: 'John Doe',
          contentType: 'course',
          contentId: 'course1',
          reason: 'inappropriate_content',
          description: 'Contains offensive material',
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      emit(AdminContentReportsLoaded(
        reports: reports,
        statusFilter: event.status,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to load content reports: $e'));
    }
  }

  /// Process content report
  Future<void> _onAdminContentReportProcessRequested(
    AdminContentReportProcessRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      // Would implement report processing logic
      emit(AdminCourseManageSuccess(
        message: 'Content report processed',
        courseId: event.reportId,
        action: event.action.name,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to process content report: $e'));
    }
  }

  /// Load financial reports
  Future<void> _onAdminFinancialReportsRequested(
    AdminFinancialReportsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    try {
      // Simplified financial data
      final financialData = FinancialData(
        totalRevenue: 125420.00,
        instructorPayouts: 87794.00,
        platformCommission: 37626.00,
        refunds: 2450.00,
        netRevenue: 122970.00,
        periodData: [
          PeriodFinancialData(
            period: DateTime(2025, 8),
            revenue: 15200.00,
            transactions: 342,
            averageOrderValue: 44.44,
          ),
          PeriodFinancialData(
            period: DateTime(2025, 9),
            revenue: 18750.00,
            transactions: 398,
            averageOrderValue: 47.11,
          ),
        ],
      );

      emit(AdminFinancialReportsLoaded(
        financialData: financialData,
        period: event.period ?? 'monthly',
        reportType: event.reportType ?? 'revenue',
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to load financial reports: $e'));
    }
  }

  /// Update platform settings
  Future<void> _onAdminSettingsUpdateRequested(
    AdminSettingsUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      // Would implement settings update logic
      emit(AdminSettingsUpdated(
        message: 'Platform settings updated successfully',
        updatedSettings: event.settingsData,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to update settings: $e'));
    }
  }

  /// Load notifications
  Future<void> _onAdminNotificationsRequested(
    AdminNotificationsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    try {
      // Simplified notifications
      final notifications = <AdminNotification>[
        AdminNotification(
          id: '1',
          type: 'system',
          title: 'System Update Required',
          message: 'A security update is available',
          priority: 'high',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
      ];

      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(AdminNotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to load notifications: $e'));
    }
  }

  /// Send announcement
  Future<void> _onAdminAnnouncementSendRequested(
    AdminAnnouncementSendRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      // Would implement announcement sending logic
      int recipientCount = 0;

      switch (event.targetAudience) {
        case 'all':
          recipientCount = 1250; // Total users
          break;
        case 'students':
          recipientCount = 1100; // Student count
          break;
        case 'instructors':
          recipientCount = 150; // Instructor count
          break;
      }

      emit(AdminAnnouncementSent(
        message: 'Announcement sent successfully',
        recipientCount: recipientCount,
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to send announcement: $e'));
    }
  }

  /// Load system logs
  Future<void> _onAdminLogsRequested(
    AdminLogsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    try {
      // Simplified logs
      final logs = <SystemLog>[
        SystemLog(
          id: '1',
          level: 'info',
          module: 'auth',
          message: 'User login successful',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          userId: 'user123',
        ),
      ];

      emit(AdminLogsLoaded(
        logs: logs,
        filters: {
          'level': event.level,
          'module': event.module,
        },
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to load logs: $e'));
    }
  }

  /// Request backup
  Future<void> _onAdminBackupRequested(
    AdminBackupRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(AdminBackupInProgress(
        backupType: event.backupType,
        progress: 0.0,
      ));

      // Simulate backup progress
      for (double progress = 0.1; progress <= 1.0; progress += 0.1) {
        await Future.delayed(const Duration(milliseconds: 300));
        emit(AdminBackupInProgress(
          backupType: event.backupType,
          progress: progress,
        ));
      }

      emit(AdminBackupCompleted(
        backupId: 'backup_${DateTime.now().millisecondsSinceEpoch}',
        backupType: event.backupType,
        filePath: '/backups/${event.backupType}_backup.sql',
      ));
    } catch (e) {
      emit(AdminError(message: 'Failed to create backup: $e'));
    }
  }
}