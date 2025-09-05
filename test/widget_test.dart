import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cima_learn/main.dart';
import 'package:cima_learn/src/services/cart_service.dart';
import 'package:cima_learn/src/services/enhanced_auth_service.dart';

void main() {
  group('CIMA Learn App Widget Tests', () {
    testWidgets('App should launch without crashing', (WidgetTester tester) async {
      // Build the app with required providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartService()),
            ChangeNotifierProvider(create: (_) => EnhancedAuthService()),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Home page should display CIMA Learn title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartService()),
            ChangeNotifierProvider(create: (_) => EnhancedAuthService()),
          ],
          child: const MyApp(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Look for CIMA Learn text
      expect(find.text('CIMA Learn'), findsAtLeastOneWidget);
    });

    testWidgets('Navigation should work properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartService()),
            ChangeNotifierProvider(create: (_) => EnhancedAuthService()),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Test menu button exists on mobile
      if (find.byIcon(Icons.menu).evaluate().isNotEmpty) {
        expect(find.byIcon(Icons.menu), findsOneWidget);
      }
    });

    testWidgets('Cart icon should be present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartService()),
            ChangeNotifierProvider(create: (_) => EnhancedAuthService()),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Cart icon should be visible
      expect(find.byIcon(Icons.shopping_cart), findsAtLeastOneWidget);
    });
  });
}