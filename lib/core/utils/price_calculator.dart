import '../../features/products/domain/entities/product.dart';
import '../constants/unit_types.dart';
import 'unit_converter.dart';

class PriceCalculator {
  /// Calculate price per base unit for a product
  static double calculatePricePerUnit(Product product) {
    final baseUnitAmount = UnitConverter.toBaseUnit(
      product.unitAmount, 
      product.unit
    );
    return product.price / (product.packCount * baseUnitAmount);
  }
  
  /// Sort products by unit price (cheapest first)
  static List<Product> sortByUnitPrice(List<Product> products) {
    // Filter to only include products that can be compared
    final comparableGroups = <UnitType, List<Product>>{};
    
    for (final product in products) {
      final unitType = product.unit.type;
      if (!comparableGroups.containsKey(unitType)) {
        comparableGroups[unitType] = [];
      }
      comparableGroups[unitType]!.add(product);
    }
    
    final sortedProducts = <Product>[];
    
    // Sort each group by unit price
    for (final group in comparableGroups.values) {
      group.sort((a, b) => 
        calculatePricePerUnit(a).compareTo(calculatePricePerUnit(b)));
      sortedProducts.addAll(group);
    }
    
    return sortedProducts;
  }
  
  /// Find the cheapest product among comparable products
  static Product? findCheapestInGroup(List<Product> products) {
    if (products.isEmpty) return null;
    
    Product cheapest = products.first;
    double cheapestPrice = calculatePricePerUnit(cheapest);
    
    for (final product in products.skip(1)) {
      if (UnitConverter.canCompare(product.unit, cheapest.unit)) {
        final price = calculatePricePerUnit(product);
        if (price < cheapestPrice) {
          cheapest = product;
          cheapestPrice = price;
        }
      }
    }
    
    return cheapest;
  }
  
  /// Format price per unit for display
  static String formatPricePerUnit(Product product) {
    final ppu = calculatePricePerUnit(product);
    final baseUnit = _getBaseUnitName(product.unit.type);
    return '฿${ppu.toStringAsFixed(3)}/$baseUnit';
  }
  
  static String _getBaseUnitName(UnitType type) {
    switch (type) {
      case UnitType.weight:
        return 'g';
      case UnitType.volume:
        return 'ml';
      case UnitType.piece:
        return 'piece';
    }
  }
}