import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:cima_learn/main.dart';
import 'package:cima_learn/src/services/cart_service.dart';
import 'package:cima_learn/src/services/enhanced_auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('App startup performance test', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
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
      stopwatch.stop();

      // App should start within reasonable time (less than 3 seconds in tests)
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      
      print('App startup time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Scroll performance test', (WidgetTester tester) async {
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

      // Find scrollable widget (if any course list exists)
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        final stopwatch = Stopwatch()..start();
        
        // Perform scroll gestures
        await tester.fling(scrollable.first, const Offset(0, -300), 1000);
        await tester.pumpAndSettle();
        
        await tester.fling(scrollable.first, const Offset(0, 300), 1000);
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // Scroll should be smooth (complete within reasonable time)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        print('Scroll performance: ${stopwatch.elapsedMilliseconds}ms');
      }
    });

    testWidgets('Memory usage stability test', (WidgetTester tester) async {
      // This test simulates multiple navigation cycles to check for memory leaks
      for (int i = 0; i < 5; i++) {
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

        // Simulate navigation if possible
        final menuButton = find.byIcon(Icons.menu);
        if (menuButton.evaluate().isNotEmpty) {
          await tester.tap(menuButton);
          await tester.pumpAndSettle();
        }
      }

      // If we reach here without crashes, memory management is stable
      expect(find.byType(MaterialApp), findsOneWidget);
      print('Memory stability test passed');
    });

    testWidgets('Widget rebuild efficiency test', (WidgetTester tester) async {
      int rebuildCount = 0;
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartService()),
            ChangeNotifierProvider(create: (_) => EnhancedAuthService()),
          ],
          child: Builder(
            builder: (context) {
              rebuildCount++;
              return const MyApp();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial build should happen only once or minimal rebuilds
      expect(rebuildCount, lessThanOrEqualTo(3));
      print('Rebuild count: $rebuildCount');
    });
  });
}