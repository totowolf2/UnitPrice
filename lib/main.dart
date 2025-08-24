import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/database_provider.dart';
import 'features/app/presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final isar = await DatabaseProvider.initialize();
  
  // Seed default data
  await DatabaseProvider.seedDefaultData(isar);
  
  runApp(
    ProviderScope(
      overrides: [
        // Override the Isar provider with the initialized instance
        isarProvider.overrideWithValue(isar),
      ],
      child: const UnitPriceApp(),
    ),
  );
}
