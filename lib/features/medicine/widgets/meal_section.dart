import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

class MedicineItem {
  final String name;
  final String description;

  const MedicineItem({required this.name, required this.description});
}

class MealSection extends StatelessWidget {
  final String label1;
  final String label2;
  final int itemCount;
  final List<MedicineItem> medicines;
  final List<bool> takenStates;
  final bool allTaken;
  final VoidCallback onToggleAll;
  final ValueChanged<int> onToggleItem;

  const MealSection({
    super.key,
    required this.label1,
    required this.label2,
    required this.itemCount,
    required this.medicines,
    required this.takenStates,
    required this.allTaken,
    required this.onToggleAll,
    required this.onToggleItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MealLabelBadge(label1: label1, label2: label2),
        const SizedBox(width: 10),
        Expanded(
          child: _MealCard(
            itemCount: itemCount,
            medicines: medicines,
            takenStates: takenStates,
            allTaken: allTaken,
            onToggleAll: onToggleAll,
            onToggleItem: onToggleItem,
          ),
        ),
      ],
    );
  }
}

class _MealLabelBadge extends StatelessWidget {
  final String label1;
  final String label2;

  const _MealLabelBadge({required this.label1, required this.label2});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -100,
            top: 0,
            child: Container(
              width: 147,
              height: 147,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.0),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE6F7FF).withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label2,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final int itemCount;
  final List<MedicineItem> medicines;
  final List<bool> takenStates;
  final bool allTaken;
  final VoidCallback onToggleAll;
  final ValueChanged<int> onToggleItem;

  const _MealCard({
    required this.itemCount,
    required this.medicines,
    required this.takenStates,
    required this.allTaken,
    required this.onToggleAll,
    required this.onToggleItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ยาทั้งหมด',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$itemCount',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const TextSpan(
                          text: ' รายการ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _TakeAllButton(taken: allTaken, onTap: onToggleAll),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(medicines.length, (i) {
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: _MedicineCard(
                item: medicines[i],
                taken: i < takenStates.length ? takenStates[i] : false,
                onToggle: () => onToggleItem(i),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TakeAllButton extends StatelessWidget {
  final bool taken;
  final VoidCallback onTap;

  const _TakeAllButton({required this.taken, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: taken ? AppColors.success600 : Colors.transparent,
          border: taken
              ? null
              : Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: Center(
                child: taken
                    ? SvgPicture.asset(
                        'assets/svg/icon_done_check.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFCFCFC),
                          BlendMode.srcIn,
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/svg/icon_pending_sun.svg',
                        width: 14,
                        height: 14,
                      ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              taken ? 'ทานแล้ว' : 'ทานทั้งหมด',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: taken ? const Color(0xFFFCFCFC) : const Color(0xFF18181B),
                height: 20 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final MedicineItem item;
  final bool taken;
  final VoidCallback onToggle;

  const _MedicineCard({
    required this.item,
    required this.taken,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/medicine.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 20,
              height: 20,
              child: Center(
                child: taken
                    ? SvgPicture.asset(
                        'assets/svg/icon_done_check.svg',
                        width: 20,
                        height: 20,
                      )
                    : SvgPicture.asset(
                        'assets/svg/icon_pending_sun.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textTertiary,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
