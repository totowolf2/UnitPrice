// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unitprice/features/app/presentation/app.dart';

void main() {
  testWidgets('App smoke test - loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: UnitPriceApp()));
    await tester.pumpAndSettle();

    // Verify that the main app components are present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Should have navigation tabs
    expect(find.text('สินค้า'), findsOneWidget);
    expect(find.text('เปรียบเทียบ'), findsOneWidget);
    expect(find.text('ประวัติ'), findsOneWidget);
    expect(find.text('ตั้งค่า'), findsOneWidget);
  });
}
