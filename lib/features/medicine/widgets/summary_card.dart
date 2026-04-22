import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'add_medicine_sheet.dart';

class SummaryCard extends StatelessWidget {
  final int morningCount;
  final int dayCount;
  final int eveningCount;
  final int bedtimeCount;

  const SummaryCard({
    super.key,
    required this.morningCount,
    required this.dayCount,
    required this.eveningCount,
    required this.bedtimeCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(label: 'เช้า', count: morningCount),
      _SummaryItem(label: 'กลางวัน', count: dayCount),
      _SummaryItem(label: 'เย็น', count: eveningCount),
      _SummaryItem(label: 'ก่อนนอน', count: bedtimeCount),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) ...[
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 32,
                color: AppColors.borderDefault,
              ),
              const SizedBox(width: 8),
            ],
          ],
          const Spacer(),
          Builder(
            builder: (context) => _LiquidGlassButton(
              onTap: () => showAddMedicineSheet(context),
              child: const Icon(Icons.add, size: 20, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final int count;

  const _SummaryItem({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.textPrimary),
            children: [
              TextSpan(
                text: '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(text: ' ', style: TextStyle(fontSize: 10)),
              const TextSpan(
                text: 'รายการ',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiquidGlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _LiquidGlassButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(296),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
