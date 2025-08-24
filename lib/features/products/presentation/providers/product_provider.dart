import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/use_cases/manage_products.dart';
import '../../../../core/providers/repository_providers.dart';

// Use case providers
final manageProductsUseCaseProvider = Provider<ManageProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ManageProductsUseCase(repository);
});

// Products list provider
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final useCase = ref.watch(manageProductsUseCaseProvider);
  return ProductsNotifier(useCase);
});

// Search and filter state
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Price filter state
final minPriceProvider = StateProvider<double?>((ref) => null);
final maxPriceProvider = StateProvider<double?>((ref) => null);

// Filtered products based on search/category/price
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final minPrice = ref.watch(minPriceProvider);
  final maxPrice = ref.watch(maxPriceProvider);
  
  return products.when(
    data: (productList) {
      var filtered = productList;
      
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((p) => 
          p.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }
      
      if (selectedCategory != null) {
        filtered = filtered.where((p) => p.categoryId == selectedCategory).toList();
      }
      
      if (minPrice != null) {
        filtered = filtered.where((p) => p.price >= minPrice).toList();
      }
      
      if (maxPrice != null) {
        filtered = filtered.where((p) => p.price <= maxPrice).toList();
      }
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Products state notifier
class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ManageProductsUseCase _useCase;
  
  ProductsNotifier(this._useCase) : super(const AsyncValue.loading()) {
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _useCase.getAllProducts();
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> addProduct(Product product) async {
    try {
      await _useCase.saveProduct(product);
      await loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateProduct(Product product) async {
    try {
      await _useCase.updateProduct(product);
      await loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteProduct(int id) async {
    try {
      await _useCase.deleteProduct(id);
      await loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> searchProducts(String query) async {
    try {
      final products = await _useCase.searchProducts(query);
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
