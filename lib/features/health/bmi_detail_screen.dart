import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/theme/app_typography.dart';
import '../../core/widgets/liquid_glass_button.dart';

class _BmiPoint {
  const _BmiPoint({
    required this.day,
    required this.month,
    required this.weight,
    required this.height,
  });
  final int day;
  final String month;
  final double weight;
  final double height;

  String get dateLabel => '$day $month';

  int get absoluteDay {
    const monthIndex = {
      'ม.ค. 69': 0,
      'ก.พ. 69': 31,
      'มี.ค. 69': 59,
      'เม.ย. 69': 90,
      'พ.ค. 69': 120,
      'มิ.ย. 69': 151,
      'ก.ค. 69': 181,
      'ส.ค. 69': 212,
      'ก.ย. 69': 243,
      'ต.ค. 69': 273,
      'พ.ย. 69': 304,
      'ธ.ค. 69': 334,
    };
    return (monthIndex[month] ?? 0) + day;
  }
}

const _bmiPoints = <_BmiPoint>[
  _BmiPoint(day: 5, month: 'ก.พ. 69', weight: 64, height: 174),
  _BmiPoint(day: 12, month: 'ก.พ. 69', weight: 63, height: 174),
  _BmiPoint(day: 19, month: 'ก.พ. 69', weight: 63, height: 174),
  _BmiPoint(day: 26, month: 'ก.พ. 69', weight: 62, height: 175),
  _BmiPoint(day: 4, month: 'มี.ค. 69', weight: 62, height: 175),
  _BmiPoint(day: 10, month: 'มี.ค. 69', weight: 61, height: 175),
  _BmiPoint(day: 16, month: 'มี.ค. 69', weight: 61, height: 175),
  _BmiPoint(day: 23, month: 'มี.ค. 69', weight: 62, height: 175),
  _BmiPoint(day: 29, month: 'มี.ค. 69', weight: 60, height: 175),
  _BmiPoint(day: 1, month: 'เม.ย. 69', weight: 58, height: 175),
  _BmiPoint(day: 3, month: 'เม.ย. 69', weight: 59, height: 175),
  _BmiPoint(day: 5, month: 'เม.ย. 69', weight: 62, height: 175),
  _BmiPoint(day: 7, month: 'เม.ย. 69', weight: 61, height: 175),
  _BmiPoint(day: 9, month: 'เม.ย. 69', weight: 60, height: 175),
  _BmiPoint(day: 11, month: 'เม.ย. 69', weight: 60, height: 175),
];

class BmiDetailScreen extends StatefulWidget {
  const BmiDetailScreen({super.key});

  @override
  State<BmiDetailScreen> createState() => _BmiDetailScreenState();
}

class _BmiDetailScreenState extends State<BmiDetailScreen> {
  int _metricTab = 0;
  int? _selectedIndex;

  void _showBmiInfoSheet(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => const _BmiInfoSheet(),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: const _HeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(
                  onBack: () => Navigator.of(context).pop(),
                  onAdd: () {},
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F8F5),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        _BmiChartCard(
                          metricTab: _metricTab,
                          onMetricChange: (i) =>
                              setState(() => _metricTab = i),
                          selectedIndex: _selectedIndex,
                          onSelect: (idx) =>
                              setState(() => _selectedIndex = idx),
                        ),
                        const SizedBox(height: 16),
                        _AboutBmiCard(
                          onTap: () => _showBmiInfoSheet(context),
                        ),
                        const SizedBox(height: 16),
                        const _OptionLabel(),
                        const SizedBox(height: 10),
                        const _HighlightOption(),
                        const SizedBox(height: 16),
                        const _SettingsCard(),
                      ],
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

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.2, -0.5),
          radius: 1.2,
          colors: [
            Color(0xFF6FC2A0),
            Color(0xFF3FA880),
            Color(0xFF1D8B6B),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onAdd});
  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Row(
        children: [
          LiquidGlassButton(
            icon: CupertinoIcons.chevron_back,
            onTap: onBack,
          ),
          const SizedBox(width: 10),
          Text(
            'Body Mass Index',
            style: AppTypography.title3(CupertinoColors.white).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          LiquidGlassButton(
            icon: CupertinoIcons.plus,
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}


class _BmiChartCard extends StatelessWidget {
  const _BmiChartCard({
    required this.metricTab,
    required this.onMetricChange,
    required this.selectedIndex,
    required this.onSelect,
  });
  final int metricTab;
  final ValueChanged<int> onMetricChange;
  final int? selectedIndex;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    final latest = _bmiPoints.last;
    final activeIdx =
        (selectedIndex ?? _bmiPoints.length - 1).clamp(0, _bmiPoints.length - 1);
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _BmiGaugeSection(
              bmi: _computeBmi(latest.weight, latest.height),
              weight: latest.weight.round(),
              height: latest.height.round(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _SegmentedTabs(
              tabs: const ['น้ำหนัก', 'ส่วนสูง'],
              selected: metricTab,
              onChange: onMetricChange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _MetricValueDisplay(
              metricTab: metricTab,
              activeIdx: activeIdx,
              isSelected: selectedIndex != null,
            ),
          ),
          SizedBox(
            height: 216,
            child: _MetricAreaChart(
              metricTab: metricTab,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static double _computeBmi(double weight, double height) {
    final h = height / 100;
    return weight / (h * h);
  }
}

class _BmiGaugeSection extends StatelessWidget {
  const _BmiGaugeSection({
    required this.bmi,
    required this.weight,
    required this.height,
  });
  final double bmi;
  final int weight;
  final int height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 236,
          height: 132,
          child: CustomPaint(
            painter: _BmiGaugePainter(bmi: bmi),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: AppTypography.title2(CupertinoColors.black)
                          .copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _GaugeBadge(
                      label: bmi < 18.5 || bmi > 23 ? 'ผิดปกติ' : 'ปกติ',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: weight.toString(),
                  label: 'น้ำหนัก (kg)',
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: const Color(0xFFE5E5E5),
              ),
              Expanded(
                child: _StatItem(
                  value: height.toString(),
                  label: 'ส่วนสูง (cm)',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GaugeBadge extends StatelessWidget {
  const _GaugeBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF4CA30D).withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: CupertinoColors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA6EF67).withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTypography.caption1(
              const Color(0xFF4CA30D),
            ).copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.275,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headline(CupertinoColors.black).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption2(const Color(0xFF737373))
              .copyWith(fontSize: 8),
        ),
      ],
    );
  }
}

class _BmiGaugePainter extends CustomPainter {
  _BmiGaugePainter({required this.bmi});
  final double bmi;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = pi;
    const sweepAngle = pi;

    // Background arc
    final bgPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    // BMI range: 10-40 mapped to 0-1
    final progress = ((bmi - 10) / 30).clamp(0.0, 1.0);

    // Gradient arc
    final gradient = const SweepGradient(
      startAngle: pi,
      endAngle: 2 * pi,
      colors: [
        Color(0xFFE5D64B), // yellow
        Color(0xFFA3D65C), // lime
        Color(0xFF35B94A), // green
        Color(0xFF1C8A3A), // dark green
      ],
      stops: [0.0, 0.35, 0.7, 1.0],
    );
    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _BmiGaugePainter oldDelegate) =>
      oldDelegate.bmi != bmi;
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.tabs,
    required this.selected,
    required this.onChange,
  });
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 4.0;
        final innerWidth = constraints.maxWidth - padding * 2;
        final segmentWidth = innerWidth / tabs.length;
        return Container(
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: const Color(0xFFD4D4D4).withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(100),
          ),
          child: SizedBox(
            height: 36,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutQuint,
                  left: selected * segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (int i = 0; i < tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChange(i),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                              style: AppTypography.subheadline(
                                i == selected
                                    ? const Color(0xFF0088FF)
                                    : const Color(0xFF1A1A1A),
                              ).copyWith(
                                fontSize: 15,
                                fontWeight: i == selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                letterSpacing: -0.23,
                              ),
                              child: Text(tabs[i]),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricValueDisplay extends StatelessWidget {
  const _MetricValueDisplay({
    required this.metricTab,
    required this.activeIdx,
    required this.isSelected,
  });
  final int metricTab;
  final int activeIdx;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isWeight = metricTab == 0;
    final point = _bmiPoints[activeIdx];
    final value = isWeight
        ? point.weight.round().toString()
        : point.height.round().toString();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey('$metricTab-$activeIdx'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'ค่าที่เลือก',
                style: AppTypography.caption1(const Color(0xFF6D756E))
                    .copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.275,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.title2(CupertinoColors.black).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.6,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  isWeight ? 'kg' : 'cm',
                  style: AppTypography.caption2(const Color(0xFF737373))
                      .copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            point.dateLabel,
            style: AppTypography.caption2(const Color(0xFF737373))
                .copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MetricAreaChart extends StatefulWidget {
  const _MetricAreaChart({
    required this.metricTab,
    required this.selectedIndex,
    required this.onSelect,
  });
  final int metricTab;
  final int? selectedIndex;
  final ValueChanged<int?> onSelect;

  @override
  State<_MetricAreaChart> createState() => _MetricAreaChartState();
}

class _MetricAreaChartState extends State<_MetricAreaChart>
    with TickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();
  static const double _pointWidth = 44.0;
  static const double _leftPad = 16.0;
  static const double _axisWidth = 48.0;

  late AnimationController _entryCtrl;
  late AnimationController _tabCtrl;
  late List<double> _fromValues;
  late List<double> _toValues;

  @override
  void initState() {
    super.initState();
    _fromValues = _currentValues();
    _toValues = _fromValues;
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..value = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entryCtrl.forward();
    });
  }

  List<double> _currentValues() => [
        for (final p in _bmiPoints)
          widget.metricTab == 0 ? p.weight : p.height,
      ];

  @override
  void didUpdateWidget(covariant _MetricAreaChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metricTab != widget.metricTab) {
      _fromValues = _toValues;
      _toValues = _currentValues();
      _tabCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _entryCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  int _nearestIndexByX(double x, List<double> xs) {
    if (xs.isEmpty) return 0;
    int best = 0;
    double bestDist = (xs[0] - x).abs();
    for (int i = 1; i < xs.length; i++) {
      final d = (xs[i] - x).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final values = [
      for (final p in _bmiPoints)
        widget.metricTab == 0 ? p.weight : p.height,
    ];
    final xLabels = [for (final p in _bmiPoints) p.day.toString()];
    final yLabels = widget.metricTab == 0
        ? const [120, 90, 60, 30, 10]
        : const [200, 180, 160, 140, 120];
    return LayoutBuilder(
      builder: (context, constraints) {
        const rightPad = 16.0;
        final visibleWidth = constraints.maxWidth - _axisWidth;
        final contentWidth =
            (values.length * _pointWidth + _leftPad + rightPad)
                .clamp(visibleWidth, double.infinity);
        final chartWidth = contentWidth - _leftPad - rightPad;
        final n = values.length;
        final xPositions = [
          for (int i = 0; i < n; i++)
            n == 1
                ? _leftPad + chartWidth / 2
                : _leftPad + (i / (n - 1)) * chartWidth,
        ];
        return Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                scrollDirection: Axis.horizontal,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: contentWidth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => widget
                        .onSelect(_nearestIndexByX(d.localPosition.dx, xPositions)),
                    onPanUpdate: (d) => widget
                        .onSelect(_nearestIndexByX(d.localPosition.dx, xPositions)),
                    child: AnimatedBuilder(
                      animation:
                          Listenable.merge([_entryCtrl, _tabCtrl]),
                      builder: (_, __) {
                        final entry = Curves.easeOutCubic
                            .transform(_entryCtrl.value);
                        final tab = Curves.fastEaseInToSlowEaseOut
                            .transform(_tabCtrl.value);
                        final morphed = <double>[
                          for (int i = 0; i < values.length; i++)
                            _fromValues[i] +
                                (_toValues[i] - _fromValues[i]) * tab,
                        ];
                        return CustomPaint(
                          painter: _AreaChartPainter(
                            values: morphed,
                            yLabels: yLabels,
                            xLabels: xLabels,
                            xPositions: xPositions,
                            markerIndex: (widget.selectedIndex ??
                                    values.length - 1)
                                .clamp(0, values.length - 1),
                            entry: entry,
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: _axisWidth,
              child: CustomPaint(
                painter: _AxisLabelsPainter(yLabels: yLabels),
                size: Size.infinite,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AxisLabelsPainter extends CustomPainter {
  _AxisLabelsPainter({required this.yLabels});
  final List<int> yLabels;

  @override
  void paint(Canvas canvas, Size size) {
    const topPad = 8.0;
    const bottomPad = 22.0;
    final chartHeight = size.height - topPad - bottomPad;
    final labelStyle = TextStyle(
      color: const Color(0xFF6D756E),
      fontSize: 10,
      letterSpacing: 0.6,
    );
    for (int i = 0; i < yLabels.length; i++) {
      final t = i / (yLabels.length - 1);
      final y = topPad + t * chartHeight;
      final tp = TextPainter(
        text: TextSpan(text: yLabels[i].toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(8, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _AxisLabelsPainter oldDelegate) =>
      oldDelegate.yLabels != yLabels;
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({
    required this.values,
    required this.yLabels,
    required this.xLabels,
    required this.markerIndex,
    required this.xPositions,
    this.entry = 1,
  });
  final List<double> values;
  final List<int> yLabels;
  final List<String> xLabels;
  final int markerIndex;
  final List<double> xPositions;
  final double entry;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 16.0;
    const rightPad = 16.0;
    const topPad = 8.0;
    const bottomPad = 22.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final labelStyle = TextStyle(
      color: const Color(0xFF6D756E),
      fontSize: 10,
      letterSpacing: 0.6,
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 0.5;

    for (int i = 0; i < yLabels.length; i++) {
      final t = i / (yLabels.length - 1);
      final y = topPad + t * chartHeight;
      final isLast = i == yLabels.length - 1;
      if (isLast) {
        canvas.drawLine(
          Offset(leftPad, y),
          Offset(leftPad + chartWidth, y),
          Paint()
            ..color = const Color(0xFFB3B3B3)
            ..strokeWidth = 0.5,
        );
      } else {
        _drawDashed(
          canvas,
          Offset(leftPad, y),
          Offset(leftPad + chartWidth, y),
          gridPaint,
          dash: 3,
          gap: 3,
        );
      }
    }

    for (int i = 0; i < xLabels.length; i++) {
      final x = xPositions[i];
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, topPad + chartHeight + 6),
      );
    }

    final yMax = yLabels.first.toDouble();
    final yMin = yLabels.last.toDouble();
    double xFor(int i) => xPositions[i];
    double yFor(double v) =>
        topPad + (1 - (v - yMin) / (yMax - yMin)) * chartHeight;

    final lineColor = const Color(0xFF34C759);

    final points = [
      for (int i = 0; i < values.length; i++) Offset(xFor(i), yFor(values[i])),
    ];

    // Draw smooth line path
    final linePath = _smoothPath(points);

    // Area fill path
    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, topPad + chartHeight)
      ..lineTo(points.first.dx, topPad + chartHeight)
      ..close();
    final areaShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x5534C759), Color(0x1F34C759), Color(0x0034C759)],
      stops: [0.0, 0.55, 1.0],
    ).createShader(Rect.fromLTWH(leftPad, topPad, chartWidth, chartHeight));

    // Entry-reveal clip: left-to-right wipe
    canvas.save();
    final revealWidth = chartWidth * entry.clamp(0.0, 1.0);
    canvas.clipRect(
      Rect.fromLTWH(leftPad, 0, revealWidth, size.height),
    );
    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = areaShader
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor.withValues(alpha: 0.22)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();

    // Dashed marker line
    final mIdx = markerIndex.clamp(0, values.length - 1);
    final markerX = xFor(mIdx);
    if (markerX - leftPad <= revealWidth + 0.5) {
      final markerOpacity = ((entry - 0.85) / 0.15).clamp(0.0, 1.0);
      _drawDashed(
        canvas,
        Offset(markerX, topPad),
        Offset(markerX, topPad + chartHeight),
        Paint()
          ..color = lineColor.withValues(alpha: 0.5 * markerOpacity)
          ..strokeWidth = 1,
        dash: 4,
        gap: 3,
      );
      canvas.drawCircle(
        Offset(markerX, yFor(values[mIdx])),
        10,
        Paint()..color = lineColor.withValues(alpha: 0.18 * markerOpacity),
      );
      canvas.drawCircle(
        Offset(markerX, yFor(values[mIdx])),
        5.5,
        Paint()..color = CupertinoColors.white.withValues(alpha: markerOpacity),
      );
      canvas.drawCircle(
        Offset(markerX, yFor(values[mIdx])),
        4,
        Paint()..color = lineColor.withValues(alpha: markerOpacity),
      );
    }
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];
      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  void _drawDashed(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dash = 4,
    double gap = 3,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final n = (distance / (dash + gap)).floor();
    final ux = dx / distance;
    final uy = dy / distance;
    for (int i = 0; i < n; i++) {
      final sx = start.dx + (dash + gap) * i * ux;
      final sy = start.dy + (dash + gap) * i * uy;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + dash * ux, sy + dash * uy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.xLabels != xLabels ||
      oldDelegate.xPositions != xPositions ||
      oldDelegate.markerIndex != markerIndex ||
      oldDelegate.entry != entry;
}

class _AboutBmiCard extends StatelessWidget {
  const _AboutBmiCard({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: CupertinoColors.white),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: SizedBox(
              width: 102,
              height: 102,
              child: Image.asset(
                'assets/images/vital_bmi.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'เกี่ยวกับ BMI',
                        style: AppTypography.headline(
                          const Color(0xFF1A1A1A),
                        ).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE5E5E5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'i',
                        style: AppTypography.caption2(
                          const Color(0xFF6D756E),
                        ).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withValues(alpha: 0.55),
                        border: Border.all(
                          color: CupertinoColors.white.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'BMI (Body Mass Index) คือ ดัชนีมวลกาย\nใช้ประเมินว่า "น้ำหนักตัวเหมาะสมกับส่วนสูงหรือไม่"',
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subheadline(
                          const Color(0xFF1A1A1A),
                        ).copyWith(
                          fontSize: 14,
                          height: 1.43,
                          letterSpacing: 0.14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _OptionLabel extends StatelessWidget {
  const _OptionLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Option',
      style: AppTypography.headline(const Color(0xFF1A1A1A)).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _HighlightOption extends StatefulWidget {
  const _HighlightOption();

  @override
  State<_HighlightOption> createState() => _HighlightOptionState();
}

class _HighlightOptionState extends State<_HighlightOption> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _on = !_on),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _on
                    ? 'ไม่ต้องแสงบนหน้าสรุปสุขภาพ'
                    : 'แสงบนหน้าสรุปสุขภาพ',
                style: AppTypography.subheadline(
                  const Color(0xFF1A1A1A),
                ).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _on ? const Color(0xFFFEF9C3) : const Color(0xFFE5E5E5),
              ),
              alignment: Alignment.center,
              child: Icon(
                CupertinoIcons.star_fill,
                color: _on
                    ? const Color(0xFFCA8A04)
                    : const Color(0xFF9CA3AF),
                size: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'แสดงข้อมูลทั้งหมด',
              style: AppTypography.subheadline(
                const Color(0xFF1A1A1A),
              ).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: Color(0xFF6D756E),
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _BmiInfoSheet extends StatelessWidget {
  const _BmiInfoSheet();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F5).withValues(alpha: 0.92),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.white.withValues(alpha: 0.7),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A)
                              .withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 40),
                          Expanded(
                            child: Center(
                              child: Text(
                                'เกี่ยวกับ BMI',
                                style: AppTypography.headline(
                                  const Color(0xFF1A1A1A),
                                ).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          LiquidGlassButton(
  icon: CupertinoIcons.xmark,
  iconColor: const Color(0xFF1A1A1A),
  onTap: () => Navigator.of(context).pop(),
),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: const [
                          _BmiHeroHeader(),
                          _BmiInfoCard(
                            children: [
                              _BmiSection(
                                title: 'BMI คืออะไร?',
                                children: [
                                  _BmiBodyText(
                                    'BMI (Body Mass Index) คือ ดัชนีมวลกาย\nใช้ประเมินว่า "น้ำหนักตัวเหมาะสมกับส่วนสูงหรือไม่"',
                                  ),
                                  _BmiBodyText(
                                      'เป็นตัวชี้วัดพื้นฐานด้านสุขภาพ'),
                                ],
                              ),
                              SizedBox(height: 16),
                              _BmiSection(
                                title: 'เกณฑ์ BMI (สำหรับคนเอเชีย)',
                                children: [
                                  _BmiStatusRow(
                                    icon: CupertinoIcons.info_circle_fill,
                                    color: Color(0xFF0EA5E9),
                                    text: 'ผอม < 18.5 น้ำหนักน้อย',
                                  ),
                                  _BmiStatusRow(
                                    icon:
                                        CupertinoIcons.checkmark_circle_fill,
                                    color: Color(0xFF22C55E),
                                    text: 'ปกติ 18.5 – 22.9 สุขภาพดี',
                                  ),
                                  _BmiStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFFEAB308),
                                    text: 'เริ่มอ้วน 23 – 24.9 เสี่ยง',
                                  ),
                                  _BmiStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFFF97316),
                                    text: 'อ้วน 25 – 29.9 เสี่ยงสูง',
                                  ),
                                  _BmiStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFFEF4444),
                                    text: 'อ้วนมาก ≥ 30 อันตราย',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _BmiSection(
                                title: 'ข้อจำกัดของ BMI',
                                children: [
                                  _BmiBodyText(
                                    '  - ไม่แยก "ไขมัน vs กล้ามเนื้อ"\n  - คนออกกำลังกายอาจ BMI สูงแต่สุขภาพดี\n  - ไม่บอกตำแหน่งไขมัน (เช่น พุง)',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _BmiSection(
                                title: 'คำแนะนำตามค่า BMI',
                                children: [
                                  _BmiStatusRow(
                                    icon: Icons.directions_run_rounded,
                                    color: Color(0xFF0EA5E9),
                                    text: 'ผอม → เพิ่มโปรตีน / ออกกำลังกาย',
                                  ),
                                  _BmiStatusRow(
                                    icon: Icons.self_improvement_rounded,
                                    color: Color(0xFF22C55E),
                                    text: 'ปกติ → รักษาสมดุล',
                                  ),
                                  _BmiStatusRow(
                                    icon: Icons.restaurant_rounded,
                                    color: Color(0xFFF97316),
                                    text: 'สูง → คุมอาหาร + ออกกำลังกาย',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _BmiInfoCard(
                            children: [_BmiReferenceRow()],
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
      ),
    );
  }
}

class _BmiHeroHeader extends StatelessWidget {
  const _BmiHeroHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x554FB896),
                    Color(0x224FB896),
                    Color(0x004FB896),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                'assets/images/bmi_hero_anim.gif',
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/vital_bmi.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BmiInfoCard extends StatelessWidget {
  const _BmiInfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.white.withValues(alpha: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _BmiSection extends StatelessWidget {
  const _BmiSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.headline(const Color(0xFF1A1A1A)).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...children
            .expand((c) => [c, const SizedBox(height: 4)])
            .toList()
          ..removeLast(),
      ],
    );
  }
}

class _BmiBodyText extends StatelessWidget {
  const _BmiBodyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.subheadline(const Color(0xFF1A1A1A)).copyWith(
        fontSize: 14,
        height: 1.43,
        letterSpacing: 0.14,
      ),
    );
  }
}

class _BmiStatusRow extends StatelessWidget {
  const _BmiStatusRow({
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.85,
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.subheadline(
                const Color(0xFF1A1A1A),
              ).copyWith(
                fontSize: 14,
                height: 1.43,
                letterSpacing: 0.14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiReferenceRow extends StatelessWidget {
  const _BmiReferenceRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'แหล่งอ้างอิง',
            style: AppTypography.subheadline(
              const Color(0xFF1A1A1A),
            ).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(
          CupertinoIcons.arrow_up_right_square,
          color: Color(0xFF1A1A1A),
          size: 16,
        ),
      ],
    );
  }
}
