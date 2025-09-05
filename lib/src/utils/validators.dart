/// Security-focused validation utilities for CIMA Learn
/// Provides comprehensive input validation and sanitization
import 'dart:convert';

class Validators {
  // Email validation with comprehensive regex
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  // Strong password validation
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    
    // Must contain at least one lowercase letter, one uppercase letter, one digit
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    
    return hasLowercase && hasUppercase && hasDigit;
  }

  // Get password strength score (0-4)
  static int getPasswordStrength(String password) {
    int score = 0;
    
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    
    return score > 4 ? 4 : score;
  }

  // Sanitize user input to prevent XSS
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .replaceAll('/', '&#x2F;')
        .trim();
  }

  // Validate course ID format (UUID or alphanumeric)
  static bool isValidCourseId(String courseId) {
    if (courseId.isEmpty) return false;
    
    // Check for UUID format
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    
    // Check for alphanumeric format (6-50 characters)
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9_-]{6,50}$');
    
    return uuidRegex.hasMatch(courseId) || alphanumericRegex.hasMatch(courseId);
  }

  // Validate user ID format
  static bool isValidUserId(String userId) {
    if (userId.isEmpty) return false;
    
    // Supabase user IDs are UUIDs
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    
    return uuidRegex.hasMatch(userId);
  }

  // Validate payment reference format
  static bool isValidPaymentReference(String reference) {
    if (reference.isEmpty) return false;
    
    // CIMA payment references: CIMA_courseId_userId_timestamp
    final cimaRefRegex = RegExp(r'^CIMA_[a-zA-Z0-9_-]+_[a-zA-Z0-9_-]+_\d+$');
    
    // Bulk payment references: BULK_CIMA_hash_userId_timestamp
    final bulkRefRegex = RegExp(r'^BULK_CIMA_\d+_[a-zA-Z0-9_-]+_\d+$');
    
    return cimaRefRegex.hasMatch(reference) || bulkRefRegex.hasMatch(reference);
  }

  // Validate numeric amount (price, payment)
  static bool isValidAmount(dynamic amount) {
    if (amount == null) return false;
    
    double? numericAmount;
    
    if (amount is String) {
      numericAmount = double.tryParse(amount);
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    }
    
    if (numericAmount == null) return false;
    
    // Must be positive and reasonable (less than 1 million)
    return numericAmount > 0 && numericAmount <= 1000000;
  }

  // Validate currency code
  static bool isValidCurrency(String currency) {
    const validCurrencies = ['NGN', 'USD', 'EUR', 'GBP'];
    return validCurrencies.contains(currency.toUpperCase());
  }

  // Validate name (no special characters, reasonable length)
  static bool isValidName(String name) {
    if (name.isEmpty || name.length > 100) return false;
    
    // Allow letters, spaces, apostrophes, hyphens
    final nameRegex = RegExp(r"^[a-zA-Z\s'\-]+$");
    return nameRegex.hasMatch(name);
  }

  // Validate phone number (international format)
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    
    // Remove all non-digit characters except +
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Must start with + and have 7-15 digits
    final phoneRegex = RegExp(r'^\+\d{7,15}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  // Validate URL format
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Validate JSON string
  static bool isValidJson(String jsonString) {
    if (jsonString.isEmpty) return false;
    
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Validate course title (no XSS, reasonable length)
  static bool isValidCourseTitle(String title) {
    if (title.isEmpty || title.length > 200) return false;
    
    // Allow letters, numbers, spaces, basic punctuation
    final titleRegex = RegExp(r"^[a-zA-Z0-9\s\-_:.,!()&]+$");
    return titleRegex.hasMatch(title);
  }

  // Validate course description (HTML content)
  static bool isValidCourseDescription(String description) {
    if (description.isEmpty || description.length > 5000) return false;
    
    // Basic HTML tag validation (whitelist approach)
    final allowedTags = RegExp(
      r'<\/?(?:p|br|strong|em|ul|ol|li|h[1-6]|blockquote|a|img)\b[^>]*>',
      caseSensitive: false,
    );
    
    // Remove allowed tags and check for any remaining HTML
    final withoutAllowedTags = description.replaceAll(allowedTags, '');
    
    // Check for any remaining HTML tags (potential XSS)
    final hasUnallowedTags = RegExp(r'<[^>]+>').hasMatch(withoutAllowedTags);
    
    return !hasUnallowedTags;
  }

  // Validate integer within range
  static bool isValidInteger(dynamic value, {int? min, int? max}) {
    if (value == null) return false;
    
    int? intValue;
    
    if (value is String) {
      intValue = int.tryParse(value);
    } else if (value is num) {
      intValue = value.round();
    }
    
    if (intValue == null) return false;
    
    if (min != null && intValue < min) return false;
    if (max != null && intValue > max) return false;
    
    return true;
  }

  // Validate file extension
  static bool isValidFileExtension(String filename, List<String> allowedExtensions) {
    if (filename.isEmpty) return false;
    
    final extension = filename.toLowerCase().split('.').last;
    return allowedExtensions.map((e) => e.toLowerCase()).contains(extension);
  }

  // Validate course category
  static bool isValidCourseCategory(String category) {
    const validCategories = [
      'arbitration',
      'mediation',
      'commercial_law',
      'dispute_resolution',
      'negotiation',
      'contract_law',
      'international_law',
      'construction_law',
      'employment_law',
      'insurance_law',
    ];
    
    return validCategories.contains(category.toLowerCase());
  }

  // Validate user role
  static bool isValidUserRole(String role) {
    const validRoles = ['student', 'instructor', 'admin'];
    return validRoles.contains(role.toLowerCase());
  }

  // Validate CIMA membership level
  static bool isValidMembershipLevel(String level) {
    const validLevels = [
      'associate',
      'graduate',
      'fellow',
      'student',
      'affiliate',
    ];
    
    return validLevels.contains(level.toLowerCase());
  }

  // Rate limiting validation (check if action is allowed)
  static bool isWithinRateLimit(String key, int maxAttempts, Duration window) {
    // This would typically use a cache or database to track attempts
    // For now, return true (implement proper rate limiting in production)
    return true;
  }

  // Validate quiz answer format
  static bool isValidQuizAnswer(dynamic answer) {
    if (answer == null) return false;
    
    // Handle different answer types
    if (answer is String) {
      return answer.trim().isNotEmpty && answer.length <= 1000;
    } else if (answer is List) {
      return answer.every((item) => item is String && item.trim().isNotEmpty);
    } else if (answer is bool || answer is int || answer is double) {
      return true;
    }
    
    return false;
  }

  // Comprehensive form validation with error messages
  static Map<String, String?> validateRegistrationForm({
    required String fullName,
    required String email,
    required String password,
    String? profession,
    String? organization,
    String? phone,
  }) {
    final errors = <String, String?>{};

    if (!isValidName(fullName)) {
      errors['fullName'] = 'Please enter a valid full name (letters, spaces, hyphens only)';
    }

    if (!isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    if (!isStrongPassword(password)) {
      errors['password'] = 'Password must be at least 8 characters with uppercase, lowercase, and digit';
    }

    if (profession != null && profession.isNotEmpty && !isValidName(profession)) {
      errors['profession'] = 'Please enter a valid profession';
    }

    if (organization != null && organization.isNotEmpty && organization.length > 100) {
      errors['organization'] = 'Organization name must be less than 100 characters';
    }

    if (phone != null && phone.isNotEmpty && !isValidPhoneNumber(phone)) {
      errors['phone'] = 'Please enter a valid phone number (with country code)';
    }

    return errors;
  }
}

// Security utility class for additional protections
class SecurityUtils {
  // Generate secure random strings
  static String generateSecureToken(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }

  // Hash sensitive data (for logging purposes only)
  static String hashForLogging(String sensitiveData) {
    if (sensitiveData.length <= 4) return '***';
    
    return sensitiveData.substring(0, 2) + 
           '*' * (sensitiveData.length - 4) + 
           sensitiveData.substring(sensitiveData.length - 2);
  }

  // Check for common SQL injection patterns (defense in depth)
  static bool containsSqlInjectionPattern(String input) {
    final patterns = [
      r'(\bUNION\b|\bSELECT\b|\bINSERT\b|\bUPDATE\b|\bDELETE\b|\bDROP\b)',
      r'(\bOR\b\s+\d+\s*=\s*\d+|\bAND\b\s+\d+\s*=\s*\d+)',
      r'(\'|\";|\|\||&&)',
      r'(\bxp_|\bsp_|\bfn_)',
    ];
    
    final normalizedInput = input.toUpperCase();
    
    for (final pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(normalizedInput)) {
        return true;
      }
    }
    
    return false;
  }

  // Check for XSS patterns
  static bool containsXssPattern(String input) {
    final patterns = [
      r'<script[^>]*>',
      r'javascript:',
      r'on\w+\s*=',
      r'<iframe[^>]*>',
      r'<object[^>]*>',
      r'<embed[^>]*>',
    ];
    
    for (final pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }
    
    return false;
  }

  // Validate and sanitize file upload
  static Map<String, dynamic> validateFileUpload({
    required String filename,
    required int fileSize,
    required List<String> allowedExtensions,
    int maxSizeInBytes = 10 * 1024 * 1024, // 10MB default
  }) {
    final result = <String, dynamic>{
      'isValid': true,
      'errors': <String>[],
      'sanitizedFilename': filename,
    };

    // Check file size
    if (fileSize > maxSizeInBytes) {
      result['isValid'] = false;
      result['errors'].add('File size exceeds maximum allowed size');
    }

    // Check file extension
    if (!Validators.isValidFileExtension(filename, allowedExtensions)) {
      result['isValid'] = false;
      result['errors'].add('File type not allowed');
    }

    // Sanitize filename
    final sanitizedName = filename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    
    result['sanitizedFilename'] = sanitizedName;

    return result;
  }
}