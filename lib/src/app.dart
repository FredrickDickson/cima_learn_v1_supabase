import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_routes.dart';
import '../config/app_theme.dart';
import 'config/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/enrolled_courses_page.dart';
import 'screens/not_found_page.dart';
import 'screens/onboarding_screen.dart';
import 'screens/learning_paths_page.dart';
import 'screens/free_intro_course_page.dart';
import 'screens/admin_dashboard.dart';
import 'screens/instructor_dashboard.dart';
import 'screens/cart_page.dart';

class CimaLearnApp extends StatefulWidget {
  const CimaLearnApp({super.key});

  @override
  State<CimaLearnApp> createState() => _CimaLearnAppState();
}

class _CimaLearnAppState extends State<CimaLearnApp> {
  bool _isOnboardingCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('onboarding_completed') ?? false;
      setState(() {
        _isOnboardingCompleted = completed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isOnboardingCompleted = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFB71C1C),
                  Color(0xFF8B1538),
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'CIMA Learn',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          if (themeProvider.isLoading) {
            return MaterialApp(
              home: Scaffold(
                body: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFB71C1C),
                        Color(0xFF8B1538),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CIMA Learn - Dispute Resolution Training',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: _isOnboardingCompleted ? '/' : '/onboarding',
            routes: {
              '/': (context) => const HomePage(),
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignupPage(),
              '/enrolled-courses': (context) => const EnrolledCoursesPage(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/learning-paths': (context) => const LearningPathsPage(),
              '/free-intro-course': (context) => const FreeIntroCourse(),
              '/admin': (context) => const AdminDashboard(),
              '/instructor': (context) => const InstructorDashboard(),
              '/cart': (context) => const CartPage(),
            },
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (context) => const NotFoundPage(),
            ),
          );
        },
      ),
    );
  }
}