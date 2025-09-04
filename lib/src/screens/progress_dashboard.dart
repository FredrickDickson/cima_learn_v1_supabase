import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_progress.dart';
import '../services/progress_service.dart';
import '../utils/responsive.dart';
import '../widgets/loading_widget.dart';
import '../screens/course_detail_page.dart';
import '../models/course.dart';

class ProgressDashboard extends StatefulWidget {
  const ProgressDashboard({Key? key}) : super(key: key);

  @override
  State<ProgressDashboard> createState() => _ProgressDashboardState();
}

class _ProgressDashboardState extends State<ProgressDashboard> {
  final ProgressService _progressService = ProgressService();
  List<CourseProgress> _courseProgress = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final progress = await _progressService.getUserCourseProgress(user.id);
      final stats = await _progressService.getUserStatistics(user.id);

      setState(() {
        _courseProgress = progress;
        _statistics = stats;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading progress: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Progress'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : RefreshIndicator(
              onRefresh: _loadProgressData,
              child: SingleChildScrollView(
                padding: ResponsivePadding.symmetric(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildStatisticsCards(),
                    const SizedBox(height: 32),
                    _buildProgressOverview(),
                    const SizedBox(height: 32),
                    _buildCourseProgressList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Statistics',
          style: TextStyle(
            fontSize: ResponsiveFontSize.heading2(context),
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB71C1C),
          ),
        ),
        const SizedBox(height: 16),
        Responsive(
          mobile: _buildStatsMobile(),
          desktop: _buildStatsDesktop(),
        ),
      ],
    );
  }

  Widget _buildStatsMobile() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(
              'Total Courses',
              _statistics['totalCourses']?.toString() ?? '0',
              Icons.school,
              Colors.blue,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              'Completed',
              _statistics['completedCourses']?.toString() ?? '0',
              Icons.check_circle,
              Colors.green,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(
              'In Progress',
              _statistics['inProgressCourses']?.toString() ?? '0',
              Icons.play_circle,
              Colors.orange,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              'Completion Rate',
              '${_statistics['completionRate']?.toInt() ?? 0}%',
              Icons.trending_up,
              const Color(0xFFB71C1C),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsDesktop() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          'Total Courses',
          _statistics['totalCourses']?.toString() ?? '0',
          Icons.school,
          Colors.blue,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          'Completed',
          _statistics['completedCourses']?.toString() ?? '0',
          Icons.check_circle,
          Colors.green,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          'In Progress',
          _statistics['inProgressCourses']?.toString() ?? '0',
          Icons.play_circle,
          Colors.orange,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          'Completion Rate',
          '${_statistics['completionRate']?.toInt() ?? 0}%',
          Icons.trending_up,
          const Color(0xFFB71C1C),
        )),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveFontSize.heading2(context),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveFontSize.body(context),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverview() {
    if (_courseProgress.isEmpty) {
      return const SizedBox.shrink();
    }

    final averageProgress = _statistics['averageProgress']?.toDouble() ?? 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: ResponsiveFontSize.heading3(context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: averageProgress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Text(
              '${averageProgress.toInt()}% Average Progress',
              style: TextStyle(
                fontSize: ResponsiveFontSize.body(context),
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB71C1C),
              ),
            ),
            if (_statistics['totalTimeSpent'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Total Time Spent: ${_formatDuration(_statistics['totalTimeSpent'])}',
                style: TextStyle(
                  fontSize: ResponsiveFontSize.body(context),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgressList() {
    if (_courseProgress.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Icon(
                Icons.school_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Courses Enrolled',
                style: TextStyle(
                  fontSize: ResponsiveFontSize.heading3(context),
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start learning by enrolling in a course!',
                style: TextStyle(
                  fontSize: ResponsiveFontSize.body(context),
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Browse Courses',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Progress',
          style: TextStyle(
            fontSize: ResponsiveFontSize.heading2(context),
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB71C1C),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _courseProgress.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final progress = _courseProgress[index];
            return _buildCourseProgressCard(progress);
          },
        ),
      ],
    );
  }

  Widget _buildCourseProgressCard(CourseProgress progress) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to course detail
          // You would need to implement this with actual course data
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress.courseTitle,
                          style: TextStyle(
                            fontSize: ResponsiveFontSize.heading3(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusChip(progress.status),
                      ],
                    ),
                  ),
                  Text(
                    progress.formattedProgress,
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.heading3(context),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB71C1C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.progressPercentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress.isCompleted ? Colors.green : const Color(0xFFB71C1C),
                ),
                minHeight: 6,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Modules: ${progress.completedModules}/${progress.totalModules}',
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.body(context),
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Last accessed: ${_formatDate(progress.lastAccessedAt)}',
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.body(context),
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'completed':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        displayText = 'Completed';
        break;
      case 'in_progress':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        displayText = 'In Progress';
        break;
      case 'paused':
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        displayText = 'Paused';
        break;
      default:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        displayText = 'Enrolled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}