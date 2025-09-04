class CartItem {
  final String courseId;
  final String title;
  final String instructor;
  final double price;
  final String imageUrl;
  final DateTime addedAt;
  final String category;
  final String level;

  CartItem({
    required this.courseId,
    required this.title,
    required this.instructor,
    required this.price,
    required this.imageUrl,
    required this.addedAt,
    required this.category,
    required this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'title': title,
      'instructor': instructor,
      'price': price,
      'imageUrl': imageUrl,
      'addedAt': addedAt.toIso8601String(),
      'category': category,
      'level': level,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      courseId: json['courseId'],
      title: json['title'],
      instructor: json['instructor'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      addedAt: DateTime.parse(json['addedAt']),
      category: json['category'],
      level: json['level'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.courseId == courseId;
  }

  @override
  int get hashCode => courseId.hashCode;
}