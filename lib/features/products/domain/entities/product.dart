import '../../../../core/constants/unit_types.dart';
import '../../../../core/utils/unit_converter.dart';

abstract class Product {
  int get id;
  String get name;
  double get price;
  int get packCount;
  double get unitAmount;
  Unit get unit;
  String? get imagePath;
  String? get categoryId;
  DateTime get createdAt;
  DateTime get updatedAt;
  
  // Computed property for unit price per base unit
  double get unitPricePerBaseUnit {
    final baseUnitAmount = UnitConverter.toBaseUnit(unitAmount, unit);
    return price / (packCount * baseUnitAmount);
  }
}