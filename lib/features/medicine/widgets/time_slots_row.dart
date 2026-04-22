import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../theme/time_period.dart';

class TimeSlotsRow extends StatelessWidget {
  final TimePeriod selected;
  final ValueChanged<TimePeriod> onSelected;
  final Map<TimePeriod, bool> doneByPeriod;

  const TimeSlotsRow({
    super.key,
    required this.selected,
    required this.onSelected,
    this.doneByPeriod = const {},
  });

  static const _slots = [
    _TimeSlotData(time: '09:00', label: 'เช้า', period: TimePeriod.morning),
    _TimeSlotData(time: '12:00', label: 'กลางวัน', period: TimePeriod.day),
    _TimeSlotData(time: '18:00', label: 'เย็น', period: TimePeriod.evening),
    _TimeSlotData(time: '21:00', label: 'ก่อนนอน', period: TimePeriod.bedtime),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _slots.length; i++) ...[
          Expanded(
            child: _TimeSlotCard(
              data: _slots[i],
              isActive: _slots[i].period == selected,
              done: doneByPeriod[_slots[i].period] ?? false,
              onTap: () => onSelected(_slots[i].period),
            ),
          ),
          if (i < _slots.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _TimeSlotData {
  final String time;
  final String label;
  final TimePeriod period;

  const _TimeSlotData({
    required this.time,
    required this.label,
    required this.period,
  });
}

class _TimeSlotCard extends StatelessWidget {
  final _TimeSlotData data;
  final bool isActive;
  final bool done;
  final VoidCallback onTap;

  const _TimeSlotCard({
    required this.data,
    required this.isActive,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.primary600 : Colors.transparent,
            width: 1,
          ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _StateIcon(done: done),
            const SizedBox(height: 12),
            Text(
              data.time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  final bool done;

  const _StateIcon({required this.done});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: done
            ? SvgPicture.asset(
                'assets/svg/icon_done_check.svg',
                width: 24,
                height: 24,
              )
            : SvgPicture.asset(
                'assets/svg/icon_pending_sun.svg',
                width: 21,
                height: 21,
              ),
      ),
    );
  }
}
