import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import '../models/video_lesson.dart';
import '../models/course_module.dart';
import '../services/storage_service.dart';
import '../services/enhanced_localization_service.dart';
import 'dart:async';

/// Comprehensive video player widget with HLS streaming and progress tracking
/// Supports offline downloads, multiple qualities, subtitles, and resume functionality
class VideoPlayerWidget extends StatefulWidget {
  final VideoLesson? videoLesson;
  final CourseModule? module; // For backward compatibility
  final String userId;
  final String preferredLanguage;
  final Function(VideoProgress progress)? onProgressUpdate;
  final Function(double)? onProgressChanged; // Legacy support
  final Function()? onVideoCompleted;
  final Function()? onCompleted; // Legacy support
  final Function(String error)? onError;
  final bool allowOfflineDownload;
  final bool autoPlay;
  final String languageCode;

  const VideoPlayerWidget({
    Key? key,
    this.videoLesson,
    this.module,
    this.userId = '',
    this.preferredLanguage = 'en',
    this.languageCode = 'en',
    this.onProgressUpdate,
    this.onProgressChanged,
    this.onVideoCompleted,
    this.onCompleted,
    this.onError,
    this.allowOfflineDownload = true,
    this.autoPlay = false,
  }) : super(key: key);

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService.instance;
  
  // Player controllers
  BetterPlayerController? _betterPlayerController;
  BetterPlayerDataSource? _dataSource;
  
  // Video state
  VideoContent? _currentVideoContent;
  VideoQuality _currentQuality = VideoQuality.p720;
  double _playbackSpeed = 1.0;
  bool _isPlayerReady = false;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Legacy compatibility
  bool _isPlaying = false;
  bool _showControls = true;
  double _progress = 0.0;
  double _volume = 1.0;
  bool _isFullscreen = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _videoUrl;
  
  // Progress tracking
  VideoProgress? _currentProgress;
  Timer? _progressTimer;
  int _lastReportedPosition = 0;
  
  // Download state
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isDownloaded = false;
  String? _downloadPath;
  
  // UI state
  Timer? _controlsTimer;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsOpacity;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for controls
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _controlsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controlsAnimationController, curve: Curves.easeInOut),
    );
    
    _controlsAnimationController.forward();
    
    // Initialize video player
    if (widget.videoLesson != null) {
      _initializeModernPlayer();
    } else if (widget.module != null) {
      _initializeLegacyPlayer();
    }
    
    // Check download status
    if (widget.videoLesson != null) {
      _checkDownloadStatus();
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    _progressTimer?.cancel();
    _controlsTimer?.cancel();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  /// Initialize modern video player with VideoLesson
  Future<void> _initializeModernPlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get best video content for user's preferred language
      _currentVideoContent = widget.videoLesson!.getBestVideoContent(
        widget.preferredLanguage,
        preferredQuality: _currentQuality,
      );

      if (_currentVideoContent == null) {
        throw Exception('No video content available');
      }

      // Use HLS stream if available, otherwise fallback to raw video
      String videoUrl = _currentVideoContent!.streamingUrl;
      
      // Get signed URL for secure streaming
      final signedUrl = await _storageService.getVideoStreamingUrl(videoUrl);
      if (signedUrl != null) {
        videoUrl = signedUrl;
      }

      // Configure player data source
      _dataSource = BetterPlayerDataSource(
        _currentVideoContent!.hlsUrl != null 
            ? BetterPlayerDataSourceType.network
            : BetterPlayerDataSourceType.network,
        videoUrl,
        subtitles: _buildSubtitlesList(),
        videoFormat: _currentVideoContent!.hlsUrl != null 
            ? BetterPlayerVideoFormat.hls
            : BetterPlayerVideoFormat.other,
      );

      // Configure player
      final betterPlayerConfiguration = BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: widget.autoPlay,
        looping: false,
        allowedScreenSleep: false,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        systemOverlaysAfterFullScreen: SystemUiOverlay.values,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enablePlayPause: true,
          enableMute: true,
          enableFullscreen: true,
          enablePip: true,
          enableSkips: false,
          enableProgressBar: true,
          enableProgressText: true,
          enableAudioTracks: true,
          enableSubtitles: true,
          enableQualities: true,
          showControlsOnInitialize: true,
          controlBarColor: Color(0xCC000000),
          progressBarPlayedColor: Color(0xFFB71C1C),
          progressBarHandleColor: Color(0xFFB71C1C),
        ),
      );

      _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: _dataSource,
      );

      // Setup event listeners
      _betterPlayerController!.addEventsListener(_onPlayerEvent);
      
      // Resume from last position if available
      if (widget.videoLesson!.progress != null) {
        await _betterPlayerController!.seekTo(
          Duration(seconds: widget.videoLesson!.progress!.currentPositionSeconds),
        );
      }

      // Start progress tracking
      _startProgressTracking();

      setState(() {
        _isPlayerReady = true;
        _isLoading = false;
        _totalDuration = Duration(seconds: widget.videoLesson!.durationSeconds);
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      widget.onError?.call(e.toString());
    }
  }

  /// Initialize legacy player for CourseModule compatibility
  void _initializeLegacyPlayer() {
    setState(() {
      _isLoading = true;
    });

    // Get video URL for current language or fallback to English
    _videoUrl = widget.module!.getContentForLanguage(widget.languageCode);
    
    if (_videoUrl != null) {
      // Simulate video loading
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _totalDuration = Duration(minutes: widget.module!.estimatedDurationMinutes);
          });
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Build subtitles list for the player
  List<BetterPlayerSubtitlesSource> _buildSubtitlesList() {
    if (widget.videoLesson == null) return [];
    
    final subtitles = <BetterPlayerSubtitlesSource>[];
    
    for (final entry in widget.videoLesson!.subtitles.entries) {
      subtitles.add(
        BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.network,
          name: _getLanguageName(entry.key),
          urls: [entry.value],
        ),
      );
    }
    
    return subtitles;
  }

  /// Get language display name
  String _getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'ar': return 'العربية';
      case 'fr': return 'Français';
      case 'es': return 'Español';
      default: return code.toUpperCase();
    }
  }

  /// Handle player events
  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        setState(() {
          _isPlayerReady = true;
        });
        break;
        
      case BetterPlayerEventType.play:
        setState(() {
          _isPlaying = true;
        });
        _hideControlsAfterDelay();
        break;
        
      case BetterPlayerEventType.pause:
        setState(() {
          _isPlaying = false;
        });
        _showControls = true;
        _controlsAnimationController.forward();
        _controlsTimer?.cancel();
        break;
        
      case BetterPlayerEventType.finished:
        _onVideoFinished();
        break;
        
      case BetterPlayerEventType.exception:
        setState(() {
          _errorMessage = 'Video playback error occurred';
        });
        break;
        
      default:
        break;
    }
  }

  /// Start progress tracking
  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_betterPlayerController?.isVideoInitialized() == true) {
        _updateProgress();
      } else if (widget.module != null && _isPlaying) {
        _simulateProgress();
      }
    });
  }

  /// Update video progress for modern player
  void _updateProgress() {
    final position = _betterPlayerController?.videoPlayerController?.value.position;
    final duration = _betterPlayerController?.videoPlayerController?.value.duration;
    
    if (position != null && duration != null) {
      final currentSeconds = position.inSeconds;
      final totalSeconds = duration.inSeconds;
      
      setState(() {
        _currentPosition = position;
        _totalDuration = duration;
        _progress = totalSeconds > 0 ? currentSeconds / totalSeconds : 0.0;
      });
      
      // Only update if position changed significantly (avoid spam)
      if ((currentSeconds - _lastReportedPosition).abs() >= 2) {
        _lastReportedPosition = currentSeconds;
        
        final completionPercentage = totalSeconds > 0 
            ? (currentSeconds / totalSeconds) * 100 
            : 0.0;
            
        final progress = VideoProgress(
          id: widget.videoLesson!.progress?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
          userId: widget.userId,
          lessonId: widget.videoLesson!.id,
          currentPositionSeconds: currentSeconds,
          watchTimeSeconds: (widget.videoLesson!.progress?.watchTimeSeconds ?? 0) + 2,
          completionPercentage: completionPercentage,
          isCompleted: completionPercentage >= 90, // Consider 90% as completed
          playbackQuality: _currentQuality.value,
          playbackSpeed: _playbackSpeed,
          lastWatchedAt: DateTime.now(),
          createdAt: widget.videoLesson!.progress?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        setState(() {
          _currentProgress = progress;
        });
        
        widget.onProgressUpdate?.call(progress);
        widget.onProgressChanged?.call(completionPercentage);
      }
    }
  }

  /// Legacy progress simulation
  void _simulateProgress() {
    if (!_isPlaying) return;

    setState(() {
      _currentPosition = Duration(
        milliseconds: _currentPosition.inMilliseconds + 2000,
      );
      
      if (_totalDuration.inMilliseconds > 0) {
        _progress = _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
        _progress = _progress.clamp(0.0, 1.0);
      }
    });

    widget.onProgressChanged?.call(_progress * 100);

    if (_progress >= 1.0) {
      _onVideoCompleted();
    }
  }

  /// Handle video completion
  void _onVideoFinished() {
    if (_currentProgress != null) {
      final completedProgress = _currentProgress!.copyWith(
        completionPercentage: 100.0,
        isCompleted: true,
      );
      
      widget.onProgressUpdate?.call(completedProgress);
    }
    
    setState(() {
      _isPlaying = false;
      _progress = 1.0;
    });
    
    widget.onVideoCompleted?.call();
    widget.onCompleted?.call();
  }

  /// Legacy methods for backward compatibility
  void _togglePlayPause() {
    if (_betterPlayerController != null) {
      if (_isPlaying) {
        _betterPlayerController!.pause();
      } else {
        _betterPlayerController!.play();
      }
    } else {
      setState(() {
        _isPlaying = !_isPlaying;
      });

      if (_isPlaying) {
        _simulateProgress();
      }
    }
  }

  void _onVideoCompleted() {
    setState(() {
      _isPlaying = false;
      _progress = 1.0;
    });
    widget.onCompleted?.call();
  }

  void _seekTo(double value) {
    if (_betterPlayerController != null) {
      final newPosition = Duration(
        milliseconds: (_totalDuration.inMilliseconds * value).round(),
      );
      _betterPlayerController!.seekTo(newPosition);
    } else {
      setState(() {
        _progress = value;
        _currentPosition = Duration(
          milliseconds: (_totalDuration.inMilliseconds * value).round(),
        );
      });
    }
  }

  void _toggleFullscreen() {
    if (_betterPlayerController != null) {
      _betterPlayerController!.toggleFullScreen();
    } else {
      setState(() {
        _isFullscreen = !_isFullscreen;
      });
    }
  }

  /// Show/hide player controls
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls) {
      _controlsAnimationController.forward();
      _hideControlsAfterDelay();
    } else {
      _controlsAnimationController.reverse();
      _controlsTimer?.cancel();
    }
  }

  /// Hide controls after delay
  void _hideControlsAfterDelay() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying) {
        setState(() {
          _showControls = false;
        });
        _controlsAnimationController.reverse();
      }
    });
  }

  /// Download video for offline viewing
  Future<void> _downloadVideo() async {
    if (_isDownloading || _isDownloaded || widget.videoLesson == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final downloadPath = await _storageService.downloadVideoForOffline(
        videoUrl: _currentVideoContent!.rawVideoUrl,
        lessonId: widget.videoLesson!.id,
        userId: widget.userId,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      if (downloadPath != null) {
        setState(() {
          _isDownloaded = true;
          _downloadPath = downloadPath;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video downloaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  /// Check if video is already downloaded
  Future<void> _checkDownloadStatus() async {
    if (widget.videoLesson == null) return;
    
    final progress = await _storageService.getDownloadProgress(widget.videoLesson!.id);
    setState(() {
      _isDownloaded = progress >= 100.0;
      _downloadProgress = progress;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (widget.videoLesson != null && !widget.videoLesson!.isReadyForPlayback) {
      return _buildProcessingWidget();
    }

    if (_videoUrl == null && widget.module != null) {
      return _buildErrorState();
    }

    return _buildVideoPlayer();
  }

  /// Build loading widget
  Widget _buildLoadingState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
            ),
            const SizedBox(height: 16),
            Text(
              EnhancedLocalizationService.t('loading'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              EnhancedLocalizationService.t('error'),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Video not available',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.videoLesson != null 
                  ? _initializeModernPlayer 
                  : _initializeLegacyPlayer,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build processing widget
  Widget _buildProcessingWidget() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Video Processing',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${widget.videoLesson!.processingStatus.value}',
              style: const TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your video is being processed and will be available soon.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build main video player
  Widget _buildVideoPlayer() {
    final isModernPlayer = _betterPlayerController != null && _isPlayerReady;
    
    return Column(
      children: [
        // Video player container
        Container(
          height: _isFullscreen ? MediaQuery.of(context).size.height : 300,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(12),
            child: Stack(
              children: [
                // Modern video player
                if (isModernPlayer)
                  BetterPlayer(controller: _betterPlayerController!),
                
                // Legacy video placeholder
                if (!isModernPlayer) _buildLegacyVideoPlaceholder(),
                
                // Custom controls overlay for modern player
                if (isModernPlayer && _showControls) _buildCustomControls(),
                
                // Legacy controls
                if (!isModernPlayer && (_showControls || !_isPlaying))
                  _buildLegacyVideoControls(),
                
                // Tap detector for showing/hiding controls
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _toggleControls,
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Video controls and info for modern player
        if (widget.videoLesson != null) ...[
          const SizedBox(height: 16),
          _buildVideoControlsSection(),
        ],
      ],
    );
  }

  /// Build legacy video placeholder
  Widget _buildLegacyVideoPlaceholder() {
    return Center(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[900]!,
              Colors.grey[700]!,
            ],
          ),
          borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              widget.module?.title ?? widget.videoLesson?.title ?? 'Video Content',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(_totalDuration),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build custom controls overlay for modern player
  Widget _buildCustomControls() {
    return AnimatedBuilder(
      animation: _controlsOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: _controlsOpacity.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top controls
                  Row(
                    children: [
                      Text(
                        widget.videoLesson!.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (widget.allowOfflineDownload) _buildDownloadButton(),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Bottom controls
                  Row(
                    children: [
                      Text(
                        widget.videoLesson!.formattedDuration,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      if (_currentProgress != null)
                        Text(
                          '${_currentProgress!.completionPercentage.toStringAsFixed(0)}% completed',
                          style: const TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build download button
  Widget _buildDownloadButton() {
    if (_isDownloading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          value: _downloadProgress / 100,
          strokeWidth: 2,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_isDownloaded) {
      return const Icon(Icons.download_done, color: Colors.green);
    }

    return IconButton(
      icon: const Icon(Icons.download, color: Colors.white),
      onPressed: _downloadVideo,
    );
  }

  /// Build video controls section for modern player
  Widget _buildVideoControlsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quality and speed controls
            if (widget.videoLesson!.getAvailableQualities(widget.preferredLanguage).isNotEmpty)
              Row(
                children: [
                  // Quality selector
                  const Text('Quality: '),
                  DropdownButton<VideoQuality>(
                    value: _currentQuality,
                    items: widget.videoLesson!.getAvailableQualities(widget.preferredLanguage)
                        .map((quality) => DropdownMenuItem(
                              value: quality,
                              child: Text(quality.value),
                            ))
                        .toList(),
                    onChanged: (quality) {
                      if (quality != null) {
                        setState(() {
                          _currentQuality = quality;
                        });
                        // Quality change would be implemented here
                      }
                    },
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // Speed selector
                  const Text('Speed: '),
                  DropdownButton<double>(
                    value: _playbackSpeed,
                    items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                        .map((speed) => DropdownMenuItem(
                              value: speed,
                              child: Text('${speed}x'),
                            ))
                        .toList(),
                    onChanged: (speed) {
                      if (speed != null) {
                        setState(() {
                          _playbackSpeed = speed;
                        });
                        _betterPlayerController?.setSpeed(speed);
                      }
                    },
                  ),
                ],
              ),
            
            // Progress info
            if (_currentProgress != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _currentProgress!.completionPercentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress: ${_currentProgress!.completionPercentage.toStringAsFixed(1)}%'),
                  Text('Watch time: ${Duration(seconds: _currentProgress!.watchTimeSeconds).toString().split('.').first}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build legacy video controls
  Widget _buildLegacyVideoControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Top controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.module?.title ?? 'Video',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFullscreen,
                      tooltip: EnhancedLocalizationService.t('fullscreen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Center play/pause button
          Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFB71C1C).withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress bar
                Row(
                  children: [
                    Text(
                      _formatDuration(_currentPosition),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFFB71C1C),
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: const Color(0xFFB71C1C),
                          overlayColor: const Color(0xFFB71C1C).withOpacity(0.3),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: _progress,
                          onChanged: _seekTo,
                          min: 0.0,
                          max: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(_totalDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Bottom button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white),
                          onPressed: () {
                            _seekTo((_progress - 0.1).clamp(0.0, 1.0));
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white),
                          onPressed: () {
                            _seekTo((_progress + 0.1).clamp(0.0, 1.0));
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _volume > 0 ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _volume = _volume > 0 ? 0 : 1.0;
                            });
                          },
                        ),
                        Text(
                          '${(_progress * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}