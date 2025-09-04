import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to CIMA Learn',
      description: 'Your gateway to professional dispute resolution training. Join the Center for International Mediators and Arbitrators community.',
      icon: Icons.school,
      color: const Color(0xFFB71C1C),
    ),
    OnboardingPage(
      title: 'World-Class Training',
      description: 'Learn from leading experts in arbitration and mediation through our hybrid learning model combining online and in-person sessions.',
      icon: Icons.workspace_premium,
      color: const Color(0xFF1976D2),
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      description: 'Monitor your learning journey with detailed progress tracking, course completion certificates, and professional development records.',
      icon: Icons.trending_up,
      color: const Color(0xFF388E3C),
    ),
    OnboardingPage(
      title: 'Professional Certification',
      description: 'Earn globally recognized CIMA certifications and advance your career from Associate (ACIMArb) to Fellowship (FCIMArb).',
      icon: Icons.card_membership,
      color: const Color(0xFFF57C00),
    ),
    OnboardingPage(
      title: 'Global Network',
      description: 'Connect with arbitrators, legal practitioners, and experts worldwide through our exclusive professional community.',
      icon: Icons.public,
      color: const Color(0xFF7B1FA2),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: ResponsivePadding.symmetric(context),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPageContent(_pages[index]);
                  },
                ),
              ),
              
              // Page indicators
              _buildPageIndicators(),
              
              const SizedBox(height: 32),
              
              // Navigation buttons
              Padding(
                padding: ResponsivePadding.symmetric(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    _currentPage > 0
                        ? TextButton.icon(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                            ),
                          )
                        : const SizedBox(width: 100),
                    
                    // Next/Get Started button
                    ElevatedButton.icon(
                      onPressed: _nextPage,
                      icon: Icon(_currentPage == _pages.length - 1 
                          ? Icons.check 
                          : Icons.arrow_forward),
                      label: Text(_currentPage == _pages.length - 1 
                          ? 'Get Started' 
                          : 'Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    return Padding(
      padding: ResponsivePadding.symmetric(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: ResponsiveFontSize.heading1(context),
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB71C1C),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: ResponsiveFontSize.body(context),
              color: Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _pages.asMap().entries.map((entry) {
        final index = entry.key;
        final isActive = index == _currentPage;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFB71C1C) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}