import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnhancedAuthService extends ChangeNotifier {
  static final EnhancedAuthService _instance = EnhancedAuthService._internal();
  factory EnhancedAuthService() => _instance;
  EnhancedAuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userId => _currentUser?.id ?? '';

  // Initialize auth state
  Future<void> initialize() async {
    _currentUser = _supabase.auth.currentUser;
    if (_currentUser != null) {
      await _loadUserProfile();
    }
    
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        await _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
    
    notifyListeners();
  }

  // Load user profile from database
  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;
    
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', _currentUser!.id)
          .maybeSingle();

      if (response != null) {
        _userProfile = response;
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  // Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? profession,
    String? organization,
    String? country,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'full_name': fullName.trim(),
        },
      );

      if (response.user != null) {
        // Create profile in database
        await _createUserProfile(
          userId: response.user!.id,
          email: email.trim(),
          fullName: fullName.trim(),
          profession: profession,
          organization: organization,
          country: country,
        );

        // If session exists, user is automatically signed in
        if (response.session != null) {
          _currentUser = response.user;
          await _loadUserProfile();
          return AuthResult.success('Account created successfully!');
        } else {
          return AuthResult.success('Please check your email to confirm your account.');
        }
      } else {
        return AuthResult.error('Failed to create account. Please try again.');
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return AuthResult.error(e.message);
    } catch (e) {
      _setError('An unexpected error occurred.');
      return AuthResult.error('An unexpected error occurred.');
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        return AuthResult.success('Welcome back!');
      } else {
        return AuthResult.error('Failed to sign in. Please try again.');
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return AuthResult.error(e.message);
    } catch (e) {
      _setError('An unexpected error occurred.');
      return AuthResult.error('An unexpected error occurred.');
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://cimalearning.com/auth/callback',
      );
      return AuthResult.success('Redirecting to Google...');
    } on AuthException catch (e) {
      _setError(e.message);
      return AuthResult.error(e.message);
    } catch (e) {
      _setError('Google sign-in failed.');
      return AuthResult.error('Google sign-in failed.');
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<AuthResult> signOut() async {
    _setLoading(true);

    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      _userProfile = null;
      return AuthResult.success('Signed out successfully.');
    } catch (e) {
      return AuthResult.error('Failed to sign out.');
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'https://cimalearning.com/reset-password',
      );
      return AuthResult.success('Password reset email sent!');
    } on AuthException catch (e) {
      _setError(e.message);
      return AuthResult.error(e.message);
    } catch (e) {
      _setError('Failed to send reset email.');
      return AuthResult.error('Failed to send reset email.');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    _clearError();

    try {
      await _supabase
          .from('profiles')
          .update({
            ...profileData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      await _loadUserProfile();
      return AuthResult.success('Profile updated successfully!');
    } catch (e) {
      _setError('Failed to update profile.');
      return AuthResult.error('Failed to update profile.');
    } finally {
      _setLoading(false);
    }
  }

  // Check if user is enrolled in a course
  Future<bool> isEnrolledInCourse(String courseId) async {
    if (_currentUser == null) return false;

    try {
      final response = await _supabase
          .from('enrollments')
          .select()
          .eq('user_id', _currentUser!.id)
          .eq('course_id', courseId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking enrollment: $e');
      return false;
    }
  }

  // Get user's enrolled courses
  Future<List<String>> getEnrolledCourses() async {
    if (_currentUser == null) return [];

    try {
      final response = await _supabase
          .from('enrollments')
          .select('course_id')
          .eq('user_id', _currentUser!.id);

      return response.map((item) => item['course_id'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching enrolled courses: $e');
      return [];
    }
  }

  // Create user profile in database
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? profession,
    String? organization,
    String? country,
  }) async {
    try {
      final profileData = {
        'user_id': userId,
        'email': email,
        'full_name': fullName,
        'display_name': fullName.split(' ').first,
        'profession': profession,
        'organization': organization,
        'country': country,
        'cima_membership_level': 'associate',
        'experience_level': 'beginner',
        'profile_completed': profession != null && organization != null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('profiles').upsert(profileData);
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult._(this.isSuccess, this.message);

  factory AuthResult.success(String message) => AuthResult._(true, message);
  factory AuthResult.error(String message) => AuthResult._(false, message);
}