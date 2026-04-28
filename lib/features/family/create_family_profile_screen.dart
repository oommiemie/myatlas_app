import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/popover_menu.dart';
import '../../core/widgets/press_effect.dart';
import 'family_devices.dart';

class _ProfileDraft {
  String? photoPath;
  String name = '';
  String surname = '';
  String? relationship;
  DateTime? birthDate;
  String? bloodType;
  String phone = '';
  final Set<DeviceKind> connectedDevices = {};

  bool get isProfileValid =>
      name.trim().isNotEmpty && surname.trim().isNotEmpty;

  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years -= 1;
    }
    return years;
  }
}

Future<void> showCreateFamilyProfileScreen(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    CupertinoPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const CreateFamilyProfileScreen(),
    ),
  );
}

class CreateFamilyProfileScreen extends StatefulWidget {
  const CreateFamilyProfileScreen({super.key});

  @override
  State<CreateFamilyProfileScreen> createState() =>
      _CreateFamilyProfileScreenState();
}

class _CreateFamilyProfileScreenState extends State<CreateFamilyProfileScreen> {
  final _ProfileDraft _draft = _ProfileDraft();
  int _stage = 0; // 0 = profile, 1 = devices, 2 = done
  bool _forward = true;

  void _go(int next) {
    if (next == _stage) return;
    setState(() {
      _forward = next > _stage;
      _stage = next;
    });
  }

  Future<void> _handleClose() async {
    final touched = _draft.name.isNotEmpty ||
        _draft.surname.isNotEmpty ||
        _draft.birthDate != null ||
        _draft.photoPath != null;
    if (_stage == 2 || !touched) {
      Navigator.of(context).pop();
      return;
    }
    final yes = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('ออกจากการสร้างโปรไฟล์?'),
        content: const Text('ข้อมูลที่กรอกไว้จะหายไปทั้งหมด'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ทำต่อ'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ออก'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              stage: _stage,
              onBack: _stage > 0 && _stage < 2 ? () => _go(_stage - 1) : null,
              onClose: _handleClose,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) {
                  final beginX = _forward ? 0.18 : -0.18;
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(beginX, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: _buildStage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case 0:
        return _ProfileStage(
          key: const ValueKey('profile'),
          draft: _draft,
          onChanged: () => setState(() {}),
          onNext: _draft.isProfileValid ? () => _go(1) : null,
        );
      case 1:
        return _DevicesStage(
          key: const ValueKey('devices'),
          draft: _draft,
          onChanged: () => setState(() {}),
          onSave: () => _go(2),
        );
      default:
        return _DoneStage(
          key: const ValueKey('done'),
          draft: _draft,
          onDone: () => Navigator.of(context).pop(),
        );
    }
  }
}

// ── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.stage,
    required this.onBack,
    required this.onClose,
  });
  final int stage;
  final VoidCallback? onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  switch (stage) {
                    0 => 'ข้อมูลโปรไฟล์',
                    1 => 'เชื่อมต่ออุปกรณ์',
                    _ => 'พร้อมแล้ว',
                  },
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                if (onBack != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LiquidGlassButton(
                      icon: CupertinoIcons.chevron_back,
                      iconColor: const Color(0xFF1A1A1A),
                      onTap: onBack!,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.xmark,
                    iconColor: const Color(0xFF1A1A1A),
                    onTap: onClose,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _Steps(current: stage),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    final step = (current).clamp(0, 2);
    return SizedBox(
      height: 6,
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: i <= step
                      ? const Color(0xFF1D8B6B)
                      : const Color(0xFF1A1A1A).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stage 1: Profile ────────────────────────────────────────────────────────

class _ProfileStage extends StatefulWidget {
  const _ProfileStage({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onNext,
  });
  final _ProfileDraft draft;
  final VoidCallback onChanged;
  final VoidCallback? onNext;

  @override
  State<_ProfileStage> createState() => _ProfileStageState();
}

class _ProfileStageState extends State<_ProfileStage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _surnameCtrl;
  late final TextEditingController _phoneCtrl;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _surnameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  static const _months = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  static const _bloodTypes = ['A', 'B', 'AB', 'O', 'ไม่ทราบ'];

  static const _relationships = <(String, IconData)>[
    ('พ่อ', CupertinoIcons.person_fill),
    ('แม่', CupertinoIcons.person_fill),
    ('พี่', CupertinoIcons.person_2_fill),
    ('น้อง', CupertinoIcons.person_2_fill),
    ('ลูก', CupertinoIcons.smiley_fill),
    ('คู่สมรส', CupertinoIcons.heart_fill),
    ('ญาติ', CupertinoIcons.person_3_fill),
    ('อื่น ๆ', CupertinoIcons.person_crop_circle_fill),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.draft.name);
    _surnameCtrl = TextEditingController(text: widget.draft.surname);
    _phoneCtrl = TextEditingController(text: widget.draft.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _phoneCtrl.dispose();
    _nameFocus.dispose();
    _surnameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    final initial = widget.draft.birthDate ?? DateTime(1990, 1, 1);
    DateTime temp = initial;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 320,
        color: const Color(0xFFF8F8FA),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('ยกเลิก',
                          style: TextStyle(color: Color(0xFF6D756E))),
                    ),
                    const Spacer(),
                    const Text(
                      'เลือกวันเกิด',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        widget.draft.birthDate = temp;
                        widget.onChanged();
                        Navigator.of(ctx).pop();
                      },
                      child: const Text(
                        'เสร็จ',
                        style: TextStyle(
                          color: Color(0xFF1D8B6B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initial,
                  maximumDate: DateTime.now(),
                  minimumYear: 1900,
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _birthLabel() {
    final d = widget.draft.birthDate;
    if (d == null) return 'แตะเพื่อเลือกวันเกิด';
    return '${d.day} ${_months[d.month - 1]} ${d.year + 543}  ·  อายุ ${widget.draft.age} ปี';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              children: [
                _PhotoPicker(
                  photoPath: widget.draft.photoPath,
                  onPicked: (p) {
                    widget.draft.photoPath = p;
                    widget.onChanged();
                  },
                ),
                const SizedBox(height: 22),
                // Name + Surname row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: 'ชื่อ',
                        required: true,
                        child: AppTextField(
                          controller: _nameCtrl,
                          focusNode: _nameFocus,
                          placeholder: 'ชื่อจริง',
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              _surnameFocus.requestFocus(),
                          onChanged: (v) {
                            widget.draft.name = v;
                            widget.onChanged();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledField(
                        label: 'นามสกุล',
                        required: true,
                        child: AppTextField(
                          controller: _surnameCtrl,
                          focusNode: _surnameFocus,
                          placeholder: 'นามสกุล',
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) =>
                              FocusScope.of(context).unfocus(),
                          onChanged: (v) {
                            widget.draft.surname = v;
                            widget.onChanged();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'ความสัมพันธ์',
                  child: _RelationshipChips(
                    selected: widget.draft.relationship,
                    options: _relationships,
                    onSelect: (v) {
                      HapticFeedback.selectionClick();
                      widget.draft.relationship = v;
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'วันเกิด',
                  child: PressEffect(
                    onTap: _pickBirthDate,
                    haptic: HapticKind.none,
                    scale: 0.99,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 44,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE5E5E5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.calendar,
                            size: 18,
                            color: Color(0xFF0BA5EC),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _birthLabel(),
                              style: TextStyle(
                                color: widget.draft.birthDate == null
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF1A1A1A),
                                fontSize: 15,
                                fontWeight: widget.draft.birthDate == null
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'หมู่เลือด',
                  child: _BloodTypeChips(
                    selected: widget.draft.bloodType,
                    options: _bloodTypes,
                    onSelect: (v) {
                      HapticFeedback.selectionClick();
                      widget.draft.bloodType = v;
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'เบอร์โทร',
                  child: AppTextField(
                    controller: _phoneCtrl,
                    focusNode: _phoneFocus,
                    placeholder: '08x-xxx-xxxx',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onChanged: (v) {
                      widget.draft.phone = v;
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '* ต้องกรอกชื่อและนามสกุล · ข้อมูลอื่นเพิ่มภายหลังได้',
                  style: TextStyle(
                    color: const Color(0xFF6D756E).withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: _PrimaryButton(
              label: 'ถัดไป · เชื่อมต่ออุปกรณ์',
              enabled: widget.onNext != null,
              onTap: widget.onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.required = false,
  });
  final String label;
  final Widget child;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              if (required) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _RelationshipChips extends StatelessWidget {
  const _RelationshipChips({
    required this.selected,
    required this.options,
    required this.onSelect,
  });
  final String? selected;
  final List<(String, IconData)> options;
  final ValueChanged<String> onSelect;

  static const _tone = Color(0xFF9333EA);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (label, icon) in options)
          PressEffect(
            onTap: () => onSelect(label),
            haptic: HapticKind.none,
            scale: 0.95,
            borderRadius: BorderRadius.circular(100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected == label
                    ? _tone.withValues(alpha: 0.1)
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: selected == label
                      ? _tone
                      : const Color(0xFFE5E5E5),
                  width: selected == label ? 1.4 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 13,
                    color: selected == label
                        ? _tone
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected == label
                          ? _tone
                          : const Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: selected == label
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BloodTypeChips extends StatelessWidget {
  const _BloodTypeChips({
    required this.selected,
    required this.options,
    required this.onSelect,
  });
  final String? selected;
  final List<String> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in options)
          PressEffect(
            onTap: () => onSelect(v),
            haptic: HapticKind.none,
            scale: 0.95,
            borderRadius: BorderRadius.circular(100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected == v
                    ? const Color(0xFFBC1B06).withValues(alpha: 0.1)
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: selected == v
                      ? const Color(0xFFBC1B06)
                      : const Color(0xFFE5E5E5),
                  width: selected == v ? 1.4 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (v != 'ไม่ทราบ') ...[
                    Icon(
                      CupertinoIcons.drop_fill,
                      size: 12,
                      color: selected == v
                          ? const Color(0xFFBC1B06)
                          : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    v,
                    style: TextStyle(
                      color: selected == v
                          ? const Color(0xFFBC1B06)
                          : const Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: selected == v
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photoPath, required this.onPicked});
  final String? photoPath;
  final ValueChanged<String?> onPicked;

  void _showSourceMenu(BuildContext context, GlobalKey anchor) {
    showPopoverMenu(
      context: context,
      anchorKey: anchor,
      actions: [
        PopoverMenuAction(
          label: 'ถ่ายภาพ',
          icon: CupertinoIcons.camera,
          onTap: () => _pick(ImageSource.camera),
        ),
        PopoverMenuAction(
          label: 'เลือกจากคลังภาพ',
          icon: CupertinoIcons.photo_on_rectangle,
          onTap: () => _pick(ImageSource.gallery),
        ),
        if (photoPath != null)
          PopoverMenuAction(
            label: 'ลบรูป',
            icon: CupertinoIcons.trash,
            destructive: true,
            onTap: () => onPicked(null),
          ),
      ],
    );
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final x = await ImagePicker().pickImage(
        source: src,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (x != null) onPicked(x.path);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final anchor = GlobalKey();
    return Center(
      child: PressEffect(
        onTap: () => _showSourceMenu(context, anchor),
        haptic: HapticKind.selection,
        scale: 0.95,
        rippleShape: BoxShape.circle,
        child: Stack(
          children: [
            Container(
              key: anchor,
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1D8B6B).withValues(alpha: 0.08),
                border: Border.all(
                  color: CupertinoColors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: photoPath != null
                  ? Image.file(File(photoPath!), fit: BoxFit.cover)
                  : const Icon(
                      CupertinoIcons.person_fill,
                      size: 56,
                      color: Color(0xFF1D8B6B),
                    ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1D8B6B),
                  border:
                      Border.all(color: CupertinoColors.white, width: 3),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.camera_fill,
                  size: 14,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stage 2: Devices ────────────────────────────────────────────────────────

class _DevicesStage extends StatelessWidget {
  const _DevicesStage({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onSave,
  });
  final _ProfileDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onSave;

  void _toggle(BuildContext context, DeviceKind kind) {
    HapticFeedback.selectionClick();
    if (draft.connectedDevices.contains(kind)) {
      draft.connectedDevices.remove(kind);
    } else {
      draft.connectedDevices.add(kind);
      AppToast.success(context, 'เริ่มเชื่อมต่อ ${kind.label}');
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'เลือกอุปกรณ์ที่ใช้ติดตามข้อมูลสุขภาพ\nสามารถเชื่อมต่อหลายอุปกรณ์ได้',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6D756E),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              for (final k in DeviceKind.values) ...[
                DeviceTile(
                  kind: k,
                  connected: draft.connectedDevices.contains(k),
                  onTap: () => _toggle(context, k),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: 'ข้ามไปก่อน',
                  onTap: onSave,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _PrimaryButton(
                  label: draft.connectedDevices.isEmpty
                      ? 'บันทึกโปรไฟล์'
                      : 'บันทึก · ${draft.connectedDevices.length} อุปกรณ์',
                  enabled: true,
                  onTap: onSave,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// ── Stage 3: Done ───────────────────────────────────────────────────────────

class _DoneStage extends StatelessWidget {
  const _DoneStage({super.key, required this.draft, required this.onDone});
  final _ProfileDraft draft;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF26A37E), Color(0xFF157F5E)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D8B6B).withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.checkmark_alt,
              color: CupertinoColors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'เพิ่ม ${draft.name} แล้ว',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            draft.connectedDevices.isEmpty
                ? 'ยังไม่ได้เชื่อมต่ออุปกรณ์ใด ๆ — สามารถเชื่อมเพิ่มภายหลังได้'
                : 'เชื่อมต่อกับ ${draft.connectedDevices.length} อุปกรณ์เรียบร้อย คุณสามารถดูข้อมูลสุขภาพในหน้าครอบครัว',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6D756E),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.55,
            ),
          ),
          const Spacer(flex: 2),
          _PrimaryButton(
            label: 'เสร็จสิ้น',
            enabled: true,
            onTap: onDone,
          ),
        ],
      ),
    );
  }
}

// ── Buttons ─────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: enabled ? onTap : null,
      haptic: HapticKind.medium,
      scale: 0.97,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF26A37E), Color(0xFF157F5E)],
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color:
                          const Color(0xFF1D8B6B).withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.97,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

