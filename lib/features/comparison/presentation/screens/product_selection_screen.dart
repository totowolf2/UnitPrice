import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/constants/unit_types.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_button.dart';

class ProductSelectionScreen extends ConsumerStatefulWidget {
  final List<Product> alreadySelected;
  
  const ProductSelectionScreen({
    super.key,
    this.alreadySelected = const [],
  });
  
  @override
  ConsumerState<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends ConsumerState<ProductSelectionScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedProductIds = <String>{};
  
  @override
  void initState() {
    super.initState();
    // Initialize with already selected products
    _selectedProductIds.addAll(
      widget.alreadySelected.map((p) => p.id.toString()),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredProducts = ref.watch(filteredProductsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกสินค้าเปรียบเทียบ'),
        actions: [
          if (_selectedProductIds.isNotEmpty)
            TextButton(
              onPressed: _confirmSelection,
              child: Text(
                'เลือก (${_selectedProductIds.length})',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: AppStrings.search,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          _buildCategoryFilter(),
          
          // Search bar (if searching)
          if (ref.watch(searchQueryProvider).isNotEmpty) 
            _buildSearchBar(),
          
          // Selected products count
          if (_selectedProductIds.isNotEmpty)
            _buildSelectedCounter(),
          
          // Products list
          Expanded(
            child: filteredProducts.when(
              data: (products) => _buildProductsList(products),
              loading: () => LoadingIndicatorVariants.fullScreen(
                message: 'กำลังโหลดสินค้า...',
              ),
              error: (error, stackTrace) => EmptyStateVariants.error(
                errorMessage: error.toString(),
                onAction: () => ref.refresh(filteredProductsProvider),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedProductIds.isNotEmpty 
        ? _buildBottomActionBar() 
        : null,
    );
  }
  
  Widget _buildCategoryFilter() {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('ทั้งหมด'),
              selected: selectedCategoryId == null,
              onSelected: (_) {
                ref.read(selectedCategoryProvider.notifier).state = null;
              },
            ),
            const SizedBox(width: ThemeConstants.spacingS),
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoriesProvider);
                return categoriesAsync.when(
                  data: (categories) => Row(
                    children: categories.map((category) => Padding(
                      padding: const EdgeInsets.only(right: ThemeConstants.spacingS),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: selectedCategoryId == category.id.toString(),
                        onSelected: (_) {
                          ref.read(selectedCategoryProvider.notifier).state = 
                              category.id.toString();
                        },
                      ),
                    )).toList(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    final searchQuery = ref.watch(searchQueryProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาสินค้า...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              )
            : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
    );
  }
  
  Widget _buildSelectedCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: ThemeConstants.spacingS),
          Text(
            'เลือกแล้ว ${_selectedProductIds.length} รายการ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductsList(List<Product> products) {
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2,
        title: 'ไม่พบสินค้า',
        message: 'ลองเพิ่มสินค้าใหม่หรือปรับเปลี่ยนเงื่อนไขการค้นหา',
        actionText: 'เพิ่มสินค้า',
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: ThemeConstants.spacingS),
      itemBuilder: (context, index) {
        final product = products[index];
        final productId = product.id.toString();
        final isSelected = _selectedProductIds.contains(productId);
        final isAlreadyInComparison = widget.alreadySelected
            .any((p) => p.id.toString() == productId);
        
        return _SelectableProductCard(
          product: product,
          isSelected: isSelected,
          isAlreadyInComparison: isAlreadyInComparison,
          onSelectionChanged: (selected) {
            setState(() {
              if (selected) {
                _selectedProductIds.add(productId);
              } else {
                _selectedProductIds.remove(productId);
              }
            });
          },
        );
      },
    );
  }
  
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedProductIds.clear();
                });
              },
              child: const Text('ล้างทั้งหมด'),
            ),
            const Spacer(),
            AppButtonVariants.primary(
              text: 'เลือก (${_selectedProductIds.length})',
              icon: Icons.check,
              onPressed: _confirmSelection,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ค้นหาสินค้า'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'พิมพ์ชื่อสินค้า...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).state = '';
              Navigator.of(context).pop();
            },
            child: const Text('ล้าง'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ค้นหา'),
          ),
        ],
      ),
    );
  }
  
  void _confirmSelection() {
    final allProducts = ref.read(filteredProductsProvider).valueOrNull ?? [];
    final selectedProducts = allProducts
        .where((p) => _selectedProductIds.contains(p.id.toString()))
        .toList();
    
    Navigator.of(context).pop(selectedProducts);
  }
}

class _SelectableProductCard extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final bool isAlreadyInComparison;
  final ValueChanged<bool> onSelectionChanged;
  
  const _SelectableProductCard({
    required this.product,
    required this.isSelected,
    required this.isAlreadyInComparison,
    required this.onSelectionChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected 
        ? theme.colorScheme.primaryContainer.withAlpha(100)
        : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        onTap: isAlreadyInComparison 
          ? null 
          : () => onSelectionChanged(!isSelected),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          child: Row(
            children: [
              // Selection checkbox
              if (isAlreadyInComparison)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 24,
                )
              else
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onSelectionChanged(value ?? false),
                ),
              
              const SizedBox(width: ThemeConstants.spacingM),
              
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: ThemeConstants.spacingXS),
                    Text(
                      '฿${product.price.toStringAsFixed(AppConstants.pricePrecision)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingXS),
                    Text(
                      '${product.unitAmount} ${product.unit.displayName} • ${product.packCount} แพ็ค',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Unit price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '฿${product.unitPricePerBaseUnit.toStringAsFixed(AppConstants.ppuPrecision)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'ต่อ${product.unit.baseUnit.displayName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}