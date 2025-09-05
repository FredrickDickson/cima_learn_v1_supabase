import 'package:equatable/equatable.dart';

/// Instructor events for the InstructorBloc
sealed class InstructorEvent extends Equatable {
  const InstructorEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load instructor dashboard data
class InstructorDashboardRequested extends InstructorEvent {
  const InstructorDashboardRequested({required this.instructorId});

  final String instructorId;

  @override
  List<Object> get props => [instructorId];
}

/// Event to load instructor's courses
class InstructorCoursesRequested extends InstructorEvent {
  const InstructorCoursesRequested({
    required this.instructorId,
    this.status,
  });

  final String instructorId;
  final String? status; // draft, pending, published, rejected

  @override
  List<Object?> get props => [instructorId, status];
}

/// Event to create new course
class InstructorCourseCreateRequested extends InstructorEvent {
  const InstructorCourseCreateRequested({
    required this.instructorId,
    required this.courseData,
  });

  final String instructorId;
  final Map<String, dynamic> courseData;

  @override
  List<Object> get props => [instructorId, courseData];
}

/// Event to update existing course
class InstructorCourseUpdateRequested extends InstructorEvent {
  const InstructorCourseUpdateRequested({
    required this.courseId,
    required this.updateData,
  });

  final String courseId;
  final Map<String, dynamic> updateData;

  @override
  List<Object> get props => [courseId, updateData];
}

/// Event to delete course
class InstructorCourseDeleteRequested extends InstructorEvent {
  const InstructorCourseDeleteRequested({required this.courseId});

  final String courseId;

  @override
  List<Object> get props => [courseId];
}

/// Event to submit course for approval
class InstructorCourseSubmitRequested extends InstructorEvent {
  const InstructorCourseSubmitRequested({required this.courseId});

  final String courseId;

  @override
  List<Object> get props => [courseId];
}

/// Event to load course analytics
class InstructorAnalyticsRequested extends InstructorEvent {
  const InstructorAnalyticsRequested({
    required this.instructorId,
    this.courseId,
    this.dateRange,
  });

  final String instructorId;
  final String? courseId;
  final DateRange? dateRange;

  @override
  List<Object?> get props => [instructorId, courseId, dateRange];
}

/// Event to load student enrollments
class InstructorStudentsRequested extends InstructorEvent {
  const InstructorStudentsRequested({
    required this.instructorId,
    this.courseId,
  });

  final String instructorId;
  final String? courseId;

  @override
  List<Object?> get props => [instructorId, courseId];
}

/// Event to load course reviews
class InstructorReviewsRequested extends InstructorEvent {
  const InstructorReviewsRequested({
    required this.instructorId,
    this.courseId,
  });

  final String instructorId;
  final String? courseId;

  @override
  List<Object?> get props => [instructorId, courseId];
}

/// Event to upload course content
class InstructorContentUploadRequested extends InstructorEvent {
  const InstructorContentUploadRequested({
    required this.courseId,
    required this.contentType,
    required this.filePath,
    this.metadata,
  });

  final String courseId;
  final String contentType; // video, document, image
  final String filePath;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [courseId, contentType, filePath, metadata];
}

/// Event to manage course lessons
class InstructorLessonManageRequested extends InstructorEvent {
  const InstructorLessonManageRequested({
    required this.courseId,
    required this.action,
    this.lessonId,
    this.lessonData,
  });

  final String courseId;
  final LessonAction action;
  final String? lessonId;
  final Map<String, dynamic>? lessonData;

  @override
  List<Object?> get props => [courseId, action, lessonId, lessonData];
}

/// Event to load earnings and payments
class InstructorEarningsRequested extends InstructorEvent {
  const InstructorEarningsRequested({
    required this.instructorId,
    this.period,
  });

  final String instructorId;
  final String? period; // monthly, yearly, all-time

  @override
  List<Object?> get props => [instructorId, period];
}

/// Event to update instructor profile
class InstructorProfileUpdateRequested extends InstructorEvent {
  const InstructorProfileUpdateRequested({
    required this.instructorId,
    required this.profileData,
  });

  final String instructorId;
  final Map<String, dynamic> profileData;

  @override
  List<Object> get props => [instructorId, profileData];
}

/// Event to load instructor notifications
class InstructorNotificationsRequested extends InstructorEvent {
  const InstructorNotificationsRequested({required this.instructorId});

  final String instructorId;

  @override
  List<Object> get props => [instructorId];
}

/// Event to respond to student message
class InstructorMessageResponseRequested extends InstructorEvent {
  const InstructorMessageResponseRequested({
    required this.messageId,
    required this.response,
  });

  final String messageId;
  final String response;

  @override
  List<Object> get props => [messageId, response];
}

/// Event to generate course report
class InstructorReportGenerateRequested extends InstructorEvent {
  const InstructorReportGenerateRequested({
    required this.instructorId,
    required this.reportType,
    this.courseId,
    this.dateRange,
  });

  final String instructorId;
  final String reportType; // sales, student-progress, engagement
  final String? courseId;
  final DateRange? dateRange;

  @override
  List<Object?> get props => [instructorId, reportType, courseId, dateRange];
}

/// Date range model
class DateRange extends Equatable {
  const DateRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  @override
  List<Object> get props => [start, end];
}

/// Lesson management actions
enum LessonAction {
  create,
  update,
  delete,
  reorder,
  publish,
  unpublish,
}