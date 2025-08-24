import 'dart:io';

import 'package:flutter/material.dart';

import '../../../products/domain/entities/product.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/models/comparison_result.dart';

class ComparisonCard extends StatelessWidget {
  final Product product;
  final ComparisonResult result;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  
  const ComparisonCard({
    super.key,
    required this.product,
    required this.result,
    this.onRemove,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLowestPrice = result.isCheapest(product);
    
    return AppCard(
      onTap: onTap,
      border: isLowestPrice ? Border.all(
        color: colorScheme.primary,
        width: 2,
      ) : null,
      backgroundColor: isLowestPrice 
          ? colorScheme.primaryContainer.withOpacity(0.1)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with cheapest badge and remove button
          Row(
            children: [
              if (isLowestPrice)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spacingS,
                    vertical: ThemeConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
                  ),
                  child: Text(
                    AppStrings.cheapest,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onRemove,
                  tooltip: 'ลบ',
                ),
            ],
          ),
          
          const SizedBox(height: ThemeConstants.spacingS),
          
          // Product image
          AspectRatio(
            aspectRatio: ThemeConstants.productCardAspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              child: product.imagePath != null && File(product.imagePath!).existsSync()
                  ? Image.file(
                      File(product.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
          ),
          
          const SizedBox(height: ThemeConstants.spacingM),
          
          // Product details
          _buildProductDetails(context),
        ],
      ),
    );
  }
  
  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.shopping_basket_outlined,
          size: 32,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
  
  Widget _buildProductDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLowestPrice = result.isCheapest(product);
    final pricePerUnit = result.getPricePerUnit(product);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: ThemeConstants.spacingXS),
        
        // Product price
        Text(
          '฿${product.price.toStringAsFixed(AppConstants.pricePrecision)}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: ThemeConstants.spacingXS),
        
        // Package info
        Text(
          '${product.unitAmount} ${product.unit.displayName} × ${product.packCount}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(height: ThemeConstants.spacingS),
        
        // Price per unit with highlight
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingM,
            vertical: ThemeConstants.spacingS,
          ),
          decoration: BoxDecoration(
            color: isLowestPrice 
                ? colorScheme.primaryContainer
                : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          ),
          child: Column(
            children: [
              Text(
                AppStrings.pricePerUnit,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isLowestPrice 
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingXS),
              Text(
                '฿${pricePerUnit.toStringAsFixed(AppConstants.ppuPrecision)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLowestPrice 
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: ThemeConstants.spacingS),
        
        // Savings indicator (if not the cheapest)
        if (!isLowestPrice && result.cheapestProduct != null)
          _buildSavingsIndicator(context),
      ],
    );
  }
  
  Widget _buildSavingsIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final cheapestPrice = result.getPricePerUnit(result.cheapestProduct!);
    final currentPrice = result.getPricePerUnit(product);
    final difference = currentPrice - cheapestPrice;
    final percentageMore = (difference / cheapestPrice * 100);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingS,
        vertical: ThemeConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
      ),
      child: Text(
        '+฿${difference.toStringAsFixed(AppConstants.ppuPrecision)} (${percentageMore.toStringAsFixed(1)}%)',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.orange.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}