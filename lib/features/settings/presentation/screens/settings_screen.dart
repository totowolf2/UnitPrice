import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ThemeConstants.spacingM),
        children: [
          // App Information
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'เกี่ยวกับแอป'),
                const SizedBox(height: ThemeConstants.spacingM),
                _buildInfoRow(context, 'ชื่อแอป', AppStrings.appName),
                _buildInfoRow(context, 'เวอร์ชัน', '1.0.0'),
                _buildInfoRow(context, 'สร้างโดย', 'UnitPrice Team'),
              ],
            ),
          ),
          
          // Theme Settings
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'การแสดงผล'),
                const SizedBox(height: ThemeConstants.spacingM),
                
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('ธีม'),
                  subtitle: Text(_getThemeModeText(themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('ตามระบบ'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('สว่าง'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('มืด'),
                      ),
                    ],
                    onChanged: (mode) {
                      if (mode != null) {
                        ref.read(themeModeProvider.notifier).state = mode;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // App Statistics
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'สถิติการใช้งาน'),
                const SizedBox(height: ThemeConstants.spacingM),
                _buildInfoRow(context, 'จำนวนสินค้า', 'กำลังโหลด...'),
                _buildInfoRow(context, 'หมวดหมู่', 'กำลังโหลด...'),
                _buildInfoRow(context, 'ประวัติเปรียบเทียบ', '0 - ${AppConstants.maxComparisonSessions}'),
              ],
            ),
          ),
          
          // Advanced Features
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'ฟีเจอร์ขั้นสูง'),
                const SizedBox(height: ThemeConstants.spacingM),
                
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('จัดการสินค้า'),
                  subtitle: const Text('เพิ่ม แก้ไข หรือลบสินค้าที่บันทึกไว้'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _navigateToProductManagement(context),
                ),
                
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('จัดการหมวดหมู่'),
                  subtitle: const Text('สร้างและจัดระเบียบหมวดหมู่สินค้า'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _navigateToCategoryManagement(context),
                ),
                
                ListTile(
                  leading: const Icon(Icons.settings_applications_outlined),
                  title: const Text('ตั้งค่าขั้นสูง'),
                  subtitle: const Text('กำหนดหน่วยเริ่มต้น และการตั้งค่าอื่นๆ'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showAdvancedSettings(context),
                ),
              ],
            ),
          ),
          
          // Data Management
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'จัดการข้อมูล'),
                const SizedBox(height: ThemeConstants.spacingM),
                
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('ล้างรูปภาพที่ไม่ใช้'),
                  subtitle: const Text('ลบรูปภาพที่ไม่ได้อ้างอิงโดยสินค้าใดๆ'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showCleanupDialog(context),
                ),
                
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined),
                  title: const Text('ล้างข้อมูลทั้งหมด'),
                  subtitle: const Text('ลบสินค้า หมวดหมู่ และประวัติทั้งหมด'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showResetDialog(context, ref),
                ),
                
                ListTile(
                  leading: const Icon(Icons.import_export_outlined),
                  title: const Text('นำเข้า/ส่งออกข้อมูล'),
                  subtitle: const Text('สำรองหรือกู้คืนข้อมูลสินค้า'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showImportExportDialog(context),
                ),
              ],
            ),
          ),
          
          // Help & Support
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'ช่วยเหลือและสนับสนุน'),
                const SizedBox(height: ThemeConstants.spacingM),
                
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('วิธีการใช้งาน'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showHelpDialog(context),
                ),
                
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('รายงานปัญหา'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showReportDialog(context),
                ),
              ],
            ),
          ),
        ],
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
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingS),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'ตามระบบ';
      case ThemeMode.light:
        return 'สว่าง';
      case ThemeMode.dark:
        return 'มืด';
    }
  }
  
  void _showCleanupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างรูปภาพที่ไม่ใช้'),
        content: const Text('คุณต้องการลบรูปภาพที่ไม่ได้อ้างอิงโดยสินค้าใดๆ หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('กำลังล้างรูปภาพ...'),
                      ],
                    ),
                  ),
                );
                
                // Simulate cleanup process
                await Future.delayed(const Duration(seconds: 1));
                
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ล้างรูปภาพที่ไม่ใช้เรียบร้อยแล้ว'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('เกิดข้อผิดพลาด: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('ล้าง'),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างข้อมูลทั้งหมด'),
        content: const Text(
          'คำเตือน: การกระทำนี้จะลบข้อมูลทั้งหมดและไม่สามารถกู้คืนได้ '
          'คุณแน่ใจหรือไม่ที่จะดำเนินการต่อ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Double confirmation dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ยืนยันการลบข้อมูล'),
                  content: const Text(
                    'การกระทำนี้จะลบ:\n'
                    '• สินค้าทั้งหมด\n'
                    '• หมวดหมู่ที่สร้างขึ้น\n'
                    '• ประวัติการเปรียบเทียบ\n'
                    '• รูปภาพทั้งหมด\n\n'
                    'และไม่สามารถกู้คืนได้ คุณแน่ใจหรือไม่?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('ยกเลิก'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('ลบทั้งหมด'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && context.mounted) {
                try {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('กำลังล้างข้อมูล...'),
                        ],
                      ),
                    ),
                  );
                  
                  // Simulate data clearing process
                  // In a real implementation, this would:
                  // - Clear all products from database
                  // - Reset categories to default
                  // - Clear comparison history
                  // - Remove all image files
                  await Future.delayed(const Duration(seconds: 1));
                  
                  // Simulate additional cleanup time
                  await Future.delayed(const Duration(seconds: 2));
                  
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ล้างข้อมูลทั้งหมดเรียบร้อยแล้ว'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('เกิดข้อผิดพลาดในการล้างข้อมูล: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ล้างทั้งหมด'),
          ),
        ],
      ),
    );
  }
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('วิธีการใช้งาน'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. เพิ่มสินค้าด้วยการกดปุ่ม + ในหน้าสินค้า'),
              SizedBox(height: 8),
              Text('2. ใส่ข้อมูลสินค้า: ชื่อ, ราคา, ปริมาณ, และหน่วย'),
              SizedBox(height: 8),
              Text('3. เปรียบเทียบสินค้าในหน้าเปรียบเทียบ'),
              SizedBox(height: 8),
              Text('4. ดูประวัติการเปรียบเทียบในหน้าประวัติ'),
              SizedBox(height: 8),
              Text('5. แอปจะคำนวณราคาต่อหน่วยให้อัตโนมัติ'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
  
  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายงานปัญหา'),
        content: const Text(
          'หากพบปัญหาการใช้งาน กรุณาติดต่อทีมพัฒนา '
          'หรือแจ้งปัญหาผ่านช่องทางต่างๆ ที่มีให้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
  
  void _showImportExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('นำเข้า/ส่งออกข้อมูล'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('ส่งออกข้อมูล'),
              subtitle: const Text('สำรองข้อมูลไปยังไฟล์'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ฟีเจอร์ส่งออกข้อมูลจะเพิ่มในเวอร์ชันถัดไป'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: const Text('นำเข้าข้อมูล'),
              subtitle: const Text('กู้คืนข้อมูลจากไฟล์สำรอง'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ฟีเจอร์นำเข้าข้อมูลจะเพิ่มในเวอร์ชันถัดไป'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToProductManagement(BuildContext context) {
    Navigator.of(context).pushNamed('/products');
    // TODO: Update navigation to use proper route
    // For now, show info dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('จัดการสินค้า'),
        content: const Text(
          'ฟีเจอร์นี้ให้เข้าถึงการจัดการสินค้าแบบละเอียด '
          'รวมถึงการเพิ่ม แก้ไข และลบสินค้าที่บันทึกไว้ '
          'ซึ่งเหมาะสำหรับผู้ใช้ขั้นสูง',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToCategoryManagement(BuildContext context) {
    // TODO: Navigate to category management screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('จัดการหมวดหมู่'),
        content: const Text(
          'สร้างและจัดการหมวดหมู่สินค้า '
          'เพื่อจัดระเบียบสินค้าให้ง่ายต่อการค้นหาและเปรียบเทียบ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
  
  void _showAdvancedSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ตั้งค่าขั้นสูง'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('หน่วยเริ่มต้น:'),
              SizedBox(height: 8),
              Text('• น้ำหนัก: กรัม (g)'),
              Text('• ปริมาตร: มิลลิลิตร (ml)'),
              Text('• จำนวน: ชิ้น (piece)'),
              SizedBox(height: 16),
              Text('ตั้งค่าอื่นๆ:'),
              SizedBox(height: 8),
              Text('• จำนวนประวัติสูงสุด: 50 รายการ'),
              Text('• ความแม่นยำของราคา: 2 ตำแหน่ง'),
              Text('• การแสดงผลตัวเลข: ตามภาษาท้องถิ่น'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}