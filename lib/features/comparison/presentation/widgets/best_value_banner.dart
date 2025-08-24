import 'package:flutter/material.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/comparison_result.dart';
import '../../../products/domain/entities/product.dart';

class BestValueBanner extends StatelessWidget {
  final ComparisonResult result;
  final VoidCallback? onTap;
  
  const BestValueBanner({
    super.key,
    required this.result,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cheapest = result.cheapestProduct;
    
    if (cheapest == null) {
      return const SizedBox.shrink();
    }
    
    final bestPrice = result.getPricePerUnit(cheapest);
    final unitName = _getBaseUnitDisplayName(cheapest);
    
    return Container(
      margin: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.spacingL),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(width: ThemeConstants.spacingM),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best Value',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 2),
                      
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          children: [
                            TextSpan(text: '฿${bestPrice.toStringAsFixed(AppConstants.ppuPrecision)}'),
                            TextSpan(
                              text: '/$unitName',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        cheapest.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                if (result.products.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                    ),
                    child: Text(
                      '${result.products.length} items',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getBaseUnitDisplayName(Product product) {
    switch (product.unit.type.toString()) {
      case 'UnitType.weight':
        return product.unitAmount >= 1000 ? 'kg' : 'g';
      case 'UnitType.volume':
        return product.unitAmount >= 1000 ? 'L' : 'ml';
      case 'UnitType.piece':
        return 'piece';
      default:
        return product.unit.displayName;
    }
  }
}

class CompactBestValueBanner extends StatelessWidget {
  final ComparisonResult result;
  
  const CompactBestValueBanner({
    super.key,
    required this.result,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cheapest = result.cheapestProduct;
    
    if (cheapest == null) {
      return const SizedBox.shrink();
    }
    
    final bestPrice = result.getPricePerUnit(cheapest);
    final unitName = _getBaseUnitDisplayName(cheapest);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          
          const SizedBox(width: ThemeConstants.spacingS),
          
          Text(
            'Best: ฿${bestPrice.toStringAsFixed(AppConstants.ppuPrecision)}/$unitName',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getBaseUnitDisplayName(Product product) {
    switch (product.unit.type.toString()) {
      case 'UnitType.weight':
        return product.unitAmount >= 1000 ? 'kg' : 'g';
      case 'UnitType.volume':
        return product.unitAmount >= 1000 ? 'L' : 'ml';
      case 'UnitType.piece':
        return 'piece';
      default:
        return product.unit.displayName;
    }
  }
}