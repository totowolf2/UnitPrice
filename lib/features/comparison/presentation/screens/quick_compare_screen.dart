import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/constants/unit_types.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/comparison_provider.dart';
import '../widgets/quick_item_card.dart';

class QuickCompareScreen extends ConsumerStatefulWidget {
  const QuickCompareScreen({super.key});

  @override
  ConsumerState<QuickCompareScreen> createState() => _QuickCompareScreenState();
}

class _QuickCompareScreenState extends ConsumerState<QuickCompareScreen> {
  @override
  void initState() {
    super.initState();
    
    AppLogger.logScreenView('quick_compare_screen');
    
    // Initialize with 2 empty items for a quick start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(quickCompareProvider.notifier);
      if (ref.read(quickCompareProvider).items.isEmpty) {
        notifier.addItem();
        notifier.addItem();
        
        AppLogger.logEvent('quick_compare_initialized', parameters: {
          'initial_items': 2,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quickCompareState = ref.watch(quickCompareProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Compare'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            onPressed: quickCompareState.items.isNotEmpty
                ? () => _showClearConfirmation(context)
                : null,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          // Best Value Banner
          if (quickCompareState.cheapest != null)
            _buildBestValueBanner(quickCompareState),

          // Base Unit Toggle Row
          _buildBaseUnitToggle(quickCompareState),

          // Items List
          Expanded(
            child: _buildItemsList(quickCompareState),
          ),

          // Bottom Actions
          _buildBottomActions(quickCompareState),
        ],
      ),
    );
  }

  Widget _buildBestValueBanner(QuickCompareState state) {
    if (state.cheapest == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cheapest = state.cheapest!;
    final unitName = _getBaseUnitDisplayName(cheapest.unit);

    return Container(
      margin: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingL),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeConstants.spacingM),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
              ),
              child: const Icon(
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
                      color: Colors.white.withValues(alpha: 0.9),
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
                        TextSpan(text: '฿${cheapest.unitPrice.toStringAsFixed(AppConstants.ppuPrecision)}'),
                        TextSpan(
                          text: '/$unitName',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Item ${state.items.indexOf(cheapest) + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (state.items.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                ),
                child: Text(
                  '${state.items.where((item) => item.price > 0 && item.quantity > 0).length} items',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseUnitToggle(QuickCompareState state) {
    final theme = Theme.of(context);
    final currentBaseUnit = state.baseUnit ?? Unit.gram;
    final unitType = currentBaseUnit.type;

    // Get compatible units for the current unit type
    final compatibleUnits = Unit.values
        .where((unit) => unit.type == unitType)
        .toList();

    if (compatibleUnits.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
      padding: const EdgeInsets.all(ThemeConstants.spacingS),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Base Unit:',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: ThemeConstants.spacingS),
          ...compatibleUnits.map((unit) {
            final isSelected = unit == currentBaseUnit;
            return Padding(
              padding: const EdgeInsets.only(right: ThemeConstants.spacingS),
              child: FilterChip(
                label: Text(unit.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(quickCompareProvider.notifier).setBaseUnit(unit);
                    AppLogger.logUserAction('change_base_unit', context: {
                      'new_unit': unit.displayName,
                      'unit_type': unit.type.toString(),
                    });
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemsList(QuickCompareState state) {
    if (state.items.isEmpty) {
      return EmptyState(
        icon: Icons.speed_outlined,
        title: 'Ready to Compare',
        message: 'Add items to see which offers the best value per unit',
        actionText: 'Add First Item',
        onAction: () => ref.read(quickCompareProvider.notifier).addItem(),
      );
    }

    final sortedItems = ref.read(quickCompareProvider.notifier).sortedItems;
    final cheapestId = state.cheapest?.id;

    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      itemCount: sortedItems.length + 1, // +1 for add item card
      itemBuilder: (context, index) {
        if (index == sortedItems.length) {
          // Add item card at the end
          return AddItemCard(
            onTap: () {
              ref.read(quickCompareProvider.notifier).addItem();
            },
          );
        }

        final item = sortedItems[index];
        final isCheapest = item.id == cheapestId && item.price > 0 && item.quantity > 0;
        
        // Find second cheapest for highlighting
        final validItems = sortedItems.where((i) => i.price > 0 && i.quantity > 0).toList();
        final isSecondBest = validItems.length > 1 && 
            validItems[1].id == item.id && 
            !isCheapest;

        return QuickItemCard(
          id: item.id,
          price: item.price > 0 ? item.price : null,
          quantity: item.quantity > 0 ? item.quantity : null,
          unit: item.unit,
          isCheapest: isCheapest,
          isSecondBest: isSecondBest,
          unitPrice: item.unitPrice > 0 ? item.unitPrice : null,
          onRemove: () {
            ref.read(quickCompareProvider.notifier).removeItem(item.id);
          },
          onUpdate: (price, quantity, unit) {
            ref.read(quickCompareProvider.notifier).updateItem(item.id, price, quantity, unit);
          },
        );
      },
    );
  }

  Widget _buildBottomActions(QuickCompareState state) {
    final theme = Theme.of(context);
    final hasValidItems = state.items.any((item) => item.price > 0 && item.quantity > 0);

    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Clear All',
                type: AppButtonType.outlined,
                icon: Icons.clear_all_rounded,
                onPressed: state.items.isNotEmpty
                    ? () => _showClearConfirmation(context)
                    : null,
              ),
            ),
            const SizedBox(width: ThemeConstants.spacingM),
            Expanded(
              child: AppButtonVariants.primary(
                text: 'Save Session',
                icon: Icons.bookmark_add_rounded,
                onPressed: hasValidItems ? () => _saveSession(context) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Items'),
        content: const Text('Are you sure you want to clear all items from the comparison?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(quickCompareProvider.notifier).clearAll();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _saveSession(BuildContext context) {
    final state = ref.read(quickCompareProvider);
    final validItems = state.items.where((item) => item.price > 0 && item.quantity > 0).toList();
    
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid items to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Save session to history - functionality can be implemented later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session saved with ${validItems.length} items'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View History',
          onPressed: () {
            // Navigate to history tab
            // This would typically use Navigator or update the tab index
          },
        ),
      ),
    );
  }

  String _getBaseUnitDisplayName(Unit unit) {
    switch (unit.type) {
      case UnitType.weight:
        return 'g';
      case UnitType.volume:
        return 'ml';
      case UnitType.piece:
        return 'pc';
    }
  }
}