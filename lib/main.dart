import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/supabase_config.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Could not load .env file: $e');
  }

  try {
    // Initialize Supabase with the provided credentials
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Supabase initialization failed: $e');
  }

  runApp(const CimaLearnApp());
}