import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import '../utils/course_utils.dart';
import '../../config/supabase_config.dart';

class CourseService {
  // Fetch all courses filtered by category from Supabase or use mock data
  Future<List<Course>> getFilteredCourses(String category) async {
    try {
      // Check if we're in offline mode and return mock data
      if (isOfflineMode) {
        return _getMockCourses(category);
      }

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
    } catch (e) {
      // Fallback to mock data on any error
      return _getMockCourses(category);
    }
  }

  // Mock data for demo purposes
  List<Course> _getMockCourses(String category) {
    final allCourses = [
      Course(
        id: '1',
        title: 'International Commercial Arbitration Fundamentals',
        instructor: 'Dr. Sarah Mitchell',
        rating: 4.8,
        reviewCount: 156,
        duration: '8 hours',
        studentCount: 1200,
        price: 299.0,
        originalPrice: 399.0,
        category: 'arbitration',
        level: 'Beginner',
        image: 'assets/images/arbitration-london.jpg',
        isPopular: true,
        isBestseller: false,
      ),
      Course(
        id: '2',
        title: 'Advanced Mediation Techniques',
        instructor: 'Prof. James Chen',
        rating: 4.9,
        reviewCount: 89,
        duration: '12 hours',
        studentCount: 845,
        price: 349.0,
        category: 'mediation',
        level: 'Advanced',
        image: 'assets/images/advanced-mediation.jpg',
        isPopular: false,
        isBestseller: true,
      ),
      Course(
        id: '3',
        title: 'DIAC Arbitration Rules: A Comprehensive Guide',
        instructor: 'Maria Rodriguez',
        rating: 4.7,
        reviewCount: 234,
        duration: '6 hours',
        studentCount: 987,
        price: 199.0,
        originalPrice: 249.0,
        category: 'arbitration',
        level: 'Intermediate',
        image: 'assets/images/diac-rules.jpg',
        isPopular: true,
        isBestseller: false,
      ),
      Course(
        id: '4',
        title: 'Commercial Law Essentials for Dispute Resolution',
        instructor: 'Robert Wilson',
        rating: 4.6,
        reviewCount: 178,
        duration: '10 hours',
        studentCount: 1456,
        price: 279.0,
        category: 'commercial-law',
        level: 'Beginner',
        image: 'assets/images/commercial-law.jpg',
        isPopular: false,
        isBestseller: false,
      ),
      Course(
        id: '5',
        title: 'Investment Treaty Arbitration',
        instructor: 'Dr. Elena Vasquez',
        rating: 4.9,
        reviewCount: 67,
        duration: '15 hours',
        studentCount: 432,
        price: 449.0,
        originalPrice: 599.0,
        category: 'arbitration',
        level: 'Advanced',
        image: 'assets/images/investment-arbitration.jpg',
        isPopular: false,
        isBestseller: true,
      ),
      Course(
        id: '6',
        title: 'Construction Dispute Resolution',
        instructor: 'Michael Thompson',
        rating: 4.5,
        reviewCount: 123,
        duration: '9 hours',
        studentCount: 678,
        price: 329.0,
        category: 'corporate-disputes',
        level: 'Intermediate',
        image: 'assets/images/construction-dispute.jpg',
        isPopular: true,
        isBestseller: false,
      ),
      Course(
        id: '7',
        title: 'Compliance and Risk Management',
        instructor: 'Lisa Park',
        rating: 4.7,
        reviewCount: 198,
        duration: '7 hours',
        studentCount: 1034,
        price: 249.0,
        category: 'compliance',
        level: 'Beginner',
        image: 'assets/images/compliance-risk.jpg',
        isPopular: false,
        isBestseller: false,
      ),
      Course(
        id: '8',
        title: 'Ethics in International Arbitration',
        instructor: 'Prof. David Kumar',
        rating: 4.8,
        reviewCount: 145,
        duration: '5 hours',
        studentCount: 756,
        price: 179.0,
        originalPrice: 229.0,
        category: 'arbitration',
        level: 'Intermediate',
        image: 'assets/images/ethics-arbitration.jpg',
        isPopular: true,
        isBestseller: true,
      ),
    ];

    if (category == 'all') return allCourses;
    return allCourses.where((course) => course.category == category).toList();
  }

  // Enroll a user in a course
  Future<void> enrollCourse(String courseId) async {
    try {
      if (isOfflineMode) {
        // In offline mode, just simulate enrollment
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        return; // Success in demo mode
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      await Supabase.instance.client.from('enrollments').insert({
        'user_id': user.id,
        'course_id': courseId,
      });
    } catch (e) {
      // In demo mode, enrollment always succeeds
      if (isOfflineMode) return;
      rethrow;
    }
  }

  // Fetch enrolled courses for the current user
  Future<List<Course>> getEnrolledCourses() async {
    try {
      if (isOfflineMode) {
        // In offline mode, return a sample of enrolled courses
        final mockCourses = _getMockCourses('all');
        return mockCourses.take(3).toList(); // Return first 3 as "enrolled"
      }

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
    } catch (e) {
      // Fallback to mock enrolled courses
      final mockCourses = _getMockCourses('all');
      return mockCourses.take(2).toList();
    }
  }
}