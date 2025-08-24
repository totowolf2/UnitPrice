import 'package:flutter/material.dart';

import '../../core/constants/theme_constants.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: ThemeConstants.spacingL),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: ThemeConstants.spacingM),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: ThemeConstants.spacingL),
              AppButton.outlined(
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Specialized empty state variants
extension EmptyStateVariants on EmptyState {
  static EmptyState noProducts({
    Key? key,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.shopping_basket_outlined,
      title: 'ไม่มีสินค้า',
      message: 'เพิ่มสินค้าเพื่อเริ่มเปรียบเทียบราคา',
      actionText: 'เพิ่มสินค้า',
      onAction: onAction,
    );
  }

  static EmptyState noSearchResults({
    Key? key,
    String? searchQuery,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.search_off,
      title: 'ไม่พบสินค้า',
      message: searchQuery != null 
          ? 'ไม่พบสินค้าที่ตรงกับ "$searchQuery"'
          : 'ลองค้นหาด้วยคำอื่น',
    );
  }

  static EmptyState noHistory({Key? key}) {
    return EmptyState(
      key: key,
      icon: Icons.history,
      title: 'ไม่มีประวัติการเปรียบเทียบ',
      message: 'เมื่อคุณเปรียบเทียบสินค้าแล้ว ประวัติจะปรากฏที่นี่',
    );
  }

  static EmptyState noCategories({
    Key? key,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.category_outlined,
      title: 'ไม่มีหมวดหมู่',
      message: 'เพิ่มหมวดหมู่เพื่อจัดระเบียบสินค้า',
      actionText: 'เพิ่มหมวดหมู่',
      onAction: onAction,
    );
  }

  static EmptyState error({
    Key? key,
    String? errorMessage,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.error_outline,
      title: 'เกิดข้อผิดพลาด',
      message: errorMessage ?? 'กรุณาลองใหม่อีกครั้ง',
      actionText: 'ลองใหม่',
      onAction: onAction,
    );
  }

  static EmptyState loading({Key? key}) {
    return EmptyState(
      key: key,
      icon: Icons.hourglass_empty,
      title: 'กำลังโหลด...',
      message: 'กรุณารอสักครู่',
    );
  }
}