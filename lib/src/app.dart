import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../config/app_theme.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/enrolled_courses_page.dart';
import 'screens/not_found_page.dart';

class CimaLearnApp extends StatelessWidget {
  const CimaLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CIMA Learn',
      theme: appTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/enrolled-courses': (context) => const EnrolledCoursesPage(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const NotFoundPage(),
      ),
    );
  }
}