import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/skeleton_box.dart';
import '../family/family_devices.dart';
import '../nutrition/food_lens/food_lens_flow.dart';
import '../nutrition/nutrition_detail_screen.dart';
import 'health_metric_prefs.dart';
import 'widgets/health_metric_edit_sheet.dart';
import 'add_health_data_screen.dart';
import 'blood_pressure_detail_screen.dart';
import 'blood_sugar_detail_screen.dart';
import 'bmi_detail_screen.dart';
import 'cgm_detail_screen.dart';
import 'heart_rate_detail_screen.dart';
import 'sleep_detail_screen.dart';
import 'spo2_detail_screen.dart';
import 'temperature_detail_screen.dart';
import 'waist_detail_screen.dart';
import 'data/health_data.dart';
import 'widgets/active_energy_card.dart';
import 'widgets/meal_card.dart';
import 'widgets/metric_card.dart';
import 'widgets/mini_activity_card.dart';
import 'widgets/mini_charts.dart';
import 'widgets/tip_card.dart';
import 'widgets/week_labels.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  final HealthRepository _repo = HealthRepository(seed: 7);
  late HealthData _data;
  bool _loading = true;
  Timer? _skeletonTimer;
  final Set<DeviceKind> _userDevices = {
    DeviceKind.smartwatch,
    DeviceKind.cgm,
  };

  void _openDevicePairing() {
    showManageDevicesSheet(
      context,
      selected: _userDevices,
      onChanged: (next) {
        setState(() {
          _userDevices
            ..clear()
            ..addAll(next);
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _data = _repo.load();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _skeletonTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _loading = false);
      _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    setState(() => _data = _repo.load());
  }

  Widget _staggered(int index, int total, Widget child) {
    final start = (index / (total * 1.6)).clamp(0.0, 0.9);
    final end = (start + 0.55).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, c) {
        final t = CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 24),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final padding = Responsive.pagePadding(context);

    if (_loading) return _HealthSkeleton(bg: bg);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text('สรุปสุขภาพ'),
                backgroundColor: bg.withValues(alpha: 0.85),
                border: null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LiquidGlassButton(
                      icon: Icons.bluetooth,
                      onTap: _openDevicePairing,
                      size: 36,
                      iconSize: 18,
                      iconColor: const Color(0xFF1D8B6B),
                    ),
                    const SizedBox(width: 8),
                    LiquidGlassButton(
                      icon: CupertinoIcons.square_grid_2x2_fill,
                      onTap: () => showHealthMetricEditSheet(context),
                      size: 36,
                      iconSize: 18,
                      iconColor: const Color(0xFF1D8B6B),
                    ),
                  ],
                ),
              ),
              CupertinoSliverRefreshControl(onRefresh: _refresh),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  padding.horizontal / 2,
                  8,
                  padding.horizontal / 2,
                  120,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    _staggered(0, 3, _NutritionSection(data: _data)),
                    const SizedBox(height: 24),
                    _staggered(1, 3, _VitalSignSection(data: _data)),
                    const SizedBox(height: 24),
                    _staggered(2, 3, _HighlightsSection(data: _data)),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatInt(num v) {
  final i = v.round();
  final s = i.toString();
  final buf = StringBuffer();
  for (int k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(',');
    buf.write(s[k]);
  }
  return buf.toString();
}

class _LiveValue extends StatefulWidget {
  const _LiveValue({required this.initialIndex, required this.builder});
  final int initialIndex;
  final Widget Function(int index, ValueChanged<int?> onTouch) builder;

  @override
  State<_LiveValue> createState() => _LiveValueState();
}

class _LiveValueState extends State<_LiveValue> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    return widget.builder(_touched ?? widget.initialIndex, (i) {
      if (i == _touched) return;
      setState(() => _touched = i);
    });
  }
}

Widget _sectionTitle(BuildContext context, String text) {
  final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
  final primary = isDark ? AppColors.labelDark : const Color(0xFF1A1A1A);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      text,
      style: AppTypography.callout(primary).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final meal = data.meal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'โภชนาการ'),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => NutritionDetailScreen(data: data),
            ),
          ),
          child: MealCard(
            tagline: meal.tagline,
            name: meal.name,
            calories: _formatInt(meal.calories),
            carbs: '${meal.mealsEaten}',
            onScan: () => openFoodLens(context),
          ),
        ),
      ],
    );
  }
}

class _VitalSignSection extends StatelessWidget {
  const _VitalSignSection({required this.data});
  final HealthData data;

  Widget _cardFor(HealthMetricKey key) {
    switch (key) {
      case HealthMetricKey.bloodPressure:
        return _BloodPressureCard(data: data);
      case HealthMetricKey.bmi:
        return _BmiCard(data: data);
      case HealthMetricKey.temperature:
        return _TemperatureCard(data: data);
      case HealthMetricKey.sleep:
        return _SleepCard(data: data);
      case HealthMetricKey.heartRate:
        return _HeartRateCard(data: data);
      case HealthMetricKey.cgm:
        return _CgmCard(data: data);
      case HealthMetricKey.waist:
        return _WaistCard(data: data);
      case HealthMetricKey.spo2:
        return _SpO2Card(data: data);
      case HealthMetricKey.bloodSugar:
        return _BloodSugarCard(data: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;
    return ValueListenableBuilder<HealthMetricPrefs>(
      valueListenable: healthMetricPrefsStore,
      builder: (_, prefs, __) {
        final visible = prefs.order
            .where((k) => prefs.pinned.contains(k))
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'สัญญาณชีพ'),
            if (visible.isEmpty)
              const _EmptyVitals()
            else
              for (var i = 0; i < visible.length; i++) ...[
                _cardFor(visible[i]),
                if (i < visible.length - 1) const SizedBox(height: spacing),
              ],
          ],
        );
      },
    );
  }
}

class _EmptyVitals extends StatelessWidget {
  const _EmptyVitals();

  @override
  Widget build(BuildContext context) {
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
            CupertinoIcons.pin_slash,
            color: Color(0xFF8E8E93),
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            'ยังไม่ได้ปักหมุดรายการใด',
            style: AppTypography.headline(const Color(0xFF1A1A1A))
                .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'กดปุ่มจัดเรียงด้านบนเพื่อเลือกรายการ',
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

class _BloodPressureCard extends StatelessWidget {
  const _BloodPressureCard({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final sys = data.bloodPressure.primary;
    final dia = data.bloodPressure.secondary;
    return MetricCard(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const BloodPressureDetailScreen(),
          ),
        );
      },
      onAdd: () => showAddHealthDataScreen(
        context,
        initial: HealthMetricKey.bloodPressure,
      ),
      icon: CupertinoIcons.heart_fill,
      iconColor: const Color(0xFFB7185E),
      label: 'ความดันโลหิต',
      value: '${sys.points[sys.latestIndex].value.round()}/${dia.points[dia.latestIndex].value.round()}',
      unit: 'mmHg',
      chartHeight: 72,
      chart: DualLineChart(
        primary: sys.values,
        secondary: dia.values,
        dates: sys.dates,
        primaryColor: const Color(0xFFF06C8C),
        secondaryColor: const Color(0xFF4A6CF7),
        primaryLabel: 'Sys',
        secondaryLabel: 'Dia',
        primaryUnit: ' mmHg',
        interactive: false,
      ),
      bottom: WeekLabels(labels: WeekLabels.fromDates(sys.dates)),
    );
  }
}

class _BmiCard extends StatelessWidget {
  const _BmiCard({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final primary = isDark ? AppColors.labelDark : AppColors.label;
    final secondary =
        isDark ? AppColors.secondaryLabelDark : AppColors.secondaryLabel;
    return MetricCard(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const BmiDetailScreen(),
          ),
        );
      },
      onAdd: () => showAddHealthDataScreen(
        context,
        initial: HealthMetricKey.bmi,
      ),
      icon: CupertinoIcons.chart_pie_fill,
      iconColor: AppColors.nutrition,
      label: 'ดัชนีมวลกาย',
      value: '',
      unit: '',
      chart: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: BmiGauge(value: data.bmi, color: AppColors.nutrition),
          ),
          Positioned(
            bottom: 0,
            child: Text(
              data.bmi.toStringAsFixed(1),
              style: AppTypography.title1(primary)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      chartHeight: 70,
      bottom: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'น้ำหนัก (kg)',
              value: data.weightKg.toStringAsFixed(0),
              primary: primary,
              secondary: secondary,
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: AppColors.separator.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _Stat(
              label: 'ส่วนสูง (cm)',
              value: data.heightCm.toStringAsFixed(0),
              primary: primary,
              secondary: secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.primary,
    required this.secondary,
  });
  final String label;
  final String value;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.subheadline(primary)
                .copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(label,
            style: AppTypography.caption2(secondary)
                .copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _TemperatureCard extends StatelessWidget {
  const _TemperatureCard({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final s = data.temperature;
    return _LiveValue(
      initialIndex: s.latestIndex,
      builder: (idx, onTouch) => MetricCard(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const TemperatureDetailScreen(),
            ),
          );
        },
        onAdd: () => showAddHealthDataScreen(
          context,
          initial: HealthMetricKey.temperature,
        ),
        icon: CupertinoIcons.thermometer,
        iconColor: AppColors.mindfulness,
        label: 'อุณหภูมิ',
        value: s.values[idx].toStringAsFixed(1),
        unit: '°C',
        chartHeight: 56,
        chart: MiniLineChart(
          data: s.values,
          dates: s.dates,
          color: AppColors.mindfulness,
          showDots: true,
          unit: '°C',
          indicatorIndex: idx,
          interactive: false,
        ),
        bottom: WeekLabels(labels: WeekLabels.fromDates(s.dates)),
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  const _SleepCard({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final s = data.sleep;
    return _LiveValue(
      initialIndex: s.latestIndex,
      builder: (idx, onTouch) => MetricCard(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const SleepDetailScreen(),
            ),
          );
        },
        onAdd: () => showAddHealthDataScreen(
          context,
          initial: HealthMetricKey.sleep,
        ),
        icon: CupertinoIcons.moon_fill,
        iconColor: AppColors.sleep,
        label: 'การนอน',
        value: s.values[idx].toStringAsFixed(1),
        unit: 'hrs',
        chartHeight: 56,
        chart: PillBarChart(
          values: s.values,
          dates: s.dates,
          color: AppColors.sleep,
          unit: ' hrs',
          interactive: false,
        ),
        bottom: WeekLabels(labels: WeekLabels.fromDates(s.dates)),
      ),
    );
  }
}

class _HeartRateCard extends StatelessWidget {
  const _HeartRateCard({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final s = data.heartRate;
    return _LiveValue(
      initialIndex: s.latestIndex,
      builder: (idx, onTouch) => MetricCard(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const HeartRateDetailScreen(),
            ),
          );
        },
        onAdd: () => showAddHealthDataScreen(
          context,
          initial: HealthMetricKey.heartRate,
        ),
        icon: CupertinoIcons.waveform_path_ecg,
        iconColor: AppColors.health,
        label: 'อัตราการเต้นหัวใจ',
        value: s.values[idx].round().toString(),
        unit: 'bpm',
        chartHeight: 56,
        chart: MiniLineChart(
          data: s.values,
          dates: s.dates,
          color: AppColors.health,
          indicatorIndex: idx,
          unit: ' bpm',
          interactive: false,
        ),
        bottom: WeekLabels(labels: WeekLabels.fromDates(s.dates)),
      ),
    );
  }
}

class _CgmCard extends StatelessWidget {
  const _CgmCard({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final s = data.cgm;
    return _LiveValue(
      initialIndex: s.latestIndex,
      builder: (idx, onTouch) => MetricCard(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const CgmDetailScreen(),
            ),
          );
        },
        onAdd: () => showAddHealthDataScreen(
          context,
          initial: HealthMetricKey.cgm,
        ),
        icon: CupertinoIcons.drop_fill,
        iconColor: AppColors.sleep,
        label: 'น้ำตาลต่อเนื่อง',
        value: s.values[idx].round().toString(),
        unit: 'mg/dl',
        chartHeight: 76,
        chart: MiniLineChart(
          data: s.values,
          dates: s.dates,
          color: AppColors.sleep,
          indicatorIndex: idx,
          unit: ' mg/dl',
          interactive: false,
        ),
        bottom: WeekLabels(labels: WeekLabels.fromDates(s.dates)),
      ),
    );
  }
}

class _WaistCard extends StatelessWidget {
  const _WaistCard({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final s = data.waist;
    return _LiveValue(
      initialIndex: s.latestIndex,
      builder: (idx, onTouch) => MetricCard(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const WaistDetailScreen(),
            ),
          );
        },
        onAdd: () => showAddHealthDataScreen(
          context,
          initial: HealthMetricKey.waist,
        ),
        icon: CupertinoIcons.circle_fill,
        iconColor: AppColors.nutrition,
        label: 'รอบเอว',
        value: s.values[idx].toStringAsFixed(1),
        unit: 'in',
        chartHeight: 56,
        chart: MiniLineChart(
          data: s.values,
          dates: s.dates,
          color: AppColors.nutrition,
          indicatorIndex: idx,
          unit: ' in',
          interactive: false,
        ),
        bottom: WeekLabels(labels: WeekLabels.fromDates(s.dates)),
      ),
    );
  }
}

class _SpO2Card extends StatelessWidget {
  const _SpO2Card({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final s = data.spO2;
    return _LiveValue(
      initialIndex: s.latestIndex,
      builder: (idx, onTouch) => MetricCard(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const Spo2DetailScreen(),
            ),
          );
        },
        onAdd: () => showAddHealthDataScreen(
          context,
          initial: HealthMetricKey.spo2,
        ),
        icon: CupertinoIcons.wind,
        iconColor: AppColors.mindfulness,
        label: 'ออกซิเจนในเลือด',
        value: s.values[idx].round().toString(),
        unit: '%',
        chartHeight: 56,
        chart: MiniBarChart(
          values: s.values,
          dates: s.dates,
          color: AppColors.mindfulness,
          highlightIndex: idx,
          barWidth: 4,
          unit: '%',
          interactive: false,
        ),
        bottom: WeekLabels(labels: WeekLabels.fromDates(s.dates)),
      ),
    );
  }
}

class _BloodSugarCard extends StatelessWidget {
  const _BloodSugarCard({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final s = data.bloodSugar;
    return _LiveValue(
      initialIndex: s.latestIndex,
      builder: (idx, onTouch) => MetricCard(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const BloodSugarDetailScreen(),
            ),
          );
        },
        onAdd: () => showAddHealthDataScreen(
          context,
          initial: HealthMetricKey.bloodSugar,
        ),
        icon: CupertinoIcons.drop_fill,
        iconColor: AppColors.health,
        label: 'น้ำตาลในเลือด',
        value: s.values[idx].round().toString(),
        unit: 'mg/dl',
        chartHeight: 76,
        chart: MiniLineChart(
          data: s.values,
          dates: s.dates,
          color: AppColors.health,
          indicatorIndex: idx,
          unit: ' mg/dl',
          interactive: false,
        ),
        bottom: WeekLabels(labels: WeekLabels.fromDates(s.dates)),
      ),
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'รายการเด่น'),
        TipCard(
          title: 'ขอสรุปเกี่ยวกับสุขภาพของคุณ',
          content: data.aiTip,
        ),
        const SizedBox(height: spacing),
        _LiveValue(
          initialIndex: data.activeEnergy.latestIndex,
          builder: (idx, onTouch) => ActiveEnergyCard(
            kcal: data.activeEnergy.values[idx].round(),
            weekly: data.activeEnergy.values,
            dates: data.activeEnergy.dates,
            highlightIndex: idx,
            onTouch: onTouch,
          ),
        ),
        const SizedBox(height: spacing),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _StepsCard(data: data)),
              const SizedBox(width: spacing),
              Expanded(child: _ActivityMini(data: data)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final s = data.steps;
    return _LiveValue(
      initialIndex: s.latestIndex,
      builder: (idx, onTouch) => MetricCard(
        icon: Icons.directions_walk,
        iconColor: const Color(0xFFE32616),
        label: 'ก้าวเดิน',
        value: _formatInt(s.values[idx]),
        unit: 'ก้าว',
        chartHeight: 56,
        showChevron: false,
        chart: MiniBarChart(
          values: s.values,
          dates: s.dates,
          color: const Color(0xFFE32616),
          highlightIndex: idx,
          barWidth: 6,
          unit: ' steps',
          dimAlpha: 0.2,
          useDimGradient: true,
          onTouch: onTouch,
        ),
        bottom: WeekLabels(labels: WeekLabels.fromDates(s.dates)),
      ),
    );
  }
}

class _ActivityMini extends StatelessWidget {
  const _ActivityMini({required this.data});
  final HealthData data;

  @override
  Widget build(BuildContext context) {
    final a = data.activity;
    return MiniActivityCard(
      move: a.move,
      moveGoal: a.moveGoal,
      exercise: a.exercise,
      exerciseGoal: a.exerciseGoal,
      stand: a.stand,
      standGoal: a.standGoal,
    );
  }
}

class _HealthSkeleton extends StatelessWidget {
  final Color bg;

  const _HealthSkeleton({required this.bg});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: SkeletonHost(
        builder: (_, shimmer) => SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(shimmer: shimmer, width: 180, height: 32),
              const SizedBox(height: 24),
              // Tip card placeholder
              SkeletonBox(shimmer: shimmer, height: 96, borderRadius: 24),
              const SizedBox(height: 16),
              // Metric grid (2x3)
              for (int row = 0; row < 3; row++) ...[
                Row(
                  children: [
                    Expanded(
                      child: SkeletonBox(
                          shimmer: shimmer, height: 120, borderRadius: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SkeletonBox(
                          shimmer: shimmer, height: 120, borderRadius: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              // Big chart card
              SkeletonBox(shimmer: shimmer, height: 200, borderRadius: 24),
            ],
          ),
        ),
      ),
    );
  }
}
