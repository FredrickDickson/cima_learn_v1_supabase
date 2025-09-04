import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/instructor_service.dart';

class InstructorCoursesPage extends StatefulWidget {
  final InstructorService instructorService;

  const InstructorCoursesPage({Key? key, required this.instructorService}) : super(key: key);

  @override
  State<InstructorCoursesPage> createState() => _InstructorCoursesPageState();
}

class _InstructorCoursesPageState extends State<InstructorCoursesPage> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.instructorService,
      child: Consumer<InstructorService>(
        builder: (context, service, child) {
          final filteredCourses = _getFilteredCourses(service);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Courses',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage and track your published courses.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to course creation
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Course'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildFilterTabs(),
                const SizedBox(height: 24),
                if (service.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (filteredCourses.isEmpty)
                  _buildEmptyState()
                else
                  _buildCoursesList(filteredCourses),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'all', 'label': 'All Courses', 'count': widget.instructorService.myCourses.length},
      {'key': 'published', 'label': 'Published', 'count': widget.instructorService.myCourses.where((c) => c.status == 'published').length},
      {'key': 'draft', 'label': 'Draft', 'count': widget.instructorService.myCourses.where((c) => c.status == 'draft').length},
      {'key': 'pending', 'label': 'Pending Review', 'count': widget.instructorService.myCourses.where((c) => c.status == 'pending_approval').length},
    ];

    return Row(
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter['key'];
        return Container(
          margin: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedFilter = filter['key'] as String;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFB71C1C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${filter['count']}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_selectedFilter == 'all' || _selectedFilter == 'draft')
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to course creation
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Your First Course'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(List courses) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(dynamic course) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course image placeholder
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 48,
                    color: Colors.grey[500],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(course.status ?? 'draft'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (course.status ?? 'draft').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₦${course.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFB71C1C),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${course.enrollmentCount} students',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleCourseAction(value, course),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit Course'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 18),
                                SizedBox(width: 8),
                                Text('Duplicate'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'analytics',
                            child: Row(
                              children: [
                                Icon(Icons.analytics, size: 18),
                                SizedBox(width: 8),
                                Text('View Analytics'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'students',
                            child: Row(
                              children: [
                                Icon(Icons.people, size: 18),
                                SizedBox(width: 8),
                                Text('View Students'),
                              ],
                            ),
                          ),
                          if ((course.status ?? 'draft') == 'draft')
                            const PopupMenuItem(
                              value: 'publish',
                              child: Row(
                                children: [
                                  Icon(Icons.publish, size: 18),
                                  SizedBox(width: 8),
                                  Text('Publish'),
                                ],
                              ),
                            ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${course.duration}h',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List _getFilteredCourses(InstructorService service) {
    switch (_selectedFilter) {
      case 'published':
        return service.myCourses.where((c) => c.status == 'published').toList();
      case 'draft':
        return service.myCourses.where((c) => c.status == 'draft').toList();
      case 'pending':
        return service.myCourses.where((c) => c.status == 'pending_approval').toList();
      default:
        return service.myCourses;
    }
  }

  String _getEmptyStateTitle() {
    switch (_selectedFilter) {
      case 'published':
        return 'No Published Courses';
      case 'draft':
        return 'No Draft Courses';
      case 'pending':
        return 'No Pending Courses';
      default:
        return 'No Courses Yet';
    }
  }

  String _getEmptyStateSubtitle() {
    switch (_selectedFilter) {
      case 'published':
        return 'You haven\'t published any courses yet. Publish a draft course to get started.';
      case 'draft':
        return 'You don\'t have any draft courses. Create a new course to start building.';
      case 'pending':
        return 'No courses are currently pending review.';
      default:
        return 'Start sharing your knowledge by creating your first course.';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'pending_approval':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleCourseAction(String action, dynamic course) {
    switch (action) {
      case 'edit':
        _editCourse(course);
        break;
      case 'duplicate':
        _duplicateCourse(course);
        break;
      case 'analytics':
        _viewAnalytics(course);
        break;
      case 'students':
        _viewStudents(course);
        break;
      case 'publish':
        _publishCourse(course);
        break;
      case 'delete':
        _deleteCourse(course);
        break;
    }
  }

  void _editCourse(dynamic course) {
    // Navigate to course edit page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course editing coming soon!')),
    );
  }

  void _duplicateCourse(dynamic course) {
    // Duplicate course logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course duplication coming soon!')),
    );
  }

  void _viewAnalytics(dynamic course) {
    // Show course-specific analytics
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course analytics coming soon!')),
    );
  }

  void _viewStudents(dynamic course) {
    // Show enrolled students
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student list coming soon!')),
    );
  }

  void _publishCourse(dynamic course) {
    widget.instructorService.submitCourseForApproval(course.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course submitted for approval!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteCourse(dynamic course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await widget.instructorService.deleteCourse(course.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Course deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}