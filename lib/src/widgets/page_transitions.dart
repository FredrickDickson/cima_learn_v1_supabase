import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Custom page route with smooth transitions
class CIMAPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final TransitionType transitionType;
  final Duration duration;

  CIMAPageRoute({
    required this.child,
    this.transitionType = TransitionType.slideFromRight,
    this.duration = CIMAAnimations.pageTransition,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              context,
              animation,
              secondaryAnimation,
              child,
              transitionType,
            );
          },
        );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    TransitionType type,
  ) {
    switch (type) {
      case TransitionType.slideFromRight:
        return _slideTransition(
          animation,
          secondaryAnimation,
          child,
          const Offset(1.0, 0.0),
          const Offset(-0.3, 0.0),
        );
      
      case TransitionType.slideFromLeft:
        return _slideTransition(
          animation,
          secondaryAnimation,
          child,
          const Offset(-1.0, 0.0),
          const Offset(0.3, 0.0),
        );
      
      case TransitionType.slideFromBottom:
        return _slideTransition(
          animation,
          secondaryAnimation,
          child,
          const Offset(0.0, 1.0),
          const Offset(0.0, -0.3),
        );
      
      case TransitionType.fadeIn:
        return FadeTransition(
          opacity: animation,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(secondaryAnimation),
            child: child,
          ),
        );
      
      case TransitionType.scaleIn:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(
            opacity: animation,
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(secondaryAnimation),
              child: child,
            ),
          ),
        );
      
      case TransitionType.rotateIn:
        return RotationTransition(
          turns: Tween<double>(begin: -0.1, end: 0.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
    }
  }

  static Widget _slideTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    Offset primaryOffset,
    Offset secondaryOffset,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: primaryOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: secondaryOffset,
        ).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic),
        ),
        child: child,
      ),
    );
  }
}

enum TransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fadeIn,
  scaleIn,
  rotateIn,
}

/// Navigation extensions for easy page transitions
extension NavigationExtensions on NavigatorState {
  Future<T?> pushWithTransition<T extends Object?>(
    Widget page, {
    TransitionType transition = TransitionType.slideFromRight,
    Duration? duration,
  }) {
    return push<T>(CIMAPageRoute<T>(
      child: page,
      transitionType: transition,
      duration: duration ?? CIMAAnimations.pageTransition,
    ));
  }

  Future<T?> pushReplacementWithTransition<T extends Object?, TO extends Object?>(
    Widget page, {
    TransitionType transition = TransitionType.slideFromRight,
    Duration? duration,
    TO? result,
  }) {
    return pushReplacement<T, TO>(CIMAPageRoute<T>(
      child: page,
      transitionType: transition,
      duration: duration ?? CIMAAnimations.pageTransition,
    ), result: result);
  }
}

/// Hero animations for shared elements
class CIMAHero extends StatelessWidget {
  final Object tag;
  final Widget child;
  final Duration duration;

  const CIMAHero({
    super.key,
    required this.tag,
    required this.child,
    this.duration = CIMAAnimations.medium,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final Hero toHero = toHeroContext.widget as Hero;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (animation.value * 0.1),
              child: toHero.child,
            );
          },
        );
      },
      child: child,
    );
  }
}

/// Animated list transitions
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = CIMAAnimations.medium,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Stagger animation based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Staggered grid animations
class StaggeredGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Duration animationDuration;
  final Duration staggerDelay;

  const StaggeredGridView({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.animationDuration = CIMAAnimations.medium,
    this.staggerDelay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          delay: staggerDelay,
          duration: animationDuration,
          child: children[index],
        );
      },
    );
  }
}

/// Pull-to-refresh with custom animations
class CIMAPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const CIMAPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  State<CIMAPullToRefresh> createState() => _CIMAPullToRefreshState();
}

class _CIMAPullToRefreshState extends State<CIMAPullToRefresh>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: CIMAAnimations.medium,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: widget.color ?? CIMAColors.primary,
      backgroundColor: CIMAColors.cardBackground,
      strokeWidth: 3.0,
      child: widget.child,
    );
  }
}