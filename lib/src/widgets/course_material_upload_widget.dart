import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/storage_service.dart';
import '../utils/responsive.dart';
import 'loading_widget.dart';

/// Widget for uploading course materials (PDFs, documents, etc.)
/// Used by instructors to upload course content and resources
class CourseMaterialUploadWidget extends StatefulWidget {
  final String courseId;
  final String instructorId;
  final Function(String)? onUploadSuccess;
  final String title;
  final String description;

  const CourseMaterialUploadWidget({
    Key? key,
    required this.courseId,
    required this.instructorId,
    this.onUploadSuccess,
    this.title = 'Course Materials',
    this.description = 'Upload PDFs, documents, and other course resources',
  }) : super(key: key);

  @override
  State<CourseMaterialUploadWidget> createState() => _CourseMaterialUploadWidgetState();
}

class _CourseMaterialUploadWidgetState extends State<CourseMaterialUploadWidget> {
  final StorageService _storageService = StorageService();
  final List<CourseMaterial> _uploadedMaterials = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: const Color(0xFFB71C1C),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: ResponsiveFontSize.heading3(context),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB71C1C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: ResponsiveFontSize.body(context),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadMaterial,
                icon: _isUploading
                    ? const LoadingWidget(size: 16, color: Colors.white)
                    : const Icon(Icons.cloud_upload),
                label: Text(_isUploading ? 'Uploading...' : 'Upload Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Uploaded Materials List
            if (_uploadedMaterials.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Uploaded Materials',
                style: TextStyle(
                  fontSize: ResponsiveFontSize.heading4(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _uploadedMaterials.length,
                itemBuilder: (context, index) {
                  final material = _uploadedMaterials[index];
                  return _buildMaterialItem(material, index);
                },
              ),
            ],

            // Help Text
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Supported formats: PDF, DOC, DOCX, PPT, PPTX, TXT (Max: 50MB)',
                      style: TextStyle(
                        fontSize: ResponsiveFontSize.small(context),
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(CourseMaterial material, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFB71C1C),
          child: Icon(
            _getFileIcon(material.fileName),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          material.fileName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Uploaded ${_formatDate(material.uploadedAt)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Color(0xFFB71C1C)),
              onPressed: () => _openMaterial(material),
              tooltip: 'Open material',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red[400]),
              onPressed: () => _deleteMaterial(material, index),
              tooltip: 'Delete material',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadMaterial() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final materialUrl = await _storageService.uploadCourseMaterial(
        widget.courseId,
        widget.instructorId,
      );

      if (materialUrl != null) {
        // Extract filename from URL for display
        final uri = Uri.parse(materialUrl);
        final fileName = uri.pathSegments.last.split('_').skip(1).join('_');

        final material = CourseMaterial(
          fileName: fileName,
          url: materialUrl,
          uploadedAt: DateTime.now(),
        );

        setState(() {
          _uploadedMaterials.add(material);
        });

        Fluttertoast.showToast(
          msg: 'Material uploaded successfully!',
          backgroundColor: const Color(0xFFB71C1C),
          textColor: Colors.white,
        );

        // Notify parent widget
        widget.onUploadSuccess?.call(materialUrl);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Upload failed: ${e.toString()}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteMaterial(CourseMaterial material, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${material.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _storageService.deleteFileByUrl(material.url);
        if (success) {
          setState(() {
            _uploadedMaterials.removeAt(index);
          });

          Fluttertoast.showToast(
            msg: 'Material deleted successfully',
            backgroundColor: const Color(0xFFB71C1C),
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Failed to delete material: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  void _openMaterial(CourseMaterial material) {
    // Open material in new tab/window
    // You can implement url_launcher here if needed
    Fluttertoast.showToast(
      msg: 'Opening ${material.fileName}...',
      backgroundColor: const Color(0xFFB71C1C),
      textColor: Colors.white,
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Data model for course materials
class CourseMaterial {
  final String fileName;
  final String url;
  final DateTime uploadedAt;

  CourseMaterial({
    required this.fileName,
    required this.url,
    required this.uploadedAt,
  });
}