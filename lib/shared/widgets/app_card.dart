import 'package:flutter/material.dart';

import '../../core/constants/theme_constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(ThemeConstants.radiusL),
        border: border,
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: elevation!,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: ThemeConstants.elevationS,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: child,
    );
    
    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(ThemeConstants.radiusL),
        child: cardContent,
      );
    }
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
      child: cardContent,
    );
  }
}

// Specialized card variants
extension AppCardVariants on AppCard {
  static AppCard outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
    Color? borderColor,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      onTap: onTap,
      elevation: 0,
      border: Border.all(
        color: borderColor ?? Colors.grey.shade300,
        width: 1,
      ),
    );
  }

  static AppCard elevated({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      onTap: onTap,
      elevation: ThemeConstants.elevationM,
    );
  }

  static AppCard highlighted({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    required Color highlightColor,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      onTap: onTap,
      border: Border.all(
        color: highlightColor,
        width: 2,
      ),
      elevation: ThemeConstants.elevationS,
    );
  }
}