/// Application configuration constants
class AppConfig {
  /// Paystack public key for payment processing
  static const String paystackPublicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: '',
  );

  /// Paystack secret key for payment processing (server-side only)
  static const String paystackSecretKey = String.fromEnvironment(
    'PAYSTACK_SECRET_KEY', 
    defaultValue: '',
  );

  /// Application environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// API base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pgmtaemwcueobaexthaq.supabase.co',
  );

  /// Maximum upload file size (in bytes)
  static const int maxUploadSize = 100 * 1024 * 1024; // 100 MB

  /// Supported video formats
  static const List<String> supportedVideoFormats = [
    '.mp4',
    '.webm',
    '.mov',
    '.avi',
  ];

  /// Supported image formats
  static const List<String> supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];

  /// Default pagination size
  static const int defaultPageSize = 20;

  /// Maximum quiz time limit (in minutes)
  static const int maxQuizTimeLimit = 180;

  /// Default course thumbnail
  static const String defaultCourseThumbnail = '/assets/images/default-course.jpg';
}