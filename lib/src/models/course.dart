class Course {
  final String id;
  final String title;
  final String instructor;
  final double rating;
  final int reviewCount;
  final String duration;
  final int studentCount;
  final double price;
  final double? originalPrice;
  final String category;
  final String level;
  final String image;
  final bool isPopular;
  final bool isBestseller;
  final String description;
  final List<String> skills;
  final String language;
  final String? videoUrl;
  final List<String> modules;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    required this.studentCount,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.level,
    required this.image,
    this.isPopular = false,
    this.isBestseller = false,
    required this.description,
    this.skills = const [],
    this.language = 'en',
    this.videoUrl,
    this.modules = const [],
  });

  // Factory method to create Course from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      instructor: json['instructor'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      duration: json['duration'] as String,
      studentCount: json['student_count'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      category: json['category'] as String,
      level: json['level'] as String,
      image: json['image'] as String,
      isPopular: json['is_popular'] as bool? ?? false,
      isBestseller: json['is_bestseller'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      language: json['language'] as String? ?? 'en',
      videoUrl: json['video_url'] as String?,
      modules: List<String>.from(json['modules'] ?? []),
    );
  }

  // Method to convert Course to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'rating': rating,
      'review_count': reviewCount,
      'duration': duration,
      'student_count': studentCount,
      'price': price,
      'original_price': originalPrice,
      'category': category,
      'level': level,
      'image': image,
      'is_popular': isPopular,
      'is_bestseller': isBestseller,
      'description': description,
      'skills': skills,
      'language': language,
      'video_url': videoUrl,
      'modules': modules,
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}