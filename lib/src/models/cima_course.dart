import 'course.dart';

enum CIMALevel {
  associate, // ACIMArb - Foundational courses for beginners
  member,    // MCIMArb - Professional development
  fellow     // FCIMArb - Advanced practitioners
}

enum CourseCategory {
  adr,           // Alternative Dispute Resolution
  arbitration,   // International Arbitration
  mediation,     // Mediation practices
  construction,  // Construction disputes
  commercial,    // Commercial law
  maritime,      // Maritime arbitration
  investment,    // Investment disputes
  sports,        // Sports arbitration
  technology     // Tech & IP disputes
}

class CIMACourse extends Course {
  final CIMALevel cimaLevel;
  final CourseCategory courseCategory;
  final List<String> prerequisites;
  final int sessionCount;
  final String deliveryMode; // 'virtual', 'in-person', 'hybrid'
  final List<String> learningOutcomes;
  final String certificationOffered;
  final bool isFoundational;
  final double practicalHours;
  final double theoryHours;

  CIMACourse({
    required String id,
    required String title,
    required String description,
    required String instructor,
    required double price,
    required double rating,
    required String imageUrl,
    required int duration,
    required this.cimaLevel,
    required this.courseCategory,
    this.prerequisites = const [],
    required this.sessionCount,
    required this.deliveryMode,
    this.learningOutcomes = const [],
    required this.certificationOffered,
    this.isFoundational = false,
    this.practicalHours = 0.0,
    this.theoryHours = 0.0,
  }) : super(
          id: id,
          title: title,
          description: description,
          instructor: instructor,
          price: price,
          rating: rating,
          imageUrl: imageUrl,
          duration: duration,
          level: cimaLevel.toString().split('.').last,
          category: courseCategory.toString().split('.').last,
        );

  String get levelDisplayName {
    switch (cimaLevel) {
      case CIMALevel.associate:
        return 'Associate (ACIMArb)';
      case CIMALevel.member:
        return 'Member (MCIMArb)';
      case CIMALevel.fellow:
        return 'Fellow (FCIMArb)';
    }
  }

  String get categoryDisplayName {
    switch (courseCategory) {
      case CourseCategory.adr:
        return 'Alternative Dispute Resolution';
      case CourseCategory.arbitration:
        return 'International Arbitration';
      case CourseCategory.mediation:
        return 'Mediation';
      case CourseCategory.construction:
        return 'Construction Disputes';
      case CourseCategory.commercial:
        return 'Commercial Law';
      case CourseCategory.maritime:
        return 'Maritime Arbitration';
      case CourseCategory.investment:
        return 'Investment Disputes';
      case CourseCategory.sports:
        return 'Sports Arbitration';
      case CourseCategory.technology:
        return 'Technology & IP';
    }
  }

  String get difficultyLevel {
    switch (cimaLevel) {
      case CIMALevel.associate:
        return 'Beginner';
      case CIMALevel.member:
        return 'Intermediate';
      case CIMALevel.fellow:
        return 'Advanced';
    }
  }

  bool get isHybrid => deliveryMode.toLowerCase() == 'hybrid';
  bool get isVirtual => deliveryMode.toLowerCase() == 'virtual';
  bool get isInPerson => deliveryMode.toLowerCase() == 'in-person';

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'level': cimaLevel.toString().split('.').last,
      'category': courseCategory.toString().split('.').last,
      'prerequisites': prerequisites,
      'session_count': sessionCount,
      'delivery_mode': deliveryMode,
      'learning_outcomes': learningOutcomes,
      'certification_offered': certificationOffered,
      'is_foundational': isFoundational,
      'practical_hours': practicalHours,
      'theory_hours': theoryHours,
    });
    return json;
  }

  factory CIMACourse.fromJson(Map<String, dynamic> json) {
    return CIMACourse(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructor: json['instructor'],
      price: (json['price'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 4.5).toDouble(),
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      duration: json['duration'] ?? 0,
      cimaLevel: CIMALevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['level'],
        orElse: () => CIMALevel.associate,
      ),
      courseCategory: CourseCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => CourseCategory.adr,
      ),
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      sessionCount: json['session_count'] ?? 1,
      deliveryMode: json['delivery_mode'] ?? 'virtual',
      learningOutcomes: List<String>.from(json['learning_outcomes'] ?? []),
      certificationOffered: json['certification_offered'] ?? 'Certificate of Completion',
      isFoundational: json['is_foundational'] ?? false,
      practicalHours: (json['practical_hours'] ?? 0.0).toDouble(),
      theoryHours: (json['theory_hours'] ?? 0.0).toDouble(),
    );
  }
}