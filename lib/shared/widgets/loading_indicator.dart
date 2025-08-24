import 'package:flutter/material.dart';

import '../../core/constants/theme_constants.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool overlay;
  
  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
    this.overlay = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget loadingWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? theme.colorScheme.primary,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: ThemeConstants.spacingM),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
    
    if (overlay) {
      return Container(
        color: theme.colorScheme.surface.withOpacity(0.8),
        child: Center(child: loadingWidget),
      );
    }
    
    return Center(child: loadingWidget);
  }
}

// Specialized loading indicator variants
extension LoadingIndicatorVariants on LoadingIndicator {
  static LoadingIndicator small({
    Key? key,
    String? message,
    Color? color,
  }) {
    return LoadingIndicator(
      key: key,
      message: message,
      color: color,
      size: 16.0,
    );
  }

  static LoadingIndicator large({
    Key? key,
    String? message,
    Color? color,
  }) {
    return LoadingIndicator(
      key: key,
      message: message,
      color: color,
      size: 48.0,
    );
  }

  static LoadingIndicator overlay({
    Key? key,
    String? message,
    double size = 24.0,
    Color? color,
  }) {
    return LoadingIndicator(
      key: key,
      message: message,
      size: size,
      color: color,
      overlay: true,
    );
  }

  static LoadingIndicator fullScreen({
    Key? key,
    String? message,
  }) {
    return LoadingIndicator(
      key: key,
      message: message ?? 'กำลังโหลด...',
      size: 48.0,
      overlay: true,
    );
  }
}

// Shimmer loading effect for lists
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  
  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });
  
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }
    
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Pre-built shimmer placeholders
class ShimmerCard extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  
  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width = double.infinity,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? 
              BorderRadius.circular(ThemeConstants.radiusL),
        ),
      ),
    );
  }
}