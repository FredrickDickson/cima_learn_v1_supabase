import 'package:flutter/material.dart';
import '../models/video_lesson.dart';
import '../models/course_module.dart';
import '../services/video_service.dart';
import '../services/video_processing_service.dart';
import '../services/course_service.dart';
import 'video_upload_widget.dart';
import 'video_player_widget.dart';
import 'dart:async';

/// Comprehensive instructor dashboard for video management
/// Features video upload, progress monitoring, analytics, and course management
class InstructorVideoDashboard extends StatefulWidget {
  final String instructorId;
  final String courseId;
  final String? moduleId;

  const InstructorVideoDashboard({
    Key? key,
    required this.instructorId,
    required this.courseId,
    this.moduleId,
  }) : super(key: key);

  @override
  InstructorVideoDashboardState createState() => InstructorVideoDashboardState();
}

class InstructorVideoDashboardState extends State<InstructorVideoDashboard>
    with TickerProviderStateMixin {
  final VideoService _videoService = VideoService();
  final VideoProcessingService _processingService = VideoProcessingService();
  final CourseService _courseService = CourseService();

  // Dashboard state
  List<CourseModule> _modules = [];
  List<VideoLesson> _videoLessons = [];
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> _processingQueue = {};
  bool _isLoading = true;
  String? _errorMessage;

  // UI state
  late TabController _tabController;
  String _selectedModuleId = '';
  VideoLesson? _selectedLesson;

  // Streams
  final Map<String, StreamSubscription> _processingStreams = {};

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    _selectedModuleId = widget.moduleId ?? '';
    
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposalProcessingStreams();
    super.dispose();
  }

  /// Load all dashboard data
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load course modules with videos
      _modules = await _courseService.getCourseModulesWithVideos(
        widget.courseId,
        widget.instructorId,
      );

      // Get all video lessons for the course
      if (_modules.isNotEmpty) {
        _selectedModuleId = _selectedModuleId.isEmpty ? _modules.first.id : _selectedModuleId;
        await _loadModuleVideos(_selectedModuleId);
      }

      // Load analytics
      _analytics = await _courseService.getCourseAnalytics(widget.courseId);

      // Load processing queue
      final queueData = await _processingService.getProcessingQueue();
      _processingQueue = {
        'queue': queueData,
        'analytics': await _processingService.getProcessingAnalytics(),
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Load videos for a specific module
  Future<void> _loadModuleVideos(String moduleId) async {
    try {
      _videoLessons = await _videoService.getModuleVideoLessons(
        moduleId,
        widget.instructorId,
      );

      // Setup processing status streams
      _setupProcessingStreams();

      setState(() {});
    } catch (e) {
      print('Error loading module videos: $e');
    }
  }

  /// Setup processing status streams for videos
  void _setupProcessingStreams() {
    _disposalProcessingStreams();

    for (final lesson in _videoLessons) {
      if (lesson.processingStatus.isProcessing) {
        final stream = _processingService.streamProcessingStatus(lesson.id);
        _processingStreams[lesson.id] = stream.listen((status) {
          setState(() {
            // Update lesson status in the list
            final index = _videoLessons.indexWhere((l) => l.id == lesson.id);
            if (index != -1) {
              _videoLessons[index] = VideoLesson(
                id: lesson.id,
                moduleId: lesson.moduleId,
                courseId: lesson.courseId,
                title: lesson.title,
                description: lesson.description,
                orderIndex: lesson.orderIndex,
                durationSeconds: lesson.durationSeconds,
                thumbnailUrl: lesson.thumbnailUrl,
                videoContent: lesson.videoContent,
                subtitles: lesson.subtitles,
                processingStatus: status,
                metadata: lesson.metadata,
                createdAt: lesson.createdAt,
                updatedAt: DateTime.now(),
              );
            }
          });
        });
      }
    }
  }

  /// Dispose processing streams
  void _disposalProcessingStreams() {
    for (final subscription in _processingStreams.values) {
      subscription.cancel();
    }
    _processingStreams.clear();
  }

  /// Handle video upload completion
  void _onVideoUploadComplete(String videoUrl, String? thumbnailUrl) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video uploaded successfully! Processing will begin shortly.'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Reload module videos to show the new upload
    _loadModuleVideos(_selectedModuleId);
  }

  /// Handle video upload error
  void _onVideoUploadError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload failed: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading dashboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Dashboard'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.video_library), text: 'Videos'),
            Tab(icon: Icon(Icons.upload), text: 'Upload'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.settings), text: 'Processing'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVideosTab(),
          _buildUploadTab(),
          _buildAnalyticsTab(),
          _buildProcessingTab(),
        ],
      ),
    );
  }

  /// Build videos management tab
  Widget _buildVideosTab() {
    return Column(
      children: [
        // Module selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              const Text('Module: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedModuleId.isEmpty ? null : _selectedModuleId,
                  hint: const Text('Select Module'),
                  isExpanded: true,
                  items: _modules.map((module) => DropdownMenuItem(
                    value: module.id,
                    child: Text(module.title),
                  )).toList(),
                  onChanged: (moduleId) {
                    if (moduleId != null) {
                      setState(() {
                        _selectedModuleId = moduleId;
                      });
                      _loadModuleVideos(moduleId);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Videos list
        Expanded(
          child: _videoLessons.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No videos in this module'),
                      SizedBox(height: 8),
                      Text('Upload your first video using the Upload tab'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _videoLessons.length,
                  itemBuilder: (context, index) => _buildVideoCard(_videoLessons[index]),
                ),
        ),
      ],
    );
  }

  /// Build individual video card
  Widget _buildVideoCard(VideoLesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Thumbnail or placeholder
                Container(
                  width: 120,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: lesson.thumbnailUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            lesson.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.video_file, size: 32),
                          ),
                        )
                      : const Icon(Icons.video_file, size: 32),
                ),
                
                const SizedBox(width: 16),
                
                // Video info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.description,
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(lesson.formattedDuration),
                          const SizedBox(width: 16),
                          _buildProcessingStatusChip(lesson.processingStatus),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                PopupMenuButton<String>(
                  onSelected: (action) => _handleVideoAction(action, lesson),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'preview', child: Text('Preview')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'analytics', child: Text('Analytics')),
                    if (lesson.processingStatus == VideoProcessingStatus.failed)
                      const PopupMenuItem(value: 'retry', child: Text('Retry Processing')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            
            // Processing progress for videos being processed
            if (lesson.processingStatus.isProcessing) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
              ),
              const SizedBox(height: 4),
              Text(
                'Processing video... This may take several minutes.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build processing status chip
  Widget _buildProcessingStatusChip(VideoProcessingStatus status) {
    Color chipColor;
    IconData chipIcon;
    String chipText;

    switch (status) {
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
          Icon(chipIcon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(chipText, style: TextStyle(color: chipColor, fontSize: 12)),
        ],
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor.withOpacity(0.3)),
    );
  }

  /// Handle video actions
  void _handleVideoAction(String action, VideoLesson lesson) {
    switch (action) {
      case 'preview':
        _showVideoPreview(lesson);
        break;
      case 'edit':
        _editVideoLesson(lesson);
        break;
      case 'analytics':
        _showVideoAnalytics(lesson);
        break;
      case 'retry':
        _retryProcessing(lesson);
        break;
      case 'delete':
        _deleteVideo(lesson);
        break;
    }
  }

  /// Show video preview dialog
  void _showVideoPreview(VideoLesson lesson) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: VideoPlayerWidget(
                  videoLesson: lesson,
                  userId: widget.instructorId,
                  allowOfflineDownload: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Edit video lesson
  void _editVideoLesson(VideoLesson lesson) {
    // Implementation for editing video details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Video'),
        content: const Text('Video editing functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show video analytics
  void _showVideoAnalytics(VideoLesson lesson) {
    // Implementation for video analytics
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Analytics: ${lesson.title}'),
        content: const Text('Video analytics will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Retry video processing
  Future<void> _retryProcessing(VideoLesson lesson) async {
    final success = await _processingService.retryFailedProcessing(lesson.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing restarted')),
      );
      _loadModuleVideos(_selectedModuleId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to restart processing'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Delete video
  Future<void> _deleteVideo(VideoLesson lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Are you sure you want to delete "${lesson.title}"? This action cannot be undone.'),
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
    );

    if (confirmed == true) {
      final success = await _videoService.deleteVideoLesson(lesson.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video deleted successfully')),
        );
        _loadModuleVideos(_selectedModuleId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Build upload tab
  Widget _buildUploadTab() {
    if (_selectedModuleId.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Please select a module first'),
            SizedBox(height: 8),
            Text('Use the Videos tab to select a module for upload'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Video to Module',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Selected Module: ${_modules.firstWhere((m) => m.id == _selectedModuleId).title}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          VideoUploadWidget(
            courseId: widget.courseId,
            lessonId: 'new_lesson_${DateTime.now().millisecondsSinceEpoch}',
            instructorId: widget.instructorId,
            onUploadComplete: _onVideoUploadComplete,
            onError: _onVideoUploadError,
          ),
        ],
      ),
    );
  }

  /// Build analytics tab
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          // Analytics cards would go here
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Analytics data will be displayed here'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build processing tab
  Widget _buildProcessingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Processing Queue',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          // Processing queue would go here
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Processing queue will be displayed here'),
            ),
          ),
        ],
      ),
    );
  }
}