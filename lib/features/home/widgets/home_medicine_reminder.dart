import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';

class MedicineReminder {
  final String mealLabel;
  final String time;
  final String name;
  final String description;
  final String? foodTiming;

  const MedicineReminder({
    required this.mealLabel,
    required this.time,
    required this.name,
    required this.description,
    this.foodTiming,
  });

  _ReminderTheme get theme {
    switch (mealLabel) {
      case 'มื้อกลางวัน':
        return const _ReminderTheme(
          bg: Color(0xFFFF9C66),
          deco: 'assets/svg/reminder_decoration_noon.svg',
        );
      case 'มื้อเย็น':
        return const _ReminderTheme(
          bg: Color(0xFFA597C1),
          deco: 'assets/svg/reminder_decoration_evening.svg',
        );
      case 'ก่อนนอน':
        return const _ReminderTheme(
          bg: Color(0xFF0B4A6F),
          deco: 'assets/svg/reminder_decoration_bedtime.svg',
          displayLabel: 'วันที่ปัจจุบัน',
        );
      default:
        return const _ReminderTheme(
          bg: Color(0xFF7CD4FD),
          deco: 'assets/svg/reminder_decoration.svg',
        );
    }
  }
}

class _ReminderTheme {
  final Color bg;
  final String deco;
  final String? displayLabel;

  const _ReminderTheme({
    required this.bg,
    required this.deco,
    this.displayLabel,
  });
}

class HomeMedicineReminder extends StatefulWidget {
  final List<MedicineReminder> reminders;

  const HomeMedicineReminder({super.key, required this.reminders});

  @override
  State<HomeMedicineReminder> createState() => _HomeMedicineReminderState();
}

class _HomeMedicineReminderState extends State<HomeMedicineReminder> {
  late List<bool> _taken;

  @override
  void initState() {
    super.initState();
    _taken = List<bool>.filled(widget.reminders.length, false);
  }

  void _toggle(int i) {
    setState(() => _taken[i] = !_taken[i]);
    final taken = _taken[i];
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        backgroundColor:
            taken ? AppColors.success600 : AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Icon(
              taken ? Icons.check_circle : Icons.undo_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              taken ? 'บันทึกการทานยาแล้ว' : 'ยกเลิกการบันทึก',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppColors.bgPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ถึงเวลากินยา',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 163,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.reminders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _ReminderCard(
                reminder: widget.reminders[i],
                taken: _taken[i],
                onTap: () => _toggle(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final bool taken;
  final VoidCallback onTap;

  const _ReminderCard({
    required this.reminder,
    required this.taken,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = reminder.theme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 320,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.bg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                width: 165,
                height: 140,
                child: SvgPicture.asset(
                  theme.deco,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      theme.displayLabel ?? reminder.mealLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TimeChip(time: reminder.time),
                        if (reminder.foodTiming != null) ...[
                          const SizedBox(width: 8),
                          _FoodTimingChip(label: reminder.foodTiming!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _SummaryCard(reminder: reminder, taken: taken),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodTimingChip extends StatelessWidget {
  final String label;

  const _FoodTimingChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.dateChip,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xE6FFFFFF),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;

  const _TimeChip({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      decoration: BoxDecoration(
        color: AppColors.dateChip,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/icon_clock_small.svg',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xE6FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final MedicineReminder reminder;
  final bool taken;

  const _SummaryCard({required this.reminder, required this.taken});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 52,
              height: 52,
              color: const Color(0xFFE9EFEA),
              child: Image.asset(
                'assets/images/pill_bottle.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reminder.name,
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
                  reminder.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: taken
                ? SvgPicture.asset(
                    'assets/svg/icon_check_done.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.success600,
                      BlendMode.srcIn,
                    ),
                  )
                : SvgPicture.asset(
                    'assets/svg/icon_dots_circle.svg',
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF3E453F),
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
