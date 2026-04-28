import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';
import 'create_family_profile_screen.dart';

/// Entry sheet for adding a family member. Lets the user pick between
/// linking with another existing MyAtlas user via QR/Scan, or creating a
/// brand-new profile (for caregivers who track family members that don't
/// use the app themselves).
Future<void> showAddFamilyMemberSheet(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const _AddFamilyChooserSheet(),
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: anim,
              curve: Curves.fastEaseInToSlowEaseOut,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
          child: child,
        );
      },
    ),
  );
}

class _AddFamilyChooserSheet extends StatelessWidget {
  const _AddFamilyChooserSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      resizeToAvoidBottomInset: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA).withValues(alpha: 0.96),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 38,
                      height: 5,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF1A1A1A).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: LiquidGlassButton(
                        icon: CupertinoIcons.xmark,
                        iconColor: const Color(0xFF1A1A1A),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Hero illustration
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0x331D8B6B),
                          Color(0x111D8B6B),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF26A37E), Color(0xFF157F5E)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1D8B6B)
                                .withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.person_2_fill,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'เพิ่มสมาชิกครอบครัว',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'เลือกวิธีที่เหมาะกับสมาชิกของคุณ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6D756E),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    child: Column(
                      children: [
                        _ChooserCard(
                          icon: CupertinoIcons.qrcode_viewfinder,
                          tone: const Color(0xFF1D8B6B),
                          title: 'สมาชิกใช้แอป MyAtlas อยู่แล้ว',
                          subtitle:
                              'เชื่อมต่อด้วย QR Code หรือสแกนของอีกฝั่ง',
                          onTap: () {
                            Navigator.of(context).pop();
                            showQrConnectSheet(context);
                          },
                        ),
                        const SizedBox(height: 12),
                        _ChooserCard(
                          icon: CupertinoIcons.person_add_solid,
                          tone: const Color(0xFF9333EA),
                          title: 'สร้างโปรไฟล์ใหม่',
                          subtitle:
                              'สำหรับคนในครอบครัวที่ยังไม่ได้ใช้แอป กรอกข้อมูลและเชื่อมต่ออุปกรณ์ติดตามสุขภาพได้',
                          onTap: () {
                            Navigator.of(context).pop();
                            showCreateFamilyProfileScreen(context);
                          },
                          badge: 'แนะนำ',
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
    );
  }
}

class _ChooserCard extends StatelessWidget {
  const _ChooserCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
    this.badge,
  });
  final IconData icon;
  final Color tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.98,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: highlight
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tone.withValues(alpha: 0.16),
                    tone.withValues(alpha: 0.04),
                  ],
                )
              : null,
          color: highlight ? null : CupertinoColors.white,
          border: Border.all(
            color: highlight
                ? tone.withValues(alpha: 0.45)
                : const Color(0xFF747480).withValues(alpha: 0.1),
            width: highlight ? 1.5 : 1,
          ),
          boxShadow: highlight
              ? [
                  BoxShadow(
                    color: tone.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tone,
                        Color.lerp(tone, CupertinoColors.black, 0.18)!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tone.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 24, color: CupertinoColors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: badge != null ? 56 : 0),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6D756E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: highlight
                        ? tone
                        : tone.withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    CupertinoIcons.chevron_forward,
                    size: 13,
                    color: highlight ? CupertinoColors.white : tone,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: 38,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tone,
                        Color.lerp(tone, CupertinoColors.black, 0.15)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: tone.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── QR / Scan flow (existing-user path) ─────────────────────────────────────

Future<void> showQrConnectSheet(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const _QrConnectSheet(),
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: anim,
                  curve: Curves.fastEaseInToSlowEaseOut,
                  reverseCurve: Curves.easeInCubic,
                ),
              ),
          child: child,
        );
      },
    ),
  );
}

class _QrConnectSheet extends StatefulWidget {
  const _QrConnectSheet();

  @override
  State<_QrConnectSheet> createState() => _QrConnectSheetState();
}

class _QrConnectSheetState extends State<_QrConnectSheet> {
  int _tab = 0; // 0 = My QR, 1 = Scan
  bool _scanned = false;

  void _switchTab(int i) {
    setState(() {
      _tab = i;
      _scanned = false;
    });
    if (i == 1) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        if (_tab == 1) setState(() => _scanned = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.fastEaseInToSlowEaseOut,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    final isQr = child.key == const ValueKey('qr');
                    final isScan = child.key == const ValueKey('scan');
                    final isFound = child.key == const ValueKey('found');
                    Offset begin;
                    if (isQr) {
                      begin = const Offset(-0.15, 0);
                    } else if (isScan) {
                      begin = const Offset(0.15, 0);
                    } else if (isFound) {
                      begin = const Offset(0, 0.08);
                    } else {
                      begin = Offset.zero;
                    }
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: begin,
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.center,
                    children: [...previous, if (current != null) current],
                  ),
                  child: _scanned
                      ? const _FoundView(key: ValueKey('found'))
                      : _tab == 0
                          ? const _MyQrView(key: ValueKey('qr'))
                          : const _ScanView(key: ValueKey('scan')),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: Center(
                  child: _BottomTabs(
                    selected: _scanned ? 1 : _tab,
                    onChange: _switchTab,
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

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({this.titleColor = CupertinoColors.white});
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'เชื่อมต่อด้วย QR',
              style: TextStyle(
                color: titleColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _LiquidGlassCircle(
                icon: CupertinoIcons.xmark,
                onTap: () => Navigator.of(context).pop(),
                size: 36,
                iconSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomTabs extends StatelessWidget {
  const _BottomTabs({required this.selected, required this.onChange});
  final int selected;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFD4D4D4).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(100),
      ),
      child: SizedBox(
        height: 36,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segW = constraints.maxWidth / 2;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutQuint,
                  left: selected * segW,
                  top: 0,
                  bottom: 0,
                  width: segW,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (int i = 0; i < 2; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChange(i),
                          child: Center(
                            child: Text(
                              i == 0 ? 'QR ของฉัน' : 'สแกน',
                              style: TextStyle(
                                color: i == selected
                                    ? const Color(0xFF2CA989)
                                    : const Color(0xFF1A1A1A),
                                fontSize: 15,
                                fontWeight: i == selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                letterSpacing: -0.23,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MyQrView extends StatelessWidget {
  const _MyQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF68C7AD), Color(0xFF1D8B6B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -160,
            left: -80,
            child: Container(
              width: 640,
              height: 640,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    CupertinoColors.white.withValues(alpha: 0.25),
                    CupertinoColors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHeader(),
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: CupertinoColors.white.withValues(alpha: 0.18),
                        width: 0.8,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/family/my_qr.png',
                          fit: BoxFit.contain,
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.person_2_fill,
                            color: Color(0xFF1D8B6B),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanView extends StatelessWidget {
  const _ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF333333),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [Color(0xFF555555), Color(0xFF1A1A1A)],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHeader(),
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: _ScanFramePainter(),
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white
                                .withValues(alpha: 0.12),
                          ),
                          alignment: Alignment.center,
                          child: const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const cornerLen = 32.0;
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLen, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLen), paint);
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLen, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLen),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLen, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLen),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLen, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FoundView extends StatelessWidget {
  const _FoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: CupertinoColors.white),
      child: Column(
        children: [
          const _SheetHeader(titleColor: Color(0xFF1A1A1A)),
          const SizedBox(height: 80),
          Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1D8B6B).withValues(alpha: 0.05),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/family/pat.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'คุณ ภัทรพล มรรคหิรัญ',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2CA989),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    CupertinoIcons.person_add_solid,
                    size: 16,
                    color: CupertinoColors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'เพิ่มสมาชิก',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
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

class _LiquidGlassCircle extends StatelessWidget {
  const _LiquidGlassCircle({
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 20,
  });
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.65),
              ),
              child: Icon(icon, color: const Color(0xFF1A1A1A), size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}
