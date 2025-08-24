import 'dart:convert';

import 'package:flutter/material.dart';

import '../../domain/entities/comparison_session.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../shared/widgets/app_card.dart';

class SessionHistoryItem extends StatelessWidget {
  final ComparisonSession session;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  const SessionHistoryItem({
    super.key,
    required this.session,
    this.onTap,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productSnapshots = _parseProductSnapshots(session.productSnapshots);
    final cheapestProduct = _findCheapestProduct(productSnapshots);
    
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and delete button
          Row(
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: ThemeConstants.spacingS),
              Text(
                _formatDateTime(session.createdAt),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: onDelete,
                  color: Colors.red,
                  tooltip: AppStrings.delete,
                ),
            ],
          ),
          
          const SizedBox(height: ThemeConstants.spacingS),
          
          // Products summary
          Text(
            '${productSnapshots.length} สินค้า',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: ThemeConstants.spacingS),
          
          // Product names
          Text(
            productSnapshots.map((p) => p['name'] as String).join(', '),
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: ThemeConstants.spacingM),
          
          // Best deal highlight
          if (cheapestProduct != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.spacingM,
                vertical: ThemeConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: ThemeConstants.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ตัวเลือกที่คุ้มที่สุด',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          cheapestProduct['name'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '฿${(cheapestProduct['ppu'] as double).toStringAsFixed(AppConstants.ppuPrecision)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  List<Map<String, dynamic>> _parseProductSnapshots(List<String> snapshots) {
    return snapshots.map((snapshot) {
      try {
        return jsonDecode(snapshot) as Map<String, dynamic>;
      } catch (error) {
        return <String, dynamic>{};
      }
    }).where((snapshot) => snapshot.isNotEmpty).toList();
  }
  
  Map<String, dynamic>? _findCheapestProduct(List<Map<String, dynamic>> products) {
    if (products.isEmpty) return null;
    
    return products.reduce((cheapest, current) {
      final cheapestPpu = cheapest['ppu'] as double? ?? double.infinity;
      final currentPpu = current['ppu'] as double? ?? double.infinity;
      return currentPpu < cheapestPpu ? current : cheapest;
    });
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      // Today
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return 'วันนี้ $hour:$minute';
    } else if (difference.inDays == 1) {
      // Yesterday
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return 'เมื่อวาน $hour:$minute';
    } else if (difference.inDays < 7) {
      // This week
      return '${difference.inDays} วันที่แล้ว';
    } else {
      // Older
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      return '$day/$month/$year';
    }
  }
}

// Skeleton loading for history items
class SessionHistoryItemSkeleton extends StatelessWidget {
  const SessionHistoryItemSkeleton({super.key});
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: ThemeConstants.spacingS),
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: ThemeConstants.spacingM),
          
          // Product count
          Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
            ),
          ),
          
          const SizedBox(height: ThemeConstants.spacingS),
          
          // Product names
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
            ),
          ),
          
          const SizedBox(height: ThemeConstants.spacingM),
          
          // Best deal
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
          ),
        ],
      ),
    );
  }
}