import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/popover_menu.dart';
import '../../core/widgets/press_effect.dart';
import 'edit_sheets/edit_sheets.dart';
import 'edit_sheets/webview_sheet.dart';
import 'profile_photo_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  // Editable profile data
  String _name = 'ณัฐพงษ์ ทดลอง';
  DateTime _birthDate = DateTime(1999, 4, 15);
  String _bloodType = 'AB';
  String _gender = 'ชาย';
  String _status = 'โสด';
  String _phone = '0812345678';
  String _email = 'Nuntapong@gmail.com';

  // Citizen ID (shown only when verified via Health ID).
  bool _healthIdVerified = true;
  final String _citizenId = '1210567891908';

  String get _citizenIdMasked {
    if (_citizenId.length < 8) return _citizenId;
    final head = _citizenId.substring(0, 4);
    final tail = _citizenId.substring(_citizenId.length - 4);
    return '${head}XXXXX$tail';
  }

  Future<void> _verifyHealthId() async {
    await showWebViewSheet(
      context,
      title: 'Health ID',
      url: 'https://moph.id.th/login',
    );
  }

  static const _thaiMonths = [
    'ม.ค', 'ก.พ', 'มี.ค', 'เม.ย', 'พ.ค', 'มิ.ย',
    'ก.ค', 'ส.ค', 'ก.ย', 'ต.ค', 'พ.ย', 'ธ.ค',
  ];

  String get _birthDateLabel {
    final y = _birthDate.year + 543;
    return '${_birthDate.day} ${_thaiMonths[_birthDate.month - 1]} $y';
  }

  Future<void> _editName() async {
    final v = await showEditTextSheet(
      context,
      title: 'ชื่อ',
      fieldLabel: 'ชื่อ',
      iconColor: const Color(0xFF1D8B6B),
      icon: CupertinoIcons.person_crop_rectangle_fill,
      initialValue: _name,
    );
    if (v != null && v.isNotEmpty) {
      setState(() => _name = v);
      if (mounted) AppToast.success(context, 'อัปเดตข้อมูลแล้ว');
    }
  }

  Future<void> _editBirthDate() async {
    final v = await showEditDateSheet(
      context,
      title: 'วันเกิด',
      fieldLabel: 'วันเดือนปีเกิด',
      iconColor: const Color(0xFF0BA5EC),
      icon: CupertinoIcons.calendar,
      initialValue: _birthDate,
    );
    if (v != null) {
      setState(() => _birthDate = v);
      if (mounted) AppToast.success(context, 'อัปเดตข้อมูลแล้ว');
    }
  }

  Future<void> _editBloodType() async {
    final v = await showEditRadioSheet(
      context,
      title: 'หมู่เลือด',
      description: 'กรุณาเลือกหมู่เลือดของคุณ',
      iconColor: const Color(0xFFBC1B06),
      icon: CupertinoIcons.drop_fill,
      initialValue: _bloodType,
      options: const [
        RadioChoice(value: 'A', label: 'A', iconColor: Color(0xFFBC1B06)),
        RadioChoice(value: 'B', label: 'B', iconColor: Color(0xFFBC1B06)),
        RadioChoice(value: 'AB', label: 'AB', iconColor: Color(0xFFBC1B06)),
        RadioChoice(value: 'O', label: 'O', iconColor: Color(0xFFBC1B06)),
        RadioChoice(
          value: 'ไม่ทราบ',
          label: 'ไม่ทราบ',
          iconColor: Color(0xFF9CA3AF),
        ),
      ],
    );
    if (v != null) {
      setState(() => _bloodType = v);
      if (mounted) AppToast.success(context, 'อัปเดตข้อมูลแล้ว');
    }
  }

  Future<void> _editGender() async {
    final v = await showEditRadioSheet(
      context,
      title: 'เพศ',
      description: 'กรุณาเลือกเพศของคุณ',
      iconColor: const Color(0xFF38BDF8),
      icon: Icons.wc_rounded,
      initialValue: _gender,
      options: const [
        RadioChoice(
          value: 'ชาย',
          label: 'ชาย',
          iconColor: Color(0xFF38BDF8),
          icon: Icons.male_rounded,
        ),
        RadioChoice(
          value: 'หญิง',
          label: 'หญิง',
          iconColor: Color(0xFFEC4899),
          icon: Icons.female_rounded,
        ),
        RadioChoice(
          value: 'อื่นๆ',
          label: 'อื่นๆ',
          iconColor: Color(0xFF9CA3AF),
          icon: Icons.transgender_rounded,
        ),
      ],
    );
    if (v != null) {
      setState(() => _gender = v);
      if (mounted) AppToast.success(context, 'อัปเดตข้อมูลแล้ว');
    }
  }

  Future<void> _editStatus() async {
    final v = await showEditRadioSheet(
      context,
      title: 'สถานะ',
      description: 'กรุณาเลือกสถานะของคุณ',
      iconColor: const Color(0xFFEC4899),
      icon: CupertinoIcons.heart_fill,
      initialValue: _status,
      options: const [
        RadioChoice(
          value: 'โสด',
          label: 'โสด',
          iconColor: Color(0xFF3B82F6),
          icon: CupertinoIcons.person_fill,
        ),
        RadioChoice(
          value: 'สมรส',
          label: 'สมรส',
          iconColor: Color(0xFFEC4899),
          icon: CupertinoIcons.person_2_fill,
        ),
        RadioChoice(
          value: 'หม้าย',
          label: 'หม้าย',
          iconColor: Color(0xFF9333EA),
          icon: CupertinoIcons.person_fill,
        ),
        RadioChoice(
          value: 'แยกกันอยู่',
          label: 'แยกกันอยู่',
          iconColor: Color(0xFFEA580C),
          icon: CupertinoIcons.person_2_fill,
        ),
        RadioChoice(
          value: 'อื่นๆ',
          label: 'อื่นๆ',
          iconColor: Color(0xFF9CA3AF),
          icon: CupertinoIcons.ellipsis,
        ),
      ],
    );
    if (v != null) {
      setState(() => _status = v);
      if (mounted) AppToast.success(context, 'อัปเดตข้อมูลแล้ว');
    }
  }

  Future<void> _editPhone() async {
    final v = await showEditTextSheet(
      context,
      title: 'เบอร์โทรศัพท์',
      fieldLabel: 'กรุณาระบุหมายเลขโทรศัพท์',
      iconColor: const Color(0xFF9333EA),
      icon: CupertinoIcons.phone_fill,
      initialValue: _phone,
      keyboardType: TextInputType.phone,
      maxLength: 15,
    );
    if (v != null && v.isNotEmpty) {
      setState(() => _phone = v);
      if (mounted) AppToast.success(context, 'อัปเดตข้อมูลแล้ว');
    }
  }

  Future<void> _editEmail() async {
    final v = await showEditTextSheet(
      context,
      title: 'เมล',
      fieldLabel: 'กรุณาระบุเมลของคุณ',
      iconColor: const Color(0xFFEA580C),
      icon: CupertinoIcons.envelope_fill,
      initialValue: _email,
      keyboardType: TextInputType.emailAddress,
    );
    if (v != null && v.isNotEmpty) {
      setState(() => _email = v);
      if (mounted) AppToast.success(context, 'อัปเดตข้อมูลแล้ว');
    }
  }

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  Widget _stagger(int index, int total, Widget child) {
    final start = (index / total) * 0.5;
    final end = (start + 0.55).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) {
        final t = anim.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4F8F5);
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE4F5F0), Color(0xFFF4F8F5)],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollUpdateNotification ||
                  n is ScrollStartNotification) {
                _scrollOffset.value = n.metrics.pixels;
              }
              return false;
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(height: 56),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _stagger(0, 4, const _AvatarSection()),
                ),
              SliverToBoxAdapter(
                child: _stagger(
                  1,
                  4,
                  _InfoGroup(
                    title: 'ข้อมูลส่วนบุคคล',
                    rows: [
                      _InfoRow(
                        iconColor: const Color(0xFF1D8B6B),
                        icon: CupertinoIcons.person_crop_rectangle_fill,
                        label: 'ชื่อ',
                        value: _name,
                        onTap: _editName,
                      ),
                      _InfoRow(
                        iconColor: const Color(0xFF2563EB),
                        icon: CupertinoIcons.creditcard_fill,
                        label: 'เลขประจำตัวประชาชน',
                        value: _healthIdVerified
                            ? _citizenIdMasked
                            : 'ยืนยันตัวตนเพื่อดูข้อมูล',
                        valueColor: const Color(0xFF6D756E),
                        showChevron: !_healthIdVerified,
                        onTap: _healthIdVerified ? null : _verifyHealthId,
                      ),
                      _InfoRow(
                        iconColor: const Color(0xFF0BA5EC),
                        icon: CupertinoIcons.calendar,
                        label: 'วันเกิด',
                        value: _birthDateLabel,
                        onTap: _editBirthDate,
                      ),
                      _InfoRow(
                        iconColor: const Color(0xFFBC1B06),
                        icon: CupertinoIcons.drop_fill,
                        label: 'หมู่เลือด',
                        value: _bloodType,
                        onTap: _editBloodType,
                      ),
                      _InfoRow(
                        iconColor: switch (_gender) {
                          'หญิง' => const Color(0xFFEC4899),
                          'อื่นๆ' => const Color(0xFF9CA3AF),
                          _ => const Color(0xFF38BDF8),
                        },
                        icon: switch (_gender) {
                          'ชาย' => Icons.male_rounded,
                          'หญิง' => Icons.female_rounded,
                          _ => Icons.transgender_rounded,
                        },
                        label: 'เพศ',
                        value: _gender,
                        onTap: _editGender,
                      ),
                      _InfoRow(
                        iconColor: const Color(0xFFEC4899),
                        icon: CupertinoIcons.heart_fill,
                        label: 'สถานะ',
                        value: _status,
                        onTap: _editStatus,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _stagger(
                  2,
                  4,
                  _InfoGroup(
                    title: 'ติดต่อ',
                    rows: [
                      _InfoRow(
                        iconColor: const Color(0xFF9333EA),
                        icon: CupertinoIcons.phone_fill,
                        label: 'เบอร์โทรศัพท์',
                        value: _phone,
                        onTap: _editPhone,
                      ),
                      _InfoRow(
                        iconColor: const Color(0xFFEA580C),
                        icon: CupertinoIcons.envelope_fill,
                        label: 'เมล',
                        value: _email,
                        onTap: _editEmail,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _stagger(
                  3,
                  4,
                  _InfoGroup(
                    title: 'บัญชี',
                    rows: [
                      _AccountRow(
                        logo: _AccountLogo.healthId,
                        label: 'Health ID',
                        status: 'ยืนยันตัวตนแล้ว',
                        statusColor: const Color(0xFF17C964),
                        onTap: () => showWebViewSheet(
                          context,
                          title: 'Health ID',
                          url: 'https://moph.id.th/login',
                        ),
                      ),
                      _AccountRow(
                        logo: _AccountLogo.google,
                        label: 'Google',
                        status: 'ผูกแล้ว',
                        statusColor: const Color(0xFF17C964),
                        onTap: () => showWebViewSheet(
                          context,
                          title: 'Google',
                          url: 'https://accounts.google.com/',
                        ),
                      ),
                      _AccountRow(
                        logo: _AccountLogo.facebook,
                        label: 'Facebook',
                        status: 'ยังไม่ผูก',
                        statusColor: const Color(0xFF6D756E),
                        onTap: () => showWebViewSheet(
                          context,
                          title: 'Facebook',
                          url: 'https://m.facebook.com/login',
                        ),
                      ),
                      _AccountRow(
                        logo: _AccountLogo.apple,
                        label: 'Apple',
                        status: 'ยังไม่ผูก',
                        statusColor: const Color(0xFF6D756E),
                        onTap: () => showWebViewSheet(
                          context,
                          title: 'Apple',
                          url: 'https://appleid.apple.com/',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (_, offset, __) => _PinnedTopBar(
                title: 'ข้อมูลส่วนตัว',
                scrollOffset: offset,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedTopBar extends StatelessWidget {
  const _PinnedTopBar({
    required this.title,
    required this.scrollOffset,
    required this.onBack,
  });
  final String title;
  final double scrollOffset;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final progress = (scrollOffset / 60).clamp(0.0, 1.0);
    final barHeight = top + 6 + 44 + 6;
    return Stack(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22 * progress,
              sigmaY: 22 * progress,
            ),
            child: Container(
              height: barHeight,
              color:
                  const Color(0xFFF4F8F5).withValues(alpha: 0.80 * progress),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: progress,
            child: Container(
              height: 0.5,
              color: CupertinoColors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: top + 6, left: 14, right: 14),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.chevron_back,
                    onTap: onBack,
                    size: 40,
                    iconSize: 18,
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


class _AvatarSection extends StatefulWidget {
  const _AvatarSection();

  @override
  State<_AvatarSection> createState() => _AvatarSectionState();
}

class _AvatarSectionState extends State<_AvatarSection> {
  final GlobalKey _cameraKey = GlobalKey();

  Future<void> _pickFromSource(ImageSource src) async {
    final picker = ImagePicker();
    try {
      final x = await picker.pickImage(
        source: src,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (x != null) {
        ProfilePhotoService.instance.set(x.path);
      }
    } catch (_) {
      // ignore: user cancelled or permission denied
    }
  }

  void _showPicker() {
    final hasPhoto = ProfilePhotoService.instance.path.value != null;
    showPopoverMenu(
      context: context,
      anchorKey: _cameraKey,
      actions: [
        PopoverMenuAction(
          label: 'ถ่ายภาพ',
          icon: CupertinoIcons.camera,
          onTap: () => _pickFromSource(ImageSource.camera),
        ),
        PopoverMenuAction(
          label: 'เลือกจากคลังภาพ',
          icon: CupertinoIcons.photo_on_rectangle,
          onTap: () => _pickFromSource(ImageSource.gallery),
        ),
        if (hasPhoto)
          PopoverMenuAction(
            label: 'ลบรูปปัจจุบัน',
            icon: CupertinoIcons.trash,
            destructive: true,
            onTap: () => ProfilePhotoService.instance.clear(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: const ClipOval(
                  child: ProfileAvatarImage(fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: PressEffect(
                  key: _cameraKey,
                  onTap: _showPicker,
                  haptic: HapticKind.selection,
                  rippleShape: BoxShape.circle,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                      border: Border.all(
                        color: CupertinoColors.white,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      color: CupertinoColors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar image that follows the currently selected profile photo,
/// falling back to the default asset when none is set.
class ProfileAvatarImage extends StatelessWidget {
  const ProfileAvatarImage({
    super.key,
    this.fit = BoxFit.cover,
  });
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ProfilePhotoService.instance.path,
      builder: (_, path, __) {
        if (path == null) {
          return Image.asset('assets/images/family/me.png', fit: fit);
        }
        return Image.file(File(path), fit: fit);
      },
    );
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headline(const Color(0xFF1A1A1A)).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i != rows.length - 1)
                    Container(
                      height: 1,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.valueColor = const Color(0xFF1A1A1A),
    this.showChevron = true,
  });
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Color valueColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap ?? () {},
      haptic: onTap != null ? HapticKind.selection : HapticKind.none,
      scale: onTap != null ? 0.99 : 1.0,
      dim: onTap != null ? 0.96 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: CupertinoColors.white,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: CupertinoColors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6D756E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.275,
              ),
            ),
            if (showChevron) ...[
              const SizedBox(width: 10),
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 12,
                color: Color(0xFF6D756E),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _AccountLogo { healthId, google, facebook, apple }

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.logo,
    required this.label,
    required this.status,
    required this.statusColor,
    this.onTap,
  });
  final _AccountLogo logo;
  final String label;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap ?? () {},
      haptic: HapticKind.selection,
      scale: 0.99,
      dim: 0.96,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: CupertinoColors.white,
        child: Row(
          children: [
            _AccountIcon(logo: logo),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6D756E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.275,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 12,
              color: Color(0xFF6D756E),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountIcon extends StatelessWidget {
  const _AccountIcon({required this.logo});
  final _AccountLogo logo;

  @override
  Widget build(BuildContext context) {
    final asset = switch (logo) {
      _AccountLogo.healthId => 'assets/images/me/health_id.png',
      _AccountLogo.google => 'assets/images/me/google.png',
      _AccountLogo.facebook => 'assets/images/me/facebook.png',
      _AccountLogo.apple => 'assets/images/me/apple.png',
    };
    final fit = logo == _AccountLogo.apple ? BoxFit.contain : BoxFit.contain;
    return SizedBox(
      width: 24,
      height: 24,
      child: Image.asset(asset, fit: fit),
    );
  }
}
