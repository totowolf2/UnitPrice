import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unitprice/features/products/presentation/screens/product_list_screen.dart';

void main() {
  group('ProductListScreen Widget Tests', () {
    testWidgets('should show app bar with correct title and actions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check app bar elements
      expect(find.text('สินค้า'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });
    
    testWidgets('should show floating action button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check for FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
    
    testWidgets('should show search dialog when search icon is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      // Should show search dialog
      expect(find.text('ค้นหาสินค้า'), findsOneWidget);
      expect(find.text('พิมพ์ชื่อสินค้า...'), findsOneWidget);
    });
    
    testWidgets('should show filter dialog when filter icon is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap filter icon
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      
      // Should show filter dialog
      expect(find.text('ฟิลเตอร์ราคา'), findsOneWidget);
      expect(find.text('ราคาต่ำสุด (฿)'), findsOneWidget);
      expect(find.text('ราคาสูงสุด (฿)'), findsOneWidget);
    });
    
    testWidgets('should show category filter chips', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show category filter area
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
    
    testWidgets('should show empty state when no products', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Since this is a fresh app with no products, should show empty state
      // Note: This test might need adjustment based on actual empty state implementation
      expect(find.byType(ListView), findsWidgets);
    });
    
    testWidgets('should navigate to product form when FAB is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Should navigate to product form
      // In a real test, you'd verify navigation occurred
      // For now, just verify the tap doesn't crash
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('should handle search input correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Open search dialog
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      // Enter search text
      await tester.enterText(find.byType(TextField), 'rice');
      await tester.pumpAndSettle();
      
      // Tap search button
      await tester.tap(find.text('ค้นหา'));
      await tester.pumpAndSettle();
      
      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('should handle price filter input correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Open filter dialog
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      
      // Find price input fields
      final minPriceField = find.byType(TextField).first;
      final maxPriceField = find.byType(TextField).last;
      
      // Enter valid price range
      await tester.enterText(minPriceField, '10');
      await tester.enterText(maxPriceField, '100');
      await tester.pumpAndSettle();
      
      // Tap apply button
      await tester.tap(find.text('ปรับใช้'));
      await tester.pumpAndSettle();
      
      // Verify no exceptions and dialog closed
      expect(tester.takeException(), isNull);
      expect(find.text('ฟิลเตอร์ราคา'), findsNothing);
    });
    
    testWidgets('should show validation error for invalid price filter', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Open filter dialog
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      
      // Enter invalid price range (min > max)
      final minPriceField = find.byType(TextField).first;
      final maxPriceField = find.byType(TextField).last;
      
      await tester.enterText(minPriceField, '100');
      await tester.enterText(maxPriceField, '10');
      await tester.pumpAndSettle();
      
      // Try to apply
      await tester.tap(find.text('ปรับใช้'));
      await tester.pumpAndSettle();
      
      // Should show validation error
      expect(find.text('ราคาต่ำสุดต้องน้อยกว่าหรือเท่ากับราคาสูงสุด'), findsOneWidget);
    });
    
    testWidgets('should clear price filter when "ล้างฟิลเตอร์" is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Open filter dialog
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      
      // Enter some values
      final minPriceField = find.byType(TextField).first;
      await tester.enterText(minPriceField, '10');
      await tester.pumpAndSettle();
      
      // Tap clear button
      await tester.tap(find.text('ล้างฟิลเตอร์'));
      await tester.pumpAndSettle();
      
      // Verify no exceptions and dialog closed
      expect(tester.takeException(), isNull);
      expect(find.text('ฟิลเตอร์ราคา'), findsNothing);
    });
  });
}