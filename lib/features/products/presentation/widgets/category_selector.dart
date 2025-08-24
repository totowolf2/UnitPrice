import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/category_provider.dart';

class CategorySelector extends ConsumerWidget {
  // Selected category id is stored as String? for compatibility
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final String? labelText;
  
  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
    this.enabled = true,
    this.labelText,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) => _buildCategoryDropdown(context, categories),
      loading: () => _buildLoadingDropdown(context),
      error: (error, stackTrace) => _buildErrorDropdown(context, error),
    );
  }
  
  Widget _buildCategoryDropdown(BuildContext context, List<Category> categories) {
    // Add "no category" option
    final items = [
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('ไม่ระบุหมวดหมู่'),
      ),
      ...categories.map((category) => DropdownMenuItem<String?>(
        // Convert int id to String for the dropdown value
        value: category.id.toString(),
        child: Text(category.name),
      )).toList(),
    ];
    
    return DropdownButtonFormField<String?>(
      value: selectedCategoryId,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: labelText ?? AppStrings.category,
        prefixIcon: const Icon(Icons.category),
      ),
      items: items,
    );
  }
  
  Widget _buildLoadingDropdown(BuildContext context) {
    return DropdownButtonFormField<String?>(
      onChanged: null,
      decoration: InputDecoration(
        labelText: labelText ?? AppStrings.category,
        prefixIcon: const Icon(Icons.category),
        // Use the small loading indicator variant
        suffixIcon: LoadingIndicatorVariants.small(),
      ),
      items: const [],
    );
  }
  
  Widget _buildErrorDropdown(BuildContext context, Object error) {
    return DropdownButtonFormField<String?>(
      onChanged: null,
      decoration: InputDecoration(
        labelText: labelText ?? AppStrings.category,
        prefixIcon: const Icon(Icons.category),
        errorText: 'ไม่สามารถโหลดหมวดหมู่ได้',
      ),
      items: const [],
    );
  }
}

// Category chips for filtering
class CategoryChips extends ConsumerWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;
  final bool showAllOption;
  
  const CategoryChips({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
    this.showAllOption = true,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) => _buildCategoryChips(context, categories),
      loading: () => _buildLoadingChips(context),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
  
  Widget _buildCategoryChips(BuildContext context, List<Category> categories) {
    final chips = <Widget>[];
    
    if (showAllOption) {
      chips.add(_buildCategoryChip(
        context,
        id: null,
        name: 'ทั้งหมด',
        isSelected: selectedCategoryId == null,
      ));
    }
    
    for (final category in categories) {
      chips.add(_buildCategoryChip(
        context,
        // Convert int id to String for selection
        id: category.id.toString(),
        name: category.name,
        isSelected: category.id.toString() == selectedCategoryId,
      ));
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
      child: Row(
        children: chips.map((chip) => Padding(
          padding: const EdgeInsets.only(right: ThemeConstants.spacingS),
          child: chip,
        )).toList(),
      ),
    );
  }
  
  Widget _buildCategoryChip(
    BuildContext context, {
    required String? id,
    required String name,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(name),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onChanged(id);
        } else if (isSelected) {
          onChanged(null);
        }
      },
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
  
  Widget _buildLoadingChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
      child: Row(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(right: ThemeConstants.spacingS),
          child: Chip(
            label: Container(
              width: 60,
              height: 16,
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
        )),
      ),
    );
  }
}
