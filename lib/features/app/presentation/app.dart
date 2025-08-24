import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/theme_provider.dart';
import 'home_screen.dart';

class UnitPriceApp extends ConsumerWidget {
  const UnitPriceApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      
      // Theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Localization
      locale: const Locale('th', 'TH'),
      
      // Home
      home: const HomeScreen(),
    );
  }
}