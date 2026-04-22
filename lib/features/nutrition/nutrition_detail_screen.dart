import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/theme/app_typography.dart';
import '../health/data/health_data.dart';
import 'data/meal_store.dart';
import 'food_lens/food_lens_flow.dart';

class NutritionDetailScreen extends StatelessWidget {
  const NutritionDetailScreen({super.key, required this.data});

  final HealthData data;

  static const _bgPrimary = Color(0xFFF4F8F5);
  static const _primary600 = Color(0xFF1D8B6B);
  static const _primary900 = Color(0xFF093327);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textTertiary = Color(0xFF6D756E);
  static const _textSecondary = Color(0xFF3E453F);
  static const _neutral500 = Color(0xFF737373);
  static const _border = Color(0xFFE5E5E5);

  static const _thMonth = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.'
  ];

  void _openMealDetail(BuildContext context, MealEntry m) {
    final analysis = MealAnalysis(
      name: m.name,
      nameEn: m.nameEn,
      calories: m.calories,
      grams: m.grams,
      description: m.description ?? '',
      protein: m.protein,
      carbs: m.carbs,
      fat: m.fat,
      fiber: m.fiber,
      sugar: m.sugar,
      tips: m.tips,
      warning: m.warning,
    );
    Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (_) => FoodLensResultsScreen(
          imagePath: m.imagePath,
          assetImage: m.assetImage,
          analysis: analysis,
          readOnly: true,
          heroTag: 'meal-${m.id}',
        ),
      ),
    );
  }

  static String _formatTime(DateTime t) {
    final hour24 = t.hour;
    final ampm = hour24 >= 12 ? 'PM' : 'AM';
    var h = hour24 % 12;
    if (h == 0) h = 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }

  String _weekRange(List<DateTime> dates) {
    if (dates.isEmpty) return '';
    final first = dates.first;
    final last = dates.last;
    final beYear = (last.year + 543) % 100;
    final sameMonth = first.month == last.month;
    if (sameMonth) {
      return '${first.day} - ${last.day} ${_thMonth[last.month - 1]} $beYear';
    }
    return '${first.day} ${_thMonth[first.month - 1]} - ${last.day} ${_thMonth[last.month - 1]} $beYear';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgPrimary,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primary600, _primary900],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                  onBack: () => Navigator.of(context).maybePop(),
                  onScan: () => openFoodLens(context),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Container(
                      color: _bgPrimary,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        children: [
                          _WeeklyCaloriesCard(
                            average: data.dailyCalories.average.round(),
                            target: data.calorieTarget,
                            dateRange: _weekRange(data.dailyCalories.dates),
                            weekly: data.dailyCalories.values,
                            dates: data.dailyCalories.dates,
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<List<MealEntry>>(
                            valueListenable: MealStore.instance.meals,
                            builder: (_, __, ___) {
                              final store = MealStore.instance;
                              return _TodaySummaryCard(
                                calories: store.todayCalories() > 0
                                    ? store.todayCalories()
                                    : data.meal.calories,
                                mealsEaten: store.todayCount() > 0
                                    ? store.todayCount()
                                    : data.meal.mealsEaten,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<List<MealEntry>>(
                            valueListenable: MealStore.instance.meals,
                            builder: (_, meals, __) => Column(
                              children: [
                                for (final m in meals) ...[
                                  _MealListItem(
                                    name: m.name,
                                    time: _formatTime(m.time),
                                    calories: m.calories,
                                    grams: m.grams,
                                    imagePath: m.imagePath,
                                    imageAsset: m.assetImage ??
                                        'assets/images/meal_basil_chicken.png',
                                    onTap: () => _openMealDetail(context, m),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _OptionSection(),
                        ],
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

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onScan});
  final VoidCallback onBack;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Row(
        children: [
          _LiquidGlassCircle(
            icon: CupertinoIcons.chevron_back,
            onTap: onBack,
          ),
          const SizedBox(width: 10),
          Text(
            'Nutrition',
            style: AppTypography.title3(CupertinoColors.white).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _LiquidGlassCircle(
            icon: CupertinoIcons.camera_fill,
            onTap: onScan,
          ),
        ],
      ),
    );
  }
}

class _LiquidGlassCircle extends StatelessWidget {
  const _LiquidGlassCircle({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
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
                color: CupertinoColors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.35),
                  width: 0.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.white.withValues(alpha: 0.30),
                    CupertinoColors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(icon, size: 20, color: CupertinoColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyCaloriesCard extends StatefulWidget {
  const _WeeklyCaloriesCard({
    required this.average,
    required this.target,
    required this.dateRange,
    required this.weekly,
    required this.dates,
  });

  final int average;
  final int target;
  final String dateRange;
  final List<double> weekly;
  final List<DateTime> dates;

  @override
  State<_WeeklyCaloriesCard> createState() => _WeeklyCaloriesCardState();
}

class _WeeklyCaloriesCardState extends State<_WeeklyCaloriesCard> {
  int? _touched;

  static const _thDays = [
    'อาทิตย์',
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
  ];

  static const _thShort = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];

  List<String> _weekdayShort(List<DateTime> ds) =>
      [for (final d in ds) _thShort[d.weekday % 7]];

  String _dayDate(DateTime d) {
    final beYear = (d.year + 543) % 100;
    final dow = _thDays[d.weekday % 7];
    return '$dow ${d.day} ${NutritionDetailScreen._thMonth[d.month - 1]} $beYear';
  }

  List<int> _niceYLabels() {
    if (widget.weekly.isEmpty) return const [250, 200, 150, 100, 50];
    final min = widget.weekly.reduce((a, b) => a < b ? a : b);
    final max = widget.weekly.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    final rawStep = range / 4;
    const niceBases = [1, 2, 5, 10];
    final mag = pow(10, (log(rawStep) / ln10).floor()).toDouble();
    final normalized = rawStep / mag;
    final nb = niceBases.firstWhere(
      (b) => b >= normalized,
      orElse: () => 10,
    );
    final step = nb * mag;
    final niceMin = (min / step).floor() * step;
    final labels = <int>[];
    for (int i = 0; i < 5; i++) {
      labels.add((niceMin + step * i).round());
    }
    return labels.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTouched = _touched != null;
    final displayValue = isTouched
        ? widget.weekly[_touched!].round()
        : widget.average;
    final displayLabel = isTouched ? _thDays[_touched!] : 'AVERAGE';
    final displayDate = isTouched
        ? _dayDate(widget.dates[_touched!])
        : widget.dateRange;
    final yLabels = _niceYLabels();
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'แคลอรี่รายสัปดาห์',
                        style: AppTypography.callout(
                                NutritionDetailScreen._textPrimary)
                            .copyWith(
                                fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        layoutBuilder: (current, _) =>
                            current ?? const SizedBox.shrink(),
                        child: Text(
                          displayLabel,
                          key: ValueKey('lbl-$displayLabel'),
                          style: AppTypography.caption1(
                                  NutritionDetailScreen._textTertiary)
                              .copyWith(
                                  fontSize: 12, letterSpacing: 0.275),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatThousands(displayValue),
                            style: AppTypography.title1(CupertinoColors.black)
                                .copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.6,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              'kcal/วัน',
                              style: AppTypography.caption2(
                                      NutritionDetailScreen._neutral500)
                                  .copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayDate,
                        style: AppTypography.caption2(
                                NutritionDetailScreen._neutral500)
                            .copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'เป้าหมาย',
                      style: AppTypography.caption2(
                              NutritionDetailScreen._neutral500)
                          .copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.target}',
                          style: AppTypography.caption1(
                                  NutritionDetailScreen._textTertiary)
                              .copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.275,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'kcal/วัน',
                          style: AppTypography.caption2(
                                  NutritionDetailScreen._neutral500)
                              .copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 216,
              child: _WeeklyChart(
                values: widget.weekly,
                yLabels: yLabels,
                dayLabels: _weekdayShort(widget.dates),
                touchedIndex: _touched,
                onTouch: (i) {
                  if (i == _touched) return;
                  setState(() => _touched = i);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatThousands(num v) {
    final i = v.round();
    final s = i.toString();
    final buf = StringBuffer();
    for (int k = 0; k < s.length; k++) {
      if (k > 0 && (s.length - k) % 3 == 0) buf.write(',');
      buf.write(s[k]);
    }
    return buf.toString();
  }
}

class _WeeklyChart extends StatefulWidget {
  const _WeeklyChart({
    required this.values,
    required this.yLabels,
    required this.dayLabels,
    this.touchedIndex,
    this.onTouch,
  });

  final List<double> values;
  final List<int> yLabels;
  final List<String> dayLabels;
  final int? touchedIndex;
  final ValueChanged<int?>? onTouch;

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _hit(double x, double width) {
    if (widget.values.isEmpty) return;
    final slot = width / widget.values.length;
    final idx =
        (x / slot).floor().clamp(0, widget.values.length - 1);
    if (idx != widget.touchedIndex) widget.onTouch?.call(idx);
  }

  @override
  Widget build(BuildContext context) {
    const yLabelWidth = 40.0;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final progress =
            const Cubic(0.22, 1.0, 0.36, 1.0).transform(_ctrl.value);
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (d) => _hit(d.localPosition.dx, c.maxWidth),
                          onTapCancel: () => widget.onTouch?.call(null),
                          onPanStart: (d) => _hit(d.localPosition.dx, c.maxWidth),
                          onPanUpdate: (d) => _hit(d.localPosition.dx, c.maxWidth),
                          onPanEnd: (_) => Future.delayed(
                            const Duration(milliseconds: 1200),
                            () {
                              if (mounted) widget.onTouch?.call(null);
                            },
                          ),
                          child: CustomPaint(
                            painter: _WeeklyChartPainter(
                              values: widget.values,
                              yMin: widget.yLabels.last.toDouble(),
                              yMax: widget.yLabels.first.toDouble(),
                              lineColor:
                                  NutritionDetailScreen._primary600,
                              progress: progress,
                              touchedIndex: widget.touchedIndex,
                            ),
                            size: Size.infinite,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: yLabelWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final y in widget.yLabels)
                            Text(
                              '$y',
                              style: AppTypography.caption2(
                                      NutritionDetailScreen._textTertiary)
                                  .copyWith(
                                fontSize: 10,
                                letterSpacing: 0.6,
                                height: 1,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      for (final d in widget.dayLabels)
                        Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: AppTypography.caption2(
                                      NutritionDetailScreen._textTertiary)
                                  .copyWith(
                                fontSize: 10,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: yLabelWidth),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _WeeklyChartPainter extends CustomPainter {
  _WeeklyChartPainter({
    required this.values,
    required this.yMin,
    required this.yMax,
    required this.lineColor,
    required this.progress,
    this.touchedIndex,
  });

  final List<double> values;
  final double yMin;
  final double yMax;
  final Color lineColor;
  final double progress;
  final int? touchedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const levels = 5;
    final gridPaint = Paint()
      ..color = NutritionDetailScreen._border
      ..strokeWidth = 0.5;
    for (int i = 0; i < levels; i++) {
      final y = size.height * i / (levels - 1);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final slot = size.width / values.length;
    final range = (yMax - yMin) == 0 ? 1.0 : (yMax - yMin);
    final points = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(
          i * slot + slot / 2,
          size.height -
              ((values[i] - yMin) / range).clamp(0.0, 1.0) * size.height,
        ),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;
      final c1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final c2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.28),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    canvas.restore();

    final idx = touchedIndex;
    if (idx != null && idx >= 0 && idx < points.length && progress > 0.95) {
      final p = points[idx];
      final guide = Paint()
        ..color = lineColor.withValues(alpha: 0.35)
        ..strokeWidth = 1;
      const dash = 4.0;
      const gap = 4.0;
      double y = 0;
      while (y < size.height) {
        canvas.drawLine(
          Offset(p.dx, y),
          Offset(p.dx, (y + dash).clamp(0, size.height)),
          guide,
        );
        y += dash + gap;
      }
      canvas.drawCircle(p, 8,
          Paint()..color = lineColor.withValues(alpha: 0.18));
      canvas.drawCircle(p, 5,
          Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawCircle(
          p,
          5,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyChartPainter old) =>
      old.values != values ||
      old.progress != progress ||
      old.touchedIndex != touchedIndex;
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({required this.calories, required this.mealsEaten});

  final int calories;
  final int mealsEaten;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: 8,
              top: 2,
              child: Image.asset(
                'assets/images/salad_bowl.png',
                width: 96,
                height: 96,
                fit: BoxFit.contain,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'สรุปวันนี้',
                        style: AppTypography.callout(
                                NutritionDetailScreen._textPrimary)
                            .copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              CupertinoColors.white.withValues(alpha: 0.12),
                              CupertinoColors.black.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _Macro(
                                iconBg: const Color(0xFFFF6B3D),
                                icon: CupertinoIcons.flame_fill,
                                label: 'แคลอรี่วันนี้',
                                value: '$calories',
                                unit: 'kcl',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: CupertinoColors.black
                                  .withValues(alpha: 0.08),
                            ),
                            Expanded(
                              child: _Macro(
                                iconBg: NutritionDetailScreen._primary600,
                                icon: Icons.restaurant,
                                iconSize: 10,
                                label: 'เมื่ออาหารที่ทาน',
                                value: '$mealsEaten',
                                unit: 'เมื่อ',
                              ),
                            ),
                          ],
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

class _Macro extends StatelessWidget {
  const _Macro({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.unit,
    this.iconSize = 9,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String value;
  final String unit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: iconSize, color: CupertinoColors.white),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption2(
                      NutritionDetailScreen._textSecondary)
                  .copyWith(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTypography.callout(CupertinoColors.black).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6,
                height: 1,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                unit,
                style: AppTypography.caption2(
                        NutritionDetailScreen._neutral500)
                    .copyWith(fontSize: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MealListItem extends StatelessWidget {
  const _MealListItem({
    required this.name,
    required this.time,
    required this.calories,
    required this.grams,
    required this.imageAsset,
    this.imagePath,
    this.onTap,
  });

  final String name;
  final String time;
  final int calories;
  final int grams;
  final String imageAsset;
  final String? imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imagePath != null
                ? Image.file(
                    File(imagePath!),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    imageAsset,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.callout(
                          NutritionDetailScreen._textPrimary)
                      .copyWith(fontSize: 14, height: 16 / 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Meta(
                      icon: CupertinoIcons.clock,
                      text: time,
                    ),
                    const SizedBox(width: 10),
                    _VerticalDivider(),
                    const SizedBox(width: 10),
                    _Meta(
                      icon: CupertinoIcons.flame,
                      text: '$calories kcal',
                    ),
                    const SizedBox(width: 10),
                    _VerticalDivider(),
                    const SizedBox(width: 10),
                    Text(
                      '$grams g',
                      style: AppTypography.caption2(
                              NutritionDetailScreen._textTertiary)
                          .copyWith(fontSize: 10, height: 15 / 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: NutritionDetailScreen._textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.caption2(
                  NutritionDetailScreen._textTertiary)
              .copyWith(fontSize: 10, height: 15 / 10),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 8,
      color: NutritionDetailScreen._border,
    );
  }
}

class _OptionSection extends StatefulWidget {
  @override
  State<_OptionSection> createState() => _OptionSectionState();
}

class _OptionSectionState extends State<_OptionSection> {
  bool _starred = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Option',
          style: AppTypography.callout(NutritionDetailScreen._textPrimary)
              .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _StarOptionCard(
          label: _starred
              ? 'ไม่ต้องแสดงบนหน้าสรุปสุขภาพ'
              : 'แสดงบนหน้าสรุปสุขภาพ',
          starred: _starred,
          onTap: () => setState(() => _starred = !_starred),
        ),
        const SizedBox(height: 10),
        _ExpandRow(
          label: 'แสดงข้อมูลทั้งหมด',
          onTap: () {},
        ),
      ],
    );
  }
}

class _StarOptionCard extends StatelessWidget {
  const _StarOptionCard({
    required this.label,
    required this.starred,
    required this.onTap,
  });

  final String label;
  final bool starred;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.callout(
                        NutritionDetailScreen._textPrimary)
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: starred
                    ? const Color(0xFFFEF9C3)
                    : NutritionDetailScreen._border,
              ),
              alignment: Alignment.center,
              child: Icon(
                starred ? CupertinoIcons.star_fill : CupertinoIcons.star,
                size: 8,
                color: starred
                    ? const Color(0xFFD4A91A)
                    : NutritionDetailScreen._textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandRow extends StatelessWidget {
  const _ExpandRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.callout(
                        NutritionDetailScreen._textPrimary)
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: NutritionDetailScreen._textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
