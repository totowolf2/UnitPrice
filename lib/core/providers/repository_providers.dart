import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/comparison/domain/repositories/comparison_repository.dart';
import '../../features/comparison/data/repositories/comparison_repository_impl.dart';
import '../../features/comparison/data/datasources/comparison_local_datasource.dart';
import 'database_provider.dart';

// Product repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final isar = ref.watch(isarProvider);
  final dataSource = ProductLocalDataSource(isar);
  return ProductRepositoryImpl(dataSource);
});

// Comparison repository provider  
final comparisonRepositoryProvider = Provider<ComparisonRepository>((ref) {
  final isar = ref.watch(isarProvider);
  final dataSource = ComparisonLocalDataSource(isar);
  return ComparisonRepositoryImpl(dataSource);
});