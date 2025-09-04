import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/enhanced_course_service.dart';
import '../screens/course_detail_page.dart';

class CourseSearchDelegate extends SearchDelegate<Course?> {
  final EnhancedCourseService _courseService = EnhancedCourseService();

  @override
  String get searchFieldLabel => 'Search courses...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildPopularCourses();
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Course>>(
      future: _courseService.searchCourses(query: query.isEmpty ? null : query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final courses = snapshot.data ?? [];

        if (courses.isEmpty) {
          return const Center(
            child: Text('No courses found'),
          );
        }

        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.school, color: Color(0xFFB71C1C)),
              ),
              title: Text(
                course.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.instructor),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text('${course.rating}'),
                      const SizedBox(width: 16),
                      Text(course.formattedPrice),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                close(context, course);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailPage(course: course),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPopularCourses() {
    return FutureBuilder<List<Course>>(
      future: _courseService.getPopularCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Popular Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: const Icon(Icons.school, color: Color(0xFFB71C1C)),
                    ),
                    title: Text(
                      course.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.instructor),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber[700]),
                            const SizedBox(width: 4),
                            Text('${course.rating}'),
                            const SizedBox(width: 16),
                            Text(course.formattedPrice),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      query = course.title;
                      showResults(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}