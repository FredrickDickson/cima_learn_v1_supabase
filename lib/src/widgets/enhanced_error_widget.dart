import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

enum ErrorType {
  network,
  authentication,
  validation,
  payment,
  general,
  notFound,
  permission,
}

class EnhancedErrorWidget extends StatefulWidget {
  final ErrorType errorType;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const EnhancedErrorWidget({
    super.key,
    required this.errorType,
    this.title,
    this.message,
    this.actionText,
    this.onAction,
    this.onRetry,
    this.showRetryButton = true,
  });

  @override
  State<EnhancedErrorWidget> createState() => _EnhancedErrorWidgetState();
}

class _EnhancedErrorWidgetState extends State<EnhancedErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: CIMAAnimations.medium,
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorConfig = _getErrorConfig();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(CIMASpacing.lg),
            padding: const EdgeInsets.all(CIMASpacing.xl),
            decoration: BoxDecoration(
              color: CIMAColors.cardBackground,
              borderRadius: BorderRadius.circular(CIMABorderRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error icon with animation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: errorConfig.color.withOpacity(0.1),
                  ),
                  child: Icon(
                    errorConfig.icon,
                    size: 40,
                    color: errorConfig.color,
                  ),
                ),
                
                const SizedBox(height: CIMASpacing.lg),
                
                // Error title
                Text(
                  widget.title ?? errorConfig.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CIMAColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: CIMASpacing.md),
                
                // Error message
                Text(
                  widget.message ?? errorConfig.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CIMAColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: CIMASpacing.xl),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.showRetryButton && widget.onRetry != null)
                      ElevatedButton.icon(
                        onPressed: widget.onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorConfig.color,
                        ),
                      ),
                    
                    if (widget.onAction != null) ...[
                      if (widget.showRetryButton && widget.onRetry != null)
                        const SizedBox(width: CIMASpacing.md),
                      OutlinedButton.icon(
                        onPressed: widget.onAction,
                        icon: Icon(errorConfig.actionIcon),
                        label: Text(widget.actionText ?? errorConfig.actionText),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: errorConfig.color,
                          side: BorderSide(color: errorConfig.color),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ErrorConfig _getErrorConfig() {
    switch (widget.errorType) {
      case ErrorType.network:
        return ErrorConfig(
          title: 'Connection Problem',
          message: 'Please check your internet connection and try again. Make sure you\'re connected to a stable network.',
          icon: Icons.wifi_off_rounded,
          color: CIMAColors.warning,
          actionIcon: Icons.settings,
          actionText: 'Settings',
        );
        
      case ErrorType.authentication:
        return ErrorConfig(
          title: 'Authentication Required',
          message: 'You need to sign in to access this feature. Please log in to continue your learning journey.',
          icon: Icons.lock_outline_rounded,
          color: CIMAColors.secondary,
          actionIcon: Icons.login,
          actionText: 'Sign In',
        );
        
      case ErrorType.validation:
        return ErrorConfig(
          title: 'Invalid Information',
          message: 'Please check the information you entered and make sure all required fields are completed correctly.',
          icon: Icons.error_outline_rounded,
          color: CIMAColors.warning,
          actionIcon: Icons.edit,
          actionText: 'Edit',
        );
        
      case ErrorType.payment:
        return ErrorConfig(
          title: 'Payment Issue',
          message: 'We couldn\'t process your payment. Please check your payment method or try a different one.',
          icon: Icons.payment_rounded,
          color: CIMAColors.error,
          actionIcon: Icons.credit_card,
          actionText: 'Update Payment',
        );
        
      case ErrorType.notFound:
        return ErrorConfig(
          title: 'Content Not Found',
          message: 'The content you\'re looking for isn\'t available. It may have been moved or removed.',
          icon: Icons.search_off_rounded,
          color: CIMAColors.textSecondary,
          actionIcon: Icons.home,
          actionText: 'Go Home',
        );
        
      case ErrorType.permission:
        return ErrorConfig(
          title: 'Access Denied',
          message: 'You don\'t have permission to access this content. Contact support if you think this is an error.',
          icon: Icons.block_rounded,
          color: CIMAColors.error,
          actionIcon: Icons.support_agent,
          actionText: 'Contact Support',
        );
        
      default:
        return ErrorConfig(
          title: 'Something Went Wrong',
          message: 'An unexpected error occurred. Don\'t worry, our team has been notified and we\'re working on it.',
          icon: Icons.error_outline_rounded,
          color: CIMAColors.error,
          actionIcon: Icons.help_outline,
          actionText: 'Get Help',
        );
    }
  }
}

class ErrorConfig {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final IconData actionIcon;
  final String actionText;

  ErrorConfig({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.actionIcon,
    required this.actionText,
  });
}

// Toast message widget for success/error notifications
class CIMAToast {
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, CIMAColors.success, Icons.check_circle_outline);
  }
  
  static void showError(BuildContext context, String message) {
    _showToast(context, message, CIMAColors.error, Icons.error_outline);
  }
  
  static void showWarning(BuildContext context, String message) {
    _showToast(context, message, CIMAColors.warning, Icons.warning_amber_outlined);
  }
  
  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, CIMAColors.info, Icons.info_outline);
  }

  static void _showToast(BuildContext context, String message, Color color, IconData icon) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: _ToastWidget(
            message: message,
            color: color,
            icon: icon,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: CIMAAnimations.medium,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(CIMASpacing.md),
          decoration: BoxDecoration(
            color: CIMAColors.cardBackground,
            borderRadius: BorderRadius.circular(CIMABorderRadius.md),
            border: Border.all(color: widget.color, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.1),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: CIMASpacing.md),
              
              Expanded(
                child: Text(
                  widget.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CIMAColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              IconButton(
                onPressed: _dismiss,
                icon: const Icon(Icons.close),
                iconSize: 20,
                color: CIMAColors.textTertiary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}