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
        'จากข้อมูลสุขภาพล่าสุด พบความดันโลหิตและระดับน้ำตาลในเลือดอยู่ในช่วงเสี่ยง แนะนำให้ลดอาหารเค็มและน้ำตาล เพิ่มผักใบเขียวและธัญพืชไม่ขัดสี พร้อมออกกำลังกายระดับปานกลางอย่างน้อย 30 นาที/วัน 5 วัน/สัปดาห์',
    this.normalCount = 5,
    this.mediumCount = 2,
    this.highCount = 2,
  });

  @override
  State<HomeAiTipsCard> createState() => _HomeAiTipsCardState();
}

class _HomeAiTipsCardState extends State<HomeAiTipsCard> {
  // Dots bounce only during the initial "thinking" phase. As soon as the
  // label starts typing we hide them so they don't trail behind the title.
  final ValueNotifier<bool> _typing = ValueNotifier<bool>(true);

  static const String _labelText = 'คำแนะนำจาก AI';
  static const Duration _labelPerChar = Duration(milliseconds: 80);
  static const Duration _thinkDelay = Duration(seconds: 3);
  static const Duration _afterLabelBuffer = Duration(milliseconds: 200);

  Duration get _descStartDelay =>
      _thinkDelay +
      _labelPerChar * _labelText.characters.length +
      _afterLabelBuffer;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_thinkDelay, () {
      if (mounted) _typing.value = false;
    });
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AiTipsHeaderChip(
            typing: _typing,
            labelChild: _TypewriterText(
              text: _labelText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              perChar: _labelPerChar,
              startDelay: _thinkDelay,
              showCaret: false,
            ),
          ),
          const SizedBox(height: 8),
          _TypewriterText(
            text: widget.tip,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 24 / 14,
              letterSpacing: 0.3,
              wordSpacing: 1.5,
            ),
            startDelay: _descStartDelay,
          ),
          const SizedBox(height: 16),
          _RiskBarsRow(
            normal: widget.normalCount,
            medium: widget.mediumCount,
            high: widget.highCount,
          ),
          const SizedBox(height: 8),
          const _HealthMetricsRow(),
        ],
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
  final VoidCallback? onDone;

  const _TypewriterText({
    required this.text,
    required this.style,
    this.perChar = const Duration(milliseconds: 40),
    this.startDelay = const Duration(milliseconds: 200),
    this.showCaret = true,
    this.onDone,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with TickerProviderStateMixin {
  late final AnimationController _typeCtrl;
  late final AnimationController _caretCtrl;

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

    Future<void>.delayed(widget.startDelay, () {
      if (mounted) _typeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _caretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.characters.toList();
    final total = chars.length;
    return AnimatedBuilder(
      animation: Listenable.merge([_typeCtrl, _caretCtrl]),
      builder: (context, _) {
        final revealed = (total * _typeCtrl.value).floor().clamp(0, total);
        final visibleText = chars.take(revealed).join();
        // Caret appears only during active typing, not during start delay or
        // after completion.
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
              // Outer ambient glow that breathes with the light
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
              // Rotating gradient border — the running light
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
    // Each dot's phase is offset by 1/6 of the cycle (staggered wave).
    final phase = (_ctrl.value - i * 0.16) % 1.0;
    // One quick bounce in the first third, then rest.
    if (phase < 0.33) {
      final t = phase / 0.33; // 0..1
      // Sine: goes up then back down
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

class _RiskBarsRow extends StatelessWidget {
  final int normal;
  final int medium;
  final int high;

  const _RiskBarsRow({
    required this.normal,
    required this.medium,
    required this.high,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _RiskBarBlock(
            label: 'ปกติ $normal',
            color: AppColors.success600,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 70,
          child: _RiskBarBlock(
            label: 'ปานกลาง $medium',
            color: const Color(0xFFEAAA08),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 70,
          child: _RiskBarBlock(
            label: 'เสี่ยง $high',
            color: const Color(0xFFE62E05),
          ),
        ),
      ],
    );
  }
}

class _RiskBarBlock extends StatelessWidget {
  final String label;
  final Color color;

  const _RiskBarBlock({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}

class _HealthMetricsRow extends StatelessWidget {
  const _HealthMetricsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HealthMetricChip(
          icon: Icons.monitor_heart_outlined,
          label: 'ความดันโลหิต',
          value: '120/80',
          unit: 'mmHg',
        ),
        const SizedBox(width: 8),
        _HealthMetricChip(
          icon: Icons.water_drop_outlined,
          label: 'ค่าน้ำตาลในเลือด',
          value: '110',
          unit: 'mg/dL',
        ),
      ],
    );
  }
}

class _HealthMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _HealthMetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFBC1B06),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE62E05),
                  ),
                ),
                const TextSpan(text: ' ', style: TextStyle(fontSize: 11)),
                TextSpan(
                  text: unit,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
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
