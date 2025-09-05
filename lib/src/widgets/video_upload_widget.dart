import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../models/video_lesson.dart';
import 'dart:async';

/// Comprehensive video upload widget for instructors
/// Supports chunked uploads, progress tracking, and video processing status
class VideoUploadWidget extends StatefulWidget {
  final String courseId;
  final String lessonId;
  final String instructorId;
  final Function(String videoUrl, String? thumbnailUrl)? onUploadComplete;
  final Function(String error)? onError;
  final VideoLesson? existingVideo;

  const VideoUploadWidget({
    Key? key,
    required this.courseId,
    required this.lessonId,
    required this.instructorId,
    this.onUploadComplete,
    this.onError,
    this.existingVideo,
  }) : super(key: key);

  @override
  VideoUploadWidgetState createState() => VideoUploadWidgetState();
}

class VideoUploadWidgetState extends State<VideoUploadWidget>
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService.instance;
  
  // Upload state
  bool _isUploading = false;
  UploadProgress? _uploadProgress;
  String? _uploadedVideoUrl;
  String? _thumbnailUrl;
  String? _errorMessage;
  
  // Processing state
  VideoProcessingStatus _processingStatus = VideoProcessingStatus.pending;
  Timer? _processingTimer;
  
  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Check if there's an existing video
    if (widget.existingVideo != null) {
      _uploadedVideoUrl = widget.existingVideo!.getBestVideoContent('en')?.rawVideoUrl;
      _thumbnailUrl = widget.existingVideo!.thumbnailUrl;
      _processingStatus = widget.existingVideo!.processingStatus;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _processingTimer?.cancel();
    super.dispose();
  }

  /// Start video upload process
  Future<void> _startUpload() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _uploadProgress = null;
    });

    try {
      final videoUrl = await _storageService.uploadVideo(
        courseId: widget.courseId,
        lessonId: widget.lessonId,
        instructorId: widget.instructorId,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
          
          // Animate progress
          _progressController.animateTo(progress.progressPercentage / 100);
          
          // Start pulsing animation during upload
          if (progress.status == UploadStatus.uploading && !_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          }
        },
      );

      if (videoUrl != null) {
        setState(() {
          _uploadedVideoUrl = videoUrl;
          _processingStatus = VideoProcessingStatus.processing;
        });
        
        // Stop pulsing and start processing monitoring
        _pulseController.stop();
        _startProcessingMonitoring();
        
        widget.onUploadComplete?.call(videoUrl, _thumbnailUrl);
      } else {
        throw Exception('Upload was cancelled or failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      widget.onError?.call(e.toString());
    } finally {
      setState(() {
        _isUploading = false;
      });
      _pulseController.stop();
    }
  }

  /// Monitor video processing status
  void _startProcessingMonitoring() {
    _processingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // In a real implementation, you'd check the processing status from the server
      // For now, we'll simulate the processing stages
      await _simulateProcessingStages();
    });
  }

  /// Simulate video processing stages for demo
  Future<void> _simulateProcessingStages() async {
    if (_processingStatus == VideoProcessingStatus.completed) {
      _processingTimer?.cancel();
      return;
    }

    setState(() {
      switch (_processingStatus) {
        case VideoProcessingStatus.processing:
          _processingStatus = VideoProcessingStatus.transcoding;
          break;
        case VideoProcessingStatus.transcoding:
          _processingStatus = VideoProcessingStatus.completed;
          _processingTimer?.cancel();
          break;
        default:
          break;
      }
    });
  }

  /// Delete uploaded video
  Future<void> _deleteVideo() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    try {
      // In a real implementation, you'd delete from storage and database
      setState(() {
        _uploadedVideoUrl = null;
        _thumbnailUrl = null;
        _processingStatus = VideoProcessingStatus.pending;
        _uploadProgress = null;
        _errorMessage = null;
      });
      
      _progressController.reset();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete video: $e';
      });
    }
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: const Text('Are you sure you want to delete this video? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.video_library, size: 28, color: Color(0xFFB71C1C)),
                const SizedBox(width: 12),
                const Text(
                  'Video Content',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_uploadedVideoUrl != null) ...[
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteVideo,
                    tooltip: 'Delete video',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Video status section
            if (_uploadedVideoUrl != null) ...[
              _buildVideoStatusSection(),
              const SizedBox(height: 20),
            ],

            // Upload section
            if (_uploadedVideoUrl == null) ...[
              _buildUploadSection(),
            ],

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Upload guidelines
            if (_uploadedVideoUrl == null && !_isUploading) ...[
              const SizedBox(height: 20),
              _buildUploadGuidelines(),
            ],
          ],
        ),
      ),
    );
  }

  /// Build video status section
  Widget _buildVideoStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Video Uploaded Successfully',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              _buildProcessingStatusChip(),
            ],
          ),
          const SizedBox(height: 12),
          
          // Video preview
          if (_thumbnailUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _thumbnailUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.video_file, size: 48),
                ),
              ),
            ),
          ] else ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_file, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Generating thumbnail...'),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Video info
          Row(
            children: [
              const Icon(Icons.link, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _uploadedVideoUrl!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _uploadedVideoUrl!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video URL copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build processing status chip
  Widget _buildProcessingStatusChip() {
    Color chipColor;
    IconData chipIcon;
    String chipText;

    switch (_processingStatus) {
      case VideoProcessingStatus.pending:
        chipColor = Colors.grey;
        chipIcon = Icons.schedule;
        chipText = 'Pending';
        break;
      case VideoProcessingStatus.processing:
        chipColor = Colors.orange;
        chipIcon = Icons.settings;
        chipText = 'Processing';
        break;
      case VideoProcessingStatus.transcoding:
        chipColor = Colors.blue;
        chipIcon = Icons.transform;
        chipText = 'Transcoding';
        break;
      case VideoProcessingStatus.completed:
        chipColor = Colors.green;
        chipIcon = Icons.check;
        chipText = 'Ready';
        break;
      case VideoProcessingStatus.failed:
        chipColor = Colors.red;
        chipIcon = Icons.error;
        chipText = 'Failed';
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = Icons.schedule;
        chipText = 'Unknown';
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(chipText, style: TextStyle(color: chipColor)),
        ],
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor.withOpacity(0.3)),
    );
  }

  /// Build upload section
  Widget _buildUploadSection() {
    if (_isUploading) {
      return _buildUploadProgress();
    }

    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: InkWell(
            onTap: _startUpload,
            borderRadius: BorderRadius.circular(12),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 64, color: Color(0xFFB71C1C)),
                  SizedBox(height: 16),
                  Text(
                    'Click to Upload Video',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Drag and drop video files here or click to browse',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _startUpload,
          icon: const Icon(Icons.add),
          label: const Text('Choose Video File'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  /// Build upload progress section
  Widget _buildUploadProgress() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.upload, color: Color(0xFFB71C1C)),
                    SizedBox(width: 8),
                    Text(
                      'Uploading Video...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress bar
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Upload details
                if (_uploadProgress != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_uploadProgress!.progressPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_uploadProgress!.formattedSize),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Uploading: ${_uploadProgress!.fileName}',
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_uploadProgress!.estimatedTimeRemaining != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Time remaining: ${_formatDuration(_uploadProgress!.estimatedTimeRemaining!)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build upload guidelines
  Widget _buildUploadGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Upload Guidelines',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('• Supported formats: MP4, MOV, AVI, WebM, MKV'),
          const Text('• Maximum file size: 2GB'),
          const Text('• Recommended resolution: 720p or 1080p'),
          const Text('• Files will be automatically transcoded for optimal streaming'),
          const Text('• Thumbnails are generated automatically'),
        ],
      ),
    );
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}