import 'package:flutter/material.dart';

import '../../core/constants/theme_constants.dart';

enum AppButtonType { filled, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final Color? color;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.filled,
    this.icon,
    this.color,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  });
  
  const AppButton.filled({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : type = AppButtonType.filled;
  
  const AppButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : type = AppButtonType.outlined;
  
  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : type = AppButtonType.text;
  
  @override
  Widget build(BuildContext context) {
    Widget buttonContent = _buildButtonContent();
    
    if (isExpanded) {
      buttonContent = SizedBox(
        width: double.infinity,
        child: buttonContent,
      );
    }
    
    return buttonContent;
  }
  
  Widget _buildButtonContent() {
    final buttonPadding = padding ?? const EdgeInsets.symmetric(
      horizontal: ThemeConstants.spacingL,
      vertical: ThemeConstants.spacingM,
    );
    
    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : _buildButtonChild();
    
    switch (type) {
      case AppButtonType.filled:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
          ),
          child: child,
        );
        
      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: color != null ? BorderSide(color: color!) : null,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
          ),
          child: child,
        );
        
      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: color,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
          ),
          child: child,
        );
    }
  }
  
  Widget _buildButtonChild() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: ThemeConstants.spacingS),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

// Specialized button variants
extension AppButtonVariants on AppButton {
  static AppButton primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    EdgeInsetsGeometry? padding,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
      padding: padding,
      type: AppButtonType.filled,
      color: ThemeConstants.primaryBlue,
    );
  }

  static AppButton success({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    EdgeInsetsGeometry? padding,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
      padding: padding,
      type: AppButtonType.filled,
      color: ThemeConstants.primaryGreen,
    );
  }

  static AppButton warning({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    EdgeInsetsGeometry? padding,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
      padding: padding,
      type: AppButtonType.filled,
      color: ThemeConstants.primaryOrange,
    );
  }

  static AppButton destructive({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    EdgeInsetsGeometry? padding,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
      padding: padding,
      type: AppButtonType.outlined,
      color: Colors.red,
    );
  }
}