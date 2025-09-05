import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_lesson.dart';
import 'storage_service.dart';
import 'dart:async';

/// Service for handling video processing and transcoding operations
/// Manages video processing pipeline, quality generation, and HLS transcoding
class VideoProcessingService {
  static final VideoProcessingService _instance = VideoProcessingService._internal();
  factory VideoProcessingService() => _instance;
  VideoProcessingService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService.instance;

  // Processing status tracking
  final Map<String, StreamController<VideoProcessingStatus>> _statusStreams = {};

  // =====================================================================================
  // VIDEO PROCESSING PIPELINE
  // =====================================================================================

  /// Start video processing pipeline
  Future<bool> startVideoProcessing({
    required String lessonId,
    required String videoUrl,
    required String courseId,
  }) async {
    try {
      // Create processing queue entry
      await _supabase.from('video_processing_queue').insert({
        'lesson_id': lessonId,
        'video_url': videoUrl,
        'course_id': courseId,
        'status': VideoProcessingStatus.pending.value,
        'created_at': DateTime.now().toIso8601String(),
        'metadata': {
          'original_url': videoUrl,
          'processing_started_at': DateTime.now().toIso8601String(),
        },
      });

      // Update lesson status
      await _updateLessonProcessingStatus(lessonId, VideoProcessingStatus.processing);

      // Start processing pipeline
      await _processVideoAsync(lessonId, videoUrl, courseId);

      return true;
    } catch (e) {
      print('Error starting video processing: $e');
      await _updateLessonProcessingStatus(lessonId, VideoProcessingStatus.failed);
      return false;
    }
  }

  /// Process video asynchronously (simulates background processing)
  Future<void> _processVideoAsync(String lessonId, String videoUrl, String courseId) async {
    try {
      // Simulate processing steps with delays
      
      // Step 1: Video validation and metadata extraction
      await _updateLessonProcessingStatus(lessonId, VideoProcessingStatus.processing);
      await _simulateProcessingDelay(2000); // 2 seconds
      
      final metadata = await _extractVideoMetadata(videoUrl);
      
      // Step 2: Generate thumbnail
      await _generateVideoThumbnail(lessonId, videoUrl, courseId);
      await _simulateProcessingDelay(3000); // 3 seconds
      
      // Step 3: Transcode to multiple qualities
      await _updateLessonProcessingStatus(lessonId, VideoProcessingStatus.transcoding);
      await _simulateProcessingDelay(5000); // 5 seconds
      
      final qualities = await _transcodeVideoQualities(videoUrl, courseId, lessonId);
      
      // Step 4: Generate HLS streams
      final hlsUrl = await _generateHLSStream(videoUrl, courseId, lessonId);
      await _simulateProcessingDelay(3000); // 3 seconds
      
      // Step 5: Update lesson with processed content
      await _updateLessonWithProcessedContent(
        lessonId,
        videoUrl,
        hlsUrl,
        qualities,
        metadata,
      );
      
      // Mark as completed
      await _updateLessonProcessingStatus(lessonId, VideoProcessingStatus.completed);
      
      // Clean up processing queue
      await _cleanupProcessingQueue(lessonId);
      
    } catch (e) {
      print('Error in video processing pipeline: $e');
      await _updateLessonProcessingStatus(lessonId, VideoProcessingStatus.failed);
    }
  }

  /// Extract video metadata (simulated)
  Future<Map<String, dynamic>> _extractVideoMetadata(String videoUrl) async {
    // In a real implementation, this would use FFmpeg or similar
    // For demo purposes, we'll return simulated metadata
    return {
      'duration_seconds': 1800, // 30 minutes
      'width': 1920,
      'height': 1080,
      'fps': 30,
      'bitrate': 5000000,
      'codec': 'h264',
      'file_size_mb': 250.5,
      'format': 'mp4',
      'extracted_at': DateTime.now().toIso8601String(),
    };
  }

  /// Generate video thumbnail
  Future<String?> _generateVideoThumbnail(String lessonId, String videoUrl, String courseId) async {
    try {
      // In a real implementation, this would extract a frame from the video
      // For demo purposes, we'll simulate thumbnail generation
      
      final thumbnailFileName = 'courses/$courseId/lessons/$lessonId/thumbnail.jpg';
      
      // Simulate thumbnail generation with a placeholder
      // In production, you'd use FFmpeg to extract a frame
      
      return await _storageService.uploadFile(
        bucketName: StorageService.thumbnailsBucket,
        fileName: thumbnailFileName,
        fileBytes: _generatePlaceholderThumbnail(),
        contentType: 'image/jpeg',
      );
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Generate placeholder thumbnail data
  List<int> _generatePlaceholderThumbnail() {
    // This would be replaced with actual thumbnail generation
    // For now, return empty data (in production, use FFmpeg)
    return [];
  }

  /// Transcode video to multiple qualities
  Future<Map<VideoQuality, VideoContent>> _transcodeVideoQualities(
    String originalUrl,
    String courseId,
    String lessonId,
  ) async {
    final qualities = <VideoQuality, VideoContent>{};
    
    try {
      // Simulate transcoding to different qualities
      for (final quality in [VideoQuality.p360, VideoQuality.p720, VideoQuality.p1080]) {
        final qualityUrl = await _transcodeToQuality(
          originalUrl,
          quality,
          courseId,
          lessonId,
        );
        
        if (qualityUrl != null) {
          qualities[quality] = VideoContent(
            rawVideoUrl: qualityUrl,
            format: VideoFormat.mp4,
            bitrate: _getBitrateForQuality(quality),
            resolution: quality.value,
            fileSize: _getFileSizeForQuality(quality),
          );
        }
      }
    } catch (e) {
      print('Error transcoding video qualities: $e');
    }
    
    return qualities;
  }

  /// Transcode video to specific quality
  Future<String?> _transcodeToQuality(
    String originalUrl,
    VideoQuality quality,
    String courseId,
    String lessonId,
  ) async {
    try {
      // In a real implementation, this would use FFmpeg for transcoding
      // For demo purposes, we'll simulate the process
      
      final qualityFileName = 'courses/$courseId/lessons/$lessonId/${quality.value}.mp4';
      
      // Simulate transcoding process
      await _simulateProcessingDelay(2000);
      
      // In production, you'd actually transcode the video here
      // For now, we'll just return the original URL with a quality suffix
      return '${originalUrl}_${quality.value}';
    } catch (e) {
      print('Error transcoding to quality ${quality.value}: $e');
      return null;
    }
  }

  /// Generate HLS streaming manifest
  Future<String?> _generateHLSStream(String videoUrl, String courseId, String lessonId) async {
    try {
      // In a real implementation, this would generate HLS segments
      // For demo purposes, we'll simulate the process
      
      final hlsFileName = 'courses/$courseId/lessons/$lessonId/master.m3u8';
      
      // Simulate HLS generation
      await _simulateProcessingDelay(3000);
      
      // In production, you'd generate actual HLS segments and manifest
      // For now, we'll return a simulated HLS URL
      return '${videoUrl.replaceAll('.mp4', '.m3u8')}';
    } catch (e) {
      print('Error generating HLS stream: $e');
      return null;
    }
  }

  /// Update lesson with processed video content
  Future<bool> _updateLessonWithProcessedContent(
    String lessonId,
    String originalUrl,
    String? hlsUrl,
    Map<VideoQuality, VideoContent> qualities,
    Map<String, dynamic> metadata,
  ) async {
    try {
      // Prepare video content data
      final videoContent = <String, Map<String, dynamic>>{};
      
      // Add English content (default language)
      videoContent['en'] = {
        'raw_video_url': originalUrl,
        'hls_url': hlsUrl,
        'dash_url': null,
        'qualities': qualities.map(
          (key, value) => MapEntry(key.value, value.toJson()),
        ),
        'format': 'mp4',
        'bitrate': metadata['bitrate'] ?? 0,
        'resolution': '${metadata['width']}x${metadata['height']}',
        'file_size': metadata['file_size_mb'] ?? 0.0,
      };

      // Update lesson in database
      await _supabase.from('video_lessons').update({
        'video_content': videoContent,
        'duration_seconds': metadata['duration_seconds'],
        'metadata': metadata,
        'processing_status': VideoProcessingStatus.completed.value,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', lessonId);

      return true;
    } catch (e) {
      print('Error updating lesson with processed content: $e');
      return false;
    }
  }

  /// Update lesson processing status
  Future<bool> _updateLessonProcessingStatus(String lessonId, VideoProcessingStatus status) async {
    try {
      await _supabase.from('video_lessons').update({
        'processing_status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', lessonId);

      // Emit status update to stream
      _emitStatusUpdate(lessonId, status);

      return true;
    } catch (e) {
      print('Error updating lesson processing status: $e');
      return false;
    }
  }

  /// Clean up processing queue entry
  Future<void> _cleanupProcessingQueue(String lessonId) async {
    try {
      await _supabase
          .from('video_processing_queue')
          .delete()
          .eq('lesson_id', lessonId);
    } catch (e) {
      print('Error cleaning up processing queue: $e');
    }
  }

  // =====================================================================================
  // STATUS STREAMING AND MONITORING
  // =====================================================================================

  /// Stream processing status updates
  Stream<VideoProcessingStatus> streamProcessingStatus(String lessonId) {
    if (!_statusStreams.containsKey(lessonId)) {
      _statusStreams[lessonId] = StreamController<VideoProcessingStatus>.broadcast();
    }
    
    return _statusStreams[lessonId]!.stream;
  }

  /// Emit status update to stream
  void _emitStatusUpdate(String lessonId, VideoProcessingStatus status) {
    if (_statusStreams.containsKey(lessonId)) {
      _statusStreams[lessonId]!.add(status);
      
      // Close stream if processing is complete or failed
      if (status == VideoProcessingStatus.completed || status == VideoProcessingStatus.failed) {
        Timer(const Duration(seconds: 5), () {
          _statusStreams[lessonId]?.close();
          _statusStreams.remove(lessonId);
        });
      }
    }
  }

  /// Get current processing status for a lesson
  Future<VideoProcessingStatus> getCurrentProcessingStatus(String lessonId) async {
    try {
      final response = await _supabase
          .from('video_lessons')
          .select('processing_status')
          .eq('id', lessonId)
          .single();

      return VideoProcessingStatus.fromString(response['processing_status'] as String);
    } catch (e) {
      print('Error getting current processing status: $e');
      return VideoProcessingStatus.pending;
    }
  }

  /// Get processing queue status
  Future<List<Map<String, dynamic>>> getProcessingQueue() async {
    try {
      final response = await _supabase
          .from('video_processing_queue')
          .select('''
            *,
            video_lessons!inner(title, course_id)
          ''')
          .order('created_at');

      return response;
    } catch (e) {
      print('Error getting processing queue: $e');
      return [];
    }
  }

  // =====================================================================================
  // PROCESSING ANALYTICS
  // =====================================================================================

  /// Get processing analytics
  Future<Map<String, dynamic>> getProcessingAnalytics() async {
    try {
      final response = await _supabase
          .from('video_lessons')
          .select('processing_status');

      final statusCounts = <String, int>{};
      
      for (final record in response) {
        final status = record['processing_status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      final total = response.length;
      
      return {
        'total_videos': total,
        'completed': statusCounts[VideoProcessingStatus.completed.value] ?? 0,
        'processing': statusCounts[VideoProcessingStatus.processing.value] ?? 0,
        'transcoding': statusCounts[VideoProcessingStatus.transcoding.value] ?? 0,
        'failed': statusCounts[VideoProcessingStatus.failed.value] ?? 0,
        'pending': statusCounts[VideoProcessingStatus.pending.value] ?? 0,
        'success_rate': total > 0 
            ? ((statusCounts[VideoProcessingStatus.completed.value] ?? 0) / total) * 100 
            : 0,
      };
    } catch (e) {
      print('Error getting processing analytics: $e');
      return {};
    }
  }

  // =====================================================================================
  // UTILITY METHODS
  // =====================================================================================

  /// Get bitrate for video quality
  int _getBitrateForQuality(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.p360:
        return 1000000; // 1 Mbps
      case VideoQuality.p720:
        return 2500000; // 2.5 Mbps
      case VideoQuality.p1080:
        return 5000000; // 5 Mbps
      case VideoQuality.p1440:
        return 8000000; // 8 Mbps
      case VideoQuality.p2160:
        return 15000000; // 15 Mbps
      default:
        return 2500000;
    }
  }

  /// Get file size for video quality (simulated)
  double _getFileSizeForQuality(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.p360:
        return 50.0; // MB
      case VideoQuality.p720:
        return 125.0; // MB
      case VideoQuality.p1080:
        return 250.0; // MB
      case VideoQuality.p1440:
        return 400.0; // MB
      case VideoQuality.p2160:
        return 800.0; // MB
      default:
        return 125.0;
    }
  }

  /// Simulate processing delay
  Future<void> _simulateProcessingDelay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Retry failed processing
  Future<bool> retryFailedProcessing(String lessonId) async {
    try {
      // Get original video URL
      final response = await _supabase
          .from('video_lessons')
          .select('video_content, course_id')
          .eq('id', lessonId)
          .single();

      if (response == null) return false;

      final videoContent = response['video_content'] as Map<String, dynamic>;
      final originalUrl = videoContent['en']?['raw_video_url'] as String?;
      final courseId = response['course_id'] as String;

      if (originalUrl == null) return false;

      // Reset status and restart processing
      await _updateLessonProcessingStatus(lessonId, VideoProcessingStatus.pending);
      
      return await startVideoProcessing(
        lessonId: lessonId,
        videoUrl: originalUrl,
        courseId: courseId,
      );
    } catch (e) {
      print('Error retrying failed processing: $e');
      return false;
    }
  }

  /// Cancel processing
  Future<bool> cancelProcessing(String lessonId) async {
    try {
      await _updateLessonProcessingStatus(lessonId, VideoProcessingStatus.cancelled);
      await _cleanupProcessingQueue(lessonId);
      
      return true;
    } catch (e) {
      print('Error cancelling processing: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    for (final controller in _statusStreams.values) {
      controller.close();
    }
    _statusStreams.clear();
  }
}