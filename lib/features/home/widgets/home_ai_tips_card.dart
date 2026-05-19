import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeAiTipsCard extends StatefulWidget {
  final String tip;
  final int normalCount;
  final int mediumCount;
  final int highCount;

  const HomeAiTipsCard({
    super.key,
    this.tip =
        'แนะนำให้ทาน Metformin 500mg หลังอาหารเช้า-เย็น และ Atorvastatin 20mg ก่อนนอน ดื่มน้ำเปล่าตาม 1 แก้วทุกครั้ง หลีกเลี่ยงเครื่องดื่มที่มีคาเฟอีนหรือแอลกอฮอล์ระหว่างทานยา และอย่าลืมเตรียมเติมยาก่อนของเดิมหมด',
    this.normalCount = 5,
    this.mediumCount = 2,
    this.highCount = 2,
  });

  @override
  State<HomeAiTipsCard> createState() => _HomeAiTipsCardState();
}

class _HomeAiTipsCardState extends State<HomeAiTipsCard> {
  late final ValueNotifier<bool> _typing;
  static bool _hasPlayedOnce = false;

  static const String _labelText = 'คำแนะนำกินยา';
  static const Duration _titlePerChar = Duration(milliseconds: 80);
  static const Duration _thinkDelay = Duration(seconds: 3);
  static const Duration _afterTitleBuffer = Duration(milliseconds: 200);

  Duration get _tipStartDelay {
    final title = _riskLabel();
    return _thinkDelay +
        _titlePerChar * title.characters.length +
        _afterTitleBuffer;
  }

  bool get _skipAnimation => _hasPlayedOnce;

  @override
  void initState() {
    super.initState();
    _typing = ValueNotifier<bool>(!_skipAnimation);
    if (!_skipAnimation) {
      Future<void>.delayed(_thinkDelay, () {
        if (mounted) _typing.value = false;
      });
    }
  }

  @override
  void dispose() {
    _typing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.white,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -4,
                top: 4,
                width: 110,
                height: 110,
                child: Image.asset(
                  'assets/Pill.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _AiTipsHeaderChip(
                      typing: _typing,
                      labelChild: const Text(
                        _labelText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  _AiInsightCard(
                    riskTitle: _riskLabel(),
                    riskColor: _riskColor(),
                    titleStartDelay: _thinkDelay,
                    titlePerChar: _titlePerChar,
                    tip: widget.tip,
                    tipStartDelay: _tipStartDelay,
                    skipAnimation: _skipAnimation,
                    onTipDone: () => _hasPlayedOnce = true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _riskLabel() {
    if (widget.highCount > 0) return 'อย่าลืมทานยา';
    if (widget.mediumCount > 0) return 'เฝ้าระวังการทานยา';
    return 'ทานยาตรงเวลา';
  }

  Color _riskColor() {
    if (widget.highCount > 0) return AppColors.primary600;
    if (widget.mediumCount > 0) return const Color(0xFFEAAA08);
    return const Color(0xFF2CA989);
  }
}

class _AiInsightCard extends StatelessWidget {
  final String riskTitle;
  final Color riskColor;
  final Duration titleStartDelay;
  final Duration titlePerChar;
  final String tip;
  final Duration tipStartDelay;
  final bool skipAnimation;
  final VoidCallback? onTipDone;

  const _AiInsightCard({
    required this.riskTitle,
    required this.riskColor,
    required this.titleStartDelay,
    required this.titlePerChar,
    required this.tip,
    required this.tipStartDelay,
    required this.skipAnimation,
    required this.onTipDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: riskColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypewriterText(
                  text: riskTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  perChar: titlePerChar,
                  startDelay: titleStartDelay,
                  showCaret: false,
                  skipAnimation: skipAnimation,
                  skeleton: const _AiSkeleton(
                    lines: [_AiSkelLine(width: 140, height: 18)],
                  ),
                ),
                const SizedBox(height: 4),
                _TypewriterText(
                  text: tip,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.45,
                    letterSpacing: 0.2,
                  ),
                  startDelay: tipStartDelay,
                  skipAnimation: skipAnimation,
                  onDone: onTipDone,
                  // Tip skeleton stays until its own typing starts so the
                  // card doesn't collapse during the title-typing gap.
                  skeleton: const _AiSkeleton(
                    lines: [
                      _AiSkelLine(height: 10),
                      _AiSkelLine(height: 10),
                      _AiSkelLine(width: 220, height: 10),
                    ],
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

class _AiSkelLine {
  final double? width;
  final double height;
  const _AiSkelLine({this.width, this.height = 10});
}

class _AiSkeleton extends StatefulWidget {
  final List<_AiSkelLine> lines;
  const _AiSkeleton({required this.lines});

  @override
  State<_AiSkeleton> createState() => _AiSkeletonState();
}

class _AiSkeletonState extends State<_AiSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
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
        final t = _ctrl.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < widget.lines.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              _shimmerBar(widget.lines[i], t, i),
            ],
          ],
        );
      },
    );
  }

  Widget _shimmerBar(_AiSkelLine line, double t, int index) {
    // Slight phase offset per line so they shimmer in a wave.
    final phase = (t + index * 0.12) % 1.0;
    return Container(
      width: line.width,
      height: line.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(line.height / 2),
        gradient: LinearGradient(
          begin: Alignment(-1 - phase * 2, 0),
          end: Alignment(1 - phase * 2 + 1, 0),
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.55),
            const Color(0xFF7BD8B7).withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0.18),
          ],
          stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
        ),
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration perChar;
  final Duration startDelay;
  final bool showCaret;
  final bool skipAnimation;
  final VoidCallback? onDone;
  final Widget? skeleton;
  final Duration? skeletonHideAt;

  const _TypewriterText({
    required this.text,
    required this.style,
    this.perChar = const Duration(milliseconds: 40),
    this.startDelay = const Duration(milliseconds: 200),
    this.showCaret = true,
    this.skipAnimation = false,
    this.onDone,
    this.skeleton,
    this.skeletonHideAt,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with TickerProviderStateMixin {
  late final AnimationController _typeCtrl;
  late final AnimationController _caretCtrl;
  bool _started = false;
  bool _showSkeleton = true;

  @override
  void initState() {
    super.initState();
    final typeDuration = widget.perChar * widget.text.characters.length;
    _typeCtrl = AnimationController(vsync: this, duration: typeDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone?.call();
      });
    _caretCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    if (widget.skipAnimation) {
      _typeCtrl.value = 1.0;
      _started = true;
      _showSkeleton = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDone?.call();
      });
    } else {
      final hideAt = widget.skeletonHideAt ?? widget.startDelay;
      Future<void>.delayed(hideAt, () {
        if (!mounted) return;
        setState(() => _showSkeleton = false);
      });
      Future<void>.delayed(widget.startDelay, () {
        if (!mounted) return;
        setState(() => _started = true);
        _typeCtrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _caretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSkeleton && widget.skeleton != null) {
      return widget.skeleton!;
    }
    if (!_started) {
      return const SizedBox.shrink();
    }
    final chars = widget.text.characters.toList();
    final total = chars.length;
    return AnimatedBuilder(
      animation: Listenable.merge([_typeCtrl, _caretCtrl]),
      builder: (context, _) {
        final revealed = (total * _typeCtrl.value).floor().clamp(0, total);
        final visibleText = chars.take(revealed).join();
        final actuallyTyping = revealed > 0 && revealed < total;
        return RichText(
          text: TextSpan(
            style: widget.style,
            children: [
              TextSpan(text: visibleText),
              if (widget.showCaret && actuallyTyping)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Opacity(
                    opacity: _caretCtrl.value,
                    child: Container(
                      width: 2,
                      height: (widget.style.fontSize ?? 14) * 1.1,
                      margin: const EdgeInsets.only(left: 1),
                      color: AppColors.primary600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AiTipsHeaderChip extends StatefulWidget {
  final ValueListenable<bool> typing;
  final Widget labelChild;

  const _AiTipsHeaderChip({required this.typing, required this.labelChild});

  @override
  State<_AiTipsHeaderChip> createState() => _AiTipsHeaderChipState();
}

class _AiTipsHeaderChipState extends State<_AiTipsHeaderChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const radius = 100.0;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final angle = _ctrl.value * math.pi * 2;
        return IntrinsicWidth(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary600.withValues(alpha: 0.28),
                      blurRadius: 14,
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: const Color(0xFF3FC4A1).withValues(alpha: 0.18),
                      blurRadius: 22,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: SweepGradient(
                    transform: GradientRotation(angle),
                    colors: const [
                      AppColors.primary600,
                      Color(0xFF7BD8B7),
                      Colors.white,
                      Color(0xFF3FC4A1),
                      AppColors.primary600,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(1.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: _ChipContent(
                    angle: angle,
                    typing: widget.typing,
                    labelChild: widget.labelChild,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChipContent extends StatelessWidget {
  final double angle;
  final ValueListenable<bool> typing;
  final Widget labelChild;

  const _ChipContent({
    required this.angle,
    required this.typing,
    required this.labelChild,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3FC4A1), AppColors.primary600],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.auto_awesome,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          labelChild,
          ValueListenableBuilder<bool>(
            valueListenable: typing,
            builder: (_, isTyping, __) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
              child: isTyping
                  ? const Padding(
                      key: ValueKey('dots'),
                      padding: EdgeInsets.only(left: 4),
                      child: _BouncingDots(),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _offsetFor(int i) {
    final phase = (_ctrl.value - i * 0.16) % 1.0;
    if (phase < 0.33) {
      final t = phase / 0.33;
      return -4 * math.sin(t * math.pi);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Transform.translate(
                offset: Offset(0, _offsetFor(i)),
                child: Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary600,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
