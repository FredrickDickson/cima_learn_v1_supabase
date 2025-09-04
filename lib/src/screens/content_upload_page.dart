import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/responsive.dart';
import '../services/content_management_service.dart';
import '../models/course_module.dart';
import '../models/course.dart';
import '../widgets/rich_text_editor.dart';
import '../widgets/quiz_builder_widget.dart';

class ContentUploadPage extends StatefulWidget {
  final String? courseId;
  final String? moduleId;

  const ContentUploadPage({Key? key, this.courseId, this.moduleId}) : super(key: key);

  @override
  State<ContentUploadPage> createState() => _ContentUploadPageState();
}

class _ContentUploadPageState extends State<ContentUploadPage> with SingleTickerProviderStateMixin {
  final ContentManagementService _contentService = ContentManagementService();
  final _formKey = GlobalKey<FormState>();
  
  late TabController _tabController;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  
  // Form state
  String? _selectedCourseId;
  String? _selectedModuleId;
  ContentType _selectedContentType = ContentType.video;
  bool _isUploading = false;
  bool _isRequired = true;
  
  // File handling
  PlatformFile? _selectedFile;
  String? _uploadedFileUrl;
  
  // Content data
  Map<String, dynamic> _contentData = {};
  String _textContent = '';
  List<Map<String, dynamic>> _quizQuestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedCourseId = widget.courseId;
    _selectedModuleId = widget.moduleId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Content'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.videocam), text: 'Video'),
            Tab(icon: Icon(Icons.article), text: 'Text'),
            Tab(icon: Icon(Icons.quiz), text: 'Quiz'),
            Tab(icon: Icon(Icons.attach_file), text: 'Files'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildVideoUpload(),
            _buildTextEditor(),
            _buildQuizBuilder(),
            _buildFileUpload(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoUpload() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          _buildVideoUploadSection(),
          const SizedBox(height: 24),
          _buildVideoSettingsSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Content Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Required'),
                    value: _isRequired,
                    onChanged: (value) {
                      setState(() {
                        _isRequired = value;
                      });
                    },
                    activeColor: const Color(0xFFB71C1C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoUploadSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video Upload',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedFile != null
                  ? _buildVideoPreview()
                  : _buildUploadArea(),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 16),
              _buildFileInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _pickVideoFile,
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Click to upload video',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supports MP4, AVI, MOV (Max 500MB)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.video_file,
          size: 48,
          color: const Color(0xFFB71C1C),
        ),
        const SizedBox(height: 16),
        Text(
          _selectedFile!.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickVideoFile,
              icon: const Icon(Icons.refresh),
              label: const Text('Replace'),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFile = null;
                });
              },
              icon: const Icon(Icons.delete),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileInfo() {
    final fileSizeMB = _selectedFile!.size / (1024 * 1024);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'File: ${_selectedFile!.name}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Size: ${fileSizeMB.toStringAsFixed(2)} MB',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto-play'),
              subtitle: const Text('Start playing when content loads'),
              value: _contentData['autoplay'] ?? false,
              onChanged: (value) {
                setState(() {
                  _contentData['autoplay'] = value;
                });
              },
              activeColor: const Color(0xFFB71C1C),
            ),
            SwitchListTile(
              title: const Text('Show controls'),
              subtitle: const Text('Display video controls to users'),
              value: _contentData['showControls'] ?? true,
              onChanged: (value) {
                setState(() {
                  _contentData['showControls'] = value;
                });
              },
              activeColor: const Color(0xFFB71C1C),
            ),
            SwitchListTile(
              title: const Text('Track progress'),
              subtitle: const Text('Monitor student viewing progress'),
              value: _contentData['trackProgress'] ?? true,
              onChanged: (value) {
                setState(() {
                  _contentData['trackProgress'] = value;
                });
              },
              activeColor: const Color(0xFFB71C1C),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextEditor() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Text Content',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: RichTextEditor(
                        initialContent: _textContent,
                        onContentChanged: (content) {
                          _textContent = content;
                          _contentData['textContent'] = content;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQuizBuilder() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          Expanded(
            child: QuizBuilderWidget(
              initialQuestions: _quizQuestions,
              onQuestionsChanged: (questions) {
                _quizQuestions = questions;
                _contentData['questions'] = questions;
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFileUpload() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'File Upload',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedFile != null
                        ? _buildFilePreview()
                        : _buildFileUploadArea(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFileUploadArea() {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Click to upload file',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supports PDF, DOC, PPT, images (Max 100MB)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getFileIcon(_selectedFile!.extension),
          size: 48,
          color: const Color(0xFFB71C1C),
        ),
        const SizedBox(height: 16),
        Text(
          _selectedFile!.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.refresh),
              label: const Text('Replace'),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFile = null;
                });
              },
              icon: const Icon(Icons.delete),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isUploading ? null : () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadContent,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
          ),
          child: _isUploading
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Uploading...'),
                  ],
                )
              : const Text('Upload Content'),
        ),
      ],
    );
  }

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        _selectedContentType = ContentType.video;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        _selectedContentType = _getContentTypeFromExtension(result.files.first.extension);
      });
    }
  }

  ContentType _getContentTypeFromExtension(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return ContentType.pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return ContentType.image;
      default:
        return ContentType.pdf;
    }
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _uploadContent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedModuleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a module')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? contentUrl;

      // Upload file if present
      if (_selectedFile != null) {
        final fileType = _selectedContentType == ContentType.video ? 'videos' : 'files';
        contentUrl = await _contentService.uploadFile(
          _selectedFile!.name,
          _selectedFile!.bytes!,
          _selectedCourseId!,
          _selectedModuleId!,
          fileType,
        );
      }

      // Create content record
      final content = CourseContent(
        id: '', // Will be generated by database
        moduleId: _selectedModuleId!,
        contentType: _selectedContentType,
        title: _titleController.text,
        contentUrl: contentUrl,
        contentData: _contentData.isNotEmpty ? _contentData : null,
        orderIndex: 0, // Will be set based on existing content
        durationMinutes: int.tryParse(_durationController.text) ?? 0,
        isRequired: _isRequired,
        createdAt: DateTime.now(),
      );

      await _contentService.createContent(content);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading content: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}