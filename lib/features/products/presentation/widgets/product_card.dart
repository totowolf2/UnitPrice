import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/use_cases/calculate_unit_price.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../shared/widgets/app_card.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final bool isLowestPrice;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const ProductCard({
    super.key,
    required this.product,
    this.isLowestPrice = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
          // Product image with actions
          Stack(
            children: [
              _buildProductImage(context),
              if (onEdit != null || onDelete != null)
                Positioned(
                  top: ThemeConstants.spacingS,
                  right: ThemeConstants.spacingS,
                  child: _buildActionButtons(context),
                ),
              if (isLowestPrice)
                Positioned(
                  top: ThemeConstants.spacingS,
                  left: ThemeConstants.spacingS,
                  child: _buildCheapestBadge(context),
                ),
            ],
          ),
          
          const SizedBox(height: ThemeConstants.spacingM),
          
          // Product details
          _buildProductDetails(context),
        ],
      ),
    );
  }
  
  Widget _buildProductImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: ThemeConstants.productCardAspectRatio,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeConstants.radiusL),
        ),
        child: product.imagePath != null && File(product.imagePath!).existsSync()
            ? Image.file(
                File(product.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
              )
            : _buildPlaceholder(context),
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
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: onEdit,
              tooltip: AppStrings.editProduct,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, size: 18),
              color: Colors.red,
              onPressed: onDelete,
              tooltip: AppStrings.delete,
            ),
        ],
      ),
    );
  }
  
  Widget _buildCheapestBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
    );
  }
  
  Widget _buildProductDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final useCase = CalculateUnitPriceUseCase();
    
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
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingS,
            vertical: ThemeConstants.spacingXS,
          ),
          decoration: BoxDecoration(
            color: isLowestPrice 
                ? colorScheme.primaryContainer
                : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
          ),
          child: Text(
            useCase.formatPricePerUnit(product),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isLowestPrice ? FontWeight.bold : FontWeight.normal,
              color: isLowestPrice 
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// Loading placeholder for product card
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          AspectRatio(
            aspectRatio: ThemeConstants.productCardAspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ThemeConstants.radiusL),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: ThemeConstants.spacingM),
          
          // Text placeholders
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
            ),
          ),
          
          const SizedBox(height: ThemeConstants.spacingS),
          
          Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
            ),
          ),
          
          const SizedBox(height: ThemeConstants.spacingS),
          
          Container(
            height: 12,
            width: 120,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
            ),
          ),
        ],
      ),
    );
  }
}
