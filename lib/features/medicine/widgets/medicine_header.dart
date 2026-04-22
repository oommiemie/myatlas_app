import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MedicineHeader extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const MedicineHeader({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'รายการทานยา',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          _PillTabBar(
            selectedTab: selectedTab,
            onTabChanged: onTabChanged,
          ),
        ],
      ),
    );
  }
}

class _PillTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _PillTabBar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  static const _labels = ['รายการยา', 'ใบสั่งยา'];
  static const _duration = Duration(milliseconds: 260);
  static const _curve = Curves.easeOutCubic;
  static const double _tabWidth = 86;
  static const double _tabHeight = 36;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x33D4D4D4),
        borderRadius: BorderRadius.circular(296),
      ),
      child: SizedBox(
        width: _tabWidth * _labels.length,
        height: _tabHeight,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: _duration,
              curve: _curve,
              left: selectedTab * _tabWidth,
              top: 0,
              width: _tabWidth,
              height: _tabHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary600,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Row(
              children: [
                for (int i = 0; i < _labels.length; i++)
                  SizedBox(
                    width: _tabWidth,
                    height: _tabHeight,
                    child: _TabLabel(
                      label: _labels[i],
                      selected: selectedTab == i,
                      duration: _duration,
                      onTap: () => onTabChanged(i),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  const _TabLabel({
    required this.label,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: duration,
          curve: Curves.easeOut,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.textInverse : AppColors.textPrimary,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
