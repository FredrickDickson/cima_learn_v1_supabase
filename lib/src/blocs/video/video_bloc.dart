import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import 'video_event.dart';
import 'video_state.dart';

/// Video BLoC managing video playback, progress tracking, and streaming
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc() : super(VideoInitial()) {
    // Register event handlers
    on<VideoInitializeRequested>(_onVideoInitializeRequested);
    on<VideoPlayRequested>(_onVideoPlayRequested);
    on<VideoPauseRequested>(_onVideoPauseRequested);
    on<VideoSeekRequested>(_onVideoSeekRequested);
    on<VideoSpeedChanged>(_onVideoSpeedChanged);
    on<VideoQualityChanged>(_onVideoQualityChanged);
    on<VideoFullscreenToggled>(_onVideoFullscreenToggled);
    on<VideoProgressUpdated>(_onVideoProgressUpdated);
    on<VideoCompleted>(_onVideoCompleted);
    on<VideoProgressSaved>(_onVideoProgressSaved);
    on<VideoProgressLoaded>(_onVideoProgressLoaded);
    on<VideoBuffering>(_onVideoBuffering);
    on<VideoErrorOccurred>(_onVideoErrorOccurred);
    on<VideoDisposeRequested>(_onVideoDisposeRequested);
    on<VideoCaptionsToggled>(_onVideoCaptionsToggled);
    on<VideoMetadataLoaded>(_onVideoMetadataLoaded);

    // Auto-save progress timer
    _progressTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _autoSaveProgress(),
    );
  }

  Timer? _progressTimer;
  String? _currentCourseId;
  String? _currentLessonId;
  String? _currentUserId;

  @override
  Future<void> close() {
    _progressTimer?.cancel();
    return super.close();
  }

  /// Initialize video player with URL and metadata
  Future<void> _onVideoInitializeRequested(
    VideoInitializeRequested event,
    Emitter<VideoState> emit,
  ) async {
    emit(VideoInitializing());

    try {
      // Store current video context for progress tracking
      _currentCourseId = event.courseId;
      _currentLessonId = event.lessonId;
      _currentUserId = event.userId;

      // Load saved progress
      add(VideoProgressLoaded(
        courseId: event.courseId,
        lessonId: event.lessonId,
        userId: event.userId,
      ));

      // Simulate video initialization (in real app, this would initialize video player)
      await Future.delayed(const Duration(milliseconds: 500));

      // Default video metadata (would come from actual video player)
      const duration = Duration(minutes: 10); // Default duration
      const videoSize = Size(1920, 1080);
      const availableQualities = ['360p', '480p', '720p', '1080p'];
      const currentQuality = '720p';

      emit(VideoReady(
        duration: duration,
        videoSize: videoSize,
        availableQualities: availableQualities,
        currentQuality: currentQuality,
      ));

      // If start position provided, seek to it
      if (event.startPosition != null) {
        add(VideoSeekRequested(position: event.startPosition!));
      }
    } catch (e) {
      emit(VideoError(message: 'Failed to initialize video: $e'));
    }
  }

  /// Handle video play request
  Future<void> _onVideoPlayRequested(
    VideoPlayRequested event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoReady) {
      final readyState = state as VideoReady;
      emit(VideoPlaying(
        position: Duration.zero,
        duration: readyState.duration,
        speed: 1.0,
        isFullscreen: false,
        quality: readyState.currentQuality,
      ));
    } else if (state is VideoPaused) {
      final pausedState = state as VideoPaused;
      emit(VideoPlaying(
        position: pausedState.position,
        duration: pausedState.duration,
        speed: pausedState.speed,
        isFullscreen: pausedState.isFullscreen,
        quality: pausedState.quality,
        isCaptionsEnabled: pausedState.isCaptionsEnabled,
      ));
    }
  }

  /// Handle video pause request
  Future<void> _onVideoPauseRequested(
    VideoPauseRequested event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoPlaying) {
      final playingState = state as VideoPlaying;
      emit(VideoPaused(
        position: playingState.position,
        duration: playingState.duration,
        speed: playingState.speed,
        isFullscreen: playingState.isFullscreen,
        quality: playingState.quality,
        isCaptionsEnabled: playingState.isCaptionsEnabled,
      ));
    }
  }

  /// Handle video seek request
  Future<void> _onVideoSeekRequested(
    VideoSeekRequested event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      emit(VideoSeeking(
        targetPosition: event.position,
        currentPosition: currentState.position,
        duration: currentState.duration,
      ));

      // Simulate seek operation
      await Future.delayed(const Duration(milliseconds: 200));

      emit(VideoPlaying(
        position: event.position,
        duration: currentState.duration,
        speed: currentState.speed,
        isFullscreen: currentState.isFullscreen,
        quality: currentState.quality,
        isCaptionsEnabled: currentState.isCaptionsEnabled,
      ));
    } else if (state is VideoPaused) {
      final currentState = state as VideoPaused;
      emit(VideoPaused(
        position: event.position,
        duration: currentState.duration,
        speed: currentState.speed,
        isFullscreen: currentState.isFullscreen,
        quality: currentState.quality,
        isCaptionsEnabled: currentState.isCaptionsEnabled,
      ));
    }
  }

  /// Handle video speed change
  Future<void> _onVideoSpeedChanged(
    VideoSpeedChanged event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      emit(currentState.copyWith(speed: event.speed));
    } else if (state is VideoPaused) {
      final currentState = state as VideoPaused;
      emit(currentState.copyWith(speed: event.speed));
    }
  }

  /// Handle video quality change
  Future<void> _onVideoQualityChanged(
    VideoQualityChanged event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      emit(VideoQualityChanging(
        currentQuality: currentState.quality,
        targetQuality: event.quality,
        position: currentState.position,
      ));

      // Simulate quality change operation
      await Future.delayed(const Duration(seconds: 1));

      emit(currentState.copyWith(quality: event.quality));
    } else if (state is VideoPaused) {
      final currentState = state as VideoPaused;
      emit(currentState.copyWith(quality: event.quality));
    }
  }

  /// Handle fullscreen toggle
  Future<void> _onVideoFullscreenToggled(
    VideoFullscreenToggled event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      emit(currentState.copyWith(isFullscreen: !currentState.isFullscreen));
    } else if (state is VideoPaused) {
      final currentState = state as VideoPaused;
      emit(currentState.copyWith(isFullscreen: !currentState.isFullscreen));
    }
  }

  /// Handle video progress updates
  Future<void> _onVideoProgressUpdated(
    VideoProgressUpdated event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      emit(currentState.copyWith(
        position: event.position,
        duration: event.duration,
      ));
    }
  }

  /// Handle video completion
  Future<void> _onVideoCompleted(
    VideoCompleted event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      
      // Save completion progress
      if (_currentCourseId != null && _currentLessonId != null && _currentUserId != null) {
        add(VideoProgressSaved(
          courseId: _currentCourseId!,
          lessonId: _currentLessonId!,
          userId: _currentUserId!,
          position: currentState.duration,
          duration: currentState.duration,
          isCompleted: true,
        ));
      }

      emit(VideoCompleted(
        duration: currentState.duration,
        isFullscreen: currentState.isFullscreen,
        quality: currentState.quality,
      ));
    }
  }

  /// Handle video progress saving
  Future<void> _onVideoProgressSaved(
    VideoProgressSaved event,
    Emitter<VideoState> emit,
  ) async {
    try {
      final progressPercentage = event.position.inMilliseconds / event.duration.inMilliseconds;

      // Update lesson progress
      await supabase.from('lesson_progress').upsert({
        'user_id': event.userId,
        'course_id': event.courseId,
        'lesson_id': event.lessonId,
        'position_seconds': event.position.inSeconds,
        'duration_seconds': event.duration.inSeconds,
        'progress_percentage': progressPercentage,
        'is_completed': event.isCompleted,
        'last_watched_at': DateTime.now().toIso8601String(),
      });

      // Update overall course progress
      await _updateCourseProgress(event.courseId, event.userId);

      emit(VideoProgressSaved(
        position: event.position,
        duration: event.duration,
        progressPercentage: progressPercentage,
      ));
    } catch (e) {
      emit(VideoError(message: 'Failed to save progress: $e'));
    }
  }

  /// Load saved video progress
  Future<void> _onVideoProgressLoaded(
    VideoProgressLoaded event,
    Emitter<VideoState> emit,
  ) async {
    try {
      final response = await supabase
          .from('lesson_progress')
          .select('position_seconds, is_completed')
          .eq('user_id', event.userId)
          .eq('course_id', event.courseId)
          .eq('lesson_id', event.lessonId)
          .maybeSingle();

      if (response != null) {
        final positionSeconds = response['position_seconds'] as int? ?? 0;
        final savedPosition = Duration(seconds: positionSeconds);
        
        // Auto-seek to saved position if not at the beginning
        if (savedPosition.inSeconds > 5) {
          add(VideoSeekRequested(position: savedPosition));
        }
      }
    } catch (e) {
      // Silently handle progress loading errors
      print('Failed to load video progress: $e');
    }
  }

  /// Handle video buffering state
  Future<void> _onVideoBuffering(
    VideoBuffering event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      emit(currentState.copyWith(isBuffering: event.isBuffering));
    }
  }

  /// Handle video errors
  Future<void> _onVideoErrorOccurred(
    VideoErrorOccurred event,
    Emitter<VideoState> emit,
  ) async {
    emit(VideoError(
      message: event.error,
      isRecoverable: _isRecoverableError(event.error),
    ));
  }

  /// Handle video disposal
  Future<void> _onVideoDisposeRequested(
    VideoDisposeRequested event,
    Emitter<VideoState> emit,
  ) async {
    // Save current progress before disposing
    await _autoSaveProgress();
    
    _progressTimer?.cancel();
    _currentCourseId = null;
    _currentLessonId = null;
    _currentUserId = null;
    
    emit(VideoInitial());
  }

  /// Handle captions toggle
  Future<void> _onVideoCaptionsToggled(
    VideoCaptionsToggled event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      emit(currentState.copyWith(isCaptionsEnabled: event.isEnabled));
    } else if (state is VideoPaused) {
      final currentState = state as VideoPaused;
      emit(currentState.copyWith(isCaptionsEnabled: event.isEnabled));
    }
  }

  /// Handle video metadata loading
  Future<void> _onVideoMetadataLoaded(
    VideoMetadataLoaded event,
    Emitter<VideoState> emit,
  ) async {
    // This would be called when actual video player loads metadata
    if (state is VideoInitializing) {
      emit(VideoReady(
        duration: event.duration,
        videoSize: event.size,
        availableQualities: ['360p', '480p', '720p', '1080p'],
        currentQuality: event.quality,
      ));
    }
  }

  /// Auto-save progress periodically
  Future<void> _autoSaveProgress() async {
    if (_currentCourseId == null || _currentLessonId == null || _currentUserId == null) {
      return;
    }

    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      add(VideoProgressSaved(
        courseId: _currentCourseId!,
        lessonId: _currentLessonId!,
        userId: _currentUserId!,
        position: currentState.position,
        duration: currentState.duration,
        isCompleted: false,
      ));
    }
  }

  /// Update overall course progress based on lesson completions
  Future<void> _updateCourseProgress(String courseId, String userId) async {
    try {
      // Get total lessons in course
      final lessonsResponse = await supabase
          .from('lessons')
          .select('id')
          .eq('course_id', courseId);

      final totalLessons = lessonsResponse.length;

      if (totalLessons == 0) return;

      // Get completed lessons
      final completedResponse = await supabase
          .from('lesson_progress')
          .select('lesson_id')
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .eq('is_completed', true);

      final completedLessons = completedResponse.length;
      final overallProgress = completedLessons / totalLessons;

      // Update enrollment progress
      await supabase
          .from('enrollments')
          .update({
            'progress': overallProgress,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('course_id', courseId);

    } catch (e) {
      print('Failed to update course progress: $e');
    }
  }

  /// Check if error is recoverable
  bool _isRecoverableError(String error) {
    const recoverableErrors = [
      'network',
      'timeout',
      'buffering',
      'connection',
    ];

    return recoverableErrors.any((keyword) => 
      error.toLowerCase().contains(keyword));
  }
}