import 'package:equatable/equatable.dart';

/// Video events for the VideoBloc
sealed class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize video player with a video URL
class VideoInitializeRequested extends VideoEvent {
  const VideoInitializeRequested({
    required this.videoUrl,
    required this.courseId,
    required this.lessonId,
    required this.userId,
    this.startPosition,
  });

  final String videoUrl;
  final String courseId;
  final String lessonId;
  final String userId;
  final Duration? startPosition;

  @override
  List<Object?> get props => [videoUrl, courseId, lessonId, userId, startPosition];
}

/// Event to play video
class VideoPlayRequested extends VideoEvent {}

/// Event to pause video
class VideoPauseRequested extends VideoEvent {}

/// Event to seek to a specific position
class VideoSeekRequested extends VideoEvent {
  const VideoSeekRequested({required this.position});

  final Duration position;

  @override
  List<Object> get props => [position];
}

/// Event to change video playback speed
class VideoSpeedChanged extends VideoEvent {
  const VideoSpeedChanged({required this.speed});

  final double speed;

  @override
  List<Object> get props => [speed];
}

/// Event to change video quality
class VideoQualityChanged extends VideoEvent {
  const VideoQualityChanged({required this.quality});

  final String quality;

  @override
  List<Object> get props => [quality];
}

/// Event to toggle fullscreen mode
class VideoFullscreenToggled extends VideoEvent {}

/// Event to update video progress
class VideoProgressUpdated extends VideoEvent {
  const VideoProgressUpdated({
    required this.position,
    required this.duration,
  });

  final Duration position;
  final Duration duration;

  @override
  List<Object> get props => [position, duration];
}

/// Event when video playback completes
class VideoCompleted extends VideoEvent {}

/// Event to save video progress to database
class VideoProgressSaved extends VideoEvent {
  const VideoProgressSaved({
    required this.courseId,
    required this.lessonId,
    required this.userId,
    required this.position,
    required this.duration,
    required this.isCompleted,
  });

  final String courseId;
  final String lessonId;
  final String userId;
  final Duration position;
  final Duration duration;
  final bool isCompleted;

  @override
  List<Object> get props => [courseId, lessonId, userId, position, duration, isCompleted];
}

/// Event to load video progress from database
class VideoProgressLoaded extends VideoEvent {
  const VideoProgressLoaded({
    required this.courseId,
    required this.lessonId,
    required this.userId,
  });

  final String courseId;
  final String lessonId;
  final String userId;

  @override
  List<Object> get props => [courseId, lessonId, userId];
}

/// Event to handle video buffering
class VideoBuffering extends VideoEvent {
  const VideoBuffering({required this.isBuffering});

  final bool isBuffering;

  @override
  List<Object> get props => [isBuffering];
}

/// Event to handle video error
class VideoErrorOccurred extends VideoEvent {
  const VideoErrorOccurred({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

/// Event to dispose video player
class VideoDisposeRequested extends VideoEvent {}

/// Event to toggle captions/subtitles
class VideoCaptionsToggled extends VideoEvent {
  const VideoCaptionsToggled({required this.isEnabled});

  final bool isEnabled;

  @override
  List<Object> get props => [isEnabled];
}

/// Event to change audio track
class VideoAudioTrackChanged extends VideoEvent {
  const VideoAudioTrackChanged({required this.trackId});

  final String trackId;

  @override
  List<Object> get props => [trackId];
}

/// Event to load video metadata
class VideoMetadataLoaded extends VideoEvent {
  const VideoMetadataLoaded({
    required this.duration,
    required this.size,
    required this.quality,
  });

  final Duration duration;
  final Size size;
  final String quality;

  @override
  List<Object> get props => [duration, size, quality];
}

class Size {
  final double width;
  final double height;
  
  const Size(this.width, this.height);
  
  @override
  String toString() => 'Size($width, $height)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Size && runtimeType == other.runtimeType && width == other.width && height == other.height;
  
  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}