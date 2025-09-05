import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../../models/user_profile.dart';
import '../../utils/validators.dart';
import 'auth_event.dart';
import 'auth_state.dart' as auth_states;

/// Authentication BLoC managing user authentication and profile state
class AuthBloc extends Bloc<AuthEvent, auth_states.auth_states::AuthState> {
  AuthBloc() : super(auth_states.AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthProfileUpdateRequested>(_onAuthProfileUpdateRequested);
    on<AuthRoleUpgradeRequested>(_onAuthRoleUpgradeRequested);

    // Listen to auth state changes
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && data.session?.user != null) {
        _loadUserProfile(data.session!.user);
      } else if (data.event == AuthChangeEvent.signedOut) {
        add(AuthCheckRequested());
      }
    });
  }

  late final StreamSubscription _authSubscription;

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  /// Check if user is already authenticated
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<auth_states::AuthState> emit,
  ) async {
    emit(auth_states::AuthLoading());

    try {
      final session = supabase.auth.currentSession;
      
      if (session?.user != null) {
        await _loadUserProfile(session!.user, emit);
      } else {
        emit(auth_states::AuthUnauthenticated());
      }
    } catch (e) {
      emit(auth_states::AuthError(message: 'Failed to check authentication status: $e'));
    }
  }

  /// Handle user sign in
  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<auth_states::AuthState> emit,
  ) async {
    emit(auth_states::AuthLoading());

    try {
      // Validate input
      final emailError = Validators.validateEmail(event.email);
      if (emailError != null) {
        emit(auth_states::AuthError(message: emailError));
        return;
      }

      final passwordError = Validators.validatePassword(event.password);
      if (passwordError != null) {
        emit(auth_states::AuthError(message: passwordError));
        return;
      }

      // Attempt sign in
      final response = await supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!, emit);
      } else {
        emit(auth_states::AuthError(message: 'Sign in failed'));
      }
    } on AuthException catch (e) {
      emit(auth_states::AuthError(message: _getAuthErrorMessage(e)));
    } catch (e) {
      emit(auth_states::AuthError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handle user sign up
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<auth_states::AuthState> emit,
  ) async {
    emit(auth_states::AuthLoading());

    try {
      // Validate input
      final emailError = Validators.validateEmail(event.email);
      if (emailError != null) {
        emit(auth_states::AuthError(message: emailError));
        return;
      }

      final passwordError = Validators.validatePassword(event.password);
      if (passwordError != null) {
        emit(auth_states::AuthError(message: passwordError));
        return;
      }

      final nameError = Validators.validateName(event.fullName);
      if (nameError != null) {
        emit(auth_states::AuthError(message: nameError));
        return;
      }

      // Attempt sign up
      final response = await supabase.auth.signUp(
        email: event.email,
        password: event.password,
        data: {'full_name': event.fullName},
      );

      if (response.user != null) {
        if (response.session != null) {
          // User is immediately signed in
          await _createUserProfile(response.user!, event.fullName, emit);
        } else {
          // Email verification required
          emit(auth_states::AuthEmailVerificationPending(email: event.email));
        }
      } else {
        emit(auth_states::AuthError(message: 'Sign up failed'));
      }
    } on AuthException catch (e) {
      emit(auth_states::AuthError(message: _getAuthErrorMessage(e)));
    } catch (e) {
      emit(auth_states::AuthError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handle Google sign in
  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<auth_states::AuthState> emit,
  ) async {
    emit(auth_states::AuthLoading());

    try {
      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.cimalearning://login-callback/',
      );

      // Note: OAuth flow completes in the auth state change listener
    } on AuthException catch (e) {
      emit(auth_states::AuthError(message: _getAuthErrorMessage(e)));
    } catch (e) {
      emit(auth_states::AuthError(message: 'Google sign in failed: $e'));
    }
  }

  /// Handle user sign out
  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<auth_states::AuthState> emit,
  ) async {
    emit(auth_states::AuthLoading());

    try {
      await supabase.auth.signOut();
      emit(auth_states::AuthUnauthenticated());
    } catch (e) {
      emit(auth_states::AuthError(message: 'Sign out failed: $e'));
    }
  }

  /// Handle password reset request
  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<auth_states::AuthState> emit,
  ) async {
    emit(auth_states::AuthLoading());

    try {
      final emailError = Validators.validateEmail(event.email);
      if (emailError != null) {
        emit(auth_states::AuthError(message: emailError));
        return;
      }

      await supabase.auth.resetPasswordForEmail(event.email);
      emit(auth_states::AuthPasswordResetSent(email: event.email));
    } on AuthException catch (e) {
      emit(auth_states::AuthError(message: _getAuthErrorMessage(e)));
    } catch (e) {
      emit(auth_states::AuthError(message: 'Password reset failed: $e'));
    }
  }

  /// Handle profile update
  Future<void> _onAuthProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<auth_states::AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    final currentState = state as AuthAuthenticated;
    emit(auth_states::AuthProfileUpdating(user: currentState.user, profile: currentState.profile));

    try {
      final updates = <String, dynamic>{};
      
      if (event.fullName != null) updates['full_name'] = event.fullName;
      if (event.profession != null) updates['profession'] = event.profession;
      if (event.organization != null) updates['organization'] = event.organization;
      if (event.experience != null) updates['experience_level'] = event.experience;
      if (event.avatarUrl != null) updates['avatar_url'] = event.avatarUrl;

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();

        await supabase
            .from('user_profiles')
            .update(updates)
            .eq('id', currentState.user.id);
      }

      // Reload profile
      await _loadUserProfile(currentState.user, emit);
    } catch (e) {
      emit(auth_states::AuthError(message: 'Profile update failed: $e'));
    }
  }

  /// Handle role upgrade request
  Future<void> _onAuthRoleUpgradeRequested(
    AuthRoleUpgradeRequested event,
    Emitter<auth_states::AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    final currentState = state as AuthAuthenticated;
    emit(auth_states::AuthLoading());

    try {
      // Submit instructor application
      await supabase.from('instructor_applications').insert({
        'user_id': currentState.user.id,
        'target_role': event.targetRole,
        'application_data': event.applicationData,
        'status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
      });

      emit(auth_states::AuthRoleUpgradeSubmitted(
        user: currentState.user,
        profile: currentState.profile,
        targetRole: event.targetRole,
      ));
    } catch (e) {
      emit(auth_states::AuthError(message: 'Role upgrade application failed: $e'));
    }
  }

  /// Load user profile from database
  Future<void> _loadUserProfile(User user, [Emitter<auth_states::AuthState>? emit]) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      UserProfile profile;
      if (response != null) {
        profile = UserProfile.fromJson(response);
      } else {
        // Create default profile for new users
        profile = await _createDefaultProfile(user);
      }

      if (emit != null) {
        emit(auth_states::AuthAuthenticated(user: user, profile: profile));
      }
    } catch (e) {
      if (emit != null) {
        emit(auth_states::AuthError(message: 'Failed to load user profile: $e'));
      }
    }
  }

  /// Create user profile after sign up
  Future<void> _createUserProfile(User user, String fullName, Emitter<auth_states::AuthState> emit) async {
    try {
      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': fullName,
        'role': 'student',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('user_profiles').insert(profileData);

      final profile = UserProfile.fromJson(profileData);
      emit(auth_states::AuthAuthenticated(user: user, profile: profile));
    } catch (e) {
      emit(auth_states::AuthError(message: 'Failed to create user profile: $e'));
    }
  }

  /// Create default profile for existing users
  Future<UserProfile> _createDefaultProfile(User user) async {
    final profileData = {
      'id': user.id,
      'email': user.email,
      'full_name': user.userMetadata?['full_name'] ?? 'User',
      'role': 'student',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await supabase.from('user_profiles').insert(profileData);
    return UserProfile.fromJson(profileData);
  }

  /// Convert AuthException to user-friendly message
  String _getAuthErrorMessage(AuthException exception) {
    switch (exception.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'Email not confirmed':
        return 'Please verify your email address before signing in.';
      case 'User already registered':
        return 'An account with this email already exists. Please sign in instead.';
      case 'Signup disabled':
        return 'New registrations are currently disabled.';
      default:
        return exception.message;
    }
  }
}