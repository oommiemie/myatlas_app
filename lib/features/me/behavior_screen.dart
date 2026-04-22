import 'package:flutter/cupertino.dart';

import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';

class BehaviorScreen extends StatefulWidget {
  const BehaviorScreen({super.key});

  @override
  State<BehaviorScreen> createState() => _BehaviorScreenState();
}

class _BehaviorScreenState extends State<BehaviorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  bool _trackNutrition = true;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _stagger(int i, int total, Widget child) {
    final start = (i / total) * 0.5;
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
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC084FC), Color(0xFF7C3AED)],
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      LiquidGlassButton(
                        icon: CupertinoIcons.chevron_back,
                        iconColor: const Color(0xFF1A1A1A),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'พฤติกรรมผู้ใช้งาน',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F8F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    _stagger(0, 3, const _IntroCard()),
                    const SizedBox(height: 8),
                    _stagger(
                      1,
                      3,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(
                          'กำหนด',
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    _stagger(
                      2,
                      3,
                      Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _SettingRow(
                              iconColor: const Color(0xFF1D8B6B),
                              icon: CupertinoIcons.capsule_fill,
                              label: 'เตือนให้ทานก่อน',
                              value: '30 นาที',
                              onTap: () {},
                            ),
                            Container(
                              height: 1,
                              color: const Color(0xFFE5E5E5),
                            ),
                            _ToggleRow(
                              iconColor: const Color(0xFF2563EB),
                              icon: CupertinoIcons.square_fill_line_vertical_square_fill,
                              label: 'ติดตามโภชนาการ',
                              value: _trackNutrition,
                              onChanged: (v) =>
                                  setState(() => _trackNutrition = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'ให้เราช่วยดูแลสุขภาพของคุณ เพียงตั้งเวลาอาหารและเวลานอน ระบบจะช่วยเตือนทุกอย่างให้ตรงเวลา',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0.14,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 300,
              height: 300,
              child: _DayPie(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPie extends StatelessWidget {
  const _DayPie();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: const [
        // Top-left: Morning
        Positioned(
          left: 0,
          top: 0,
          child: _Quadrant(
            corner: _QuadrantCorner.topLeft,
            gradientBegin: Alignment.bottomRight,
            gradientEnd: Alignment.topLeft,
            colors: [Color(0xFFB9E6FE), Color(0xFF7CD4FD)],
            orb: _OrbStyle.sun,
          ),
        ),
        // Top-right: Noon
        Positioned(
          right: 0,
          top: 0,
          child: _Quadrant(
            corner: _QuadrantCorner.topRight,
            gradientBegin: Alignment.bottomLeft,
            gradientEnd: Alignment.topRight,
            colors: [Color(0xFFFFD6AE), Color(0xFFFF9C66)],
            orb: _OrbStyle.noon,
          ),
        ),
        // Bottom-left: Night (sleep)
        Positioned(
          left: 0,
          bottom: 0,
          child: _Quadrant(
            corner: _QuadrantCorner.bottomLeft,
            gradientBegin: Alignment.topRight,
            gradientEnd: Alignment.bottomLeft,
            colors: [Color(0xFF065986), Color(0xFF0B4A6F)],
            orb: _OrbStyle.moon,
          ),
        ),
        // Bottom-right: Evening
        Positioned(
          right: 0,
          bottom: 0,
          child: _Quadrant(
            corner: _QuadrantCorner.bottomRight,
            gradientBegin: Alignment.topLeft,
            gradientEnd: Alignment.bottomRight,
            colors: [Color(0xFFC7D2FE), Color(0xFF818CF8)],
            orb: _OrbStyle.dusk,
          ),
        ),
        // Time pills — matching Figma positions (pill bottom at y=124 for
        // top row, y=274 for bottom row; centered within 150-wide half)
        Positioned(
          left: 0,
          width: 150,
          top: 90,
          child: Center(child: _TimePill(text: 'เมื้อเช้า  06:20 น.')),
        ),
        Positioned(
          right: 0,
          width: 150,
          top: 90,
          child: Center(child: _TimePill(text: 'เมื้อกลางวัน  12:00 น.')),
        ),
        Positioned(
          left: 0,
          width: 150,
          bottom: 26,
          child: Center(child: _TimePill(text: 'เวลานอน  22:00 น.')),
        ),
        Positioned(
          right: 0,
          width: 150,
          bottom: 26,
          child: Center(child: _TimePill(text: 'เมื้อเย็น  19:00 น.')),
        ),
      ],
    );
  }
}

enum _QuadrantCorner { topLeft, topRight, bottomLeft, bottomRight }

enum _OrbStyle { sun, noon, moon, dusk }

class _Quadrant extends StatelessWidget {
  const _Quadrant({
    required this.corner,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.colors,
    required this.orb,
  });

  final _QuadrantCorner corner;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final List<Color> colors;
  final _OrbStyle orb;

  BorderRadius get _radius => switch (corner) {
        _QuadrantCorner.topLeft => const BorderRadius.only(
            topLeft: Radius.circular(1000),
          ),
        _QuadrantCorner.topRight => const BorderRadius.only(
            topRight: Radius.circular(1000),
          ),
        _QuadrantCorner.bottomLeft => const BorderRadius.only(
            bottomLeft: Radius.circular(1000),
          ),
        _QuadrantCorner.bottomRight => const BorderRadius.only(
            bottomRight: Radius.circular(1000),
          ),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: _radius,
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: colors,
          stops: const [0.3, 1.0],
        ),
        border: Border.all(color: CupertinoColors.white, width: 1),
      ),
      child: _OrbDecoration(orb: orb),
    );
  }
}

class _OrbDecoration extends StatelessWidget {
  const _OrbDecoration({required this.orb});
  final _OrbStyle orb;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 70,
        height: 70,
        child: _buildOrb(),
      ),
    );
  }

  Widget _buildOrb() {
    switch (orb) {
      case _OrbStyle.sun:
        return _concentricOrb(
          outer: CupertinoColors.white.withValues(alpha: 0.5),
          mid: CupertinoColors.white.withValues(alpha: 0.55),
          inner: const Color(0xFFFFFDF0),
        );
      case _OrbStyle.noon:
        return _concentricOrb(
          outer: const Color(0xFFFFFCDB).withValues(alpha: 0.5),
          mid: const Color(0xFFFFFCDB).withValues(alpha: 0.55),
          inner: CupertinoColors.white,
        );
      case _OrbStyle.moon:
        return _concentricOrb(
          outer: CupertinoColors.white.withValues(alpha: 0.2),
          mid: CupertinoColors.white.withValues(alpha: 0.28),
          inner: CupertinoColors.white.withValues(alpha: 0.95),
          crescent: true,
        );
      case _OrbStyle.dusk:
        return _concentricOrb(
          outer: const Color(0xFFE3D8F8).withValues(alpha: 0.5),
          mid: const Color(0xFFE3D8F8).withValues(alpha: 0.55),
          inner: CupertinoColors.white,
        );
    }
  }

  Widget _concentricOrb({
    required Color outer,
    required Color mid,
    required Color inner,
    bool crescent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: outer,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: mid,
        ),
        child: crescent
            ? ClipOval(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: inner,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -6,
                      top: -4,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0B4A6F),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inner,
                ),
              ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.clock,
            size: 12,
            color: CupertinoColors.white,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.99,
      dim: 0.96,
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
              child: Icon(icon, color: CupertinoColors.white, size: 12),
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
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
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

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final Color iconColor;
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Icon(icon, color: CupertinoColors.white, size: 12),
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
          CupertinoSwitch(
            value: value,
            activeTrackColor: const Color(0xFF34C759),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
