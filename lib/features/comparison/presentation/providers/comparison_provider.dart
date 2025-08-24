import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/comparison_session.dart';
import '../../domain/repositories/comparison_repository.dart';
import '../../data/models/comparison_session_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/use_cases/calculate_unit_price.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/constants/unit_types.dart';
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

// Quick compare item model
class QuickCompareItem {
  final String id;
  final double price;
  final double quantity;
  final Unit unit;
  final double unitPrice;
  
  QuickCompareItem({
    required this.id,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });
  
  QuickCompareItem copyWith({
    String? id,
    double? price,
    double? quantity,
    Unit? unit,
    double? unitPrice,
  }) {
    return QuickCompareItem(
      id: id ?? this.id,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

// Quick compare state
class QuickCompareState {
  final List<QuickCompareItem> items;
  final Unit? baseUnit;
  final QuickCompareItem? cheapest;
  final bool isLoading;
  final String? error;
  
  const QuickCompareState({
    this.items = const [],
    this.baseUnit,
    this.cheapest,
    this.isLoading = false,
    this.error,
  });
  
  QuickCompareState copyWith({
    List<QuickCompareItem>? items,
    Unit? baseUnit,
    QuickCompareItem? cheapest,
    bool? isLoading,
    String? error,
  }) {
    return QuickCompareState(
      items: items ?? this.items,
      baseUnit: baseUnit ?? this.baseUnit,
      cheapest: cheapest ?? this.cheapest,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Quick compare provider
final quickCompareProvider = StateNotifierProvider<QuickCompareNotifier, QuickCompareState>((ref) {
  return QuickCompareNotifier();
});

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

// Quick compare notifier
class QuickCompareNotifier extends StateNotifier<QuickCompareState> {
  QuickCompareNotifier() : super(const QuickCompareState());
  
  void addItem() {
    final newItem = QuickCompareItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      price: 0,
      quantity: 0,
      unit: Unit.values.first,
      unitPrice: 0,
    );
    
    final updatedItems = [...state.items, newItem];
    state = state.copyWith(items: updatedItems);
    
    AppLogger.logUserAction('add_quick_compare_item', context: {
      'total_items': updatedItems.length,
    });
  }
  
  void removeItem(String id) {
    final updatedItems = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: updatedItems);
    _recalculateCheapest();
    
    AppLogger.logUserAction('remove_quick_compare_item', context: {
      'remaining_items': updatedItems.length,
    });
  }
  
  void updateItem(String id, double price, double quantity, Unit unit) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final unitPrice = _calculateUnitPrice(price, quantity, unit, state.baseUnit);
        return item.copyWith(
          price: price,
          quantity: quantity,
          unit: unit,
          unitPrice: unitPrice,
        );
      }
      return item;
    }).toList();
    
    state = state.copyWith(items: updatedItems);
    _recalculateCheapest();
  }
  
  void setBaseUnit(Unit baseUnit) {
    // Recalculate all unit prices with new base unit
    final updatedItems = state.items.map((item) {
      final unitPrice = _calculateUnitPrice(item.price, item.quantity, item.unit, baseUnit);
      return item.copyWith(unitPrice: unitPrice);
    }).toList();
    
    state = state.copyWith(
      baseUnit: baseUnit,
      items: updatedItems,
    );
    _recalculateCheapest();
  }
  
  void clearAll() {
    final previousItemCount = state.items.length;
    state = const QuickCompareState();
    
    AppLogger.logUserAction('clear_all_quick_compare_items', context: {
      'cleared_items': previousItemCount,
    });
  }
  
  void _recalculateCheapest() {
    if (state.items.isEmpty) {
      state = state.copyWith(cheapest: null);
      return;
    }
    
    // Find items with valid data (price > 0, quantity > 0)
    final validItems = state.items.where((item) => 
        item.price > 0 && item.quantity > 0).toList();
    
    if (validItems.isEmpty) {
      state = state.copyWith(cheapest: null);
      return;
    }
    
    // Group by unit type for comparison
    final unitTypes = <UnitType, List<QuickCompareItem>>{};
    
    for (final item in validItems) {
      final unitType = item.unit.type;
      if (!unitTypes.containsKey(unitType)) {
        unitTypes[unitType] = [];
      }
      unitTypes[unitType]!.add(item);
    }
    
    // Find cheapest in each unit type group
    QuickCompareItem? overallCheapest;
    double cheapestPrice = double.infinity;
    
    for (final group in unitTypes.values) {
      if (group.isNotEmpty) {
        final groupCheapest = group.reduce((a, b) => 
            a.unitPrice < b.unitPrice ? a : b);
        
        if (groupCheapest.unitPrice < cheapestPrice) {
          overallCheapest = groupCheapest;
          cheapestPrice = groupCheapest.unitPrice;
        }
      }
    }
    
    state = state.copyWith(cheapest: overallCheapest);
  }
  
  double _calculateUnitPrice(double price, double quantity, Unit unit, Unit? baseUnit) {
    if (price <= 0 || quantity <= 0) return 0;
    
    // Convert to base unit amount
    final baseUnitAmount = UnitConverter.toBaseUnit(quantity, unit);
    return price / baseUnitAmount;
  }
  
  List<QuickCompareItem> get sortedItems {
    final validItems = state.items.where((item) => 
        item.price > 0 && item.quantity > 0).toList();
    
    // Group by unit type and sort within each group
    final unitTypeGroups = <UnitType, List<QuickCompareItem>>{};
    
    for (final item in validItems) {
      final unitType = item.unit.type;
      if (!unitTypeGroups.containsKey(unitType)) {
        unitTypeGroups[unitType] = [];
      }
      unitTypeGroups[unitType]!.add(item);
    }
    
    final sortedItems = <QuickCompareItem>[];
    
    // Sort each group by unit price
    for (final group in unitTypeGroups.values) {
      group.sort((a, b) => a.unitPrice.compareTo(b.unitPrice));
      sortedItems.addAll(group);
    }
    
    // Add invalid items at the end
    final invalidItems = state.items.where((item) => 
        item.price <= 0 || item.quantity <= 0).toList();
    sortedItems.addAll(invalidItems);
    
    return sortedItems;
  }
}
