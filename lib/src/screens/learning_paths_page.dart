import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';

class LearningPathsPage extends StatelessWidget {
  const LearningPathsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Header(isMobile: isMobile),
          const SizedBox(height: 32),
          
          // Hero Section
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB71C1C),
                  Color(0xFF8B1538),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Choose Your Learning Path',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select the path that matches your professional level and career goals',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Learning Paths Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: _learningPaths.length,
            itemBuilder: (context, index) {
              final path = _learningPaths[index];
              return _buildLearningPathCard(context, path, isMobile);
            },
          ),
          
          const SizedBox(height: 40),
          const Footer(),
        ],
      ),
    );
  }

  Widget _buildLearningPathCard(BuildContext context, Map<String, dynamic> path, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and level
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: path['color'].withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: path['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    path['icon'],
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  path['title'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: path['color'],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  path['subtitle'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'What you\'ll learn:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  ...path['topics'].map<Widget>((topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: path['color'],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            topic,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  
                  const Spacer(),
                  
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/', arguments: {
                          'filter_level': path['level'],
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: path['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Start ${path['title']} Path',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> _learningPaths = [
  {
    'title': 'Foundation Track',
    'subtitle': 'Associate (ACIMArb)',
    'level': 'associate',
    'color': const Color(0xFF4CAF50),
    'icon': Icons.school,
    'description': 'Perfect for beginners entering the world of dispute resolution. Build your foundational knowledge and skills.',
    'topics': [
      'Introduction to Dispute Resolution',
      'Basic Arbitration Principles',
      'Mediation Fundamentals',
      'Legal Framework Overview',
      'Professional Ethics',
    ],
  },
  {
    'title': 'Professional Track',
    'subtitle': 'Member (MCIMArb)',
    'level': 'member',
    'color': const Color(0xFF2196F3),
    'icon': Icons.business_center,
    'description': 'For practicing professionals seeking to advance their expertise and take on more complex cases.',
    'topics': [
      'Advanced Arbitration Procedures',
      'Commercial Mediation Techniques',
      'Cross-border Disputes',
      'Evidence and Procedure',
      'Award Writing and Enforcement',
    ],
  },
  {
    'title': 'Expert Track',
    'subtitle': 'Fellow (FCIMArb)',
    'level': 'fellow',
    'color': const Color(0xFFB71C1C),
    'icon': Icons.workspace_premium,
    'description': 'Elite-level training for senior practitioners, thought leaders, and those aspiring to tribunal appointments.',
    'topics': [
      'Complex Multi-party Disputes',
      'Investment Treaty Arbitration',
      'Emergency Arbitration',
      'Tribunal Leadership',
      'Industry Thought Leadership',
    ],
  },
];