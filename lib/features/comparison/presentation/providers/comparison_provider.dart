import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/comparison_session.dart';
import '../../domain/repositories/comparison_repository.dart';
import '../../data/models/comparison_session_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/use_cases/calculate_unit_price.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/models/comparison_result.dart';

// Use case provider
final calculateUnitPriceUseCaseProvider = Provider<CalculateUnitPriceUseCase>((ref) {
  return CalculateUnitPriceUseCase();
});

// Current comparison provider
final currentComparisonProvider = StateNotifierProvider<ComparisonNotifier, AsyncValue<ComparisonResult?>>((ref) {
  final useCase = ref.watch(calculateUnitPriceUseCaseProvider);
  return ComparisonNotifier(useCase);
});

// Comparison history provider
final comparisonHistoryProvider = StateNotifierProvider<ComparisonHistoryNotifier, AsyncValue<List<ComparisonSession>>>((ref) {
  final repository = ref.watch(comparisonRepositoryProvider);
  return ComparisonHistoryNotifier(repository);
});

// Selected products for comparison
final selectedProductsProvider = StateProvider<List<Product>>((ref) => []);

// Comparison state notifier
class ComparisonNotifier extends StateNotifier<AsyncValue<ComparisonResult?>> {
  final CalculateUnitPriceUseCase _useCase;
  
  ComparisonNotifier(this._useCase) : super(const AsyncValue.data(null));
  
  void compareProducts(List<Product> products) {
    if (products.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    
    try {
      // Sort products by unit price
      final sortedProducts = _useCase.sortByUnitPrice(products);
      
      // Find cheapest product
      final cheapestProduct = _useCase.findCheapestInGroup(products);
      
      // Calculate prices per unit for all products
      // Map product id (int) to computed price-per-unit
      final pricesPerUnit = <int, double>{};
      for (final product in products) {
        pricesPerUnit[product.id] = _useCase.call(product);
      }
      
      final result = ComparisonResult(
        products: sortedProducts,
        cheapestProduct: cheapestProduct,
        pricesPerUnit: pricesPerUnit,
        comparisonTime: DateTime.now(),
      );
      
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void clearComparison() {
    state = const AsyncValue.data(null);
  }
  
  void addProduct(Product product) {
    final currentResult = state.valueOrNull;
    if (currentResult == null) {
      compareProducts([product]);
    } else {
      final updatedProducts = [...currentResult.products, product];
      compareProducts(updatedProducts);
    }
  }
  
  void removeProduct(Product product) {
    final currentResult = state.valueOrNull;
    if (currentResult == null) return;
    
    final updatedProducts = currentResult.products
        .where((p) => p.id != product.id)
        .toList();
    
    if (updatedProducts.isEmpty) {
      clearComparison();
    } else {
      compareProducts(updatedProducts);
    }
  }
}

// Comparison history notifier
class ComparisonHistoryNotifier extends StateNotifier<AsyncValue<List<ComparisonSession>>> {
  final ComparisonRepository _repository;
  
  ComparisonHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadHistory();
  }
  
  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final sessions = await _repository.getRecentSessions();
      state = AsyncValue.data(sessions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> saveCurrentComparison(ComparisonResult result) async {
    try {
      // Create product snapshots
      final snapshots = result.products.map((product) => jsonEncode({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'unitAmount': product.unitAmount,
        'unit': product.unit.name,
        'packCount': product.packCount,
        'ppu': result.getPricePerUnit(product),
        'imagePath': product.imagePath,
        'categoryId': product.categoryId,
      })).toList();
      
      // Create session
      final session = ComparisonSessionModel.fromProductSnapshots(snapshots);
      
      // Save session
      await _repository.saveComparisonSession(session);
      
      // Reload history
      await loadHistory();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteSession(String sessionId) async {
    try {
      await _repository.deleteSession(sessionId);
      await loadHistory();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> clearAllSessions() async {
    try {
      final sessions = await _repository.getRecentSessions();
      for (final session in sessions) {
        // Repository expects String id; convert from int
        await _repository.deleteSession(session.id.toString());
      }
      await loadHistory();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
