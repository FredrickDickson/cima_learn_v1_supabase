/// Centralized application configuration
/// All environment variables and API keys are managed here
class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pgmtaemwcueobaexthaq.supabase.co',
  );
  
  static const String supabaseKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbXRhZW13Y3Vlb2JhZXh0aGFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4NTcwMDcsImV4cCI6MjA3MjQzMzAwN30.UleVbd7A9Fu8ceNgsJdi0Vc226IT0AuhJv7bH-3I4QI',
  );

  // Paystack Payment Configuration
  static const String paystackPublicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: '',
  );
  
  static const String paystackSecretKey = String.fromEnvironment(
    'PAYSTACK_SECRET_KEY',
    defaultValue: '',
  );

  // Application Configuration
  static const String appName = 'CIMA Learn';
  static const String appVersion = '1.0.0';
  static const String defaultLanguage = 'en';

  // API Configuration
  static const int apiTimeout = 30; // seconds
  static const String apiVersion = 'v1';

  // Development flags
  static const bool isDevelopment = bool.fromEnvironment(
    'FLUTTER_DEBUG',
    defaultValue: false,
  );

  // Validation helpers
  static bool get isSupabaseConfigured => 
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
  
  static bool get isPaystackConfigured => 
      paystackPublicKey.isNotEmpty && paystackSecretKey.isNotEmpty;

  // Configuration validation
  static void validateConfig() {
    assert(isSupabaseConfigured, 'Supabase configuration is missing');
    
    if (!isPaystackConfigured) {
      print('Warning: Paystack configuration is missing. Payment features will not work.');
    }
  }
}