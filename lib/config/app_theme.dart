import 'package:flutter/material.dart';

// Enhanced CIMA Learn Design System
class CIMAColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFFA6192E); // CIMA Red
  static const Color primaryDark = Color(0xFF8A152A);
  static const Color primaryLight = Color(0xFFB71C34);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF2E5C8A); // Professional Blue
  static const Color accent = Color(0xFFE8B948); // Gold Accent
  
  // Neutral Colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFF8C00);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF0EA5E9);
  
  // Interactive States
  static const Color hover = Color(0xFFF5F5F5);
  static const Color pressed = Color(0xFFE5E5E5);
  static const Color disabled = Color(0xFFE0E0E0);
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: CIMAColors.primary,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: CIMAColors.primary,
      onPrimary: Colors.white,
      secondary: CIMAColors.secondary,
      onSecondary: Colors.white,
      tertiary: CIMAColors.accent,
      onTertiary: Colors.black87,
      surface: CIMAColors.surface,
      onSurface: CIMAColors.textPrimary,
      background: CIMAColors.background,
      onBackground: CIMAColors.textPrimary,
      error: CIMAColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: CIMAColors.surface,
    
    // Enhanced Typography System
    textTheme: const TextTheme(
      // Display styles - for hero sections
      displayLarge: TextStyle(
        fontSize: 48, 
        fontWeight: FontWeight.w800, 
        color: CIMAColors.textPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 36, 
        fontWeight: FontWeight.w700, 
        color: CIMAColors.textPrimary,
        letterSpacing: -0.25,
      ),
      
      // Headlines - for section titles
      headlineLarge: TextStyle(
        fontSize: 32, 
        fontWeight: FontWeight.w700, 
        color: CIMAColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 28, 
        fontWeight: FontWeight.w600, 
        color: CIMAColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 24, 
        fontWeight: FontWeight.w600, 
        color: CIMAColors.textPrimary,
      ),
      
      // Titles - for card headers, etc.
      titleLarge: TextStyle(
        fontSize: 20, 
        fontWeight: FontWeight.w600, 
        color: CIMAColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.w500, 
        color: CIMAColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.w500, 
        color: CIMAColors.textPrimary,
      ),
      
      // Body text - for content
      bodyLarge: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.w400, 
        color: CIMAColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14, 
        fontWeight: FontWeight.w400, 
        color: CIMAColors.textSecondary,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.w400, 
        color: CIMAColors.textTertiary,
        height: 1.3,
      ),
      
      // Labels - for buttons, tabs, etc.
      labelLarge: TextStyle(
        fontSize: 14, 
        fontWeight: FontWeight.w600, 
        color: CIMAColors.textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.w500, 
        color: CIMAColors.textSecondary,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11, 
        fontWeight: FontWeight.w500, 
        color: CIMAColors.textTertiary,
        letterSpacing: 0.5,
      ),
    ),
    
    // Enhanced Button Themes with animations
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CIMAColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: CIMAColors.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        animationDuration: const Duration(milliseconds: 200),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.white.withOpacity(0.1);
            }
            if (states.contains(MaterialState.pressed)) {
              return Colors.white.withOpacity(0.2);
            }
            return null;
          },
        ),
      ),
    ),
    
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CIMAColors.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CIMAColors.primary,
        side: const BorderSide(color: CIMAColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CIMAColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    
    // Enhanced Card Theme
    cardTheme: CardThemeData(
      color: CIMAColors.cardBackground,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
    ),
    
    // Enhanced Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CIMAColors.surface,
      hintStyle: const TextStyle(color: CIMAColors.textTertiary),
      labelStyle: const TextStyle(color: CIMAColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CIMAColors.textTertiary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CIMAColors.textTertiary.withOpacity(0.3)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: CIMAColors.primary, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: CIMAColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: CIMAColors.surface,
      titleTextStyle: TextStyle(
        color: CIMAColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: CIMAColors.textPrimary),
    ),
    
    // Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: CIMAColors.cardBackground,
      selectedItemColor: CIMAColors.primary,
      unselectedItemColor: CIMAColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: CIMAColors.surface,
      selectedColor: CIMAColors.primary,
      labelStyle: const TextStyle(color: CIMAColors.textPrimary),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: CIMAColors.textTertiary.withOpacity(0.3)),
    ),
  );
}

// Animation Duration Constants
class CIMAAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration pageTransition = Duration(milliseconds: 300);
}

// Spacing System
class CIMASpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Border Radius System
class CIMABorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}