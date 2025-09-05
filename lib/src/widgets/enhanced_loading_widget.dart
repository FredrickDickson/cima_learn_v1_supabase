import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class EnhancedLoadingWidget extends StatefulWidget {
  final String? message;
  final double size;
  final bool showMessage;

  const EnhancedLoadingWidget({
    super.key,
    this.message,
    this.size = 40,
    this.showMessage = true,
  });

  @override
  State<EnhancedLoadingWidget> createState() => _EnhancedLoadingWidgetState();
}

class _EnhancedLoadingWidgetState extends State<EnhancedLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: CIMAAnimations.slow,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated CIMA Logo Loading Indicator
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CIMAColors.primary.withOpacity(0.8 + _animation.value * 0.2),
                      CIMAColors.secondary.withOpacity(0.6 + _animation.value * 0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CIMAColors.primary.withOpacity(0.3 + _animation.value * 0.2),
                      blurRadius: 10 + _animation.value * 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              );
            },
          ),
          
          if (widget.showMessage) ...[
            const SizedBox(height: CIMASpacing.md),
            FadeTransition(
              opacity: _animation,
              child: Text(
                widget.message ?? 'Loading...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CIMAColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Skeleton Loading Widget for Cards
class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const SkeletonLoader({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: CIMAColors.disabled,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  left: _animation.value * widget.width,
                  child: Container(
                    width: widget.width * 0.5,
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Course Card Skeleton
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CIMASpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoader(
              height: 180,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(height: CIMASpacing.md),
            const SkeletonLoader(
              height: 20,
              width: double.infinity,
            ),
            const SizedBox(height: CIMASpacing.sm),
            const SkeletonLoader(
              height: 16,
              width: 150,
            ),
            const SizedBox(height: CIMASpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonLoader(height: 16, width: 80),
                SkeletonLoader(
                  height: 36,
                  width: 100,
                  borderRadius: BorderRadius.circular(CIMABorderRadius.full),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}