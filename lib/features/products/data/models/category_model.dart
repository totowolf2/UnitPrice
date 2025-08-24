import 'package:isar/isar.dart';

import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@collection
class CategoryModel extends Category {
  @override
  Id id = Isar.autoIncrement;
  
  // Default constructor for Isar
  CategoryModel();
  
  @override
  @Index(unique: true)
  late String name;
  
  @override
  String? color;
  
  @override
  late bool isDefault;
  
  @override
  late DateTime createdAt;
  
  // Convert from domain entity
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel()
      ..name = category.name
      ..color = category.color
      ..isDefault = category.isDefault
      ..createdAt = category.createdAt;
  }
  
  // Create new instance
  CategoryModel.create({
    required this.name,
    this.color,
    this.isDefault = false,
  }) {
    createdAt = DateTime.now();
  }
  
  // Create default category
  CategoryModel.createDefault() {
    name = 'อื่นๆ';
    color = null;
    isDefault = true;
    createdAt = DateTime.now();
  }
  
  // Update instance
  void updateWith({
    String? name,
    String? color,
    bool? isDefault,
  }) {
    if (name != null) this.name = name;
    if (color != null) this.color = color;
    if (isDefault != null) this.isDefault = isDefault;
  }
}