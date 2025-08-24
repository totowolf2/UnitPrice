import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/use_cases/manage_products.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../../../core/constants/unit_types.dart';
import 'product_provider.dart';

// Product form state
class ProductFormState {
  final String name;
  final double price;
  final int packCount;
  final double unitAmount;
  final Unit unit;
  final String? imagePath;
  final String? categoryName;
  final Map<String, String?> errors;
  final bool isLoading;
  final bool isValid;
  
  const ProductFormState({
    this.name = '',
    this.price = 0.0,
    this.packCount = 1,
    this.unitAmount = 0.0,
    this.unit = Unit.piece,
    this.imagePath,
    this.categoryName,
    this.errors = const {},
    this.isLoading = false,
    this.isValid = false,
  });
  
  ProductFormState copyWith({
    String? name,
    double? price,
    int? packCount,
    double? unitAmount,
    Unit? unit,
    String? imagePath,
    String? categoryName,
    Map<String, String?>? errors,
    bool? isLoading,
    bool? isValid,
  }) {
    return ProductFormState(
      name: name ?? this.name,
      price: price ?? this.price,
      packCount: packCount ?? this.packCount,
      unitAmount: unitAmount ?? this.unitAmount,
      unit: unit ?? this.unit,
      imagePath: imagePath ?? this.imagePath,
      categoryName: categoryName ?? this.categoryName,
      errors: errors ?? this.errors,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
    );
  }
  
  ProductModel toProduct({String? categoryId}) {
    return ProductModel.create(
      name: name,
      price: price,
      packCount: packCount,
      unitAmount: unitAmount,
      unit: unit,
      imagePath: imagePath,
      categoryId: categoryId,
    );
  }
}

// Product form provider
final productFormProvider = StateNotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>((ref) {
  final useCase = ref.watch(manageProductsUseCaseProvider);
  return ProductFormNotifier(useCase);
});

// Product form notifier
class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final ManageProductsUseCase _useCase;
  
  ProductFormNotifier(this._useCase) : super(const ProductFormState());
  
  void updateName(String name) {
    state = state.copyWith(name: name);
    _validate();
  }
  
  void updatePrice(double price) {
    state = state.copyWith(price: price);
    _validate();
  }
  
  void updatePackCount(int packCount) {
    state = state.copyWith(packCount: packCount);
    _validate();
  }
  
  void updateUnitAmount(double unitAmount) {
    state = state.copyWith(unitAmount: unitAmount);
    _validate();
  }
  
  void updateUnit(Unit unit) {
    state = state.copyWith(unit: unit);
    _validate();
  }
  
  void updateImagePath(String? imagePath) {
    state = state.copyWith(imagePath: imagePath);
  }
  
  void updateCategoryName(String? categoryName) {
    state = state.copyWith(categoryName: categoryName);
  }
  
  Future<void> loadProduct(Product product) async {
    String? categoryName;
    if (product.categoryId != null) {
      try {
        final categoryId = int.parse(product.categoryId!);
        final category = await _useCase.getCategoryById(categoryId);
        categoryName = category?.name;
      } catch (e) {
        categoryName = null;
      }
    }
    
    state = ProductFormState(
      name: product.name,
      price: product.price,
      packCount: product.packCount,
      unitAmount: product.unitAmount,
      unit: product.unit,
      imagePath: product.imagePath,
      categoryName: categoryName,
    );
    _validate();
  }
  
  void reset() {
    state = const ProductFormState();
  }
  
  Future<bool> saveProduct() async {
    if (!state.isValid) return false;
    
    state = state.copyWith(isLoading: true);
    
    try {
      // Find or create category
      String? categoryId = await _getCategoryId(state.categoryName);
      
      final product = state.toProduct(categoryId: categoryId);
      await _useCase.saveProduct(product);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errors: {'general': 'เกิดข้อผิดพลาดในการบันทึก: $error'},
      );
      return false;
    }
  }
  
  Future<bool> updateProduct(Product existingProduct) async {
    if (!state.isValid) return false;
    
    state = state.copyWith(isLoading: true);
    
    try {
      // Find or create category
      String? categoryId = await _getCategoryId(state.categoryName);
      
      final product = existingProduct as ProductModel;
      product.updateWith(
        name: state.name,
        price: state.price,
        packCount: state.packCount,
        unitAmount: state.unitAmount,
        unit: state.unit,
        imagePath: state.imagePath,
        categoryId: categoryId,
      );
      
      await _useCase.updateProduct(product);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errors: {'general': 'เกิดข้อผิดพลาดในการอัปเดต: $error'},
      );
      return false;
    }
  }

  Future<String?> _getCategoryId(String? categoryName) async {
    if (categoryName == null || categoryName.trim().isEmpty) {
      // Use default category "อื่นๆ" if no category specified
      final defaultCategory = await _useCase.getDefaultCategory();
      return defaultCategory.id.toString();
    }
    
    // Check if category already exists
    final categories = await _useCase.getAllCategories();
    try {
      final existingCategory = categories.firstWhere(
        (category) => category.name.toLowerCase() == categoryName.trim().toLowerCase(),
      );
      return existingCategory.id.toString();
    } catch (e) {
      // Create new category if it doesn't exist
      final newCategory = CategoryModel.create(name: categoryName.trim());
      await _useCase.saveCategory(newCategory);
      
      // After saving, the ID will be assigned by Isar
      // Find the newly created category to get its ID
      final savedCategories = await _useCase.getAllCategories();
      final savedCategory = savedCategories.firstWhere(
        (category) => category.name.toLowerCase() == categoryName.trim().toLowerCase(),
      );
      return savedCategory.id.toString();
    }
  }
  
  void _validate() {
    final errors = _useCase.validateProduct(
      name: state.name,
      price: state.price,
      packCount: state.packCount,
      unitAmount: state.unitAmount,
    );
    
    final isValid = errors.values.every((error) => error == null);
    
    state = state.copyWith(
      errors: errors,
      isValid: isValid,
    );
  }
}