import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Only initialize Supabase if we have a valid key
    if (!isOfflineMode && supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }
  } catch (e) {
    // Silently fail and continue in offline mode
    print('Supabase initialization failed, continuing in offline mode: $e');
  }

  runApp(const CimaLearnApp());
}