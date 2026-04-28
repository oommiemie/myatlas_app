import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';

import '../../../core/widgets/liquid_glass_button.dart';
import '../../../core/widgets/press_effect.dart';
import 'treatment_data.dart';

class TreatmentDetailScreen extends StatefulWidget {
  const TreatmentDetailScreen({super.key, required this.treatment});
  final Treatment treatment;

  @override
  State<TreatmentDetailScreen> createState() => _TreatmentDetailScreenState();
}

class _TreatmentDetailScreenState extends State<TreatmentDetailScreen> {
  int _tab = 0;

  static const _tabs = <_TabSpec>[
    _TabSpec(icon: CupertinoIcons.bandage, label: 'ผลวินิจฉัย'),
    _TabSpec(icon: CupertinoIcons.lab_flask, label: 'Lab / X-ray'),
    _TabSpec(icon: CupertinoIcons.capsule, label: 'ยา'),
    _TabSpec(icon: CupertinoIcons.waveform_path_ecg, label: 'vitalsign'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = widget.treatment;
    final color = t.type.primary;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.95), t.type.primaryDark],
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      LiquidGlassButton(
                        icon: CupertinoIcons.chevron_back,
                        iconColor: const Color(0xFF1A1A1A),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatDayMonthYear(t.date),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  children: [
                    _InfoCard(
                      treatment: t,
                      tabs: _tabs,
                      selected: _tab,
                      onChange: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _tab = i);
                      },
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      layoutBuilder: (current, _) =>
                          current ?? const SizedBox.shrink(),
                      child: KeyedSubtree(
                        key: ValueKey<int>(_tab),
                        child: _buildTabContent(t, _tab),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(Treatment t, int tab) {
    switch (tab) {
      case 0:
        return _DiagnosisCard(t: t);
      case 1:
        return _LabXrayContent(t: t);
      case 2:
        return _MedicationContent(t: t);
      case 3:
      default:
        return _VitalSignsGrid(v: t.vitals);
    }
  }
}

// ─── Info card with tabs ──────────────────────────────────────────────────

class _TabSpec {
  const _TabSpec({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.treatment,
    required this.tabs,
    required this.selected,
    required this.onChange,
  });
  final Treatment treatment;
  final List<_TabSpec> tabs;
  final int selected;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final t = treatment;
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  t.hospital,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _TypeChip(type: t.type),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _InfoKv('ผู้รับบริการ', t.patient),
              _InfoKv('แผนก', t.department),
            ],
          ),
          const SizedBox(height: 12),
          _TabRow(
            tabs: tabs,
            selected: selected,
            color: t.type.primary,
            onChange: onChange,
          ),
        ],
      ),
    );
  }
}

class _InfoKv extends StatelessWidget {
  const _InfoKv(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 13,
          height: 1.35,
        ),
        children: [
          TextSpan(
            text: '$k : ',
            style: const TextStyle(color: Color(0xFF6D756E)),
          ),
          TextSpan(text: v),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final TreatmentType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: type.pillBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: type.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TabRow extends StatefulWidget {
  const _TabRow({
    required this.tabs,
    required this.selected,
    required this.color,
    required this.onChange,
  });
  final List<_TabSpec> tabs;
  final int selected;
  final Color color;
  final ValueChanged<int> onChange;

  @override
  State<_TabRow> createState() => _TabRowState();
}

class _TabRowState extends State<_TabRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late int _prev;
  late List<double> _activeWidths;

  static const _curve = Cubic(0.34, 1.2, 0.64, 1.0);
  static const _activeLabelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static const double _activeIconSize = 22;
  static const double _activeHPad = 14;
  static const double _activeLabelGap = 6;

  @override
  void initState() {
    super.initState();
    _prev = widget.selected;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 1,
    );
    _activeWidths = _measureActiveWidths();
  }

  @override
  void didUpdateWidget(covariant _TabRow old) {
    super.didUpdateWidget(old);
    if (widget.selected != old.selected) {
      _prev = old.selected;
      _ctrl.forward(from: 0);
    }
    if (!identical(old.tabs, widget.tabs)) {
      _activeWidths = _measureActiveWidths();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<double> _measureActiveWidths() {
    return widget.tabs.map((spec) {
      final tp = TextPainter(
        text: TextSpan(text: spec.label, style: _activeLabelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      return _activeHPad * 2 +
          _activeIconSize +
          _activeLabelGap +
          tp.width +
          2;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    const inactiveW = 36.0;
    const tabH = 36.0;
    final n = widget.tabs.length;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _curve.transform(_ctrl.value);
        return Row(
          children: [
            for (int i = 0; i < n; i++) ...[
              _buildTab(i, t, _activeWidths[i], inactiveW, tabH),
              if (i != n - 1) const SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTab(
    int i,
    double t,
    double activeW,
    double inactiveW,
    double h,
  ) {
    final isCurrent = i == widget.selected;
    final wasCurrent = i == _prev && _prev != widget.selected;
    double activeness;
    if (isCurrent) {
      activeness = t;
    } else if (wasCurrent) {
      activeness = 1 - t;
    } else {
      activeness = 0;
    }

    final width = inactiveW + (activeW - inactiveW) * activeness;
    final bg = Color.lerp(
      const Color(0xFFF2F2F7),
      widget.color,
      activeness,
    )!;
    final fg = Color.lerp(
      const Color(0xFF6D756E),
      CupertinoColors.white,
      activeness,
    )!;
    final iconSize = 18 + 4 * activeness;

    return SizedBox(
      width: width,
      height: h,
      child: _TabHitArea(
        onTap: () {
          if (!isCurrent) {
            HapticFeedback.selectionClick();
            widget.onChange(i);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: h,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            boxShadow: activeness > 0.05
                ? [
                    BoxShadow(
                      color: widget.color
                          .withValues(alpha: 0.35 * activeness),
                      blurRadius: 10 * activeness,
                      offset: Offset(0, 4 * activeness),
                    ),
                  ]
                : const [],
          ),
          padding: EdgeInsets.symmetric(horizontal: 8 + 6 * activeness),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.tabs[i].icon, color: fg, size: iconSize),
              if (activeness > 0.05)
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: activeness,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        widget.tabs[i].label,
                        style: TextStyle(
                          color: CupertinoColors.white
                              .withValues(alpha: activeness),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.clip,
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabHitArea extends StatelessWidget {
  const _TabHitArea({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.none,
      rippleShape: BoxShape.circle,
      scale: 0.95,
      ripple: false,
      child: child,
    );
  }
}

// ─── Tab contents ─────────────────────────────────────────────────────────

class _DiagnosisCard extends StatelessWidget {
  const _DiagnosisCard({required this.t});
  final Treatment t;

  @override
  Widget build(BuildContext context) {
    return _SheetCard(
      title: 'ผลวินิจฉัย',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.diagnosis,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 13.5,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'คำแนะนำ:',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            for (final r in t.recommendations)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 8, left: 4),
                      child: SizedBox(
                        width: 4,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 13,
                          height: 1.55,
                        ),
                      ),
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

class _LabXrayContent extends StatelessWidget {
  const _LabXrayContent({required this.t});
  final Treatment t;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (t.labs.isNotEmpty)
          _SheetCard(
            title: 'การตรวจเลือด (Blood Test)',
            child: Column(
              children: [
                for (int i = 0; i < t.labs.length; i++) ...[
                  _LabBlock(item: t.labs[i], index: i + 1),
                  if (i != t.labs.length - 1)
                    Container(height: 1, color: const Color(0xFFE5E5E5)),
                ],
              ],
            ),
          ),
        if (t.xrays.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SheetCard(
            title: 'เอกซเรย์ (X-ray)',
            child: Column(
              children: [
                for (final x in t.xrays)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                x.name,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _StatusPill(status: x.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          x.note,
                          style: const TextStyle(
                            color: Color(0xFF6D756E),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (t.labs.isEmpty && t.xrays.isEmpty)
          _EmptyCard(message: 'ไม่มีข้อมูลการตรวจ'),
      ],
    );
  }
}

class _LabBlock extends StatelessWidget {
  const _LabBlock({required this.item, required this.index});
  final LabItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$index. ${item.name}',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(status: item.status),
            ],
          ),
          const SizedBox(height: 6),
          for (final kv in item.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    kv.k,
                    style: const TextStyle(
                      color: Color(0xFF6D756E),
                      fontSize: 12.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    kv.v,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final LabStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MedicationContent extends StatelessWidget {
  const _MedicationContent({required this.t});
  final Treatment t;

  @override
  Widget build(BuildContext context) {
    if (t.medications.isEmpty) {
      return _EmptyCard(message: 'ไม่มีข้อมูลการจ่ายยา');
    }
    return Column(
      children: [
        for (int i = 0; i < t.medications.length; i++) ...[
          _MedicationCard(med: t.medications[i], index: i),
          if (i != t.medications.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({required this.med, required this.index});
  final Medication med;
  final int index;

  static const _pillImages = <String>[
    'assets/images/allergy/penicillin.png',
    'assets/images/allergy/aspirin.png',
    'assets/images/allergy/ibuprofen.png',
  ];

  @override
  Widget build(BuildContext context) {
    final img = med.image ?? _pillImages[index % _pillImages.length];
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(img, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  med.name,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  med.dose,
                  style: const TextStyle(
                    color: Color(0xFF6D756E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            med.frequency,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalSignsGrid extends StatelessWidget {
  const _VitalSignsGrid({required this.v});
  final VitalSigns v;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _VitalTile(
        icon: CupertinoIcons.heart_fill,
        iconColor: const Color(0xFFB7185E),
        label: 'ความดันโลหิต',
        value: v.bp,
        unit: 'mmHg',
      ),
      _VitalTile(
        icon: CupertinoIcons.thermometer,
        iconColor: const Color(0xFF5AC8FA),
        label: 'อุณหภูมิ',
        value: v.temp,
        unit: '°C',
      ),
      _VitalTile(
        icon: CupertinoIcons.waveform_path_ecg,
        iconColor: const Color(0xFFFF2D55),
        label: 'อัตราการเต้นหัวใจ',
        value: v.heartRate,
        unit: 'bpm',
      ),
      _VitalTile(
        icon: CupertinoIcons.wind,
        iconColor: const Color(0xFF5AC8FA),
        label: 'ออกซิเจนในเลือด',
        value: v.spo2,
        unit: '%',
      ),
      _VitalTile(
        icon: Icons.air_rounded,
        iconColor: const Color(0xFF14B8A6),
        label: 'อัตราการหายใจ',
        value: v.respirationRate,
        unit: '/min',
      ),
      _VitalTile(
        icon: CupertinoIcons.chart_pie_fill,
        iconColor: const Color(0xFF34C759),
        label: 'น้ำหนัก',
        value: v.weight,
        unit: 'kg',
      ),
      _VitalTile(
        icon: CupertinoIcons.chart_pie_fill,
        iconColor: const Color(0xFF34C759),
        label: 'ส่วนสูง',
        value: v.height,
        unit: 'cm',
      ),
    ];
    return Column(
      children: [
        for (int row = 0; row < (tiles.length + 1) ~/ 2; row++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: tiles[row * 2]),
              const SizedBox(width: 10),
              Expanded(
                child: row * 2 + 1 < tiles.length
                    ? tiles[row * 2 + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          if (row < (tiles.length - 1) ~/ 2) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _VitalTile extends StatelessWidget {
  const _VitalTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CupertinoColors.black.withValues(alpha: 0.03),
        ),
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
                  color: iconColor,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: CupertinoColors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6D756E),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
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

// ─── Shared containers ────────────────────────────────────────────────────

class _SheetCard extends StatelessWidget {
  const _SheetCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6D756E),
          fontSize: 13,
        ),
      ),
    );
  }
}
