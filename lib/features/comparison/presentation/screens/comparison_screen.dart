import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/models/comparison_result.dart';
import '../providers/comparison_provider.dart';
import '../widgets/comparison_card.dart';
import '../widgets/price_highlight.dart';
import 'product_selection_screen.dart';

class ComparisonScreen extends ConsumerWidget {
  final List<Product>? initialProducts;
  
  const ComparisonScreen({
    super.key,
    this.initialProducts,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize comparison if products provided
    if (initialProducts != null && initialProducts!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentComparisonProvider.notifier).compareProducts(initialProducts!);
      });
    }
    
    final comparisonAsync = ref.watch(currentComparisonProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.compare),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveComparison(context, ref),
            tooltip: 'บันทึกการเปรียบเทียบ',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _clearComparison(context, ref),
            tooltip: 'ล้างการเปรียบเทียบ',
          ),
        ],
      ),
      body: comparisonAsync.when(
        data: (result) => _buildComparisonContent(context, ref, result),
        loading: () => LoadingIndicatorVariants.fullScreen(
          message: 'กำลังเปรียบเทียบราคา...',
        ),
        error: (error, stackTrace) => _buildErrorState(context, ref, error),
      ),
    );
  }
  
  Widget _buildComparisonContent(
    BuildContext context, 
    WidgetRef ref, 
    ComparisonResult? result,
  ) {
    if (result == null || result.products.isEmpty) {
      return EmptyState(
        icon: Icons.compare_arrows,
        title: 'ยังไม่มีสินค้าในการเปรียบเทียบ',
        message: 'เพิ่มสินค้าเพื่อเริ่มเปรียบเทียบราคาต่อหน่วย',
        actionText: 'เลือกสินค้า',
        onAction: () => _selectProducts(context, ref),
      );
    }
    
    return Column(
      children: [
        // Price highlight summary
        if (result.hasComparableProducts())
          PriceHighlight(result: result),
        
        // Products comparison list
        Expanded(
          child: _buildProductsList(context, ref, result),
        ),
        
        // Action buttons
        _buildActionButtons(context, ref, result),
      ],
    );
  }
  
  Widget _buildProductsList(
    BuildContext context, 
    WidgetRef ref, 
    ComparisonResult result,
  ) {
    if (result.products.length == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ComparisonCard(
              product: result.products.first,
              result: result,
              onRemove: () => _removeProduct(ref, result.products.first),
            ),
            const SizedBox(height: ThemeConstants.spacingL),
            Text(
              'เพิ่มสินค้าอื่นเพื่อเปรียบเทียบ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            AppButton(
              text: 'เพิ่มสินค้า',
              type: AppButtonType.outlined,
              icon: Icons.add,
              onPressed: () => _selectProducts(context, ref),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
      itemCount: result.products.length,
      itemBuilder: (context, index) {
        final product = result.products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: ThemeConstants.spacingM),
          child: ComparisonCard(
            product: product,
            result: result,
            onRemove: () => _removeProduct(ref, product),
            onTap: () => _showProductDetails(context, product),
          ),
        );
      },
    );
  }
  
  Widget _buildActionButtons(
    BuildContext context, 
    WidgetRef ref, 
    ComparisonResult result,
  ) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'เพิ่มสินค้า',
                type: AppButtonType.outlined,
                icon: Icons.add,
                onPressed: () => _selectProducts(context, ref),
              ),
            ),
            const SizedBox(width: ThemeConstants.spacingM),
            Expanded(
              child: AppButtonVariants.primary(
                text: 'บันทึก',
                icon: Icons.save,
                onPressed: () => _saveComparison(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return EmptyStateVariants.error(
      errorMessage: error.toString(),
      onAction: () {
        ref.read(currentComparisonProvider.notifier).clearComparison();
      },
    );
  }
  
  void _selectProducts(BuildContext context, WidgetRef ref) async {
    final currentResult = ref.read(currentComparisonProvider).valueOrNull;
    final alreadySelected = currentResult?.products ?? <Product>[];
    
    final selectedProducts = await Navigator.of(context).push<List<Product>>(
      MaterialPageRoute(
        builder: (context) => ProductSelectionScreen(
          alreadySelected: alreadySelected,
        ),
      ),
    );
    
    if (selectedProducts != null && selectedProducts.isNotEmpty) {
      // Combine with already selected products
      final allProducts = <Product>[
        ...alreadySelected,
        ...selectedProducts,
      ];
      
      // Remove duplicates by ID
      final uniqueProducts = <String, Product>{};
      for (final product in allProducts) {
        uniqueProducts[product.id.toString()] = product;
      }
      
      // Update comparison
      ref.read(currentComparisonProvider.notifier)
          .compareProducts(uniqueProducts.values.toList());
    }
  }
  
  void _removeProduct(WidgetRef ref, Product product) {
    ref.read(currentComparisonProvider.notifier).removeProduct(product);
  }
  
  void _clearComparison(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างการเปรียบเทียบ'),
        content: const Text('คุณต้องการล้างสินค้าทั้งหมดออกจากการเปรียบเทียบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(currentComparisonProvider.notifier).clearComparison();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ล้าง'),
          ),
        ],
      ),
    );
  }
  
  void _saveComparison(BuildContext context, WidgetRef ref) {
    final result = ref.read(currentComparisonProvider).valueOrNull;
    if (result == null || !result.hasComparableProducts()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่มีข้อมูลการเปรียบเทียบที่จะบันทึก'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    ref.read(comparisonHistoryProvider.notifier).saveCurrentComparison(result);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกการเปรียบเทียบเรียบร้อย'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ProductDetailsSheet(product: product),
    );
  }
}

// Product details bottom sheet
class _ProductDetailsSheet extends StatelessWidget {
  final Product product;
  
  const _ProductDetailsSheet({required this.product});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          
          const SizedBox(height: ThemeConstants.spacingL),
          
          _buildDetailRow(context, 'ราคา', '฿${product.price.toStringAsFixed(AppConstants.pricePrecision)}'),
          _buildDetailRow(context, 'ปริมาณ', '${product.unitAmount} ${product.unit.displayName}'),
          _buildDetailRow(context, 'จำนวนแพ็ค', '${product.packCount}'),
          _buildDetailRow(context, 'ราคาต่อหน่วย', '฿${product.unitPricePerBaseUnit.toStringAsFixed(AppConstants.ppuPrecision)}'),
          
          const SizedBox(height: ThemeConstants.spacingL),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingS),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
