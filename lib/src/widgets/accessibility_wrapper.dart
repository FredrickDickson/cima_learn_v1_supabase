import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_theme.dart';

/// Accessibility wrapper that provides semantic information and keyboard navigation
class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeSemantics;
  final VoidCallback? onTap;
  final bool isFocusable;
  final String? tooltip;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.excludeSemantics = false,
    this.onTap,
    this.isFocusable = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    // Add tooltip if provided
    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        preferBelow: false,
        child: result,
      );
    }

    // Add semantic information
    if (!excludeSemantics) {
      result = Semantics(
        label: semanticLabel,
        hint: semanticHint,
        button: onTap != null,
        focusable: isFocusable,
        child: result,
      );
    }

    // Add keyboard navigation support
    if (onTap != null && isFocusable) {
      result = Focus(
        child: Builder(
          builder: (context) {
            final FocusNode focusNode = Focus.of(context);
            final bool hasFocus = focusNode.hasFocus;
            
            return GestureDetector(
              onTap: onTap,
              child: RawKeyboardListener(
                focusNode: focusNode,
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.enter ||
                        event.logicalKey == LogicalKeyboardKey.space) {
                      onTap?.call();
                    }
                  }
                },
                child: Container(
                  decoration: hasFocus ? BoxDecoration(
                    border: Border.all(
                      color: CIMAColors.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ) : null,
                  child: result,
                ),
              ),
            );
          },
        ),
      );
    }

    return result;
  }
}

/// Screen reader announcement widget
class AnnouncementWidget extends StatefulWidget {
  final String message;
  final bool liveRegion;

  const AnnouncementWidget({
    super.key,
    required this.message,
    this.liveRegion = true,
  });

  @override
  State<AnnouncementWidget> createState() => _AnnouncementWidgetState();
}

class _AnnouncementWidgetState extends State<AnnouncementWidget> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: widget.liveRegion,
      announcement: widget.message,
      child: const SizedBox.shrink(),
    );
  }
}

/// High contrast theme support
class HighContrastTheme {
  static ThemeData getHighContrastTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF000000),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF000000),
        onSecondary: Color(0xFFFFFFFF),
        tertiary: Color(0xFF000000),
        onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
        background: Color(0xFFFFFFFF),
        onBackground: Color(0xFF000000),
        error: Color(0xFFCC0000),
        onError: Color(0xFFFFFFFF),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: Color(0xFF000000),
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF000000),
        ),
        bodyLarge: TextStyle(
          fontSize: 18, // Increased for better readability
          fontWeight: FontWeight.w500,
          color: Color(0xFF000000),
          height: 1.6,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF000000),
          foregroundColor: const Color(0xFFFFFFFF),
          minimumSize: const Size(44, 44), // WCAG minimum touch target
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Color(0xFF000000), width: 2),
          ),
        ),
      ),
    );
  }
}

/// Font size preferences
enum FontSize { small, medium, large, extraLarge }

class FontSizeProvider extends ChangeNotifier {
  FontSize _currentSize = FontSize.medium;

  FontSize get currentSize => _currentSize;

  void updateFontSize(FontSize newSize) {
    _currentSize = newSize;
    notifyListeners();
  }

  double getScaleFactor() {
    switch (_currentSize) {
      case FontSize.small:
        return 0.85;
      case FontSize.medium:
        return 1.0;
      case FontSize.large:
        return 1.15;
      case FontSize.extraLarge:
        return 1.3;
    }
  }
}

/// Accessible form field with proper labels and error messages
class AccessibleFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool isRequired;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const AccessibleFormField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.isRequired = false,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: CIMAColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        
        const SizedBox(height: CIMASpacing.xs),
        
        // Hint text
        if (hint != null)
          Text(
            hint!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: CIMAColors.textSecondary,
            ),
          ),
        
        if (hint != null) const SizedBox(height: CIMASpacing.xs),
        
        // Text field
        Semantics(
          label: label + (isRequired ? ' required' : ''),
          hint: hint,
          textField: true,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CIMAColors.error,
              ),
              prefixIcon: _getIconForKeyboardType(),
            ),
          ),
        ),
        
        // Error message with proper semantics
        if (errorText != null) ...[
          const SizedBox(height: CIMASpacing.xs),
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: CIMAColors.error,
                ),
                const SizedBox(width: CIMASpacing.xs),
                Expanded(
                  child: Text(
                    errorText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CIMAColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget? _getIconForKeyboardType() {
    switch (keyboardType) {
      case TextInputType.emailAddress:
        return const Icon(Icons.email_outlined);
      case TextInputType.phone:
        return const Icon(Icons.phone_outlined);
      case TextInputType.url:
        return const Icon(Icons.link_outlined);
      default:
        if (obscureText) {
          return const Icon(Icons.lock_outlined);
        }
        return null;
    }
  }
}

/// Screen reader optimized navigation
class AccessibleNavigation {
  static void announcePageChange(BuildContext context, String pageName) {
    // Announce page change to screen readers
    Semantics.of(context).announce('$pageName page opened', TextDirection.ltr);
  }
  
  static void announceAction(BuildContext context, String action) {
    Semantics.of(context).announce(action, TextDirection.ltr);
  }
}

/// Focus management utilities
class FocusUtils {
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }
  
  static void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}