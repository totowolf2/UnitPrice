import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/constants/unit_types.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/product_form_provider.dart';
import 'unit_selector.dart';
import 'category_selector.dart';

class ProductForm extends ConsumerStatefulWidget {
  final Product? existingProduct;
  final VoidCallback? onSaved;
  final VoidCallback? onCancelled;
  
  const ProductForm({
    super.key,
    this.existingProduct,
    this.onSaved,
    this.onCancelled,
  });
  
  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _packCountController = TextEditingController();
  final _unitAmountController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    if (widget.existingProduct != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref.read(productFormProvider.notifier).loadProduct(widget.existingProduct!);
        _updateControllers();
      });
    } else {
      // Set default value for new product
      _packCountController.text = '1';
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _packCountController.dispose();
    _unitAmountController.dispose();
    super.dispose();
  }
  
  void _updateControllers() {
    final state = ref.read(productFormProvider);
    _nameController.text = state.name;
    _priceController.text = state.price > 0 ? state.price.toString() : '';
    _packCountController.text = state.packCount.toString(); // Always show pack count value
    _unitAmountController.text = state.unitAmount > 0 ? state.unitAmount.toString() : '';
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormProvider);
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            _buildImageSection(context, state),
            
            const SizedBox(height: ThemeConstants.spacingL),
            
            // Basic information
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'ข้อมูลพื้นฐาน'),
                  const SizedBox(height: ThemeConstants.spacingM),
                  _buildNameField(state),
                  const SizedBox(height: ThemeConstants.spacingM),
                  _buildPriceField(state),
                  const SizedBox(height: ThemeConstants.spacingM),
                  CategorySelector(
                    selectedCategoryName: state.categoryName,
                    onChanged: (categoryName) {
                      ref.read(productFormProvider.notifier).updateCategoryName(categoryName);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: ThemeConstants.spacingL),
            
            // Package information
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'ข้อมูลบรรจุภัณฑ์'),
                  const SizedBox(height: ThemeConstants.spacingM),
                  Row(
                    children: [
                      Expanded(child: _buildPackCountField(state)),
                      const SizedBox(width: ThemeConstants.spacingM),
                      Expanded(child: _buildUnitAmountField(state)),
                    ],
                  ),
                  const SizedBox(height: ThemeConstants.spacingL),
                  UnitSelector(
                    selectedUnit: state.unit,
                    onChanged: (unit) {
                      ref.read(productFormProvider.notifier).updateUnit(unit);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: ThemeConstants.spacingL),
            
            // Price per unit preview
            if (state.isValid) _buildPricePreview(context, state),
            
            const SizedBox(height: ThemeConstants.spacingL),
            
            // Error message
            if (state.errors['general'] != null)
              Container(
                padding: const EdgeInsets.all(ThemeConstants.spacingM),
                margin: const EdgeInsets.only(bottom: ThemeConstants.spacingL),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                ),
                child: Text(
                  state.errors['general']!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            
            // Action buttons
            Row(
              children: [
                if (widget.onCancelled != null)
                  Expanded(
                    child: AppButton.outlined(
                      text: AppStrings.cancel,
                      onPressed: widget.onCancelled,
                    ),
                  ),
                if (widget.onCancelled != null)
                  const SizedBox(width: ThemeConstants.spacingM),
                Expanded(
                  child: AppButtonVariants.primary(
                    text: AppStrings.save,
                    isLoading: state.isLoading,
                    onPressed: state.isValid ? _saveProduct : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  Widget _buildImageSection(BuildContext context, ProductFormState state) {
    return AppCard(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: ThemeConstants.productCardAspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              ),
              child: state.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                      child: Image.file(
                        File(state.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            _buildImagePlaceholder(context),
                      ),
                    )
                  : _buildImagePlaceholder(context),
            ),
          ),
          const SizedBox(height: ThemeConstants.spacingM),
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  text: AppStrings.takePhoto,
                  icon: Icons.camera_alt,
                  onPressed: () => _pickImage(true),
                ),
              ),
              const SizedBox(width: ThemeConstants.spacingM),
              Expanded(
                child: AppButton.outlined(
                  text: AppStrings.chooseFromGallery,
                  icon: Icons.photo_library,
                  onPressed: () => _pickImage(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildImagePlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: ThemeConstants.spacingS),
          Text(
            'ไม่มีรูปภาพ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNameField(ProductFormState state) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: AppStrings.productName,
        prefixIcon: const Icon(Icons.shopping_bag),
        errorText: state.errors['name'],
      ),
      onChanged: (value) {
        ref.read(productFormProvider.notifier).updateName(value);
      },
      validator: (value) => state.errors['name'],
    );
  }
  
  Widget _buildPriceField(ProductFormState state) {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: AppStrings.price,
        prefixIcon: const Icon(Icons.attach_money),
        suffixText: 'บาท',
        errorText: state.errors['price'],
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: (value) {
        final price = double.tryParse(value) ?? 0.0;
        ref.read(productFormProvider.notifier).updatePrice(price);
      },
      validator: (value) => state.errors['price'],
    );
  }
  
  Widget _buildPackCountField(ProductFormState state) {
    return TextFormField(
      controller: _packCountController,
      decoration: InputDecoration(
        labelText: AppStrings.packCount,
        hintText: '1',
        prefixIcon: const Icon(Icons.inventory),
        errorText: state.errors['packCount'],
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onTap: () {
        // Select all text when field is tapped for easy replacement
        if (_packCountController.text.isNotEmpty) {
          _packCountController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _packCountController.text.length,
          );
        }
      },
      onChanged: (value) {
        final packCount = int.tryParse(value) ?? 1; // Default to 1 if empty or invalid
        ref.read(productFormProvider.notifier).updatePackCount(packCount);
      },
      validator: (value) => state.errors['packCount'],
    );
  }
  
  Widget _buildUnitAmountField(ProductFormState state) {
    return TextFormField(
      controller: _unitAmountController,
      decoration: InputDecoration(
        labelText: AppStrings.unitAmount,
        prefixIcon: const Icon(Icons.straighten),
        errorText: state.errors['unitAmount'],
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
      ],
      onChanged: (value) {
        final unitAmount = double.tryParse(value) ?? 0.0;
        ref.read(productFormProvider.notifier).updateUnitAmount(unitAmount);
      },
      validator: (value) => state.errors['unitAmount'],
    );
  }
  
  Widget _buildPricePreview(BuildContext context, ProductFormState state) {
    final product = state.toProduct();
    final unitPrice = product.unitPricePerBaseUnit;
    final theme = Theme.of(context);
    
    return AppCardVariants.highlighted(
      highlightColor: theme.colorScheme.primary,
      child: Column(
        children: [
          Text(
            'ราคาต่อหน่วย (ตัวอย่าง)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ThemeConstants.spacingS),
          Text(
            '฿${unitPrice.toStringAsFixed(AppConstants.ppuPrecision)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'ต่อ ${_getBaseUnitName(state.unit.type)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getBaseUnitName(UnitType type) {
    switch (type) {
      case UnitType.weight:
        return 'กรัม';
      case UnitType.volume:
        return 'มิลลิลิตร';
      case UnitType.piece:
        return 'ชิ้น';
    }
  }
  
  void _pickImage(bool fromCamera) async {
    try {
      final imagePath = await ImageHelper.pickAndSaveImage(fromCamera: fromCamera);
      if (imagePath != null) {
        ref.read(productFormProvider.notifier).updateImagePath(imagePath);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถเลือกรูปภาพได้: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _saveProduct() async {
    final notifier = ref.read(productFormProvider.notifier);
    
    bool success;
    if (widget.existingProduct != null) {
      success = await notifier.updateProduct(widget.existingProduct!);
    } else {
      success = await notifier.saveProduct();
    }
    
    if (success && mounted) {
      widget.onSaved?.call();
    }
  }
}
