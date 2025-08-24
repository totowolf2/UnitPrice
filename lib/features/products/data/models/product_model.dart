import 'package:isar/isar.dart';

import '../../../../core/constants/unit_types.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@collection
class ProductModel extends Product {
  @override
  Id id = Isar.autoIncrement;
  
  // Default constructor for Isar
  ProductModel();
  
  @override
  @Index()
  late String name;
  
  @override
  late double price; // THB with 3 decimal precision
  
  @override
  late int packCount;
  
  @override
  late double unitAmount;
  
  @Enumerated(EnumType.name)
  late UnitType unitType; // weight, volume, piece
  
  @override
  @Enumerated(EnumType.name)
  late Unit unit; // g, kg, ml, L, piece
  
  @override
  String? imagePath;
  
  @override
  String? categoryId;
  
  @override
  late DateTime createdAt;
  
  @override
  late DateTime updatedAt;
  
  // Computed property for unit price per base unit
  @ignore
  @override
  double get unitPricePerBaseUnit {
    final baseUnitAmount = UnitConverter.toBaseUnit(unitAmount, unit);
    return price / (packCount * baseUnitAmount);
  }
  
  // Convert from domain entity
  factory ProductModel.fromEntity(Product product) {
    return ProductModel()
      ..name = product.name
      ..price = product.price
      ..packCount = product.packCount
      ..unitAmount = product.unitAmount
      ..unitType = product.unit.type
      ..unit = product.unit
      ..imagePath = product.imagePath
      ..categoryId = product.categoryId
      ..createdAt = product.createdAt
      ..updatedAt = product.updatedAt;
  }
  
  // Create new instance
  ProductModel.create({
    required this.name,
    required this.price,
    required this.packCount,
    required this.unitAmount,
    required this.unit,
    this.imagePath,
    this.categoryId,
  }) {
    unitType = unit.type;
    final now = DateTime.now();
    createdAt = now;
    updatedAt = now;
  }
  
  // Update instance
  void updateWith({
    String? name,
    double? price,
    int? packCount,
    double? unitAmount,
    Unit? unit,
    String? imagePath,
    String? categoryId,
  }) {
    if (name != null) this.name = name;
    if (price != null) this.price = price;
    if (packCount != null) this.packCount = packCount;
    if (unitAmount != null) this.unitAmount = unitAmount;
    if (unit != null) {
      this.unit = unit;
      unitType = unit.type;
    }
    if (imagePath != null) this.imagePath = imagePath;
    if (categoryId != null) this.categoryId = categoryId;
    updatedAt = DateTime.now();
  }
}