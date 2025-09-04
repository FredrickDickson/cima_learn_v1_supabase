class CourseProgress {
  final String id;
  final String userId;
  final String courseId;
  final String courseTitle;
  final double progressPercentage;
  final int completedModules;
  final int totalModules;
  final DateTime enrollmentDate;
  final DateTime? completionDate;
  final DateTime lastAccessedAt;
  final List<ModuleProgress> moduleProgress;
  final double? overallScore;
  final String status; // 'enrolled', 'in_progress', 'completed', 'paused'

  CourseProgress({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.courseTitle,
    required this.progressPercentage,
    required this.completedModules,
    required this.totalModules,
    required this.enrollmentDate,
    this.completionDate,
    required this.lastAccessedAt,
    this.moduleProgress = const [],
    this.overallScore,
    this.status = 'enrolled',
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      courseTitle: json['course_title'],
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
      completedModules: json['completed_modules'] ?? 0,
      totalModules: json['total_modules'] ?? 0,
      enrollmentDate: DateTime.parse(json['enrollment_date']),
      completionDate: json['completion_date'] != null 
          ? DateTime.parse(json['completion_date']) 
          : null,
      lastAccessedAt: DateTime.parse(json['last_accessed_at']),
      moduleProgress: json['module_progress'] != null
          ? (json['module_progress'] as List)
              .map((e) => ModuleProgress.fromJson(e))
              .toList()
          : [],
      overallScore: json['overall_score']?.toDouble(),
      status: json['status'] ?? 'enrolled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'course_title': courseTitle,
      'progress_percentage': progressPercentage,
      'completed_modules': completedModules,
      'total_modules': totalModules,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'completion_date': completionDate?.toIso8601String(),
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'module_progress': moduleProgress.map((e) => e.toJson()).toList(),
      'overall_score': overallScore,
      'status': status,
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  String get formattedProgress => '${progressPercentage.toInt()}%';
}

class ModuleProgress {
  final String moduleId;
  final String moduleTitle;
  final bool isCompleted;
  final double? score;
  final Duration timeSpent;
  final DateTime? completedAt;

  ModuleProgress({
    required this.moduleId,
    required this.moduleTitle,
    this.isCompleted = false,
    this.score,
    this.timeSpent = Duration.zero,
    this.completedAt,
  });

  factory ModuleProgress.fromJson(Map<String, dynamic> json) {
    return ModuleProgress(
      moduleId: json['module_id'],
      moduleTitle: json['module_title'],
      isCompleted: json['is_completed'] ?? false,
      score: json['score']?.toDouble(),
      timeSpent: Duration(seconds: json['time_spent_seconds'] ?? 0),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module_id': moduleId,
      'module_title': moduleTitle,
      'is_completed': isCompleted,
      'score': score,
      'time_spent_seconds': timeSpent.inSeconds,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}