import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/providers/theme_provider.dart';
import 'src/services/enhanced_auth_service.dart';
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedAuthService()),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => InstructorService()),
      ],
      child: const CimaLearnApp(),
    ),
  );
}

// Global Supabase client instance as per Flutter docs
final supabase = Supabase.instance.client;
}