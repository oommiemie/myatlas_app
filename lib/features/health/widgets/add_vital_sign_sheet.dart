import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/app_option_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/liquid_glass_button.dart';
import '../../../core/widgets/press_effect.dart';

/// One field on the value card (heart rate = 1 field, BP = 2 fields).
class VitalFieldConfig {
  const VitalFieldConfig({
    required this.label,
    required this.placeholder,
    required this.unit,
    this.keyboardType,
  });
  final String label;
  final String placeholder;
  final String unit;
  final TextInputType? keyboardType;
}

/// Payload returned by [showAddVitalSignSheet].
class VitalMeasurement {
  const VitalMeasurement({
    required this.values,
    required this.measuredAt,
    required this.location,
    this.note,
  });
  final List<String> values;
  final DateTime measuredAt;
  final String location;
  final String? note;
}

const _locations = [
  'บ้าน',
  'คลินิก',
  'โรงพยาบาล',
  'ที่ทำงาน',
  'อื่นๆ',
];

Future<VitalMeasurement?> showAddVitalSignSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color color,
  required List<VitalFieldConfig> fields,
}) {
  return Navigator.of(context, rootNavigator: true).push<VitalMeasurement>(
    PageRouteBuilder<VitalMeasurement>(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      barrierLabel: 'add-vital',
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, _, __) => _AddVitalSignSheet(
        title: title,
        icon: icon,
        color: color,
        fields: fields,
      ),
      transitionsBuilder: (ctx, anim, sec, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: child);
      },
    ),
  );
}

class _AddVitalSignSheet extends StatefulWidget {
  const _AddVitalSignSheet({
    required this.title,
    required this.icon,
    required this.color,
    required this.fields,
  });
  final String title;
  final IconData icon;
  final Color color;
  final List<VitalFieldConfig> fields;

  @override
  State<_AddVitalSignSheet> createState() => _AddVitalSignSheetState();
}

class _AddVitalSignSheetState extends State<_AddVitalSignSheet> {
  late final List<TextEditingController> _valueCtrls;
  late final TextEditingController _noteCtrl;
  DateTime _measuredAt = DateTime.now();
  String _location = _locations.first;

  @override
  void initState() {
    super.initState();
    _valueCtrls = [
      for (final _ in widget.fields) TextEditingController(),
    ];
    _noteCtrl = TextEditingController();
    for (final c in _valueCtrls) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _valueCtrls) {
      c.dispose();
    }
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _valueCtrls.every((c) => c.text.trim().isNotEmpty);

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    DateTime temp = _measuredAt;
    await showCupertinoModalPopup<void>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(38),
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.35),
                  width: 0.5,
                ),
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          LiquidGlassButton(
                            icon: CupertinoIcons.xmark,
                            iconColor: const Color(0xFF1A1A1A),
                            onTap: () => Navigator.of(ctx).pop(),
                          ),
                          const Expanded(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Text(
                                  'เลือกวันและเวลา',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          LiquidGlassButton(
                            icon: CupertinoIcons.check_mark,
                            iconColor: CupertinoColors.white,
                            tint: const Color(0xFF1D8B6B),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              setState(() => _measuredAt = temp);
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SizedBox(
                          height: 220,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.dateAndTime,
                            initialDateTime: _measuredAt,
                            maximumDate: DateTime.now(),
                            use24hFormat: true,
                            onDateTimeChanged: (d) => temp = d,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final v = await showAppOptionSheet(
      context: context,
      title: 'สถานที่วัด',
      selected: _location,
      options: _locations,
    );
    if (v != null) setState(() => _location = v);
  }

  void _save() {
    if (!_canSave) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      VitalMeasurement(
        values: _valueCtrls.map((c) => c.text.trim()).toList(),
        measuredAt: _measuredAt,
        location: _location,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  String _fmtDateTime(DateTime d) {
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year + 543}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      resizeToAvoidBottomInset: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: EdgeInsets.only(top: topInset + 10),
          child: ClipRRect(
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: SizedBox(
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: LiquidGlassButton(
                                icon: CupertinoIcons.xmark,
                                iconColor: const Color(0xFF1A1A1A),
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: LiquidGlassButton(
                                icon: CupertinoIcons.check_mark,
                                iconColor: _canSave
                                    ? CupertinoColors.white
                                    : const Color(0xFFBDBDBD),
                                tint: _canSave
                                    ? const Color(0xFF1D8B6B)
                                    : null,
                                onTap: _canSave ? _save : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                            16, 8, 16, 32 + bottomInset),
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.color,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      widget.color.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              color: CupertinoColors.white,
                              size: 34,
                            ),
                          ).padTopCenter(0),
                          const SizedBox(height: 20),
                          _Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0;
                                    i < widget.fields.length;
                                    i++) ...[
                                  if (i > 0) const SizedBox(height: 14),
                                  _Label(widget.fields[i].label),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    controller: _valueCtrls[i],
                                    placeholder: widget.fields[i].placeholder,
                                    keyboardType:
                                        widget.fields[i].keyboardType ??
                                            TextInputType.number,
                                    unit: widget.fields[i].unit,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Card(
                            child: Column(
                              children: [
                                _MetaRow(
                                  icon: CupertinoIcons.calendar,
                                  iconColor: const Color(0xFF0BA5EC),
                                  label: 'วันและเวลา',
                                  value: _fmtDateTime(_measuredAt),
                                  onTap: _pickDate,
                                ),
                                const _RowDivider(),
                                _MetaRow(
                                  icon: CupertinoIcons.location_solid,
                                  iconColor: const Color(0xFF1D8B6B),
                                  label: 'สถานที่วัด',
                                  value: _location,
                                  onTap: _pickLocation,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Label('บันทึก (ไม่บังคับ)'),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: _noteCtrl,
                                  placeholder: 'ระบุรายละเอียดเพิ่มเติม',
                                  maxLines: 3,
                                  minLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6D756E),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.99,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6D756E),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              CupertinoIcons.chevron_right,
              size: 12,
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: const Color(0xFFEDEDF0));
}

extension on Widget {
  Widget padTopCenter(double top) =>
      Padding(padding: EdgeInsets.only(top: top), child: Center(child: this));
}
