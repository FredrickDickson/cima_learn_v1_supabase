import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/paystack_service.dart';
import '../services/enhanced_auth_service.dart';
import '../utils/responsive.dart';
import '../models/cima_course.dart';

class PaystackPaymentWidget extends StatefulWidget {
  final CIMACourse course;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;

  const PaystackPaymentWidget({
    Key? key,
    required this.course,
    this.onPaymentSuccess,
    this.onPaymentFailed,
  }) : super(key: key);

  @override
  State<PaystackPaymentWidget> createState() => _PaystackPaymentWidgetState();
}

class _PaystackPaymentWidgetState extends State<PaystackPaymentWidget> {
  final PaystackService _paystackService = PaystackService();
  final EnhancedAuthService _authService = EnhancedAuthService();
  
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _initiatePayment() async {
    if (!_authService.isAuthenticated) {
      setState(() {
        _errorMessage = 'Please sign in to enroll in courses';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final userEmail = _authService.currentUser?.email;
      if (userEmail == null) {
        setState(() {
          _errorMessage = 'User email not found. Please sign in again.';
        });
        return;
      }

      final result = await _paystackService.initializePayment(
        courseId: widget.course.id,
        courseName: widget.course.title,
        amount: widget.course.price,
        currency: 'NGN', // Paystack primary currency
        userEmail: userEmail,
        metadata: {
          'course_title': widget.course.title,
          'course_instructor': widget.course.instructor,
          'course_category': widget.course.category.toString().split('.').last,
          'course_level': widget.course.level.toString().split('.').last,
        },
      );

      if (result.isSuccess && result.authorizationUrl != null) {
        // Launch Paystack payment page
        await _launchPaymentUrl(result.authorizationUrl!);
        
        // Start checking payment status
        await _checkPaymentStatus(result.reference!);
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Payment failed: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch payment page';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to open payment page: $e';
      });
    }
  }

  Future<void> _checkPaymentStatus(String reference) async {
    // Poll payment status every 3 seconds for up to 10 minutes
    int attempts = 0;
    const maxAttempts = 200; // 10 minutes / 3 seconds

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 3));
      
      try {
        final verification = await _paystackService.verifyPayment(reference);
        
        if (verification.isSuccess && verification.status == 'success') {
          widget.onPaymentSuccess?.call();
          _showSuccessDialog();
          return;
        } else if (verification.status == 'failed' || verification.status == 'abandoned') {
          widget.onPaymentFailed?.call();
          setState(() {
            _errorMessage = verification.message;
          });
          return;
        }
        
        attempts++;
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          setState(() {
            _errorMessage = 'Payment verification timeout. Please contact support.';
          });
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        title: const Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have successfully enrolled in "${widget.course.title}"',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'You can now access all course materials and start learning.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/enrolled-courses');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
            child: const Text('View My Courses'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Course summary
          _buildCourseSummary(),
          
          const SizedBox(height: 24),
          
          // Payment details
          _buildPaymentDetails(),
          
          const SizedBox(height: 24),
          
          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          
          if (_errorMessage != null) const SizedBox(height: 16),
          
          // Payment button
          _buildPaymentButton(),
          
          const SizedBox(height: 16),
          
          // Security notice
          _buildSecurityNotice(),
        ],
      ),
    );
  }

  Widget _buildCourseSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Enrollment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB71C1C),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.course.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              widget.course.instructor,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${widget.course.duration} hours',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Course Price:'),
              Text(
                '₦${widget.course.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (widget.course.originalPrice != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Original Price:', style: TextStyle(color: Colors.grey)),
                Text(
                  '₦${widget.course.originalPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('You Save:', style: TextStyle(color: Colors.green)),
                Text(
                  '₦${(widget.course.originalPrice! - widget.course.price).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₦${widget.course.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB71C1C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : _initiatePayment,
      icon: _isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.payment),
      label: Text(_isProcessing ? 'Processing...' : 'Pay with Paystack'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Secure payment powered by Paystack. Your payment information is encrypted and secure.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}