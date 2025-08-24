import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple widget tests that don't require database
void main() {
  group('Simple Widget Tests', () {
    testWidgets('Theme mode dropdown should work correctly', (tester) async {
      ThemeMode selectedMode = ThemeMode.system;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<ThemeMode>(
                  value: selectedMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('ตามระบบ'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('สว่าง'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('มืด'),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      setState(() {
                        selectedMode = mode;
                      });
                    }
                  },
                );
              },
            ),
          ),
        ),
      );
      
      // Check initial state
      expect(find.text('ตามระบบ'), findsOneWidget);
      
      // Tap dropdown
      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();
      
      // Check dropdown items
      expect(find.text('สว่าง'), findsOneWidget);
      expect(find.text('มืด'), findsOneWidget);
      
      // Select light mode
      await tester.tap(find.text('สว่าง').last);
      await tester.pumpAndSettle();
      
      // Verify selection
      expect(selectedMode, equals(ThemeMode.light));
    });
    
    testWidgets('Form validation should work with TextFormField', (tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาใส่ข้อมูล';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'ราคาต้องมากกว่า 0';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      formKey.currentState?.validate();
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState!.validate();
                    },
                    child: const Text('Validate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // Test empty validation
      await tester.tap(find.text('Validate'));
      await tester.pumpAndSettle();
      expect(find.text('กรุณาใส่ข้อมูล'), findsOneWidget);
      
      // Test invalid number
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.pumpAndSettle();
      expect(find.text('ราคาต้องมากกว่า 0'), findsOneWidget);
      
      // Test valid input
      await tester.enterText(find.byType(TextFormField), '10.50');
      await tester.pumpAndSettle();
      expect(find.text('กรุณาใส่ข้อมูล'), findsNothing);
      expect(find.text('ราคาต้องมากกว่า 0'), findsNothing);
    });
    
    testWidgets('Dialog should show and dismiss correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('ยืนยัน'),
                        content: const Text('คุณต้องการดำเนินการต่อหรือไม่?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('ยกเลิก'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('ยืนยัน'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially no dialog
      expect(find.text('ยืนยัน'), findsNothing);
      
      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      
      // Dialog should appear
      expect(find.text('ยืนยัน'), findsWidgets);
      expect(find.text('คุณต้องการดำเนินการต่อหรือไม่?'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);
      
      // Dismiss dialog
      await tester.tap(find.text('ยกเลิก'));
      await tester.pumpAndSettle();
      
      // Dialog should be gone
      expect(find.text('ยืนยัน'), findsNothing);
    });
    
    testWidgets('List filtering should work with basic logic', (tester) async {
      final List<String> items = ['Apple', 'Banana', 'Cherry', 'Date'];
      String filter = '';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                final filteredItems = items
                    .where((item) => item.toLowerCase().contains(filter.toLowerCase()))
                    .toList();
                
                return Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Filter items...',
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredItems[index]),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      
      // Initially all items visible
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      
      // Filter by 'a'
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();
      
      // Only items with 'a' should be visible
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Cherry'), findsNothing);
      
      // Filter by 'ch'
      await tester.enterText(find.byType(TextField), 'ch');
      await tester.pumpAndSettle();
      
      // Only Cherry should be visible
      expect(find.text('Cherry'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Banana'), findsNothing);
      expect(find.text('Date'), findsNothing);
    });
    
    testWidgets('List sorting should work correctly', (tester) async {
      List<Map<String, dynamic>> products = [
        {'name': 'Product A', 'price': 100.0},
        {'name': 'Product B', 'price': 50.0},
        {'name': 'Product C', 'price': 75.0},
      ];
      
      bool sortByPrice = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                final sortedProducts = List<Map<String, dynamic>>.from(products);
                if (sortByPrice) {
                  sortedProducts.sort((a, b) => a['price'].compareTo(b['price']));
                } else {
                  sortedProducts.sort((a, b) => a['name'].compareTo(b['name']));
                }
                
                return Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              sortByPrice = !sortByPrice;
                            });
                          },
                          child: Text(sortByPrice ? 'Sort by Name' : 'Sort by Price'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: sortedProducts.length,
                        itemBuilder: (context, index) {
                          final product = sortedProducts[index];
                          return ListTile(
                            title: Text(product['name']),
                            trailing: Text('฿${product['price']}'),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      
      // Initially sorted by name (A, B, C)
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect((listTiles[0].title as Text).data, equals('Product A'));
      expect((listTiles[1].title as Text).data, equals('Product B'));
      expect((listTiles[2].title as Text).data, equals('Product C'));
      
      // Sort by price
      await tester.tap(find.text('Sort by Price'));
      await tester.pumpAndSettle();
      
      // Should be sorted by price (B=50, C=75, A=100)
      final sortedListTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect((sortedListTiles[0].title as Text).data, equals('Product B'));
      expect((sortedListTiles[1].title as Text).data, equals('Product C'));
      expect((sortedListTiles[2].title as Text).data, equals('Product A'));
    });
  });
}