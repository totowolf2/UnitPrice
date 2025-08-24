import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/theme_constants.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// App theme provider
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ThemeConstants.primaryBlue,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: ThemeConstants.elevationS,
      backgroundColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: ThemeConstants.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingL,
          vertical: ThemeConstants.spacingM,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingL,
          vertical: ThemeConstants.spacingM,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingL,
          vertical: ThemeConstants.spacingM,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        borderSide: BorderSide(color: ThemeConstants.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingM,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXL),
      ),
      elevation: ThemeConstants.elevationM,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: ThemeConstants.elevationM,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    dividerTheme: DividerThemeData(
      thickness: 1,
      color: Colors.grey.shade300,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ThemeConstants.primaryBlue,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: ThemeConstants.elevationS,
      backgroundColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: ThemeConstants.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingL,
          vertical: ThemeConstants.spacingM,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingL,
          vertical: ThemeConstants.spacingM,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingL,
          vertical: ThemeConstants.spacingM,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        borderSide: BorderSide(color: ThemeConstants.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingM,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXL),
      ),
      elevation: ThemeConstants.elevationM,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: ThemeConstants.elevationM,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    dividerTheme: const DividerThemeData(thickness: 1),
  );
}
