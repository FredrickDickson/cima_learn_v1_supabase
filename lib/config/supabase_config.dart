import 'app_config.dart';

// Use centralized configuration - no more hardcoded values
String get supabaseUrl => AppConfig.supabaseUrl;
String get supabaseAnonKey => AppConfig.supabaseKey;

// Add a flag to check if we're in offline/demo mode  
bool get isOfflineMode => supabaseAnonKey.isEmpty;