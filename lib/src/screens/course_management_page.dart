import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../services/content_management_service.dart';
import '../models/course_module.dart';
import '../models/course.dart';
import 'content_upload_page.dart';

class CourseManagementPage extends StatefulWidget {
  const CourseManagementPage({Key? key}) : super(key: key);

  @override
  State<CourseManagementPage> createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage> {
  final ContentManagementService _contentService = ContentManagementService();
  List<Course> _courses = [];
  Course? _selectedCourse;
  List<CourseModule> _modules = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock data for now - replace with actual service call
      _courses = [
        Course(
          id: '1',
          title: 'Introduction to International Arbitration',
          description: 'Comprehensive introduction to arbitration principles',
          instructor: 'Dr. Sarah Johnson',
          rating: 4.8,
          price: 299.99,
          category: 'arbitration',
          imageUrl: '',
        ),
        Course(
          id: '2',
          title: 'Advanced Mediation Techniques',
          description: 'Advanced strategies for effective mediation',
          instructor: 'Prof. Michael Chen',
          rating: 4.9,
          price: 399.99,
          category: 'mediation',
          imageUrl: '',
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading courses: $e')),
      );
    }
  }

  Future<void> _loadModules(String courseId) async {
    try {
      final modules = await _contentService.getCourseModules(courseId);
      setState(() {
        _modules = modules;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading modules: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Course Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _createNewCourse,
                icon: const Icon(Icons.add),
                label: const Text('New Course'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search courses...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Courses List
                      Expanded(
                        flex: 2,
                        child: _buildCoursesList(),
                      ),
                      
                      const SizedBox(width: 24),
                      
                      // Course Details/Modules
                      Expanded(
                        flex: 3,
                        child: _selectedCourse != null
                            ? _buildCourseDetails()
                            : _buildEmptyState(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    final filteredCourses = _courses.where((course) {
      return _searchQuery.isEmpty ||
          course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Courses (${filteredCourses.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                final isSelected = _selectedCourse?.id == course.id;
                
                return Card(
                  color: isSelected ? const Color(0xFFB71C1C).withOpacity(0.1) : null,
                  child: ListTile(
                    title: Text(
                      course.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFFB71C1C) : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.instructor),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.rating.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              '\$${course.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleCourseAction(value, course),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit Course'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: ListTile(
                            leading: Icon(Icons.copy),
                            title: Text('Duplicate'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCourse = course;
                      });
                      _loadModules(course.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCourse!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${_selectedCourse!.instructor}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _addModule(_selectedCourse!.id),
                icon: const Icon(Icons.add),
                label: const Text('Add Module'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Course Stats
          Row(
            children: [
              _buildStatChip(Icons.star, _selectedCourse!.rating.toString(), Colors.amber),
              const SizedBox(width: 16),
              _buildStatChip(Icons.attach_money, _selectedCourse!.price.toStringAsFixed(2), Colors.green),
              const SizedBox(width: 16),
              _buildStatChip(Icons.folder, '${_modules.length} modules', Colors.blue),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Modules Section
          Row(
            children: [
              const Text(
                'Course Modules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _reorderModules(_selectedCourse!.id),
                icon: const Icon(Icons.reorder),
                label: const Text('Reorder'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: _modules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No modules yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _addModule(_selectedCourse!.id),
                          child: const Text('Add First Module'),
                        ),
                      ],
                    ),
                  )
                : _buildModulesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesList() {
    return ReorderableListView.builder(
      itemCount: _modules.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _modules.removeAt(oldIndex);
          _modules.insert(newIndex, item);
        });
        
        // Update order in database
        final moduleIds = _modules.map((m) => m.id).toList();
        _contentService.reorderModules(_selectedCourse!.id, moduleIds);
      },
      itemBuilder: (context, index) {
        final module = _modules[index];
        
        return Card(
          key: ValueKey(module.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFB71C1C),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              module.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${module.durationMinutes} minutes • ${module.moduleType}',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleModuleAction(value, module),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit Module'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'content',
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add Content'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(module.description),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Chip(
                          label: Text(module.moduleType.toUpperCase()),
                          backgroundColor: const Color(0xFFB71C1C).withOpacity(0.1),
                        ),
                        const SizedBox(width: 8),
                        if (module.isRequired)
                          const Chip(
                            label: Text('REQUIRED'),
                            backgroundColor: Colors.orange,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Select a course to manage',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a course from the list to view and edit its modules',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _createNewCourse() {
    // Navigate to course creation page
    showDialog(
      context: context,
      builder: (context) => const _CourseCreationDialog(),
    );
  }

  void _addModule(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentUploadPage(courseId: courseId),
      ),
    ).then((_) {
      _loadModules(courseId);
    });
  }

  void _handleCourseAction(String action, Course course) {
    switch (action) {
      case 'edit':
        // Navigate to course edit page
        break;
      case 'duplicate':
        // Duplicate course
        break;
      case 'delete':
        _deleteCourse(course);
        break;
    }
  }

  void _handleModuleAction(String action, CourseModule module) {
    switch (action) {
      case 'edit':
        // Edit module
        break;
      case 'content':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentUploadPage(
              courseId: module.courseId,
              moduleId: module.id,
            ),
          ),
        );
        break;
      case 'delete':
        _deleteModule(module);
        break;
    }
  }

  void _deleteCourse(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete course
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteModule(CourseModule module) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: Text('Are you sure you want to delete "${module.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _contentService.deleteModule(module.id);
              Navigator.pop(context);
              _loadModules(module.courseId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _reorderModules(String courseId) {
    // Show reorder dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Drag modules to reorder them')),
    );
  }
}

class _CourseCreationDialog extends StatefulWidget {
  const _CourseCreationDialog();

  @override
  State<_CourseCreationDialog> createState() => _CourseCreationDialogState();
}

class _CourseCreationDialogState extends State<_CourseCreationDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'arbitration';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Course'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Course Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instructorController,
              decoration: const InputDecoration(
                labelText: 'Instructor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (\$)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'arbitration', child: Text('Arbitration')),
                      DropdownMenuItem(value: 'mediation', child: Text('Mediation')),
                      DropdownMenuItem(value: 'commercial', child: Text('Commercial Law')),
                      DropdownMenuItem(value: 'compliance', child: Text('Compliance')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Create course
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
          ),
          child: const Text('Create Course'),
        ),
      ],
    );
  }
}