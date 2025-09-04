import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class GoogleAuthService {
  static const List<String> _scopes = [
    'email',
    'profile',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
    clientId: '', // Will be configured in Google Cloud Console
  );

  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // Sign in to Supabase with Google credentials
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        // Check if user profile exists, create if not
        UserModel? userProfile = await _getUserProfile(response.user!.id);
        
        if (userProfile == null) {
          // Create new user profile
          await _supabase.from('users').insert({
            'id': response.user!.id,
            'email': response.user!.email,
            'full_name': googleUser.displayName,
            'profile_image': googleUser.photoUrl,
            'created_at': DateTime.now().toIso8601String(),
          });

          userProfile = UserModel(
            id: response.user!.id,
            email: response.user!.email!,
            fullName: googleUser.displayName,
            profileImage: googleUser.photoUrl,
            createdAt: DateTime.now(),
          );
        }

        return userProfile;
      }
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
    return null;
  }

  // Sign out from Google and Supabase
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _supabase.auth.signOut(),
      ]);
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Get user profile from database
  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
    } catch (e) {
      print('Get user profile error: $e');
    }
    return null;
  }

  // Check if user is currently signed in
  bool get isSignedIn => _googleSignIn.currentUser != null;

  // Get current Google user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}