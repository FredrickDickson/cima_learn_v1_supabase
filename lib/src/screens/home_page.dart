import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/enhanced_course_service.dart';
import '../services/localization_service.dart';
import '../utils/responsive.dart';
import '../widgets/header.dart';
import '../widgets/hero_section.dart';
import '../widgets/course_categories.dart';
import '../widgets/course_card.dart';
import '../widgets/footer.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/course_filters_widget.dart';
import '../models/course.dart';
import '../../config/supabase_config.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String activeCategory = 'all';
  bool showMore = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final EnhancedCourseService _courseService = EnhancedCourseService();
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];

  bool get isMobile => Responsive.isMobile(context);
  bool get isOfflineMode => false; // Set to false for now, can be configured later

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _loadCourses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Fluttertoast.showToast(
        msg: 'Welcome to CIMA Learn Hub!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFB71C1C), // CIMA red color
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  Future<void> _loadCourses() async {
    final courses = await _courseService.searchCourses();
    setState(() {
      _allCourses = courses;
      _filteredCourses = courses;
    });
  }

  void _handleSearchChange(String query) {
    setState(() {
      _searchQuery = query;
    });
    _performSearch();
  }

  void _handleFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
    });
    _performSearch();
  }

  Future<void> _performSearch() async {
    final courses = await _courseService.searchCourses(
      query: _searchQuery.isEmpty ? null : _searchQuery,
      category: activeCategory == 'all' ? null : activeCategory,
    );
    
    List<Course> filteredCourses = courses;
    
    // Apply custom filters
    if (_activeFilters.isNotEmpty) {
      filteredCourses = _applyFilters(filteredCourses);
    }
    
    setState(() {
      _filteredCourses = filteredCourses;
    });
  }

  List<Course> _applyFilters(List<Course> courses) {
    List<Course> filtered = List.from(courses);
    
    // Price filters
    if (_activeFilters.containsKey('price_free')) {
      filtered = filtered.where((course) => course.price == 0).toList();
    } else if (_activeFilters.containsKey('price_under_50k')) {
      filtered = filtered.where((course) => course.price < 50000).toList();
    } else if (_activeFilters.containsKey('price_50k_200k')) {
      filtered = filtered.where((course) => course.price >= 50000 && course.price <= 200000).toList();
    } else if (_activeFilters.containsKey('price_over_200k')) {
      filtered = filtered.where((course) => course.price > 200000).toList();
    }
    
    // Quality filters
    if (_activeFilters.containsKey('quality_top_rated')) {
      filtered = filtered.where((course) => course.rating >= 4.5).toList();
    } else if (_activeFilters.containsKey('quality_popular')) {
      filtered = filtered.where((course) => course.isPopular).toList();
    }
    
    // Language filters (assuming courses have a language property)
    if (_activeFilters.containsKey('lang_en')) {
      // Filter for English courses
    } else if (_activeFilters.containsKey('lang_fr')) {
      // Filter for French courses  
    } else if (_activeFilters.containsKey('lang_ar')) {
      // Filter for Arabic courses
    } else if (_activeFilters.containsKey('lang_es')) {
      // Filter for Spanish courses
    }
    
    return filtered;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF2E2E2E),
                    ),
                    child: Text(
                      'CIMA Learn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Log In'),
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Sign Up'),
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text('My Enrolled Courses'),
                    onTap: () {
                      Navigator.pushNamed(context, '/enrolled-courses');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text('Cart'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Builder(
        builder: (context) {
          final displayedCourses = showMore ? _filteredCourses : _filteredCourses.take(6).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Header(isMobile: isMobile),
              if (isOfflineMode)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo Mode: Showing sample courses. Connect to database for live data.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const HeroSection(),
              ),
              const SizedBox(height: 24),
              // Main Search Bar - Single Point of Search
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: SearchBarWidget(
                  onSearchChanged: _handleSearchChange,
                  initialQuery: _searchQuery,
                ),
              ),
              // Course Filters
              CourseFiltersWidget(
                onFiltersChanged: _handleFiltersChanged,
                initialFilters: _activeFilters,
              ),
              const SizedBox(height: 24),
              CourseCategories(
                activeCategory: activeCategory,
                onCategoryChange: (category) {
                  setState(() {
                    activeCategory = category;
                    showMore = false;
                    _controller.reset();
                    _controller.forward();
                  });
                  _performSearch();
                },
                isMobile: isMobile,
              ),
              const SizedBox(height: 24),
              Text(
                activeCategory == 'all'
                    ? 'Featured Courses'
                    : '${activeCategory[0].toUpperCase()}${activeCategory.substring(1)} Courses',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Learn from internationally recognized experts and build your expertise in dispute resolution.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: displayedCourses.length,
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: CourseCard(course: displayedCourses[index]),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_filteredCourses.length > 6)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showMore = !showMore;
                        _controller.reset();
                        _controller.forward();
                      });
                    },
                    child: Text(showMore ? 'Show Less' : 'View All ${_filteredCourses.length} Courses'),
                  ),
                ),
              const SizedBox(height: 24),
              const Footer(),
            ],
          );
        },
      ),
    );
  }
}