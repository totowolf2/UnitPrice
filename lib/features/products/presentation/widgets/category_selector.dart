import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/category_provider.dart';

class CategorySelector extends ConsumerStatefulWidget {
  // Selected category name is now stored as String? 
  final String? selectedCategoryName;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final String? labelText;
  
  const CategorySelector({
    super.key,
    required this.selectedCategoryName,
    required this.onChanged,
    this.enabled = true,
    this.labelText,
  });
  
  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.selectedCategoryName ?? '';
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) => _buildCategoryInput(context, categories),
      loading: () => _buildLoadingInput(context),
      error: (error, stackTrace) => _buildErrorInput(context, error),
    );
  }
  
  Widget _buildCategoryInput(BuildContext context, List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          onChanged: (value) {
            widget.onChanged(value.trim().isEmpty ? null : value.trim());
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: widget.labelText ?? AppStrings.category,
            prefixIcon: const Icon(Icons.category),
            hintText: 'พิมพ์หมวดหมู่หรือเลือกจากรายการ',
          ),
        ),
        if (_showSuggestions && categories.isNotEmpty) 
          _buildSuggestionsList(categories),
      ],
    );
  }

  Widget _buildSuggestionsList(List<Category> categories) {
    final filteredCategories = categories.where((category) {
      return category.name.toLowerCase().contains(_controller.text.toLowerCase());
    }).toList();

    if (filteredCategories.isEmpty && _controller.text.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_controller.text.isEmpty)
            ListTile(
              dense: true,
              leading: const Icon(Icons.clear),
              title: const Text('ไม่ระบุหมวดหมู่'),
              onTap: () {
                _controller.clear();
                widget.onChanged(null);
                _focusNode.unfocus();
              },
            ),
          ...filteredCategories.map((category) => ListTile(
            dense: true,
            leading: const Icon(Icons.category),
            title: Text(category.name),
            onTap: () {
              _controller.text = category.name;
              widget.onChanged(category.name);
              _focusNode.unfocus();
            },
          )),
        ],
      ),
    );
  }
  
  Widget _buildLoadingInput(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: false,
      decoration: InputDecoration(
        labelText: widget.labelText ?? AppStrings.category,
        prefixIcon: const Icon(Icons.category),
        suffixIcon: LoadingIndicatorVariants.small(),
      ),
    );
  }
  
  Widget _buildErrorInput(BuildContext context, Object error) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      onChanged: (value) {
        widget.onChanged(value.trim().isEmpty ? null : value.trim());
      },
      decoration: InputDecoration(
        labelText: widget.labelText ?? AppStrings.category,
        prefixIcon: const Icon(Icons.category),
        hintText: 'พิมพ์หมวดหมู่',
        helperText: 'ไม่สามารถโหลดรายการหมวดหมู่ได้',
        helperStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
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
