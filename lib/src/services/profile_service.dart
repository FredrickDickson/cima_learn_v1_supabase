import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return UserProfile.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Create new user profile
  Future<UserProfile> createUserProfile({
    required String userId,
    required String email,
    String? fullName,
    String? profileImage,
  }) async {
    try {
      final profileData = {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'profile_image': profileImage,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('profiles').insert(profileData);

      return UserProfile.fromJson(profileData);
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Update user profile
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? fullName,
    String? profession,
    String? organization,
    String? phoneNumber,
    String? country,
    List<String>? learningPreferences,
    String? bio,
  }) async {
    try {
      final updateData = {
        'full_name': fullName,
        'profession': profession,
        'organization': organization,
        'phone_number': phoneNumber,
        'country': country,
        'learning_preferences': learningPreferences,
        'bio': bio,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove null values
      updateData.removeWhere((key, value) => value == null);

      await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId);

      // Fetch updated profile
      final updatedProfile = await getUserProfile(userId);
      if (updatedProfile == null) {
        throw Exception('Failed to fetch updated profile');
      }

      return updatedProfile;
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update profile image
  Future<UserProfile> updateProfileImage({
    required String userId,
    required String imageUrl,
  }) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'profile_image': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Fetch updated profile
      final updatedProfile = await getUserProfile(userId);
      if (updatedProfile == null) {
        throw Exception('Failed to fetch updated profile');
      }

      return updatedProfile;
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  // Get available learning preferences
  List<String> getAvailableLearningPreferences() {
    return [
      'Video Learning',
      'Interactive Exercises',
      'Case Studies',
      'Live Sessions',
      'Reading Materials',
      'Group Discussions',
      'Self-paced Learning',
      'Instructor-led',
      'Mobile Learning',
      'Gamification',
    ];
  }

  // Get available professions
  List<String> getAvailableProfessions() {
    return [
      'Lawyer',
      'Legal Counsel',
      'Arbitrator',
      'Mediator',
      'Judge',
      'Legal Consultant',
      'Corporate Legal',
      'Government Legal',
      'Academic/Professor',
      'Law Student',
      'Business Executive',
      'Compliance Officer',
      'Risk Manager',
      'Other',
    ];
  }

  // Get available countries
  List<String> getAvailableCountries() {
    return [
      'United States',
      'United Kingdom',
      'Canada',
      'Australia',
      'Germany',
      'France',
      'Netherlands',
      'Singapore',
      'Hong Kong',
      'UAE',
      'India',
      'Brazil',
      'Mexico',
      'South Africa',
      'Other',
    ];
  }
}