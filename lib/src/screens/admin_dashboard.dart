import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../services/content_management_service.dart';
import '../models/course_module.dart';
import '../models/course.dart';
import 'content_upload_page.dart';
import 'course_management_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ContentManagementService _contentService = ContentManagementService();
  int _selectedIndex = 0;
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load dashboard statistics
      setState(() {
        _dashboardStats = {
          'totalCourses': 12,
          'totalModules': 48,
          'totalContent': 156,
          'totalStudents': 342,
          'pendingApprovals': 3,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CIMA Admin Dashboard'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: isMobile ? _buildSidebar() : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: Colors.grey[100],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFB71C1C),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, 
                    size: 35, color: Color(0xFFB71C1C)),
                ),
                SizedBox(height: 12),
                Text(
                  'Content Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.library_books, 'Course Management'),
                _buildNavItem(2, Icons.upload_file, 'Content Upload'),
                _buildNavItem(3, Icons.video_library, 'Video Library'),
                _buildNavItem(4, Icons.quiz, 'Assessment Tools'),
                _buildNavItem(5, Icons.people, 'User Management'),
                _buildNavItem(6, Icons.analytics, 'Analytics'),
                _buildNavItem(7, Icons.settings, 'Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFB71C1C).withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return const CourseManagementPage();
      case 2:
        return const ContentUploadPage();
      case 3:
        return _buildVideoLibrary();
      case 4:
        return _buildAssessmentTools();
      case 5:
        return _buildUserManagement();
      case 6:
        return _buildAnalytics();
      case 7:
        return _buildSettings();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Courses', _dashboardStats['totalCourses'].toString(), 
                  Icons.library_books, Colors.blue),
              _buildStatCard('Total Modules', _dashboardStats['totalModules'].toString(), 
                  Icons.folder, Colors.green),
              _buildStatCard('Content Items', _dashboardStats['totalContent'].toString(), 
                  Icons.article, Colors.orange),
              _buildStatCard('Students', _dashboardStats['totalStudents'].toString(), 
                  Icons.people, Colors.purple),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildQuickActionCard(
                'Upload Content',
                'Add new videos, documents, or quizzes',
                Icons.upload,
                () => setState(() => _selectedIndex = 2),
              ),
              _buildQuickActionCard(
                'Create Course',
                'Start building a new course',
                Icons.add_circle,
                () => setState(() => _selectedIndex = 1),
              ),
              _buildQuickActionCard(
                'View Analytics',
                'Check performance metrics',
                Icons.analytics,
                () => setState(() => _selectedIndex = 6),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
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
              children: [
                _buildActivityItem('New course "Advanced Arbitration" created', '2 hours ago'),
                _buildActivityItem('Video uploaded to "Mediation Basics"', '4 hours ago'),
                _buildActivityItem('Quiz "Contract Law Fundamentals" completed by 15 students', '6 hours ago'),
                _buildActivityItem('Course "International Trade Law" published', '1 day ago'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String description, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFFB71C1C), size: 20),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFB71C1C),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLibrary() {
    return const Center(child: Text('Video Library - Coming Soon'));
  }

  Widget _buildAssessmentTools() {
    return const Center(child: Text('Assessment Tools - Coming Soon'));
  }

  Widget _buildUserManagement() {
    return const Center(child: Text('User Management - Coming Soon'));
  }

  Widget _buildAnalytics() {
    return const Center(child: Text('Analytics - Coming Soon'));
  }

  Widget _buildSettings() {
    return const Center(child: Text('Settings - Coming Soon'));
  }
}