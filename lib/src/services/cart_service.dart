import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/cima_course.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> _items = [];
  static const String _cartKey = 'cart_items';

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + (item.price ?? 0.0));
  }

  double get totalAmount => totalPrice; // Alias for consistency

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> cartData = jsonDecode(cartJson);
        _items = cartData.map((item) {
          try {
            return CartItem.fromJson(item);
          } catch (e) {
            debugPrint('Error parsing cart item: $e');
            return null;
          }
        }).where((item) => item != null).cast<CartItem>().toList();
        
        // Validate cart items and remove any invalid ones
        _items.removeWhere((item) => 
          item.courseId.isEmpty || 
          item.title.isEmpty || 
          (item.price ?? 0.0) < 0
        );
        
        if (_items.isNotEmpty) {
          await _saveCart(); // Save cleaned cart
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
      _items = [];
      // Clear corrupted cart data
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cartKey);
      } catch (_) {}
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<bool> addToCart(CIMACourse course) async {
    if (isInCart(course.id)) {
      return false; // Already in cart
    }

    final cartItem = CartItem(
      courseId: course.id,
      title: course.title,
      instructor: course.instructor,
      price: course.price,
      imageUrl: course.image,
      addedAt: DateTime.now(),
      category: course.category.toString().split('.').last,
      level: course.level.toString().split('.').last,
    );

    _items.add(cartItem);
    await _saveCart();
    notifyListeners();
    return true;
  }

  Future<void> removeFromCart(String courseId) async {
    _items.removeWhere((item) => item.courseId == courseId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }

  bool isInCart(String courseId) {
    return _items.any((item) => item.courseId == courseId);
  }

  Future<void> removeMultipleItems(List<String> courseIds) async {
    _items.removeWhere((item) => courseIds.contains(item.courseId));
    await _saveCart();
    notifyListeners();
  }

  List<String> get courseIds => _items.map((item) => item.courseId).toList();
}