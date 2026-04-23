import 'dart:ui';

import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter/material.dart';

enum DatePickerRange { today, week, month }

Future<DateTime?> showDatePickerBottomSheet(
  BuildContext context, {
  required DateTime selected,
  Set<DateTime> markedDates = const {},
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => DatePickerBottomSheet(
      selected: selected,
      markedDates: markedDates,
    ),
  );
}

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime selected;
  final Set<DateTime> markedDates;

  const DatePickerBottomSheet({
    super.key,
    required this.selected,
    this.markedDates = const {},
  });

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  static const _accent = Color(0xFF0485F7);
  static const _textPrimary = Color(0xFF18181B);
  static const _textMuted = Color(0xFF71717A);
  static const _indicatorDot = Color(0xFF4CA30D);

  late DateTime _displayedMonth;
  late DateTime _selected;
  DatePickerRange _range = DatePickerRange.month;

  @override
  void initState() {
    super.initState();
    _selected = DateTime(widget.selected.year, widget.selected.month, widget.selected.day);
    _displayedMonth = DateTime(_selected.year, _selected.month);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(38)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FA).withValues(alpha: 0.92),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(38)),
            border: Border(
              top: BorderSide(
                color: CupertinoColors.white.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DragHandle(),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildCalendar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RangeSegmented(
            value: _range,
            onChanged: (r) {
              setState(() => _range = r);
              if (r == DatePickerRange.today) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                Navigator.of(context).pop(today);
              }
            },
          ),
          const SizedBox(height: 12),
          _MonthHeader(
            month: _displayedMonth,
            onPrev: () => setState(() {
              _displayedMonth = DateTime(
                _displayedMonth.year,
                _displayedMonth.month - 1,
              );
            }),
            onNext: () => setState(() {
              _displayedMonth = DateTime(
                _displayedMonth.year,
                _displayedMonth.month + 1,
              );
            }),
          ),
          const SizedBox(height: 8),
          const _WeekDayHeaders(),
          const SizedBox(height: 4),
          _DateGrid(
            displayedMonth: _displayedMonth,
            selected: _selected,
            marked: widget.markedDates,
            accentColor: _accent,
            mutedColor: _textMuted,
            primaryColor: _textPrimary,
            indicatorColor: _indicatorDot,
            onTap: (d) {
              Navigator.of(context).pop(d);
            },
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFE4E4E7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _RangeSegmented extends StatelessWidget {
  final DatePickerRange value;
  final ValueChanged<DatePickerRange> onChanged;

  const _RangeSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _segment('Today', DatePickerRange.today),
          const _SegmentDivider(),
          _segment('Week', DatePickerRange.week),
          const _SegmentDivider(),
          _segment('Month', DatePickerRange.month),
        ],
      ),
    );
  }

  Widget _segment(String label, DatePickerRange r) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(r),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF18181B),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentDivider extends StatelessWidget {
  const _SegmentDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      color: Colors.black.withValues(alpha: 0.12),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavButton(icon: Icons.chevron_left, onTap: onPrev),
        Expanded(
          child: Text(
            '${_monthNames[month.month - 1]} ${month.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF18181B),
            ),
          ),
        ),
        _NavButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 22, color: const Color(0xFF0485F7)),
      ),
    );
  }
}

class _WeekDayHeaders extends StatelessWidget {
  const _WeekDayHeaders();

  static const _names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final name in _names)
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF71717A),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DateGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime selected;
  final Set<DateTime> marked;
  final Color accentColor;
  final Color mutedColor;
  final Color primaryColor;
  final Color indicatorColor;
  final ValueChanged<DateTime> onTap;

  const _DateGrid({
    required this.displayedMonth,
    required this.selected,
    required this.marked,
    required this.accentColor,
    required this.mutedColor,
    required this.primaryColor,
    required this.indicatorColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final offset = firstOfMonth.weekday % 7;
    final startDate = firstOfMonth.subtract(Duration(days: offset));

    return Column(
      children: [
        for (int week = 0; week < 6; week++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                for (int dow = 0; dow < 7; dow++)
                  Expanded(
                    child: _buildCell(
                      startDate.add(Duration(days: week * 7 + dow)),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCell(DateTime date) {
    final isOutsideMonth = date.month != displayedMonth.month;
    final isSelected = date.year == selected.year &&
        date.month == selected.month &&
        date.day == selected.day;
    final isMarked = marked.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);

    final Color textColor =
        isSelected ? Colors.white : (isOutsideMonth ? mutedColor : primaryColor);
    final Color? bgColor = isSelected ? accentColor : null;
    final double opacity = isOutsideMonth ? 0.5 : 1.0;
    final Color dotColor = isSelected ? Colors.white : indicatorColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(date),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (bgColor != null)
                  Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                if (isMarked)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: dotColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
