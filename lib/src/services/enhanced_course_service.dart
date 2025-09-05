import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import '../../config/supabase_config.dart';

class EnhancedCourseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Search courses with query and filters
  Future<List<Course>> searchCourses({
    String? query,
    String? category,
    String? level,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      print('Searching courses with query: $query, category: $category');
      
      var queryBuilder = _supabase.from('courses').select();

      // Apply filters with better validation
      if (category != null && category.isNotEmpty && category != 'All Categories' && category != 'all') {
        final normalizedCategory = category.toLowerCase().replaceAll(' ', '-');
        queryBuilder = queryBuilder.eq('category', normalizedCategory);
      }

      if (level != null && level.isNotEmpty && level != 'All Levels') {
        queryBuilder = queryBuilder.eq('level', level);
      }

      if (minPrice != null && minPrice > 0) {
        queryBuilder = queryBuilder.gte('price', minPrice);
      }

      if (maxPrice != null && maxPrice > 0) {
        queryBuilder = queryBuilder.lte('price', maxPrice);
      }

      // Improved search with better text matching
      if (query != null && query.trim().isNotEmpty) {
        final searchTerm = query.trim();
        queryBuilder = queryBuilder.or('title.ilike.%$searchTerm%,description.ilike.%$searchTerm%,instructor.ilike.%$searchTerm%');
      }

      // Add ordering for consistent results
      final orderedQuery = queryBuilder.order('created_at', ascending: false);

      final response = await orderedQuery.timeout(const Duration(seconds: 10));

      if (response.isEmpty) {
        print('No courses found in database, using mock data');
        return _searchMockCourses(query: query, category: category);
      }

      return response.map((json) {
        try {
          return Course.fromJson(json);
        } catch (e) {
          print('Error parsing course JSON: $e');
          return null;
        }
      }).where((course) => course != null).cast<Course>().toList();
    } catch (e) {
      print('Error searching courses: $e');
      return _searchMockCourses(query: query, category: category);
    }
  }

  // Get course by ID
  Future<Course?> getCourseById(String courseId) async {
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .eq('id', courseId)
          .single();

      return Course.fromJson(response);
    } catch (e) {
      print('Error fetching course by ID: $e');
      // Try to find in mock data
      final mockCourses = _getAllMockCourses();
      try {
        return mockCourses.firstWhere((course) => course.id == courseId);
      } catch (e) {
        return mockCourses.isNotEmpty ? mockCourses.first : null;
      }
    }
  }

  // Get popular courses
  Future<List<Course>> getPopularCourses() async {
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .eq('is_popular', true)
          .limit(6);

      if (response.isEmpty) {
        return _getAllMockCourses().where((c) => c.isPopular).take(6).toList();
      }

      return response.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching popular courses: $e');
      return _getAllMockCourses().where((c) => c.isPopular).take(6).toList();
    }
  }

  // Get course categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('courses')
          .select('category')
          .order('category');

      final categories = response
          .map((item) => item['category'] as String)
          .toSet()
          .toList();

      return ['All Categories', ...categories];
    } catch (e) {
      print('Error fetching categories: $e');
      return [
        'All Categories',
        'Commercial Law',
        'Arbitration',
        'Mediation',
        'Compliance'
      ];
    }
  }

  // Search mock courses (fallback)
  List<Course> _searchMockCourses({String? query, String? category}) {
    var courses = _getAllMockCourses();

    if (category != null && category != 'All Categories') {
      final categoryFilter = category.toLowerCase().replaceAll(' ', '-');
      courses = courses.where((c) => c.category == categoryFilter).toList();
    }

    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      courses = courses.where((c) =>
          c.title.toLowerCase().contains(lowerQuery) ||
          c.description.toLowerCase().contains(lowerQuery) ||
          c.instructor.toLowerCase().contains(lowerQuery)
      ).toList();
    }

    return courses;
  }

  // All mock courses with enhanced data
  List<Course> _getAllMockCourses() {
    return [
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
        description: 'Learn the fundamentals of international commercial arbitration with real-world case studies and practical exercises.',
        skills: ['Contract Law', 'Dispute Resolution', 'Legal Analysis'],
        videoUrl: 'https://example.com/course1-video',
        modules: ['Introduction to Arbitration', 'Arbitration Process', 'Awards and Enforcement'],
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
        description: 'Master advanced mediation techniques used by top professionals in complex commercial disputes.',
        skills: ['Mediation', 'Negotiation', 'Conflict Resolution'],
        videoUrl: 'https://example.com/course2-video',
        modules: ['Advanced Mediation Theory', 'Complex Case Management', 'Cross-Cultural Mediation'],
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
        description: 'Comprehensive guide to Dubai International Arbitration Centre rules and procedures.',
        skills: ['DIAC Rules', 'Arbitration Procedure', 'Legal Practice'],
        videoUrl: 'https://example.com/course3-video',
        modules: ['DIAC Overview', 'Procedural Rules', 'Practical Applications'],
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
        description: 'Essential commercial law principles for effective dispute resolution in business contexts.',
        skills: ['Commercial Law', 'Contract Analysis', 'Business Law'],
        videoUrl: 'https://example.com/course4-video',
        modules: ['Contract Basics', 'Commercial Disputes', 'Resolution Strategies'],
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
        description: 'Specialized course on investment treaty arbitration for international legal professionals.',
        skills: ['Investment Law', 'Treaty Analysis', 'International Arbitration'],
        videoUrl: 'https://example.com/course5-video',
        modules: ['Investment Treaties', 'Arbitration Process', 'Case Studies'],
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
        category: 'arbitration',
        level: 'Intermediate',
        image: 'assets/images/construction-dispute.jpg',
        isPopular: true,
        isBestseller: false,
        description: 'Specialized training in construction industry dispute resolution methods and best practices.',
        skills: ['Construction Law', 'Project Management', 'Dispute Resolution'],
        videoUrl: 'https://example.com/course6-video',
        modules: ['Construction Contracts', 'Dispute Types', 'Resolution Methods'],
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
        description: 'Comprehensive compliance and risk management strategies for modern organizations.',
        skills: ['Risk Assessment', 'Compliance Management', 'Regulatory Knowledge'],
        videoUrl: 'https://example.com/course7-video',
        modules: ['Risk Identification', 'Compliance Frameworks', 'Monitoring Systems'],
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
        description: 'Essential ethical principles and professional conduct in international arbitration practice.',
        skills: ['Professional Ethics', 'Legal Standards', 'Best Practices'],
        videoUrl: 'https://example.com/course8-video',
        modules: ['Ethical Foundations', 'Professional Standards', 'Case Examples'],
      ),
    ];
  }
}