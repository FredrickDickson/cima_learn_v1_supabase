import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_module.dart';
import '../models/cima_course.dart';
import '../services/enhanced_localization_service.dart';
import '../services/module_service.dart';
import '../widgets/video_player_widget.dart';
import '../utils/responsive.dart';
import '../widgets/loading_widget.dart';

class CourseContentPage extends StatefulWidget {
  final CIMACourse course;
  
  const CourseContentPage({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<CourseContentPage> createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  final ModuleService _moduleService = ModuleService();
  List<CourseModule> _modules = [];
  CourseModule? _currentModule;
  bool _isLoading = true;
  int _currentModuleIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    try {
      final modules = await _moduleService.getCourseModules(widget.course.id);
      setState(() {
        _modules = modules;
        if (modules.isNotEmpty) {
          _currentModule = modules.first;
          _currentModuleIndex = 0;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading course content: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectModule(int index) {
    setState(() {
      _currentModuleIndex = index;
      _currentModule = _modules[index];
    });
  }

  void _goToNextModule() {
    if (_currentModuleIndex < _modules.length - 1) {
      _selectModule(_currentModuleIndex + 1);
    }
  }

  void _goToPreviousModule() {
    if (_currentModuleIndex > 0) {
      _selectModule(_currentModuleIndex - 1);
    }
  }

  void _onVideoProgress(double progress) {
    // Update progress in database
    // This would be implemented with actual progress tracking
  }

  void _onVideoCompleted() {
    // Mark module as completed
    // Auto-advance to next module
    Future.delayed(const Duration(seconds: 1), () {
      _goToNextModule();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedLocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.course.title),
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  _showModulesList(context);
                },
                tooltip: 'Course modules',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: LoadingWidget())
              : _modules.isEmpty
                  ? _buildEmptyState()
                  : Responsive(
                      mobile: _buildMobileLayout(),
                      desktop: _buildDesktopLayout(),
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No content available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Course content will be available soon.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Current module content
        Expanded(
          child: _buildModuleContent(),
        ),
        // Module navigation
        _buildMobileNavigation(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar with module list
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: _buildModulesList(),
        ),
        // Main content area
        Expanded(
          child: _buildModuleContent(),
        ),
      ],
    );
  }

  Widget _buildModuleContent() {
    if (_currentModule == null) {
      return const Center(child: Text('No module selected'));
    }

    return SingleChildScrollView(
      padding: ResponsivePadding.symmetric(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // Module header
          _buildModuleHeader(),
          
          const SizedBox(height: 24),
          
          // Module content based on type
          _buildModuleContentWidget(),
          
          const SizedBox(height: 32),
          
          // Module navigation (desktop)
          if (!Responsive.isMobile(context))
            _buildDesktopNavigation(),
        ],
      ),
    );
  }

  Widget _buildModuleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFB71C1C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Module ${_currentModuleIndex + 1} of ${_modules.length}',
                style: const TextStyle(
                  color: Color(0xFFB71C1C),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            _buildModuleTypeIcon(),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _currentModule!.title,
          style: TextStyle(
            fontSize: ResponsiveFontSize.heading2(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_currentModule!.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _currentModule!.description,
            style: TextStyle(
              fontSize: ResponsiveFontSize.body(context),
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${_currentModule!.estimatedDurationMinutes} minutes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleTypeIcon() {
    IconData icon;
    Color color;
    
    switch (_currentModule!.moduleType) {
      case 'video':
        icon = Icons.play_circle_outline;
        color = Colors.blue;
        break;
      case 'document':
        icon = Icons.description_outlined;
        color = Colors.green;
        break;
      case 'quiz':
        icon = Icons.quiz_outlined;
        color = Colors.orange;
        break;
      case 'live_session':
        icon = Icons.video_call_outlined;
        color = Colors.purple;
        break;
      default:
        icon = Icons.school_outlined;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildModuleContentWidget() {
    switch (_currentModule!.moduleType) {
      case 'video':
        return Consumer<EnhancedLocalizationService>(
          builder: (context, localizationService, child) {
            return VideoPlayerWidget(
              module: _currentModule!,
              languageCode: localizationService.currentLanguageCode,
              onProgressChanged: _onVideoProgress,
              onCompleted: _onVideoCompleted,
            );
          },
        );
      case 'document':
        return _buildDocumentContent();
      case 'quiz':
        return _buildQuizContent();
      case 'live_session':
        return _buildLiveSessionContent();
      default:
        return _buildGenericContent();
    }
  }

  Widget _buildDocumentContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            EnhancedLocalizationService.t('download_material'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Open document URL
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document download would start here'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz,
            size: 48,
            color: Colors.orange[600],
          ),
          const SizedBox(height: 16),
          Text(
            EnhancedLocalizationService.t('quiz'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Test your knowledge of this module',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Start quiz
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quiz functionality would start here'),
                ),
              );
            },
            child: const Text('Start Quiz'),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSessionContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.video_call,
            size: 48,
            color: Colors.purple[600],
          ),
          const SizedBox(height: 16),
          const Text(
            'Live Session',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join the live session with expert instructors',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Join live session
            },
            icon: const Icon(Icons.video_call),
            label: const Text('Join Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Text('Content not available'),
      ),
    );
  }

  Widget _buildModulesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            EnhancedLocalizationService.t('course_content'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _modules.length,
            itemBuilder: (context, index) {
              final module = _modules[index];
              final isSelected = index == _currentModuleIndex;
              
              return ListTile(
                selected: isSelected,
                selectedTileColor: const Color(0xFFB71C1C).withOpacity(0.1),
                leading: _buildModuleIcon(module.moduleType),
                title: Text(
                  module.title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text('${module.estimatedDurationMinutes} min'),
                trailing: isSelected 
                    ? const Icon(Icons.play_arrow, color: Color(0xFFB71C1C))
                    : null,
                onTap: () => _selectModule(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModuleIcon(String moduleType) {
    switch (moduleType) {
      case 'video':
        return const Icon(Icons.play_circle_outline, color: Colors.blue);
      case 'document':
        return const Icon(Icons.description_outlined, color: Colors.green);
      case 'quiz':
        return const Icon(Icons.quiz_outlined, color: Colors.orange);
      case 'live_session':
        return const Icon(Icons.video_call_outlined, color: Colors.purple);
      default:
        return const Icon(Icons.school_outlined, color: Colors.grey);
    }
  }

  Widget _buildMobileNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentModuleIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToPreviousModule,
                icon: const Icon(Icons.arrow_back),
                label: Text(EnhancedLocalizationService.t('previous_module')),
              ),
            ),
          const SizedBox(width: 16),
          if (_currentModuleIndex < _modules.length - 1)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _goToNextModule,
                icon: const Icon(Icons.arrow_forward),
                label: Text(EnhancedLocalizationService.t('next_module')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentModuleIndex > 0)
          OutlinedButton.icon(
            onPressed: _goToPreviousModule,
            icon: const Icon(Icons.arrow_back),
            label: Text(EnhancedLocalizationService.t('previous_module')),
          )
        else
          const SizedBox(),
        
        if (_currentModuleIndex < _modules.length - 1)
          ElevatedButton.icon(
            onPressed: _goToNextModule,
            icon: const Icon(Icons.arrow_forward),
            label: Text(EnhancedLocalizationService.t('next_module')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
          )
        else
          const SizedBox(),
      ],
    );
  }

  void _showModulesList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: _buildModulesList(),
      ),
    );
  }
}