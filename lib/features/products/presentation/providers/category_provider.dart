import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/use_cases/manage_products.dart';
import 'product_provider.dart';

// Categories list provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  final useCase = ref.watch(manageProductsUseCaseProvider);
  return CategoriesNotifier(useCase);
});

// Default category provider
final defaultCategoryProvider = FutureProvider<Category>((ref) async {
  final useCase = ref.watch(manageProductsUseCaseProvider);
  return await useCase.getDefaultCategory();
});

// Categories state notifier
class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final ManageProductsUseCase _useCase;
  
  CategoriesNotifier(this._useCase) : super(const AsyncValue.loading()) {
    loadCategories();
  }
  
  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _useCase.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> addCategory(Category category) async {
    try {
      await _useCase.saveCategory(category);
      await loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateCategory(Category category) async {
    try {
      await _useCase.updateCategory(category);
      await loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteCategory(int id) async {
    try {
      await _useCase.deleteCategory(id);
      await loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<Category?> getCategoryById(int id) async {
    return await _useCase.getCategoryById(id);
  }
}
