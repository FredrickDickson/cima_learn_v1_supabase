class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? profileImage;
  final String? profession;
  final String? organization;
  final String? phoneNumber;
  final String? country;
  final List<String> learningPreferences;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.profileImage,
    this.profession,
    this.organization,
    this.phoneNumber,
    this.country,
    this.learningPreferences = const [],
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      profileImage: json['profile_image'],
      profession: json['profession'],
      organization: json['organization'],
      phoneNumber: json['phone_number'],
      country: json['country'],
      learningPreferences: json['learning_preferences'] != null 
          ? List<String>.from(json['learning_preferences']) 
          : [],
      bio: json['bio'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'profile_image': profileImage,
      'profession': profession,
      'organization': organization,
      'phone_number': phoneNumber,
      'country': country,
      'learning_preferences': learningPreferences,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? profileImage,
    String? profession,
    String? organization,
    String? phoneNumber,
    String? country,
    List<String>? learningPreferences,
    String? bio,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      profession: profession ?? this.profession,
      organization: organization ?? this.organization,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      learningPreferences: learningPreferences ?? this.learningPreferences,
      bio: bio ?? this.bio,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}