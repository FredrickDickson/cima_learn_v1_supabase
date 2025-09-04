const String supabaseUrl = 'https://pgmtaemwcueobaexthaq.supabase.co';

// Web-compatible approach: We'll check for environment variables at runtime
// and fall back to offline mode if not available
String get supabaseAnonKey {
  // Try to get from compile-time environment first
  const compileTimeKey = String.fromEnvironment('SUPABASE_KEY', defaultValue: '');
  if (compileTimeKey.isNotEmpty) {
    return compileTimeKey;
  }
  
  // For now, we'll use a placeholder that allows the app to work in demo mode
  // In a real production setup, you'd inject this differently
  return '';
}

// Add a flag to check if we're in offline/demo mode
bool get isOfflineMode => supabaseAnonKey.isEmpty;