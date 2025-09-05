import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/providers/theme_provider.dart';
import 'src/blocs/auth/auth_bloc.dart';
import 'src/blocs/course/course_bloc.dart';
import 'src/blocs/video/video_bloc.dart';
import 'src/blocs/payment/payment_bloc.dart';
import 'src/blocs/quiz/quiz_bloc.dart';
import 'src/blocs/instructor/instructor_bloc.dart';
import 'src/blocs/admin/admin_bloc.dart';
import 'src/services/cart_service.dart';
import 'src/services/instructor_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with direct credentials as per Flutter docs
  // These variables are exposed on the app, and that's completely fine 
  // since we have Row Level Security enabled on our Database.
  await Supabase.initialize(
    url: 'https://pgmtaemwcueobaexthaq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbXRhZW13Y3Vlb2JhZXh0aGFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0NTk3NzcsImV4cCI6MjA0MTAzNTc3N30.Sfa7Z1UjmTkz5-rnUz4u_xTJ8oFI1EH45lJGaXqg_iY',
  );
  
  print('Supabase initialized successfully');
  print('CIMA Learn ready to launch!');

  runApp(
    MultiBlocProvider(
      providers: [
        // Theme provider (keeping as Provider for now)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // BLoC providers for comprehensive state management
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => CourseBloc()),
        BlocProvider(create: (_) => VideoBloc()),
        BlocProvider(create: (_) => PaymentBloc()),
        BlocProvider(create: (_) => QuizBloc()),
        BlocProvider(create: (_) => InstructorBloc()),
        BlocProvider(create: (_) => AdminBloc()),
        
        // Legacy providers (will migrate these later)
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => InstructorService()),
      ],
      child: const CimaLearnApp(),
    ),
  );
}