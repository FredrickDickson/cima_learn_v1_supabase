import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with environment variables
  // These variables are exposed on the app, and that's completely fine 
  // since we have Row Level Security enabled on our Database.
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://pgmtaemwcueobaexthaq.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbXRhZW13Y3Vlb2JhZXh0aGFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0NTk3NzcsImV4cCI6MjA0MTAzNTc3N30.Sfa7Z1UjmTkz5-rnUz4u_xTJ8oFI1EH45lJGaXqg_iY'),
    );
    
    print('Supabase initialized successfully');
    print('CIMA Learn ready to launch!');
  } catch (e) {
    print('Failed to initialize Supabase: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const CimaLearnApp(),
    ),
  );
}