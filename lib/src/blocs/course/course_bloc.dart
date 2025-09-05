import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../../models/course.dart';
import 'course_event.dart';
import 'course_state.dart';

/// Course BLoC managing course data, search, filtering, and enrollment
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc() : super(CourseInitial()) {
    // Register event handlers
    on<CourseLoadRequested>(_onCourseLoadRequested);
    on<CourseLoadByCategoryRequested>(_onCourseLoadByCategoryRequested);
    on<CourseSearchRequested>(_onCourseSearchRequested);
    on<CourseFilterRequested>(_onCourseFilterRequested);
    on<CourseDetailRequested>(_onCourseDetailRequested);
    on<CourseEnrollmentRequested>(_onCourseEnrollmentRequested);
    on<EnrolledCoursesRequested>(_onEnrolledCoursesRequested);
    on<FeaturedCoursesRequested>(_onFeaturedCoursesRequested);
    on<PopularCoursesRequested>(_onPopularCoursesRequested);
    on<CourseRefreshRequested>(_onCourseRefreshRequested);
    on<CourseSearchCleared>(_onCourseSearchCleared);
    on<CourseFavoriteToggled>(_onCourseFavoriteToggled);
  }

  /// Load all courses with pagination
  Future<void> _onCourseLoadRequested(
    CourseLoadRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());

    try {
      final response = await supabase
          .from('courses')
          .select('*')
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .limit(20);

      final courses = response.map((data) => Course.fromJson(data)).toList();
      
      emit(CourseLoaded(
        courses: courses,
        hasMore: courses.length == 20,
      ));
    } catch (e) {
      emit(CourseError(message: 'Failed to load courses: $e'));
    }
  }

  /// Load courses by category
  Future<void> _onCourseLoadByCategoryRequested(
    CourseLoadByCategoryRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());

    try {
      final response = await supabase
          .from('courses')
          .select('*')
          .eq('category', event.category)
          .eq('status', 'published')
          .order('created_at', ascending: false);

      final courses = response.map((data) => Course.fromJson(data)).toList();
      
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      emit(CourseError(message: 'Failed to load courses for category: $e'));
    }
  }

  /// Search courses by title, description, or instructor
  Future<void> _onCourseSearchRequested(
    CourseSearchRequested event,
    Emitter<CourseState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(CourseSearchCleared());
      return;
    }

    emit(CourseLoading());

    try {
      final response = await supabase
          .from('courses')
          .select('*')
          .eq('status', 'published')
          .or('title.ilike.%${event.query}%,description.ilike.%${event.query}%')
          .order('created_at', ascending: false);

      final courses = response.map((data) => Course.fromJson(data)).toList();
      
      emit(CourseSearchResults(
        courses: courses,
        query: event.query,
      ));
    } catch (e) {
      emit(CourseError(message: 'Search failed: $e'));
    }
  }

  /// Filter courses based on multiple criteria
  Future<void> _onCourseFilterRequested(
    CourseFilterRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());

    try {
      var query = supabase.from('courses').select('*').eq('status', 'published');

      // Apply filters
      if (event.category != null && event.category!.isNotEmpty) {
        query = query.eq('category', event.category!);
      }

      if (event.level != null && event.level!.isNotEmpty) {
        query = query.eq('difficulty_level', event.level!);
      }

      if (event.priceRange != null) {
        final minPrice = event.priceRange!['min'] ?? 0.0;
        final maxPrice = event.priceRange!['max'] ?? 999999.0;
        query = query.gte('price', minPrice).lte('price', maxPrice);
      }

      if (event.language != null && event.language!.isNotEmpty) {
        query = query.eq('language', event.language!);
      }

      // Apply sorting
      switch (event.sortBy) {
        case 'price_low':
          query = query.order('price', ascending: true);
          break;
        case 'price_high':
          query = query.order('price', ascending: false);
          break;
        case 'newest':
          query = query.order('created_at', ascending: false);
          break;
        case 'popular':
          query = query.order('enrollment_count', ascending: false);
          break;
        default:
          query = query.order('created_at', ascending: false);
      }

      final response = await query;
      final courses = response.map((data) => Course.fromJson(data)).toList();

      emit(CourseFiltered(
        courses: courses,
        filters: {
          'category': event.category,
          'level': event.level,
          'priceRange': event.priceRange,
          'language': event.language,
          'sortBy': event.sortBy,
        },
      ));
    } catch (e) {
      emit(CourseError(message: 'Failed to filter courses: $e'));
    }
  }

  /// Load detailed information for a specific course
  Future<void> _onCourseDetailRequested(
    CourseDetailRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());

    try {
      // Load course details
      final courseResponse = await supabase
          .from('courses')
          .select('*')
          .eq('id', event.courseId)
          .single();

      final course = Course.fromJson(courseResponse);

      // Check enrollment status (requires user ID - could be passed as parameter)
      // For now, defaulting to false
      const isEnrolled = false;
      const isFavorite = false;

      // Load enrollment count
      final enrollmentResponse = await supabase
          .from('enrollments')
          .select('id')
          .eq('course_id', event.courseId)
          .eq('status', 'active');

      final enrollmentCount = enrollmentResponse.length;

      // Load average rating
      final ratingResponse = await supabase
          .from('course_reviews')
          .select('rating')
          .eq('course_id', event.courseId);

      double averageRating = 0.0;
      if (ratingResponse.isNotEmpty) {
        final ratings = ratingResponse.map((r) => r['rating'] as num).toList();
        averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      }

      emit(CourseDetailLoaded(
        course: course,
        isEnrolled: isEnrolled,
        isFavorite: isFavorite,
        enrollmentCount: enrollmentCount,
        averageRating: averageRating,
      ));
    } catch (e) {
      emit(CourseError(message: 'Failed to load course details: $e'));
    }
  }

  /// Handle course enrollment
  Future<void> _onCourseEnrollmentRequested(
    CourseEnrollmentRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Check if already enrolled
      final existingEnrollment = await supabase
          .from('enrollments')
          .select('id')
          .eq('user_id', event.userId)
          .eq('course_id', event.courseId)
          .maybeSingle();

      if (existingEnrollment != null) {
        emit(CourseError(message: 'Already enrolled in this course'));
        return;
      }

      // Create enrollment
      await supabase.from('enrollments').insert({
        'user_id': event.userId,
        'course_id': event.courseId,
        'enrolled_at': DateTime.now().toIso8601String(),
        'status': 'active',
        'progress': 0.0,
      });

      // Update course enrollment count
      await supabase.rpc('increment_enrollment_count', params: {
        'course_id': event.courseId,
      });

      emit(CourseEnrollmentSuccess(
        courseId: event.courseId,
        message: 'Successfully enrolled in course!',
      ));
    } catch (e) {
      emit(CourseError(message: 'Enrollment failed: $e'));
    }
  }

  /// Load user's enrolled courses
  Future<void> _onEnrolledCoursesRequested(
    EnrolledCoursesRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());

    try {
      final response = await supabase
          .from('enrollments')
          .select('*, courses(*)')
          .eq('user_id', event.userId)
          .eq('status', 'active')
          .order('enrolled_at', ascending: false);

      final courses = <Course>[];
      final progressData = <String, double>{};

      for (final enrollment in response) {
        final courseData = enrollment['courses'];
        if (courseData != null) {
          final course = Course.fromJson(courseData);
          courses.add(course);
          progressData[course.id] = (enrollment['progress'] as num?)?.toDouble() ?? 0.0;
        }
      }

      emit(EnrolledCoursesLoaded(
        courses: courses,
        progressData: progressData,
      ));
    } catch (e) {
      emit(CourseError(message: 'Failed to load enrolled courses: $e'));
    }
  }

  /// Load featured courses
  Future<void> _onFeaturedCoursesRequested(
    FeaturedCoursesRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      final response = await supabase
          .from('courses')
          .select('*')
          .eq('is_featured', true)
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .limit(6);

      final courses = response.map((data) => Course.fromJson(data)).toList();
      
      emit(FeaturedCoursesLoaded(courses: courses));
    } catch (e) {
      emit(CourseError(message: 'Failed to load featured courses: $e'));
    }
  }

  /// Load popular courses
  Future<void> _onPopularCoursesRequested(
    PopularCoursesRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      final response = await supabase
          .from('courses')
          .select('*')
          .eq('status', 'published')
          .order('enrollment_count', ascending: false)
          .limit(10);

      final courses = response.map((data) => Course.fromJson(data)).toList();
      
      emit(PopularCoursesLoaded(courses: courses));
    } catch (e) {
      emit(CourseError(message: 'Failed to load popular courses: $e'));
    }
  }

  /// Refresh course data
  Future<void> _onCourseRefreshRequested(
    CourseRefreshRequested event,
    Emitter<CourseState> emit,
  ) async {
    // Keep current courses visible while refreshing
    List<Course> currentCourses = [];
    if (state is CourseLoaded) {
      currentCourses = (state as CourseLoaded).courses;
    }

    emit(CourseRefreshing(currentCourses: currentCourses));

    // Reload courses
    add(CourseLoadRequested());
  }

  /// Clear search results
  Future<void> _onCourseSearchCleared(
    CourseSearchCleared event,
    Emitter<CourseState> emit,
  ) async {
    // Return to initial course list
    add(CourseLoadRequested());
  }

  /// Toggle course favorite status
  Future<void> _onCourseFavoriteToggled(
    CourseFavoriteToggled event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Check if course is already favorited
      final existing = await supabase
          .from('user_favorites')
          .select('id')
          .eq('user_id', event.userId)
          .eq('course_id', event.courseId)
          .maybeSingle();

      if (existing != null) {
        // Remove from favorites
        await supabase
            .from('user_favorites')
            .delete()
            .eq('user_id', event.userId)
            .eq('course_id', event.courseId);
      } else {
        // Add to favorites
        await supabase.from('user_favorites').insert({
          'user_id': event.userId,
          'course_id': event.courseId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Reload course detail if currently viewing this course
      if (state is CourseDetailLoaded) {
        final currentState = state as CourseDetailLoaded;
        if (currentState.course.id == event.courseId) {
          add(CourseDetailRequested(courseId: event.courseId));
        }
      }
    } catch (e) {
      emit(CourseError(message: 'Failed to update favorites: $e'));
    }
  }
}