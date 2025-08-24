import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../products/presentation/screens/product_list_screen.dart';
import '../../comparison/presentation/screens/comparison_screen.dart';
import '../../comparison/presentation/screens/history_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart';

final currentTabProvider = StateProvider<int>((ref) => 1); // Start with Quick Compare

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    
    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: const [
          SettingsScreen(), // Move settings to first position (will be accessed via quick compare)
          ComparisonScreen(), // Quick Compare as default
          HistoryScreen(),
          SettingsScreen(), // Keep original settings tab for now
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products', // Will be hidden in settings
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed),
            label: 'Quick Compare',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: AppStrings.history,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: AppStrings.settings,
          ),
        ],
      ),
    );
  }
}

// Alternative implementation with TabBarView if preferred
class HomeScreenWithTabs extends ConsumerWidget {
  const HomeScreenWithTabs({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appName),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.shopping_bag_outlined),
                text: AppStrings.products,
              ),
              Tab(
                icon: Icon(Icons.compare_arrows_outlined),
                text: AppStrings.compare,
              ),
              Tab(
                icon: Icon(Icons.history_outlined),
                text: AppStrings.history,
              ),
              Tab(
                icon: Icon(Icons.settings_outlined),
                text: AppStrings.settings,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductListScreen(),
            ComparisonScreen(),
            HistoryScreen(),
            SettingsScreen(),
          ],
        ),
      ),
    );
  }
}
