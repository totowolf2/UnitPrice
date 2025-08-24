import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/use_cases/manage_products.dart';
import '../../data/models/product_model.dart';
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
  final String? categoryId;
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
    this.categoryId,
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
    String? categoryId,
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
      categoryId: categoryId ?? this.categoryId,
      errors: errors ?? this.errors,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
    );
  }
  
  ProductModel toProduct() {
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
  
  void updateCategoryId(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }
  
  void loadProduct(Product product) {
    state = ProductFormState(
      name: product.name,
      price: product.price,
      packCount: product.packCount,
      unitAmount: product.unitAmount,
      unit: product.unit,
      imagePath: product.imagePath,
      categoryId: product.categoryId,
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
      final product = state.toProduct();
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
      final product = existingProduct as ProductModel;
      product.updateWith(
        name: state.name,
        price: state.price,
        packCount: state.packCount,
        unitAmount: state.unitAmount,
        unit: state.unit,
        imagePath: state.imagePath,
        categoryId: state.categoryId,
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