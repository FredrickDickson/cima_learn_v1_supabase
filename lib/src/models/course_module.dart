class CourseModule {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int orderIndex;
  final String moduleType; // 'video', 'document', 'quiz', 'live_session'
  final Map<String, String> content; // language code -> content URL/data
  final int estimatedDurationMinutes;
  final List<String> prerequisites;
  final bool isRequired;
  final Map<String, dynamic> metadata; // Additional module-specific data
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.moduleType,
    this.content = const {},
    required this.estimatedDurationMinutes,
    this.prerequisites = const [],
    this.isRequired = true,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      orderIndex: json['order_index'],
      moduleType: json['module_type'],
      content: Map<String, String>.from(json['content'] ?? {}),
      estimatedDurationMinutes: json['estimated_duration_minutes'],
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      isRequired: json['is_required'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'order_index': orderIndex,
      'module_type': moduleType,
      'content': content,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'prerequisites': prerequisites,
      'is_required': isRequired,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String? getContentForLanguage(String languageCode) {
    return content[languageCode] ?? content['en']; // Fallback to English
  }

  bool get isVideo => moduleType == 'video';
  bool get isDocument => moduleType == 'document';
  bool get isQuiz => moduleType == 'quiz';
  bool get isLiveSession => moduleType == 'live_session';
}