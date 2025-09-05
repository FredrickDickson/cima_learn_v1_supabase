import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../../models/course.dart';
import 'instructor_event.dart';
import 'instructor_state.dart';

/// Instructor BLoC managing instructor dashboard and course management
class InstructorBloc extends Bloc<InstructorEvent, InstructorState> {
  InstructorBloc() : super(InstructorInitial()) {
    // Register event handlers
    on<InstructorDashboardRequested>(_onInstructorDashboardRequested);
    on<InstructorCoursesRequested>(_onInstructorCoursesRequested);
    on<InstructorCourseCreateRequested>(_onInstructorCourseCreateRequested);
    on<InstructorCourseUpdateRequested>(_onInstructorCourseUpdateRequested);
    on<InstructorCourseDeleteRequested>(_onInstructorCourseDeleteRequested);
    on<InstructorCourseSubmitRequested>(_onInstructorCourseSubmitRequested);
    on<InstructorAnalyticsRequested>(_onInstructorAnalyticsRequested);
    on<InstructorStudentsRequested>(_onInstructorStudentsRequested);
    on<InstructorReviewsRequested>(_onInstructorReviewsRequested);
    on<InstructorContentUploadRequested>(_onInstructorContentUploadRequested);
    on<InstructorLessonManageRequested>(_onInstructorLessonManageRequested);
    on<InstructorEarningsRequested>(_onInstructorEarningsRequested);
    on<InstructorProfileUpdateRequested>(_onInstructorProfileUpdateRequested);
    on<InstructorNotificationsRequested>(_onInstructorNotificationsRequested);
  }

  /// Load instructor dashboard data
  Future<void> _onInstructorDashboardRequested(
    InstructorDashboardRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());

    try {
      // Load overview data
      final coursesResponse = await supabase
          .from('courses')
          .select('id, status')
          .eq('instructor_id', event.instructorId);

      final enrollmentsResponse = await supabase
          .from('enrollments')
          .select('course_id, courses!enrollments_course_id_fkey(instructor_id)')
          .eq('courses.instructor_id', event.instructorId);

      final overview = InstructorOverview(
        totalCourses: coursesResponse.length,
        totalStudents: enrollmentsResponse.length,
        totalEarnings: 0.0, // Would calculate from payments
        averageRating: 4.5, // Would calculate from reviews
        coursesPublished: coursesResponse.where((c) => c['status'] == 'published').length,
        coursesPending: coursesResponse.where((c) => c['status'] == 'pending').length,
        newEnrollmentsThisMonth: 0, // Would calculate based on date
        completionRate: 0.85, // Would calculate from progress data
      );

      // Load recent activity (simplified)
      final recentActivity = <ActivityItem>[
        ActivityItem(
          id: '1',
          type: 'enrollment',
          description: 'New student enrolled in Advanced Mediation',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      // Load upcoming tasks (simplified)
      final upcomingTasks = <TaskItem>[
        TaskItem(
          id: '1',
          title: 'Review student submissions',
          description: 'Check 5 pending assignments',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          priority: 'high',
          status: 'pending',
        ),
      ];

      emit(InstructorDashboardLoaded(
        overview: overview,
        recentActivity: recentActivity,
        upcomingTasks: upcomingTasks,
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to load dashboard: $e'));
    }
  }

  /// Load instructor's courses
  Future<void> _onInstructorCoursesRequested(
    InstructorCoursesRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());

    try {
      var query = supabase
          .from('courses')
          .select('*')
          .eq('instructor_id', event.instructorId);

      if (event.status != null) {
        query = query.eq('status', event.status!);
      }

      final response = await query.order('created_at', ascending: false);
      final courses = response.map((data) => Course.fromJson(data)).toList();

      emit(InstructorCoursesLoaded(
        courses: courses,
        totalCourses: courses.length,
        filter: event.status,
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to load courses: $e'));
    }
  }

  /// Create new course
  Future<void> _onInstructorCourseCreateRequested(
    InstructorCourseCreateRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorCourseProcessing(action: 'creating'));

    try {
      final courseData = {
        ...event.courseData,
        'instructor_id': event.instructorId,
        'status': 'draft',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('courses')
          .insert(courseData)
          .select()
          .single();

      emit(InstructorCourseSuccess(
        message: 'Course created successfully',
        courseId: response['id'],
        action: 'created',
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to create course: $e'));
    }
  }

  /// Update existing course
  Future<void> _onInstructorCourseUpdateRequested(
    InstructorCourseUpdateRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorCourseProcessing(action: 'updating', courseId: event.courseId));

    try {
      await supabase
          .from('courses')
          .update({
            ...event.updateData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.courseId);

      emit(InstructorCourseSuccess(
        message: 'Course updated successfully',
        courseId: event.courseId,
        action: 'updated',
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to update course: $e'));
    }
  }

  /// Delete course
  Future<void> _onInstructorCourseDeleteRequested(
    InstructorCourseDeleteRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorCourseProcessing(action: 'deleting', courseId: event.courseId));

    try {
      await supabase
          .from('courses')
          .delete()
          .eq('id', event.courseId);

      emit(InstructorCourseSuccess(
        message: 'Course deleted successfully',
        courseId: event.courseId,
        action: 'deleted',
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to delete course: $e'));
    }
  }

  /// Submit course for approval
  Future<void> _onInstructorCourseSubmitRequested(
    InstructorCourseSubmitRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorCourseProcessing(action: 'submitting', courseId: event.courseId));

    try {
      await supabase
          .from('courses')
          .update({
            'status': 'pending',
            'submitted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.courseId);

      emit(InstructorCourseSuccess(
        message: 'Course submitted for review',
        courseId: event.courseId,
        action: 'submitted',
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to submit course: $e'));
    }
  }

  /// Load analytics data
  Future<void> _onInstructorAnalyticsRequested(
    InstructorAnalyticsRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());

    try {
      // Simplified analytics implementation
      final analytics = InstructorAnalytics(
        totalRevenue: 5250.00,
        totalEnrollments: 342,
        averageRating: 4.7,
        completionRate: 0.78,
        engagementRate: 0.85,
        refundRate: 0.02,
        monthlyData: [
          MonthlyData(
            month: DateTime(2025, 8),
            revenue: 1200.00,
            enrollments: 45,
            completions: 38,
          ),
          MonthlyData(
            month: DateTime(2025, 9),
            revenue: 1850.00,
            enrollments: 67,
            completions: 52,
          ),
        ],
      );

      final courseAnalytics = <String, CourseAnalytics>{};

      emit(InstructorAnalyticsLoaded(
        analytics: analytics,
        courseAnalytics: courseAnalytics,
        period: event.dateRange?.toString() ?? 'all-time',
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to load analytics: $e'));
    }
  }

  /// Load students data
  Future<void> _onInstructorStudentsRequested(
    InstructorStudentsRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());

    try {
      var query = supabase
          .from('enrollments')
          .select('*, courses!enrollments_course_id_fkey(title), user_profiles!enrollments_user_id_fkey(full_name)')
          .eq('courses.instructor_id', event.instructorId);

      if (event.courseId != null) {
        query = query.eq('course_id', event.courseId!);
      }

      final response = await query.order('enrolled_at', ascending: false);

      final students = response.map((data) => StudentEnrollment(
        studentId: data['user_id'],
        studentName: data['user_profiles']['full_name'] ?? 'Unknown',
        courseId: data['course_id'],
        courseName: data['courses']['title'] ?? 'Unknown Course',
        enrolledAt: DateTime.parse(data['enrolled_at']),
        progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
        lastActive: DateTime.parse(data['updated_at'] ?? data['enrolled_at']),
      )).toList();

      emit(InstructorStudentsLoaded(
        students: students,
        totalStudents: students.length,
        courseFilter: event.courseId,
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to load students: $e'));
    }
  }

  /// Load reviews data
  Future<void> _onInstructorReviewsRequested(
    InstructorReviewsRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());

    try {
      var query = supabase
          .from('course_reviews')
          .select('*, courses!course_reviews_course_id_fkey(instructor_id), user_profiles!course_reviews_user_id_fkey(full_name)')
          .eq('courses.instructor_id', event.instructorId);

      if (event.courseId != null) {
        query = query.eq('course_id', event.courseId!);
      }

      final response = await query.order('created_at', ascending: false);

      final reviews = response.map((data) => CourseReview(
        id: data['id'],
        courseId: data['course_id'],
        studentId: data['user_id'],
        studentName: data['user_profiles']['full_name'] ?? 'Anonymous',
        rating: data['rating'],
        comment: data['comment'] ?? '',
        createdAt: DateTime.parse(data['created_at']),
      )).toList();

      final averageRating = reviews.isNotEmpty
          ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length
          : 0.0;

      emit(InstructorReviewsLoaded(
        reviews: reviews,
        averageRating: averageRating,
        totalReviews: reviews.length,
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to load reviews: $e'));
    }
  }

  /// Handle content upload
  Future<void> _onInstructorContentUploadRequested(
    InstructorContentUploadRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorContentUploading(
      progress: 0.0,
      contentType: event.contentType,
    ));

    try {
      // Simulate upload progress
      for (double progress = 0.1; progress <= 1.0; progress += 0.1) {
        await Future.delayed(const Duration(milliseconds: 200));
        emit(InstructorContentUploading(
          progress: progress,
          contentType: event.contentType,
        ));
      }

      // Simulate successful upload
      final contentUrl = 'https://storage.supabase.co/bucket/${event.contentType}s/uploaded_file.${event.contentType}';

      emit(InstructorContentUploaded(
        contentUrl: contentUrl,
        contentType: event.contentType,
        message: '${event.contentType.toUpperCase()} uploaded successfully',
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to upload content: $e'));
    }
  }

  /// Handle lesson management
  Future<void> _onInstructorLessonManageRequested(
    InstructorLessonManageRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorCourseProcessing(action: 'managing_lessons'));

    try {
      switch (event.action) {
        case LessonAction.create:
          await supabase.from('lessons').insert({
            ...event.lessonData!,
            'course_id': event.courseId,
            'created_at': DateTime.now().toIso8601String(),
          });
          break;
        
        case LessonAction.update:
          await supabase
              .from('lessons')
              .update(event.lessonData!)
              .eq('id', event.lessonId!);
          break;
          
        case LessonAction.delete:
          await supabase
              .from('lessons')
              .delete()
              .eq('id', event.lessonId!);
          break;
          
        default:
          // Handle other actions
          break;
      }

      emit(InstructorCourseSuccess(
        message: 'Lesson ${event.action.name} successful',
        courseId: event.courseId,
        action: event.action.name,
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to manage lesson: $e'));
    }
  }

  /// Load earnings data
  Future<void> _onInstructorEarningsRequested(
    InstructorEarningsRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());

    try {
      // Simplified earnings implementation
      final earnings = InstructorEarnings(
        totalEarnings: 12450.00,
        pendingEarnings: 850.00,
        paidEarnings: 11600.00,
        commissionRate: 0.70, // 70% to instructor
        nextPayoutDate: DateTime.now().add(const Duration(days: 7)),
        thisMonthEarnings: 2100.00,
      );

      final paymentHistory = <PaymentRecord>[
        PaymentRecord(
          id: '1',
          amount: 1200.00,
          payoutDate: DateTime.now().subtract(const Duration(days: 30)),
          status: 'paid',
          coursesSold: 24,
        ),
      ];

      emit(InstructorEarningsLoaded(
        earnings: earnings,
        paymentHistory: paymentHistory,
        period: event.period ?? 'all-time',
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to load earnings: $e'));
    }
  }

  /// Update instructor profile
  Future<void> _onInstructorProfileUpdateRequested(
    InstructorProfileUpdateRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());

    try {
      await supabase
          .from('user_profiles')
          .update({
            ...event.profileData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.instructorId);

      emit(InstructorCourseSuccess(
        message: 'Profile updated successfully',
        courseId: event.instructorId,
        action: 'profile_updated',
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to update profile: $e'));
    }
  }

  /// Load notifications
  Future<void> _onInstructorNotificationsRequested(
    InstructorNotificationsRequested event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());

    try {
      // Simplified notifications implementation
      final notifications = <InstructorNotification>[
        InstructorNotification(
          id: '1',
          type: 'enrollment',
          title: 'New Enrollment',
          message: 'A student enrolled in your Advanced Mediation course',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
      ];

      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(InstructorNotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(InstructorError(message: 'Failed to load notifications: $e'));
    }
  }
}