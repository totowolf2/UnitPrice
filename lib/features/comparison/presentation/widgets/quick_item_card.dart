import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/unit_types.dart';

class QuickItemCard extends StatefulWidget {
  final String? id;
  final double? price;
  final double? quantity;
  final Unit? unit;
  final bool isCheapest;
  final bool isSecondBest;
  final double? unitPrice;
  final VoidCallback? onRemove;
  final Function(double price, double quantity, Unit unit)? onUpdate;
  
  const QuickItemCard({
    super.key,
    this.id,
    this.price,
    this.quantity,
    this.unit,
    this.isCheapest = false,
    this.isSecondBest = false,
    this.unitPrice,
    this.onRemove,
    this.onUpdate,
  });
  
  @override
  State<QuickItemCard> createState() => _QuickItemCardState();
}

class _QuickItemCardState extends State<QuickItemCard> {
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  Unit? _selectedUnit;
  
  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.price?.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.quantity?.toString() ?? '',
    );
    _selectedUnit = widget.unit;
  }
  
  @override
  void didUpdateWidget(QuickItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.price != oldWidget.price) {
      _priceController.text = widget.price?.toString() ?? '';
    }
    if (widget.quantity != oldWidget.quantity) {
      _quantityController.text = widget.quantity?.toString() ?? '';
    }
    if (widget.unit != oldWidget.unit) {
      _selectedUnit = widget.unit;
    }
  }
  
  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color cardColor = theme.colorScheme.surface;
    Color borderColor = theme.colorScheme.outline.withValues(alpha: 0.2);
    double borderWidth = 1;
    
    if (widget.isCheapest) {
      cardColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
      borderColor = theme.colorScheme.primary;
      borderWidth = 2;
    } else if (widget.isSecondBest) {
      cardColor = theme.colorScheme.secondaryContainer.withValues(alpha: 0.3);
      borderColor = theme.colorScheme.secondary.withValues(alpha: 0.5);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.isCheapest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.spacingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Best',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (widget.isSecondBest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.spacingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
                    ),
                    child: Text(
                      '2nd',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                
                IconButton(
                  onPressed: widget.onRemove,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacingS),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildPriceField(theme),
                ),
                const SizedBox(width: ThemeConstants.spacingS),
                Expanded(
                  flex: 2,
                  child: _buildQuantityField(theme),
                ),
                const SizedBox(width: ThemeConstants.spacingS),
                Expanded(
                  flex: 3,
                  child: _buildUnitSelector(theme),
                ),
              ],
            ),
            
            if (widget.unitPrice != null) ...[
              const SizedBox(height: ThemeConstants.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
                ),
                child: Text(
                  '฿${widget.unitPrice!.toStringAsFixed(AppConstants.ppuPrecision)}/${_getBaseUnitName(_selectedUnit)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '฿',
            prefixStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingS,
              vertical: ThemeConstants.spacingS,
            ),
          ),
          style: theme.textTheme.bodyMedium,
          onChanged: _onInputChanged,
        ),
      ],
    );
  }
  
  Widget _buildQuantityField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qty',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: '0.0',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingS,
              vertical: ThemeConstants.spacingS,
            ),
          ),
          style: theme.textTheme.bodyMedium,
          onChanged: _onInputChanged,
        ),
      ],
    );
  }
  
  Widget _buildUnitSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<Unit>(
          value: _selectedUnit,
          decoration: InputDecoration(
            hintText: 'Select',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingS,
              vertical: ThemeConstants.spacingS,
            ),
          ),
          style: theme.textTheme.bodyMedium,
          items: Unit.values.map((unit) {
            return DropdownMenuItem<Unit>(
              value: unit,
              child: Text(
                unit.displayName,
                style: theme.textTheme.bodySmall,
              ),
            );
          }).toList(),
          onChanged: (Unit? value) {
            setState(() {
              _selectedUnit = value;
            });
            _onInputChanged('');
          },
        ),
      ],
    );
  }
  
  void _onInputChanged(String _) {
    final price = double.tryParse(_priceController.text);
    final quantity = double.tryParse(_quantityController.text);
    
    if (price != null && quantity != null && _selectedUnit != null) {
      widget.onUpdate?.call(price, quantity, _selectedUnit!);
    }
  }
  
  String _getBaseUnitName(Unit? unit) {
    if (unit == null) return 'unit';
    
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

class AddItemCard extends StatelessWidget {
  final VoidCallback? onTap;
  
  const AddItemCard({
    super.key,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingM),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          child: SizedBox(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.spacingM),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: ThemeConstants.spacingS),
                
                Text(
                  'Add Item',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}