import '../../features/products/domain/entities/product.dart';

class ComparisonResult {
  final List<Product> products;
  final Product? cheapestProduct;
  // Map product id (int) to its price-per-unit
  final Map<int, double> pricesPerUnit;
  final DateTime comparisonTime;
  
  ComparisonResult({
    required this.products,
    required this.cheapestProduct,
    required this.pricesPerUnit,
    required this.comparisonTime,
  });
  
  bool isCheapest(Product product) {
    return cheapestProduct?.id == product.id;
  }
  
  double getPricePerUnit(Product product) {
    return pricesPerUnit[product.id] ?? 0.0;
  }
  
  bool hasComparableProducts() {
    return products.length > 1 && cheapestProduct != null;
  }
  
  List<Product> getSortedProducts() {
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) {
      final priceA = getPricePerUnit(a);
      final priceB = getPricePerUnit(b);
      return priceA.compareTo(priceB);
    });
    return sorted;
  }
}
