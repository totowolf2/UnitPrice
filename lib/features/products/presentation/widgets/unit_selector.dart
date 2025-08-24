import 'package:flutter/material.dart';

import '../../../../core/constants/unit_types.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../shared/models/unit_type.dart';

class UnitSelector extends StatelessWidget {
  final Unit selectedUnit;
  final ValueChanged<Unit> onChanged;
  final bool enabled;
  
  const UnitSelector({
    super.key,
    required this.selectedUnit,
    required this.onChanged,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'หน่วย',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: ThemeConstants.spacingS),
        
        _buildUnitTypeSelector(context),
      ],
    );
  }
  
  Widget _buildUnitTypeSelector(BuildContext context) {
    final unitTypes = UnitTypeModel.getAllUnitTypes();
    
    return Column(
      children: unitTypes.map((unitType) => 
        _buildUnitTypeSection(context, unitType)).toList(),
    );
  }
  
  Widget _buildUnitTypeSection(BuildContext context, UnitTypeModel unitType) {
    final theme = Theme.of(context);
    final hasSelectedUnit = unitType.units.contains(selectedUnit);
    
    return Card(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingS),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unitType.displayName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: hasSelectedUnit 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: ThemeConstants.spacingS),
            
            Wrap(
              spacing: ThemeConstants.spacingS,
              children: unitType.units.map((unit) => 
                _buildUnitChip(context, unit)).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUnitChip(BuildContext context, Unit unit) {
    final theme = Theme.of(context);
    final isSelected = unit == selectedUnit;
    
    return FilterChip(
      label: Text(unit.displayName),
      selected: isSelected,
      onSelected: enabled ? (selected) {
        if (selected) {
          onChanged(unit);
        }
      } : null,
      backgroundColor: theme.colorScheme.surfaceVariant,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

// Simple dropdown version for compact forms
class UnitDropdown extends StatelessWidget {
  final Unit selectedUnit;
  final ValueChanged<Unit?> onChanged;
  final bool enabled;
  final String? labelText;
  
  const UnitDropdown({
    super.key,
    required this.selectedUnit,
    required this.onChanged,
    this.enabled = true,
    this.labelText,
  });
  
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Unit>(
      value: selectedUnit,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: labelText ?? 'หน่วย',
        prefixIcon: const Icon(Icons.straighten),
      ),
      items: Unit.values.map((unit) {
        final unitType = UnitTypeModel.getAllUnitTypes()
            .firstWhere((type) => type.type == unit.type);
        
        return DropdownMenuItem<Unit>(
          value: unit,
          child: Text('${unit.displayName} (${unitType.displayName})'),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'กรุณาเลือกหน่วย';
        }
        return null;
      },
    );
  }
}