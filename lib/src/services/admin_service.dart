import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import 'enhanced_auth_service.dart';

class AdminService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _instructorApplications = [];
  List<Course> _pendingCourses = [];
  Map<String, dynamic>? _platformAnalytics;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get instructorApplications => _instructorApplications;
  List<Course> get pendingCourses => _pendingCourses;
  Map<String, dynamic>? get platformAnalytics => _platformAnalytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all users
  Future<void> loadUsers() async {
    _setLoading(true);
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      _users = List<Map<String, dynamic>>.from(response);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load users: $e';
      debugPrint('Error loading users: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load instructor applications
  Future<void> loadInstructorApplications() async {
    _setLoading(true);
    try {
      final response = await _supabase
          .from('instructor_applications')
          .select('''
            *,
            profiles!inner(full_name, email, display_name)
          ''')
          .order('created_at', ascending: false);

      _instructorApplications = List<Map<String, dynamic>>.from(response);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load instructor applications: $e';
      debugPrint('Error loading instructor applications: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load pending courses
  Future<void> loadPendingCourses() async {
    _setLoading(true);
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .eq('status', 'pending_approval')
          .order('created_at', ascending: false);

      _pendingCourses = response.map((data) => Course.fromJson(data)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load pending courses: $e';
      debugPrint('Error loading pending courses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load platform analytics
  Future<void> loadPlatformAnalytics() async {
    _setLoading(true);
    try {
      // Get user counts
      final usersResponse = await _supabase
          .from('profiles')
          .select('role, created_at');

      final totalUsers = usersResponse.length;
      final students = usersResponse.where((u) => u['role'] == 'student').length;
      final instructors = usersResponse.where((u) => u['role'] == 'instructor').length;
      final admins = usersResponse.where((u) => u['role'] == 'admin').length;

      // Get this month's new users
      final now = DateTime.now();
      final thisMonthUsers = usersResponse.where((u) {
        final userDate = DateTime.parse(u['created_at']);
        return userDate.year == now.year && userDate.month == now.month;
      }).length;

      // Get course counts
      final coursesResponse = await _supabase
          .from('courses')
          .select('status, created_at');

      final totalCourses = coursesResponse.length;
      final publishedCourses = coursesResponse.where((c) => c['status'] == 'published').length;
      final pendingCourses = coursesResponse.where((c) => c['status'] == 'pending_approval').length;

      // Get enrollment data
      final enrollmentsResponse = await _supabase
          .from('enrollments')
          .select('created_at, payment_reference');

      final totalEnrollments = enrollmentsResponse.length;

      // Get payment data
      final paymentsResponse = await _supabase
          .from('payments')
          .select('amount, status, created_at')
          .eq('status', 'completed');

      final totalRevenue = paymentsResponse
          .fold<double>(0, (sum, payment) => sum + (payment['amount'] as num).toDouble());

      final thisMonthRevenue = paymentsResponse.where((payment) {
        final paymentDate = DateTime.parse(payment['created_at']);
        return paymentDate.year == now.year && paymentDate.month == now.month;
      }).fold<double>(0, (sum, payment) => sum + (payment['amount'] as num).toDouble());

      _platformAnalytics = {
        'totalUsers': totalUsers,
        'students': students,
        'instructors': instructors,
        'admins': admins,
        'thisMonthUsers': thisMonthUsers,
        'totalCourses': totalCourses,
        'publishedCourses': publishedCourses,
        'pendingCourses': pendingCourses,
        'totalEnrollments': totalEnrollments,
        'totalRevenue': totalRevenue,
        'thisMonthRevenue': thisMonthRevenue,
        'avgRevenuePerEnrollment': totalEnrollments > 0 ? totalRevenue / totalEnrollments : 0,
      };

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load platform analytics: $e';
      debugPrint('Error loading platform analytics: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Approve instructor application
  Future<bool> approveInstructorApplication(String applicationId, String userId) async {
    _setLoading(true);
    try {
      // Update user role to instructor
      await _supabase
          .from('profiles')
          .update({'role': 'instructor', 'updated_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId);

      // Update application status
      await _supabase
          .from('instructor_applications')
          .update({
            'status': 'approved',
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', applicationId);

      // Reload applications
      await loadInstructorApplications();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to approve application: $e';
      debugPrint('Error approving instructor application: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reject instructor application
  Future<bool> rejectInstructorApplication(String applicationId, String reason) async {
    _setLoading(true);
    try {
      await _supabase
          .from('instructor_applications')
          .update({
            'status': 'rejected',
            'rejection_reason': reason,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', applicationId);

      // Reload applications
      await loadInstructorApplications();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reject application: $e';
      debugPrint('Error rejecting instructor application: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Approve course
  Future<bool> approveCourse(String courseId) async {
    _setLoading(true);
    try {
      await _supabase
          .from('courses')
          .update({
            'status': 'published',
            'published_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', courseId);

      // Reload pending courses
      await loadPendingCourses();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to approve course: $e';
      debugPrint('Error approving course: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reject course
  Future<bool> rejectCourse(String courseId, String reason) async {
    _setLoading(true);
    try {
      await _supabase
          .from('courses')
          .update({
            'status': 'rejected',
            'rejection_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', courseId);

      // Reload pending courses
      await loadPendingCourses();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reject course: $e';
      debugPrint('Error rejecting course: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user role
  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    _setLoading(true);
    try {
      await _supabase
          .from('profiles')
          .update({'role': newRole.name, 'updated_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId);

      // Update local users list
      final userIndex = _users.indexWhere((u) => u['user_id'] == userId);
      if (userIndex != -1) {
        _users[userIndex]['role'] = newRole.name;
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user role: $e';
      debugPrint('Error updating user role: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete user (soft delete by deactivating)
  Future<bool> deactivateUser(String userId) async {
    _setLoading(true);
    try {
      await _supabase
          .from('profiles')
          .update({'is_active': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId);

      // Update local users list
      final userIndex = _users.indexWhere((u) => u['user_id'] == userId);
      if (userIndex != -1) {
        _users[userIndex]['is_active'] = false;
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to deactivate user: $e';
      debugPrint('Error deactivating user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reactivate user
  Future<bool> reactivateUser(String userId) async {
    _setLoading(true);
    try {
      await _supabase
          .from('profiles')
          .update({'is_active': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId);

      // Update local users list
      final userIndex = _users.indexWhere((u) => u['user_id'] == userId);
      if (userIndex != -1) {
        _users[userIndex]['is_active'] = true;
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reactivate user: $e';
      debugPrint('Error reactivating user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user activity logs
  Future<List<Map<String, dynamic>>> getUserActivityLogs(String userId) async {
    try {
      // This would typically come from an audit log table
      // For now, we'll return mock data
      return [
        {
          'id': '1',
          'user_id': userId,
          'action': 'login',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'ip_address': '192.168.1.1',
          'user_agent': 'Mozilla/5.0...',
        },
        {
          'id': '2',
          'user_id': userId,
          'action': 'course_enrollment',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'details': 'Enrolled in Introduction to Arbitration',
        },
      ];
    } catch (e) {
      debugPrint('Error loading user activity logs: $e');
      return [];
    }
  }

  // Send platform notification to all users
  Future<bool> sendPlatformNotification(String title, String message, String type) async {
    _setLoading(true);
    try {
      // This would typically use a notification service
      // For now, we'll insert into a notifications table
      final userIds = _users.map((user) => user['user_id']).toList();
      
      final notifications = userIds.map((userId) => {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      await _supabase.from('notifications').insert(notifications);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send notification: $e';
      debugPrint('Error sending platform notification: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load all admin data
  Future<void> loadAllAdminData() async {
    await Future.wait([
      loadUsers(),
      loadInstructorApplications(),
      loadPendingCourses(),
      loadPlatformAnalytics(),
    ]);
  }
}