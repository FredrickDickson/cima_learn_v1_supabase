import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/enhanced_auth_service.dart';
import '../services/instructor_service.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../utils/responsive.dart';
import 'course_creation_page.dart';
import 'instructor_analytics_page.dart';
import 'instructor_courses_page.dart';

class InstructorDashboard extends StatefulWidget {
  const InstructorDashboard({Key? key}) : super(key: key);

  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard> {
  int _selectedIndex = 0;
  late InstructorService _instructorService;

  @override
  void initState() {
    super.initState();
    _instructorService = InstructorService();
    _loadInstructorData();
  }

  void _loadInstructorData() {
    final auth = Provider.of<EnhancedAuthService>(context, listen: false);
    if (auth.isAuthenticated) {
      _instructorService.loadMyCourses(auth.userId);
      _instructorService.loadCourseAnalytics(auth.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedAuthService>(
      builder: (context, auth, child) {
        // Check if user has instructor access
        if (!auth.canCreateCourses()) {
          return _buildAccessDenied();
        }

        final isMobile = Responsive.isMobile(context);
        
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              Header(isMobile: isMobile),
              Expanded(
                child: Row(
                  children: [
                    _buildSidebar(),
                    Expanded(
                      child: _buildMainContent(),
                    ),
                  ],
                ),
              ),
              const Footer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Access Denied',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You need instructor privileges to access this area.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Go to Home'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _showInstructorApplicationDialog(),
              child: const Text('Apply to Become an Instructor'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final menuItems = [
      {'icon': Icons.dashboard, 'title': 'Overview', 'index': 0},
      {'icon': Icons.school, 'title': 'My Courses', 'index': 1},
      {'icon': Icons.add_circle_outline, 'title': 'Create Course', 'index': 2},
      {'icon': Icons.analytics, 'title': 'Analytics', 'index': 3},
      {'icon': Icons.message, 'title': 'Messages', 'index': 4},
      {'icon': Icons.settings, 'title': 'Settings', 'index': 5},
    ];

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Consumer<EnhancedAuthService>(
                    builder: (context, auth, child) {
                      return Text(
                        auth.displayName.isNotEmpty
                            ? auth.displayName[0].toUpperCase()
                            : 'I',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB71C1C),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<EnhancedAuthService>(
                  builder: (context, auth, child) {
                    return Column(
                      children: [
                        Text(
                          auth.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            auth.userRole.displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: menuItems.map((item) {
                final isSelected = _selectedIndex == item['index'];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFB71C1C).withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[600],
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[800],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = item['index'] as int;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return InstructorCoursesPage(instructorService: _instructorService);
      case 2:
        return CourseCreationPage(instructorService: _instructorService);
      case 3:
        return InstructorAnalyticsPage(instructorService: _instructorService);
      case 4:
        return _buildMessages();
      case 5:
        return _buildSettings();
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return ChangeNotifierProvider.value(
      value: _instructorService,
      child: Consumer<InstructorService>(
        builder: (context, service, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructor Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back! Here\'s your teaching overview.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                if (service.analytics != null) ...[
                  _buildAnalyticsCards(service.analytics!),
                  const SizedBox(height: 32),
                ],
                _buildQuickActions(),
                const SizedBox(height: 32),
                _buildRecentCourses(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsCards(Map<String, dynamic> analytics) {
    final cards = [
      {
        'title': 'Total Courses',
        'value': analytics['totalCourses']?.toString() ?? '0',
        'icon': Icons.school,
        'color': const Color(0xFFB71C1C),
      },
      {
        'title': 'Total Students',
        'value': analytics['totalEnrollments']?.toString() ?? '0',
        'icon': Icons.people,
        'color': const Color(0xFF1976D2),
      },
      {
        'title': 'Total Revenue',
        'value': '₦${(analytics['totalRevenue'] ?? 0).toStringAsFixed(0)}',
        'icon': Icons.monetization_on,
        'color': const Color(0xFF388E3C),
      },
      {
        'title': 'This Month',
        'value': '₦${(analytics['thisMonthRevenue'] ?? 0).toStringAsFixed(0)}',
        'icon': Icons.trending_up,
        'color': const Color(0xFFFF9800),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    card['icon'] as IconData,
                    color: card['color'] as Color,
                    size: 24,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                card['value'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Create New Course',
        'subtitle': 'Start building your next course',
        'icon': Icons.add_circle_outline,
        'color': const Color(0xFFB71C1C),
        'onTap': () => setState(() => _selectedIndex = 2),
      },
      {
        'title': 'View Analytics',
        'subtitle': 'Check your teaching performance',
        'icon': Icons.analytics,
        'color': const Color(0xFF1976D2),
        'onTap': () => setState(() => _selectedIndex = 3),
      },
      {
        'title': 'Manage Courses',
        'subtitle': 'Edit and update your courses',
        'icon': Icons.edit,
        'color': const Color(0xFF388E3C),
        'onTap': () => setState(() => _selectedIndex = 1),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: action['onTap'] as VoidCallback,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          action['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          action['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentCourses() {
    return ChangeNotifierProvider.value(
      value: _instructorService,
      child: Consumer<InstructorService>(
        builder: (context, service, child) {
          final recentCourses = service.myCourses.take(3).toList();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Courses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (recentCourses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No courses yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first course to start teaching',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() => _selectedIndex = 2),
                        child: const Text('Create Course'),
                      ),
                    ],
                  ),
                )
              else
                ...recentCourses.map((course) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.school,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course.category,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₦${course.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFFB71C1C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                // Navigate to course edit
                                break;
                              case 'analytics':
                                // Show course analytics
                                break;
                              case 'students':
                                // Show enrolled students
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Course'),
                            ),
                            const PopupMenuItem(
                              value: 'analytics',
                              child: Text('View Analytics'),
                            ),
                            const PopupMenuItem(
                              value: 'students',
                              child: Text('View Students'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessages() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Messages feature coming soon!'),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Settings feature coming soon!'),
        ],
      ),
    );
  }

  void _showInstructorApplicationDialog() {
    final qualificationsController = TextEditingController();
    final experienceController = TextEditingController();
    final teachingController = TextEditingController();
    final portfolioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apply to Become an Instructor',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: qualificationsController,
                decoration: const InputDecoration(
                  labelText: 'Qualifications *',
                  hintText: 'Your educational background and certifications',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: 'Professional Experience *',
                  hintText: 'Your work experience and expertise',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: teachingController,
                decoration: const InputDecoration(
                  labelText: 'Teaching Experience',
                  hintText: 'Any previous teaching or training experience',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: portfolioController,
                decoration: const InputDecoration(
                  labelText: 'Portfolio/Website',
                  hintText: 'Link to your portfolio or professional website',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  Consumer<EnhancedAuthService>(
                    builder: (context, auth, child) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : () async {
                          if (qualificationsController.text.trim().isEmpty ||
                              experienceController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all required fields'),
                              ),
                            );
                            return;
                          }

                          final result = await auth.requestInstructorRole(
                            qualifications: qualificationsController.text.trim(),
                            experience: experienceController.text.trim(),
                            teachingExperience: teachingController.text.trim().isNotEmpty
                                ? teachingController.text.trim()
                                : null,
                            portfolio: portfolioController.text.trim().isNotEmpty
                                ? portfolioController.text.trim()
                                : null,
                          );

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message),
                                backgroundColor: result.isSuccess
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Submit Application'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}