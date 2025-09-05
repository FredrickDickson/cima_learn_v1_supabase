import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.desktop &&
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.mobile;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    if (size.width >= ResponsiveBreakpoints.desktop) {
      return desktop;
    } else if (size.width >= ResponsiveBreakpoints.mobile) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}

// Responsive padding helper
class ResponsivePadding {
  static EdgeInsets symmetric(BuildContext context, {
    double mobileHorizontal = 16,
    double mobileVertical = 16,
    double tabletHorizontal = 32,
    double tabletVertical = 24,
    double desktopHorizontal = 64,
    double desktopVertical = 32,
  }) {
    if (Responsive.isDesktop(context)) {
      return EdgeInsets.symmetric(
        horizontal: desktopHorizontal,
        vertical: desktopVertical,
      );
    } else if (Responsive.isTablet(context)) {
      return EdgeInsets.symmetric(
        horizontal: tabletHorizontal,
        vertical: tabletVertical,
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: mobileHorizontal,
        vertical: mobileVertical,
      );
    }
  }
}

// Responsive font sizes
class ResponsiveFontSize {
  static double heading1(BuildContext context) {
    if (Responsive.isDesktop(context)) return 48;
    if (Responsive.isTablet(context)) return 36;
    return 28;
  }

  static double heading2(BuildContext context) {
    if (Responsive.isDesktop(context)) return 36;
    if (Responsive.isTablet(context)) return 28;
    return 24;
  }

  static double heading3(BuildContext context) {
    if (Responsive.isDesktop(context)) return 24;
    if (Responsive.isTablet(context)) return 20;
    return 18;
  }

  static double body(BuildContext context) {
    if (Responsive.isDesktop(context)) return 16;
    if (Responsive.isTablet(context)) return 15;
    return 14;
  }

  static double heading4(BuildContext context) {
    if (Responsive.isDesktop(context)) return 18;
    if (Responsive.isTablet(context)) return 17;
    return 16;
  }

  static double small(BuildContext context) {
    if (Responsive.isDesktop(context)) return 14;
    if (Responsive.isTablet(context)) return 13;
    return 12;
  }
}