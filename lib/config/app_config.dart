/// Centralized application configuration
/// All environment variables and API keys are managed here
/// SECURITY: No default values for API keys - all come from environment only
class AppConfig {
  // Supabase Configuration - Values come from environment only
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_KEY');

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
  static bool get isSupabaseConfigured => 
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
  
  static bool get isPaystackConfigured => 
      paystackPublicKey.isNotEmpty && paystackSecretKey.isNotEmpty;

  // Dynamic URL generation for callbacks and redirects
  static String getAuthCallbackUrl() => '$appProtocol://$appDomain/auth/callback';
  static String getPasswordResetUrl() => '$appProtocol://$appDomain/reset-password';
  static String getPaymentCallbackUrl() => '$appProtocol://$appDomain/payment/callback';

  // Configuration validation - graceful handling for development
  static void validateConfig() {
    if (!isSupabaseConfigured) {
      print('⚠ Warning: Supabase configuration missing. Please set SUPABASE_URL and SUPABASE_KEY environment variables.');
    }
    if (!isPaystackConfigured) {
      print('⚠ Warning: Paystack configuration missing. Payment features will not work.');
    }
    
    // Validate domain configuration
    if (appDomain.isEmpty) {
      print('⚠ Warning: APP_DOMAIN not configured. Using default domain.');
    }
  }
}