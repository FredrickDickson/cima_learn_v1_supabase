class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? profileImage;
  final DateTime createdAt;
  final List<String> enrolledCourses;
  final String language;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.profileImage,
    required this.createdAt,
    this.enrolledCourses = const [],
    this.language = 'en',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      profileImage: json['profile_image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      enrolledCourses: List<String>.from(json['enrolled_courses'] ?? []),
      language: json['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'enrolled_courses': enrolledCourses,
      'language': language,
    };
  }
}