import 'dart:math' as math;

import 'package:flutter/material.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _BackgroundDecor(),
                    _PhoneMockup(),
                  ],
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
                    _RegisterFooter(onTap: () => _enterApp(context)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
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
          'My Atlas',
          style: TextStyle(
            fontFamily: 'Google Sans',
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
            fontFamily: 'Google Sans',
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
              fontFamily: 'Google Sans',
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
            fontFamily: 'Google Sans',
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

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (_, constraints) {
            // Figma decoration zone: 440 x 593 (frame width × y of title block).
            // Map normalized coords to actual zone size.
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return Stack(
              children: [
                // Top-left — Health (vital)
                Positioned(
                  left: 0.127 * w,
                  top: 0.135 * h,
                  child: _FeatureCircle(
                    size: 0.218 * w,
                    asset: 'assets/vital.png',
                  ),
                ),
                // Top-right — Family
                Positioned(
                  left: 0.83 * w,
                  top: 0.05 * h,
                  child: _FeatureCircle(
                    size: 0.115 * w,
                    asset: 'assets/fam.png',
                  ),
                ),
                // Mid-left — Medicine
                Positioned(
                  left: 0.036 * w,
                  top: 0.462 * h,
                  child: _FeatureCircle(
                    size: 0.186 * w,
                    asset: 'assets/med.png',
                  ),
                ),
                // Bottom-left — Nutrition (kcal)
                Positioned(
                  left: 0.18 * w,
                  top: 0.74 * h,
                  child: _FeatureCircle(
                    size: 0.16 * w,
                    asset: 'assets/kcal.png',
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

class _FeatureCircle extends StatefulWidget {
  final double size;
  final String asset;
  const _FeatureCircle({required this.size, required this.asset});

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
            child: Image.asset(
              widget.asset,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -236,
      bottom: -50,
      child: Image.asset(
        'assets/loginimage.png',
        width: 490,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}
