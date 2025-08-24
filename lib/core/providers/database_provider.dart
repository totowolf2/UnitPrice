import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/products/data/models/product_model.dart';
import '../../features/products/data/models/category_model.dart';
import '../../features/comparison/data/models/comparison_session_model.dart';
import '../constants/app_constants.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar instance must be overridden in main()');
});

class DatabaseProvider {
  static Future<Isar> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    
    return await Isar.open(
      [
        ProductModelSchema,
        CategoryModelSchema,
        ComparisonSessionModelSchema,
      ],
      directory: dir.path,
      name: AppConstants.databaseName,
      inspector: true, // Enable for debugging
    );
  }
  
  static Future<void> seedDefaultData(Isar isar) async {
    // Check if default category already exists
    final defaultCategory = await isar.categoryModels
        .filter()
        .isDefaultEqualTo(true)
        .findFirst();
    
    if (defaultCategory == null) {
      await isar.writeTxn(() async {
        final category = CategoryModel.createDefault();
        await isar.categoryModels.put(category);
      });
    }
  }
}