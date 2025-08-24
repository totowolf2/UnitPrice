import '../entities/product.dart';
import '../../../../core/utils/price_calculator.dart';

class CalculateUnitPriceUseCase {
  double call(Product product) {
    return PriceCalculator.calculatePricePerUnit(product);
  }
  
  String formatPricePerUnit(Product product) {
    return PriceCalculator.formatPricePerUnit(product);
  }
  
  List<Product> sortByUnitPrice(List<Product> products) {
    return PriceCalculator.sortByUnitPrice(products);
  }
  
  Product? findCheapestInGroup(List<Product> products) {
    return PriceCalculator.findCheapestInGroup(products);
  }
}