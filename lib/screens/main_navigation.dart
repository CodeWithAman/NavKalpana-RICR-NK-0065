// =====================================================
// MainNavigation – bottom nav shell
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard_screen.dart';
import '../screens/expense_list_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/budget_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const _pages = [
    DashboardScreen(),
    ExpenseListScreen(),
    AnalyticsScreen(),
    BudgetScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _BottomBar(
        selected: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Home',     index: 0, selected: selected, onTap: onTap),
          _NavItem(icon: Icons.list_alt,     label: 'Expenses', index: 1, selected: selected, onTap: onTap),
          _NavItem(icon: Icons.bar_chart,    label: 'Analytics',index: 2, selected: selected, onTap: onTap),
          _NavItem(icon: Icons.account_balance_wallet, label: 'Budget', index: 3, selected: selected, onTap: onTap),
          _NavItem(icon: Icons.person,       label: 'Profile',  index: 4, selected: selected, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon; final String label; final int index, selected;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.label, required this.index,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == selected;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: active ? AppTheme.accent : AppTheme.textDim, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(
            color: active ? AppTheme.accent : AppTheme.textDim,
            fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.normal,
          )),
        ]),
      ),
    );
  }
}
