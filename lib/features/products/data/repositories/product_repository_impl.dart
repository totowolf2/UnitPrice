import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource _localDataSource;
  
  ProductRepositoryImpl(this._localDataSource);
  
  @override
  Future<List<Product>> getAllProducts() async {
    final models = await _localDataSource.getAllProducts();
    return models.cast<Product>();
  }
  
  @override
  Future<Product?> getProductById(int id) async {
    final model = await _localDataSource.getProductById(id);
    return model;
  }
  
  @override
  Future<void> saveProduct(Product product) async {
    final model = product is ProductModel 
        ? product 
        : ProductModel.fromEntity(product);
    await _localDataSource.saveProduct(model);
  }
  
  @override
  Future<void> updateProduct(Product product) async {
    final model = product is ProductModel 
        ? product 
        : ProductModel.fromEntity(product);
    await _localDataSource.updateProduct(model);
  }
  
  @override
  Future<void> deleteProduct(int id) async {
    await _localDataSource.deleteProduct(id);
  }
  
  @override
  Future<List<Product>> searchProducts(String query) async {
    final models = await _localDataSource.searchProducts(query);
    return models.cast<Product>();
  }
  
  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final models = await _localDataSource.getProductsByCategory(categoryId);
    return models.cast<Product>();
  }
  
  // Category operations
  @override
  Future<List<Category>> getAllCategories() async {
    final models = await _localDataSource.getAllCategories();
    return models.cast<Category>();
  }
  
  @override
  Future<Category?> getCategoryById(int id) async {
    final model = await _localDataSource.getCategoryById(id);
    return model;
  }
  
  @override
  Future<void> saveCategory(Category category) async {
    final model = category is CategoryModel 
        ? category 
        : CategoryModel.fromEntity(category);
    await _localDataSource.saveCategory(model);
  }
  
  @override
  Future<void> updateCategory(Category category) async {
    final model = category is CategoryModel 
        ? category 
        : CategoryModel.fromEntity(category);
    await _localDataSource.updateCategory(model);
  }
  
  @override
  Future<void> deleteCategory(int id) async {
    await _localDataSource.deleteCategory(id);
  }
  
  @override
  Future<Category> getDefaultCategory() async {
    final model = await _localDataSource.getDefaultCategory();
    if (model == null) {
      throw Exception('Default category not found');
    }
    return model;
  }
}