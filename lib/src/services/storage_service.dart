import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

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
}