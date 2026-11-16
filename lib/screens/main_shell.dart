import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'assistant_screen.dart';
import 'calendar_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'stock_screen.dart';

/// Holds the five main tabs and the bottom navigation bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _pages = [
    HomeScreen(),
    StockScreen(),
    OrdersScreen(),
    CalendarScreen(),
    AssistantScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = context.watch<AppState>().tab;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: tab, children: _pages),
      ),
      bottomNavigationBar: BottomNav(
        index: tab,
        onTap: (i) => context.read<AppState>().goToTab(i),
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.inventory_2_outlined, 'Stock'),
    (Icons.assignment_outlined, 'Orders'),
    (Icons.calendar_month_outlined, 'Calendar'),
    (Icons.auto_awesome_outlined, 'AI Assistant'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 36,
                        height: 30,
                        decoration: BoxDecoration(
                          color: i == index
                              ? AppColors.lavenderTint
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(_items[i].$1,
                            size: 23,
                            color: i == index ? AppColors.ink : AppColors.muted),
                      ),
                      const SizedBox(height: 3),
                      Text(_items[i].$2,
                          style: AppText.body(11,
                              color:
                                  i == index ? AppColors.ink : AppColors.muted,
                              weight: i == index
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ],
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
