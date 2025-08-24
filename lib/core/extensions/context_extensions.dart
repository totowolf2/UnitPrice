import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  
  // MediaQuery shortcuts
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  
  // Navigation shortcuts
  NavigatorState get navigator => Navigator.of(this);
  void pop<T extends Object?>([T? result]) => navigator.pop(result);
  Future<T?> push<T extends Object?>(Route<T> route) => navigator.push(route);
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) => navigator.pushNamed(routeName, arguments: arguments);
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> newRoute, {
    TO? result,
  }) => navigator.pushReplacement(newRoute, result: result);
  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Route<T> newRoute,
    RoutePredicate predicate,
  ) => navigator.pushAndRemoveUntil(newRoute, predicate);
  
  // Scaffold shortcuts
  ScaffoldState? get scaffold => Scaffold.maybeOf(this);
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
  
  void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: colorScheme.error,
    );
  }
  
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }
  
  // Dialog shortcuts
  Future<T?> showCustomDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }
  
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'ยืนยัน',
    String cancelText = 'ยกเลิก',
    bool isDangerous = false,
  }) {
    return showCustomDialog<bool>(
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            style: isDangerous
                ? FilledButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  // Responsive breakpoints
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
  
  // Safe area
  EdgeInsets get safeArea => MediaQuery.of(this).padding;
  double get statusBarHeight => safeArea.top;
  double get bottomPadding => safeArea.bottom;
  
  // Keyboard
  bool get isKeyboardOpen => viewInsets.bottom > 0;
  double get keyboardHeight => viewInsets.bottom;
  
  // Orientation
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
}