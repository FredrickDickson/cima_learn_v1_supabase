import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../models/course_module.dart';
import '../services/enhanced_localization_service.dart';
import '../utils/responsive.dart';

class VideoPlayerWidget extends StatefulWidget {
  final CourseModule module;
  final Function(double)? onProgressChanged;
  final Function()? onCompleted;
  final String languageCode;

  const VideoPlayerWidget({
    Key? key,
    required this.module,
    this.onProgressChanged,
    this.onCompleted,
    this.languageCode = 'en',
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _showControls = true;
  double _progress = 0.0;
  double _volume = 1.0;
  bool _isFullscreen = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() {
    setState(() {
      _isLoading = true;
    });

    // Get video URL for current language or fallback to English
    _videoUrl = widget.module.getContentForLanguage(widget.languageCode);
    
    if (_videoUrl != null) {
      // Simulate video loading
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _totalDuration = Duration(minutes: widget.module.estimatedDurationMinutes);
          });
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      // Start progress simulation
      _simulateProgress();
    }
  }

  void _simulateProgress() {
    if (!_isPlaying) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isPlaying) {
        setState(() {
          _currentPosition = Duration(
            milliseconds: _currentPosition.inMilliseconds + 1000,
          );
          
          if (_totalDuration.inMilliseconds > 0) {
            _progress = _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
            _progress = _progress.clamp(0.0, 1.0);
          }
        });

        widget.onProgressChanged?.call(_progress * 100);

        if (_progress >= 1.0) {
          _onVideoCompleted();
        } else {
          _simulateProgress();
        }
      }
    });
  }

  void _onVideoCompleted() {
    setState(() {
      _isPlaying = false;
      _progress = 1.0;
    });
    widget.onCompleted?.call();
  }

  void _seekTo(double value) {
    setState(() {
      _progress = value;
      _currentPosition = Duration(
        milliseconds: (_totalDuration.inMilliseconds * value).round(),
      );
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      // Hide controls after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
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

    if (_videoUrl == null) {
      return _buildErrorState();
    }

    return _buildVideoPlayer();
  }

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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildErrorState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              EnhancedLocalizationService.t('error'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Video not available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: _isFullscreen ? MediaQuery.of(context).size.height : 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video placeholder (in real implementation, this would be the actual video)
            Center(
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
                      widget.module.title,
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
            ),
            
            // Video controls overlay
            if (_showControls || !_isPlaying)
              _buildVideoControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
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
                  widget.module.title,
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