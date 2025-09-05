import 'package:flutter_test/flutter_test.dart';
import 'package:cima_learn/src/services/cart_service.dart';
import 'package:cima_learn/src/models/cart_item.dart';
import 'package:cima_learn/src/models/cima_course.dart';

void main() {
  group('Cart Service Tests', () {
    late CartService cartService;

    setUp(() {
      cartService = CartService();
    });

    test('Should add item to cart correctly', () {
      final course = CIMACourse(
        id: 'test-course-1',
        title: 'Test Course',
        description: 'Test Description',
        instructor: 'Test Instructor',
        price: 100.0,
        rating: 4.5,
        reviewCount: 10,
        studentCount: 50,
        image: 'test.jpg',
        duration: '2 hours',
        cimaLevel: CIMALevel.associate,
        courseCategory: CourseCategory.arbitration,
        sessionCount: 5,
        deliveryMode: 'virtual',
        certificationOffered: 'Certificate of Completion',
      );

      cartService.addToCart(course);

      expect(cartService.items.length, equals(1));
      expect(cartService.items.first.courseId, equals('test-course-1'));
      expect(cartService.totalAmount, equals(100.0));
    });

    test('Should not add duplicate items', () {
      final course = CIMACourse(
        id: 'test-course-1',
        title: 'Test Course',
        description: 'Test Description',
        instructor: 'Test Instructor',
        price: 100.0,
        rating: 4.5,
        reviewCount: 10,
        studentCount: 50,
        image: 'test.jpg',
        duration: '2 hours',
        cimaLevel: CIMALevel.associate,
        courseCategory: CourseCategory.arbitration,
        sessionCount: 5,
        deliveryMode: 'virtual',
        certificationOffered: 'Certificate of Completion',
      );

      cartService.addToCart(course);
      cartService.addToCart(course); // Try to add duplicate

      expect(cartService.items.length, equals(1));
    });

    test('Should remove item from cart', () {
      final course = CIMACourse(
        id: 'test-course-1',
        title: 'Test Course',
        description: 'Test Description',
        instructor: 'Test Instructor',
        price: 100.0,
        rating: 4.5,
        reviewCount: 10,
        studentCount: 50,
        image: 'test.jpg',
        duration: '2 hours',
        cimaLevel: CIMALevel.associate,
        courseCategory: CourseCategory.arbitration,
        sessionCount: 5,
        deliveryMode: 'virtual',
        certificationOffered: 'Certificate of Completion',
      );

      cartService.addToCart(course);
      expect(cartService.items.length, equals(1));

      cartService.removeFromCart('test-course-1');
      expect(cartService.items.length, equals(0));
      expect(cartService.totalAmount, equals(0.0));
    });

    test('Should calculate total correctly', () {
      final course1 = CIMACourse(
        id: 'course-1',
        title: 'Course 1',
        description: 'Description 1',
        instructor: 'Instructor 1',
        price: 100.0,
        rating: 4.5,
        reviewCount: 10,
        studentCount: 50,
        image: 'test1.jpg',
        duration: '2 hours',
        cimaLevel: CIMALevel.associate,
        courseCategory: CourseCategory.arbitration,
        sessionCount: 5,
        deliveryMode: 'virtual',
        certificationOffered: 'Certificate of Completion',
      );

      final course2 = CIMACourse(
        id: 'course-2',
        title: 'Course 2',
        description: 'Description 2',
        instructor: 'Instructor 2',
        price: 150.0,
        rating: 4.0,
        reviewCount: 20,
        studentCount: 30,
        image: 'test2.jpg',
        duration: '3 hours',
        cimaLevel: CIMALevel.member,
        courseCategory: CourseCategory.mediation,
        sessionCount: 8,
        deliveryMode: 'hybrid',
        certificationOffered: 'Professional Certificate',
      );

      cartService.addToCart(course1);
      cartService.addToCart(course2);

      expect(cartService.totalAmount, equals(250.0));
      expect(cartService.items.length, equals(2));
    });
  });
}