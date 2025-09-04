import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import '../utils/course_utils.dart';

class CourseService {
  // Fetch all courses filtered by category from Supabase
  Future<List<Course>> getFilteredCourses(String category) async {
    final response = await Supabase.instance.client
        .from('courses')
        .select()
        .order('title', ascending: true);

    final List<Course> courses = (response as List).map((data) {
      return Course(
        id: data['id'] as String,
        title: data['title'] as String,
        category: data['category'] as String,
        level: data['level'] as String? ?? 'Beginner',
        instructor: data['instructor'] as String,
        rating: (data['rating'] as num).toDouble(),
        reviewCount: data['review_count'] as int,
        studentCount: data['student_count'] as int,
        duration: data['duration'] as String,
        price: (data['price'] as num).toDouble(),
        originalPrice: data['original_price'] != null ? (data['original_price'] as num).toDouble() : null,
        isBestseller: data['is_bestseller'] as bool,
        isPopular: data['is_popular'] as bool,
        image: data['image'] as String,
      );
    }).toList();

    if (category == 'all') return courses;
    return courses.where((course) => course.category == category).toList();
  }

  // Enroll a user in a course
  Future<void> enrollCourse(String courseId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await Supabase.instance.client.from('enrollments').insert({
      'user_id': user.id,
      'course_id': courseId,
    });
  }

  // Fetch enrolled courses for the current user
  Future<List<Course>> getEnrolledCourses() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return [];
    }

    final response = await Supabase.instance.client
        .from('enrollments')
        .select('course_id')
        .eq('user_id', user.id);

    final enrolledCourseIds = response.map((e) => e['course_id'] as String).toList();
    final allCourses = await getFilteredCourses('all');
    return allCourses.where((course) => enrolledCourseIds.contains(course.id)).toList();
  }
}