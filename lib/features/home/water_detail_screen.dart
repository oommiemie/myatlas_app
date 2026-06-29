import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Icons,
        showModalBottomSheet,
        ChoiceChip,
        MaterialTapTargetSize,
        VisualDensity;

enum _Period { day, week, month, year }

/// Water-intake detail screen — same layout as the nutrition detail screen
/// (gradient header with glass buttons over a rounded content sheet) but with
/// water data: a weekly chart, today's summary, and an intake log.
class WaterDetailScreen extends StatefulWidget {
  const WaterDetailScreen({
    super.key,
    required this.goalMl,
    required this.mlPerGlass,
    required this.consumedMl,
    this.onSettingsChanged,
  });

  final int goalMl;
  final int mlPerGlass;
  final int consumedMl;

  /// Called when the user changes the goal / glass size from this screen so the
  /// home card stays in sync.
  final void Function(int goalMl, int mlPerGlass)? onSettingsChanged;

  static const _bgPrimary = Color(0xFFF4F8F5);
  static const _ink = Color(0xFF1A1A2E);
  // Blue water header.
  static const _headerTop = Color(0xFF4FC3F7);
  static const _headerBottom = Color(0xFF0277BD);
  static const _water = Color(0xFF1E88E5);

  static const _thMonth = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];
  static const _thShort = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];

  static const _glassOptions = [150, 200, 250, 300, 350];

  static Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Thai Looped',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      );

  static String formatMl(num v) {
    final s = v.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  State<WaterDetailScreen> createState() => _WaterDetailScreenState();
}

class _WaterDetailScreenState extends State<WaterDetailScreen> {
  late int _goalMl = widget.goalMl;
  late int _mlPerGlass = widget.mlPerGlass;

  void _openSettings() {
    showWaterSettingsSheet(
      context: context,
      goalMl: _goalMl,
      mlPerGlass: _mlPerGlass,
      onSaved: (goal, perGlass) {
        setState(() {
          _goalMl = goal;
          _mlPerGlass = perGlass;
        });
        widget.onSettingsChanged?.call(goal, perGlass);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final glasses = (widget.consumedMl / _mlPerGlass).round();

    return CupertinoPageScaffold(
      backgroundColor: WaterDetailScreen._bgPrimary,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    WaterDetailScreen._headerTop,
                    WaterDetailScreen._headerBottom,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                  title: 'การดื่มน้ำ',
                  onBack: () => Navigator.of(context).maybePop(),
                  action: _GlassCircle(
                    icon: CupertinoIcons.slider_horizontal_3,
                    onTap: _openSettings,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Container(
                      color: WaterDetailScreen._bgPrimary,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        children: [
                          _WaterChartCard(
                            goalMl: _goalMl,
                            consumedMl: widget.consumedMl,
                            thShort: WaterDetailScreen._thShort,
                            thMonth: WaterDetailScreen._thMonth,
                          ),
                          const SizedBox(height: 16),
                          _TodayCard(
                            consumedMl: widget.consumedMl,
                            goalMl: _goalMl,
                            glasses: glasses,
                          ),
                          const SizedBox(height: 16),
                          WaterDetailScreen._sectionTitle('บันทึกการดื่มวันนี้'),
                          const SizedBox(height: 8),
                          _IntakeLog(glasses: glasses, mlPerGlass: _mlPerGlass),
                          const SizedBox(height: 16),
                          _GoalCard(goalMl: _goalMl, mlPerGlass: _mlPerGlass),
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
  const _Header({required this.title, required this.onBack, this.action});
  final String title;
  final VoidCallback onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Row(
        children: [
          _GlassCircle(icon: CupertinoIcons.chevron_back, onTap: onBack),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Thai Looped',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.white,
              ),
            ),
          ),
          if (action != null) ...[const SizedBox(width: 10), action!],
        ],
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.icon, required this.onTap});
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
              ),
              child: Icon(icon, size: 20, color: CupertinoColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Computed series for a given period.
class _Series {
  const _Series({
    required this.values,
    required this.labels,
    required this.showGoal,
    required this.range,
    required this.headerTitle,
  });
  final List<double> values;
  final List<String> labels; // '' = no tick label under that bar
  final bool showGoal;
  final String range;
  final String headerTitle;
}

/// Water bar-chart card with วัน/สัปดาห์/เดือน/ปี tabs (like the nutrition card).
class _WaterChartCard extends StatefulWidget {
  const _WaterChartCard({
    required this.goalMl,
    required this.consumedMl,
    required this.thShort,
    required this.thMonth,
  });

  final int goalMl;
  final int consumedMl;
  final List<String> thShort;
  final List<String> thMonth;

  @override
  State<_WaterChartCard> createState() => _WaterChartCardState();
}

class _WaterChartCardState extends State<_WaterChartCard>
    with SingleTickerProviderStateMixin {
  static const _water = Color(0xFF1E88E5);
  static const _ink = Color(0xFF1A1A2E);
  static const _muted = Color(0xFF8A97A3);

  _Period _period = _Period.week;
  int? _touched;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setPeriod(_Period p) {
    if (p == _period) return;
    setState(() {
      _period = p;
      _touched = null;
    });
    _ctrl.forward(from: 0);
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  _Series _series() {
    final g = widget.goalMl.toDouble();
    switch (_period) {
      case _Period.day:
        // 24 hourly buckets summing to today's consumption.
        const weights = [
          0, 0, 0, 0, 0, 0, 2, 4, 5, 3, 4, 5,
          6, 4, 3, 4, 5, 3, 4, 3, 2, 1, 0, 0,
        ];
        final total = weights.fold<int>(0, (a, b) => a + b);
        final values = [
          for (final w in weights) widget.consumedMl * w / total,
        ];
        final labels = [
          for (var h = 0; h < 24; h++)
            h % 6 == 0 ? h.toString().padLeft(2, '0') : '',
        ];
        final t = _today;
        final by = (t.year + 543) % 100;
        return _Series(
          values: values,
          labels: labels,
          showGoal: false,
          range: '${t.day} ${widget.thMonth[t.month - 1]} $by',
          headerTitle: 'ปริมาณน้ำรายวัน',
        );
      case _Period.week:
        final dates = [
          for (var i = 6; i >= 0; i--) _today.subtract(Duration(days: i)),
        ];
        final values = [
          g * 0.72, g * 1.05, g * 0.84, g * 0.95, g * 0.62, g * 1.10,
          widget.consumedMl.toDouble(),
        ];
        final f = dates.first;
        final l = dates.last;
        final by = (l.year + 543) % 100;
        return _Series(
          values: values,
          labels: [for (final d in dates) widget.thShort[d.weekday % 7]],
          showGoal: true,
          range:
              '${f.day} ${widget.thMonth[f.month - 1]} - ${l.day} ${widget.thMonth[l.month - 1]} $by',
          headerTitle: 'ปริมาณน้ำรายสัปดาห์',
        );
      case _Period.month:
        final t = _today;
        final days = DateTime(t.year, t.month + 1, 0).day;
        // Mock daily intake across the month (last = today's actual).
        final values = [
          for (var i = 0; i < days; i++)
            i == t.day - 1
                ? widget.consumedMl.toDouble()
                : g * (0.6 + ((i * 37) % 60) / 100),
        ];
        final labels = [
          for (var i = 0; i < days; i++)
            (i % 5 == 0 || i == days - 1) ? '${i + 1}' : '',
        ];
        final by = (t.year + 543) % 100;
        return _Series(
          values: values,
          labels: labels,
          showGoal: true,
          range: '${widget.thMonth[t.month - 1]} $by',
          headerTitle: 'ปริมาณน้ำรายเดือน',
        );
      case _Period.year:
        final t = _today;
        // Mock monthly-average daily intake.
        final values = [
          for (var m = 0; m < 12; m++) g * (0.7 + ((m * 53) % 50) / 100),
        ];
        return _Series(
          values: values,
          labels: [for (var m = 0; m < 12; m++) widget.thMonth[m]],
          showGoal: true,
          range: 'ปี ${t.year + 543}',
          headerTitle: 'ปริมาณน้ำรายปี',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _series();
    final touched = _touched != null && _touched! < s.values.length;
    final int headerValue;
    final String headerLabel;
    final String headerUnit;
    if (touched) {
      headerValue = s.values[_touched!].round();
      headerLabel = s.labels[_touched!].isNotEmpty
          ? s.labels[_touched!]
          : 'ที่เลือก';
      headerUnit = 'มล.';
    } else if (_period == _Period.day) {
      headerValue = widget.consumedMl;
      headerLabel = 'รวมวันนี้';
      headerUnit = 'มล.';
    } else {
      headerValue =
          (s.values.reduce((a, b) => a + b) / s.values.length).round();
      headerLabel = 'เฉลี่ย';
      headerUnit = 'มล./วัน';
    }

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PeriodTabs(value: _period, onChanged: _setPeriod),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.headerTitle,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      headerLabel,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontSize: 12,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          WaterDetailScreen.formatMl(headerValue),
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            color: _ink,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3, left: 4),
                          child: Text(
                            headerUnit,
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Thai Looped',
                              fontSize: 11,
                              color: _muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.range,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontSize: 11,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (s.showGoal)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'เป้าหมาย',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontSize: 11,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${WaterDetailScreen.formatMl(widget.goalMl)} มล./วัน',
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _water,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final p = const Cubic(0.22, 1, 0.36, 1).transform(_ctrl.value);
                return LayoutBuilder(
                  builder: (context, c) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) {
                        final slot = c.maxWidth / s.values.length;
                        final i = (d.localPosition.dx / slot)
                            .floor()
                            .clamp(0, s.values.length - 1);
                        setState(() => _touched = i == _touched ? null : i);
                      },
                      child: CustomPaint(
                        size: Size(c.maxWidth, 170),
                        painter: _BarsPainter(
                          values: s.values,
                          goal: s.showGoal ? widget.goalMl.toDouble() : null,
                          labels: s.labels,
                          touched: _touched,
                          progress: p,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmented วัน/สัปดาห์/เดือน/ปี selector (water-blue accent).
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
                    for (int i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(_Period.values[i]),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Thai Looped',
                                fontSize: 15,
                                color: i == selected
                                    ? const Color(0xFF1E88E5)
                                    : const Color(0xFF1A1A1A),
                                fontWeight: i == selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
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

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.goal,
    required this.labels,
    required this.touched,
    required this.progress,
  });

  final List<double> values;
  final double? goal; // null → no goal reference line
  final List<String> labels;
  final int? touched;
  final double progress;

  static const _water = Color(0xFF1E88E5);
  static const _dim = Color(0xFFBBDEFB);

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 22.0;
    final chartH = size.height - labelH;
    final maxV = [
      ...values,
      if (goal != null) goal!,
    ].reduce((a, b) => a > b ? a : b) * 1.12;
    final slot = size.width / values.length;
    // Bars shrink to fit when there are many (day = 24, month = ~30).
    final barW = (slot * 0.55).clamp(3.0, 14.0);
    final radius = Radius.circular((barW / 2).clamp(2.0, 7.0));

    // Goal reference line (dashed) — only when a goal applies.
    if (goal != null) {
      final goalY = chartH * (1 - goal! / maxV);
      final dash = Paint()
        ..color = _water.withValues(alpha: 0.35)
        ..strokeWidth = 1.5;
      for (double x = 0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, goalY), Offset(x + 4, goalY), dash);
      }
    }

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < values.length; i++) {
      final cx = slot * i + slot / 2;
      final h = chartH * (values[i] / maxV) * progress;
      final isSel = touched == i;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barW / 2, chartH - h, barW, h),
        radius,
      );
      canvas.drawRRect(
        rect,
        Paint()..color = (touched == null || isSel) ? _water : _dim,
      );

      if (labels[i].isEmpty) continue;
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Thai Looped',
          fontSize: 11,
          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
          color: isSel ? _water : const Color(0xFF8A97A3),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, size.height - labelH + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.progress != progress || old.touched != touched;
}

/// Today summary: consumed amount + glasses, frosted inner panel.
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.consumedMl,
    required this.goalMl,
    required this.glasses,
  });

  final int consumedMl;
  final int goalMl;
  final int glasses;

  static const _ink = Color(0xFF1A1A2E);
  static const _water = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    final pct = ((consumedMl / goalMl) * 100).clamp(0, 999).round();
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สรุปวันนี้',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Thai Looped',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _Stat(
                      iconBg: _water,
                      icon: Icons.water_drop,
                      label: 'ดื่มวันนี้',
                      value: WaterDetailScreen.formatMl(consumedMl),
                      unit: 'มล.',
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: CupertinoColors.black.withValues(alpha: 0.06),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _Stat(
                      iconBg: const Color(0xFF4FC3F7),
                      icon: Icons.local_drink,
                      label: 'จำนวนแก้ว',
                      value: '$glasses',
                      unit: 'แก้ว',
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: CupertinoColors.black.withValues(alpha: 0.06),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _Stat(
                      iconBg: const Color(0xFF0277BD),
                      icon: Icons.flag,
                      label: 'ของเป้าหมาย',
                      value: '$pct',
                      unit: '%',
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

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 10, color: CupertinoColors.white),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Thai Looped',
                  fontSize: 11,
                  color: Color(0xFF6D756E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Thai Looped',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Thai Looped',
                  fontSize: 10,
                  color: Color(0xFF8A97A3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Today's drink events (mock times spread through the day).
class _IntakeLog extends StatelessWidget {
  const _IntakeLog({required this.glasses, required this.mlPerGlass});
  final int glasses;
  final int mlPerGlass;

  @override
  Widget build(BuildContext context) {
    if (glasses <= 0) {
      return Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text(
          'ยังไม่มีการบันทึกวันนี้',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Thai Looped',
            fontSize: 13,
            color: Color(0xFF8A97A3),
          ),
        ),
      );
    }
    // Spread events from 08:00 across ~13 hours.
    return Column(
      children: [
        for (var i = 0; i < glasses; i++) ...[
          _logItem(8 * 60 + (i * 780 ~/ glasses)),
          if (i < glasses - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _logItem(int minutes) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final time =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} น.';
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FC3F7), Color(0xFF1E88E5)],
              ),
            ),
            child: const Icon(Icons.local_drink, color: CupertinoColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'ดื่มน้ำ',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Thai Looped',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai Looped',
              fontSize: 12,
              color: Color(0xFF8A97A3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '+$mlPerGlass มล.',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai Looped',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E88E5),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goalMl, required this.mlPerGlass});
  final int goalMl;
  final int mlPerGlass;

  @override
  Widget build(BuildContext context) {
    final l = goalMl / 1000;
    final litres =
        l == l.roundToDouble() ? l.toStringAsFixed(0) : l.toStringAsFixed(1);
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _goalItem('เป้าหมายต่อวัน', '$litres ลิตร'),
            ),
          ),
          Container(
            width: 1,
            height: 34,
            color: CupertinoColors.black.withValues(alpha: 0.06),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _goalItem('ปริมาณต่อแก้ว', '$mlPerGlass มล.'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Thai Looped',
            fontSize: 12,
            color: Color(0xFF6D756E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Thai Looped',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E88E5),
          ),
        ),
      ],
    );
  }
}

/// Shared "ตั้งค่าการดื่มน้ำ" bottom sheet — daily goal stepper + glass-size
/// chips. Used by both the water detail screen and the home water card so the
/// settings UI stays in one place.
Future<void> showWaterSettingsSheet({
  required BuildContext context,
  required int goalMl,
  required int mlPerGlass,
  required void Function(int goalMl, int mlPerGlass) onSaved,
}) {
  var goal = goalMl;
  var perGlass = mlPerGlass;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: CupertinoColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (sheetCtx, setSheet) {
          String goalLabel() {
            final l = goal / 1000;
            return '${l == l.roundToDouble() ? l.toStringAsFixed(0) : l.toStringAsFixed(1)} ลิตร';
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              20 + MediaQuery.viewInsetsOf(sheetCtx).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ตั้งค่าการดื่มน้ำ',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: WaterDetailScreen._ink,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'เป้าหมายต่อวัน',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B6B7A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _waterStepperButton(
                      icon: Icons.remove,
                      onTap: goal > 500
                          ? () => setSheet(() => goal -= 250)
                          : null,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          goalLabel(),
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: WaterDetailScreen._water,
                          ),
                        ),
                      ),
                    ),
                    _waterStepperButton(
                      icon: Icons.add,
                      onTap: goal < 5000
                          ? () => setSheet(() => goal += 250)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'ปริมาณต่อแก้ว',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B6B7A),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final ml in WaterDetailScreen._glassOptions)
                      ChoiceChip(
                        label: Text('$ml มล.'),
                        selected: perGlass == ml,
                        onSelected: (_) => setSheet(() => perGlass = ml),
                        labelStyle: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai Looped',
                          fontWeight: FontWeight.w600,
                          color: perGlass == ml
                              ? CupertinoColors.white
                              : WaterDetailScreen._ink,
                        ),
                        // Balanced vertical padding (Thai looped font sits a
                        // touch high by default).
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        selectedColor: WaterDetailScreen._water,
                        backgroundColor: const Color(0xFFEFF6FA),
                        showCheckmark: false,
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      onSaved(goal, perGlass);
                      Navigator.of(sheetCtx).pop();
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FC3F7), WaterDetailScreen._water],
                        ),
                      ),
                      child: const Text(
                        'บันทึก',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai Looped',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _waterStepperButton({required IconData icon, VoidCallback? onTap}) {
  final enabled = onTap != null;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enabled ? const Color(0xFFEFF6FA) : const Color(0xFFF4F4F4),
      ),
      child: Icon(
        icon,
        size: 20,
        color: enabled ? WaterDetailScreen._water : const Color(0xFFC4C4C4),
      ),
    ),
  );
}
