import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unitprice/features/products/presentation/screens/product_form_screen.dart';

void main() {
  group('ProductFormScreen Widget Tests', () {
    testWidgets('should show validation error when name is empty', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductFormScreen(),
          ),
        ),
      );
      
      // Wait for the form to load
      await tester.pumpAndSettle();
      
      // Find the save button and tap it without filling the form
      final saveButton = find.text('บันทึก');
      expect(saveButton, findsOneWidget);
      
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      
      // Should show validation error for name field
      expect(find.text('กรุณาใส่ชื่อสินค้า'), findsOneWidget);
    });
    
    testWidgets('should show validation error when price is invalid', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductFormScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Fill name field
      await tester.enterText(find.byType(TextFormField).first, 'Test Product');
      
      // Find price field and enter invalid price
      final priceField = find.byKey(const Key('price_field'));
      expect(priceField, findsOneWidget);
      await tester.enterText(priceField, '0');
      
      // Try to save
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();
      
      // Should show validation error for price
      expect(find.text('ราคาต้องมากกว่า 0'), findsOneWidget);
    });
    
    testWidgets('should show validation error when pack count is invalid', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductFormScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Fill required fields
      await tester.enterText(find.byType(TextFormField).first, 'Test Product');
      await tester.enterText(find.byKey(const Key('price_field')), '10.50');
      
      // Enter invalid pack count
      final packCountField = find.byKey(const Key('pack_count_field'));
      expect(packCountField, findsOneWidget);
      await tester.enterText(packCountField, '0');
      
      // Try to save
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();
      
      // Should show validation error
      expect(find.text('จำนวนแพ็คต้องมากกว่า 0'), findsOneWidget);
    });
    
    testWidgets('should show validation error when unit amount is invalid', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductFormScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Fill required fields
      await tester.enterText(find.byType(TextFormField).first, 'Test Product');
      await tester.enterText(find.byKey(const Key('price_field')), '10.50');
      await tester.enterText(find.byKey(const Key('pack_count_field')), '1');
      
      // Enter invalid unit amount
      final unitAmountField = find.byKey(const Key('unit_amount_field'));
      expect(unitAmountField, findsOneWidget);
      await tester.enterText(unitAmountField, '0');
      
      // Try to save
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();
      
      // Should show validation error
      expect(find.text('ปริมาณต่อชิ้นต้องมากกว่า 0'), findsOneWidget);
    });
    
    testWidgets('should calculate and display unit price preview', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductFormScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Fill all required fields
      await tester.enterText(find.byType(TextFormField).first, 'Test Product');
      await tester.enterText(find.byKey(const Key('price_field')), '100');
      await tester.enterText(find.byKey(const Key('pack_count_field')), '2');
      await tester.enterText(find.byKey(const Key('unit_amount_field')), '500');
      
      // Wait for calculation
      await tester.pumpAndSettle();
      
      // Should show unit price preview
      // 100 / (2 * 500) = 0.1 THB per gram
      expect(find.textContaining('0.10'), findsWidgets);
    });
    
    testWidgets('should show form fields with correct labels', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductFormScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check for required form fields
      expect(find.text('ชื่อสินค้า'), findsOneWidget);
      expect(find.text('ราคา (฿)'), findsOneWidget);
      expect(find.text('จำนวนแพ็ค'), findsOneWidget);
      expect(find.text('ปริมาณต่อชิ้น'), findsOneWidget);
      expect(find.text('หน่วย'), findsOneWidget);
      expect(find.text('หมวดหมู่'), findsOneWidget);
    });
    
    testWidgets('should have image picker button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductFormScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Look for image picker elements
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
      expect(find.text('เพิ่มรูปภาพ'), findsOneWidget);
    });
  });
}