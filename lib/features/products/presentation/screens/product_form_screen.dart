import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/product_form.dart';
import '../providers/product_form_provider.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends ConsumerWidget {
  final Product? product;
  
  const ProductFormScreen({
    super.key,
    this.product,
  });
  
  bool get isEditing => product != null;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editProduct : AppStrings.addProduct),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleCancel(context, ref),
        ),
      ),
      body: ProductForm(
        existingProduct: product,
        onSaved: () => _handleSaved(context, ref),
        onCancelled: () => _handleCancel(context, ref),
      ),
    );
  }
  
  void _handleSaved(BuildContext context, WidgetRef ref) {
    // Refresh the products list to show the new product
    ref.read(productsProvider.notifier).loadProducts();
    
    // Reset the form
    ref.read(productFormProvider.notifier).reset();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'อัปเดตสินค้าเรียบร้อย' : 'เพิ่มสินค้าเรียบร้อย',
        ),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back
    Navigator.of(context).pop();
  }
  
  void _handleCancel(BuildContext context, WidgetRef ref) {
    final state = ref.read(productFormProvider);
    
    // Check if form has unsaved changes
    if (_hasUnsavedChanges(state)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ยกเลิกการแก้ไข'),
          content: const Text('คุณมีการเปลี่ยนแปลงที่ยังไม่ได้บันทึก คุณต้องการออกจากหน้านี้หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () {
                // Reset form and navigate back
                ref.read(productFormProvider.notifier).reset();
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close form screen
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('ออก'),
            ),
          ],
        ),
      );
    } else {
      // No unsaved changes, just navigate back
      ref.read(productFormProvider.notifier).reset();
      Navigator.of(context).pop();
    }
  }
  
  bool _hasUnsavedChanges(ProductFormState state) {
    if (product == null) {
      // New product - check if any field has content
      return state.name.isNotEmpty ||
             state.price > 0 ||
             state.packCount > 1 ||
             state.unitAmount > 0 ||
             state.imagePath != null ||
             state.categoryId != null;
    } else {
      // Editing product - check if any field has changed
      return state.name != product!.name ||
             state.price != product!.price ||
             state.packCount != product!.packCount ||
             state.unitAmount != product!.unitAmount ||
             state.unit != product!.unit ||
             state.imagePath != product!.imagePath ||
             state.categoryId != product!.categoryId;
    }
  }
}