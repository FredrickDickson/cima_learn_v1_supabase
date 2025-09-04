import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/cima_course.dart';
import '../utils/responsive.dart';
import 'enrollment_button.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (course.isBestseller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Bestseller',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (course.isPopular)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${course.instructor}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${course.rating} (${course.reviewCount})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        const Icon(Icons.people, size: 16, color: Color(0xFF666666)),
                        const SizedBox(width: 4),
                        Text(
                          '${course.studentCount}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Color(0xFF666666)),
                        const SizedBox(width: 4),
                        Text(course.duration, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${course.price.toInt()}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            if (course.originalPrice != null)
                              Text(
                                '\$${course.originalPrice!.toInt()}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: const Color(0xFF666666),
                                    ),
                              ),
                          ],
                        ),
                        EnrollmentButton(
                          course: CIMACourse(
                            id: course.id,
                            title: course.title,
                            description: course.description,
                            instructor: course.instructor,
                            price: course.price,
                            rating: course.rating,
                            imageUrl: course.image,
                            duration: int.tryParse(course.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 8,
                            level: _mapToLevel(course.level),
                            category: _mapToCategory(course.category),
                            sessionCount: 4,
                            deliveryMode: 'virtual',
                            certificationOffered: 'Certificate of Completion',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}