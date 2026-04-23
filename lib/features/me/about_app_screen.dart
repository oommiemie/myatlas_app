import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/widgets/liquid_glass_button.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _orbit;
  late final AnimationController _breathe;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _orbit.dispose();
    _breathe.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          const Positioned.fill(child: _AuroraBackground()),
          // Twinkling star particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _float,
              builder: (_, __) => _TwinkleStars(phase: _float.value),
            ),
          ),
          // Concentric orbital rings — counter-rotating pair
          Center(
            child: AnimatedBuilder(
              animation: _orbit,
              builder: (_, __) => Transform.rotate(
                angle: _orbit.value * 2 * math.pi * 0.2,
                child: const _OrbitalRings(),
              ),
            ),
          ),
          // Iridescent shimmer ring around hero
          Center(
            child: AnimatedBuilder(
              animation: _orbit,
              builder: (_, __) => Transform.rotate(
                angle: -_orbit.value * 2 * math.pi * 0.5,
                child: CustomPaint(
                  size: const Size(260, 260),
                  painter: _IridescentRingPainter(),
                ),
              ),
            ),
          ),
          // Hero app icon centered
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_enter, _breathe]),
              builder: (_, __) {
                final t = Curves.easeOutBack.transform(_enter.value);
                return Transform.scale(
                  scale: t,
                  child: Opacity(
                    opacity: _enter.value,
                    child: _HeroBadge(breathe: _breathe),
                  ),
                );
              },
            ),
          ),
          // Pinned top bar — transparent, centered title (like Settings)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'เกี่ยวกับแอปพลิเคชั่น',
                      style: TextStyle(
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
                        onTap: () => Navigator.of(context).pop(),
                        size: 40,
                        iconSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Frosted glass footer panel
          const Align(
            alignment: Alignment.bottomCenter,
            child: _AboutFooter(),
          ),
        ],
      ),
    );
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEDFAF3), Color(0xFFF4F8F5)],
              stops: [0.0, 0.6],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.25),
              radius: 1.0,
              colors: [
                const Color(0xFFBEE7DB).withValues(alpha: 0.6),
                const Color(0xFFBEE7DB).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1.0, 0.2),
              radius: 0.9,
              colors: [
                const Color(0xFFA5B4FC).withValues(alpha: 0.32),
                const Color(0xFFA5B4FC).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.0, -0.1),
              radius: 0.9,
              colors: [
                const Color(0xFFFBCFE8).withValues(alpha: 0.32),
                const Color(0xFFFBCFE8).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.3, 0.4),
              radius: 0.7,
              colors: [
                const Color(0xFFFDE68A).withValues(alpha: 0.28),
                const Color(0xFFFDE68A).withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TwinkleStars extends StatelessWidget {
  const _TwinkleStars({required this.phase});
  final double phase;

  static const _stars =
      <({double x, double y, double size, double phase, Color color})>[
    (x: 0.08, y: 0.10, size: 2.5, phase: 0.00, color: Color(0xFFFACC15)),
    (x: 0.22, y: 0.06, size: 3.5, phase: 0.15, color: Color(0xFF1D8B6B)),
    (x: 0.42, y: 0.09, size: 2.0, phase: 0.30, color: Color(0xFFEC4899)),
    (x: 0.70, y: 0.08, size: 3.0, phase: 0.45, color: Color(0xFF2563EB)),
    (x: 0.88, y: 0.14, size: 2.5, phase: 0.10, color: Color(0xFFFACC15)),
    (x: 0.05, y: 0.32, size: 2.0, phase: 0.60, color: Color(0xFF1D8B6B)),
    (x: 0.95, y: 0.28, size: 2.5, phase: 0.75, color: Color(0xFFA855F7)),
    (x: 0.15, y: 0.48, size: 3.5, phase: 0.25, color: Color(0xFFEC4899)),
    (x: 0.85, y: 0.50, size: 3.0, phase: 0.55, color: Color(0xFFFACC15)),
    (x: 0.03, y: 0.62, size: 2.5, phase: 0.85, color: Color(0xFF2563EB)),
    (x: 0.97, y: 0.68, size: 2.0, phase: 0.40, color: Color(0xFF1D8B6B)),
    (x: 0.25, y: 0.75, size: 2.5, phase: 0.65, color: Color(0xFFFACC15)),
    (x: 0.50, y: 0.05, size: 2.0, phase: 0.90, color: Color(0xFF0EA5E9)),
    (x: 0.60, y: 0.44, size: 2.0, phase: 0.20, color: Color(0xFFFACC15)),
    (x: 0.38, y: 0.58, size: 2.0, phase: 0.70, color: Color(0xFF1D8B6B)),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (_, c) => Stack(
          children: [
            for (final s in _stars)
              Positioned(
                left: s.x * c.maxWidth - s.size,
                top: s.y * c.maxHeight - s.size,
                child: Opacity(
                  opacity: 0.4 +
                      0.6 *
                          ((math.sin((phase + s.phase) * 2 * math.pi) + 1) /
                              2),
                  child: Container(
                    width: s.size * 2,
                    height: s.size * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.color,
                      boxShadow: [
                        BoxShadow(
                          color: s.color.withValues(alpha: 0.7),
                          blurRadius: s.size * 3,
                        ),
                      ],
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

class _IridescentRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = SweepGradient(
        colors: [
          const Color(0xFFEC4899).withValues(alpha: 0.75),
          const Color(0xFFFACC15).withValues(alpha: 0.75),
          const Color(0xFF1D8B6B).withValues(alpha: 0.75),
          const Color(0xFF2563EB).withValues(alpha: 0.75),
          const Color(0xFFA855F7).withValues(alpha: 0.75),
          const Color(0xFFEC4899).withValues(alpha: 0.75),
        ],
        stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _IridescentRingPainter old) => false;
}

class _OrbitalRings extends StatelessWidget {
  const _OrbitalRings();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 720,
      height: 720,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < 6; i++)
            _GradientRing(
              size: 720 - i * 80.0,
              opacity: 0.55 - i * 0.06,
            ),
        ],
      ),
    );
  }
}

class _GradientRing extends StatelessWidget {
  const _GradientRing({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GradientRingPainter(opacity: opacity),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          const Color(0xFFBEE7DB).withValues(alpha: opacity),
          const Color(0xFF2BB892).withValues(alpha: opacity * 0.5),
          const Color(0xFFBEE7DB).withValues(alpha: opacity * 0.2),
          const Color(0xFFBEE7DB).withValues(alpha: opacity),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter old) =>
      old.opacity != opacity;
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.breathe});
  final Animation<double> breathe;

  @override
  Widget build(BuildContext context) {
    final t = breathe.value;
    final glowAlpha = 0.20 + 0.18 * t;
    final scale = 1 + 0.04 * t;
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer breathing halo
          Transform.scale(
            scale: 1 + 0.08 * t,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1D8B6B).withValues(alpha: glowAlpha),
                    const Color(0xFF1D8B6B).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Mid frosted ring
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CupertinoColors.white.withValues(alpha: 0.35),
                  CupertinoColors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          // Hero illustration from Figma (breathes)
          Transform.scale(
            scale: scale,
            child: Image.asset(
              'assets/images/me/about_hero.png',
              width: 168,
              height: 168,
              fit: BoxFit.contain,
            ),
          ),
          // Sparkle accent top-right
          Positioned(
            top: 30 - 6 * t,
            right: 34,
            child: Opacity(
              opacity: 0.45 + 0.4 * t,
              child: const Icon(
                CupertinoIcons.sparkles,
                color: Color(0xFF2BB892),
                size: 18,
              ),
            ),
          ),
          Positioned(
            bottom: 28 + 4 * t,
            left: 36,
            child: Opacity(
              opacity: 0.3 + 0.5 * (1 - t),
              child: const Icon(
                CupertinoIcons.sparkles,
                color: Color(0xFFFACC15),
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _AboutFooter extends StatelessWidget {
  const _AboutFooter();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                CupertinoColors.white.withValues(alpha: 0.9),
                CupertinoColors.white.withValues(alpha: 0),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0E5B44),
                        Color(0xFF2BB892),
                        Color(0xFF1D8B6B),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(rect),
                    child: const Text(
                      'My Atlas',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Application',
                    style: TextStyle(
                      color: Color(0xFF3E453F),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CupertinoColors.white.withValues(alpha: 0.9),
                          CupertinoColors.white.withValues(alpha: 0.55),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: CupertinoColors.white,
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D8B6B).withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          CupertinoIcons.sparkles,
                          size: 12,
                          color: Color(0xFF1D8B6B),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Version 3.0.0',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: Color(0xFF3E453F),
                        fontSize: 14,
                        height: 26 / 14,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'อยากรู้จักเรามากขึ้น คุณสามารถดูรายละเอียดเพิ่มเติมเกี่ยวกับบริการและแนวคิดของเราได้ที่ ',
                        ),
                        TextSpan(
                          text: 'เว็บไซต์',
                          style: TextStyle(
                            color: Color(0xFF2463EB),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' ซึ่งมีข้อมูลครบถ้วนให้คุณสำรวจได้อย่างสะดวกและรวดเร็ว',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        CupertinoIcons.news,
                        size: 12,
                        color: Color(0xFF6D756E),
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '2026 HealthFlow — All rights reserved. ดูแลสุขภาพของคุณไปกับเรา',
                          style: TextStyle(
                            color: Color(0xFF3E453F),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
