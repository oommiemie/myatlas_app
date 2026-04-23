import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/press_effect.dart';

enum _PinStep { set, confirm }

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key, this.pinLength = 6});
  final int pinLength;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with TickerProviderStateMixin {
  _PinStep _step = _PinStep.set;
  String _first = '';
  String _input = '';
  String? _error;

  late final AnimationController _shake;
  late final Animation<double> _shakeAnim;
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shake);
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shake.dispose();
    _breathe.dispose();
    super.dispose();
  }

  String get _title => switch (_step) {
        _PinStep.set => 'กำหนดรหัส PIN',
        _PinStep.confirm => 'ยืนยันรหัส PIN',
      };

  String get _subtitle => switch (_step) {
        _PinStep.set => 'กรุณาตั้งรหัส PIN ${widget.pinLength} หลัก',
        _PinStep.confirm => 'กรอกรหัสอีกครั้งเพื่อยืนยัน',
      };

  void _handleDigit(String d) {
    if (_input.length >= widget.pinLength) return;
    HapticFeedback.selectionClick();
    setState(() {
      _input += d;
      _error = null;
    });
    if (_input.length == widget.pinLength) {
      _complete();
    }
  }

  void _handleDelete() {
    if (_input.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _error = null;
    });
  }

  Future<void> _complete() async {
    if (_step == _PinStep.set) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      HapticFeedback.mediumImpact();
      setState(() {
        _first = _input;
        _input = '';
        _step = _PinStep.confirm;
      });
    } else {
      if (_input == _first) {
        HapticFeedback.heavyImpact();
        if (!mounted) return;
        Navigator.of(context).pop(_input);
      } else {
        HapticFeedback.heavyImpact();
        _shake.forward(from: 0);
        setState(() {
          _error = 'รหัสไม่ตรงกัน กรุณาลองใหม่';
          _input = '';
          _first = '';
          _step = _PinStep.set;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          const Positioned.fill(child: _AuroraBackground()),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _StepIndicator(current: _step == _PinStep.set ? 0 : 1),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  child: Column(
                    key: ValueKey('${_step}_${_error ?? ""}'),
                    children: [
                      _HaloLockIcon(breathe: _breathe),
                      const SizedBox(height: 24),
                      Text(
                        _title,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _error != null
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF6D756E),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) {
                    final t = _shakeAnim.value;
                    double phase;
                    if (t == 0) {
                      phase = 0;
                    } else if (t < 0.25) {
                      phase = t * 4;
                    } else if (t < 0.75) {
                      phase = (0.5 - t) * 4;
                    } else {
                      phase = (t - 1) * 4;
                    }
                    return Transform.translate(
                      offset: Offset(10 * phase, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < widget.pinLength; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _PinDot(filled: i < _input.length),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                _NumberPad(
                  onDigit: _handleDigit,
                  onDelete: _handleDelete,
                  onCancel: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 24),
              ],
            ),
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
              colors: [Color(0xFFE8FAF3), Color(0xFFF4F8F5)],
              stops: [0.0, 0.55],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.9, -0.7),
              radius: 1.1,
              colors: [
                const Color(0xFF8DE4C9).withValues(alpha: 0.45),
                const Color(0xFF8DE4C9).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.1, -0.4),
              radius: 1.0,
              colors: [
                const Color(0xFFB8F3E6).withValues(alpha: 0.6),
                const Color(0xFFB8F3E6).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.3, 0.5),
              radius: 0.8,
              colors: [
                const Color(0xFFC8E8FF).withValues(alpha: 0.28),
                const Color(0xFFC8E8FF).withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HaloLockIcon extends StatelessWidget {
  const _HaloLockIcon({required this.breathe});
  final Animation<double> breathe;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: breathe,
      builder: (_, __) {
        final t = breathe.value;
        final glow = 0.22 + 0.18 * t;
        final ringScale = 1 + 0.08 * t;
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow halo
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1D8B6B).withValues(alpha: glow),
                      const Color(0xFF1D8B6B).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              // Glass ring
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.white.withValues(alpha: 0.5),
                    border: Border.all(
                      color: CupertinoColors.white.withValues(alpha: 0.8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1D8B6B).withValues(alpha: 0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
              // Solid icon bubble
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF26A47E), Color(0xFF12624A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF12624A).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.lock_fill,
                  color: CupertinoColors.white,
                  size: 38,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});
  final int current; // 0-based

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 2; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            width: i == current ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i <= current
                  ? const Color(0xFF1D8B6B)
                  : const Color(0xFF1D8B6B).withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          if (i == 0) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _PinDot extends StatelessWidget {
  const _PinDot({required this.filled});
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: filled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF26A47E), Color(0xFF12624A)],
              )
            : null,
        color: filled ? null : CupertinoColors.white.withValues(alpha: 0.6),
        border: Border.all(
          color: filled
              ? const Color(0xFF1D8B6B)
              : const Color(0xFF1A1A1A).withValues(alpha: 0.22),
          width: 1.4,
        ),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: const Color(0xFF1D8B6B).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onDigit,
    required this.onDelete,
    required this.onCancel,
  });
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    Widget digit(String d) => _PadButton(
          label: d,
          onTap: () => onDigit(d),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [for (final d in row) digit(d)],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Center(
                    child: PressEffect(
                      onTap: onCancel,
                      haptic: HapticKind.selection,
                      scale: 0.9,
                      rippleShape: BoxShape.circle,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Text(
                          'ยกเลิก',
                          style: TextStyle(
                            color: Color(0xFF1D8B6B),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                digit('0'),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Center(
                    child: PressEffect(
                      onTap: onDelete,
                      haptic: HapticKind.none,
                      scale: 0.9,
                      rippleShape: BoxShape.circle,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Icon(
                          CupertinoIcons.delete_left_fill,
                          size: 26,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
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

class _PadButton extends StatelessWidget {
  const _PadButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.none,
      scale: 0.88,
      rippleShape: BoxShape.circle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Frosted backdrop (blur + saturation)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.compose(
                    outer: const ColorFilter.matrix(_padGlassMatrix),
                    inner: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              // 2. Base tint gradient (frosted white)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          CupertinoColors.white.withValues(alpha: 0.72),
                          CupertinoColors.white.withValues(alpha: 0.42),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 3. Specular highlight (top-left)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.55, -0.95),
                        radius: 1.3,
                        colors: [
                          CupertinoColors.white.withValues(alpha: 0.55),
                          CupertinoColors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 4. Glass rim
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _PadRimPainter()),
                ),
              ),
              // 5. Digit label
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const List<double> _padGlassMatrix = <double>[
  1.4722, -0.4290, -0.0432, 0, 0,
  -0.1278, 1.1710, -0.0432, 0, 0,
  -0.1278, -0.4290, 1.5568, 0, 0,
  0, 0, 0, 1, 0,
];

class _PadRimPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          CupertinoColors.white.withValues(alpha: 0.9),
          CupertinoColors.white.withValues(alpha: 0.2),
        ],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _PadRimPainter old) => false;
}
