import '../entities/product.dart';
import '../entities/category.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<Product?> getProductById(int id);
  Future<void> saveProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> getProductsByCategory(String categoryId);
  
  // Category operations
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);
  Future<void> saveCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<Category> getDefaultCategory();
}