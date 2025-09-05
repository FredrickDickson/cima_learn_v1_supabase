import 'package:flutter/foundation.dart';

/// Comprehensive video lesson model for the Udemy-like platform
/// Supports HLS streaming, progress tracking, and multi-language content
class VideoLesson {
  final String id;
  final String moduleId;
  final String courseId;
  final String title;
  final String description;
  final int orderIndex;
  final int durationSeconds;
  final String? thumbnailUrl;
  final Map<String, VideoContent> videoContent; // language -> video content
  final Map<String, String> subtitles; // language -> subtitle URL
  final VideoProcessingStatus processingStatus;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // User-specific data
  final VideoProgress? progress;
  final bool isDownloaded;
  final String? downloadPath;

  const VideoLesson({
    required this.id,
    required this.moduleId,
    required this.courseId,
    required this.title,
    this.description = '',
    required this.orderIndex,
    this.durationSeconds = 0,
    this.thumbnailUrl,
    this.videoContent = const {},
    this.subtitles = const {},
    this.processingStatus = VideoProcessingStatus.pending,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.progress,
    this.isDownloaded = false,
    this.downloadPath,
  });

  factory VideoLesson.fromJson(Map<String, dynamic> json) {
    return VideoLesson(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      orderIndex: json['order_index'] as int,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoContent: (json['video_content'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, VideoContent.fromJson(value)))
          ?? {},
      subtitles: Map<String, String>.from(json['subtitles'] as Map? ?? {}),
      processingStatus: VideoProcessingStatus.fromString(
        json['processing_status'] as String? ?? 'pending'
      ),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      progress: json['progress'] != null 
          ? VideoProgress.fromJson(json['progress'])
          : null,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
      downloadPath: json['download_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'order_index': orderIndex,
      'duration_seconds': durationSeconds,
      'thumbnail_url': thumbnailUrl,
      'video_content': videoContent.map((key, value) => MapEntry(key, value.toJson())),
      'subtitles': subtitles,
      'processing_status': processingStatus.value,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get video content for a specific language and quality
  VideoContent? getVideoContent(String language, {VideoQuality? quality}) {
    final content = videoContent[language];
    if (content == null) return null;
    
    if (quality != null) {
      return content.qualities[quality];
    }
    
    // Return highest quality available
    if (content.qualities.isNotEmpty) {
      final qualities = content.qualities.keys.toList()
        ..sort((a, b) => b.resolution.compareTo(a.resolution));
      return content.qualities[qualities.first];
    }
    
    return content;
  }

  /// Get the best available video content with fallbacks
  VideoContent? getBestVideoContent(String preferredLanguage, {VideoQuality? preferredQuality}) {
    // Try preferred language first
    var content = getVideoContent(preferredLanguage, quality: preferredQuality);
    if (content != null) return content;
    
    // Fallback to English
    content = getVideoContent('en', quality: preferredQuality);
    if (content != null) return content;
    
    // Fallback to any available language
    if (videoContent.isNotEmpty) {
      final firstLanguage = videoContent.keys.first;
      return getVideoContent(firstLanguage, quality: preferredQuality);
    }
    
    return null;
  }

  /// Get subtitle URL for a language
  String? getSubtitleUrl(String language) {
    return subtitles[language] ?? subtitles['en'];
  }

  /// Get available languages for this video
  List<String> getAvailableLanguages() {
    return videoContent.keys.toList();
  }

  /// Get available qualities for a language
  List<VideoQuality> getAvailableQualities(String language) {
    final content = videoContent[language];
    return content?.qualities.keys.toList() ?? [];
  }

  /// Check if video is ready for playback
  bool get isReadyForPlayback {
    return processingStatus == VideoProcessingStatus.completed &&
           videoContent.isNotEmpty;
  }

  /// Get formatted duration
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Create copy with updated progress
  VideoLesson copyWithProgress(VideoProgress progress) {
    return VideoLesson(
      id: id,
      moduleId: moduleId,
      courseId: courseId,
      title: title,
      description: description,
      orderIndex: orderIndex,
      durationSeconds: durationSeconds,
      thumbnailUrl: thumbnailUrl,
      videoContent: videoContent,
      subtitles: subtitles,
      processingStatus: processingStatus,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      progress: progress,
      isDownloaded: isDownloaded,
      downloadPath: downloadPath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoLesson && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VideoLesson(id: $id, title: $title)';
}

/// Video content for specific language and quality
class VideoContent {
  final String rawVideoUrl;
  final String? hlsUrl;
  final String? dashUrl;
  final Map<VideoQuality, VideoContent> qualities;
  final VideoFormat format;
  final int bitrate;
  final String resolution;
  final double fileSize; // in MB

  const VideoContent({
    required this.rawVideoUrl,
    this.hlsUrl,
    this.dashUrl,
    this.qualities = const {},
    this.format = VideoFormat.mp4,
    this.bitrate = 0,
    this.resolution = '720p',
    this.fileSize = 0.0,
  });

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    return VideoContent(
      rawVideoUrl: json['raw_video_url'] as String,
      hlsUrl: json['hls_url'] as String?,
      dashUrl: json['dash_url'] as String?,
      qualities: (json['qualities'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(
              VideoQuality.fromString(key),
              VideoContent.fromJson(value)))
          ?? {},
      format: VideoFormat.fromString(json['format'] as String? ?? 'mp4'),
      bitrate: json['bitrate'] as int? ?? 0,
      resolution: json['resolution'] as String? ?? '720p',
      fileSize: (json['file_size'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raw_video_url': rawVideoUrl,
      'hls_url': hlsUrl,
      'dash_url': dashUrl,
      'qualities': qualities.map((key, value) => MapEntry(key.value, value.toJson())),
      'format': format.value,
      'bitrate': bitrate,
      'resolution': resolution,
      'file_size': fileSize,
    };
  }

  /// Get the best streaming URL (prefers HLS, then DASH, then raw)
  String get streamingUrl => hlsUrl ?? dashUrl ?? rawVideoUrl;
}

/// Video progress tracking model
class VideoProgress {
  final String id;
  final String userId;
  final String lessonId;
  final int currentPositionSeconds;
  final int watchTimeSeconds;
  final double completionPercentage;
  final bool isCompleted;
  final String playbackQuality;
  final double playbackSpeed;
  final DateTime lastWatchedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VideoProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    this.currentPositionSeconds = 0,
    this.watchTimeSeconds = 0,
    this.completionPercentage = 0.0,
    this.isCompleted = false,
    this.playbackQuality = '720p',
    this.playbackSpeed = 1.0,
    required this.lastWatchedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoProgress.fromJson(Map<String, dynamic> json) {
    return VideoProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String,
      currentPositionSeconds: json['current_position_seconds'] as int? ?? 0,
      watchTimeSeconds: json['watch_time_seconds'] as int? ?? 0,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['is_completed'] as bool? ?? false,
      playbackQuality: json['playback_quality'] as String? ?? '720p',
      playbackSpeed: (json['playback_speed'] as num?)?.toDouble() ?? 1.0,
      lastWatchedAt: DateTime.parse(json['last_watched_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'current_position_seconds': currentPositionSeconds,
      'watch_time_seconds': watchTimeSeconds,
      'completion_percentage': completionPercentage,
      'is_completed': isCompleted,
      'playback_quality': playbackQuality,
      'playback_speed': playbackSpeed,
      'last_watched_at': lastWatchedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create copy with updated position
  VideoProgress copyWith({
    int? currentPositionSeconds,
    int? watchTimeSeconds,
    double? completionPercentage,
    bool? isCompleted,
    String? playbackQuality,
    double? playbackSpeed,
  }) {
    return VideoProgress(
      id: id,
      userId: userId,
      lessonId: lessonId,
      currentPositionSeconds: currentPositionSeconds ?? this.currentPositionSeconds,
      watchTimeSeconds: watchTimeSeconds ?? this.watchTimeSeconds,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
      playbackQuality: playbackQuality ?? this.playbackQuality,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      lastWatchedAt: DateTime.now(),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Video processing status
enum VideoProcessingStatus {
  pending('pending'),
  uploading('uploading'),
  processing('processing'),
  transcoding('transcoding'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const VideoProcessingStatus(this.value);
  final String value;

  static VideoProcessingStatus fromString(String value) {
    return VideoProcessingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VideoProcessingStatus.pending,
    );
  }

  bool get isProcessing => this == VideoProcessingStatus.processing || 
                          this == VideoProcessingStatus.transcoding ||
                          this == VideoProcessingStatus.uploading;
}

/// Video quality levels
enum VideoQuality {
  p144('144p', 144),
  p240('240p', 240),
  p360('360p', 360),
  p480('480p', 480),
  p720('720p', 720),
  p1080('1080p', 1080),
  p1440('1440p', 1440),
  p2160('2160p', 2160);

  const VideoQuality(this.value, this.resolution);
  final String value;
  final int resolution;

  static VideoQuality fromString(String value) {
    return VideoQuality.values.firstWhere(
      (quality) => quality.value == value,
      orElse: () => VideoQuality.p720,
    );
  }
}

/// Video formats
enum VideoFormat {
  mp4('mp4'),
  webm('webm'),
  mov('mov'),
  avi('avi'),
  hls('m3u8'),
  dash('mpd');

  const VideoFormat(this.value);
  final String value;

  static VideoFormat fromString(String value) {
    return VideoFormat.values.firstWhere(
      (format) => format.value == value,
      orElse: () => VideoFormat.mp4,
    );
  }
}

/// Upload progress tracking
class UploadProgress {
  final String uploadId;
  final String fileName;
  final double progressPercentage;
  final int uploadedBytes;
  final int totalBytes;
  final UploadStatus status;
  final String? errorMessage;
  final DateTime startedAt;
  final DateTime? completedAt;

  const UploadProgress({
    required this.uploadId,
    required this.fileName,
    this.progressPercentage = 0.0,
    this.uploadedBytes = 0,
    this.totalBytes = 0,
    this.status = UploadStatus.pending,
    this.errorMessage,
    required this.startedAt,
    this.completedAt,
  });

  String get formattedSize {
    return '${(uploadedBytes / 1024 / 1024).toStringAsFixed(1)} MB / ${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  Duration? get estimatedTimeRemaining {
    if (progressPercentage == 0 || status == UploadStatus.completed) return null;
    
    final elapsed = DateTime.now().difference(startedAt);
    final remainingPercentage = 100 - progressPercentage;
    final timePerPercent = elapsed.inSeconds / progressPercentage;
    
    return Duration(seconds: (remainingPercentage * timePerPercent).round());
  }
}

enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
  cancelled,
  paused,
}