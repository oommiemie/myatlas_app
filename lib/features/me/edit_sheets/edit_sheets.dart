import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/press_effect.dart';
import 'edit_sheet_scaffold.dart';

/// Text-input sheet (name / phone / email).
Future<String?> showEditTextSheet(
  BuildContext context, {
  required String title,
  required String fieldLabel,
  required Color iconColor,
  required IconData icon,
  required String initialValue,
  TextInputType keyboardType = TextInputType.text,
  int? maxLength,
}) {
  return showEditSheet<String>(context, (_) {
    return _EditTextSheet(
      title: title,
      fieldLabel: fieldLabel,
      iconColor: iconColor,
      icon: icon,
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLength: maxLength,
    );
  });
}

class _EditTextSheet extends StatefulWidget {
  const _EditTextSheet({
    required this.title,
    required this.fieldLabel,
    required this.iconColor,
    required this.icon,
    required this.initialValue,
    required this.keyboardType,
    required this.maxLength,
  });
  final String title;
  final String fieldLabel;
  final Color iconColor;
  final IconData icon;
  final String initialValue;
  final TextInputType keyboardType;
  final int? maxLength;

  @override
  State<_EditTextSheet> createState() => _EditTextSheetState();
}

class _EditTextSheetState extends State<_EditTextSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _canSave {
    final t = _ctrl.text.trim();
    return t.isNotEmpty && t != widget.initialValue.trim();
  }

  @override
  Widget build(BuildContext context) {
    return EditSheetScaffold(
      title: widget.title,
      iconColor: widget.iconColor,
      icon: widget.icon,
      onSave: _canSave
          ? () => Navigator.of(context).pop(_ctrl.text.trim())
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.fieldLabel,
            style: const TextStyle(
              color: Color(0xFF6D756E),
              fontSize: 12,
              letterSpacing: 0.275,
            ),
          ),
          const SizedBox(height: 6),
          AppTextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
          ),
        ],
      ),
    );
  }
}

/// Date-picker sheet for birth date.
Future<DateTime?> showEditDateSheet(
  BuildContext context, {
  required String title,
  required String fieldLabel,
  required Color iconColor,
  required IconData icon,
  required DateTime initialValue,
}) {
  return showEditSheet<DateTime>(context, (_) {
    return _EditDateSheet(
      title: title,
      fieldLabel: fieldLabel,
      iconColor: iconColor,
      icon: icon,
      initialValue: initialValue,
    );
  });
}

class _EditDateSheet extends StatefulWidget {
  const _EditDateSheet({
    required this.title,
    required this.fieldLabel,
    required this.iconColor,
    required this.icon,
    required this.initialValue,
  });
  final String title;
  final String fieldLabel;
  final Color iconColor;
  final IconData icon;
  final DateTime initialValue;

  @override
  State<_EditDateSheet> createState() => _EditDateSheetState();
}

class _EditDateSheetState extends State<_EditDateSheet> {
  late DateTime _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  static const _thaiMonths = [
    'ม.ค',
    'ก.พ',
    'มี.ค',
    'เม.ย',
    'พ.ค',
    'มิ.ย',
    'ก.ค',
    'ส.ค',
    'ก.ย',
    'ต.ค',
    'พ.ย',
    'ธ.ค',
  ];

  String _formatThai(DateTime d) {
    final buddhistYear = d.year + 543;
    return '${d.day} ${_thaiMonths[d.month - 1]} $buddhistYear';
  }

  bool get _canSave {
    final a = _value;
    final b = widget.initialValue;
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  @override
  Widget build(BuildContext context) {
    return EditSheetScaffold(
      title: widget.title,
      iconColor: widget.iconColor,
      icon: widget.icon,
      onSave:
          _canSave ? () => Navigator.of(context).pop(_value) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.fieldLabel,
            style: const TextStyle(
              color: Color(0xFF6D756E),
              fontSize: 12,
              letterSpacing: 0.275,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color(0xFFE5E5E5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatThai(_value),
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.calendar,
                  color: Color(0xFF6D756E),
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _IosCalendar(
              initialDate: _value,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onChanged: (d) => setState(() => _value = d),
            ),
          ),
        ],
      ),
    );
  }
}

class RadioChoice {
  const RadioChoice({
    required this.value,
    required this.label,
    required this.iconColor,
    this.icon,
  });
  final String value;
  final String label;
  final Color iconColor;
  final IconData? icon;
}

/// Radio-list sheet (blood / gender / status).
Future<String?> showEditRadioSheet(
  BuildContext context, {
  required String title,
  required String description,
  required Color iconColor,
  required IconData icon,
  required List<RadioChoice> options,
  required String initialValue,
}) {
  return showEditSheet<String>(context, (_) {
    return _EditRadioSheet(
      title: title,
      description: description,
      iconColor: iconColor,
      icon: icon,
      options: options,
      initialValue: initialValue,
    );
  });
}

class _EditRadioSheet extends StatefulWidget {
  const _EditRadioSheet({
    required this.title,
    required this.description,
    required this.iconColor,
    required this.icon,
    required this.options,
    required this.initialValue,
  });
  final String title;
  final String description;
  final Color iconColor;
  final IconData icon;
  final List<RadioChoice> options;
  final String initialValue;

  @override
  State<_EditRadioSheet> createState() => _EditRadioSheetState();
}

class _EditRadioSheetState extends State<_EditRadioSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  bool get _canSave => _selected != widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return EditSheetScaffold(
      title: widget.title,
      iconColor: widget.iconColor,
      icon: widget.icon,
      onSave: _canSave
          ? () => Navigator.of(context).pop(_selected)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              widget.description,
              style: const TextStyle(
                color: Color(0xFF6D756E),
                fontSize: 12,
                letterSpacing: 0.275,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < widget.options.length; i++) ...[
                  _RadioRow(
                    choice: widget.options[i],
                    selected: widget.options[i].value == _selected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = widget.options[i].value);
                    },
                  ),
                  if (i != widget.options.length - 1)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 60),
                      color: const Color(0xFFE5E5E5),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.choice,
    required this.selected,
    required this.onTap,
  });
  final RadioChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: choice.iconColor,
              ),
              alignment: Alignment.center,
              child: Icon(
                choice.icon ?? CupertinoIcons.drop_fill,
                color: CupertinoColors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                choice.label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.275,
                ),
              ),
            ),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF17C964) : const Color(0xFFF4F4F5),
        border: Border.all(
          color: selected
              ? const Color(0xFF17C964)
              : const Color(0xFFD4D4D8),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white,
              ),
            )
          : null,
    );
  }
}

// ─── iOS-style calendar ───────────────────────────────────────────────────

class _IosCalendar extends StatefulWidget {
  const _IosCalendar({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  @override
  State<_IosCalendar> createState() => _IosCalendarState();
}

class _IosCalendarState extends State<_IosCalendar> {
  late DateTime _selected;
  late DateTime _visibleMonth;
  bool _yearMode = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _visibleMonth =
        DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  static const _months = <String>[
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];
  static const _weekdays = <String>['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _canPrev {
    final prev = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    return !prev.isBefore(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  bool get _canNext {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    return !next.isAfter(
      DateTime(widget.lastDate.year, widget.lastDate.month),
    );
  }

  void _changeMonth(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  List<DateTime?> _monthCells() {
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leading = first.weekday % 7; // Sunday = 0
    final lastDay =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final cells = <DateTime?>[
      for (int i = 0; i < leading; i++) null,
      for (int d = 1; d <= lastDay; d++)
        DateTime(_visibleMonth.year, _visibleMonth.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(
          title:
              '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year + 543}',
          yearMode: _yearMode,
          onToggleYear: () {
            HapticFeedback.selectionClick();
            setState(() => _yearMode = !_yearMode);
          },
          onPrev: _canPrev ? () => _changeMonth(-1) : null,
          onNext: _canNext ? () => _changeMonth(1) : null,
        ),
        const SizedBox(height: 4),
        if (_yearMode)
          _YearGrid(
            firstYear: widget.firstDate.year,
            lastYear: widget.lastDate.year,
            selectedYear: _visibleMonth.year,
            onPick: (y) {
              setState(() {
                _visibleMonth = DateTime(y, _visibleMonth.month);
                _yearMode = false;
              });
            },
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (final w in _weekdays)
                  Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: const TextStyle(
                          color: Color(0xFF6D756E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Column(
              children: [
                for (int row = 0;
                    row < _monthCells().length ~/ 7;
                    row++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        for (int col = 0; col < 7; col++) ...[
                          Expanded(
                            child: _DayCell(
                              date: _monthCells()[row * 7 + col],
                              isSelected:
                                  _monthCells()[row * 7 + col] != null &&
                                      _sameDay(
                                        _monthCells()[row * 7 + col]!,
                                        _selected,
                                      ),
                              isToday:
                                  _monthCells()[row * 7 + col] != null &&
                                      _sameDay(
                                        _monthCells()[row * 7 + col]!,
                                        today,
                                      ),
                              onTap: (d) {
                                HapticFeedback.selectionClick();
                                setState(() => _selected = d);
                                widget.onChanged(d);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.yearMode,
    required this.onToggleYear,
    required this.onPrev,
    required this.onNext,
  });
  final String title;
  final bool yearMode;
  final VoidCallback onToggleYear;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          PressEffect(
            onTap: onToggleYear,
            haptic: HapticKind.selection,
            scale: 0.96,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: yearMode
                        ? const Color(0xFF1D8B6B)
                        : const Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  yearMode
                      ? CupertinoIcons.chevron_down
                      : CupertinoIcons.chevron_forward,
                  size: 12,
                  color: const Color(0xFF1D8B6B),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (!yearMode) ...[
            _ArrowBtn(
              icon: CupertinoIcons.chevron_back,
              onTap: onPrev,
            ),
            const SizedBox(width: 4),
            _ArrowBtn(
              icon: CupertinoIcons.chevron_forward,
              onTap: onNext,
            ),
          ],
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      rippleShape: BoxShape.circle,
      scale: 0.82,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF1D8B6B) : const Color(0xFFCBD0CC),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });
  final DateTime? date;
  final bool isSelected;
  final bool isToday;
  final void Function(DateTime) onTap;

  @override
  Widget build(BuildContext context) {
    if (date == null) {
      return const SizedBox(height: 38);
    }
    Color textColor = const Color(0xFF1A1A1A);
    Color bg = const Color(0x00000000);
    if (isSelected) {
      bg = const Color(0xFF1D8B6B);
      textColor = CupertinoColors.white;
    } else if (isToday) {
      textColor = const Color(0xFF1D8B6B);
    }
    return PressEffect(
      onTap: () => onTap(date!),
      haptic: HapticKind.none,
      rippleShape: BoxShape.circle,
      scale: 0.85,
      dim: 0.9,
      child: SizedBox(
        height: 38,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bg,
            ),
            child: Text(
              '${date!.day}',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: isSelected || isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _YearGrid extends StatelessWidget {
  const _YearGrid({
    required this.firstYear,
    required this.lastYear,
    required this.selectedYear,
    required this.onPick,
  });
  final int firstYear;
  final int lastYear;
  final int selectedYear;
  final void Function(int) onPick;

  @override
  Widget build(BuildContext context) {
    final years = [
      for (int y = lastYear; y >= firstYear; y--) y,
    ];
    return SizedBox(
      height: 220,
      child: GridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.8,
        children: [
          for (final y in years)
            PressEffect(
              onTap: () => onPick(y),
              haptic: HapticKind.selection,
              scale: 0.92,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: y == selectedYear
                      ? const Color(0xFF1D8B6B)
                      : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${y + 543}',
                  style: TextStyle(
                    color: y == selectedYear
                        ? CupertinoColors.white
                        : const Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: y == selectedYear
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
