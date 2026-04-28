import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/thai_date.dart';
import '../data/mock_data.dart';
import 'appointment_card.dart';

class AppointmentSection extends StatelessWidget {
  final AppointmentBucket bucket;
  final List<AppointmentItem> items;

  const AppointmentSection({
    super.key,
    required this.bucket,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final isSoon = bucket == AppointmentBucket.soon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DividerHeader(label: bucket.label),
        const SizedBox(height: 8),
        for (int i = 0; i < items.length; i++) ...[
          _DateLabel(date: items[i].date),
          const SizedBox(height: 8),
          AppointmentCard(item: items[i], isSoon: isSoon),
          if (i < items.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _DividerHeader extends StatelessWidget {
  final String label;

  const _DividerHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.borderDefault,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFA5ACA6),
              height: 20 / 10,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.borderDefault,
          ),
        ),
      ],
    );
  }
}

class _DateLabel extends StatelessWidget {
  final DateTime date;

  const _DateLabel({required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'วัน${ThaiDate.weekdayName(date)} ที่',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: date.day.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(
                text: ' ',
                style: TextStyle(fontSize: 20),
              ),
              TextSpan(
                text: '${ThaiDate.monthName(date.month)} ${date.year + 543}',
                style: const TextStyle(
                  fontSize: 12,
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
