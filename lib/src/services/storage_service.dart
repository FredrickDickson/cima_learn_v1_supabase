import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../models/video_lesson.dart';

/// Service for handling file uploads and storage with Supabase Storage
/// Manages course materials, profile images, certificates, and other user files
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Storage bucket names  
  static const String profileImagesBucket = 'profile-images';
  static const String courseMaterialsBucket = 'course-materials';
  static const String certificatesBucket = 'certificates';
  static const String uploadsBucket = 'uploads';
  // Video-specific buckets
  static const String videosBucket = 'videos';
  static const String thumbnailsBucket = 'thumbnails';
  static const String hlsStreamsBucket = 'hls-streams';
  static const String downloadsBucket = 'downloads';

  // Video upload settings
  static const int chunkSize = 5 * 1024 * 1024; // 5MB chunks
  static const int maxVideoSize = 2 * 1024 * 1024 * 1024; // 2GB max
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi', 'webm', 'mkv'];

  /// Upload a file to Supabase Storage
  /// Returns the public URL if successful, null if failed
  Future<String?> uploadFile({
    required String bucketName,
    required String fileName,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      // Upload file to Supabase Storage
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(fileName, fileBytes);

      // Get the public URL
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  /// Pick and upload an image file
  /// Returns the public URL if successful
  Future<String?> uploadImage({
    required String bucketName,
    String? folder,
  }) async {
    try {
      // Let user pick an image file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      final file = result.files.first;
      
      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        throw Exception('File size must be less than 5MB');
      }
      
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.extension ?? 'jpg';
      final fileName = '${folder ?? 'uploads'}/${timestamp}_${file.name}';
      
      return await uploadFile(
        bucketName: bucketName,
        fileName: fileName,
        fileBytes: file.bytes!,
        contentType: 'image/$extension',
      );
    } catch (e) {
      print('Image upload error: $e');
      throw e;
    }
  }

  /// Pick and upload a document file (PDF, DOC, etc.)
  /// Returns the public URL if successful
  Future<String?> uploadDocument({
    required String bucketName,
    String? folder,
    List<String>? allowedExtensions,
  }) async {
    try {
      // Let user pick a document file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      final file = result.files.first;
      
      // Validate file size (max 50MB for documents)
      if (file.size > 50 * 1024 * 1024) {
        throw Exception('File size must be less than 50MB');
      }
      
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${folder ?? 'documents'}/${timestamp}_${file.name}';
      
      return await uploadFile(
        bucketName: bucketName,
        fileName: fileName,
        fileBytes: file.bytes!,
        contentType: _getContentType(file.extension ?? 'pdf'),
      );
    } catch (e) {
      print('Document upload error: $e');
      throw e;
    }
  }

  /// Upload profile image for a user
  /// Returns the public URL if successful
  Future<String?> uploadProfileImage(String userId) async {
    try {
      return await uploadImage(
        bucketName: profileImagesBucket,
        folder: 'users/$userId',
      );
    } catch (e) {
      print('Profile image upload error: $e');
      return null;
    }
  }

  /// Upload course material for an instructor
  /// Returns the public URL if successful
  Future<String?> uploadCourseMaterial(String courseId, String instructorId) async {
    try {
      return await uploadDocument(
        bucketName: courseMaterialsBucket,
        folder: 'courses/$courseId',
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      );
    } catch (e) {
      print('Course material upload error: $e');
      return null;
    }
  }

  /// Delete a file from storage
  /// Returns true if successful
  Future<bool> deleteFile({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      await _supabase.storage
          .from(bucketName)
          .remove([fileName]);
      return true;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  /// Get file info from URL
  /// Returns the bucket name and file path
  Map<String, String>? getFileInfoFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 3) {
        final bucketName = pathSegments[2];
        final filePath = pathSegments.skip(3).join('/');
        
        return {
          'bucket': bucketName,
          'path': filePath,
        };
      }
      return null;
    } catch (e) {
      print('Error parsing file URL: $e');
      return null;
    }
  }

  /// Delete file by URL
  Future<bool> deleteFileByUrl(String url) async {
    final fileInfo = getFileInfoFromUrl(url);
    if (fileInfo == null) return false;
    
    return await deleteFile(
      bucketName: fileInfo['bucket']!,
      fileName: fileInfo['path']!,
    );
  }

  /// Get appropriate content type for file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  /// Check if storage is available
  bool get isStorageAvailable {
    try {
      return _supabase.storage != null;
    } catch (e) {
      return false;
    }
  }

  // =====================================================================================
  // VIDEO UPLOAD AND PROCESSING METHODS
  // =====================================================================================

  /// Upload video with chunked upload support and progress tracking
  Future<String?> uploadVideo({
    required String courseId,
    required String lessonId,
    required String instructorId,
    Function(UploadProgress)? onProgress,
  }) async {
    try {
      // Pick video file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      final file = result.files.first;
      
      // Validate video file
      final validationResult = _validateVideoFile(file);
      if (!validationResult.isValid) {
        throw Exception(validationResult.errorMessage);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.extension ?? 'mp4';
      final fileName = 'courses/$courseId/lessons/$lessonId/${timestamp}_${file.name}';

      // Create upload progress tracker
      final uploadId = 'upload_$timestamp';
      var uploadProgress = UploadProgress(
        uploadId: uploadId,
        fileName: file.name!,
        totalBytes: file.size,
        startedAt: DateTime.now(),
      );

      onProgress?.call(uploadProgress);

      String? videoUrl;

      if (file.size > chunkSize) {
        // Use chunked upload for large files
        videoUrl = await _uploadVideoChunked(
          fileName: fileName,
          fileBytes: file.bytes!,
          onProgress: (progress) {
            uploadProgress = UploadProgress(
              uploadId: uploadId,
              fileName: file.name!,
              progressPercentage: progress,
              uploadedBytes: (file.size * progress / 100).round(),
              totalBytes: file.size,
              status: progress == 100 ? UploadStatus.completed : UploadStatus.uploading,
              startedAt: uploadProgress.startedAt,
              completedAt: progress == 100 ? DateTime.now() : null,
            );
            onProgress?.call(uploadProgress);
          },
        );
      } else {
        // Direct upload for smaller files
        videoUrl = await uploadFile(
          bucketName: videosBucket,
          fileName: fileName,
          fileBytes: file.bytes!,
          contentType: 'video/$extension',
        );
        
        uploadProgress = UploadProgress(
          uploadId: uploadId,
          fileName: file.name!,
          progressPercentage: 100,
          uploadedBytes: file.size,
          totalBytes: file.size,
          status: UploadStatus.completed,
          startedAt: uploadProgress.startedAt,
          completedAt: DateTime.now(),
        );
        onProgress?.call(uploadProgress);
      }

      if (videoUrl != null) {
        // Generate thumbnail
        await _generateThumbnail(videoUrl, courseId, lessonId);
        
        // Trigger video processing
        await _triggerVideoProcessing(videoUrl, courseId, lessonId);
      }

      return videoUrl;
    } catch (e) {
      print('Video upload error: $e');
      throw e;
    }
  }

  /// Upload video with chunked upload for large files
  Future<String?> _uploadVideoChunked({
    required String fileName,
    required Uint8List fileBytes,
    Function(double)? onProgress,
  }) async {
    try {
      final totalSize = fileBytes.length;
      final totalChunks = (totalSize / chunkSize).ceil();
      
      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize < totalSize) ? start + chunkSize : totalSize;
        final chunk = fileBytes.sublist(start, end);
        
        // Upload chunk
        await _supabase.storage
            .from(videosBucket)
            .uploadBinary('${fileName}_chunk_$i', chunk);
            
        // Report progress
        final progress = ((i + 1) / totalChunks) * 100;
        onProgress?.call(progress);
      }

      // Combine chunks (this would typically be done server-side)
      // For now, we'll use the first chunk approach
      // In production, implement server-side chunk combining
      
      final publicUrl = _supabase.storage
          .from(videosBucket)
          .getPublicUrl('${fileName}_chunk_0');

      return publicUrl;
    } catch (e) {
      print('Chunked upload error: $e');
      return null;
    }
  }

  /// Validate video file before upload
  VideoValidationResult _validateVideoFile(PlatformFile file) {
    // Check file size
    if (file.size > maxVideoSize) {
      return VideoValidationResult(
        isValid: false,
        errorMessage: 'Video file is too large. Maximum size is ${maxVideoSize / 1024 / 1024 / 1024}GB',
      );
    }

    // Check file format
    final extension = file.extension?.toLowerCase();
    if (extension == null || !supportedVideoFormats.contains(extension)) {
      return VideoValidationResult(
        isValid: false,
        errorMessage: 'Unsupported video format. Supported formats: ${supportedVideoFormats.join(', ')}',
      );
    }

    return VideoValidationResult(isValid: true);
  }

  /// Generate thumbnail for uploaded video
  Future<String?> _generateThumbnail(String videoUrl, String courseId, String lessonId) async {
    try {
      // Download video temporarily to generate thumbnail
      final tempDir = await getTemporaryDirectory();
      final videoFile = File('${tempDir.path}/temp_video.mp4');
      
      // In a real implementation, you'd download the video
      // For now, we'll simulate thumbnail generation
      
      final thumbnailData = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 320,
        quality: 75,
      );

      if (thumbnailData != null) {
        final thumbnailFileName = 'courses/$courseId/lessons/$lessonId/thumbnail.jpg';
        
        return await uploadFile(
          bucketName: thumbnailsBucket,
          fileName: thumbnailFileName,
          fileBytes: thumbnailData,
          contentType: 'image/jpeg',
        );
      }
    } catch (e) {
      print('Thumbnail generation error: $e');
    }
    
    return null;
  }

  /// Trigger video processing and transcoding
  Future<void> _triggerVideoProcessing(String videoUrl, String courseId, String lessonId) async {
    try {
      // In a real implementation, this would trigger a background job
      // For now, we'll create a database entry to track processing
      
      await _supabase.from('video_processing_queue').insert({
        'video_url': videoUrl,
        'course_id': courseId,
        'lesson_id': lessonId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('Video processing triggered for lesson: $lessonId');
    } catch (e) {
      print('Error triggering video processing: $e');
    }
  }

  /// Download video for offline viewing
  Future<String?> downloadVideoForOffline({
    required String videoUrl,
    required String lessonId,
    required String userId,
    Function(double)? onProgress,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${appDir.path}/videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      final fileName = 'lesson_${lessonId}.mp4';
      final filePath = '${videoDir.path}/$fileName';
      final file = File(filePath);

      // Download with progress tracking
      final dio = Dio();
      await dio.download(
        videoUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            onProgress?.call(progress);
          }
        },
      );

      return filePath;
    } catch (e) {
      print('Video download error: $e');
      return null;
    }
  }

  /// Get signed URL for video streaming
  Future<String?> getVideoStreamingUrl(String videoPath, {int expirySeconds = 3600}) async {
    try {
      return await _supabase.storage
          .from(videosBucket)
          .createSignedUrl(videoPath, expirySeconds);
    } catch (e) {
      print('Error creating signed URL: $e');
      return null;
    }
  }

  /// Get HLS streaming URL for a video
  Future<String?> getHLSStreamingUrl(String videoPath) async {
    try {
      // Convert video path to HLS path
      final hlsPath = videoPath.replaceAll('.mp4', '.m3u8');
      
      return await _supabase.storage
          .from(hlsStreamsBucket)
          .createSignedUrl(hlsPath, 3600);
    } catch (e) {
      print('Error getting HLS URL: $e');
      return null;
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file.path.contains('temp_video') || file.path.contains('thumbnail_')) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Cleanup error: $e');
    }
  }

  /// Get download progress for offline video
  Future<double> getDownloadProgress(String lessonId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/videos/lesson_${lessonId}.mp4';
      final file = File(filePath);
      
      if (await file.exists()) {
        return 100.0; // Already downloaded
      }
      
      // Check for partial downloads
      final partialFile = File('${filePath}.partial');
      if (await partialFile.exists()) {
        // Return partial progress (this would need to be tracked separately)
        return 50.0; // Placeholder
      }
      
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

/// Video validation result
class VideoValidationResult {
  final bool isValid;
  final String? errorMessage;

  VideoValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}