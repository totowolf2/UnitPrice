import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/use_cases/calculate_unit_price.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_selector.dart';
import 'product_form_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});
  
  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  
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
        title: const Text(AppStrings.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: AppStrings.search,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'ฟิลเตอร์',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          _buildCategoryFilter(),
          
          // Price filter indicator
          _buildPriceFilterIndicator(),
          
          // Search bar (if searching)
          _buildSearchBar(),
          
          // Products list
          Expanded(
            child: filteredProducts.when(
              data: (products) => _buildProductsList(context, products),
              loading: () => _buildLoadingList(),
              error: (error, stackTrace) => _buildErrorState(context, error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        tooltip: AppStrings.addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildCategoryFilter() {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    return CategoryChips(
      selectedCategoryId: selectedCategory,
      onChanged: (categoryId) {
        ref.read(selectedCategoryProvider.notifier).state = categoryId;
      },
    );
  }
  
  Widget _buildPriceFilterIndicator() {
    final minPrice = ref.watch(minPriceProvider);
    final maxPrice = ref.watch(maxPriceProvider);
    
    if (minPrice == null && maxPrice == null) {
      return const SizedBox.shrink();
    }
    
    String priceText = '';
    if (minPrice != null && maxPrice != null) {
      priceText = '฿${minPrice.toStringAsFixed(2)} - ฿${maxPrice.toStringAsFixed(2)}';
    } else if (minPrice != null) {
      priceText = 'มากกว่า ฿${minPrice.toStringAsFixed(2)}';
    } else if (maxPrice != null) {
      priceText = 'น้อยกว่า ฿${maxPrice.toStringAsFixed(2)}';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: ThemeConstants.spacingXS),
          Text(
            'ฟิลเตอร์ราคา: $priceText',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              ref.read(minPriceProvider.notifier).state = null;
              ref.read(maxPriceProvider.notifier).state = null;
            },
            child: const Text('ล้าง'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    final searchQuery = ref.watch(searchQueryProvider);
    
    if (searchQuery.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: AppStrings.search,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSearch,
          ),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
    );
  }
  
  Widget _buildProductsList(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      final searchQuery = ref.read(searchQueryProvider);
      if (searchQuery.isNotEmpty) {
        return EmptyStateVariants.noSearchResults(searchQuery: searchQuery);
      }
      return EmptyStateVariants.noProducts(
        onAction: _addProduct,
      );
    }
    
    // Sort products by unit price and find cheapest
    final useCase = CalculateUnitPriceUseCase();
    final sortedProducts = useCase.sortByUnitPrice(products);
    final cheapestProduct = useCase.findCheapestInGroup(sortedProducts);
    
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) {
        final product = sortedProducts[index];
        final isLowestPrice = cheapestProduct?.id == product.id;
        
        return ProductCard(
          product: product,
          isLowestPrice: isLowestPrice,
          onTap: () => _viewProduct(product),
          onEdit: () => _editProduct(product),
          onDelete: () => _deleteProduct(context, product),
        );
      },
    );
  }
  
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }
  
  Widget _buildErrorState(BuildContext context, Object error) {
    return EmptyStateVariants.error(
      errorMessage: error.toString(),
      onAction: () {
        ref.read(productsProvider.notifier).loadProducts();
      },
    );
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.search),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ค้นหาชื่อสินค้า...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = _searchController.text;
              Navigator.of(context).pop();
            },
            child: const Text(AppStrings.search),
          ),
        ],
      ),
    );
  }
  
  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }
  
  void _addProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductFormScreen(),
      ),
    );
  }
  
  void _editProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );
  }
  
  void _viewProduct(Product product) {
    // TODO: Navigate to product detail screen if needed
    // For now, just edit the product
    _editProduct(product);
  }
  
  void _deleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบสินค้า'),
        content: Text('คุณแน่ใจหรือไม่ที่จะลบ "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(productsProvider.notifier).deleteProduct(product.id);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog() {
    final minPrice = ref.read(minPriceProvider);
    final maxPrice = ref.read(maxPriceProvider);
    
    final minController = TextEditingController(
      text: minPrice?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: maxPrice?.toString() ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ฟิลเตอร์ราคา'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'ราคาต่ำสุด (฿)',
                hintText: 'เช่น 10.50',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            TextField(
              controller: maxController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'ราคาสูงสุด (฿)',
                hintText: 'เช่น 100.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear filters
              ref.read(minPriceProvider.notifier).state = null;
              ref.read(maxPriceProvider.notifier).state = null;
              Navigator.of(context).pop();
            },
            child: const Text('ล้างฟิลเตอร์'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final minText = minController.text.trim();
              final maxText = maxController.text.trim();
              
              // Parse and validate prices
              double? minPriceValue;
              double? maxPriceValue;
              
              if (minText.isNotEmpty) {
                minPriceValue = double.tryParse(minText);
                if (minPriceValue == null || minPriceValue < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ราคาต่ำสุดไม่ถูกต้อง'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }
              
              if (maxText.isNotEmpty) {
                maxPriceValue = double.tryParse(maxText);
                if (maxPriceValue == null || maxPriceValue < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ราคาสูงสุดไม่ถูกต้อง'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }
              
              // Validate range
              if (minPriceValue != null && maxPriceValue != null && 
                  minPriceValue > maxPriceValue) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ราคาต่ำสุดต้องน้อยกว่าหรือเท่ากับราคาสูงสุด'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Apply filters
              ref.read(minPriceProvider.notifier).state = minPriceValue;
              ref.read(maxPriceProvider.notifier).state = maxPriceValue;
              
              Navigator.of(context).pop();
            },
            child: const Text('ปรับใช้'),
          ),
        ],
      ),
    ).then((_) {
      minController.dispose();
      maxController.dispose();
    });
  }
}
