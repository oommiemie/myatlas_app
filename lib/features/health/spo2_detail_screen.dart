import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/theme/app_typography.dart';

class _SpSample {
  const _SpSample({
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

final _spSamples = <_SpSample>[
  // Day — hourly SpO₂ readings; typically 95-99% with mild dips during sleep
  _SpSample(
    values: [
      96, 95, 95, 94, 94, 95, 96, 97,
      98, 98, 97, 97, 98, 97, 96, 97,
      98, 97, 96, 97, 98, 97, 96, 95,
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
    markerIndex: 16,
  ),
  // Week — 7 days
  _SpSample(
    values: [97, 96, 98, 97, 95, 96, 97].map((e) => e.toDouble()).toList(),
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
  // Month — 30 days
  _SpSample(
    values: [
      97, 96, 97, 98, 96, 95, 96, 97, 98, 97,
      96, 95, 97, 98, 96, 97, 95, 96, 97, 98,
      97, 96, 95, 97, 98, 96, 97, 96, 95, 97,
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
  // Year — 12 months
  _SpSample(
    values: [97, 97, 96, 96, 95, 96, 96, 97, 97, 98, 97, 97]
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

const _yLabels = [100, 75, 50, 25, 0];
const _yMax = 100.0;
const _yMin = 0.0;

int _currentMarker(int tab, int n) => (n - 1).clamp(0, n - 1);

class Spo2DetailScreen extends StatefulWidget {
  const Spo2DetailScreen({super.key});

  @override
  State<Spo2DetailScreen> createState() => _Spo2DetailScreenState();
}

class _Spo2DetailScreenState extends State<Spo2DetailScreen> {
  int _tab = 0;
  int? _selectedIndex;

  void _showSpInfoSheet() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => const _SpInfoSheet(),
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
                        _SpChartCard(
                          tab: _tab,
                          onTabChange: (i) => setState(() => _tab = i),
                          selectedIndex: _selectedIndex,
                          onSelect: (idx) =>
                              setState(() => _selectedIndex = idx),
                        ),
                        const SizedBox(height: 16),
                        _AboutSpCard(onTap: _showSpInfoSheet),
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
            Color(0xFF98D5F5),
            Color(0xFF36BFFA),
            Color(0xFF1B86C4),
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
            'SpO₂',
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

class _SpChartCard extends StatelessWidget {
  const _SpChartCard({
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
    final sample = _spSamples[tab];
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
            child: _SpBarChart(
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
                  '%',
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

class _SpBarChart extends StatefulWidget {
  const _SpBarChart({
    required this.tab,
    required this.selectedIndex,
    required this.onSelect,
  });
  final int tab;
  final int? selectedIndex;
  final ValueChanged<int?> onSelect;

  @override
  State<_SpBarChart> createState() => _SpBarChartState();
}

class _SpBarChartState extends State<_SpBarChart>
    with TickerProviderStateMixin {
  static const double _leftPad = 16.0;
  static const double _rightPad = 16.0;
  static const double _axisWidth = 48.0;

  late AnimationController _entryCtrl;
  late AnimationController _tabCtrl;
  late _SpSample _from;
  late _SpSample _to;

  @override
  void initState() {
    super.initState();
    _from = _spSamples[widget.tab];
    _to = _from;
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..value = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void didUpdateWidget(covariant _SpBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      _from = _to;
      _to = _spSamples[widget.tab];
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

  @override
  Widget build(BuildContext context) {
    final current = _spSamples[widget.tab];
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
                    final markerIdx = (widget.selectedIndex ??
                            _currentMarker(widget.tab, current.values.length))
                            .clamp(0, n - 1);
                    return CustomPaint(
                      painter: _SpBarPainter(
                        values: current.values,
                        xPositions: xPositions,
                        xLabels: current.xLabels,
                        xLabelIndices: current.xLabelIndices,
                        markerIndex: markerIdx,
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

class _SpBarPainter extends CustomPainter {
  _SpBarPainter({
    required this.values,
    required this.xPositions,
    required this.xLabels,
    required this.xLabelIndices,
    required this.markerIndex,
    required this.entry,
    required this.tabT,
  });
  final List<double> values;
  final List<double> xPositions;
  final List<String> xLabels;
  final List<int> xLabelIndices;
  final int markerIndex;
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

    final baseline = topPad + chartHeight;
    double yFor(double v) =>
        topPad + (1 - (v - _yMin) / (_yMax - _yMin)) * chartHeight;

    const barColorTop = Color(0xFFB3E4FC);
    const barColorBottom = Color(0xFF5AC8FA);
    const barColorMarker = Color(0xFF1A8BC5);
    const double barWidth = 5;
    const double barRadius = 2.5;

    for (int i = 0; i < values.length; i++) {
      final x = xPositions[i];
      final yTop = yFor(values[i]);
      // Entry animation: each bar grows from baseline based on reveal progress
      final revealProgress = (entry * values.length - i).clamp(0.0, 1.0);
      final animatedTop = baseline - (baseline - yTop) * revealProgress;
      if (revealProgress <= 0.01) continue;
      final isMarker = i == markerIndex;
      final shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isMarker
            ? [barColorBottom, barColorMarker]
            : [barColorTop, barColorBottom],
      ).createShader(Rect.fromLTRB(x - barWidth / 2, animatedTop,
          x + barWidth / 2, baseline));
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          x - barWidth / 2,
          animatedTop,
          x + barWidth / 2,
          baseline,
        ),
        const Radius.circular(barRadius),
      );
      canvas.drawRRect(
        rrect,
        Paint()..shader = shader,
      );
    }

    // Marker emphasis dot at top of selected bar
    if (tabT >= 1.0) {
      final mIdx = markerIndex.clamp(0, values.length - 1);
      final x = xPositions[mIdx];
      final yTop = yFor(values[mIdx]);
      final markerOpacity = ((entry - 0.85) / 0.15).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, yTop),
        10,
        Paint()..color = barColorMarker.withValues(alpha: 0.18 * markerOpacity),
      );
      canvas.drawCircle(
        Offset(x, yTop),
        6,
        Paint()..color = CupertinoColors.white.withValues(alpha: markerOpacity),
      );
      canvas.drawCircle(
        Offset(x, yTop),
        4.5,
        Paint()..color = barColorMarker.withValues(alpha: markerOpacity),
      );
      canvas.drawCircle(
        Offset(x, yTop),
        1.8,
        Paint()..color = CupertinoColors.white.withValues(alpha: markerOpacity),
      );
    }
  }

  void _drawDashed(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dash = 4,
    double gap = 3,
  }) {
    double x = start.dx;
    final y = start.dy;
    while (x < end.dx) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _SpBarPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.xPositions != xPositions ||
      oldDelegate.markerIndex != markerIndex ||
      oldDelegate.entry != entry ||
      oldDelegate.tabT != tabT;
}

class _AboutSpCard extends StatelessWidget {
  const _AboutSpCard({this.onTap});
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
                  'assets/images/vital_spo2.png',
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
                          'เกี่ยวกับ SpO₂',
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
                          'SpO₂ (Peripheral Oxygen Saturation) คือ เปอร์เซ็นต์ของออกซิเจนในเลือดที่จับกับฮีโมโกลบิน เป็นตัวชี้วัดประสิทธิภาพการแลกเปลี่ยนออกซิเจนของระบบหายใจ',
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

class _SpInfoSheet extends StatelessWidget {
  const _SpInfoSheet();

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
                                'เกี่ยวกับ SpO₂',
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
                          _SpHeroHeader(),
                          _SpInfoCard(
                            children: [
                              _SpSection(
                                title: 'SpO₂ คืออะไร?',
                                children: [
                                  _SpBodyText(
                                    'SpO₂ (Peripheral Oxygen Saturation) คือ เปอร์เซ็นต์ของออกซิเจนในเลือดที่จับกับฮีโมโกลบิน สะท้อนประสิทธิภาพการแลกเปลี่ยนออกซิเจนของปอดและระบบไหลเวียน',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _SpSection(
                                title: 'ค่า SpO₂ ปกติ',
                                children: [
                                  _SpBodyText('หน่วย: %'),
                                  SizedBox(height: 6),
                                  _SpSubheading('ระดับออกซิเจนในเลือด'),
                                  SizedBox(height: 4),
                                  _SpStatusRow(
                                    icon: CupertinoIcons.checkmark_circle_fill,
                                    color: Color(0xFF22C55E),
                                    text: 'ปกติ 95 – 100%',
                                  ),
                                  _SpStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFFEAB308),
                                    text: 'ต่ำเล็กน้อย 90 – 94%',
                                  ),
                                  _SpStatusRow(
                                    icon: CupertinoIcons
                                        .exclamationmark_circle_fill,
                                    color: Color(0xFFEF4444),
                                    text: 'ต่ำอันตราย < 90% ควรพบแพทย์',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _SpSection(
                                title: 'ปัจจัยที่มีผลต่อค่า SpO₂',
                                children: [
                                  _SpStatusRow(
                                    icon: Icons.air_rounded,
                                    color: Color(0xFF6D756E),
                                    text: 'โรคระบบทางเดินหายใจ',
                                  ),
                                  _SpStatusRow(
                                    icon: CupertinoIcons.heart_fill,
                                    color: Color(0xFF6D756E),
                                    text: 'โรคหัวใจ / ระบบไหลเวียน',
                                  ),
                                  _SpStatusRow(
                                    icon: Icons.landscape_rounded,
                                    color: Color(0xFF6D756E),
                                    text: 'ระดับความสูง / อากาศเบาบาง',
                                  ),
                                  _SpStatusRow(
                                    icon: CupertinoIcons.smoke_fill,
                                    color: Color(0xFF6D756E),
                                    text: 'การสูบบุหรี่',
                                  ),
                                  _SpStatusRow(
                                    icon: CupertinoIcons.bed_double_fill,
                                    color: Color(0xFF6D756E),
                                    text: 'ภาวะหยุดหายใจขณะหลับ',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _SpSection(
                                title: 'วิธีวัดให้แม่นยำ',
                                children: [
                                  _SpBodyText(
                                    '  - นั่งพักเงียบ ๆ 5 นาที\n  - ถอดยาทาเล็บออกก่อนวัด\n  - ไม่เคลื่อนไหวระหว่างวัด\n  - ใช้นิ้วที่อุ่นและสะอาด',
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _SpSection(
                                title: 'ดูแลระบบหายใจให้ดี',
                                children: [
                                  _SpStatusRow(
                                    icon: Icons.directions_run_rounded,
                                    color: Color(0xFF22C55E),
                                    text: 'ออกกำลังกายแบบแอโรบิก',
                                  ),
                                  _SpStatusRow(
                                    icon: Icons.self_improvement_rounded,
                                    color: Color(0xFF8B5CF6),
                                    text: 'ฝึกหายใจลึก ๆ / โยคะ',
                                  ),
                                  _SpStatusRow(
                                    icon: Icons.smoke_free_rounded,
                                    color: Color(0xFFE11D48),
                                    text: 'เลี่ยงบุหรี่ / มลพิษ',
                                  ),
                                  _SpStatusRow(
                                    icon: Icons.medical_services_rounded,
                                    color: Color(0xFF36BFFA),
                                    text: 'พบแพทย์หาก SpO₂ ต่ำต่อเนื่อง',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _SpInfoCard(
                            children: [_SpReferenceRow()],
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

class _SpHeroHeader extends StatelessWidget {
  const _SpHeroHeader();

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
                    Color(0x5536BFFA),
                    Color(0x2236BFFA),
                    Color(0x0036BFFA),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                'assets/images/spo2_hero_anim.gif',
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/vital_spo2.png',
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

class _SpInfoCard extends StatelessWidget {
  const _SpInfoCard({required this.children});
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

class _SpSection extends StatelessWidget {
  const _SpSection({required this.title, required this.children});
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

class _SpBodyText extends StatelessWidget {
  const _SpBodyText(this.text);
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

class _SpSubheading extends StatelessWidget {
  const _SpSubheading(this.text);
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

class _SpStatusRow extends StatelessWidget {
  const _SpStatusRow({
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

class _SpReferenceRow extends StatelessWidget {
  const _SpReferenceRow();

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
