# 📱 UnitPrice Mobile App - Project Requirements and Plan (PRP)

## 📋 Project Overview

**Objective**: Build an offline Flutter mobile app for comparing unit prices of products across different package sizes and units, starting with common liquid/weight measurements but supporting all unit types.

**Target Platform**: Android-first (iOS future consideration)
**Architecture**: Feature-first structure with clean architecture principles
**State Management**: Riverpod
**Database**: Isar (offline-first NoSQL)
**UI Framework**: Material 3 with dynamic theming

---

## 🎯 Core Requirements Summary

Based on INIT.md specifications:

### Functional Requirements
- **Product Management**: CRUD operations for products with name, price, category, image, pack count, unit amount, and unit type
- **Unit Price Calculation**: Automatic PPU (Price Per Unit) calculation with unit conversion
- **Price Comparison**: Sort products by cheapest to most expensive unit price
- **Search & Filter**: Find products by name, category, or price range
- **Session History**: Store and display last 3 comparison sessions with product snapshots
- **Category Management**: Custom categories with default "อื่นๆ" (Others)
- **Image Support**: Camera/gallery selection with compression

### Technical Requirements
- **Offline-First**: Complete functionality without internet connection
- **Thai Language**: Primary UI language with Thai text support
- **Data Persistence**: Local storage with Isar database
- **Unit Conversion**: Automatic conversion between compatible units (g↔kg, ml↔L)
- **Session Limits**: Circular buffer maintaining only 3 most recent comparison sessions

---

## 🏗️ Architecture Implementation Plan

### Project Structure (Feature-First Approach)
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── unit_types.dart
│   │   └── theme_constants.dart
│   ├── utils/
│   │   ├── unit_converter.dart
│   │   ├── price_calculator.dart
│   │   └── image_helper.dart
│   ├── providers/
│   │   ├── database_provider.dart
│   │   └── theme_provider.dart
│   └── extensions/
│       └── context_extensions.dart
├── shared/
│   ├── widgets/
│   │   ├── app_card.dart
│   │   ├── app_button.dart
│   │   ├── empty_state.dart
│   │   └── loading_indicator.dart
│   └── models/
│       ├── unit_type.dart
│       └── comparison_result.dart
├── features/
│   ├── products/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── product.dart
│   │   │   │   └── category.dart
│   │   │   ├── repositories/
│   │   │   │   └── product_repository.dart
│   │   │   └── use_cases/
│   │   │       ├── calculate_unit_price.dart
│   │   │       ├── convert_units.dart
│   │   │       └── manage_products.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── product_model.dart
│   │   │   │   └── category_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── product_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── product_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── product_provider.dart
│   │       │   ├── category_provider.dart
│   │       │   └── product_form_provider.dart
│   │       ├── screens/
│   │       │   ├── product_list_screen.dart
│   │       │   ├── product_form_screen.dart
│   │       │   └── category_management_screen.dart
│   │       └── widgets/
│   │           ├── product_card.dart
│   │           ├── product_form.dart
│   │           ├── category_selector.dart
│   │           └── unit_selector.dart
│   ├── comparison/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── comparison_session.dart
│   │   │   └── repositories/
│   │   │       └── comparison_repository.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── comparison_session_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── comparison_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── comparison_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── comparison_provider.dart
│   │       ├── screens/
│   │       │   ├── comparison_screen.dart
│   │       │   └── history_screen.dart
│   │       └── widgets/
│   │           ├── comparison_card.dart
│   │           ├── price_highlight.dart
│   │           └── session_history_item.dart
│   └── settings/
│       └── presentation/
│           └── screens/
│               └── settings_screen.dart
```

---

## 🔧 Technical Implementation Details

### Database Schema (Isar)

#### Product Model
```dart
@collection
class Product {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String name;
  
  late double price; // THB with 3 decimal precision
  late int packCount;
  late double unitAmount;
  
  @Enumerated(EnumType.name)
  late UnitType unitType; // weight, volume, piece
  
  @Enumerated(EnumType.name)
  late Unit unit; // g, kg, ml, L, piece
  
  String? imagePath;
  String? categoryId;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  
  // Computed properties
  double get unitPricePerBaseUnit {
    final baseUnitAmount = UnitConverter.toBaseUnit(unitAmount, unit);
    return price / (packCount * baseUnitAmount);
  }
}
```

#### Category Model
```dart
@collection
class Category {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String name;
  
  String? color;
  late bool isDefault;
  late DateTime createdAt;
}
```

#### Comparison Session Model
```dart
@collection
class ComparisonSession {
  Id id = Isar.autoIncrement;
  late DateTime createdAt;
  
  late List<String> productSnapshots; // JSON strings of product data at comparison time
  
  // Ensure only 3 sessions are kept (circular buffer)
  static const int maxSessions = 3;
}
```

### Unit System Implementation

#### Unit Types and Conversion
```dart
enum UnitType { weight, volume, piece }

enum Unit {
  // Weight
  gram(UnitType.weight, 1.0),
  kilogram(UnitType.weight, 1000.0),
  
  // Volume  
  milliliter(UnitType.volume, 1.0),
  liter(UnitType.volume, 1000.0),
  
  // Piece
  piece(UnitType.piece, 1.0);
  
  const Unit(this.type, this.baseMultiplier);
  final UnitType type;
  final double baseMultiplier; // Conversion factor to base unit
}

class UnitConverter {
  static double toBaseUnit(double amount, Unit unit) {
    return amount * unit.baseMultiplier;
  }
  
  static bool canCompare(Unit unit1, Unit unit2) {
    return unit1.type == unit2.type;
  }
}
```

### Price Calculation Logic
```dart
class PriceCalculator {
  static double calculatePricePerUnit(Product product) {
    final baseUnitAmount = UnitConverter.toBaseUnit(
      product.unitAmount, 
      product.unit
    );
    return product.price / (product.packCount * baseUnitAmount);
  }
  
  static List<Product> sortByUnitPrice(List<Product> products) {
    final comparableProducts = products.where((p) => 
      products.any((other) => 
        UnitConverter.canCompare(p.unit, other.unit))).toList();
    
    comparableProducts.sort((a, b) => 
      calculatePricePerUnit(a).compareTo(calculatePricePerUnit(b)));
    
    return comparableProducts;
  }
}
```

---

## 📱 Material 3 UI Implementation

### Theme Configuration
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3), // Blue primary
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
```

### Key UI Components

#### Product Card with Price Highlighting
```dart
class ProductCard extends ConsumerWidget {
  final Product product;
  final bool isLowestPrice;
  
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      decoration: BoxDecoration(
        border: isLowestPrice ? Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ) : null,
      ),
      child: Column(
        children: [
          // Product image with placeholder
          AspectRatio(
            aspectRatio: 16/9,
            child: product.imagePath != null 
              ? Image.file(File(product.imagePath!), fit: BoxFit.cover)
              : Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(Icons.shopping_basket),
                ),
          ),
          
          // Product details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                Text('฿${product.price.toStringAsFixed(2)}'),
                Text('${product.unitAmount} ${product.unit.name} × ${product.packCount}'),
                
                // Price per unit with highlight
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLowestPrice 
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '฿${product.unitPricePerBaseUnit.toStringAsFixed(3)}/base unit',
                    style: TextStyle(
                      fontWeight: isLowestPrice ? FontWeight.bold : FontWeight.normal,
                      color: isLowestPrice 
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔄 Riverpod State Management

### Core Providers Setup
```dart
// Database provider
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar instance must be overridden');
});

// Product repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return ProductRepositoryImpl(ProductLocalDataSource(isar));
});

// Products list provider with search/filter
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductsNotifier(repository);
});

// Product form provider for add/edit
final productFormProvider = StateNotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductFormNotifier(repository);
});

// Search and filter state
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Filtered products based on search/category
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  return products.whenData((productList) {
    var filtered = productList;
    
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    
    if (selectedCategory != null) {
      filtered = filtered.where((p) => p.categoryId == selectedCategory).toList();
    }
    
    return PriceCalculator.sortByUnitPrice(filtered);
  });
});
```

### State Notifiers
```dart
class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;
  
  ProductsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    try {
      final products = await _repository.getAllProducts();
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> addProduct(Product product) async {
    await _repository.saveProduct(product);
    loadProducts();
  }
  
  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    loadProducts();
  }
}
```

---

## 📷 Image Handling Implementation

### Image Management Service
```dart
class ImageService {
  static const String _imageFolder = 'product_images';
  
  static Future<String?> pickAndSaveImage({bool fromCamera = false}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (image == null) return null;
    
    // Get app documents directory
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory imageDir = Directory('${appDir.path}/$_imageFolder');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    
    // Generate unique filename
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String imagePath = '${imageDir.path}/$fileName';
    
    // Compress and save image
    final Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      image.path,
      minWidth: 512,
      minHeight: 512,
      quality: 85,
    );
    
    if (compressedImage != null) {
      final File savedImage = File(imagePath);
      await savedImage.writeAsBytes(compressedImage);
      return imagePath;
    }
    
    return null;
  }
  
  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath != null) {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }
  }
}
```

---

## 🔄 Session Management

### Comparison Session Logic
```dart
class ComparisonService {
  final Isar _isar;
  
  ComparisonService(this._isar);
  
  Future<void> saveComparisonSession(List<Product> products) async {
    await _isar.writeTxn(() async {
      // Get current sessions count
      final sessionsCount = await _isar.comparisonSessions.count();
      
      // If we have 3 sessions, delete the oldest one
      if (sessionsCount >= 3) {
        final oldestSession = await _isar.comparisonSessions
          .orderByCreatedAt()
          .first();
        if (oldestSession != null) {
          await _isar.comparisonSessions.delete(oldestSession.id);
        }
      }
      
      // Create new session with product snapshots
      final session = ComparisonSession()
        ..createdAt = DateTime.now()
        ..productSnapshots = products.map((p) => jsonEncode({
          'name': p.name,
          'price': p.price,
          'unitAmount': p.unitAmount,
          'unit': p.unit.name,
          'packCount': p.packCount,
          'ppu': p.unitPricePerBaseUnit,
        })).toList();
        
      await _isar.comparisonSessions.put(session);
    });
  }
  
  Future<List<ComparisonSession>> getRecentSessions() async {
    return await _isar.comparisonSessions
      .orderByCreatedAtDesc()
      .limit(3)
      .findAll();
  }
}
```

---

## ✅ Implementation Task List

### Phase 1: Project Setup & Core Infrastructure
1. **Initialize Flutter project with dependencies**
   - Create new Flutter project
   - Add dependencies: `flutter_riverpod`, `isar`, `isar_flutter_libs`, `path_provider`, `image_picker`, `flutter_image_compress`
   - Add dev dependencies: `isar_generator`, `build_runner`, `riverpod_generator`
   - Configure `analysis_options.yaml` for strict linting

2. **Setup database and core providers**
   - Implement Isar models with proper annotations
   - Create database initialization provider
   - Setup core repository pattern with dependency injection
   - Run code generation: `dart run build_runner build`

3. **Implement unit system and conversion logic**
   - Create Unit enums with conversion factors
   - Implement UnitConverter utility class
   - Create PriceCalculator with PPU logic
   - Add unit tests for conversion accuracy

### Phase 2: Product Management Features
4. **Create product CRUD operations**
   - Implement ProductRepository with Isar integration
   - Create Product domain entities and data models
   - Setup Riverpod providers for product management
   - Implement product form validation logic

5. **Build product management UI**
   - Create ProductCard widget with Material 3 styling
   - Implement ProductForm with all required fields
   - Add image picker integration with compression
   - Create category selection dropdown
   - Implement unit type selector with conversion preview

6. **Add search and filtering functionality**
   - Implement search provider with text filtering
   - Create category filter chip system
   - Add sort by price functionality with unit conversion
   - Implement empty state handling

### Phase 3: Comparison & History Features
7. **Implement comparison logic**
   - Create comparison screen with highlighted cheapest option
   - Implement unit compatibility checking
   - Add real-time PPU calculation and display
   - Create comparison session saving logic

8. **Build history management**
   - Implement circular buffer for 3 recent sessions
   - Create history screen with session details
   - Add session snapshot viewing capability
   - Implement session deletion functionality

### Phase 4: UI/UX Polish & Testing
9. **Apply Material 3 theming and animations**
   - Configure dynamic color scheme with blue/green/orange accents
   - Add Hero animations between screens
   - Implement AnimatedList for product additions
   - Add empty state illustrations and helpful messaging

10. **Comprehensive testing**
    - Unit tests for PPU calculations and unit conversions
    - Widget tests for form validation and user interactions
    - Golden tests for product cards in light/dark themes
    - Integration tests for complete CRUD workflows

11. **Performance optimization and final touches**
    - Implement image loading optimization with caching
    - Add Thai language localization
    - Test offline functionality thoroughly
    - Optimize database queries and indexing

---

## 🧪 Validation Gates

The following commands must execute successfully for deployment readiness:

```bash
# Code quality and formatting
dart format --set-exit-if-changed .
dart analyze --fatal-infos

# Code generation (must run without errors)
dart run build_runner build --delete-conflicting-outputs

# Testing
flutter test test/unit/ --coverage
flutter test test/widget/
flutter test integration_test/

# Build verification
flutter build apk --debug
flutter build apk --release

# Performance profiling
flutter run --profile --trace-startup
```

### Critical Test Coverage Requirements
- **Unit Tests**: PPU calculation accuracy, unit conversion precision, session limit enforcement
- **Widget Tests**: Form validation, search functionality, sort ordering
- **Integration Tests**: Complete product lifecycle (add → compare → save session → delete)
- **Golden Tests**: Product card rendering consistency across themes

---

## 🌟 Critical Success Factors

### Technical Considerations
1. **Unit Conversion Accuracy**: All calculations must handle decimal precision correctly (3 decimal places for THB)
2. **Offline Reliability**: App must function completely without internet connectivity
3. **Thai Language Support**: All text rendering and input must handle Thai characters properly
4. **Image Storage**: Efficient image compression and cleanup to prevent storage bloat
5. **Performance**: Smooth scrolling with hundreds of products in list

### User Experience Priorities
1. **Immediate Visual Feedback**: Real-time PPU calculation while user types in form
2. **Clear Price Comparison**: Obvious highlighting of cheapest option with visual distinction
3. **Intuitive Unit Selection**: Logical grouping and conversion preview
4. **Robust Error Handling**: Clear error messages in Thai language
5. **Accessible Design**: Material 3 accessibility standards compliance

### Data Integrity Safeguards
1. **Session Limiting**: Enforce maximum 3 sessions with proper circular buffer
2. **Image Cleanup**: Delete orphaned images when products are removed
3. **Unit Compatibility**: Prevent comparisons between incompatible unit types
4. **Price Precision**: Maintain accuracy in financial calculations
5. **Backup Strategy**: Export/import capability for user data migration (future consideration)

---

## 📊 Key External Resources

### Official Documentation
- **Flutter Material 3**: https://m3.material.io/develop/flutter
- **Riverpod Architecture Guide**: https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/
- **Isar Database CRUD**: https://isar.dev/crud.html
- **Flutter Image Handling**: https://docs.flutter.dev/cookbook/plugins/picture-using-camera

### Reference Implementations
- **Flutter Riverpod Clean Architecture**: https://github.com/Uuttssaavv/flutter-clean-architecture-riverpod
- **Isar Offline Storage Examples**: https://github.com/isar/isar
- **Price Comparison Flutter App**: https://github.com/sang-bui/price-comparison-app
- **Material 3 Demo**: https://flutter.github.io/samples/web/material_3_demo/

### Best Practices Resources
- **Flutter Project Structure 2024**: https://www.dhiwise.com/post/flutter-project-structure-for-building-future-proof-flutter-apps
- **Isar Database Guide**: https://www.dhiwise.com/post/exploring-isar-flutter-a-powerful-database-for-flutter
- **Image Storage Best Practices**: https://codeberg.org/Flutter-Explained/local_db_tutorial_store_image

---

## 🎯 PRP Quality Assessment

**Confidence Score: 9/10**

### Strengths
- ✅ Complete technical architecture with specific code examples
- ✅ Detailed implementation roadmap with clear task breakdown
- ✅ Comprehensive external resource links for reference
- ✅ Executable validation gates for quality assurance
- ✅ Real-world Flutter patterns from established repositories
- ✅ Specific Thai language and cultural requirements addressed
- ✅ Performance and offline considerations thoroughly planned
- ✅ Database schema and state management fully specified

### Potential Challenges
- ⚠️ Isar database maintenance concerns (community-maintained)
- ⚠️ Complex unit conversion logic requires thorough testing
- ⚠️ Image storage management needs careful implementation
- ⚠️ Thai text rendering may require platform-specific testing

### Success Probability
This PRP provides sufficient context and detail for successful one-pass implementation by an AI agent with access to the specified external resources and Flutter development capabilities. The combination of specific technical requirements, working code examples, and comprehensive validation gates creates a high probability of successful implementation.