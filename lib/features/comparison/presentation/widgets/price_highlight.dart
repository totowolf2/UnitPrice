import 'package:flutter/material.dart';

import '../../../products/domain/entities/product.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../shared/models/comparison_result.dart';

class PriceHighlight extends StatelessWidget {
  final ComparisonResult result;
  
  const PriceHighlight({
    super.key,
    required this.result,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!result.hasComparableProducts()) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(ThemeConstants.spacingM),
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: ThemeConstants.elevationM,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: ThemeConstants.spacingL),
          _buildComparison(context),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final cheapest = result.cheapestProduct!;
    
    return Column(
      children: [
        Icon(
          Icons.emoji_events,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: ThemeConstants.spacingS),
        Text(
          'ตัวเลือกที่คุ้มที่สุด',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingS),
        Text(
          cheapest.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildComparison(BuildContext context) {
    final theme = Theme.of(context);
    final sortedProducts = result.getSortedProducts();
    final cheapest = sortedProducts.first;
    final cheapestPrice = result.getPricePerUnit(cheapest);
    
    return Column(
      children: [
        // Best price display
        Container(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          ),
          child: Column(
            children: [
              Text(
                'ราคาต่อหน่วย',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingXS),
              Text(
                '฿${cheapestPrice.toStringAsFixed(AppConstants.ppuPrecision)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: ThemeConstants.spacingM),
        
        // Savings comparison
        if (sortedProducts.length > 1)
          _buildSavingsComparison(context, sortedProducts, cheapestPrice),
      ],
    );
  }
  
  Widget _buildSavingsComparison(
    BuildContext context, 
    List<Product> sortedProducts, 
    double cheapestPrice,
  ) {
    final theme = Theme.of(context);
    final mostExpensive = sortedProducts.last;
    final mostExpensivePrice = result.getPricePerUnit(mostExpensive);
    final totalSavings = mostExpensivePrice - cheapestPrice;
    final percentageSavings = (totalSavings / mostExpensivePrice * 100);
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.savings,
                color: Colors.green.shade700,
                size: 20,
              ),
              const SizedBox(width: ThemeConstants.spacingS),
              Text(
                'คุณประหยัดได้',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConstants.spacingS),
          Text(
            '฿${totalSavings.toStringAsFixed(AppConstants.ppuPrecision)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          Text(
            '(${percentageSavings.toStringAsFixed(1)}% ถูกกว่า)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// Animated price highlight for individual products
class AnimatedPriceHighlight extends StatefulWidget {
  final Product product;
  final bool isHighlighted;
  final double pricePerUnit;
  
  const AnimatedPriceHighlight({
    super.key,
    required this.product,
    required this.isHighlighted,
    required this.pricePerUnit,
  });
  
  @override
  State<AnimatedPriceHighlight> createState() => _AnimatedPriceHighlightState();
}

class _AnimatedPriceHighlightState extends State<AnimatedPriceHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ThemeConstants.animationNormal,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isHighlighted) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedPriceHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingS),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              border: widget.isHighlighted
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Text(
              '฿${widget.pricePerUnit.toStringAsFixed(AppConstants.ppuPrecision)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: widget.isHighlighted 
                    ? FontWeight.bold 
                    : FontWeight.normal,
                color: widget.isHighlighted
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}