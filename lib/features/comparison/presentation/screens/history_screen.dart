import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/comparison_session.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/data/models/product_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/constants/unit_types.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/comparison_provider.dart';
import '../widgets/session_history_item.dart';
import 'comparison_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(comparisonHistoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.history),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _clearAllHistory(context, ref),
            tooltip: 'ล้างประวัติทั้งหมด',
          ),
        ],
      ),
      body: historyAsync.when(
        data: (sessions) => _buildHistoryList(context, ref, sessions),
        loading: () => _buildLoadingList(),
        error: (error, stackTrace) => _buildErrorState(context, ref, error),
      ),
    );
  }
  
  Widget _buildHistoryList(
    BuildContext context, 
    WidgetRef ref, 
    List<ComparisonSession> sessions,
  ) {
    if (sessions.isEmpty) {
      return EmptyStateVariants.noHistory();
    }
    
    return Column(
      children: [
        // Session limit info
        _buildSessionLimitInfo(context, sessions.length),
        
        // Sessions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return SessionHistoryItem(
                session: session,
                onTap: () => _viewSession(context, ref, session),
                onDelete: () => _deleteSession(context, ref, session),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSessionLimitInfo(BuildContext context, int sessionCount) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(ThemeConstants.spacingM),
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: ThemeConstants.spacingS),
              Text(
                'ประวัติการเปรียบเทียบ',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConstants.spacingXS),
          Text(
            '$sessionCount/${AppConstants.maxComparisonSessions} เซสชัน (เก็บเฉพาะ ${AppConstants.maxComparisonSessions} เซสชันล่าสุด)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      itemCount: 3,
      itemBuilder: (context, index) => const SessionHistoryItemSkeleton(),
    );
  }
  
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return EmptyStateVariants.error(
      errorMessage: error.toString(),
      onAction: () {
        ref.read(comparisonHistoryProvider.notifier).loadHistory();
      },
    );
  }
  
  void _viewSession(BuildContext context, WidgetRef ref, ComparisonSession session) {
    try {
      // Parse product snapshots back to products
      final products = _parseSessionProducts(session.productSnapshots);
      
      if (products.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถโหลดข้อมูลเซสชันได้'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Navigate to comparison screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ComparisonScreen(),
        ),
      );
      
      // TODO: Initialize quick compare with historical products
      // This would require updating the quick compare provider to accept initial data
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _deleteSession(BuildContext context, WidgetRef ref, ComparisonSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบประวัติ'),
        content: const Text('คุณต้องการลบประวัติการเปรียบเทียบนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              // Provider API expects String id; convert from int
              ref.read(comparisonHistoryProvider.notifier).deleteSession(session.id.toString());
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
  
  void _clearAllHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างประวัติทั้งหมด'),
        content: const Text('คุณต้องการล้างประวัติการเปรียบเทียบทั้งหมดหรือไม่? การกระทำนี้ไม่สามารถยกเลิกได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(comparisonHistoryProvider.notifier).clearAllSessions();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ล้างทั้งหมด'),
          ),
        ],
      ),
    );
  }
  
  List<Product> _parseSessionProducts(List<String> snapshots) {
    final products = <Product>[];
    
    for (final snapshot in snapshots) {
      try {
        final data = jsonDecode(snapshot) as Map<String, dynamic>;
        
        // Create a temporary product from the snapshot
        final product = ProductModel.create(
          name: data['name'] as String? ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          packCount: (data['packCount'] as num?)?.toInt() ?? 1,
          unitAmount: (data['unitAmount'] as num?)?.toDouble() ?? 0.0,
          unit: _parseUnit(data['unit'] as String?),
          imagePath: data['imagePath'] as String?,
          categoryId: data['categoryId'] as String?,
        );
        
        products.add(product);
      } catch (error) {
        // Skip invalid snapshots
        continue;
      }
    }
    
    return products;
  }
  
  Unit _parseUnit(String? unitName) {
    if (unitName == null) return Unit.piece;
    
    try {
      return Unit.values.firstWhere(
        (unit) => unit.name == unitName,
        orElse: () => Unit.piece,
      );
    } catch (error) {
      return Unit.piece;
    }
  }
}
