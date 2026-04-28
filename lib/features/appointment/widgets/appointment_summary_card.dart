import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppointmentSummaryCard extends StatelessWidget {
  final int soonCount;
  final int weekCount;
  final int monthCount;

  const AppointmentSummaryCard({
    super.key,
    required this.soonCount,
    required this.weekCount,
    required this.monthCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(label: 'เร็วๆนี้', count: soonCount),
      _SummaryItem(label: '1 สัปดาห์', count: weekCount),
      _SummaryItem(label: '1 เดือน', count: monthCount),
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
            fontSize: 11,
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
              const TextSpan(text: ' ', style: TextStyle(fontSize: 11)),
              const TextSpan(
                text: 'รายการ',
                style: TextStyle(
                  fontSize: 11,
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
