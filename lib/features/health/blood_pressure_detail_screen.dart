import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import 'widgets/add_vital_sign_sheet.dart';

class BloodPressureDetailScreen extends StatefulWidget {
  const BloodPressureDetailScreen({super.key});

  @override
  State<BloodPressureDetailScreen> createState() =>
      _BloodPressureDetailScreenState();
}

class _BpSample {
  const _BpSample({
    required this.sys,
    required this.dia,
    required this.xLabels,
    required this.xLabelIndices,
    required this.pointLabels,
    required this.markerIndex,
  });
  final List<double> sys;
  final List<double> dia;
  final List<String> xLabels;
  final List<int> xLabelIndices;
  final List<String> pointLabels;
  final int markerIndex;
}

const _bpSamples = <_BpSample>[
  // Day — 16 readings at 1.5hr intervals. Realistic healthy adult:
  // lowest during sleep (~108/68), higher during waking (~120/78), a small
  // post-exercise bump in the evening.
  _BpSample(
    sys: [114, 112, 110, 108, 110, 114, 118, 122, 120, 118, 120, 124, 128, 122, 118, 116],
    dia: [72, 70, 68, 68, 70, 72, 74, 78, 76, 74, 76, 78, 82, 78, 74, 72],
    xLabels: ['12 AM', '6', '12 PM', '6'],
    xLabelIndices: [0, 4, 8, 12],
    pointLabels: [
      '00:00', '01:30', '03:00', '04:30', '06:00', '07:30', '09:00', '10:30',
      '12:00', '13:30', '15:00', '16:30', '18:00', '19:30', '21:00', '22:30',
    ],
    markerIndex: 12,
  ),
  // Week — daily averages; a slightly stressful Friday (higher)
  _BpSample(
    sys: [120, 118, 122, 119, 126, 121, 117],
    dia: [76, 74, 78, 75, 82, 77, 74],
    xLabels: ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'],
    xLabelIndices: [0, 1, 2, 3, 4, 5, 6],
    pointLabels: [
      'จ 5 เม.ย.', 'อ 6 เม.ย.', 'พ 7 เม.ย.', 'พฤ 8 เม.ย.',
      'ศ 9 เม.ย.', 'ส 10 เม.ย.', 'อา 11 เม.ย.',
    ],
    markerIndex: 4,
  ),
  // Month — 30 daily averages with a mid-month stress peak and recovery
  _BpSample(
    sys: [
      118, 120, 119, 122, 120, 118, 116, 118, 121, 124,
      122, 120, 118, 120, 122, 125, 128, 130, 126, 122,
      120, 117, 118, 120, 123, 126, 122, 119, 118, 120,
    ],
    dia: [
      74, 76, 74, 78, 76, 74, 72, 74, 77, 80,
      78, 76, 74, 76, 78, 80, 82, 84, 80, 78,
      76, 73, 74, 76, 78, 80, 77, 75, 74, 76,
    ],
    xLabels: ['1', '8', '15', '22', '29'],
    xLabelIndices: [0, 7, 14, 21, 28],
    pointLabels: [
      '1 เม.ย.', '2 เม.ย.', '3 เม.ย.', '4 เม.ย.', '5 เม.ย.', '6 เม.ย.',
      '7 เม.ย.', '8 เม.ย.', '9 เม.ย.', '10 เม.ย.', '11 เม.ย.', '12 เม.ย.',
      '13 เม.ย.', '14 เม.ย.', '15 เม.ย.', '16 เม.ย.', '17 เม.ย.', '18 เม.ย.',
      '19 เม.ย.', '20 เม.ย.', '21 เม.ย.', '22 เม.ย.', '23 เม.ย.', '24 เม.ย.',
      '25 เม.ย.', '26 เม.ย.', '27 เม.ย.', '28 เม.ย.', '29 เม.ย.', '30 เม.ย.',
    ],
    markerIndex: 17,
  ),
  // Year — 12 monthly averages with hot-season slight dip
  _BpSample(
    sys: [122, 121, 120, 118, 116, 117, 119, 121, 123, 124, 122, 121],
    dia: [78, 77, 76, 74, 72, 73, 75, 77, 79, 80, 78, 77],
    xLabels: ['ม.ค.', 'เม.ย.', 'ก.ค.', 'ต.ค.'],
    xLabelIndices: [0, 3, 6, 9],
    pointLabels: [
      'ม.ค. 69', 'ก.พ. 69', 'มี.ค. 69', 'เม.ย. 69', 'พ.ค. 69', 'มิ.ย. 69',
      'ก.ค. 69', 'ส.ค. 69', 'ก.ย. 69', 'ต.ค. 69', 'พ.ย. 69', 'ธ.ค. 69',
    ],
    markerIndex: 3,
  ),
];

int _currentBpMarker(int tab, int n) => (n - 1).clamp(0, n - 1);

class _BloodPressureDetailScreenState
    extends State<BloodPressureDetailScreen> {
  int _tabIndex = 0;
  final List<int?> _selected = List<int?>.filled(_bpSamples.length, null);

  void _showBpInfoSheet(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => const _BpInfoSheet(),
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
                  onAdd: () async {
                    final result = await showAddVitalSignSheet(
                      context,
                      title: 'เพิ่มความดันโลหิต',
                      icon: CupertinoIcons.heart_fill,
                      color: const Color(0xFFBE123C),
                      fields: const [
                        VitalFieldConfig(
                          label: 'ค่าบน (Systolic)',
                          placeholder: '120',
                          unit: 'mmHg',
                        ),
                        VitalFieldConfig(
                          label: 'ค่าล่าง (Diastolic)',
                          placeholder: '80',
                          unit: 'mmHg',
                        ),
                      ],
                    );
                    if (result != null && context.mounted) {
                      AppToast.success(context, 'บันทึกค่าความดันแล้ว');
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
                        _ChartCard(
                          tabIndex: _tabIndex,
                          onTabChange: (i) => setState(() => _tabIndex = i),
                          selectedIndex: _selected[_tabIndex],
                          onSelect: (idx) =>
                              setState(() => _selected[_tabIndex] = idx),
                        ),
                        const SizedBox(height: 16),
                        _AboutCard(
                          onTap: () => _showBpInfoSheet(context),
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.2, -0.6),
          radius: 1.2,
          colors: [
            Color(0xFFF6A5B9),
            Color(0xFFE37A94),
            Color(0xFFC9566F),
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
            'ความดันโลหิต',
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


class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.tabIndex,
    required this.onTabChange,
    required this.selectedIndex,
    required this.onSelect,
  });
  final int tabIndex;
  final ValueChanged<int> onTabChange;
  final int? selectedIndex;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    final sample = _bpSamples[tabIndex];
    final activeIdx =
        (selectedIndex ?? _currentBpMarker(tabIndex, sample.sys.length))
            .clamp(0, sample.sys.length - 1);
    final sysV = sample.sys[activeIdx].round();
    final diaV = sample.dia[activeIdx].round();
    final valueLabel = '$sysV/$diaV';
    final dateLabel = sample.pointLabels[activeIdx];
    final isSelected = selectedIndex != null;
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _SegmentedTabs(
              tabs: const ['วัน', 'สัปดาห์', 'เดือน', 'ปี'],
              selected: tabIndex,
              onChange: onTabChange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey('$tabIndex-$activeIdx'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSelected
                              ? 'ค่าที่เลือก'
                              : (tabIndex == 0 ? 'Value' : 'ค่าเฉลี่ย'),
                          style: AppTypography.caption1(
                            const Color(0xFF6D756E),
                          ).copyWith(
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
                              valueLabel,
                              style: AppTypography.title2(
                                CupertinoColors.black,
                              ).copyWith(
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
                                'mmHg',
                                style: AppTypography.caption2(
                                  const Color(0xFF737373),
                                ).copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dateLabel,
                          style: AppTypography.caption2(
                            const Color(0xFF737373),
                          ).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                const _StatusBadge(label: 'ปกติ'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
            child: SizedBox(
              height: 224,
              child: _BpLineChart(
                sample: sample,
                selectedIndex: activeIdx,
                onSelect: onSelect,
              ),
            ),
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
                          color: CupertinoColors.black
                              .withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: CupertinoColors.black
                              .withValues(alpha: 0.04),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
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

class _BpLineChart extends StatefulWidget {
  const _BpLineChart({
    required this.sample,
    required this.selectedIndex,
    required this.onSelect,
  });
  final _BpSample sample;
  final int selectedIndex;
  final ValueChanged<int?> onSelect;

  @override
  State<_BpLineChart> createState() => _BpLineChartState();
}

class _BpLineChartState extends State<_BpLineChart>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _entryCtrl;
  late _BpSample _from;
  late _BpSample _to;

  @override
  void initState() {
    super.initState();
    _from = widget.sample;
    _to = widget.sample;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..value = 1;
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void didUpdateWidget(covariant _BpLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sample != widget.sample) {
      _from = oldWidget.sample;
      _to = widget.sample;
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  static const double _leftPad = 16.0;
  static const double _rightPad = 16.0;
  static const double _axisWidth = 48.0;

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
    final n = widget.sample.sys.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleWidth = constraints.maxWidth - _axisWidth;
        final contentWidth = visibleWidth;
        final chartWidth = contentWidth - _leftPad - _rightPad;
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
                scrollDirection: Axis.horizontal,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: contentWidth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => widget.onSelect(
                        _nearestIndexByX(d.localPosition.dx, xPositions)),
                    onPanStart: (d) => widget.onSelect(
                        _nearestIndexByX(d.localPosition.dx, xPositions)),
                    onPanUpdate: (d) => widget.onSelect(
                        _nearestIndexByX(d.localPosition.dx, xPositions)),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_ctrl, _entryCtrl]),
                      builder: (_, __) {
                        final t = Curves.fastEaseInToSlowEaseOut
                            .transform(_ctrl.value);
                        final entry = Curves.easeOutCubic
                            .transform(_entryCtrl.value);
                        return CustomPaint(
                          painter: _BpChartPainter(
                            from: _from,
                            to: _to,
                            t: t,
                            entry: entry,
                            overrideMarker: widget.selectedIndex,
                            xPositions: xPositions,
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
                painter: _BpAxisLabelsPainter(),
                size: Size.infinite,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BpAxisLabelsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const topPad = 8.0;
    const bottomPad = 22.0;
    final chartHeight = size.height - topPad - bottomPad;
    final yLabels = [200, 150, 100, 50, 0];
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
  bool shouldRepaint(covariant _BpAxisLabelsPainter oldDelegate) => false;
}

class _BpChartPainter extends CustomPainter {
  _BpChartPainter({
    required this.from,
    required this.to,
    required this.t,
    required this.entry,
    required this.xPositions,
    this.overrideMarker,
  });
  final int? overrideMarker;
  final double entry;
  final _BpSample from;
  final _BpSample to;
  final double t;
  final List<double> xPositions;
  _BpSample get sample => to;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 16.0;
    const rightPad = 16.0;
    const topPad = 8.0;
    const bottomPad = 22.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 0.5;

    final yLabels = [200, 150, 100, 50, 0];
    for (int i = 0; i < yLabels.length; i++) {
      final t = i / (yLabels.length - 1);
      final y = topPad + t * chartHeight;
      final isZero = yLabels[i] == 0;
      if (isZero) {
        final p = Paint()
          ..color = const Color(0xFFB3B3B3)
          ..strokeWidth = 0.5;
        canvas.drawLine(Offset(leftPad, y), Offset(leftPad + chartWidth, y), p);
      } else {
        _drawDashedLine(
          canvas,
          Offset(leftPad, y),
          Offset(leftPad + chartWidth, y),
          gridPaint,
          dashWidth: 3,
          gapWidth: 3,
        );
      }
    }

    final sysColor = const Color(0xFFF06C8C);
    final diaColor = const Color(0xFF4A6CF7);

    double yFor(double v) {
      final clamped = v.clamp(0.0, 200.0);
      return topPad + (1 - clamped / 200) * chartHeight;
    }

    const resampleN = 60;
    final sysFrom = _resample(from.sys, resampleN);
    final sysTo = _resample(to.sys, resampleN);
    final diaFrom = _resample(from.dia, resampleN);
    final diaTo = _resample(to.dia, resampleN);

    final sysMorphed = <double>[
      for (int i = 0; i < resampleN; i++)
        sysFrom[i] + (sysTo[i] - sysFrom[i]) * t,
    ];
    final diaMorphed = <double>[
      for (int i = 0; i < resampleN; i++)
        diaFrom[i] + (diaTo[i] - diaFrom[i]) * t,
    ];

    double xForN(int i, int n) {
      return leftPad + (i / (n - 1)) * chartWidth;
    }

    final dashPaint = Paint()
      ..color = sysColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    final toMarkerIdx = overrideMarker ?? to.markerIndex;
    final fromMarkerFrac =
        from.markerIndex / (from.sys.length - 1).clamp(1, 1 << 31);
    final toMarkerFrac =
        toMarkerIdx / (to.sys.length - 1).clamp(1, 1 << 31);
    final markerFrac = overrideMarker != null
        ? toMarkerFrac
        : fromMarkerFrac + (toMarkerFrac - fromMarkerFrac) * t;
    final markerX = leftPad + markerFrac * chartWidth;
    _drawDashedLine(
      canvas,
      Offset(markerX, topPad),
      Offset(markerX, topPad + chartHeight),
      dashPaint,
      dashWidth: 4,
      gapWidth: 3,
    );

    // Clip to a left-to-right reveal width based on entry progress.
    canvas.save();
    final revealWidth = chartWidth * entry.clamp(0.0, 1.0);
    canvas.clipRect(
      Rect.fromLTWH(leftPad, 0, revealWidth, size.height),
    );
    _drawSmoothLine(
      canvas,
      sysMorphed,
      (i) => xForN(i, resampleN),
      yFor,
      sysColor,
    );
    _drawSmoothLine(
      canvas,
      diaMorphed,
      (i) => xForN(i, resampleN),
      yFor,
      diaColor,
    );
    canvas.restore();

    if (markerX - leftPad <= revealWidth + 0.5) {
      final sysMarkerY = _sampleAt(sysMorphed, markerFrac);
      final diaMarkerY = _sampleAt(diaMorphed, markerFrac);
      final markerOpacity = ((entry - 0.85) / 0.15).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(markerX, yFor(sysMarkerY)),
        4,
        Paint()..color = sysColor.withValues(alpha: markerOpacity),
      );
      canvas.drawCircle(
        Offset(markerX, yFor(diaMarkerY)),
        4,
        Paint()..color = diaColor.withValues(alpha: markerOpacity),
      );
    }

    // X labels: cross-fade between from and to. Position each label at its
    // point's x (using xLabelIndices).
    void drawXLabels(
      _BpSample s,
      double opacity, {
      List<double>? positions,
    }) {
      if (opacity <= 0.001) return;
      final xLabels = s.xLabels;
      final labelIdxs = s.xLabelIndices;
      final style = TextStyle(
        color: const Color(0xFF6D756E).withValues(alpha: opacity),
        fontSize: 10,
        letterSpacing: 0.6,
      );
      final pointCount = s.sys.length;
      for (int i = 0; i < xLabels.length; i++) {
        final pointIdx = labelIdxs[i].clamp(0, pointCount - 1);
        final x = positions != null && pointIdx < positions.length
            ? positions[pointIdx]
            : (pointCount == 1
                ? leftPad + chartWidth / 2
                : leftPad + (pointIdx / (pointCount - 1)) * chartWidth);
        final tp = TextPainter(
          text: TextSpan(text: xLabels[i], style: style),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();
        tp.paint(
          canvas,
          Offset(x - tp.width / 2, topPad + chartHeight + 6),
        );
      }
    }

    if (from != to) drawXLabels(from, 1 - t);
    drawXLabels(to, t, positions: xPositions);
  }

  static List<double> _resample(List<double> values, int n) {
    if (values.isEmpty) return List.filled(n, 0);
    if (values.length == 1) return List.filled(n, values.first);
    final out = List<double>.filled(n, 0);
    for (int i = 0; i < n; i++) {
      final pos = i * (values.length - 1) / (n - 1);
      final lo = pos.floor();
      final hi = (lo + 1).clamp(0, values.length - 1);
      final frac = pos - lo;
      out[i] = values[lo] + (values[hi] - values[lo]) * frac;
    }
    return out;
  }

  static double _sampleAt(List<double> values, double frac) {
    if (values.isEmpty) return 0;
    final pos = frac.clamp(0.0, 1.0) * (values.length - 1);
    final lo = pos.floor();
    final hi = (lo + 1).clamp(0, values.length - 1);
    final f = pos - lo;
    return values[lo] + (values[hi] - values[lo]) * f;
  }

  void _drawSmoothLine(
    Canvas canvas,
    List<double> values,
    double Function(int) xFor,
    double Function(double) yFor,
    Color color,
  ) {
    if (values.length < 2) return;
    final path = Path();
    final points = [
      for (int i = 0; i < values.length; i++)
        Offset(xFor(i), yFor(values[i])),
    ];
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
    // Soft glow under the line
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashWidth = 4,
    double gapWidth = 3,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final dashCount = (distance / (dashWidth + gapWidth)).floor();
    final unitX = dx / distance;
    final unitY = dy / distance;
    for (int i = 0; i < dashCount; i++) {
      final sx = start.dx + (dashWidth + gapWidth) * i * unitX;
      final sy = start.dy + (dashWidth + gapWidth) * i * unitY;
      final ex = sx + dashWidth * unitX;
      final ey = sy + dashWidth * unitY;
      canvas.drawLine(Offset(sx, sy), Offset(ex, ey), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BpChartPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.t != t ||
      oldDelegate.entry != entry ||
      oldDelegate.overrideMarker != overrideMarker ||
      oldDelegate.xPositions != xPositions;
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({this.onTap});
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
                'assets/images/vital_heart.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFFFE4E4),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.heart_fill,
                    color: Color(0xFFB7185E),
                    size: 58,
                  ),
                ),
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
                        'เกี่ยวกับความดันโลหิต',
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
                        'ความดันโลหิต (Blood Pressure) คือแรงดันที่เลือดกดดันผนังหลอดเลือดขณะไหลเวียนไปทั่วร่างกาย การวัดความดันโลหิตจะบอกถึงการทำงานของหัวใจและความต้านทานของหลอดเลือดทั้งในช่วงที่หัวใจบีบตัว (ซิสโตลิก) และในช่วงที่หัวใจพัก (ไดแอสโตลิก) โดยตัวเลขที่ได้จะเป็นการวัดในหน่วยมิลลิเมตรปรอท (mmHg)',
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
  bool _on = false;

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
                color: _on
                    ? const Color(0xFFFEF9C3)
                    : const Color(0xFFE5E5E5),
              ),
              alignment: Alignment.center,
              child: Icon(
                _on ? Icons.star_rounded : Icons.star_outline_rounded,
                color: _on
                    ? const Color(0xFFCA8A04)
                    : const Color(0xFF9CA3AF),
                size: 12,
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
          _settingsRow('แสดงข้อมูลทั้งหมด'),
          const SizedBox(height: 16),
          Container(height: 0.5, color: const Color(0xFFE5E5E5)),
          const SizedBox(height: 16),
          _settingsRow('การเชื่อมต่ออุปกรณ์'),
        ],
      ),
    );
  }

  Widget _settingsRow(String label) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
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
    );
  }
}

class _BpInfoSheet extends StatelessWidget {
  const _BpInfoSheet();

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
                        color:
                            const Color(0xFF1A1A1A).withValues(alpha: 0.18),
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
                              'เกี่ยวกับความดันโลหิต',
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
                        _BpHeroHeader(),
                        _BpInfoCard(
                          children: [
                            _BpInfoSection(
                              title: 'ความดันโลหิตคืออะไร?',
                              children: [
                                _BpBodyText(
                                  'ความดันโลหิต คือ แรงดันของเลือดในหลอดเลือด\nเกิดจากการที่หัวใจสูบฉีดเลือดไปเลี้ยงร่างกาย',
                                ),
                                _BpBodyText('โดยค่าความดันจะมี 2 ตัวเลข:'),
                                _BpBodyText(
                                  '  - ตัวบน (Systolic) – ขณะหัวใจบีบตัว\n  - ตัวล่าง (Diastolic) – ขณะหัวใจคลายตัว',
                                ),
                                _BpBodyText('ตัวอย่าง: 120/80 mmHg'),
                              ],
                            ),
                            SizedBox(height: 16),
                            _BpInfoSection(
                              title: 'ระดับความดันโลหิต',
                              children: [
                                _BpStatusRow(
                                  icon: CupertinoIcons.checkmark_circle_fill,
                                  color: Color(0xFF22C55E),
                                  text: 'ปกติ < 120 / 80 สุขภาพดี',
                                ),
                                _BpStatusRow(
                                  icon:
                                      CupertinoIcons.exclamationmark_circle_fill,
                                  color: Color(0xFFEAB308),
                                  text:
                                      'เริ่มสูง 120–139 / 80–89 ควรเฝ้าระวัง',
                                ),
                                _BpStatusRow(
                                  icon:
                                      CupertinoIcons.exclamationmark_circle_fill,
                                  color: Color(0xFFF97316),
                                  text:
                                      'สูง (ระยะ 1) 140–159 / 90–99 เริ่มมีความเสี่ยง',
                                ),
                                _BpStatusRow(
                                  icon:
                                      CupertinoIcons.exclamationmark_circle_fill,
                                  color: Color(0xFFEF4444),
                                  text: 'สูง (ระยะ 2+) ≥ 160 / 100 ควรพบแพทย์',
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _BpInfoSection(
                              title: 'ทำไมต้องระวังความดัน?',
                              children: [
                                _BpBodyText('ความดันโลหิตสูง อาจเพิ่มความเสี่ยง:'),
                                _BpBodyText(
                                  '  - โรคหัวใจ\n  - โรคหลอดเลือดสมอง\n  - โรคไต',
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _BpInfoSection(
                              title: 'ความดัน “เปลี่ยนได้” ตลอดวัน',
                              children: [
                                _BpBodyText('ค่าความดันไม่ได้คงที่ ขึ้นอยู่กับ:'),
                                _BpStatusRow(
                                  icon: Icons.psychology_alt_rounded,
                                  color: Color(0xFF8B5CF6),
                                  text: 'ความเครียด',
                                ),
                                _BpStatusRow(
                                  icon: Icons.directions_walk_rounded,
                                  color: Color(0xFF0EA5E9),
                                  text: 'การเคลื่อนไหว',
                                ),
                                _BpStatusRow(
                                  icon: CupertinoIcons.clock_fill,
                                  color: Color(0xFF6D756E),
                                  text: 'ช่วงเวลา',
                                ),
                                _BpStatusRow(
                                  icon: Icons.lunch_dining_rounded,
                                  color: Color(0xFFE11D48),
                                  text: 'การกินเค็ม',
                                ),
                                _BpBodyText(
                                  'ดังนั้นควรดู “แนวโน้ม” มากกว่าค่าครั้งเดียว',
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _BpInfoSection(
                              title: 'วิธีวัดให้แม่นยำ',
                              children: [
                                _BpBodyText(
                                  '  - นั่งพักก่อนวัด 5 นาที\n  - ไม่พูด / ไม่ขยับระหว่างวัด\n  - วัดซ้ำ 2–3 ครั้ง',
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _BpInfoSection(
                              title: 'ดูแลตัวเองง่ายๆ',
                              children: [
                                _BpStatusRow(
                                  icon: Icons.lunch_dining_rounded,
                                  color: Color(0xFFE11D48),
                                  text: 'ลดเค็ม ลดมัน',
                                ),
                                _BpStatusRow(
                                  icon: Icons.directions_run_rounded,
                                  color: Color(0xFFF97316),
                                  text: 'ออกกำลังกายสม่ำเสมอ',
                                ),
                                _BpStatusRow(
                                  icon: Icons.bedtime_rounded,
                                  color: Color(0xFF6366F1),
                                  text: 'พักผ่อนให้เพียงพอ',
                                ),
                                _BpStatusRow(
                                  icon: Icons.wine_bar_rounded,
                                  color: Color(0xFF8B5CF6),
                                  text: 'หลีกเลี่ยงบุหรี่และแอลกอฮอล์',
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _BpInfoCard(
                          children: [
                            _BpReferenceRow(),
                          ],
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

class _BpHeroHeader extends StatelessWidget {
  const _BpHeroHeader();

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
                    Color(0x55F06C8C),
                    Color(0x22F06C8C),
                    Color(0x00F06C8C),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                'assets/images/bp_heart_anim.gif',
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BpInfoCard extends StatelessWidget {
  const _BpInfoCard({required this.children});
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

class _BpInfoSection extends StatelessWidget {
  const _BpInfoSection({required this.title, required this.children});
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

class _BpBodyText extends StatelessWidget {
  const _BpBodyText(this.text);
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

class _BpStatusRow extends StatelessWidget {
  const _BpStatusRow({
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

class _BpReferenceRow extends StatelessWidget {
  const _BpReferenceRow();

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
