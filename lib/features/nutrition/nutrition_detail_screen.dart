import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';

import '../../core/theme/app_typography.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../health/data/health_data.dart';
import 'data/meal_store.dart';
import 'food_lens/food_chat_screen.dart';
import 'food_lens/food_lens_flow.dart';

enum _Period { day, week, month, year }

class _PeriodSnapshot {
  const _PeriodSnapshot({
    required this.values,
    required this.dates,
    required this.average,
    required this.range,
  });
  final List<double> values;
  final List<DateTime> dates;
  final int average;
  final String range;
}

class NutritionDetailScreen extends StatefulWidget {
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

  @override
  State<NutritionDetailScreen> createState() => _NutritionDetailScreenState();
}

class _NutritionDetailScreenState extends State<NutritionDetailScreen> {
  _Period _period = _Period.week;
  DateTime _anchor = DateTime.now();

  HealthData get data => widget.data;

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    DateTime temp = _anchor;
    final title = switch (_period) {
      _Period.day => 'เลือกวัน',
      _Period.week => 'เลือกสัปดาห์',
      _Period.month => 'เลือกเดือน',
      _Period.year => 'เลือกปี',
    };
    await showCupertinoModalPopup<void>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(38),
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.35),
                  width: 0.5,
                ),
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A)
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          LiquidGlassButton(
                            icon: CupertinoIcons.xmark,
                            iconColor: const Color(0xFF1A1A1A),
                            onTap: () => Navigator.of(ctx).pop(),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          LiquidGlassButton(
                            icon: CupertinoIcons.check_mark,
                            iconColor: CupertinoColors.white,
                            tint: const Color(0xFF1D8B6B),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              setState(() => _anchor = temp);
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 240,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: _anchor,
                            maximumDate: DateTime.now(),
                            onDateTimeChanged: (d) => temp = d,
                          ),
                        ),
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

  // Re-expose parent's static const as instance shortcuts so the rest of
  // this state class can keep using bare names.
  static const _bgPrimary = NutritionDetailScreen._bgPrimary;
  static const _primary600 = NutritionDetailScreen._primary600;
  static const _primary900 = NutritionDetailScreen._primary900;
  static const _thMonth = NutritionDetailScreen._thMonth;

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

  List<MealEntry> _filterByPeriod(List<MealEntry> meals) {
    final now = DateTime.now();
    late final DateTime from;
    switch (_period) {
      case _Period.day:
        from = DateTime(now.year, now.month, now.day);
      case _Period.week:
        from = now.subtract(const Duration(days: 7));
      case _Period.month:
        from = now.subtract(const Duration(days: 30));
      case _Period.year:
        from = now.subtract(const Duration(days: 365));
    }
    final result = [
      for (final m in meals)
        if (!m.time.isBefore(from)) m,
    ];
    result.sort((a, b) => b.time.compareTo(a.time));
    return result;
  }

  String _periodTimeLabel(DateTime t) {
    switch (_period) {
      case _Period.day:
        return _formatTime(t);
      case _Period.week:
      case _Period.month:
        final dow = NutritionDetailScreen._thMonth;
        return '${t.day} ${dow[t.month - 1]} · ${_formatTime(t)}';
      case _Period.year:
        return '${t.day} ${NutritionDetailScreen._thMonth[t.month - 1]}';
    }
  }

  _PeriodSnapshot _periodData() {
    final now = _anchor;
    final base = data.dailyCalories.values.isEmpty
        ? 1900.0
        : data.dailyCalories.values
                .reduce((a, b) => a + b) /
            data.dailyCalories.values.length;
    switch (_period) {
      case _Period.day:
        // 24 hourly buckets — small calories spread across breakfast/lunch/dinner.
        const buckets = [
          0, 0, 0, 0, 0, 0,
          120, 350, 80, 30, 40,
          0, 480, 220, 90, 60,
          40, 30, 600, 280, 90,
          40, 0, 0,
        ];
        final values = buckets.map((e) => e.toDouble()).toList();
        final dates = List.generate(
          24,
          (i) => DateTime(now.year, now.month, now.day, i),
        );
        final total = values.fold<double>(0, (a, b) => a + b).round();
        final dayName = NutritionDetailScreen._thMonth[now.month - 1];
        return _PeriodSnapshot(
          values: values,
          dates: dates,
          average: total,
          range: '${now.day} $dayName ${(now.year + 543) % 100}',
        );
      case _Period.week:
        return _PeriodSnapshot(
          values: data.dailyCalories.values,
          dates: data.dailyCalories.dates,
          average: data.dailyCalories.average.round(),
          range: _weekRange(data.dailyCalories.dates),
        );
      case _Period.month:
        // 30 days centered on `now`.
        final rng = base;
        final values = List<double>.generate(30, (i) {
          // Wave between 70-130% of base for visual variety.
          final t = i / 29 * 6.283;
          return (rng * (0.75 + 0.18 * (1 - (i % 7) / 7) + 0.07 * sin(t)))
              .clamp(800, 2800)
              .toDouble();
        });
        final dates = List.generate(
          30,
          (i) => DateTime(now.year, now.month, now.day - 29 + i),
        );
        final avg = values.reduce((a, b) => a + b) / values.length;
        return _PeriodSnapshot(
          values: values,
          dates: dates,
          average: avg.round(),
          range:
              '${dates.first.day} ${NutritionDetailScreen._thMonth[dates.first.month - 1]} - ${dates.last.day} ${NutritionDetailScreen._thMonth[dates.last.month - 1]} ${(now.year + 543) % 100}',
        );
      case _Period.year:
        // 12 months averaged.
        final values = List<double>.generate(12, (i) {
          final t = i / 11 * 6.283;
          return (base * (0.92 + 0.08 * (1 - i % 3 / 3) + 0.05 * cos(t)))
              .clamp(1200, 2600)
              .toDouble();
        });
        final dates = List.generate(
          12,
          (i) => DateTime(now.year, i + 1, 1),
        );
        final avg = values.reduce((a, b) => a + b) / values.length;
        return _PeriodSnapshot(
          values: values,
          dates: dates,
          average: avg.round(),
          range: 'พ.ศ. ${(now.year + 543)}',
        );
    }
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
                          Builder(
                            builder: (_) {
                              final p = _periodData();
                              return _WeeklyCaloriesCard(
                                period: _period,
                                onPeriodChanged: (next) =>
                                    setState(() => _period = next),
                                onTapDate: _pickDate,
                                average: p.average,
                                target: data.calorieTarget,
                                dateRange: p.range,
                                weekly: p.values,
                                dates: p.dates,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<List<MealEntry>>(
                            valueListenable: MealStore.instance.meals,
                            builder: (_, __, ___) {
                              final store = MealStore.instance;
                              final baseCal = store.todayCalories() > 0
                                  ? store.todayCalories()
                                  : data.meal.calories;
                              final baseCount = store.todayCount() > 0
                                  ? store.todayCount()
                                  : data.meal.mealsEaten;
                              final mult = switch (_period) {
                                _Period.day => 1,
                                _Period.week => 7,
                                _Period.month => 30,
                                _Period.year => 365,
                              };
                              return _TodaySummaryCard(
                                period: _period,
                                calories: baseCal * mult,
                                mealsEaten: baseCount * mult,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _AiNutritionTipsCard(period: _period),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<List<MealEntry>>(
                            valueListenable: MealStore.instance.meals,
                            builder: (_, meals, __) {
                              final filtered = _filterByPeriod(meals);
                              if (filtered.isEmpty) {
                                return _EmptyMealsHint(period: _period);
                              }
                              return Column(
                                children: [
                                  for (final m in filtered) ...[
                                    _MealListItem(
                                      name: m.name,
                                      time: _periodTimeLabel(m.time),
                                      calories: m.calories,
                                      grams: m.grams,
                                      imagePath: m.imagePath,
                                      imageAsset: m.assetImage ??
                                          'assets/images/meal_basil_chicken.png',
                                      onTap: () =>
                                          _openMealDetail(context, m),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ],
                              );
                            },
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
            'โภชนาการ',
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

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.value, required this.onChanged});
  final _Period value;
  final ValueChanged<_Period> onChanged;

  static const _tabs = ['วัน', 'สัปดาห์', 'เดือน', 'ปี'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 4.0;
        final innerWidth = constraints.maxWidth - padding * 2;
        final segmentWidth = innerWidth / _tabs.length;
        final selected = value.index;
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
                          color:
                              CupertinoColors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (int i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(_Period.values[i]),
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
                              child: Text(_tabs[i]),
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

class _WeeklyCaloriesCard extends StatefulWidget {
  const _WeeklyCaloriesCard({
    required this.period,
    required this.onPeriodChanged,
    required this.onTapDate,
    required this.average,
    required this.target,
    required this.dateRange,
    required this.weekly,
    required this.dates,
  });

  final _Period period;
  final ValueChanged<_Period> onPeriodChanged;
  final VoidCallback onTapDate;
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

  static const _thMonthShort = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  String _touchLabel(DateTime d) {
    switch (widget.period) {
      case _Period.day:
        return '${d.hour.toString().padLeft(2, '0')}:00';
      case _Period.week:
        return _thDays[d.weekday % 7];
      case _Period.month:
        return '${d.day} ${_thMonthShort[d.month - 1]}';
      case _Period.year:
        return _thMonthShort[d.month - 1];
    }
  }

  List<String> _xLabels(List<DateTime> ds) {
    switch (widget.period) {
      case _Period.day:
        // 24 hourly points — show only 00, 06, 12, 18, others blank.
        return List<String>.generate(
          ds.length,
          (i) {
            final h = ds[i].hour;
            return h % 6 == 0 ? h.toString().padLeft(2, '0') : '';
          },
        );
      case _Period.week:
        return [for (final d in ds) _thShort[d.weekday % 7]];
      case _Period.month:
        // ~30 days — show every ~5 days as date number.
        return List<String>.generate(
          ds.length,
          (i) => i % 5 == 0 || i == ds.length - 1
              ? ds[i].day.toString()
              : '',
        );
      case _Period.year:
        return [for (final d in ds) _thMonthShort[d.month - 1]];
    }
  }

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
    final displayLabel = isTouched
        ? _touchLabel(widget.dates[_touched!])
        : 'AVERAGE';
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
            _PeriodTabs(
              value: widget.period,
              onChanged: widget.onPeriodChanged,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        switch (widget.period) {
                          _Period.day => 'แคลอรี่รายวัน',
                          _Period.week => 'แคลอรี่รายสัปดาห์',
                          _Period.month => 'แคลอรี่รายเดือน',
                          _Period.year => 'แคลอรี่รายปี',
                        },
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
                                  .copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onTapDate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayDate,
                              style: AppTypography.caption2(
                                      NutritionDetailScreen._neutral500)
                                  .copyWith(fontSize: 11),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              CupertinoIcons.calendar,
                              size: 12,
                              color: Color(0xFF1D8B6B),
                            ),
                          ],
                        ),
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
                          .copyWith(fontSize: 11),
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
                              .copyWith(fontSize: 11),
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
                dayLabels: _xLabels(widget.dates),
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
                                fontSize: 11,
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
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: AppTypography.caption2(
                                      NutritionDetailScreen._textTertiary)
                                  .copyWith(
                                fontSize: 11,
                                letterSpacing: 0.2,
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

class _AiNutritionTipsCard extends StatelessWidget {
  const _AiNutritionTipsCard({required this.period});
  final _Period period;

  String get _periodLabel => switch (period) {
        _Period.day => 'วันนี้',
        _Period.week => 'สัปดาห์นี้',
        _Period.month => 'เดือนนี้',
        _Period.year => 'ปีนี้',
      };

  List<_AiTip> get _tips => switch (period) {
        _Period.day => const [
            _AiTip(
              icon: CupertinoIcons.flame_fill,
              color: Color(0xFFFF6B3D),
              title: 'แคลอรี่อยู่ในเกณฑ์ดี',
              body:
                  'วันนี้ได้รับ ~1,940 kcal ใกล้เคียงเป้า ลองเพิ่มผักใบเขียวมื้อเย็น',
            ),
            _AiTip(
              icon: CupertinoIcons.leaf_arrow_circlepath,
              color: Color(0xFF1D8B6B),
              title: 'โปรตีนเหมาะสม',
              body: 'สลัดอกไก่ + กุ้งให้โปรตีนเพียงพอ ดีต่อกล้ามเนื้อ',
            ),
            _AiTip(
              icon: CupertinoIcons.drop_fill,
              color: Color(0xFFEC4899),
              title: 'น้ำตาลค่อนข้างสูง',
              body: 'กาแฟลาเต้กับขนมปังเช้านี้มีน้ำตาลรวมสูง ลองเปลี่ยนเป็นชาเขียว',
            ),
          ],
        _Period.week => const [
            _AiTip(
              icon: CupertinoIcons.chart_bar_alt_fill,
              color: Color(0xFF1D8B6B),
              title: 'พลังงานเฉลี่ยดี',
              body: 'สัปดาห์นี้ทานเฉลี่ย 1,840 kcal/วัน ต่ำกว่าเป้า 2,200 เล็กน้อย',
            ),
            _AiTip(
              icon: CupertinoIcons.heart_circle_fill,
              color: Color(0xFFEF6B7A),
              title: 'หวาน-โซเดียมสูง 3 มื้อ',
              body: 'กะเพราไก่ไข่ดาว ปรับลดน้ำปลา/น้ำตาลปรุงเพิ่มจะดีต่อความดัน',
            ),
            _AiTip(
              icon: CupertinoIcons.calendar_today,
              color: Color(0xFF6366F1),
              title: 'มื้อเช้าสม่ำเสมอ',
              body: 'ทานมื้อเช้าครบ 5/7 วัน ทำต่อให้ครบสัปดาห์',
            ),
          ],
        _Period.month => const [
            _AiTip(
              icon: CupertinoIcons.graph_circle_fill,
              color: Color(0xFF1D8B6B),
              title: 'สัดส่วนสมดุล',
              body: 'เดือนนี้คาร์บ 50% โปรตีน 25% ไขมัน 25% ตรงตามแนวทาง',
            ),
            _AiTip(
              icon: CupertinoIcons.drop_fill,
              color: Color(0xFFAF52DE),
              title: 'น้ำตาลเฉลี่ยสูง',
              body: 'เครื่องดื่มหวานวันละ 1 แก้ว ลดลงจะช่วยเรื่องน้ำตาลในเลือด',
            ),
            _AiTip(
              icon: CupertinoIcons.checkmark_seal_fill,
              color: Color(0xFF3B82F6),
              title: 'ไฟเบอร์เพียงพอ',
              body: 'ทานผัก/ผลไม้เฉลี่ย 4 หน่วยบริโภค/วัน ดีต่อระบบขับถ่าย',
            ),
          ],
        _Period.year => const [
            _AiTip(
              icon: CupertinoIcons.arrow_down_circle_fill,
              color: Color(0xFF1D8B6B),
              title: 'แคลอรี่เฉลี่ยลดลง',
              body: 'ปีนี้เฉลี่ย 1,920 kcal/วัน ลดจากปีก่อน ~150 kcal/วัน',
            ),
            _AiTip(
              icon: CupertinoIcons.star_circle_fill,
              color: Color(0xFFFFB020),
              title: 'พฤติกรรมการกินสม่ำเสมอ',
              body: 'บันทึกอาหารต่อเนื่อง 312 วัน ดีมาก!',
            ),
            _AiTip(
              icon: CupertinoIcons.heart_fill,
              color: Color(0xFFEC4899),
              title: 'แนะนำสำหรับปีหน้า',
              body: 'เพิ่มมื้อปลาทะเลสัปดาห์ละ 2 ครั้ง เพื่อ Omega-3',
            ),
          ],
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9333EA).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.sparkles,
                  color: CupertinoColors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'แนะนำโดย AI',
                      style: AppTypography.callout(
                              NutritionDetailScreen._textPrimary)
                          .copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'จากพฤติกรรมการทาน$_periodLabel',
                      style: AppTypography.caption2(
                              NutritionDetailScreen._textTertiary)
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < _tips.length; i++) ...[
            _AiTipRow(tip: _tips[i]),
            if (i < _tips.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          _AskAiButton(period: period),
        ],
      ),
    );
  }
}

class _AskAiButton extends StatelessWidget {
  const _AskAiButton({required this.period});
  final _Period period;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final periodLabel = switch (period) {
          _Period.day => 'วันนี้',
          _Period.week => 'สัปดาห์นี้',
          _Period.month => 'เดือนนี้',
          _Period.year => 'ปีนี้',
        };
        final analysis = MealAnalysis(
          name: 'โภชนาการ$periodLabel',
          nameEn: 'Nutrition Overview',
          calories: 1940,
          grams: 0,
          description: 'สรุปโภชนาการรวมจากมื้ออาหารของคุณ$periodLabel',
          protein: 86,
          carbs: 230,
          fat: 58,
          fiber: 24,
          sugar: 42,
          tips: const [],
        );
        showFoodChat(context, analysis: analysis);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9333EA).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.sparkles,
              color: CupertinoColors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'ถาม AI เพิ่มเติม',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiTip {
  const _AiTip({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

class _AiTipRow extends StatelessWidget {
  const _AiTipRow({required this.tip});
  final _AiTip tip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tip.color.withValues(alpha: 0.14),
          ),
          alignment: Alignment.center,
          child: Icon(tip.icon, color: tip.color, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tip.title,
                style: AppTypography.subheadline(
                        NutritionDetailScreen._textPrimary)
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                tip.body,
                style: AppTypography.caption2(
                        NutritionDetailScreen._textSecondary)
                    .copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyMealsHint extends StatelessWidget {
  const _EmptyMealsHint({required this.period});
  final _Period period;

  @override
  Widget build(BuildContext context) {
    final label = switch (period) {
      _Period.day => 'วันนี้',
      _Period.week => '7 วันที่ผ่านมา',
      _Period.month => '30 วันที่ผ่านมา',
      _Period.year => '12 เดือนที่ผ่านมา',
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.tray,
            color: Color(0xFF8E8E93),
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            'ยังไม่มีอาหารบันทึกใน$label',
            style: AppTypography.headline(const Color(0xFF1A1A1A))
                .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'สแกนหรือบันทึกมื้อใหม่เพื่อเริ่มต้น',
            style: TextStyle(
              color: Color(0xFF6D756E),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({
    required this.period,
    required this.calories,
    required this.mealsEaten,
  });

  final _Period period;
  final int calories;
  final int mealsEaten;

  String get _title => switch (period) {
        _Period.day => 'สรุปวันนี้',
        _Period.week => 'สรุปสัปดาห์นี้',
        _Period.month => 'สรุปเดือนนี้',
        _Period.year => 'สรุปปีนี้',
      };

  String get _caloriesLabel => switch (period) {
        _Period.day => 'แคลอรี่วันนี้',
        _Period.week => 'แคลอรี่สัปดาห์นี้',
        _Period.month => 'แคลอรี่เดือนนี้',
        _Period.year => 'แคลอรี่ปีนี้',
      };

  String get _mealsLabel => switch (period) {
        _Period.day => 'มื้อ',
        _Period.week => 'มื้อในสัปดาห์',
        _Period.month => 'มื้อในเดือน',
        _Period.year => 'มื้อในปี',
      };

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
                        _title,
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
                                label: _caloriesLabel,
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
                                label: 'จำนวนมื้ออาหาร',
                                value: '$mealsEaten',
                                unit: _mealsLabel,
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
                  .copyWith(fontSize: 11),
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
                    .copyWith(fontSize: 10),
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
                          .copyWith(fontSize: 11, height: 15 / 10),
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
              .copyWith(fontSize: 11, height: 15 / 10),
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
          'ตัวเลือก',
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
