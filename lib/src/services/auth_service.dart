import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        // Create user profile in users table
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
        });

        return UserModel(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
    return null;
  }

  // Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return await getUserProfile(response.user!.id);
      }
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
    return null;
  }

  // Get user profile from database
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<UserModel?> updateProfile({
    required String userId,
    String? fullName,
    String? profileImage,
    String? language,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (profileImage != null) updates['profile_image'] = profileImage;
      if (language != null) updates['language'] = language;

      await _supabase.from('users').update(updates).eq('id', userId);

      return await getUserProfile(userId);
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }
}