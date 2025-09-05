enum ContentType {
  video,
  document,
  text,
  quiz,
  assignment,
  live_session,
  audio,
  presentation,
  interactive,
  pdf,
  image
}

class CourseContent {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final ContentType contentType;
  final String? fileUrl;
  final String? textContent;
  final Map<String, dynamic>? quizData;
  final int orderIndex;
  final int durationMinutes;
  final bool isRequired;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseContent({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.contentType,
    this.fileUrl,
    this.textContent,
    this.quizData,
    required this.orderIndex,
    required this.durationMinutes,
    this.isRequired = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      id: json['id'],
      moduleId: json['module_id'],
      title: json['title'],
      description: json['description'],
      contentType: ContentType.values.firstWhere(
        (type) => type.name == json['content_type'],
        orElse: () => ContentType.text,
      ),
      fileUrl: json['file_url'],
      textContent: json['text_content'],
      quizData: json['quiz_data'],
      orderIndex: json['order_index'],
      durationMinutes: json['duration_minutes'],
      isRequired: json['is_required'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'title': title,
      'description': description,
      'content_type': contentType.name,
      'file_url': fileUrl,
      'text_content': textContent,
      'quiz_data': quizData,
      'order_index': orderIndex,
      'duration_minutes': durationMinutes,
      'is_required': isRequired,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Additional classes for enhanced module functionality
class ModuleContent {
  final String id;
  final String language;
  final String title;
  final String description;
  final String? contentUrl;
  final Map<String, dynamic>? metadata;

  ModuleContent({
    required this.id,
    required this.language,
    required this.title,
    required this.description,
    this.contentUrl,
    this.metadata,
  });

  factory ModuleContent.fromJson(Map<String, dynamic> json) {
    return ModuleContent(
      id: json['id'],
      language: json['language'] ?? 'en',
      title: json['title'],
      description: json['description'] ?? '',
      contentUrl: json['content_url'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'title': title,
      'description': description,
      'content_url': contentUrl,
      'metadata': metadata,
    };
  }
}

class VideoProgress {
  final String userId;
  final String moduleId;
  final double watchedDuration;
  final double totalDuration;
  final bool isCompleted;
  final DateTime lastWatched;

  VideoProgress({
    required this.userId,
    required this.moduleId,
    required this.watchedDuration,
    required this.totalDuration,
    this.isCompleted = false,
    required this.lastWatched,
  });

  factory VideoProgress.fromJson(Map<String, dynamic> json) {
    return VideoProgress(
      userId: json['user_id'],
      moduleId: json['module_id'],
      watchedDuration: (json['watched_duration'] as num).toDouble(),
      totalDuration: (json['total_duration'] as num).toDouble(),
      isCompleted: json['is_completed'] ?? false,
      lastWatched: DateTime.parse(json['last_watched']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'module_id': moduleId,
      'watched_duration': watchedDuration,
      'total_duration': totalDuration,
      'is_completed': isCompleted,
      'last_watched': lastWatched.toIso8601String(),
    };
  }

  double get progressPercentage {
    if (totalDuration <= 0) return 0.0;
    return (watchedDuration / totalDuration).clamp(0.0, 1.0);
  }
}

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
  
  // Enhanced fields for better functionality
  final List<ModuleContent>? multiLanguageContent;
  final VideoProgress? userProgress;
  final bool isCompleted;
  final double completionPercentage;

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
    this.multiLanguageContent,
    this.userProgress,
    this.isCompleted = false,
    this.completionPercentage = 0.0,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'] ?? '',
      orderIndex: json['order_index'],
      moduleType: json['module_type'],
      content: Map<String, String>.from(json['content'] ?? {}),
      estimatedDurationMinutes: json['estimated_duration_minutes'] ?? 30,
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      isRequired: json['is_required'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      multiLanguageContent: json['module_content'] != null
          ? (json['module_content'] as List)
              .map((content) => ModuleContent.fromJson(content))
              .toList()
          : null,
      userProgress: json['user_progress'] != null
          ? VideoProgress.fromJson(json['user_progress'])
          : null,
      isCompleted: json['is_completed'] ?? false,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
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
    // First check multi-language content
    if (multiLanguageContent != null) {
      for (final content in multiLanguageContent!) {
        if (content.language == languageCode && content.contentUrl != null) {
          return content.contentUrl;
        }
      }
    }
    
    // Fallback to legacy content map
    return content[languageCode] ?? content['en']; // Fallback to English
  }

  /// Get content for the user's preferred language with fallback
  String? getLocalizedContentUrl(String preferredLanguage) {
    return getContentForLanguage(preferredLanguage) ?? 
           getContentForLanguage('en') ?? 
           content.values.isNotEmpty ? content.values.first : null;
  }

  /// Check if module has content in a specific language
  bool hasContentInLanguage(String languageCode) {
    return getContentForLanguage(languageCode) != null;
  }

  /// Get available languages for this module
  List<String> getAvailableLanguages() {
    final languages = <String>{};
    
    // Add from multi-language content
    if (multiLanguageContent != null) {
      for (final content in multiLanguageContent!) {
        languages.add(content.language);
      }
    }
    
    // Add from legacy content map
    languages.addAll(content.keys);
    
    return languages.toList();
  }

  bool get isVideo => moduleType == 'video';
  bool get isDocument => moduleType == 'document';
  bool get isQuiz => moduleType == 'quiz';
  bool get isLiveSession => moduleType == 'live_session';

  /// Create a copy with updated progress
  CourseModule copyWithProgress({
    VideoProgress? userProgress,
    bool? isCompleted,
    double? completionPercentage,
  }) {
    return CourseModule(
      id: id,
      courseId: courseId,
      title: title,
      description: description,
      orderIndex: orderIndex,
      moduleType: moduleType,
      content: content,
      estimatedDurationMinutes: estimatedDurationMinutes,
      prerequisites: prerequisites,
      isRequired: isRequired,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      multiLanguageContent: multiLanguageContent,
      userProgress: userProgress ?? this.userProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}