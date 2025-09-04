import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/responsive.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../services/enhanced_auth_service.dart';
import '../services/admin_service.dart';
import '../models/course.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late AdminService _adminService;
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _adminService = AdminService();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    await _adminService.loadAllAdminData();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedAuthService>(
      builder: (context, auth, child) {
        // Check admin access
        if (!auth.hasAdminAccess()) {
          return _buildAccessDenied();
        }

        final isMobile = Responsive.isMobile(context);
        
        return ChangeNotifierProvider.value(
          value: _adminService,
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            body: Column(
              children: [
                Header(isMobile: isMobile),
                Expanded(
                  child: Row(
                    children: [
                      _buildSidebar(),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildMainContent(),
                      ),
                    ],
                  ),
                ),
                const Footer(),
              ],
            ),
          ),
        );
      },
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
                _buildNavItem(1, Icons.people, 'User Management'),
                _buildNavItem(2, Icons.school, 'Course Approval'),
                _buildNavItem(3, Icons.person_add, 'Instructor Applications'),
                _buildNavItem(4, Icons.analytics, 'Platform Analytics'),
                _buildNavItem(5, Icons.notification_important, 'Notifications'),
                _buildNavItem(6, Icons.settings, 'Platform Settings'),
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
              'You need administrator privileges to access this area.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return _buildUserManagement();
      case 2:
        return _buildCourseApproval();
      case 3:
        return _buildInstructorApplications();
      case 4:
        return _buildPlatformAnalytics();
      case 5:
        return _buildNotifications();
      case 6:
        return _buildPlatformSettings();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    return Consumer<AdminService>(
      builder: (context, adminService, child) {
        final analytics = adminService.platformAnalytics;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Platform overview and management tools',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              if (analytics != null) ...[
                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Total Users', analytics['totalUsers'].toString(), 
                        Icons.people, const Color(0xFFB71C1C)),
                    _buildStatCard('Total Courses', analytics['totalCourses'].toString(), 
                        Icons.school, const Color(0xFF1976D2)),
                    _buildStatCard('Total Revenue', '₦${analytics['totalRevenue'].toStringAsFixed(0)}', 
                        Icons.monetization_on, const Color(0xFF388E3C)),
                    _buildStatCard('This Month', '₦${analytics['thisMonthRevenue'].toStringAsFixed(0)}', 
                        Icons.trending_up, const Color(0xFFFF9800)),
                  ],
                ),
                const SizedBox(height: 32),
                _buildUserBreakdown(analytics),
                const SizedBox(height: 32),
              ],
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    'Manage Users',
                    'View and manage user accounts',
                    Icons.people,
                    () => setState(() => _selectedIndex = 1),
                  ),
                  _buildQuickActionCard(
                    'Course Approval',
                    'Review pending course submissions',
                    Icons.school,
                    () => setState(() => _selectedIndex = 2),
                  ),
                  _buildQuickActionCard(
                    'Instructor Applications',
                    'Review instructor applications',
                    Icons.person_add,
                    () => setState(() => _selectedIndex = 3),
                  ),
                  _buildQuickActionCard(
                    'Platform Analytics',
                    'View detailed analytics',
                    Icons.analytics,
                    () => setState(() => _selectedIndex = 4),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildPendingActions(adminService),
            ],
          ),
        );
      },
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

  Widget _buildUserBreakdown(Map<String, dynamic> analytics) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'User Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildUserTypeCard('Students', analytics['students'], Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserTypeCard('Instructors', analytics['instructors'], Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserTypeCard('Admins', analytics['admins'], Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard(String type, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            type,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions(AdminService adminService) {
    final pendingApplications = adminService.instructorApplications
        .where((app) => app['status'] == 'pending')
        .length;
    final pendingCourses = adminService.pendingCourses.length;
    
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Pending Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (pendingApplications > 0) 
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_add, color: Colors.orange),
              ),
              title: Text('$pendingApplications Instructor Applications'),
              subtitle: const Text('Pending review'),
              trailing: TextButton(
                onPressed: () => setState(() => _selectedIndex = 3),
                child: const Text('Review'),
              ),
            ),
          if (pendingCourses > 0)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Colors.blue),
              ),
              title: Text('$pendingCourses Course Submissions'),
              subtitle: const Text('Awaiting approval'),
              trailing: TextButton(
                onPressed: () => setState(() => _selectedIndex = 2),
                child: const Text('Review'),
              ),
            ),
          if (pendingApplications == 0 && pendingCourses == 0)
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('All caught up!'),
              subtitle: Text('No pending actions at this time'),
            ),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return const Center(child: Text('User Management - Coming Soon'));
  }

  Widget _buildCourseApproval() {
    return const Center(child: Text('Course Approval - Coming Soon'));
  }

  Widget _buildInstructorApplications() {
    return const Center(child: Text('Instructor Applications - Coming Soon'));
  }

  Widget _buildPlatformAnalytics() {
    return const Center(child: Text('Platform Analytics - Coming Soon'));
  }

  Widget _buildNotifications() {
    return const Center(child: Text('Notifications - Coming Soon'));
  }

  Widget _buildPlatformSettings() {
    return const Center(child: Text('Platform Settings - Coming Soon'));
  }
}