import 'package:flutter/material.dart';

/// Responsive layout utilities for adaptive UI design
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 768) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive breakpoints helper
class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

/// Responsive spacing helper
class ResponsiveSpacing {
  static double small(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 8.0 : 12.0;
  static double medium(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 16.0 : 24.0;
  static double large(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 24.0 : 32.0;
  static double extraLarge(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 32.0 : 48.0;
}

/// Responsive font sizes helper
class ResponsiveFontSizes {
  static double caption(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 12.0 : 14.0;
  static double body(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 14.0 : 16.0;
  static double subtitle(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 16.0 : 18.0;
  static double title(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 20.0 : 24.0;
  static double headline(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 24.0 : 32.0;
  static double display(BuildContext context) => ResponsiveBreakpoints.isMobile(context) ? 32.0 : 48.0;
}