import 'package:flutter/material.dart';

import '../../domain/home_tab.dart';

/// A horizontally scrollable row of top-level browse tabs, styled after
/// SHEIN's category bar: plain text tabs with a bold underline on the
/// active one, rather than filled chips.
class HomeTabBar extends StatelessWidget {
  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  const HomeTabBar({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: HomeTab.values.length,
        itemBuilder: (context, index) {
          final tab = HomeTab.values[index];
          final isSelected = tab == selected;
          final isSale = tab == HomeTab.sale;
          final color = isSale
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface;

          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: InkWell(
              onTap: () => onSelected(tab),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? color
                          : color.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 2.5,
                    width: isSelected ? 20 : 0,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
