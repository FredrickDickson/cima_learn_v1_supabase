import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/instructor_service.dart';

class InstructorAnalyticsPage extends StatefulWidget {
  final InstructorService instructorService;

  const InstructorAnalyticsPage({Key? key, required this.instructorService}) : super(key: key);

  @override
  State<InstructorAnalyticsPage> createState() => _InstructorAnalyticsPageState();
}

class _InstructorAnalyticsPageState extends State<InstructorAnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.instructorService,
      child: Consumer<InstructorService>(
        builder: (context, service, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics & Performance',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your teaching performance and student engagement.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                if (service.analytics != null) ...[
                  _buildOverviewCards(service.analytics!),
                  const SizedBox(height: 32),
                  _buildPerformanceCharts(),
                  const SizedBox(height: 32),
                  _buildCoursePerformance(),
                  const SizedBox(height: 32),
                  _buildStudentFeedback(),
                ] else
                  _buildLoadingState(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> analytics) {
    final cards = [
      {
        'title': 'Total Courses',
        'value': analytics['totalCourses']?.toString() ?? '0',
        'subtitle': 'Published courses',
        'icon': Icons.school,
        'color': const Color(0xFFB71C1C),
        'trend': '+2 this month',
        'trendUp': true,
      },
      {
        'title': 'Total Students',
        'value': analytics['totalEnrollments']?.toString() ?? '0',
        'subtitle': 'Enrolled students',
        'icon': Icons.people,
        'color': const Color(0xFF1976D2),
        'trend': '+${analytics['thisMonthEnrollments'] ?? 0} this month',
        'trendUp': true,
      },
      {
        'title': 'Total Revenue',
        'value': '₦${(analytics['totalRevenue'] ?? 0).toStringAsFixed(0)}',
        'subtitle': 'Lifetime earnings',
        'icon': Icons.monetization_on,
        'color': const Color(0xFF388E3C),
        'trend': '+₦${(analytics['thisMonthRevenue'] ?? 0).toStringAsFixed(0)} this month',
        'trendUp': true,
      },
      {
        'title': 'Average Rating',
        'value': '4.8',
        'subtitle': 'Course rating',
        'icon': Icons.star,
        'color': const Color(0xFFFF9800),
        'trend': '+0.2 from last month',
        'trendUp': true,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (card['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      card['icon'] as IconData,
                      color: card['color'] as Color,
                      size: 24,
                    ),
                  ),
                  Icon(
                    card['trendUp'] as bool ? Icons.trending_up : Icons.trending_down,
                    color: card['trendUp'] as bool ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                card['value'] as String,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card['title'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                card['trend'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: card['trendUp'] as bool ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceCharts() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enrollment Trends',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Chart Coming Soon',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue by Course',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Pie Chart\nComing Soon',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoursePerformance() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Course Title')),
                DataColumn(label: Text('Enrollments')),
                DataColumn(label: Text('Revenue')),
                DataColumn(label: Text('Rating')),
                DataColumn(label: Text('Completion Rate')),
                DataColumn(label: Text('Status')),
              ],
              rows: widget.instructorService.myCourses.map((course) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          course.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(Text((course.enrollmentCount ?? 0).toString())),
                    DataCell(Text('₦${(course.price * (course.enrollmentCount ?? 0)).toStringAsFixed(0)}')),
                    DataCell(
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(course.rating.toStringAsFixed(1)),
                        ],
                      ),
                    ),
                    DataCell(Text('85%')), // Mock completion rate
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(course.status ?? 'draft').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (course.status ?? 'draft').toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(course.status ?? 'draft'),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentFeedback() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Student Feedback',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Show all feedback
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mock feedback data
          ...[
            {
              'student': 'John Smith',
              'course': 'Introduction to Arbitration',
              'rating': 5,
              'comment': 'Excellent course! Very comprehensive and well-structured.',
              'date': '2 days ago',
            },
            {
              'student': 'Sarah Johnson',
              'course': 'Commercial Mediation',
              'rating': 4,
              'comment': 'Great content, would love more practical examples.',
              'date': '1 week ago',
            },
            {
              'student': 'Michael Brown',
              'course': 'Construction Disputes',
              'rating': 5,
              'comment': 'Fantastic instructor! Learned so much.',
              'date': '2 weeks ago',
            },
          ].map((feedback) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFB71C1C),
                            child: Text(
                              (feedback['student'] as String)[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feedback['student'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                feedback['course'] as String,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                size: 16,
                                color: index < (feedback['rating'] as int)
                                    ? Colors.orange
                                    : Colors.grey[300],
                              );
                            }),
                          ),
                          Text(
                            feedback['date'] as String,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feedback['comment'] as String,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'pending_approval':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}