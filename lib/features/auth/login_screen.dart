import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../shell/main_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _enterApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF104F3C), Color(0xFF1D8B6B)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Faint BMS watermark behind the title / login block.
              const _BmsWatermark(),
              Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                // The decor widget also draws the phone, so orbiting circles
                // can pass both behind and in front of it.
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [_BackgroundDecor()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _TitleBlock(),
                    const SizedBox(height: 24),
                    _HealthIdButton(onTap: () => _enterApp(context)),
                    const SizedBox(height: 24),
                    const _OrDivider(),
                    const SizedBox(height: 24),
                    _SocialRow(onTap: () => _enterApp(context)),
                    const SizedBox(height: 24),
                    Text(
                      'เวอร์ชัน 1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Large, very faint BMS logo sitting behind the login artwork.
class _BmsWatermark extends StatelessWidget {
  const _BmsWatermark();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (_, c) {
            final w = c.maxWidth;
            // Square watermark wider than the screen so it bleeds off both
            // sides, pushed down so the bottom is cropped too.
            final size = w * 0.95;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: (w - size) / 2,
                  bottom: size * 0.40,
                  width: size,
                  height: size,
                  child: Opacity(
                    opacity: 0.18,
                    // Fade the watermark out toward its bottom edge.
                    child: ShaderMask(
                      shaderCallback: (r) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFFFFFFF),
                          Color(0x00FFFFFF),
                        ],
                        stops: [0.0, 0.28, 1.0],
                      ).createShader(r),
                      blendMode: BlendMode.dstIn,
                      // Group logo on a white disc, like the orbit chip.
                      child: Container(
                        padding: EdgeInsets.all(size * 0.13),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: SvgPicture.asset(
                          'assets/logo_bmsgroup.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MyAtlas',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Thai Looped',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.textInverse,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ข้อมูลสุขภาพของคุณ ทั้งหมดในที่เดียว ติดตามสัญญาณชีพ '
          'รับการแจ้งเตือนเรื่องยา และนับแคลอรี่',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Thai Looped',
            fontSize: 14,
            height: 24 / 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _HealthIdButton extends StatelessWidget {
  final VoidCallback onTap;
  const _HealthIdButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D8B6B), Color(0xFFECDB59)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: onTap,
              child: const Center(child: _HealthIdLogo()),
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthIdLogo extends StatelessWidget {
  const _HealthIdLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/healthid.png',
      height: 26,
      fit: BoxFit.contain,
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final lineColor = Colors.white.withValues(alpha: 0.4);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'หรือ เข้าสู่ระบบโดย',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Thai Looped',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  final VoidCallback onTap;
  const _SocialRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            child: Image.asset('assets/google.png', height: 22),
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            child: Image.asset('assets/facebook.png', height: 22),
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset('assets/line.png', height: 22, width: 22),
            ),
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            child: Image.asset('assets/apple.png', height: 22),
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _SocialButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Material(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white, width: 0.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _RegisterFooter extends StatelessWidget {
  final VoidCallback onTap;
  const _RegisterFooter({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Thai Looped',
            fontSize: 12,
            color: Colors.white,
          ),
          children: [
            TextSpan(text: 'คุณมีบัญชีหรือยัง? ถ้ายัง มาลงทะเบียนกันเถอะ! '),
            TextSpan(
              text: 'ลงทะเบียน',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Orbit ring geometry (tweak these to adjust the Saturn-ring layout) ──────
const double _kOrbitCx = 0.555; // ring centre X (fraction of width)
const double _kOrbitCy = 0.460; // ring centre Y (fraction of height)
const double _kOrbitRx = 0.490; // horizontal radius (fraction of width)
const double _kOrbitRy = 0.050; // vertical radius (fraction of height)
const double _kOrbitTilt = -1.043; // ring tilt, radians

class _BackgroundDecor extends StatefulWidget {
  const _BackgroundDecor();

  @override
  State<_BackgroundDecor> createState() => _BackgroundDecorState();
}

class _BackgroundDecorState extends State<_BackgroundDecor>
    with SingleTickerProviderStateMixin {
  // Slow, continuous revolution around the phone.
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 44),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: IgnorePointer(child: _ring()));
  }

  Widget _ring() {
    return LayoutBuilder(
          builder: (_, constraints) {
            // Figma decoration zone: 440 x 593 (frame width × y of title block).
            // Map normalized coords to actual zone size.
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // Saturn-style ring: the circles revolve on a wide, squashed,
            // tilted ellipse centred on the phone (geometry consts above).
            const cxF = _kOrbitCx, cyF = _kOrbitCy;
            const rxF = _kOrbitRx, ryF = _kOrbitRy;
            const tilt = _kOrbitTilt;

            return AnimatedBuilder(
              animation: _spin,
              builder: (_, __) {
                final spin = _spin.value * 360.0;
                // (sinA, widget) — sinA < 0 means the upper (near) half of the
                // ring, which is drawn in front of the phone and scaled up.
                final items = <(double, Widget)>[];

                void orbit(
                  double deg,
                  double sizeF,
                  String asset, {
                  bool circleBg = false,
                }) {
                  final a = (deg + spin) * math.pi / 180;
                  final sinA = math.sin(a);
                  final ex = rxF * w * math.cos(a);
                  final ey = ryF * h * sinA;
                  final dx = ex * math.cos(tilt) - ey * math.sin(tilt);
                  final dy = ex * math.sin(tilt) + ey * math.cos(tilt);
                  // Top of the ring = nearest → largest; bottom = farthest.
                  final depth = 0.52 + 0.86 * ((1 - sinA) / 2);
                  final s = sizeF * w * depth;
                  items.add((
                    sinA,
                    Positioned(
                      // Keyed by asset so re-ordering between the front/back
                      // layers doesn't reassign State (which looked like a
                      // sudden jump backwards).
                      key: ValueKey(asset),
                      // No clamping — clamping pins circles at the frame edge
                      // and makes the orbit stutter. The radii below are sized
                      // so the whole ring stays in frame.
                      left: cxF * w + dx - s / 2,
                      top: cyF * h + dy - s / 2,
                      // Distant circles also fade back slightly, which sells
                      // the depth more than scale alone.
                      child: Opacity(
                        opacity: 0.62 + 0.38 * ((1 - sinA) / 2),
                        child: _FeatureCircle(
                          size: s,
                          asset: asset,
                          circleBg: circleBg,
                        ),
                      ),
                    ),
                  ));
                }

                // Evenly spaced around the ring so they revolve in formation.
                // The ring emerges from behind the phone at 180° and reaches
                // its nearest point at 270°. The brand logos start just past
                // 180° so they ride the whole front arc instead of being
                // swept away straight after the screen opens.
                orbit(190, 0.15, 'assets/logo_bmsgroup.svg', circleBg: true);
                orbit(250, 0.145, 'assets/logoMyAtlascare.png', circleBg: true);
                orbit(310, 0.13, 'assets/fam.png');
                orbit(10, 0.17, 'assets/vital.png');
                orbit(70, 0.15, 'assets/med.png');
                orbit(130, 0.14, 'assets/kcal.png');

                // Far half behind the phone, near half in front of it.
                final far = [
                  for (final it in items)
                    if (it.$1 >= 0) it.$2,
                ];
                final near = [
                  for (final it in items)
                    if (it.$1 < 0) it.$2,
                ];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ...far,
                    const _PhoneMockup(),
                    ...near,
                  ],
                );
              },
            );
          },
    );
  }
}

class _FeatureCircle extends StatefulWidget {
  final double size;
  final String asset;

  /// Wraps the asset in a glossy silver sphere (for logos with no backdrop).
  final bool circleBg;
  const _FeatureCircle({
    required this.size,
    required this.asset,
    this.circleBg = false,
  });

  @override
  State<_FeatureCircle> createState() => _FeatureCircleState();
}

class _FeatureCircleState extends State<_FeatureCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final double _phase;

  @override
  void initState() {
    super.initState();
    _phase = (widget.size * 13.7) % 1.0;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final dy = math.sin((_ctrl.value + _phase) * 2 * math.pi) * 5;
        return Transform.translate(
          offset: Offset(0, dy),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: widget.circleBg
                ? Container(
                    padding: EdgeInsets.all(widget.size * 0.13),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Glossy silver sphere, matching the BMS icon's look.
                      gradient: const RadialGradient(
                        center: Alignment(-0.3, -0.4),
                        radius: 0.95,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFF1F3F5),
                          Color(0xFFDCE1E5),
                          Color(0xFFC2C9CF),
                        ],
                        stops: [0.0, 0.45, 0.8, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _assetImage(widget.asset),
                  )
                : _assetImage(widget.asset),
          ),
        );
      },
    );
  }

  /// Renders either raster or SVG assets with the same contain fit.
  Widget _assetImage(String asset) => asset.endsWith('.svg')
      ? SvgPicture.asset(asset, fit: BoxFit.contain)
      : Image.asset(asset, fit: BoxFit.contain);
}

// ignore: unused_element
class _BmsBadge extends StatelessWidget {
  const _BmsBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 34,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SvgPicture.asset(
          'assets/logo_bmsgroup.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -236,
      bottom: -80,
      child: Image.asset(
        'assets/hand.png',
        width: 490,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}
