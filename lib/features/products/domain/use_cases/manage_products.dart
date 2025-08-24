import '../entities/product.dart';
import '../entities/category.dart';
import '../repositories/product_repository.dart';

class ManageProductsUseCase {
  final ProductRepository _repository;
  
  ManageProductsUseCase(this._repository);
  
  // Product operations
  Future<List<Product>> getAllProducts() async {
    return await _repository.getAllProducts();
  }
  
  Future<Product?> getProductById(int id) async {
    return await _repository.getProductById(id);
  }
  
  Future<void> saveProduct(Product product) async {
    await _repository.saveProduct(product);
  }
  
  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
  }
  
  Future<void> deleteProduct(int id) async {
    await _repository.deleteProduct(id);
  }
  
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return await getAllProducts();
    return await _repository.searchProducts(query);
  }
  
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return await _repository.getProductsByCategory(categoryId);
  }
  
  // Category operations
  Future<List<Category>> getAllCategories() async {
    return await _repository.getAllCategories();
  }
  
  Future<Category?> getCategoryById(int id) async {
    return await _repository.getCategoryById(id);
  }
  
  Future<void> saveCategory(Category category) async {
    await _repository.saveCategory(category);
  }
  
  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
  }
  
  Future<void> deleteCategory(int id) async {
    await _repository.deleteCategory(id);
  }
  
  Future<Category> getDefaultCategory() async {
    return await _repository.getDefaultCategory();
  }
  
  // Validation helpers
  bool isValidProductName(String name) {
    return name.trim().isNotEmpty && name.length >= 2;
  }
  
  bool isValidPrice(double price) {
    return price > 0 && price <= 999999.99;
  }
  
  bool isValidPackCount(int packCount) {
    return packCount > 0 && packCount <= 9999;
  }
  
  bool isValidUnitAmount(double unitAmount) {
    return unitAmount > 0 && unitAmount <= 999999.99;
  }
  
  Map<String, String?> validateProduct({
    required String name,
    required double price,
    required int packCount,
    required double unitAmount,
  }) {
    final errors = <String, String?>{};
    
    if (!isValidProductName(name)) {
      errors['name'] = 'ชื่อสินค้าต้องมีอย่างน้อย 2 ตัวอักษร';
    }
    
    if (!isValidPrice(price)) {
      errors['price'] = 'ราคาต้องมากกว่า 0 และไม่เกิน 999,999.99';
    }
    
    if (!isValidPackCount(packCount)) {
      errors['packCount'] = 'จำนวนแพ็คต้องมากกว่า 0 และไม่เกิน 9,999';
    }
    
    if (!isValidUnitAmount(unitAmount)) {
      errors['unitAmount'] = 'ปริมาณต่อหน่วยต้องมากกว่า 0 และไม่เกิน 999,999.99';
    }
    
    return errors;
  }
}
