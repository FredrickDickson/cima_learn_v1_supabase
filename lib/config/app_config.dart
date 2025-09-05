/// Centralized application configuration
/// Following Flutter docs pattern - Supabase credentials are public with RLS protection
class AppConfig {
  // Supabase Configuration - Uses environment variables for best practices
  // These are safe to expose as Row Level Security protects the data
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://pgmtaemwcueobaexthaq.supabase.co');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbXRhZW13Y3Vlb2JhZXh0aGFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0NTk3NzcsImV4cCI6MjA0MTAzNTc3N30.Sfa7Z1UjmTkz5-rnUz4u_xTJ8oFI1EH45lJGaXqg_iY');

  // Paystack Payment Configuration - Values come from environment only
  static const String paystackPublicKey = String.fromEnvironment('PAYSTACK_PUBLIC_KEY');
  static const String paystackSecretKey = String.fromEnvironment('PAYSTACK_SECRET_KEY');

  // App Domain Configuration - Makes URLs configurable for different environments
  static const String appDomain = String.fromEnvironment('APP_DOMAIN', defaultValue: 'cimalearning.com');
  static const String appProtocol = String.fromEnvironment('APP_PROTOCOL', defaultValue: 'https');

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
  static bool get isSupabaseConfigured => true; // Always configured now
  
  static bool get isPaystackConfigured => 
      paystackPublicKey.isNotEmpty && paystackSecretKey.isNotEmpty;

  // Dynamic URL generation for callbacks and redirects
  static String getAuthCallbackUrl() => '$appProtocol://$appDomain/auth/callback';
  static String getPasswordResetUrl() => '$appProtocol://$appDomain/reset-password';
  static String getPaymentCallbackUrl() => '$appProtocol://$appDomain/payment/callback';

  // Configuration validation - simplified for hardcoded Supabase
  static void validateConfig() {
    print('✓ Supabase: Configured with hardcoded credentials');
    if (!isPaystackConfigured) {
      print('⚠ Warning: Paystack configuration missing. Payment features will not work.');
    }
    print('✓ Domain: $appDomain configured');
  }
}