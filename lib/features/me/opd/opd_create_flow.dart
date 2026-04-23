import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/liquid_glass_button.dart';
import '../../../core/widgets/press_effect.dart';
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

  // Stage 1 — vitals
  final _bp = TextEditingController();
  final _temp = TextEditingController();
  final _heartRate = TextEditingController();
  final _weight = TextEditingController(text: '65');
  final _height = TextEditingController(text: '170');

  // Stage 2 — symptoms
  final Set<String> _symptoms = {};
  static const _symptomOptions = [
    'ไอ', 'น้ำมูก', 'ปวดศีรษะ', 'เป็นไข้',
    'อาเจียน', 'ท้องเสีย', 'ปวดท้อง', 'ปัสสาวะแสบขัด',
  ];
  final _chiefComplaint = TextEditingController();
  int _durationDays = 1;
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
        'duration_days': _durationDays,
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
    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('บันทึกสำเร็จ'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('ลงทะเบียน OPD เรียบร้อยแล้ว สามารถแสดง QR Code ได้ทันที'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F5).withValues(alpha: 0.92),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.white.withValues(alpha: 0.7),
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
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(2.5),
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
    );
  }

  // ─── STEP 1 — Patient info + vital signs ────────────────────────────────

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _InfoCard(
          rows: const [
            ('ชื่อ', 'ณัฐพงษ์ ทดลอง'),
            ('เลขประจำตัวประชาชน', '1210XXXXX1908'),
            ('อายุ', '27 ปี'),
            ('เพศ', 'ชาย'),
            ('หมู่เลือด', 'AB'),
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
                placeholder: '00/00',
                controller: _bp,
              ),
              const SizedBox(height: 16),
              _VitalField(
                icon: CupertinoIcons.thermometer,
                iconColor: const Color(0xFF2563EB),
                label: 'อุณหภูมิ',
                placeholder: '00',
                controller: _temp,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _VitalField(
                icon: CupertinoIcons.waveform_path_ecg,
                iconColor: const Color(0xFFBE123C),
                label: 'Heart Rate',
                placeholder: '00',
                controller: _heartRate,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _VitalField(
                icon: CupertinoIcons.person_fill,
                iconColor: const Color(0xFF1D8B6B),
                label: 'น้ำหนัก',
                placeholder: '65',
                controller: _weight,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _VitalField(
                icon: CupertinoIcons.arrow_up_arrow_down,
                iconColor: const Color(0xFF1D8B6B),
                label: 'ส่วนสูง',
                placeholder: '170',
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
                value: _durationDays,
                onChanged: (v) => setState(() => _durationDays = v),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
                value: _smoking,
                options: const ['ไม่เคยสูบ', 'เคยสูบแต่เลิกแล้ว', 'สูบเป็นประจำ'],
                onChanged: (v) => setState(() => _smoking = v),
              ),
              const SizedBox(height: 16),
              const _FieldLabel(text: 'ดื่มสุรา'),
              const SizedBox(height: 8),
              _DropdownField(
                value: _alcohol,
                options: const ['ไม่ดื่ม', 'ดื่มบางครั้ง', 'ดื่มเป็นประจำ'],
                onChanged: (v) => setState(() => _alcohol = v),
              ),
              const SizedBox(height: 16),
              const _FieldLabel(text: 'การออกกำลังกาย'),
              const SizedBox(height: 8),
              _DropdownField(
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
        _SummarySection(
          title: 'ข้อมูลผู้ป่วย',
          items: const [
            ('ชื่อ', 'ณัฐพงษ์ ทดลอง'),
            ('CID', '1210XXXXX1908'),
            ('อายุ', '27 ปี'),
            ('เพศ', 'ชาย'),
            ('หมู่เลือด', 'AB'),
          ],
        ),
        const SizedBox(height: 12),
        _SummarySection(
          title: 'Vital Signs',
          items: [
            ('ความดันโลหิต', _bp.text.isEmpty ? '-' : _bp.text),
            ('อุณหภูมิ', _temp.text.isEmpty ? '-' : '${_temp.text} °C'),
            ('Heart Rate',
                _heartRate.text.isEmpty ? '-' : '${_heartRate.text} bpm'),
            ('น้ำหนัก', '${_weight.text} kg'),
            ('ส่วนสูง', '${_height.text} cm'),
          ],
        ),
        const SizedBox(height: 12),
        _SummarySection(
          title: 'อาการ',
          items: [
            ('อาการ', _symptoms.isEmpty ? '-' : _symptoms.join(', ')),
            (
              'อาการสำคัญ',
              _chiefComplaint.text.isEmpty ? '-' : _chiefComplaint.text,
            ),
            ('ระยะเวลา', '$_durationDays วัน'),
          ],
        ),
        const SizedBox(height: 12),
        _SummarySection(
          title: 'ประวัติครอบครัว',
          items: [
            (
              'บิดา',
              _fatherHistory.isEmpty
                  ? (_fatherOther.text.isEmpty ? '-' : _fatherOther.text)
                  : _fatherHistory.join(', '),
            ),
            (
              'มารดา',
              _motherHistory.isEmpty
                  ? (_motherOther.text.isEmpty ? '-' : _motherOther.text)
                  : _motherHistory.join(', '),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummarySection(
          title: 'ประวัติสุขภาพ',
          items: [
            (
              'โรคประจำตัว',
              _chronicDiseases.isEmpty ? '-' : _chronicDiseases.join(', ')
            ),
            ('แพ้ยา', _allergies.isEmpty ? '-' : _allergies.join(', ')),
            ('ผ่าตัด', _surgery.text.isEmpty ? '-' : _surgery.text),
          ],
        ),
        const SizedBox(height: 12),
        _SummarySection(
          title: 'พฤติกรรม',
          items: [
            ('อาการชัก', _seizure),
            ('การสูบบุหรี่', _smoking),
            ('ดื่มสุรา', _alcohol),
            ('การออกกำลังกาย', _exercise),
          ],
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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
          Row(
            children: [
              for (int i = 0; i < total; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step
                          ? const Color(0xFF1D8B6B)
                          : const Color(0xFF1D8B6B).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                if (i != total - 1) const SizedBox(width: 6),
              ],
            ],
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].$1,
                      style: const TextStyle(
                        color: Color(0xFF6D756E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    rows[i].$2,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.275,
                    ),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              Container(height: 1, color: const Color(0xFFE5E5E5)),
          ],
        ],
      ),
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

class _VitalField extends StatelessWidget {
  const _VitalField({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.keyboardType,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 12, color: CupertinoColors.white),
            ),
            const SizedBox(width: 8),
            _FieldLabel(text: label),
          ],
        ),
        const SizedBox(height: 8),
        _PillTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}

class _PillTextField extends StatelessWidget {
  const _PillTextField({
    required this.controller,
    this.placeholder = '',
    this.keyboardType,
  });
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      placeholderStyle: const TextStyle(
        color: Color(0xFF6D756E),
        fontSize: 16,
      ),
      style: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 16,
        letterSpacing: 0.275,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$value',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          PressEffect(
            onTap: () => onChanged((value - 1).clamp(1, 365)),
            haptic: HapticKind.selection,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5F5F5),
              ),
              child: const Icon(
                CupertinoIcons.minus,
                size: 12,
                color: Color(0xFF6D756E),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'วัน',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PressEffect(
            onTap: () => onChanged((value + 1).clamp(1, 365)),
            haptic: HapticKind.selection,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1D8B6B),
              ),
              child: const Icon(
                CupertinoIcons.plus,
                size: 12,
                color: CupertinoColors.white,
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

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.95,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6).copyWith(
          left: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: selected
              ? selectedColor.withValues(alpha: 0.9)
              : CupertinoColors.white,
          border: !selected
              ? Border.all(
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.08),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showRadio
                  ? (selected
                      ? CupertinoIcons.largecircle_fill_circle
                      : CupertinoIcons.circle)
                  : (selected
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.circle),
              size: 12,
              color: selected
                  ? CupertinoColors.white
                  : const Color(0xFF6D756E),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? CupertinoColors.white
                    : const Color(0xFF3E453F),
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w500 : FontWeight.w400,
              ),
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
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: () async {
        HapticFeedback.selectionClick();
        final v = await showCupertinoModalPopup<String>(
          context: context,
          builder: (ctx) => CupertinoActionSheet(
            actions: [
              for (final o in options)
                CupertinoActionSheetAction(
                  isDefaultAction: o == value,
                  onPressed: () => Navigator.of(ctx).pop(o),
                  child: Text(o),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ยกเลิก'),
            ),
          ),
        );
        if (v != null) onChanged(v);
      },
      haptic: HapticKind.none,
      scale: 0.99,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border.all(color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(100),
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

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.title, required this.items});
  final String title;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      items[i].$1,
                      style: const TextStyle(
                        color: Color(0xFF6D756E),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      items[i].$2,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != items.length - 1)
              Container(height: 1, color: const Color(0xFFE5E5E5)),
          ],
        ],
      ),
    );
  }
}
