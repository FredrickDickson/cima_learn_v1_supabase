import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

/// Authentication states for the AuthBloc
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class AuthInitial extends AuthState {}

/// State when authentication status is being checked
class AuthLoading extends AuthState {}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.user,
    required this.profile,
  });

  final dynamic user; // Supabase User object
  final UserProfile profile;

  @override
  List<Object?> get props => [user, profile];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {}

/// State when authentication operation fails
class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// State when sign up is successful but email verification is pending
class AuthEmailVerificationPending extends AuthState {
  const AuthEmailVerificationPending({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

/// State when password reset email is sent
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

/// State when profile is being updated
class AuthProfileUpdating extends AuthState {
  const AuthProfileUpdating({
    required this.user,
    required this.profile,
  });

  final dynamic user;
  final UserProfile profile;

  @override
  List<Object?> get props => [user, profile];
}

/// State when role upgrade application is submitted
class AuthRoleUpgradeSubmitted extends AuthState {
  const AuthRoleUpgradeSubmitted({
    required this.user,
    required this.profile,
    required this.targetRole,
  });

  final dynamic user;
  final UserProfile profile;
  final String targetRole;

  @override
  List<Object?> get props => [user, profile, targetRole];
}