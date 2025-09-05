import 'package:equatable/equatable.dart';

/// Course events for the CourseBloc
sealed class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all courses
class CourseLoadRequested extends CourseEvent {}

/// Event to load courses by category
class CourseLoadByCategoryRequested extends CourseEvent {
  const CourseLoadByCategoryRequested({required this.category});

  final String category;

  @override
  List<Object> get props => [category];
}

/// Event to search courses
class CourseSearchRequested extends CourseEvent {
  const CourseSearchRequested({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

/// Event to filter courses
class CourseFilterRequested extends CourseEvent {
  const CourseFilterRequested({
    this.category,
    this.level,
    this.priceRange,
    this.duration,
    this.language,
    this.sortBy,
  });

  final String? category;
  final String? level;
  final Map<String, double>? priceRange;
  final String? duration;
  final String? language;
  final String? sortBy;

  @override
  List<Object?> get props => [category, level, priceRange, duration, language, sortBy];
}

/// Event to load course details
class CourseDetailRequested extends CourseEvent {
  const CourseDetailRequested({required this.courseId});

  final String courseId;

  @override
  List<Object> get props => [courseId];
}

/// Event to enroll in a course
class CourseEnrollmentRequested extends CourseEvent {
  const CourseEnrollmentRequested({
    required this.courseId,
    required this.userId,
  });

  final String courseId;
  final String userId;

  @override
  List<Object> get props => [courseId, userId];
}

/// Event to load user's enrolled courses
class EnrolledCoursesRequested extends CourseEvent {
  const EnrolledCoursesRequested({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to load featured courses
class FeaturedCoursesRequested extends CourseEvent {}

/// Event to load popular courses
class PopularCoursesRequested extends CourseEvent {}

/// Event to refresh course data
class CourseRefreshRequested extends CourseEvent {}

/// Event to clear search results
class CourseSearchCleared extends CourseEvent {}

/// Event to add course to favorites
class CourseFavoriteToggled extends CourseEvent {
  const CourseFavoriteToggled({
    required this.courseId,
    required this.userId,
  });

  final String courseId;
  final String userId;

  @override
  List<Object> get props => [courseId, userId];
}