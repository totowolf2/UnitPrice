import 'package:isar/isar.dart';

import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductLocalDataSource {
  final Isar _isar;
  
  ProductLocalDataSource(this._isar);
  
  // Product operations
  Future<List<ProductModel>> getAllProducts() async {
    return await _isar.productModels.where().findAll();
  }
  
  Future<ProductModel?> getProductById(int id) async {
    return await _isar.productModels.get(id);
  }
  
  Future<void> saveProduct(ProductModel product) async {
    await _isar.writeTxn(() async {
      await _isar.productModels.put(product);
    });
  }
  
  Future<void> updateProduct(ProductModel product) async {
    await _isar.writeTxn(() async {
      product.updatedAt = DateTime.now();
      await _isar.productModels.put(product);
    });
  }
  
  Future<void> deleteProduct(int id) async {
    await _isar.writeTxn(() async {
      await _isar.productModels.delete(id);
    });
  }
  
  Future<List<ProductModel>> searchProducts(String query) async {
    return await _isar.productModels
        .filter()
        .nameContains(query, caseSensitive: false)
        .findAll();
  }
  
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    return await _isar.productModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .findAll();
  }
  
  // Category operations
  Future<List<CategoryModel>> getAllCategories() async {
    return await _isar.categoryModels.where().findAll();
  }
  
  Future<CategoryModel?> getCategoryById(int id) async {
    return await _isar.categoryModels.get(id);
  }
  
  Future<void> saveCategory(CategoryModel category) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(category);
    });
  }
  
  Future<void> updateCategory(CategoryModel category) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(category);
    });
  }
  
  Future<void> deleteCategory(int id) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.delete(id);
    });
  }
  
  Future<CategoryModel?> getDefaultCategory() async {
    return await _isar.categoryModels
        .filter()
        .isDefaultEqualTo(true)
        .findFirst();
  }
}
