import 'package:equatable/equatable.dart';
import 'video_event.dart';

/// Video states for the VideoBloc
sealed class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class VideoInitial extends VideoState {}

/// State when video is being initialized
class VideoInitializing extends VideoState {}

/// State when video is ready to play
class VideoReady extends VideoState {
  const VideoReady({
    required this.duration,
    required this.videoSize,
    required this.availableQualities,
    required this.currentQuality,
  });

  final Duration duration;
  final Size videoSize;
  final List<String> availableQualities;
  final String currentQuality;

  @override
  List<Object> get props => [duration, videoSize, availableQualities, currentQuality];
}

/// State when video is playing
class VideoPlaying extends VideoState {
  const VideoPlaying({
    required this.position,
    required this.duration,
    required this.speed,
    required this.isFullscreen,
    required this.quality,
    this.isBuffering = false,
    this.isCaptionsEnabled = false,
  });

  final Duration position;
  final Duration duration;
  final double speed;
  final bool isFullscreen;
  final String quality;
  final bool isBuffering;
  final bool isCaptionsEnabled;

  @override
  List<Object> get props => [
    position, duration, speed, isFullscreen, quality, isBuffering, isCaptionsEnabled
  ];

  VideoPlaying copyWith({
    Duration? position,
    Duration? duration,
    double? speed,
    bool? isFullscreen,
    String? quality,
    bool? isBuffering,
    bool? isCaptionsEnabled,
  }) {
    return VideoPlaying(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      quality: quality ?? this.quality,
      isBuffering: isBuffering ?? this.isBuffering,
      isCaptionsEnabled: isCaptionsEnabled ?? this.isCaptionsEnabled,
    );
  }
}

/// State when video is paused
class VideoPaused extends VideoState {
  const VideoPaused({
    required this.position,
    required this.duration,
    required this.speed,
    required this.isFullscreen,
    required this.quality,
    this.isCaptionsEnabled = false,
  });

  final Duration position;
  final Duration duration;
  final double speed;
  final bool isFullscreen;
  final String quality;
  final bool isCaptionsEnabled;

  @override
  List<Object> get props => [
    position, duration, speed, isFullscreen, quality, isCaptionsEnabled
  ];

  VideoPaused copyWith({
    Duration? position,
    Duration? duration,
    double? speed,
    bool? isFullscreen,
    String? quality,
    bool? isCaptionsEnabled,
  }) {
    return VideoPaused(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      quality: quality ?? this.quality,
      isCaptionsEnabled: isCaptionsEnabled ?? this.isCaptionsEnabled,
    );
  }
}

/// State when video is buffering
class VideoBuffering extends VideoState {
  const VideoBuffering({
    required this.position,
    required this.duration,
    required this.speed,
    required this.isFullscreen,
    required this.quality,
    this.isCaptionsEnabled = false,
  });

  final Duration position;
  final Duration duration;
  final double speed;
  final bool isFullscreen;
  final String quality;
  final bool isCaptionsEnabled;

  @override
  List<Object> get props => [
    position, duration, speed, isFullscreen, quality, isCaptionsEnabled
  ];
}

/// State when video playback is completed
class VideoCompleted extends VideoState {
  const VideoCompleted({
    required this.duration,
    required this.isFullscreen,
    required this.quality,
    this.progressSaved = false,
  });

  final Duration duration;
  final bool isFullscreen;
  final String quality;
  final bool progressSaved;

  @override
  List<Object> get props => [duration, isFullscreen, quality, progressSaved];
}

/// State when video progress is being saved
class VideoProgressSaving extends VideoState {
  const VideoProgressSaving({
    required this.position,
    required this.duration,
  });

  final Duration position;
  final Duration duration;

  @override
  List<Object> get props => [position, duration];
}

/// State when video progress is successfully saved
class VideoProgressSaved extends VideoState {
  const VideoProgressSaved({
    required this.position,
    required this.duration,
    required this.progressPercentage,
  });

  final Duration position;
  final Duration duration;
  final double progressPercentage;

  @override
  List<Object> get props => [position, duration, progressPercentage];
}

/// State when video encounters an error
class VideoError extends VideoState {
  const VideoError({
    required this.message,
    this.isRecoverable = false,
  });

  final String message;
  final bool isRecoverable;

  @override
  List<Object> get props => [message, isRecoverable];
}

/// State when video is seeking to a new position
class VideoSeeking extends VideoState {
  const VideoSeeking({
    required this.targetPosition,
    required this.currentPosition,
    required this.duration,
  });

  final Duration targetPosition;
  final Duration currentPosition;
  final Duration duration;

  @override
  List<Object> get props => [targetPosition, currentPosition, duration];
}

/// State when video quality is being changed
class VideoQualityChanging extends VideoState {
  const VideoQualityChanging({
    required this.currentQuality,
    required this.targetQuality,
    required this.position,
  });

  final String currentQuality;
  final String targetQuality;
  final Duration position;

  @override
  List<Object> get props => [currentQuality, targetQuality, position];
}