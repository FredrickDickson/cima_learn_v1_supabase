import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';

class FreeIntroCourse extends StatefulWidget {
  const FreeIntroCourse({Key? key}) : super(key: key);

  @override
  State<FreeIntroCourse> createState() => _FreeIntroCourseState();
}

class _FreeIntroCourseState extends State<FreeIntroCourse> {
  int _currentModule = 0;
  bool _hasStarted = false;

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Welcome to Dispute Resolution',
      'duration': '5 min',
      'type': 'video',
      'description': 'An introduction to the world of alternative dispute resolution and why it matters.',
      'completed': false,
    },
    {
      'title': 'Types of Dispute Resolution',
      'duration': '8 min', 
      'type': 'video',
      'description': 'Understanding arbitration, mediation, and other ADR methods.',
      'completed': false,
    },
    {
      'title': 'CIMA\'s Role in ADR',
      'duration': '7 min',
      'type': 'video', 
      'description': 'Learn about CIMA\'s mission and how we support dispute resolution professionals.',
      'completed': false,
    },
    {
      'title': 'Quick Knowledge Check',
      'duration': '5 min',
      'type': 'quiz',
      'description': 'Test your understanding with a brief interactive quiz.',
      'completed': false,
    },
    {
      'title': 'Your Next Steps',
      'duration': '3 min',
      'type': 'video',
      'description': 'Discover how to continue your learning journey with CIMA.',
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Header(isMobile: isMobile),
          const SizedBox(height: 24),
          
          if (!_hasStarted) _buildWelcomeSection(isMobile) else _buildCourseContent(isMobile),
          
          const SizedBox(height: 40),
          const Footer(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(bool isMobile) {
    return Column(
      children: [
        // Hero Section
        Container(
          padding: EdgeInsets.all(isMobile ? 24 : 48),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF388E3C),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Color(0xFF4CAF50),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Introduction to Dispute Resolution',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'FREE 30-MINUTE COURSE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Get started with the fundamentals of alternative dispute resolution. Perfect for beginners and those curious about the field.',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: isMobile ? double.infinity : 300,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasStarted = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.play_arrow, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Start Free Course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Course Overview
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What You\'ll Learn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              
              ..._modules.map((module) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        module['type'] == 'quiz' ? Icons.quiz : Icons.play_circle_outline,
                        color: const Color(0xFF4CAF50),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            module['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        module['duration'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseContent(bool isMobile) {
    final currentModule = _modules[_currentModule];
    
    return Column(
      children: [
        // Progress Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _hasStarted = false;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      'Module ${_currentModule + 1} of ${_modules.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (_currentModule + 1) / _modules.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Course Content
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentModule['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentModule['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Video/Quiz Content Placeholder
              Container(
                width: double.infinity,
                height: isMobile ? 200 : 300,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentModule['type'] == 'quiz' ? Icons.quiz : Icons.play_circle_outline,
                      size: 64,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentModule['type'] == 'quiz' ? 'Interactive Quiz' : 'Video Content',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Duration: ${currentModule['duration']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Navigation Buttons
              Row(
                children: [
                  if (_currentModule > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentModule--;
                          });
                        },
                        child: const Text('Previous'),
                      ),
                    ),
                  
                  if (_currentModule > 0) const SizedBox(width: 16),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentModule < _modules.length - 1) {
                          setState(() {
                            _modules[_currentModule]['completed'] = true;
                            _currentModule++;
                          });
                        } else {
                          // Course completed
                          _showCompletionDialog();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                      child: Text(
                        _currentModule < _modules.length - 1 ? 'Next Module' : 'Complete Course',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFF4CAF50), size: 32),
            SizedBox(width: 12),
            Text('Congratulations!'),
          ],
        ),
        content: const Text(
          'You\'ve completed the Introduction to Dispute Resolution course! You\'re now ready to explore our full course catalog and continue your learning journey.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Explore More Courses'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/learning-paths');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Choose Learning Path'),
          ),
        ],
      ),
    );
  }
}