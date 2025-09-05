import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'config/app_config.dart';
import 'src/app.dart';
import 'src/providers/theme_provider.dart';
import 'src/services/enhanced_auth_service.dart';
import 'src/services/cart_service.dart';
import 'src/services/instructor_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Validate configuration before initialization
    AppConfig.validateConfig();
    
    // Initialize Supabase using centralized configuration
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseKey,
    );
    print('Supabase initialized successfully');
    print('Payment configuration: ${AppConfig.isPaystackConfigured ? "✓ Configured" : "⚠ Missing"}');
  } catch (e) {
    print('Supabase initialization failed: $e');
  }

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