import 'package:equatable/equatable.dart';
import '../../models/course.dart';

/// Course states for the CourseBloc
sealed class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class CourseInitial extends CourseState {}

/// State when courses are being loaded
class CourseLoading extends CourseState {}

/// State when courses are successfully loaded
class CourseLoaded extends CourseState {
  const CourseLoaded({
    required this.courses,
    this.hasMore = false,
    this.page = 1,
  });

  final List<Course> courses;
  final bool hasMore;
  final int page;

  @override
  List<Object> get props => [courses, hasMore, page];
}

/// State when course search results are loaded
class CourseSearchResults extends CourseState {
  const CourseSearchResults({
    required this.courses,
    required this.query,
    this.hasMore = false,
  });

  final List<Course> courses;
  final String query;
  final bool hasMore;

  @override
  List<Object> get props => [courses, query, hasMore];
}

/// State when courses are filtered
class CourseFiltered extends CourseState {
  const CourseFiltered({
    required this.courses,
    required this.filters,
    this.hasMore = false,
  });

  final List<Course> courses;
  final Map<String, dynamic> filters;
  final bool hasMore;

  @override
  List<Object> get props => [courses, filters, hasMore];
}

/// State when a specific course detail is loaded
class CourseDetailLoaded extends CourseState {
  const CourseDetailLoaded({
    required this.course,
    required this.isEnrolled,
    required this.isFavorite,
    this.enrollmentCount = 0,
    this.averageRating = 0.0,
    this.reviews = const [],
  });

  final Course course;
  final bool isEnrolled;
  final bool isFavorite;
  final int enrollmentCount;
  final double averageRating;
  final List<Map<String, dynamic>> reviews;

  @override
  List<Object> get props => [
    course, isEnrolled, isFavorite, enrollmentCount, averageRating, reviews
  ];
}

/// State when enrolled courses are loaded
class EnrolledCoursesLoaded extends CourseState {
  const EnrolledCoursesLoaded({
    required this.courses,
    required this.progressData,
  });

  final List<Course> courses;
  final Map<String, double> progressData; // courseId -> progress percentage

  @override
  List<Object> get props => [courses, progressData];
}

/// State when featured courses are loaded
class FeaturedCoursesLoaded extends CourseState {
  const FeaturedCoursesLoaded({required this.courses});

  final List<Course> courses;

  @override
  List<Object> get props => [courses];
}

/// State when popular courses are loaded
class PopularCoursesLoaded extends CourseState {
  const PopularCoursesLoaded({required this.courses});

  final List<Course> courses;

  @override
  List<Object> get props => [courses];
}

/// State when course enrollment is successful
class CourseEnrollmentSuccess extends CourseState {
  const CourseEnrollmentSuccess({
    required this.courseId,
    required this.message,
  });

  final String courseId;
  final String message;

  @override
  List<Object> get props => [courseId, message];
}

/// State when course operation fails
class CourseError extends CourseState {
  const CourseError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// State when refreshing course data
class CourseRefreshing extends CourseState {
  const CourseRefreshing({required this.currentCourses});

  final List<Course> currentCourses;

  @override
  List<Object> get props => [currentCourses];
}