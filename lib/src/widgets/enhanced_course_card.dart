import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/cima_course.dart';
import '../utils/responsive.dart';
import '../../config/app_theme.dart';
import 'enrollment_button.dart';

class EnhancedCourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const EnhancedCourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  State<EnhancedCourseCard> createState() => _EnhancedCourseCardState();
}

class _EnhancedCourseCardState extends State<EnhancedCourseCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _favoriteController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _favoriteAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: CIMAAnimations.fast,
      vsync: this,
    );
    _favoriteController = AnimationController(
      duration: CIMAAnimations.medium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    
    _favoriteAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _favoriteController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleFavorite() {
    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });
    widget.onFavorite?.call();
  }

  // Helper method to map string level to CIMALevel enum
  CIMALevel _mapToLevel(String level) {
    switch (level.toLowerCase()) {
      case 'associate':
        return CIMALevel.associate;
      case 'member':
        return CIMALevel.member;
      case 'fellow':
        return CIMALevel.fellow;
      default:
        return CIMALevel.associate;
    }
  }

  // Helper method to map string category to CourseCategory enum
  CourseCategory _mapToCategory(String category) {
    switch (category.toLowerCase()) {
      case 'arbitration':
        return CourseCategory.arbitration;
      case 'mediation':
        return CourseCategory.mediation;
      case 'commercial-law':
      case 'commercial_law':
        return CourseCategory.commercial;
      case 'compliance':
        return CourseCategory.commercial;
      case 'corporate-disputes':
      case 'corporate_disputes':
        return CourseCategory.construction;
      default:
        return CourseCategory.adr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedBuilder(
              animation: _elevationAnimation,
              builder: (context, child) {
                return Card(
                  elevation: _elevationAnimation.value,
                  shadowColor: CIMAColors.primary.withOpacity(0.1),
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.all(CIMASpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(CIMABorderRadius.lg),
                  ),
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(CIMABorderRadius.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageSection(),
                        _buildContentSection(isMobile),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CIMAColors.primary.withOpacity(0.8),
                CIMAColors.secondary.withOpacity(0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Course image or placeholder
              if (widget.course.image.isNotEmpty)
                Positioned.fill(
                  child: Image.asset(
                    widget.course.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  ),
                ),
              if (widget.course.image.isEmpty)
                _buildImagePlaceholder(),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Course badges
        Positioned(
          top: CIMASpacing.sm,
          left: CIMASpacing.sm,
          child: Wrap(
            spacing: CIMASpacing.xs,
            children: [
              if (widget.course.isBestseller)
                _buildBadge('Bestseller', CIMAColors.accent),
              if (widget.course.isPopular)
                _buildBadge('Popular', CIMAColors.success),
            ],
          ),
        ),
        
        // Favorite button
        Positioned(
          top: CIMASpacing.sm,
          right: CIMASpacing.sm,
          child: AnimatedBuilder(
            animation: _favoriteAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _favoriteAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFavorite ? CIMAColors.error : CIMAColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: _handleFavorite,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Play button overlay
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: AnimatedOpacity(
                opacity: _isHovered ? 1.0 : 0.8,
                duration: CIMAAnimations.fast,
                child: const Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 32,
                      color: CIMAColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CIMAColors.primary.withOpacity(0.8),
            CIMAColors.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.school_outlined,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CIMASpacing.sm,
        vertical: CIMASpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(CIMABorderRadius.full),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContentSection(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(CIMASpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course title
          Text(
            widget.course.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: CIMASpacing.xs),
          
          // Instructor
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: CIMAColors.textSecondary,
              ),
              const SizedBox(width: CIMASpacing.xs),
              Expanded(
                child: Text(
                  widget.course.instructor,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: CIMAColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CIMASpacing.sm),
          
          // Rating and students
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.course.rating.floor() 
                      ? Icons.star 
                      : Icons.star_border,
                    size: 16,
                    color: CIMAColors.accent,
                  );
                }),
              ),
              const SizedBox(width: CIMASpacing.xs),
              Text(
                '${widget.course.rating}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ' (${widget.course.reviewCount})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CIMAColors.textTertiary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CIMASpacing.sm),
          
          // Course meta info
          Row(
            children: [
              _buildMetaChip(
                Icons.access_time,
                widget.course.duration,
              ),
              const SizedBox(width: CIMASpacing.xs),
              _buildMetaChip(
                Icons.people_outline,
                '${widget.course.studentCount} students',
              ),
            ],
          ),
          
          const SizedBox(height: CIMASpacing.md),
          
          // Price and enrollment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.course.originalPrice != null)
                    Text(
                      '₦${widget.course.originalPrice!.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: CIMAColors.textTertiary,
                      ),
                    ),
                  Text(
                    '₦${widget.course.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CIMAColors.primary,
                    ),
                  ),
                ],
              ),
              
              if (!isMobile)
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle enrollment
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Enroll'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
            ],
          ),
          
          if (isMobile) ...[
            const SizedBox(height: CIMASpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle enrollment
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Enroll Now'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CIMASpacing.sm,
        vertical: CIMASpacing.xs,
      ),
      decoration: BoxDecoration(
        color: CIMAColors.surface,
        borderRadius: BorderRadius.circular(CIMABorderRadius.sm),
        border: Border.all(
          color: CIMAColors.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: CIMAColors.textSecondary,
          ),
          const SizedBox(width: CIMASpacing.xs),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: CIMAColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}