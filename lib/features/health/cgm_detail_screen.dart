import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import 'widgets/add_measurement.dart';
import 'widgets/add_vital_sign_sheet.dart';
import 'widgets/health_detail_app_bar.dart';
import 'widgets/measure_animations.dart';

class _CgmSample {
  const _CgmSample({
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

// Real-time CGM data: 48 readings at 30-min intervals over the last ~24 hours.
// Index 0 = 10:30 (yesterday), index 47 = 10:00 today (= "NOW").
// Hand-tuned to look realistic: lunch + dinner peaks, overnight low, dawn rise,
// breakfast spike then recovery. Last value (90) shows on the hero gauge.
const _cgm24hValues = <double>[
  142, 130, 122, 118,            // 10:30-12:00 (post-breakfast settling)
  122, 134, 152, 172,            // 12:30-14:00 (lunch climb)
  178, 162, 148, 138,            // 14:30-16:00 (recovery)
  132, 130, 132, 138,            // 16:30-18:00 (afternoon)
  148, 165, 180, 188,            // 18:30-20:00 (dinner climb)
  176, 158, 140, 128,            // 20:30-22:00 (recovery)
  118, 110, 102, 95,             // 22:30-00:00 (pre-sleep)
  90, 86, 82, 80,                // 00:30-02:00 (sleeping)
  78, 78, 80, 82,                // 02:30-04:00 (overnight low)
  84, 88, 92, 96,                // 04:30-06:00 (dawn rise)
  100, 108, 118, 130,            // 06:30-08:00 (waking)
  145, 165, 110, 90,             // 08:30-10:00 (breakfast peak then NOW=90)
];

/// Builds 4 time windows ending at "now". Each slices the 24h dataset above.
List<_CgmSample> _buildCgmSamples() {
  // Window definitions: (hours, label-stride-hours).
  // 3h → labels every 1h; 6h → every 2h; 12h → every 4h; 24h → every 6h.
  // 30-min readings → 1h = 2 indices.
  String timeAt(int totalMinFromMidnightYesterday) {
    final total = totalMinFromMidnightYesterday;
    final hr = (total ~/ 60) % 24;
    final mn = total % 60;
    return '${hr.toString().padLeft(2, '0')}:${mn.toString().padLeft(2, '0')}';
  }

  // First reading is at 10:30 yesterday = 10*60+30 = 630 min from y-day midnight.
  String pointLabelFor(int idx) => timeAt(630 + idx * 30);

  _CgmSample sample({
    required int hours,
    required int strideHours,
  }) {
    final total = _cgm24hValues.length;
    // Number of readings spanning the window: hours * 2 (every 30min) + 1 to include both endpoints.
    final count = hours * 2 + 1;
    final start = (total - count).clamp(0, total - 1);
    final values = _cgm24hValues.sublist(start);
    // Build labels every `strideHours` from start, plus "NOW" at the end.
    // Window length in indices = values.length - 1.
    final lastIdx = values.length - 1;
    final stridePts = strideHours * 2;
    final indices = <int>[];
    for (int i = 0; i <= lastIdx; i += stridePts) {
      if (lastIdx - i >= stridePts) {
        // Skip second-to-last if too close to NOW.
        indices.add(i);
      }
    }
    indices.add(lastIdx);
    final labels = indices
        .map((i) => i == lastIdx ? 'NOW' : pointLabelFor(start + i))
        .toList();
    return _CgmSample(
      values: values,
      xLabels: labels,
      xLabelIndices: indices,
      pointLabels: List.generate(
        values.length,
        (i) => pointLabelFor(start + i),
      ),
      dateLabel: '$hours ชั่วโมงล่าสุด',
      markerIndex: lastIdx,
    );
  }

  return [
    sample(hours: 3, strideHours: 1),
    sample(hours: 6, strideHours: 2),
    sample(hours: 12, strideHours: 4),
    sample(hours: 24, strideHours: 6),
  ];
}

final _cgmSamples = _buildCgmSamples();

const _yLabels = [250, 200, 150, 100, 50];
const _yMax = 250.0;
const _yMin = 50.0;

const _lineColor = Color(0xFFAF52DE);

int _currentMarker(int tab, int n) => (n - 1).clamp(0, n - 1);

class CgmDetailScreen extends StatefulWidget {
  const CgmDetailScreen({super.key});

  @override
  State<CgmDetailScreen> createState() => _CgmDetailScreenState();
}

class _CgmDetailScreenState extends State<CgmDetailScreen> {
  int _tab = 0;
  int? _selectedIndex;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void dispose() {
    _scrollOffset.dispose();
    super.dispose();
  }

  Future<void> _addMeasurement() async {
    final result = await showAddMeasurement(
      context,
      title: 'เพิ่มค่าน้ำตาลต่อเนื่อง',
      animation: MeasureAnimationKind.sugarDrop,
      icon: CupertinoIcons.waveform_path_ecg,
      color: const Color(0xFFF59E0B),
      fields: const [
        VitalFieldConfig(
          label: 'น้ำตาลต่อเนื่อง (CGM)',
          placeholder: '100',
          unit: 'mg/dL',
        ),
      ],
    );
    if (result != null && mounted) {
      AppToast.success(context, 'บันทึกค่าน้ำตาลต่อเนื่องแล้ว');
    }
  }

  void _showCgmInfoSheet() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => const _CgmInfoSheet(),
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
            height: 180,
            child: DetailHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(
                  height: HealthDetailAppBar.safeAreaContentHeight,
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
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n is ScrollUpdateNotification ||
                            n is ScrollStartNotification) {
                          _scrollOffset.value = n.metrics.pixels;
                        }
                        return false;
                      },
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        children: [
                          _CgmChartCard(
                            tab: _tab,
                            onTabChange: (i) => setState(() => _tab = i),
                            selectedIndex: _selectedIndex,
                            onSelect: (idx) =>
                                setState(() => _selectedIndex = idx),
                          ),
                          const SizedBox(height: 16),
                          _AboutCgmCard(onTap: _showCgmInfoSheet),
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
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (_, offset, __) => HealthDetailAppBar(
                title: 'น้ำตาลต่อเนื่อง',
                scrollOffset: offset,
                onBack: () => Navigator.of(context).pop(),
                action: LiquidGlassButton(
                  icon: CupertinoIcons.plus,
                  onTap: _addMeasurement,
                  size: 40,
                  iconSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CgmChartCard extends StatelessWidget {
  const _CgmChartCard({
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
    final sample = _cgmSamples[tab];
    final fallback = _currentMarker(tab, sample.values.length);
    final activeIdx =
        (selectedIndex ?? fallback).clamp(0, sample.values.length - 1);
    final value = sample.values[activeIdx];
    final timeLabel = activeIdx == sample.values.length - 1
        ? 'ตอนนี้'
        : sample.pointLabels[activeIdx];
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _CgmHeroGauge(
              value: value,
              timeLabel: timeLabel,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _SegmentedTabs(
              tabs: const ['3 ชม.', '6 ชม.', '12 ชม.', '24 ชม.'],
              selected: tab,
              onChange: onTabChange,
            ),
          ),
          SizedBox(
            height: 216,
            child: _CgmAreaChart(
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

/// Circle gauge that mirrors the Figma hero — soft mint ring around current
/// reading, last-known timestamp, and a status pill.
class _CgmHeroGauge extends StatelessWidget {
  const _CgmHeroGauge({required this.value, required this.timeLabel});
  final double value;
  final String timeLabel;

  ({String label, Color color}) _statusFor(double v) {
    if (v < 70) return (label: 'น้ำตาลต่ำ', color: const Color(0xFFD97706));
    if (v >= 200) {
      return (label: 'สูงมาก', color: const Color(0xFFDC2626));
    }
    if (v >= 140) return (label: 'สูง', color: const Color(0xFFD97706));
    return (label: 'ปกติ', color: const Color(0xFF4CA30D));
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusFor(value);
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: CustomPaint(
              key: ValueKey(status.color.toARGB32()),
              size: const Size(150, 150),
              painter: _GaugeRingPainter(color: status.color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.arrow_up_left_circle,
                    size: 10,
                    color: Color(0xFF6D756E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$timeLabel น.',
                    style: const TextStyle(
                      color: Color(0xFF6D756E),
                      fontSize: 11,
                      letterSpacing: -0.6,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value.round().toString(),
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.6,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'mg/dL',
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: CupertinoColors.white.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.275,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugeRingPainter extends CustomPainter {
  _GaugeRingPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    // Soft outer glow
    canvas.drawCircle(
      center,
      radius + 1,
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Outer thin track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.35),
    );
    // Inner thick band
    canvas.drawCircle(
      center,
      radius - 4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = color.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeRingPainter old) => old.color != color;
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

class _CgmAreaChart extends StatefulWidget {
  const _CgmAreaChart({
    required this.tab,
    required this.selectedIndex,
    required this.onSelect,
  });
  final int tab;
  final int? selectedIndex;
  final ValueChanged<int?> onSelect;

  @override
  State<_CgmAreaChart> createState() => _CgmAreaChartState();
}

class _CgmAreaChartState extends State<_CgmAreaChart>
    with TickerProviderStateMixin {
  static const double _leftPad = 16.0;
  static const double _rightPad = 16.0;
  static const double _axisWidth = 48.0;
  static const int _resampleN = 60;

  late AnimationController _entryCtrl;
  late AnimationController _tabCtrl;
  late _CgmSample _from;
  late _CgmSample _to;

  @override
  void initState() {
    super.initState();
    _from = _cgmSamples[widget.tab];
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
  void didUpdateWidget(covariant _CgmAreaChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      _from = _to;
      _to = _cgmSamples[widget.tab];
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
    final current = _cgmSamples[widget.tab];
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
                      painter: _CgmChartPainter(
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
      fontSize: 11,
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

class _CgmChartPainter extends CustomPainter {
  _CgmChartPainter({
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
      fontSize: 11,
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
      colors: [Color(0x66AF52DE), Color(0x1FAF52DE), Color(0x00AF52DE)],
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
    // Soft glow behind the line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = _lineColor.withValues(alpha: 0.22)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = _lineColor
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
          ..color = _lineColor.withValues(alpha: 0.5 * markerOpacity)
          ..strokeWidth = 1,
        dash: 4,
        gap: 3,
      );
      // Outer soft halo
      canvas.drawCircle(
        Offset(markerX, yFor(markerY)),
        10,
        Paint()
          ..color = _lineColor.withValues(alpha: 0.18 * markerOpacity),
      );
      canvas.drawCircle(
        Offset(markerX, yFor(markerY)),
        6,
        Paint()..color = CupertinoColors.white.withValues(alpha: markerOpacity),
      );
      canvas.drawCircle(
        Offset(markerX, yFor(markerY)),
        4.5,
        Paint()..color = _lineColor.withValues(alpha: markerOpacity),
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
  bool shouldRepaint(covariant _CgmChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.xPositions != xPositions ||
      oldDelegate.markerX != markerX ||
      oldDelegate.markerY != markerY ||
      oldDelegate.entry != entry ||
      oldDelegate.tabT != tabT;
}

class _AboutCgmCard extends StatelessWidget {
  const _AboutCgmCard({this.onTap});
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
                  'assets/images/vital_cgm.png',
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
                          'เกี่ยวกับ CGM',
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
                            fontSize: 11,
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
                          'CGM (Continuous Glucose Monitoring) คือ\nระบบติดตามระดับน้ำตาลในเลือดแบบต่อเนื่อง 24 ชั่วโมง',
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
      'ตัวเลือก',
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

class _CgmInfoSheet extends StatelessWidget {
  const _CgmInfoSheet();

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
                                'เกี่ยวกับ CGM',
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
                          _CgmHeroHeader(),
                          _CgmInfoCard(
                            children: [
                              _CgmSection(
                                title: 'CGM คืออะไร?',
                                children: [
                                  _CgmBodyText(
                                    'CGM (Continuous Glucose Monitoring) คือ ระบบเซ็นเซอร์ติดผิวหนังที่วัดระดับน้ำตาลในของเหลวระหว่างเซลล์ตลอด 24 ชั่วโมง ส่งข้อมูลไปยังมือถือแบบต่อเนื่อง',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _CgmSection(
                                title: 'ประโยชน์ของ CGM',
                                children: [
                                  _CgmStatusRow(
                                    icon: CupertinoIcons.chart_bar_alt_fill,
                                    color: Color(0xFF9333EA),
                                    text: 'เห็นแนวโน้มน้ำตาลรายวัน',
                                  ),
                                  _CgmStatusRow(
                                    icon: CupertinoIcons.timer_fill,
                                    color: Color(0xFF7C3AED),
                                    text: 'ตรวจจับการขึ้นลงหลังอาหาร',
                                  ),
                                  _CgmStatusRow(
                                    icon: Icons.notifications_active_rounded,
                                    color: Color(0xFFEF4444),
                                    text: 'เตือนเมื่อน้ำตาลสูง/ต่ำเกิน',
                                  ),
                                  _CgmStatusRow(
                                    icon: Icons.medical_services_rounded,
                                    color: Color(0xFF22C55E),
                                    text: 'ช่วยปรับอินซูลิน / ยา / อาหาร',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _CgmSection(
                                title: 'ค่าน้ำตาลที่ควรทราบ',
                                children: [
                                  _CgmSubheading('Time in Range (TIR)'),
                                  SizedBox(height: 4),
                                  _CgmStatusRow(
                                    icon: CupertinoIcons.checkmark_circle_fill,
                                    color: Color(0xFF22C55E),
                                    text: 'ปกติ 70 – 180 mg/dL',
                                  ),
                                  _CgmStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFF0EA5E9),
                                    text: 'ต่ำ < 70 mg/dL',
                                  ),
                                  _CgmStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFFEAB308),
                                    text: 'สูง 181 – 250 mg/dL',
                                  ),
                                  _CgmStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFFEF4444),
                                    text: 'สูงมาก > 250 mg/dL',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _CgmSection(
                                title: 'ใครเหมาะกับ CGM?',
                                children: [
                                  _CgmStatusRow(
                                    icon: Icons.healing_rounded,
                                    color: Color(0xFF6D756E),
                                    text: 'ผู้ป่วยเบาหวานชนิดที่ 1 / 2',
                                  ),
                                  _CgmStatusRow(
                                    icon: Icons.pregnant_woman_rounded,
                                    color: Color(0xFF6D756E),
                                    text: 'หญิงตั้งครรภ์ที่มีเบาหวาน',
                                  ),
                                  _CgmStatusRow(
                                    icon: Icons.fitness_center_rounded,
                                    color: Color(0xFF6D756E),
                                    text: 'ผู้ที่ต้องการปรับไลฟ์สไตล์/อาหาร',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _CgmSection(
                                title: 'ใช้ CGM ให้ได้ผล',
                                children: [
                                  _CgmBodyText(
                                    '  - ติดเซ็นเซอร์ตามคำแนะนำบริษัทผู้ผลิต\n  - สอบเทียบตามช่วงเวลาที่แนะนำ\n  - บันทึกอาหาร / กิจกรรมคู่กับค่า\n  - ปรึกษาแพทย์เมื่อค่าผิดปกติต่อเนื่อง',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _CgmInfoCard(
                            children: [_CgmReferenceRow()],
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

class _CgmHeroHeader extends StatelessWidget {
  const _CgmHeroHeader();

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
                    Color(0x559333EA),
                    Color(0x229333EA),
                    Color(0x009333EA),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                'assets/images/vital_cgm.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CgmInfoCard extends StatelessWidget {
  const _CgmInfoCard({required this.children});
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

class _CgmSection extends StatelessWidget {
  const _CgmSection({required this.title, required this.children});
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

class _CgmBodyText extends StatelessWidget {
  const _CgmBodyText(this.text);
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

class _CgmSubheading extends StatelessWidget {
  const _CgmSubheading(this.text);
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

class _CgmStatusRow extends StatelessWidget {
  const _CgmStatusRow({
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
          Icon(icon, color: color.withValues(alpha: 0.85), size: 14),
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

class _CgmReferenceRow extends StatelessWidget {
  const _CgmReferenceRow();

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
