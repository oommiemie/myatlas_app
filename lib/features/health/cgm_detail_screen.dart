import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/theme/app_typography.dart';

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

final _cgmSamples = <_CgmSample>[
  // Day — 48 half-hourly CGM readings (00:00..23:30) with realistic meal
  // spikes, dawn phenomenon, and sensor micro-fluctuations.
  _CgmSample(
    values: [
      // 00:00 post-dinner slow decline
      108, 104, 100, 96, 92, 89, 86, 84,
      // 04:00 overnight low then dawn rise
      82, 80, 80, 82, 86, 90, 94, 100,
      // 08:00 breakfast spike, peak ~09:00
      110, 132, 162, 170, 158, 140, 124, 112,
      // 12:00 lunch (12:30) peak ~13:30 then recovery
      118, 148, 182, 176, 154, 132, 116, 108,
      // 16:00 afternoon snack + stable
      106, 110, 118, 124, 120, 116, 122, 138,
      // 20:00 dinner peak then wind-down
      168, 188, 176, 154, 134, 122, 114, 110,
    ].map((e) => e.toDouble()).toList(),
    xLabels: const ['12 AM', '6', '12 PM', '6'],
    xLabelIndices: const [0, 12, 24, 36],
    pointLabels: const [
      '00:00', '00:30', '01:00', '01:30', '02:00', '02:30',
      '03:00', '03:30', '04:00', '04:30', '05:00', '05:30',
      '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
      '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
      '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
      '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
      '21:00', '21:30', '22:00', '22:30', '23:00', '23:30',
    ],
    dateLabel: '11 เม.ย. 69',
    markerIndex: 39,
  ),
  // Week — 7 daily averages
  _CgmSample(
    values: [124, 132, 118, 128, 136, 142, 126]
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
  // Month — 30 daily averages with natural drift and a post-holiday spike
  _CgmSample(
    values: [
      118, 122, 120, 116, 124, 132, 126, 120, 118, 122,
      128, 124, 118, 116, 120, 126, 130, 138, 144, 132,
      124, 118, 120, 124, 128, 136, 148, 140, 128, 122,
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
  // Year — 12 monthly averages with festive-season rise (Apr / Dec)
  _CgmSample(
    values: [120, 124, 128, 138, 130, 124, 126, 132, 128, 122, 126, 138]
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
            height: 250,
            child: _HeaderBackground(),
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
            Color(0xFFCB9AEE),
            Color(0xFF9333EA),
            Color(0xFF6B21A8),
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
          _LiquidGlassButton(
            icon: CupertinoIcons.chevron_back,
            onTap: onBack,
          ),
          const SizedBox(width: 10),
          Text(
            'CGM',
            style: AppTypography.title3(CupertinoColors.white).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _LiquidGlassButton(
            icon: CupertinoIcons.plus,
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}

class _LiquidGlassButton extends StatelessWidget {
  const _LiquidGlassButton({required this.icon, required this.onTap});
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
                color: CupertinoColors.white.withValues(alpha: 0.65),
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1A1A1A),
                size: 20,
              ),
            ),
          ),
        ),
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
                  'mg/dl',
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
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1A1A1A)
                                    .withValues(alpha: 0.06),
                              ),
                              child: const Icon(
                                CupertinoIcons.xmark,
                                color: Color(0xFF1A1A1A),
                                size: 16,
                              ),
                            ),
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
