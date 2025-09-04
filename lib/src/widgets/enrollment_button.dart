import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cima_course.dart';
import '../services/enhanced_auth_service.dart';
import '../services/paystack_service.dart';
import '../services/enhanced_localization_service.dart';
import '../services/cart_service.dart';
import 'paystack_payment_widget.dart';

class EnrollmentButton extends StatefulWidget {
  final CIMACourse course;
  final bool isExpanded;

  const EnrollmentButton({
    Key? key,
    required this.course,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<EnrollmentButton> createState() => _EnrollmentButtonState();
}

class _EnrollmentButtonState extends State<EnrollmentButton> {
  final PaystackService _paystackService = PaystackService();
  bool _isCheckingEnrollment = false;
  bool _isEnrolled = false;
  bool _hasPaid = false;

  @override
  void initState() {
    super.initState();
    _checkEnrollmentStatus();
  }

  Future<void> _checkEnrollmentStatus() async {
    setState(() {
      _isCheckingEnrollment = true;
    });

    try {
      final authService = context.read<EnhancedAuthService>();
      if (authService.isAuthenticated) {
        final enrolled = await authService.isEnrolledInCourse(widget.course.id);
        final paid = await _paystackService.hasUserPaidForCourse(widget.course.id);
        
        setState(() {
          _isEnrolled = enrolled;
          _hasPaid = paid;
        });
      }
    } catch (e) {
      debugPrint('Error checking enrollment status: $e');
    } finally {
      setState(() {
        _isCheckingEnrollment = false;
      });
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          child: PaystackPaymentWidget(
            course: widget.course,
            onPaymentSuccess: () {
              Navigator.of(context).pop();
              _checkEnrollmentStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(EnhancedLocalizationService.t('enrollment_successful')),
                  backgroundColor: Colors.green,
                ),
              );
            },
            onPaymentFailed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment failed. Please try again.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(EnhancedLocalizationService.t('sign_in')),
        content: const Text('Please sign in to enroll in courses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(EnhancedLocalizationService.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
            child: Text(EnhancedLocalizationService.t('sign_in')),
          ),
        ],
      ),
    );
  }

  void _navigateToCourse() {
    Navigator.pushNamed(
      context,
      '/course-content',
      arguments: widget.course,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedAuthService>(
      builder: (context, authService, child) {
        if (_isCheckingEnrollment) {
          return _buildLoadingButton();
        }

        if (_isEnrolled || _hasPaid) {
          return _buildContinueButton();
        }

        if (!authService.isAuthenticated) {
          return _buildSignInButton();
        }

        return _buildEnrollButton();
      },
    );
  }

  Widget _buildLoadingButton() {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        minimumSize: widget.isExpanded 
            ? const Size(double.infinity, 48) 
            : const Size(120, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(EnhancedLocalizationService.t('loading')),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton.icon(
      onPressed: _navigateToCourse,
      icon: const Icon(Icons.play_arrow),
      label: Text(EnhancedLocalizationService.t('continue_learning')),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        minimumSize: widget.isExpanded 
            ? const Size(double.infinity, 48) 
            : const Size(160, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return OutlinedButton.icon(
      onPressed: _showLoginPrompt,
      icon: const Icon(Icons.login),
      label: Text(EnhancedLocalizationService.t('sign_in')),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFB71C1C),
        side: const BorderSide(color: Color(0xFFB71C1C)),
        minimumSize: widget.isExpanded 
            ? const Size(double.infinity, 48) 
            : const Size(120, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildEnrollButton() {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final isInCart = cartService.isInCart(widget.course.id);
        
        return Row(
          mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Add to Cart Button
            if (!isInCart)
              Expanded(
                flex: widget.isExpanded ? 1 : 0,
                child: OutlinedButton.icon(
                  onPressed: () => _addToCart(cartService),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(widget.isExpanded ? 'Add to Cart' : ''),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB71C1C),
                    side: const BorderSide(color: Color(0xFFB71C1C)),
                    minimumSize: widget.isExpanded 
                        ? const Size(double.infinity, 48) 
                        : const Size(50, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            if (!isInCart && widget.isExpanded) const SizedBox(width: 8),
            // Enroll Now Button
            Expanded(
              flex: widget.isExpanded ? (isInCart ? 2 : 1) : 0,
              child: ElevatedButton.icon(
                onPressed: _showPaymentDialog,
                icon: Icon(isInCart ? Icons.shopping_cart_checkout : Icons.shopping_cart),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isInCart ? 'Buy Now' : EnhancedLocalizationService.t('enroll_now')),
                    if (widget.isExpanded)
                      Text(
                        '₦${widget.course.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  minimumSize: widget.isExpanded 
                      ? const Size(double.infinity, 48) 
                      : const Size(140, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(CartService cartService) {
    final added = cartService.addToCart(widget.course);
    if (added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.course.title} added to cart'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course is already in cart'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}