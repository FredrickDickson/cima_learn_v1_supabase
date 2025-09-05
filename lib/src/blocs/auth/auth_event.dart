import 'package:equatable/equatable.dart';

/// Authentication events for the AuthBloc
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check if user is already authenticated
class AuthCheckRequested extends AuthEvent {}

/// Event to sign in with email and password
class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

/// Event to sign up with email and password
class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });

  final String email;
  final String password;
  final String fullName;

  @override
  List<Object> get props => [email, password, fullName];
}

/// Event to sign in with Google OAuth
class AuthGoogleSignInRequested extends AuthEvent {}

/// Event to sign out
class AuthSignOutRequested extends AuthEvent {}

/// Event to reset password
class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

/// Event to update user profile
class AuthProfileUpdateRequested extends AuthEvent {
  const AuthProfileUpdateRequested({
    this.fullName,
    this.profession,
    this.organization,
    this.experience,
    this.avatarUrl,
  });

  final String? fullName;
  final String? profession;
  final String? organization;
  final String? experience;
  final String? avatarUrl;

  @override
  List<Object?> get props => [fullName, profession, organization, experience, avatarUrl];
}

/// Event to upgrade user role (student to instructor)
class AuthRoleUpgradeRequested extends AuthEvent {
  const AuthRoleUpgradeRequested({
    required this.targetRole,
    required this.applicationData,
  });

  final String targetRole;
  final Map<String, dynamic> applicationData;

  @override
  List<Object> get props => [targetRole, applicationData];
}