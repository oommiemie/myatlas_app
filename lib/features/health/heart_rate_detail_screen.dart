import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import 'widgets/add_measurement.dart';
import 'widgets/add_vital_sign_sheet.dart';
import 'widgets/measure_animations.dart';

class _HrSample {
  const _HrSample({
    required this.values,
    required this.xLabels,
    required this.xLabelIndices,
    required this.pointLabels,
    required this.dateLabel,
    required this.markerIndex,
  });
  final List<double> values;
  final List<String> xLabels;
  final List<int> xLabelIndices;
  final List<String> pointLabels;
  final String dateLabel;
  final int markerIndex;
}

final _hrSamples = <_HrSample>[
  // Day — 24 hourly readings simulating a typical workday with an evening
  // workout. Sleep dips to ~52-58, a commute bump ~100, mid-day steady ~78-88,
  // workout spike to ~150, recovery back to sleep-range by 11pm.
  _HrSample(
    values: [
      62, 58, 55, 53, 52, 54, 60, 72,
      88, 102, 86, 78, 82, 88, 80, 76,
      84, 96, 132, 150, 118, 92, 76, 66,
    ].map((e) => e.toDouble()).toList(),
    xLabels: const ['12 AM', '6', '12 PM', '6'],
    xLabelIndices: const [0, 6, 12, 18],
    pointLabels: const [
      '00:00', '01:00', '02:00', '03:00', '04:00', '05:00',
      '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
      '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
      '18:00', '19:00', '20:00', '21:00', '22:00', '23:00',
    ],
    dateLabel: '11 เม.ย. 69',
    markerIndex: 19,
  ),
  // Week — 7 days (Mon..Sun), daily average RHR with variation from
  // activity: weekends slightly higher from social activity/workouts.
  _HrSample(
    values: [72, 74, 71, 76, 78, 82, 75]
        .map((e) => e.toDouble())
        .toList(),
    xLabels: const ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'],
    xLabelIndices: const [0, 1, 2, 3, 4, 5, 6],
    pointLabels: const [
      'จ. 7 เม.ย.',
      'อ. 8 เม.ย.',
      'พ. 9 เม.ย.',
      'พฤ. 10 เม.ย.',
      'ศ. 11 เม.ย.',
      'ส. 12 เม.ย.',
      'อา. 13 เม.ย.',
    ],
    dateLabel: 'สัปดาห์ที่ 15',
    markerIndex: 4,
  ),
  // Month — 30 daily average RHR. Includes one stressful peak (day 18, ~88)
  // and a recovery dip after a rest day (day 22, ~70).
  _HrSample(
    values: [
      73, 75, 74, 72, 76, 78, 75, 73, 74, 76,
      79, 78, 75, 73, 74, 77, 80, 84, 88, 82,
      76, 70, 72, 74, 76, 78, 77, 75, 74, 76,
    ].map((e) => e.toDouble()).toList(),
    xLabels: const ['1', '8', '15', '22', '29'],
    xLabelIndices: const [0, 7, 14, 21, 28],
    pointLabels: const [
      '1 เม.ย. 69', '2 เม.ย. 69', '3 เม.ย. 69', '4 เม.ย. 69', '5 เม.ย. 69',
      '6 เม.ย. 69', '7 เม.ย. 69', '8 เม.ย. 69', '9 เม.ย. 69', '10 เม.ย. 69',
      '11 เม.ย. 69', '12 เม.ย. 69', '13 เม.ย. 69', '14 เม.ย. 69', '15 เม.ย. 69',
      '16 เม.ย. 69', '17 เม.ย. 69', '18 เม.ย. 69', '19 เม.ย. 69', '20 เม.ย. 69',
      '21 เม.ย. 69', '22 เม.ย. 69', '23 เม.ย. 69', '24 เม.ย. 69', '25 เม.ย. 69',
      '26 เม.ย. 69', '27 เม.ย. 69', '28 เม.ย. 69', '29 เม.ย. 69', '30 เม.ย. 69',
    ],
    dateLabel: 'เม.ย. 69',
    markerIndex: 10,
  ),
  // Year — 12 monthly average RHR. Summer months (Apr-Jun, hot Thailand)
  // trend slightly higher from heat; cool months trend lower.
  _HrSample(
    values: [72, 73, 75, 78, 80, 81, 80, 78, 76, 74, 72, 71]
        .map((e) => e.toDouble())
        .toList(),
    xLabels: const ['ม.ค.', 'เม.ย.', 'ก.ค.', 'ต.ค.'],
    xLabelIndices: const [0, 3, 6, 9],
    pointLabels: const [
      'ม.ค. 69', 'ก.พ. 69', 'มี.ค. 69', 'เม.ย. 69',
      'พ.ค. 69', 'มิ.ย. 69', 'ก.ค. 69', 'ส.ค. 69',
      'ก.ย. 69', 'ต.ค. 69', 'พ.ย. 69', 'ธ.ค. 69',
    ],
    dateLabel: '2569',
    markerIndex: 3,
  ),
];

const _yLabels = [180, 140, 100, 70, 40];
const _yMax = 180.0;
const _yMin = 40.0;

int _currentMarker(int tab, int n) => (n - 1).clamp(0, n - 1);

class HeartRateDetailScreen extends StatefulWidget {
  const HeartRateDetailScreen({super.key});

  @override
  State<HeartRateDetailScreen> createState() => _HeartRateDetailScreenState();
}

class _HeartRateDetailScreenState extends State<HeartRateDetailScreen> {
  int _tab = 0;
  int? _selectedIndex;

  void _showHrInfoSheet() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => const _HrInfoSheet(),
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
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: _HeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(
                  onBack: () => Navigator.of(context).pop(),
                  onAdd: () async {
                    final result = await showAddMeasurement(
                      context,
                      title: 'เพิ่ม Heart Rate',
                      icon: CupertinoIcons.heart_fill,
                      color: const Color(0xFFBE123C),
                      animation: MeasureAnimationKind.ecg,
                      fields: const [
                        VitalFieldConfig(
                          label: 'อัตราการเต้นหัวใจ',
                          placeholder: '72',
                          unit: 'bpm',
                        ),
                      ],
                    );
                    if (result != null && context.mounted) {
                      AppToast.success(context, 'บันทึกค่า Heart Rate แล้ว');
                    }
                  },
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
                        _HrChartCard(
                          tab: _tab,
                          onTabChange: (i) => setState(() => _tab = i),
                          selectedIndex: _selectedIndex,
                          onSelect: (idx) =>
                              setState(() => _selectedIndex = idx),
                        ),
                        const SizedBox(height: 16),
                        _AboutHrCard(onTap: _showHrInfoSheet),
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
            Color(0xFFE78CA6),
            Color(0xFFCF5073),
            Color(0xFF9B1F4E),
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
            'Heart Rate',
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


class _HrChartCard extends StatelessWidget {
  const _HrChartCard({
    required this.tab,
    required this.onTabChange,
    required this.selectedIndex,
    required this.onSelect,
  });
  final int tab;
  final ValueChanged<int> onTabChange;
  final int? selectedIndex;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    final sample = _hrSamples[tab];
    final fallback = _currentMarker(tab, sample.values.length);
    final activeIdx =
        (selectedIndex ?? fallback).clamp(0, sample.values.length - 1);
    final value = sample.values[activeIdx];
    final activeLabel = selectedIndex != null
        ? sample.pointLabels[activeIdx]
        : sample.dateLabel;
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _SegmentedTabs(
              tabs: const ['วัน', 'สัปดาห์', 'เดือน', 'ปี'],
              selected: tab,
              onChange: onTabChange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ValueDisplay(
                    value: value,
                    dateLabel: activeLabel,
                    isSelected: selectedIndex != null,
                  ),
                ),
                const _StatusBadge(label: 'ปกติ'),
              ],
            ),
          ),
          SizedBox(
            height: 216,
            child: _HrAreaChart(
              tab: tab,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
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

class _ValueDisplay extends StatelessWidget {
  const _ValueDisplay({
    required this.value,
    required this.dateLabel,
    required this.isSelected,
  });
  final double value;
  final String dateLabel;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
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
        key: ValueKey('$value-$dateLabel-$isSelected'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSelected ? 'ค่าที่เลือก' : 'Value',
            style: AppTypography.caption1(const Color(0xFF6D756E)).copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.275,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.round().toString(),
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
                  'bpm',
                  style: AppTypography.caption2(const Color(0xFF737373))
                      .copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dateLabel,
            style: AppTypography.caption2(const Color(0xFF737373))
                .copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});
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

class _HrAreaChart extends StatefulWidget {
  const _HrAreaChart({
    required this.tab,
    required this.selectedIndex,
    required this.onSelect,
  });
  final int tab;
  final int? selectedIndex;
  final ValueChanged<int?> onSelect;

  @override
  State<_HrAreaChart> createState() => _HrAreaChartState();
}

class _HrAreaChartState extends State<_HrAreaChart>
    with TickerProviderStateMixin {
  static const double _leftPad = 16.0;
  static const double _rightPad = 16.0;
  static const double _axisWidth = 48.0;
  static const int _resampleN = 60;

  late AnimationController _entryCtrl;
  late AnimationController _tabCtrl;
  late _HrSample _from;
  late _HrSample _to;

  @override
  void initState() {
    super.initState();
    _from = _hrSamples[widget.tab];
    _to = _from;
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..value = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void didUpdateWidget(covariant _HrAreaChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      _from = _to;
      _to = _hrSamples[widget.tab];
      _tabCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
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

  List<double> _resample(List<double> src) {
    if (src.length == _resampleN) return List.of(src);
    final out = <double>[];
    for (int i = 0; i < _resampleN; i++) {
      final t = i / (_resampleN - 1);
      final pos = t * (src.length - 1);
      final lo = pos.floor();
      final hi = (lo + 1).clamp(0, src.length - 1);
      final f = pos - lo;
      out.add(src[lo] + (src[hi] - src[lo]) * f);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final current = _hrSamples[widget.tab];
    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleWidth = constraints.maxWidth - _axisWidth;
        final contentWidth = visibleWidth;
        final chartWidth = contentWidth - _leftPad - _rightPad;
        final n = current.values.length;
        final xPositions = [
          for (int i = 0; i < n; i++)
            n == 1
                ? _leftPad + chartWidth / 2
                : _leftPad + (i / (n - 1)) * chartWidth,
        ];
        return Row(
          children: [
            SizedBox(
              width: contentWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => widget.onSelect(
                    _nearestIndexByX(d.localPosition.dx, xPositions)),
                onPanUpdate: (d) => widget.onSelect(
                    _nearestIndexByX(d.localPosition.dx, xPositions)),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_entryCtrl, _tabCtrl]),
                  builder: (_, __) {
                    final entry =
                        Curves.easeOutCubic.transform(_entryCtrl.value);
                    final tabT = Curves.fastEaseInToSlowEaseOut
                        .transform(_tabCtrl.value);
                    final isMorphing = tabT < 1.0 && !identical(_from, _to);
                    List<double> morphValues;
                    List<double> morphXPositions;
                    List<String> xLabels;
                    List<int> xLabelIndices;
                    if (isMorphing) {
                      final a = _resample(_from.values);
                      final b = _resample(_to.values);
                      morphValues = [
                        for (int i = 0; i < _resampleN; i++)
                          a[i] + (b[i] - a[i]) * tabT,
                      ];
                      morphXPositions = [
                        for (int i = 0; i < _resampleN; i++)
                          _leftPad + (i / (_resampleN - 1)) * chartWidth,
                      ];
                      xLabels = tabT < 0.5 ? _from.xLabels : _to.xLabels;
                      xLabelIndices = tabT < 0.5
                          ? [
                              for (final idx in _from.xLabelIndices)
                                ((idx / (_from.values.length - 1)) *
                                        (_resampleN - 1))
                                    .round(),
                            ]
                          : [
                              for (final idx in _to.xLabelIndices)
                                ((idx / (_to.values.length - 1)) *
                                        (_resampleN - 1))
                                    .round(),
                            ];
                    } else {
                      morphValues = List.of(current.values);
                      morphXPositions = xPositions;
                      xLabels = current.xLabels;
                      xLabelIndices = current.xLabelIndices;
                    }
                    final mIdx = (widget.selectedIndex ??
                            _currentMarker(widget.tab, current.values.length))
                        .clamp(0, n - 1);
                    final markerX = n == 1
                        ? _leftPad + chartWidth / 2
                        : _leftPad + (mIdx / (n - 1)) * chartWidth;
                    final markerY = current.values[mIdx];
                    return CustomPaint(
                      painter: _HrChartPainter(
                        values: morphValues,
                        xPositions: morphXPositions,
                        xLabels: xLabels,
                        xLabelIndices: xLabelIndices,
                        markerX: markerX,
                        markerY: markerY,
                        entry: entry,
                        tabT: tabT,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: _axisWidth,
              child: CustomPaint(
                painter: _AxisLabelsPainter(),
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
    for (int i = 0; i < _yLabels.length; i++) {
      final t = i / (_yLabels.length - 1);
      final y = topPad + t * chartHeight;
      final tp = TextPainter(
        text: TextSpan(text: _yLabels[i].toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(8, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HrChartPainter extends CustomPainter {
  _HrChartPainter({
    required this.values,
    required this.xPositions,
    required this.xLabels,
    required this.xLabelIndices,
    required this.markerX,
    required this.markerY,
    required this.entry,
    required this.tabT,
  });
  final List<double> values;
  final List<double> xPositions;
  final List<String> xLabels;
  final List<int> xLabelIndices;
  final double markerX;
  final double markerY;
  final double entry;
  final double tabT;

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

    for (int i = 0; i < _yLabels.length; i++) {
      final t = i / (_yLabels.length - 1);
      final y = topPad + t * chartHeight;
      final isLast = i == _yLabels.length - 1;
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
      final pointIdx = xLabelIndices[i].clamp(0, xPositions.length - 1);
      final x = xPositions[pointIdx];
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, topPad + chartHeight + 6),
      );
    }

    double yFor(double v) =>
        topPad + (1 - (v - _yMin) / (_yMax - _yMin)) * chartHeight;

    const lineColor = Color(0xFFFF2D55);
    final isMorphing = tabT < 1.0;

    final points = [
      for (int i = 0; i < values.length; i++)
        Offset(xPositions[i], yFor(values[i])),
    ];

    final linePath = _smoothPath(points);
    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, topPad + chartHeight)
      ..lineTo(points.first.dx, topPad + chartHeight)
      ..close();
    final areaShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x66FF2D55), Color(0x1FFF2D55), Color(0x00FF2D55)],
      stops: [0.0, 0.55, 1.0],
    ).createShader(Rect.fromLTWH(leftPad, topPad, chartWidth, chartHeight));

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

    if (!isMorphing && markerX - leftPad <= revealWidth + 0.5) {
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
        Offset(markerX, yFor(markerY)),
        10,
        Paint()..color = lineColor.withValues(alpha: 0.18 * markerOpacity),
      );
      canvas.drawCircle(
        Offset(markerX, yFor(markerY)),
        6,
        Paint()..color = CupertinoColors.white.withValues(alpha: markerOpacity),
      );
      canvas.drawCircle(
        Offset(markerX, yFor(markerY)),
        4.5,
        Paint()..color = lineColor.withValues(alpha: markerOpacity),
      );
      canvas.drawCircle(
        Offset(markerX, yFor(markerY)),
        1.8,
        Paint()..color = CupertinoColors.white.withValues(alpha: markerOpacity),
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
  bool shouldRepaint(covariant _HrChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.xPositions != xPositions ||
      oldDelegate.markerX != markerX ||
      oldDelegate.markerY != markerY ||
      oldDelegate.entry != entry ||
      oldDelegate.tabT != tabT;
}

class _AboutHrCard extends StatelessWidget {
  const _AboutHrCard({this.onTap});
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
                  'assets/images/vital_heartrate.png',
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
                          'เกี่ยวกับการเต้นของหัวใจ',
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
                          'การเต้นของหัวใจเป็นกระบวนการพื้นฐานที่สำคัญที่สุดสำหรับการรักษาชีวิตมนุษย์ โดยการเต้นของหัวใจจะช่วยให้เลือดไหลเวียนไปยังอวัยวะต่างๆ',
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
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: _SettingsRowText('แสดงข้อมูลทั้งหมด')),
              Icon(
                CupertinoIcons.chevron_right,
                color: Color(0xFF6D756E),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 0.5, color: const Color(0xFFE5E5E5)),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _SettingsRowText('การเชื่อมต่ออุปกรณ์')),
              Icon(
                CupertinoIcons.chevron_right,
                color: Color(0xFF6D756E),
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsRowText extends StatelessWidget {
  const _SettingsRowText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.subheadline(const Color(0xFF1A1A1A)).copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _HrInfoSheet extends StatelessWidget {
  const _HrInfoSheet();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(38)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA).withValues(alpha: 0.92),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.white.withValues(alpha: 0.35),
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
                                'เกี่ยวกับการเต้นของหัวใจ',
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
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: const [
                          _HrHeroHeader(),
                          _HrInfoCard(
                            children: [
                              _HrSection(
                                title: 'การเต้นของหัวใจคืออะไร?',
                                children: [
                                  _HrBodyText(
                                    'การเต้นของหัวใจ (Heart Rate) คือ จำนวนครั้งที่หัวใจบีบตัวต่อนาที ใช้สะท้อนสมรรถภาพระบบไหลเวียนและสภาวะของร่างกาย',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _HrSection(
                                title: 'อัตราการเต้นของหัวใจปกติ',
                                children: [
                                  _HrBodyText(
                                    'ผู้ใหญ่ขณะพัก: 60 – 100 ครั้ง/นาที',
                                  ),
                                  SizedBox(height: 6),
                                  _HrSubheading('ระดับอัตราการเต้น'),
                                  SizedBox(height: 4),
                                  _HrStatusRow(
                                    icon: CupertinoIcons.checkmark_circle_fill,
                                    color: Color(0xFF22C55E),
                                    text: 'ปกติ 60 – 100 ครั้ง/นาที',
                                  ),
                                  _HrStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFF0EA5E9),
                                    text: 'ต่ำกว่า < 60 (Bradycardia)',
                                  ),
                                  _HrStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFFF97316),
                                    text: 'สูงกว่า > 100 (Tachycardia)',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _HrSection(
                                title: 'ทำไมอัตราเต้นถึงเปลี่ยนแปลง?',
                                children: [
                                  _HrStatusRow(
                                    icon: Icons.directions_run_rounded,
                                    color: Color(0xFF6D756E),
                                    text: 'การออกกำลังกาย / กิจกรรม',
                                  ),
                                  _HrStatusRow(
                                    icon: CupertinoIcons.bed_double_fill,
                                    color: Color(0xFF6D756E),
                                    text: 'การพักผ่อน / การนอนหลับ',
                                  ),
                                  _HrStatusRow(
                                    icon: Icons.sentiment_very_dissatisfied,
                                    color: Color(0xFF6D756E),
                                    text: 'ความเครียด / ความวิตกกังวล',
                                  ),
                                  _HrStatusRow(
                                    icon: CupertinoIcons.heart_fill,
                                    color: Color(0xFF6D756E),
                                    text: 'โรคหัวใจ / ความดันโลหิต',
                                  ),
                                  _HrStatusRow(
                                    icon: CupertinoIcons.drop_fill,
                                    color: Color(0xFF6D756E),
                                    text: 'การขาดน้ำ / คาเฟอีน',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _HrSection(
                                title: 'วิธีวัดให้แม่นยำ',
                                children: [
                                  _HrBodyText(
                                    '  - นั่งพักเงียบ ๆ 5 นาที\n  - วัดในเวลาใกล้เคียงกันของวัน\n  - ไม่ดื่มกาแฟ/ออกกำลังกายก่อนวัด\n  - วัดซ้ำ 2–3 ครั้งเพื่อหาค่าเฉลี่ย',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _HrSection(
                                title: 'ดูแลหัวใจให้แข็งแรง',
                                children: [
                                  _HrStatusRow(
                                    icon: Icons.directions_run_rounded,
                                    color: Color(0xFF22C55E),
                                    text: 'ออกกำลังกายแอโรบิกสม่ำเสมอ',
                                  ),
                                  _HrStatusRow(
                                    icon: CupertinoIcons.moon_zzz_fill,
                                    color: Color(0xFF8B5CF6),
                                    text: 'พักผ่อนให้เพียงพอ',
                                  ),
                                  _HrStatusRow(
                                    icon: Icons.restaurant_rounded,
                                    color: Color(0xFFF97316),
                                    text: 'อาหารสมดุล ลดเค็ม / ไขมันอิ่มตัว',
                                  ),
                                  _HrStatusRow(
                                    icon: Icons.medical_services_rounded,
                                    color: Color(0xFFE11D48),
                                    text: 'ตรวจสุขภาพเมื่อเต้นผิดจังหวะบ่อย',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _HrInfoCard(
                            children: [_HrReferenceRow()],
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

class _HrHeroHeader extends StatelessWidget {
  const _HrHeroHeader();

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
                    Color(0x55E11D48),
                    Color(0x22E11D48),
                    Color(0x00E11D48),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                'assets/images/heart_rate_hero_anim.gif',
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/vital_heartrate.png',
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

class _HrInfoCard extends StatelessWidget {
  const _HrInfoCard({required this.children});
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

class _HrSection extends StatelessWidget {
  const _HrSection({required this.title, required this.children});
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
        ...children,
      ],
    );
  }
}

class _HrBodyText extends StatelessWidget {
  const _HrBodyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTypography.subheadline(const Color(0xFF1A1A1A)).copyWith(
          fontSize: 14,
          height: 1.43,
          letterSpacing: 0.14,
        ),
      ),
    );
  }
}

class _HrSubheading extends StatelessWidget {
  const _HrSubheading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Text(
        text,
        style: AppTypography.subheadline(const Color(0xFF1A1A1A)).copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.43,
          letterSpacing: 0.14,
        ),
      ),
    );
  }
}

class _HrStatusRow extends StatelessWidget {
  const _HrStatusRow({
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
      padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.8), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  AppTypography.subheadline(const Color(0xFF1A1A1A)).copyWith(
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

class _HrReferenceRow extends StatelessWidget {
  const _HrReferenceRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'แหล่งอ้างอิง',
            style: AppTypography.subheadline(const Color(0xFF1A1A1A))
                .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const Icon(
          CupertinoIcons.arrow_up_right_square_fill,
          color: Color(0xFF6D756E),
          size: 16,
        ),
      ],
    );
  }
}
