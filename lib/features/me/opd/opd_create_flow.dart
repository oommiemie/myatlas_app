import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/liquid_glass_button.dart';
import '../../../core/widgets/press_effect.dart';
import '../../health/data/health_data.dart';
import 'opd_data.dart';

class OpdCreateFlow extends StatefulWidget {
  const OpdCreateFlow({super.key});

  @override
  State<OpdCreateFlow> createState() => _OpdCreateFlowState();
}

class _OpdCreateFlowState extends State<OpdCreateFlow> {
  final PageController _pc = PageController();
  int _step = 0;
  static const _stepsCount = 4;

  // Stage 1 — vitals (prefilled from latest health summary)
  late final TextEditingController _bp;
  late final TextEditingController _temp;
  late final TextEditingController _heartRate;
  late final TextEditingController _weight;
  late final TextEditingController _height;

  @override
  void initState() {
    super.initState();
    final hd = HealthRepository(seed: 42).load();
    final sys = hd.bloodPressure.primary;
    final dia = hd.bloodPressure.secondary;
    _bp = TextEditingController(
      text:
          '${sys.points[sys.latestIndex].value.round()}/${dia.points[dia.latestIndex].value.round()}',
    );
    final t = hd.temperature;
    _temp = TextEditingController(
      text: t.points[t.latestIndex].value.toStringAsFixed(1),
    );
    final hr = hd.heartRate;
    _heartRate = TextEditingController(
      text: hr.points[hr.latestIndex].value.round().toString(),
    );
    _weight = TextEditingController(text: hd.weightKg.toStringAsFixed(0));
    _height = TextEditingController(text: hd.heightCm.toStringAsFixed(0));
  }

  // Stage 2 — symptoms
  final Set<String> _symptoms = {};
  static const _symptomOptions = [
    'ไอ', 'น้ำมูก', 'ปวดศีรษะ', 'เป็นไข้',
    'อาเจียน', 'ท้องเสีย', 'ปวดท้อง', 'ปัสสาวะแสบขัด',
  ];
  final _chiefComplaint = TextEditingController();
  final _durationValue = TextEditingController(text: '1');
  String _durationUnit = 'วัน';
  static const _durationUnits = ['วัน', 'สัปดาห์', 'เดือน', 'ปี'];
  final Set<String> _fatherHistory = {};
  final _fatherOther = TextEditingController();
  final Set<String> _motherHistory = {};
  final _motherOther = TextEditingController();

  // Stage 3 — history & habits
  final Set<String> _chronicDiseases = {
    'เบาหวาน (Diabetes Mellitus)',
    'โรคหัวใจ (Heart Disease)',
    'ความดันโลหิตสูง',
  };
  final Set<String> _allergies = {'Penicillin', 'Aspirin', 'Ibuprofen'};
  final _surgery = TextEditingController();
  String _seizure = 'ไม่มีอาการ';
  String _smoking = 'ไม่เคยสูบ';
  String _alcohol = 'ไม่ดื่ม';
  String _exercise = 'ไม่ออกเลย';

  @override
  void dispose() {
    _pc.dispose();
    _bp.dispose();
    _temp.dispose();
    _heartRate.dispose();
    _weight.dispose();
    _height.dispose();
    _chiefComplaint.dispose();
    _durationValue.dispose();
    _fatherOther.dispose();
    _motherOther.dispose();
    _surgery.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == _stepsCount - 1) {
      _save();
      return;
    }
    HapticFeedback.selectionClick();
    _pc.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    setState(() => _step++);
  }

  void _prev() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    HapticFeedback.selectionClick();
    _pc.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    setState(() => _step--);
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    final entry = OpdEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: 'ณัฐพงษ์ ทดลอง',
      cid: '1210XXXXX1908',
      registeredAt: DateTime.now(),
      form: {
        'bp': _bp.text,
        'temp': _temp.text,
        'heart_rate': _heartRate.text,
        'weight': _weight.text,
        'height': _height.text,
        'symptoms': _symptoms.toList(),
        'chief': _chiefComplaint.text,
        'duration_value': _durationValue.text,
        'duration_unit': _durationUnit,
        'father_history': _fatherHistory.toList(),
        'mother_history': _motherHistory.toList(),
        'chronic': _chronicDiseases.toList(),
        'allergies': _allergies.toList(),
        'surgery': _surgery.text,
        'seizure': _seizure,
        'smoking': _smoking,
        'alcohol': _alcohol,
        'exercise': _exercise,
      },
    );
    if (!mounted) return;
    AppToast.success(context, 'ลงทะเบียน OPD เรียบร้อยแล้ว');
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
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
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  _Header(
                    step: _step,
                    total: _stepsCount,
                    onBack: _prev,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pc,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1(),
                        _buildStep2(),
                        _buildStep3(),
                        _buildSummary(),
                      ],
                    ),
                  ),
                  _BottomBar(
                    isLast: _step == _stepsCount - 1,
                    onTap: _next,
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

  // ─── STEP 1 — Patient info + vital signs ────────────────────────────────

  Widget _buildStep1() {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    // Bottom bar (~88) is already hidden behind the keyboard, so we only
    // need extra room equal to (keyboard - bar) to lift the last field out.
    final extra = bottomInset > 0
        ? (bottomInset - 88).clamp(0.0, double.infinity)
        : 0.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 32 + extra),
      children: [
        _InfoCard(
          rows: const [
            (
              icon: CupertinoIcons.person_crop_rectangle_fill,
              color: Color(0xFF1D8B6B),
              label: 'ชื่อ',
              value: 'ณัฐพงษ์ ทดลอง',
            ),
            (
              icon: CupertinoIcons.creditcard_fill,
              color: Color(0xFF2563EB),
              label: 'เลขประจำตัว',
              value: '1210XXXXX1908',
            ),
            (
              icon: CupertinoIcons.calendar,
              color: Color(0xFF0BA5EC),
              label: 'อายุ',
              value: '27 ปี',
            ),
            (
              icon: CupertinoIcons.person_fill,
              color: Color(0xFF38BDF8),
              label: 'เพศ',
              value: 'ชาย',
            ),
            (
              icon: CupertinoIcons.drop_fill,
              color: Color(0xFFBE123C),
              label: 'หมู่เลือด',
              value: 'AB',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _WhiteCard(
          child: Column(
            children: [
              _VitalField(
                icon: CupertinoIcons.heart_fill,
                iconColor: const Color(0xFFBE123C),
                label: 'ความดันโลหิต',
                placeholder: '120/80',
                unit: 'mmHg',
                controller: _bp,
              ),
              const SizedBox(height: 14),
              _VitalField(
                icon: CupertinoIcons.thermometer,
                iconColor: const Color(0xFF2563EB),
                label: 'อุณหภูมิ',
                placeholder: '36.5',
                unit: '°C',
                controller: _temp,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
              ),
              const SizedBox(height: 14),
              _VitalField(
                icon: CupertinoIcons.waveform_path_ecg,
                iconColor: const Color(0xFFBE123C),
                label: 'Heart Rate',
                placeholder: '72',
                unit: 'bpm',
                controller: _heartRate,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _VitalField(
                icon: CupertinoIcons.person_fill,
                iconColor: const Color(0xFF1D8B6B),
                label: 'น้ำหนัก',
                placeholder: '65',
                unit: 'kg',
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
              ),
              const SizedBox(height: 14),
              _VitalField(
                icon: CupertinoIcons.arrow_up_arrow_down,
                iconColor: const Color(0xFF1D8B6B),
                label: 'ส่วนสูง',
                placeholder: '170',
                unit: 'cm',
                controller: _height,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── STEP 2 — Symptoms, chief complaint, family ─────────────────────────

  Widget _buildStep2() {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final extra = bottomInset > 0
        ? (bottomInset - 88).clamp(0.0, double.infinity)
        : 0.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 32 + extra),
      children: [
        _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(text: 'อาการ'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _symptomOptions)
                    _ChoiceChip(
                      label: s,
                      selected: _symptoms.contains(s),
                      onTap: () => setState(() {
                        _symptoms.contains(s)
                            ? _symptoms.remove(s)
                            : _symptoms.add(s);
                      }),
                      selectedColor: const Color(0xFF2CA989),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const _FieldLabel(text: 'อาการสำคัญ'),
              const SizedBox(height: 8),
              _PillTextField(controller: _chiefComplaint),
              const SizedBox(height: 16),
              const _FieldLabel(text: 'ระยะเวลา'),
              const SizedBox(height: 8),
              _DurationField(
                controller: _durationValue,
                unit: _durationUnit,
                units: _durationUnits,
                onUnitChanged: (v) => setState(() => _durationUnit = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FamilyHistoryCard(
          title: 'ประวัติครอบครัว(บิดา)',
          accent: const Color(0xFF0BA5EC),
          history: _fatherHistory,
          other: _fatherOther,
          onChange: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _FamilyHistoryCard(
          title: 'ประวัติครอบครัว(มารดา)',
          accent: const Color(0xFF9333EA),
          history: _motherHistory,
          other: _motherOther,
          onChange: () => setState(() {}),
        ),
      ],
    );
  }

  // ─── STEP 3 — Chronic / Allergy / Habits ────────────────────────────────

  Widget _buildStep3() {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final extra = bottomInset > 0
        ? (bottomInset - 88).clamp(0.0, double.infinity)
        : 0.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 32 + extra),
      children: [
        _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabelRow(
                text: 'โรคประจำตัว',
                onAdd: () => _addChip(
                  title: 'เพิ่มโรคประจำตัว',
                  target: _chronicDiseases,
                ),
              ),
              const SizedBox(height: 8),
              _DangerChips(
                items: _chronicDiseases,
                onRemove: (v) =>
                    setState(() => _chronicDiseases.remove(v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabelRow(
                text: 'แพ้ยา',
                onAdd: () => _addChip(
                  title: 'เพิ่มการแพ้ยา',
                  target: _allergies,
                ),
              ),
              const SizedBox(height: 8),
              _DangerChips(
                items: _allergies,
                onRemove: (v) => setState(() => _allergies.remove(v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(text: 'ผ่าตัด'),
              const SizedBox(height: 8),
              _PillTextField(controller: _surgery),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(text: 'อาการชัก'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final v in ['มีอาการ', 'ไม่มีอาการ'])
                    _ChoiceChip(
                      label: v,
                      selected: _seizure == v,
                      onTap: () => setState(() => _seizure = v),
                      selectedColor: const Color(0xFF2CA989),
                      showRadio: true,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const _FieldLabel(text: 'การสูบบุหรี่'),
              const SizedBox(height: 8),
              _DropdownField(
                title: 'การสูบบุหรี่',
                value: _smoking,
                options: const [
                  'ไม่เคยสูบ',
                  'เคยสูบแต่เลิกแล้ว',
                  'สูบเป็นครั้งคราว (< 1 มวน/วัน)',
                  'สูบ 1-10 มวน/วัน',
                  'สูบ 11-20 มวน/วัน',
                  'สูบมากกว่า 20 มวน/วัน',
                ],
                onChanged: (v) => setState(() => _smoking = v),
              ),
              const SizedBox(height: 16),
              const _FieldLabel(text: 'ดื่มสุรา'),
              const SizedBox(height: 8),
              _DropdownField(
                title: 'ดื่มสุรา',
                value: _alcohol,
                options: const [
                  'ไม่ดื่ม',
                  'ดื่มในโอกาสพิเศษ',
                  'ดื่มบางครั้ง (1-2 ครั้ง/สัปดาห์)',
                  'ดื่มบ่อย (3-4 ครั้ง/สัปดาห์)',
                  'ดื่มเป็นประจำ (ทุกวัน)',
                ],
                onChanged: (v) => setState(() => _alcohol = v),
              ),
              const SizedBox(height: 16),
              const _FieldLabel(text: 'การออกกำลังกาย'),
              const SizedBox(height: 8),
              _DropdownField(
                title: 'การออกกำลังกาย',
                value: _exercise,
                options: const [
                  'ไม่ออกเลย',
                  'บางครั้ง (1-2 ครั้ง/สัปดาห์)',
                  'ประจำ (3-5 ครั้ง/สัปดาห์)',
                  'ทุกวัน',
                ],
                onChanged: (v) => setState(() => _exercise = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addChip({
    required String title,
    required Set<String> target,
  }) async {
    final controller = TextEditingController();
    final v = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (v != null && v.isNotEmpty) {
      setState(() => target.add(v));
    }
  }

  // ─── STEP 4 — Summary ───────────────────────────────────────────────────

  Widget _buildSummary() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        const _SummaryHeader(),
        const SizedBox(height: 16),
        const _InfoCard(
          rows: [
            (
              icon: CupertinoIcons.person_crop_rectangle_fill,
              color: Color(0xFF1D8B6B),
              label: 'ชื่อ',
              value: 'ณัฐพงษ์ ทดลอง',
            ),
            (
              icon: CupertinoIcons.creditcard_fill,
              color: Color(0xFF2563EB),
              label: 'เลขประจำตัว',
              value: '1210XXXXX1908',
            ),
            (
              icon: CupertinoIcons.calendar,
              color: Color(0xFF0BA5EC),
              label: 'อายุ',
              value: '27 ปี',
            ),
            (
              icon: CupertinoIcons.person_fill,
              color: Color(0xFF38BDF8),
              label: 'เพศ',
              value: 'ชาย',
            ),
            (
              icon: CupertinoIcons.drop_fill,
              color: Color(0xFFBE123C),
              label: 'หมู่เลือด',
              value: 'AB',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          icon: CupertinoIcons.heart_fill,
          iconColor: const Color(0xFFBE123C),
          title: 'Vital Signs',
          child: _VitalGrid(
            items: [
              (
                icon: CupertinoIcons.heart_fill,
                color: const Color(0xFFBE123C),
                label: 'ความดันโลหิต',
                value: _bp.text.isEmpty ? '-' : _bp.text,
                unit: 'mmHg',
              ),
              (
                icon: CupertinoIcons.thermometer,
                color: const Color(0xFF2563EB),
                label: 'อุณหภูมิ',
                value: _temp.text.isEmpty ? '-' : _temp.text,
                unit: '°C',
              ),
              (
                icon: CupertinoIcons.waveform_path_ecg,
                color: const Color(0xFFBE123C),
                label: 'Heart Rate',
                value: _heartRate.text.isEmpty ? '-' : _heartRate.text,
                unit: 'bpm',
              ),
              (
                icon: CupertinoIcons.person_fill,
                color: const Color(0xFF1D8B6B),
                label: 'น้ำหนัก',
                value: _weight.text.isEmpty ? '-' : _weight.text,
                unit: 'kg',
              ),
              (
                icon: CupertinoIcons.arrow_up_arrow_down,
                color: const Color(0xFF1D8B6B),
                label: 'ส่วนสูง',
                value: _height.text.isEmpty ? '-' : _height.text,
                unit: 'cm',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: CupertinoIcons.bandage_fill,
          iconColor: const Color(0xFF2CA989),
          title: 'อาการ',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryLabel('อาการที่พบ'),
              const SizedBox(height: 8),
              if (_symptoms.isEmpty)
                const _EmptyText()
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in _symptoms)
                      _SummaryChip(
                        label: s,
                        color: const Color(0xFF2CA989),
                      ),
                  ],
                ),
              const SizedBox(height: 14),
              _SummaryLabel('อาการสำคัญ'),
              const SizedBox(height: 6),
              Text(
                _chiefComplaint.text.isEmpty ? '-' : _chiefComplaint.text,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              _SummaryLabel('ระยะเวลา'),
              const SizedBox(height: 6),
              _DurationBadge(
                value: _durationValue.text,
                unit: _durationUnit,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: CupertinoIcons.group_solid,
          iconColor: const Color(0xFF9333EA),
          title: 'ประวัติครอบครัว',
          child: Column(
            children: [
              _FamilyLine(
                label: 'บิดา',
                accent: const Color(0xFF0BA5EC),
                history: _fatherHistory,
                other: _fatherOther.text,
              ),
              const SizedBox(height: 10),
              _FamilyLine(
                label: 'มารดา',
                accent: const Color(0xFF9333EA),
                history: _motherHistory,
                other: _motherOther.text,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: CupertinoIcons.heart_circle_fill,
          iconColor: const Color(0xFFE62E05),
          title: 'ประวัติสุขภาพ',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryLabel('โรคประจำตัว'),
              const SizedBox(height: 8),
              if (_chronicDiseases.isEmpty)
                const _EmptyText()
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in _chronicDiseases)
                      _SummaryChip(
                        label: s,
                        color: const Color(0xFFE62E05),
                      ),
                  ],
                ),
              const SizedBox(height: 14),
              _SummaryLabel('แพ้ยา'),
              const SizedBox(height: 8),
              if (_allergies.isEmpty)
                const _EmptyText()
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in _allergies)
                      _SummaryChip(
                        label: s,
                        color: const Color(0xFFD97706),
                      ),
                  ],
                ),
              const SizedBox(height: 14),
              _SummaryLabel('ผ่าตัด'),
              const SizedBox(height: 6),
              Text(
                _surgery.text.isEmpty ? '-' : _surgery.text,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: CupertinoIcons.heart_slash_fill,
          iconColor: const Color(0xFFEA580C),
          title: 'พฤติกรรม',
          child: Column(
            children: [
              _BehaviorRow(
                icon: CupertinoIcons.bolt_fill,
                color: const Color(0xFFF59E0B),
                label: 'อาการชัก',
                value: _seizure,
              ),
              const _BehaviorDivider(),
              _BehaviorRow(
                icon: CupertinoIcons.smoke_fill,
                color: const Color(0xFF6D756E),
                label: 'การสูบบุหรี่',
                value: _smoking,
              ),
              const _BehaviorDivider(),
              _BehaviorRow(
                icon: CupertinoIcons.drop_fill,
                color: const Color(0xFF8B5CF6),
                label: 'ดื่มสุรา',
                value: _alcohol,
              ),
              const _BehaviorDivider(),
              _BehaviorRow(
                icon: CupertinoIcons.sportscourt_fill,
                color: const Color(0xFF1D8B6B),
                label: 'การออกกำลังกาย',
                value: _exercise,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Sub widgets ──────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.total,
    required this.onBack,
    required this.onClose,
  });
  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onClose;

  static const _accent = Color(0xFF1D8B6B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'คัดกรองด้วยตนเอง',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                if (step > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LiquidGlassButton(
                      icon: CupertinoIcons.chevron_back,
                      onTap: onBack,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.xmark,
                    onTap: onClose,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              children: [
                for (int i = 0; i < total; i++) ...[
                  Expanded(
                    flex: i == step ? 3 : 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: i <= step
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF2CA989),
                                  Color(0xFF1D8B6B),
                                ],
                              )
                            : null,
                        color: i > step
                            ? _accent.withValues(alpha: 0.14)
                            : null,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: i == step
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
                  if (i != total - 1) const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.isLast, required this.onTap});
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: PressEffect(
        onTap: onTap,
        haptic: HapticKind.medium,
        scale: 0.97,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1D8B6B),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D8B6B).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            isLast ? 'บันทึก' : 'ถัดไป',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<
      ({IconData icon, Color color, String label, String value})> rows;

  String _field(String label) =>
      rows.firstWhere((r) => r.label == label, orElse: () => _missing).value;

  static const _missing = (
    icon: CupertinoIcons.question,
    color: Color(0xFF6D756E),
    label: '',
    value: '-',
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0891B2), Color(0xFF0369A1)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0369A1).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative curved stripe
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: hospital-style brand row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          CupertinoIcons.heart_fill,
                          size: 10,
                          color: CupertinoColors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'MyAtlas · OPD',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'บัตรประจำตัว',
                    style: TextStyle(
                      color: CupertinoColors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Photo + name
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: CupertinoColors.white.withValues(alpha: 0.55),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      color: CupertinoColors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _field('ชื่อ'),
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'CID ${_field('เลขประจำตัว')}',
                          style: TextStyle(
                            color: CupertinoColors.white
                                .withValues(alpha: 0.75),
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: CupertinoColors.white.withValues(alpha: 0.18),
              ),
              const SizedBox(height: 12),
              // Mini grid stats
              Row(
                children: [
                  Expanded(
                    child: _IdCardStat(
                      icon: CupertinoIcons.calendar,
                      label: 'อายุ',
                      value: _field('อายุ'),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: CupertinoColors.white.withValues(alpha: 0.18),
                  ),
                  Expanded(
                    child: _IdCardStat(
                      icon: CupertinoIcons.person_fill,
                      label: 'เพศ',
                      value: _field('เพศ'),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: CupertinoColors.white.withValues(alpha: 0.18),
                  ),
                  Expanded(
                    child: _IdCardStat(
                      icon: CupertinoIcons.drop_fill,
                      label: 'หมู่เลือด',
                      value: _field('หมู่เลือด'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdCardStat extends StatelessWidget {
  const _IdCardStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 10,
              color: CupertinoColors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: CupertinoColors.white.withValues(alpha: 0.75),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6D756E),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.275,
        ),
      );
}

class _FieldLabelRow extends StatelessWidget {
  const _FieldLabelRow({required this.text, required this.onAdd});
  final String text;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _FieldLabel(text: text)),
        LiquidGlassButton(
          icon: CupertinoIcons.plus,
          onTap: onAdd,
          iconColor: const Color(0xFF1D8B6B),
          size: 32,
          iconSize: 14,
        ),
      ],
    );
  }
}

class _VitalField extends StatefulWidget {
  const _VitalField({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.keyboardType,
    this.unit,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? unit;

  @override
  State<_VitalField> createState() => _VitalFieldState();
}

class _VitalFieldState extends State<_VitalField> {
  late final FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (_focus.hasFocus != _focused) {
      setState(() => _focused = _focus.hasFocus);
    }
    if (_focus.hasFocus) {
      // Wait for keyboard to open so viewInsets updates, then scroll
      // the field above the keyboard.
      Future.delayed(const Duration(milliseconds: 280), () {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0.2,
        );
      });
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_handleFocus);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.iconColor,
              ),
              alignment: Alignment.center,
              child:
                  Icon(widget.icon, size: 11, color: CupertinoColors.white),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          padding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focused
                  ? const Color(0xFF1D8B6B)
                  : const Color(0xFFE5E5E5),
              width: _focused ? 1.5 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: const Color(0xFF1D8B6B).withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  placeholder: widget.placeholder,
                  keyboardType: widget.keyboardType,
                  placeholderStyle: const TextStyle(
                    color: Color(0xFFA5ACA6),
                    fontSize: 16,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  padding: EdgeInsets.zero,
                  decoration: const BoxDecoration(),
                ),
              ),
              if (widget.unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6),
                  child: Text(
                    widget.unit!,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PillTextField extends StatefulWidget {
  const _PillTextField({
    required this.controller,
    this.placeholder = '',
    this.keyboardType,
  });
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;

  @override
  State<_PillTextField> createState() => _PillTextFieldState();
}

class _PillTextFieldState extends State<_PillTextField> {
  late final FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (_focus.hasFocus != _focused) {
      setState(() => _focused = _focus.hasFocus);
    }
    if (_focus.hasFocus) {
      Future.delayed(const Duration(milliseconds: 280), () {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0.2,
        );
      });
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_handleFocus);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(
          color: _focused
              ? const Color(0xFF1D8B6B)
              : const Color(0xFFE5E5E5),
          width: _focused ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: const Color(0xFF1D8B6B).withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: CupertinoTextField(
        controller: widget.controller,
        focusNode: _focus,
        placeholder: widget.placeholder,
        keyboardType: widget.keyboardType,
        placeholderStyle: const TextStyle(
          color: Color(0xFFA5ACA6),
          fontSize: 16,
        ),
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(),
      ),
    );
  }
}

class _DurationField extends StatefulWidget {
  const _DurationField({
    required this.controller,
    required this.unit,
    required this.units,
    required this.onUnitChanged,
  });
  final TextEditingController controller;
  final String unit;
  final List<String> units;
  final ValueChanged<String> onUnitChanged;

  @override
  State<_DurationField> createState() => _DurationFieldState();
}

class _DurationFieldState extends State<_DurationField> {
  late final FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (_focus.hasFocus != _focused) {
      setState(() => _focused = _focus.hasFocus);
    }
    if (_focus.hasFocus) {
      Future.delayed(const Duration(milliseconds: 280), () {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0.2,
        );
      });
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_handleFocus);
    _focus.dispose();
    super.dispose();
  }

  Future<void> _pickUnit() async {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    final v = await _showOptionSheet(
      context: context,
      title: 'เลือกหน่วยเวลา',
      selected: widget.unit,
      options: widget.units,
    );
    if (v != null) widget.onUnitChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 44,
      padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(
          color: _focused
              ? const Color(0xFF1D8B6B)
              : const Color(0xFFE5E5E5),
          width: _focused ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: const Color(0xFF1D8B6B).withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: widget.controller,
              focusNode: _focus,
              keyboardType: TextInputType.number,
              placeholder: '0',
              placeholderStyle: const TextStyle(
                color: Color(0xFFA5ACA6),
                fontSize: 16,
              ),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(),
            ),
          ),
          PressEffect(
            onTap: _pickUnit,
            haptic: HapticKind.none,
            scale: 0.96,
            borderRadius: BorderRadius.circular(100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 32,
              padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F4),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: Text(
                      widget.unit,
                      key: ValueKey(widget.unit),
                      style: const TextStyle(
                        color: Color(0xFF1D8B6B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    size: 12,
                    color: Color(0xFF1D8B6B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    this.showRadio = false,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final bool showRadio;

  static const _curve = Curves.easeOutCubic;
  static const _duration = Duration(milliseconds: 240);

  @override
  Widget build(BuildContext context) {
    final selectedIcon = showRadio
        ? CupertinoIcons.largecircle_fill_circle
        : CupertinoIcons.checkmark_alt;
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.94,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(selectedColor, CupertinoColors.white, 0.08)!,
                    selectedColor,
                  ],
                )
              : null,
          color: selected ? null : CupertinoColors.white,
          border: Border.all(
            color: selected
                ? selectedColor.withValues(alpha: 0)
                : const Color(0xFF1A1A1A).withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: _duration,
              curve: _curve,
              child: AnimatedSwitcher(
                duration: _duration,
                switchInCurve: _curve,
                switchOutCurve: _curve,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: selected
                    ? Padding(
                        key: const ValueKey('on'),
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white.withValues(alpha: 0.25),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            selectedIcon,
                            size: 11,
                            color: CupertinoColors.white,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('off'), width: 0),
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: _duration,
              curve: _curve,
              style: TextStyle(
                color: selected
                    ? CupertinoColors.white
                    : const Color(0xFF3E453F),
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerChips extends StatelessWidget {
  const _DangerChips({required this.items, required this.onRemove});
  final Set<String> items;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '-',
          style: TextStyle(color: Color(0xFF6D756E), fontSize: 14),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in items)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6).copyWith(
              right: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE62E05).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s,
                  style: const TextStyle(
                    color: Color(0xFFE62E05),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                PressEffect(
                  onTap: () => onRemove(s),
                  haptic: HapticKind.selection,
                  rippleShape: BoxShape.circle,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.white.withValues(alpha: 0.6),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.xmark,
                      size: 10,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: () async {
        HapticFeedback.selectionClick();
        FocusScope.of(context).unfocus();
        final v = await _showOptionSheet(
          context: context,
          title: title,
          selected: value,
          options: options,
        );
        if (v != null) onChanged(v);
      },
      haptic: HapticKind.none,
      scale: 0.99,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border.all(color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: Color(0xFF6D756E),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyHistoryCard extends StatefulWidget {
  const _FamilyHistoryCard({
    required this.title,
    required this.accent,
    required this.history,
    required this.other,
    required this.onChange,
  });
  final String title;
  final Color accent;
  final Set<String> history;
  final TextEditingController other;
  final VoidCallback onChange;

  @override
  State<_FamilyHistoryCard> createState() => _FamilyHistoryCardState();
}

class _FamilyHistoryCardState extends State<_FamilyHistoryCard> {
  static const _options = ['เป็นโรคเรื้อรัง', 'ความดัน', 'เบาหวาน'];

  void _toggle(String v) {
    setState(() {
      widget.history.contains(v)
          ? widget.history.remove(v)
          : widget.history.add(v);
    });
    widget.onChange();
  }

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(text: widget.title),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in _options)
                _ChoiceChip(
                  label: o,
                  selected: widget.history.contains(o),
                  onTap: () => _toggle(o),
                  selectedColor: widget.accent,
                ),
            ],
          ),
          const SizedBox(height: 12),
          const _FieldLabel(text: 'อื่นๆ'),
          const SizedBox(height: 8),
          _PillTextField(controller: widget.other),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0891B2), Color(0xFF0369A1)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.white.withValues(alpha: 0.25),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: CupertinoColors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ทวนข้อมูลก่อนบันทึก',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'กรุณาตรวจสอบข้อมูลด้านล่าง หากถูกต้องแล้วกดบันทึก',
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                    height: 1.45,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

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
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SummaryLabel extends StatelessWidget {
  const _SummaryLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6D756E),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      );
}

class _EmptyText extends StatelessWidget {
  const _EmptyText();

  @override
  Widget build(BuildContext context) => const Text(
        '-',
        style: TextStyle(color: Color(0xFF6D756E), fontSize: 15),
      );
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.value, required this.unit});
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1D8B6B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.clock_fill,
            size: 12,
            color: Color(0xFF1D8B6B),
          ),
          const SizedBox(width: 6),
          Text(
            '${value.isEmpty ? '-' : value} $unit',
            style: const TextStyle(
              color: Color(0xFF1D8B6B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalGrid extends StatelessWidget {
  const _VitalGrid({required this.items});
  final List<
      ({
        IconData icon,
        Color color,
        String label,
        String value,
        String unit
      })> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        const spacing = 10.0;
        final tileWidth = (c.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final it in items)
              SizedBox(
                width: tileWidth,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEDEDF0),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: it.color,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              it.icon,
                              size: 11,
                              color: CupertinoColors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              it.label,
                              style: const TextStyle(
                                color: Color(0xFF6D756E),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            it.value,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            it.unit,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FamilyLine extends StatelessWidget {
  const _FamilyLine({
    required this.label,
    required this.accent,
    required this.history,
    required this.other,
  });
  final String label;
  final Color accent;
  final Set<String> history;
  final String other;

  @override
  Widget build(BuildContext context) {
    final items = [
      ...history,
      if (other.isNotEmpty) other,
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const _EmptyText()
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in items)
                  _SummaryChip(label: s, color: accent),
              ],
            ),
        ],
      ),
    );
  }
}

class _BehaviorRow extends StatelessWidget {
  const _BehaviorRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: color),
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
        ],
      ),
    );
  }
}

class _BehaviorDivider extends StatelessWidget {
  const _BehaviorDivider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: const Color(0xFFEDEDF0));
}

Future<String?> _showOptionSheet({
  required BuildContext context,
  required String title,
  required String selected,
  required List<String> options,
}) {
  return showCupertinoModalPopup<String>(
    context: context,
    barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
    builder: (ctx) {
      String temp = selected;
      return Padding(
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
                child: StatefulBuilder(
                  builder: (ctx, setInner) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          width: 36,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A)
                                .withValues(alpha: 0.25),
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
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    title,
                                    style: const TextStyle(
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
                                Navigator.of(ctx).pop(temp);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (int i = 0; i < options.length; i++) ...[
                                PressEffect(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setInner(() => temp = options[i]);
                                  },
                                  haptic: HapticKind.none,
                                  scale: 0.99,
                                  dim: 0.96,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    color: CupertinoColors.white,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            options[i],
                                            style: const TextStyle(
                                              color: Color(0xFF1A1A1A),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.275,
                                            ),
                                          ),
                                        ),
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                              milliseconds: 180),
                                          child: temp == options[i]
                                              ? const Icon(
                                                  CupertinoIcons.check_mark,
                                                  key: ValueKey('on'),
                                                  size: 20,
                                                  color: Color(0xFF1D8B6B),
                                                )
                                              : const SizedBox(
                                                  key: ValueKey('off'),
                                                  width: 20,
                                                  height: 20,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (i != options.length - 1)
                                  Container(
                                    height: 1,
                                    color: const Color(0xFFE5E5E5),
                                  ),
                              ],
                            ],
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
    },
  );
}
