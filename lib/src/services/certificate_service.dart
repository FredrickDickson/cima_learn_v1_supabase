import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'enhanced_auth_service.dart';

class CertificateService {
  static final CertificateService _instance = CertificateService._internal();
  factory CertificateService() => _instance;
  CertificateService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final EnhancedAuthService _authService = EnhancedAuthService();

  // Generate certificate for course completion
  Future<String?> generateCourseCertificate({
    required String courseId,
    required String courseTitle,
    required String instructorName,
    required DateTime completionDate,
    required double finalScore,
  }) async {
    if (!_authService.isAuthenticated) {
      throw Exception('User must be authenticated to generate certificate');
    }

    try {
      final userProfile = _authService.userProfile;
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      final certificateId = _generateCertificateId(courseId);
      final certificateData = {
        'id': certificateId,
        'user_id': _authService.userId,
        'course_id': courseId,
        'certificate_type': 'course_completion',
        'recipient_name': userProfile['full_name'] ?? 'Student',
        'course_title': courseTitle,
        'instructor_name': instructorName,
        'completion_date': completionDate.toIso8601String(),
        'final_score': finalScore,
        'certificate_number': _generateCertificateNumber(),
        'issued_at': DateTime.now().toIso8601String(),
        'valid_until': DateTime.now().add(const Duration(days: 365 * 3)).toIso8601String(), // Valid for 3 years
        'verification_code': _generateVerificationCode(),
        'is_verified': true,
        'template_used': 'cima_standard',
      };

      // Store certificate in database
      await _supabase.from('certificates').insert(certificateData);

      // Update enrollment record
      await _supabase
          .from('enrollments')
          .update({
            'certificate_issued': true,
            'certificate_url': 'certificates/$certificateId',
            'completion_percentage': 100.0,
            'completed_at': completionDate.toIso8601String(),
          })
          .eq('user_id', _authService.userId)
          .eq('course_id', courseId);

      return certificateId;
    } catch (e) {
      debugPrint('Error generating certificate: $e');
      rethrow;
    }
  }

  // Get user's certificates
  Future<List<Map<String, dynamic>>> getUserCertificates() async {
    if (!_authService.isAuthenticated) return [];

    try {
      final response = await _supabase
          .from('certificates')
          .select('''
            *,
            courses(title, instructor, image)
          ''')
          .eq('user_id', _authService.userId)
          .order('issued_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching certificates: $e');
      return [];
    }
  }

  // Verify certificate by verification code
  Future<Map<String, dynamic>?> verifyCertificate(String verificationCode) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select('''
            *,
            courses(title, instructor),
            profiles!inner(full_name, email)
          ''')
          .eq('verification_code', verificationCode)
          .eq('is_verified', true)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error verifying certificate: $e');
      return null;
    }
  }

  // Check if user has certificate for course
  Future<bool> hasCertificateForCourse(String courseId) async {
    if (!_authService.isAuthenticated) return false;

    try {
      final response = await _supabase
          .from('certificates')
          .select('id')
          .eq('user_id', _authService.userId)
          .eq('course_id', courseId)
          .eq('is_verified', true)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking certificate: $e');
      return false;
    }
  }

  // Get certificate details
  Future<Map<String, dynamic>?> getCertificateDetails(String certificateId) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select('''
            *,
            courses(title, instructor, image),
            profiles!inner(full_name, email, country, profession)
          ''')
          .eq('id', certificateId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching certificate details: $e');
      return null;
    }
  }

  // Check course completion eligibility
  Future<bool> isEligibleForCertificate(String courseId) async {
    if (!_authService.isAuthenticated) return false;

    try {
      // Check enrollment status
      final enrollment = await _supabase
          .from('enrollments')
          .select()
          .eq('user_id', _authService.userId)
          .eq('course_id', courseId)
          .maybeSingle();

      if (enrollment == null) return false;

      // Check if already has certificate
      if (enrollment['certificate_issued'] == true) return false;

      // Check completion percentage (should be 100%)
      final completionPercentage = (enrollment['completion_percentage'] ?? 0.0).toDouble();
      if (completionPercentage < 100.0) return false;

      // Check quiz requirements if any
      final quizzes = await _supabase
          .from('quizzes')
          .select('id, is_required, passing_score')
          .eq('course_id', courseId)
          .eq('is_required', true);

      for (var quiz in quizzes) {
        final bestAttempt = await _supabase
            .from('quiz_attempts')
            .select('percentage, is_passed')
            .eq('user_id', _authService.userId)
            .eq('quiz_id', quiz['id'])
            .order('percentage', ascending: false)
            .limit(1)
            .maybeSingle();

        if (bestAttempt == null || bestAttempt['is_passed'] != true) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error checking certificate eligibility: $e');
      return false;
    }
  }

  // Generate PDF certificate (placeholder - would integrate with PDF generation service)
  Future<String?> generateCertificatePDF(String certificateId) async {
    try {
      final certificate = await getCertificateDetails(certificateId);
      if (certificate == null) return null;

      // This would integrate with a PDF generation service
      // For now, we'll return a placeholder URL
      final pdfUrl = 'https://cimalearning.com/certificates/$certificateId.pdf';
      
      // Update certificate with PDF URL
      await _supabase
          .from('certificates')
          .update({'pdf_url': pdfUrl})
          .eq('id', certificateId);

      return pdfUrl;
    } catch (e) {
      debugPrint('Error generating PDF certificate: $e');
      return null;
    }
  }

  // Revoke certificate (admin function)
  Future<void> revokeCertificate(String certificateId, String reason) async {
    try {
      await _supabase
          .from('certificates')
          .update({
            'is_verified': false,
            'revoked_at': DateTime.now().toIso8601String(),
            'revocation_reason': reason,
          })
          .eq('id', certificateId);
    } catch (e) {
      debugPrint('Error revoking certificate: $e');
      rethrow;
    }
  }

  // Get certificate statistics
  Future<Map<String, dynamic>> getCertificateStatistics() async {
    if (!_authService.isAuthenticated) return {};

    try {
      final certificates = await getUserCertificates();
      
      final totalCertificates = certificates.length;
      final recentCertificates = certificates.where((cert) {
        final issuedAt = DateTime.parse(cert['issued_at']);
        return DateTime.now().difference(issuedAt).inDays <= 30;
      }).length;

      // Group by certificate type
      final typeGroups = <String, int>{};
      for (var cert in certificates) {
        final type = cert['certificate_type'] ?? 'unknown';
        typeGroups[type] = (typeGroups[type] ?? 0) + 1;
      }

      return {
        'total_certificates': totalCertificates,
        'recent_certificates': recentCertificates,
        'certificates_by_type': typeGroups,
        'latest_certificate': certificates.isNotEmpty ? certificates.first : null,
      };
    } catch (e) {
      debugPrint('Error fetching certificate statistics: $e');
      return {};
    }
  }

  // Helper methods
  String _generateCertificateId(String courseId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = _authService.userId.substring(0, 8);
    return 'cert_${courseId}_${userId}_$timestamp';
  }

  String _generateCertificateNumber() {
    final year = DateTime.now().year;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'CIMA-$year-${timestamp.toString().substring(8)}';
  }

  String _generateVerificationCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = _authService.userId.substring(0, 8);
    return 'VERIFY_${timestamp}_$userId'.toUpperCase();
  }
}