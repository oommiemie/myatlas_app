import 'dart:ui';

import 'package:flutter/cupertino.dart';

Future<void> showAddFamilyMemberSheet(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const _AddFamilySheet(),
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim,
            curve: Curves.fastEaseInToSlowEaseOut,
            reverseCurve: Curves.easeInCubic,
          )),
          child: child,
        );
      },
    ),
  );
}

class _AddFamilySheet extends StatefulWidget {
  const _AddFamilySheet();

  @override
  State<_AddFamilySheet> createState() => _AddFamilySheetState();
}

class _AddFamilySheetState extends State<_AddFamilySheet> {
  int _tab = 0; // 0 = My QR, 1 = Scan
  bool _scanned = false;

  void _switchTab(int i) {
    setState(() {
      _tab = i;
      _scanned = false;
    });
    if (i == 1) {
      // Simulate a scan result after 1.8s
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
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(38)),
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
                    children: [
                      ...previous,
                      if (current != null) current,
                    ],
                  ),
                  child: _scanned
                      ? const _FoundView(key: ValueKey('found'))
                      : _tab == 0
                          ? const _MyQrView(key: ValueKey('qr'))
                          : const _ScanView(key: ValueKey('scan')),
                ),
              ),
              // Persistent tab bar pinned at bottom (doesn't fade on tab swap)
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
              'เพิ่มสมาชิกครอบครัว',
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
  const _BottomTabs({
    required this.selected,
    required this.onChange,
    this.onDark = true,
  });
  final int selected;
  final ValueChanged<int> onChange;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: 250,
      decoration: BoxDecoration(
        color: onDark
            ? CupertinoColors.black.withValues(alpha: 0.25)
            : const Color(0xFFD4D4D4).withValues(alpha: 0.22),
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
                              i == 0 ? 'My QR code' : 'Scan',
                              style: TextStyle(
                                color: i == selected
                                    ? const Color(0xFF2CA989)
                                    : (onDark
                                        ? CupertinoColors.white
                                        : const Color(0xFF1A1A1A)),
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
          // Soft top ellipse glow
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
                        color: CupertinoColors.white
                            .withValues(alpha: 0.18),
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
          // Dim scanner background
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
    // Top-left
    canvas.drawLine(
        const Offset(0, 0), const Offset(cornerLen, 0), paint);
    canvas.drawLine(
        const Offset(0, 0), const Offset(0, cornerLen), paint);
    // Top-right
    canvas.drawLine(Offset(size.width, 0),
        Offset(size.width - cornerLen, 0), paint);
    canvas.drawLine(Offset(size.width, 0),
        Offset(size.width, cornerLen), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height),
        Offset(cornerLen, size.height), paint);
    canvas.drawLine(Offset(0, size.height),
        Offset(0, size.height - cornerLen), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - cornerLen, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLen), paint);
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
              child: Icon(
                icon,
                color: const Color(0xFF1A1A1A),
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
