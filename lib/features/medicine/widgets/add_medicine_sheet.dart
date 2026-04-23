import 'dart:ui';

import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/thai_date.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';

enum _MealSlot { morning, day, evening, bedtime }

Future<void> showAddMedicineSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddMedicineSheet(),
  );
}

class AddMedicineSheet extends StatefulWidget {
  const AddMedicineSheet({super.key});

  @override
  State<AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<AddMedicineSheet> {
  int _step = 0;

  // Step 1 fields
  int _typeIndex = 0;
  final _nameCtrl = TextEditingController();
  final _instructionCtrl = TextEditingController();
  int _count = 0;
  final _strengthCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();

  // Step 2 fields
  final Set<int> _days = {1};
  final Set<_MealSlot> _selectedMeals = {_MealSlot.morning};
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  static const Map<_MealSlot, TimeOfDay> _mealDefaultTimes = {
    _MealSlot.morning: TimeOfDay(hour: 6, minute: 20),
    _MealSlot.day: TimeOfDay(hour: 12, minute: 0),
    _MealSlot.evening: TimeOfDay(hour: 19, minute: 0),
    _MealSlot.bedtime: TimeOfDay(hour: 22, minute: 0),
  };

  static const _types = ['ยาน้ำ', 'ยาเม็ด', 'แคปซูล', 'ยาฉีด'];

  static const _stepButtons = ['ถัดไป', 'สรุปการบันทึกยา', 'บันทึก'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instructionCtrl.dispose();
    _strengthCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _onTypeChanged(int i) {
    setState(() => _typeIndex = i);
  }

  void _toggleMeal(_MealSlot slot) {
    setState(() {
      if (_selectedMeals.contains(slot)) {
        _selectedMeals.remove(slot);
      } else {
        _selectedMeals.add(slot);
      }
    });
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _finish() {
    Navigator.of(context).pop();
    AppToast.success(context, 'บันทึกรายการยาแล้ว');
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(38)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: h * 0.92,
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
          child: Column(
        children: [
          _Header(
            showBack: _step > 0,
            onBack: _back,
            onClose: () => Navigator.of(context).pop(),
          ),
          _Stepper(currentStep: _step),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: _PrimaryButton(
              label: _stepButtons[_step],
              onTap: _next,
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _DetailsForm(
          typeIndex: _typeIndex,
          types: _types,
          nameCtrl: _nameCtrl,
          instructionCtrl: _instructionCtrl,
          count: _count,
          onCountChanged: (c) => setState(() => _count = c),
          strengthCtrl: _strengthCtrl,
          unitCtrl: _unitCtrl,
          onTypeChanged: _onTypeChanged,
        );
      case 1:
        return _ScheduleForm(
          selectedDays: _days,
          onDayToggle: (i) => setState(() {
            if (_days.contains(i)) {
              _days.remove(i);
            } else {
              _days.add(i);
            }
          }),
          selectedMeals: _selectedMeals,
          mealTimes: _mealDefaultTimes,
          onMealToggle: _toggleMeal,
          rangeStart: _rangeStart,
          rangeEnd: _rangeEnd,
          onRangeChange: (s, e) => setState(() {
            _rangeStart = s;
            _rangeEnd = e;
          }),
        );
      default:
        return _SummaryView(
          typeLabel: _types[_typeIndex],
          name: _nameCtrl.text,
          instruction: _instructionCtrl.text,
          count: _count,
          strength: _strengthCtrl.text,
          unit: _unitCtrl.text,
          days: _days,
          selectedMeals: _selectedMeals,
          mealTimes: _mealDefaultTimes,
          rangeStart: _rangeStart,
          rangeEnd: _rangeEnd,
          onEditDetails: () => setState(() => _step = 0),
          onEditSchedule: () => setState(() => _step = 1),
        );
    }
  }
}

class _Header extends StatelessWidget {
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const _Header({
    required this.showBack,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'เพิ่มรายการยา',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: _CircleButton(icon: Icons.chevron_left, onTap: onBack),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: _CircleButton(icon: Icons.close, onTap: onClose),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int currentStep;

  const _Stepper({required this.currentStep});

  static const _totalSteps = 3;
  static const _accent = Color(0xFF1D8B6B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: Row(
        children: [
          for (int i = 0; i < _totalSteps; i++) ...[
            Expanded(
              flex: i == currentStep ? 3 : 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                height: 5,
                decoration: BoxDecoration(
                  gradient: i <= currentStep
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF2CA989),
                            Color(0xFF1D8B6B),
                          ],
                        )
                      : null,
                  color: i > currentStep
                      ? _accent.withValues(alpha: 0.14)
                      : null,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: i == currentStep
                      ? [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            if (i != _totalSteps - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

/* ---------- Step 1: Details ---------- */

class _DetailsForm extends StatelessWidget {
  final int typeIndex;
  final List<String> types;
  final TextEditingController nameCtrl;
  final TextEditingController instructionCtrl;
  final int count;
  final ValueChanged<int> onCountChanged;
  final TextEditingController strengthCtrl;
  final TextEditingController unitCtrl;
  final ValueChanged<int> onTypeChanged;

  const _DetailsForm({
    required this.typeIndex,
    required this.types,
    required this.nameCtrl,
    required this.instructionCtrl,
    required this.count,
    required this.onCountChanged,
    required this.strengthCtrl,
    required this.unitCtrl,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: _EditablePhotoPlaceholder()),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: types.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _TypePill(
              label: types[i],
              selected: i == typeIndex,
              onTap: () => onTypeChanged(i),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          children: [
            const _FieldLabel('ชื่อยา'),
            _TextField(controller: nameCtrl, hint: 'ตัวอย่าง: Paracetamol'),
            const SizedBox(height: 16),
            const _FieldLabel('วิธีใช้ยา'),
            _TextField(
              controller: instructionCtrl,
              hint:
                  'ตัวอย่าง: "รับประทานครั้งละ 1 เม็ด วันละ 3 ครั้ง หลังอาหารทันที"',
              maxLines: 3,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FormSection(
          children: [
            const _FieldLabel('จำนวน'),
            _CountInput(value: count, onChanged: onCountChanged),
          ],
        ),
        const SizedBox(height: 12),
        _FormSection(
          children: [
            const _FieldLabel('ความแรงของยา'),
            _TextField(controller: strengthCtrl, hint: 'ระบุตัวเลข'),
            const SizedBox(height: 16),
            const _FieldLabel('หน่วย'),
            _TextField(controller: unitCtrl, hint: 'ระบุหน่วย'),
          ],
        ),
      ],
    );
  }
}

class _EditablePhotoPlaceholder extends StatelessWidget {
  const _EditablePhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hook: image picker would go here
      },
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFEDEFED),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.medication_outlined,
                size: 48,
                color: Color(0xFFB0B4B1),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary600,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppChoiceChip(
      label: label,
      selected: selected,
      onTap: onTap,
      showRadio: true,
    );
  }
}

class _CountInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CountInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CountButton(
          icon: Icons.remove,
          enabled: value > 0,
          bg: const Color(0xFFD9D9D9),
          onTap: () => onChanged((value - 1).clamp(0, 999)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              value == 0 ? 'ระบุจำนวน' : '$value',
              style: TextStyle(
                fontSize: 14,
                color: value == 0
                    ? const Color(0xFFB0B4B1)
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _CountButton(
          icon: Icons.add,
          enabled: true,
          bg: AppColors.primary600,
          onTap: () => onChanged((value + 1).clamp(0, 999)),
        ),
      ],
    );
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color bg;
  final VoidCallback onTap;

  const _CountButton({
    required this.icon,
    required this.enabled,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.5,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

/* ---------- Step 2: Schedule ---------- */

class _ScheduleForm extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<int> onDayToggle;
  final Set<_MealSlot> selectedMeals;
  final Map<_MealSlot, TimeOfDay> mealTimes;
  final ValueChanged<_MealSlot> onMealToggle;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final void Function(DateTime?, DateTime?) onRangeChange;

  const _ScheduleForm({
    required this.selectedDays,
    required this.onDayToggle,
    required this.selectedMeals,
    required this.mealTimes,
    required this.onMealToggle,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onRangeChange,
  });

  static const _dayLabels = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormSection(
          children: [
            const _FieldLabel('วันในสัปดาห์'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < _dayLabels.length; i++)
                  GestureDetector(
                    onTap: () => onDayToggle(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: selectedDays.contains(i)
                            ? AppColors.primary600
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: selectedDays.contains(i)
                          ? const Icon(Icons.check_circle,
                              size: 18, color: Colors.white)
                          : Text(
                              _dayLabels[i],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FormSection(
          children: [
            const _FieldLabel('ทานยาตอนไหน'),
            const SizedBox(height: 12),
            _MealTimeQuadrants(
              selectedMeals: selectedMeals,
              mealTimes: mealTimes,
              onMealToggle: onMealToggle,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FormSection(
          children: [
            const _FieldLabel('ระยะเวลา'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _RangeCalendar(
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                onRangeChange: onRangeChange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RangeCalendar extends StatefulWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final void Function(DateTime?, DateTime?) onRangeChange;

  const _RangeCalendar({
    required this.rangeStart,
    required this.rangeEnd,
    required this.onRangeChange,
  });

  @override
  State<_RangeCalendar> createState() => _RangeCalendarState();
}

class _RangeCalendarState extends State<_RangeCalendar> {
  late DateTime _month;

  static const _dayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.rangeStart?.year ?? DateTime.now().year,
        widget.rangeStart?.month ?? DateTime.now().month);
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  void _handleTap(DateTime date) {
    final d = _stripTime(date);
    final start = widget.rangeStart;
    final end = widget.rangeEnd;
    if (start == null || end != null) {
      widget.onRangeChange(d, null);
    } else {
      if (d.isBefore(start)) {
        widget.onRangeChange(d, start);
      } else if (d.isAtSameMomentAs(start)) {
        widget.onRangeChange(d, d);
      } else {
        widget.onRangeChange(start, d);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '${_monthNames[_month.month - 1]} ${_month.year}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFF0485F7), size: 18),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                _month = DateTime(_month.year, _month.month - 1);
              }),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.chevron_left,
                    color: Color(0xFF0485F7), size: 22),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                _month = DateTime(_month.year, _month.month + 1);
              }),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.chevron_right,
                    color: Color(0xFF0485F7), size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final d in _dayHeaders)
              Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        _buildGrid(),
      ],
    );
  }

  Widget _buildGrid() {
    final first = DateTime(_month.year, _month.month, 1);
    final offset = first.weekday % 7;
    final start = first.subtract(Duration(days: offset));
    return Column(
      children: [
        for (int w = 0; w < 6; w++)
          Row(
            children: [
              for (int d = 0; d < 7; d++)
                Expanded(
                  child: _buildCell(start.add(Duration(days: w * 7 + d))),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(DateTime date) {
    final outside = date.month != _month.month;
    final rs = widget.rangeStart;
    final re = widget.rangeEnd;
    final d = _stripTime(date);

    bool isStart = rs != null && d.isAtSameMomentAs(rs);
    bool isEnd = re != null && d.isAtSameMomentAs(re);
    bool isSingle = isStart && (re == null || isEnd && rs.isAtSameMomentAs(re));
    bool inRange = rs != null &&
        re != null &&
        d.isAfter(rs) &&
        d.isBefore(re);

    const bgColor = Color(0x1A0485F7);
    final bothSet = rs != null && re != null;
    final leftFilled = inRange || (isEnd && bothSet && !rs.isAtSameMomentAs(re));
    final rightFilled = inRange || (isStart && bothSet && !re.isAtSameMomentAs(rs));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(date),
      child: SizedBox(
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Range highlight split into 2 halves
            if (leftFilled || rightFilled)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 32,
                      color: leftFilled ? bgColor : Colors.transparent,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 32,
                      color: rightFilled ? bgColor : Colors.transparent,
                    ),
                  ),
                ],
              ),
            // Circle for start/end
            if (isStart || isEnd || isSingle)
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF0485F7),
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: (isStart || isEnd)
                    ? Colors.white
                    : outside
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Step 3: Summary ---------- */

class _SummaryView extends StatelessWidget {
  final String typeLabel;
  final String name;
  final String instruction;
  final int count;
  final String strength;
  final String unit;
  final Set<int> days;
  final Set<_MealSlot> selectedMeals;
  final Map<_MealSlot, TimeOfDay> mealTimes;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final VoidCallback onEditDetails;
  final VoidCallback onEditSchedule;

  const _SummaryView({
    required this.typeLabel,
    required this.name,
    required this.instruction,
    required this.count,
    required this.strength,
    required this.unit,
    required this.days,
    required this.selectedMeals,
    required this.mealTimes,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onEditDetails,
    required this.onEditSchedule,
  });

  static const _fullDayNames = [
    'อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์',
  ];

  static const _mealNames = {
    _MealSlot.morning: 'มื้อเช้า',
    _MealSlot.day: 'มื้อกลางวัน',
    _MealSlot.evening: 'มื้อเย็น',
    _MealSlot.bedtime: 'เวลานอน',
  };

  String get _daysText {
    if (days.isEmpty) return '—';
    final sorted = days.toList()..sort();
    return sorted.map((i) => _fullDayNames[i]).join(', ');
  }

  String _fmt(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String get _mealTimesText {
    if (selectedMeals.isEmpty) return '—';
    final order = [
      _MealSlot.morning,
      _MealSlot.day,
      _MealSlot.evening,
      _MealSlot.bedtime,
    ];
    return order
        .where(selectedMeals.contains)
        .map((s) => '${_mealNames[s]} ${_fmt(mealTimes[s]!)}')
        .join(', ');
  }

  String get _rangeText {
    if (rangeStart == null) return '—';
    if (rangeEnd == null) return ThaiDate.format(rangeStart!);
    return '${ThaiDate.format(rangeStart!)}  →  ${ThaiDate.format(rangeEnd!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryGroup(
          title: 'รายละเอียดยา',
          onEdit: onEditDetails,
          children: [
            _SummaryRow(label: 'ประเภทยา', value: typeLabel),
            _SummaryRow(label: 'ชื่อยา', value: name.isEmpty ? '—' : name),
            _SummaryRow(
              label: 'วิธีใช้ยา',
              value: instruction.isEmpty ? '—' : instruction,
            ),
            _SummaryRow(label: 'จำนวน', value: count == 0 ? '—' : '$count'),
            _SummaryRow(
              label: 'ความแรง',
              value: strength.isEmpty
                  ? '—'
                  : '$strength $unit'.trim(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryGroup(
          title: 'วันและเวลาทานยา',
          onEdit: onEditSchedule,
          children: [
            _SummaryRow(label: 'วันในสัปดาห์', value: _daysText),
            _SummaryRow(label: 'ทานยา', value: _mealTimesText),
            _SummaryRow(label: 'ระยะเวลา', value: _rangeText),
          ],
        ),
      ],
    );
  }
}

class _SummaryGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onEdit;

  const _SummaryGroup({
    required this.title,
    required this.children,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Row(
                  children: const [
                    Icon(Icons.edit_outlined,
                        size: 14, color: AppColors.primary600),
                    SizedBox(width: 4),
                    Text(
                      'แก้ไข',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------- Shared form primitives ---------- */

class _FormSection extends StatelessWidget {
  final List<Widget> children;

  const _FormSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      placeholder: hint,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : null,
    );
  }
}

/* ---------- Meal time quadrants ---------- */

class _MealTimeQuadrants extends StatelessWidget {
  final Set<_MealSlot> selectedMeals;
  final Map<_MealSlot, TimeOfDay> mealTimes;
  final ValueChanged<_MealSlot> onMealToggle;

  const _MealTimeQuadrants({
    required this.selectedMeals,
    required this.mealTimes,
    required this.onMealToggle,
  });

  static String _fmt(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm น.';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          final pillOffset = size * 0.05;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuadrantBg(
                              type: _MealSlot.morning,
                              selected:
                                  selectedMeals.contains(_MealSlot.morning),
                              onTap: () => onMealToggle(_MealSlot.morning),
                            ),
                          ),
                          Expanded(
                            child: _QuadrantBg(
                              type: _MealSlot.day,
                              selected: selectedMeals.contains(_MealSlot.day),
                              onTap: () => onMealToggle(_MealSlot.day),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuadrantBg(
                              type: _MealSlot.bedtime,
                              selected:
                                  selectedMeals.contains(_MealSlot.bedtime),
                              onTap: () => onMealToggle(_MealSlot.bedtime),
                            ),
                          ),
                          Expanded(
                            child: _QuadrantBg(
                              type: _MealSlot.evening,
                              selected:
                                  selectedMeals.contains(_MealSlot.evening),
                              onTap: () => onMealToggle(_MealSlot.evening),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Pills — positioned at each quadrant's center, tap to toggle
              Positioned(
                left: pillOffset,
                top: size * 0.2,
                child: _MealPill(
                  label: 'มื้อเช้า',
                  time: _fmt(mealTimes[_MealSlot.morning]!),
                  selected: selectedMeals.contains(_MealSlot.morning),
                  onTap: () => onMealToggle(_MealSlot.morning),
                ),
              ),
              Positioned(
                right: pillOffset,
                top: size * 0.2,
                child: _MealPill(
                  label: 'มื้อกลางวัน',
                  time: _fmt(mealTimes[_MealSlot.day]!),
                  selected: selectedMeals.contains(_MealSlot.day),
                  onTap: () => onMealToggle(_MealSlot.day),
                ),
              ),
              Positioned(
                left: pillOffset,
                bottom: size * 0.2,
                child: _MealPill(
                  label: 'เวลานอน',
                  time: _fmt(mealTimes[_MealSlot.bedtime]!),
                  selected: selectedMeals.contains(_MealSlot.bedtime),
                  onTap: () => onMealToggle(_MealSlot.bedtime),
                ),
              ),
              Positioned(
                right: pillOffset,
                bottom: size * 0.2,
                child: _MealPill(
                  label: 'มื้อเย็น',
                  time: _fmt(mealTimes[_MealSlot.evening]!),
                  selected: selectedMeals.contains(_MealSlot.evening),
                  onTap: () => onMealToggle(_MealSlot.evening),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuadrantBg extends StatelessWidget {
  final _MealSlot type;
  final bool selected;
  final VoidCallback onTap;

  const _QuadrantBg({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = switch (type) {
      _MealSlot.morning => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB9E6FE), Color(0xFF7CD4FD)],
          stops: [0.29, 1.0],
        ),
      _MealSlot.day => const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFD6AE), Color(0xFFFF9C66)],
        ),
      _MealSlot.evening => const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Color(0xFFC7D2FE), Color(0xFF818CF8)],
        ),
      _MealSlot.bedtime => const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFF065986), Color(0xFF0B4A6F)],
        ),
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(gradient: gradient),
        foregroundDecoration: BoxDecoration(
          color: selected ? null : Colors.white.withValues(alpha: 0.55),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            // Per Figma: glow 70 in 150 quadrant = 46.67%
            final glowSize = size.shortestSide * 0.467;
            // Per Figma: glow left = 35/150 = 23.3%
            final glowLeft = size.width * 0.233;
            // Per Figma top Y: morning=45, day=33, bedtime=23, evening=36 (out of 150)
            final glowTop = size.height *
                switch (type) {
                  _MealSlot.morning => 0.30,
                  _MealSlot.day => 0.22,
                  _MealSlot.bedtime => 0.15,
                  _MealSlot.evening => 0.24,
                };
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Stars band at top of bedtime/evening
                // Per Figma: (11, 10) 128x40 in 150 quadrant
                if (type == _MealSlot.bedtime || type == _MealSlot.evening)
                  Positioned(
                    top: size.height * 0.067,
                    left: size.width * 0.073,
                    width: size.width * 0.855,
                    height: size.height * 0.264,
                    child: SvgPicture.asset(
                      type == _MealSlot.bedtime
                          ? 'assets/svg/meal_stars_bedtime.svg'
                          : 'assets/svg/meal_stars_evening.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                Positioned(
                  left: glowLeft,
                  top: glowTop,
                  width: glowSize,
                  height: glowSize,
                  child: _SunMoonGlow(type: type),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SunMoonGlow extends StatelessWidget {
  final _MealSlot type;

  const _SunMoonGlow({required this.type});

  @override
  Widget build(BuildContext context) {
    // Per Figma: outer 70, middle 54 (pad 8), inner 34 (pad 10)
    final Color ring = switch (type) {
      _MealSlot.morning => Colors.white.withValues(alpha: 0.5),
      _MealSlot.day => const Color(0xFFFFFCDB).withValues(alpha: 0.5),
      _MealSlot.evening => const Color(0xFFE3D8F8).withValues(alpha: 0.5),
      _MealSlot.bedtime => Colors.white.withValues(alpha: 0.2),
    };
    final Color core = switch (type) {
      _MealSlot.morning => const Color(0xFFFFFDF0),
      _MealSlot.day => Colors.white,
      _MealSlot.evening => Colors.white,
      _MealSlot.bedtime => Colors.transparent,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        // Outer frame size is this widget's width (≈ 70 in Figma)
        final outer = constraints.biggest.shortestSide;
        // Padding 8 in 70 = 11.43%
        final padOuter = outer * 0.1143;
        // Padding 10 in 54 = 18.52%
        final middle = outer - padOuter * 2; // ≈ 54
        final padMiddle = middle * 0.1852;
        // Inner circle size ≈ 34
        final inner = middle - padMiddle * 2;

        return Container(
          padding: EdgeInsets.all(padOuter),
          decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
          child: Container(
            padding: EdgeInsets.all(padMiddle),
            decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
            child: Container(
              decoration: BoxDecoration(color: core, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: type == _MealSlot.bedtime
                  ? SizedBox(
                      // Moon SVG 28x30 inside inner 34x34
                      width: inner * 0.824, // 28/34
                      height: inner * 0.882, // 30/34
                      child: SvgPicture.asset(
                        'assets/svg/meal_moon_crescent.svg',
                        fit: BoxFit.contain,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _MealPill extends StatelessWidget {
  final String label;
  final String time;
  final bool selected;
  final VoidCallback onTap;

  const _MealPill({
    required this.label,
    required this.time,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0x4D000000); // black 30% (matches CSS rgba(0,0,0,0.3))
    const fg = Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: selected ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            border: selected
                ? Border.all(color: AppColors.primary600, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 12, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary600,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFCFCFC),
          ),
        ),
      ),
    );
  }
}
