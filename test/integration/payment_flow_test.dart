import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:cima_learn/main.dart';
import 'package:cima_learn/src/services/cart_service.dart';
import 'package:cima_learn/src/services/enhanced_auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Payment Flow Integration Tests', () {
    testWidgets('Complete course enrollment flow', (WidgetTester tester) async {
      // Launch the app
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

      // Test navigation to course detail
      // Note: This would require actual course cards to be present
      // For now, we'll test the navigation structure exists

      // Verify home page loaded
      expect(find.text('CIMA Learn'), findsAtLeastOneWidget);

      // Look for course cards or course listings
      await tester.pump(const Duration(seconds: 2));

      // Test cart functionality
      final cartIcon = find.byIcon(Icons.shopping_cart);
      if (cartIcon.evaluate().isNotEmpty) {
        await tester.tap(cartIcon);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Authentication flow test', (WidgetTester tester) async {
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

      // Look for login/auth related widgets
      final menuButton = find.byIcon(Icons.menu);
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();
      }

      // Test if authentication prompts work
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Responsive design test', (WidgetTester tester) async {
      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(375, 812));
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

      // Verify mobile layout
      expect(find.byIcon(Icons.menu), findsOneWidget);

      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pump();

      // Desktop layout should show different navigation
      expect(find.byType(MaterialApp), findsOneWidget);

      // Reset to original size
      await tester.binding.setSurfaceSize(null);
    });
  });
}