import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';
import '../health/widgets/mini_charts.dart';
import 'call_screen.dart';
import 'care_giver_screen.dart';
import 'fall_alert.dart';
import 'family_devices.dart';

// Bangkok example coordinate for the family home.
const double _homeLat = 13.7563;
const double _homeLon = 100.5018;

Future<void> _openDirectionsInMaps() async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&destination=$_homeLat,$_homeLon'
    '&travelmode=driving',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class FamilyDetailScreen extends StatefulWidget {
  const FamilyDetailScreen({super.key, required this.member});
  final FamilyMember member;

  @override
  State<FamilyDetailScreen> createState() => _FamilyDetailScreenState();
}

class _FamilyDetailScreenState extends State<FamilyDetailScreen>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);
  late final AnimationController _enter;
  // Mock state — in a real app this would come from a repository.
  late final Set<DeviceKind> _connectedDevices;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
    _connectedDevices = _seedDevicesFor(widget.member);
  }

  Set<DeviceKind> _seedDevicesFor(FamilyMember m) {
    // Pre-fill plausible devices based on which vitals the member already has.
    final s = <DeviceKind>{DeviceKind.smartwatch};
    if (m.cgm > 0) s.add(DeviceKind.cgm);
    if (m.spo2 > 0) s.add(DeviceKind.spo2);
    return s;
  }

  Future<void> _manageDevices() async {
    await showManageDevicesSheet(
      context,
      selected: _connectedDevices,
      memberName: widget.member.name.split(' ').first,
      onChanged: (next) {
        setState(() {
          _connectedDevices
            ..clear()
            ..addAll(next);
        });
      },
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  FamilyMember get member => widget.member;

  Widget _stagger(int index, int total, Widget child) {
    final start = (index / total) * 0.5;
    final end = (start + 0.55).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) {
        final t = anim.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4F8F5);
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE4F5F0), Color(0xFFF4F8F5)],
                  stops: [0.0, 0.5],
                ),
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollUpdateNotification || n is ScrollStartNotification) {
                _scrollOffset.value = n.metrics.pixels;
              }
              return false;
            },
            child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(height: 56),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    _stagger(0, 7, _ProfileCard(member: member)),
                    const SizedBox(height: 16),
                    _stagger(1, 7, _MetricsGrid(member: member)),
                    const SizedBox(height: 16),
                    _stagger(2, 7, _StepsCard(member: member)),
                    const SizedBox(height: 16),
                    _stagger(
                      3,
                      7,
                      _DevicesCard(
                        member: member,
                        connected: _connectedDevices,
                        onManage: _manageDevices,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _stagger(4, 7, const _LocationCard()),
                    const SizedBox(height: 16),
                    _stagger(5, 7, const _RecentEventsSection()),
                    const SizedBox(height: 16),
                    _stagger(6, 7, const _EmergencyContactsSection()),
                  ]),
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
              builder: (_, offset, __) => _PinnedTopBar(
                title: 'ข้อมูลคนในครอบครัว',
                scrollOffset: offset,
                onBack: () => Navigator.of(context).pop(),
                onCall: () => showCallScreen(
                  context,
                  member: widget.member,
                  type: CallType.voice,
                  direction: CallDirection.outgoing,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedTopBar extends StatelessWidget {
  const _PinnedTopBar({
    required this.title,
    required this.scrollOffset,
    required this.onBack,
    required this.onCall,
  });
  final String title;
  final double scrollOffset;
  final VoidCallback onBack;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final progress = (scrollOffset / 60).clamp(0.0, 1.0);
    final barHeight = top + 6 + 44 + 6;
    return Stack(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22 * progress,
              sigmaY: 22 * progress,
            ),
            child: Container(
              height: barHeight,
              color: const Color(0xFFF4F8F5)
                  .withValues(alpha: 0.80 * progress),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: progress,
            child: Container(
              height: 0.5,
              color: CupertinoColors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: top + 6, left: 14, right: 14),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.chevron_back,
                    onTap: onBack,
                    size: 40,
                    iconSize: 18,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.phone_fill,
                    onTap: onCall,
                    size: 40,
                    iconSize: 18,
                    iconColor: const Color(0xFF2CA989),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.member});
  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FamilyMemberCard(member: member),
        ValueListenableBuilder<Map<String, FallAlert>>(
          valueListenable: fallAlertsStore,
          builder: (_, store, __) {
            if (!store.containsKey(member.name)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: FallAlertBanner(member: member),
            );
          },
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.member});
  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    final hrData = [68, 72, 74, 76, 78, 80, 72]
        .map((e) => e.toDouble())
        .toList();
    final cgmData = [110, 115, 120, 118, 125, 122, 120]
        .map((e) => e.toDouble())
        .toList();
    final spo2Data = [96, 98, 95, 93, 92, 95, 98]
        .map((e) => e.toDouble())
        .toList();
    final bpSys = [142, 148, 150, 145, 152, 148, 150]
        .map((e) => e.toDouble())
        .toList();
    final bpDia = [74, 76, 78, 75, 80, 77, 77]
        .map((e) => e.toDouble())
        .toList();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: CupertinoIcons.heart_fill,
                iconColor: AppColors.health,
                label: 'อัตราการเต้นหัวใจ',
                value: member.heartRate.toString(),
                unit: 'bpm',
                chart: MiniLineChart(
                  data: hrData,
                  color: AppColors.health,
                  indicatorIndex: hrData.length - 1,
                  interactive: false,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: CupertinoIcons.sun_max,
                iconColor: AppColors.mindfulness,
                label: 'ออกซิเจนในเลือด',
                value: member.spo2.toString(),
                unit: '%',
                chart: MiniBarChart(
                  values: spo2Data,
                  color: AppColors.mindfulness,
                  highlightIndex: spo2Data.length - 1,
                  barWidth: 4,
                  interactive: false,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: CupertinoIcons.drop_fill,
                iconColor: AppColors.sleep,
                label: 'น้ำตาลต่อเนื่อง',
                value: member.cgm.toString(),
                unit: 'mg/dl',
                chart: MiniLineChart(
                  data: cgmData,
                  color: AppColors.sleep,
                  indicatorIndex: cgmData.length - 1,
                  interactive: false,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: CupertinoIcons.heart_circle_fill,
                iconColor: const Color(0xFFBE123C),
                label: 'ความดันโลหิต',
                value: '150/77',
                unit: 'mmHg',
                chart: DualLineChart(
                  primary: bpSys,
                  secondary: bpDia,
                  primaryColor: const Color(0xFFF06C8C),
                  secondaryColor: const Color(0xFF4A6CF7),
                  primaryLabel: 'Sys',
                  secondaryLabel: 'Dia',
                  interactive: false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.member});
  final FamilyMember member;

  static const _stepColor = Color(0xFFE32616);
  static const _weekDayLabels = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];

  String _formatInt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int k = 0; k < s.length; k++) {
      if (k > 0 && (s.length - k) % 3 == 0) buf.write(',');
      buf.write(s[k]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (member.steps / member.stepsGoal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final remaining = (member.stepsGoal - member.steps).clamp(0, 1 << 31);
    final reached = member.steps >= member.stepsGoal;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _stepColor,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.flame_fill,
                  color: CupertinoColors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'ก้าวเดินวันนี้',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: reached
                      ? const Color(0xFF1D8B6B).withValues(alpha: 0.14)
                      : _stepColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  reached ? 'ถึงเป้าแล้ว' : '$percent%',
                  style: TextStyle(
                    color: reached
                        ? const Color(0xFF1D8B6B)
                        : _stepColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatInt(member.steps),
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ ${_formatInt(member.stepsGoal)} ก้าว',
                  style: const TextStyle(
                    color: Color(0xFF6D756E),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reached
                ? 'เดินครบเป้าหมายแล้ว วันนี้สุดยอดเลย'
                : 'อีก ${_formatInt(remaining)} ก้าวจะถึงเป้าหมาย',
            style: const TextStyle(
              color: Color(0xFF6D756E),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: reached
                              ? const [
                                  Color(0xFF26A37E),
                                  Color(0xFF1D8B6B),
                                ]
                              : const [
                                  Color(0xFFFF6B5A),
                                  Color(0xFFE32616),
                                ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '7 วันที่ผ่านมา',
            style: TextStyle(
              color: Color(0xFF6D756E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: _StepsWeekChart(
              values: member.stepsWeek,
              goal: member.stepsGoal,
              dayLabels: _weekDayLabels,
              color: _stepColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsWeekChart extends StatelessWidget {
  const _StepsWeekChart({
    required this.values,
    required this.goal,
    required this.dayLabels,
    required this.color,
  });
  final List<int> values;
  final int goal;
  final List<String> dayLabels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final scaleMax = maxVal > goal ? maxVal : goal;
    final lastIdx = values.length - 1;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < values.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _StepsBar(
                        progress: values[i] / scaleMax,
                        color: i == lastIdx
                            ? color
                            : color.withValues(alpha: 0.35),
                        reachedGoal: values[i] >= goal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (int i = 0; i < values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dayLabels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: i == lastIdx
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF6D756E),
                        fontSize: 11,
                        fontWeight: i == lastIdx
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StepsBar extends StatelessWidget {
  const _StepsBar({
    required this.progress,
    required this.color,
    required this.reachedGoal,
  });
  final double progress;
  final Color color;
  final bool reachedGoal;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            ),
          ),
          FractionallySizedBox(
            heightFactor: progress.clamp(0.05, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: reachedGoal
                      ? [
                          const Color(0xFF26A37E),
                          color.withValues(alpha: 0.6),
                        ]
                      : [color, color.withValues(alpha: 0.55)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevicesCard extends StatelessWidget {
  const _DevicesCard({
    required this.member,
    required this.connected,
    required this.onManage,
  });
  final FamilyMember member;
  final Set<DeviceKind> connected;
  final VoidCallback onManage;

  /// Plausible per-device battery derived from the member's primary battery
  /// plus a deterministic offset per device kind.
  int _batteryFor(DeviceKind kind) {
    final base = member.batteryPercent;
    switch (kind) {
      case DeviceKind.smartwatch:
        return base;
      case DeviceKind.loopBand:
        return (base + 10).clamp(8, 100);
      case DeviceKind.smartRing:
        return (base - 8).clamp(8, 100);
      case DeviceKind.cgm:
        return (base - 5).clamp(8, 100);
      case DeviceKind.bp:
        return (base + 25).clamp(8, 100);
      case DeviceKind.spo2:
        return (base - 12).clamp(8, 100);
      case DeviceKind.scale:
        return 88;
      case DeviceKind.thermometer:
        return 72;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = connected.toList();
    final isEmpty = list.isEmpty;
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1D8B6B),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.dot_radiowaves_left_right,
                  color: CupertinoColors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'อุปกรณ์ที่เชื่อมต่อ',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (!isEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D8B6B).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${list.length} อุปกรณ์',
                    style: const TextStyle(
                      color: Color(0xFF1D8B6B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'ยังไม่ได้เชื่อมต่ออุปกรณ์ใด ๆ',
                style: TextStyle(
                  color: Color(0xFF6D756E),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < list.length; i++) ...[
                  _ConnectedDeviceRow(
                    kind: list[i],
                    battery: _batteryFor(list[i]),
                  ),
                  if (i < list.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        height: 0.5,
                        color: const Color(0xFFEDEDF0),
                      ),
                    ),
                ],
              ],
            ),
          const SizedBox(height: 14),
          PressEffect(
            onTap: onManage,
            haptic: HapticKind.selection,
            scale: 0.98,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: const Color(0xFF1D8B6B).withValues(alpha: 0.4),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.add,
                    size: 14,
                    color: Color(0xFF1D8B6B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isEmpty ? 'เชื่อมต่ออุปกรณ์' : 'จัดการอุปกรณ์',
                    style: const TextStyle(
                      color: Color(0xFF1D8B6B),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectedDeviceRow extends StatelessWidget {
  const _ConnectedDeviceRow({required this.kind, required this.battery});
  final DeviceKind kind;
  final int battery;

  Color get _batteryColor {
    if (battery < 20) return const Color(0xFFDC2626);
    if (battery < 40) return const Color(0xFFD97706);
    return const Color(0xFF1D8B6B);
  }

  IconData get _batteryIcon {
    if (battery >= 75) return CupertinoIcons.battery_75_percent;
    if (battery >= 25) return CupertinoIcons.battery_25_percent;
    return CupertinoIcons.battery_empty;
  }

  @override
  Widget build(BuildContext context) {
    final c = _batteryColor;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kind.tone.withValues(alpha: 0.14),
          ),
          alignment: Alignment.center,
          child: Icon(kind.icon, color: kind.tone, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kind.label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_batteryIcon, size: 14, color: c),
              const SizedBox(width: 4),
              Text(
                '$battery%',
                style: TextStyle(
                  color: c,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.chart,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        color: CupertinoColors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.caption1(
                          const Color(0xFF6D756E),
                        ).copyWith(
                          fontSize: 12,
                          letterSpacing: 0.275,
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
                      style: AppTypography.title2(CupertinoColors.black)
                          .copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.6,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: AppTypography.caption2(
                          const Color(0xFF737373),
                        ).copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFDEE8E0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/family/bangkok_map.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.location_solid,
                                      color: CupertinoColors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ตำแหน่งล่าสุด',
                                      style: AppTypography.caption1(
                                        CupertinoColors.white,
                                      ).copyWith(
                                        fontSize: 12,
                                        letterSpacing: 0.275,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'บ้านเลขที่ 42/5 ซอย 3',
                                  style: AppTypography.subheadline(
                                    CupertinoColors.white,
                                  ).copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.white
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    'โซน A',
                                    style: AppTypography.caption2(
                                      CupertinoColors.white,
                                    ).copyWith(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _CircleIconButton(
                            icon: CupertinoIcons.map_fill,
                            onTap: _openDirectionsInMaps,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment(0, -0.4),
              child: _MapPin(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatefulWidget {
  const _MapPin();

  @override
  State<_MapPin> createState() => _MapPinState();
}

class _MapPinState extends State<_MapPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              final t = Curves.easeOut.transform(_pulse.value);
              final size = 40 + 56 * t;
              final alpha = (1 - t) * 0.35;
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF2D55).withValues(alpha: alpha),
                ),
              );
            },
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF2D55).withValues(alpha: 0.18),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.white,
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF5A74), Color(0xFFFF2D55)],
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
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
          color: CupertinoColors.white.withValues(alpha: 0.75),
        ),
        child: const Icon(
          CupertinoIcons.map_fill,
          color: Color(0xFF0088FF),
          size: 18,
        ),
      ),
    );
  }
}

class _RecentEventsSection extends StatelessWidget {
  const _RecentEventsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'เหตุการณ์ล่าสุด',
                style:
                    AppTypography.headline(const Color(0xFF1A1A1A)).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'ดูทั้งหมด',
              style: AppTypography.caption1(const Color(0xFF0088FF))
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const _EventRow(
          title: 'การล้ม',
          date: '6 เม.ย.',
          statusLabel: 'กำลังช่วยเหลือ',
          statusColor: Color(0xFF51A2FF),
          closed: false,
        ),
        const SizedBox(height: 8),
        const _EventRow(
          title: 'การล้ม',
          date: '6 เม.ย.',
          statusLabel: 'ปิดเคสแล้ว',
          statusColor: Color(0xFF71717B),
          closed: true,
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.title,
    required this.date,
    required this.statusLabel,
    required this.statusColor,
    required this.closed,
  });
  final String title;
  final String date;
  final String statusLabel;
  final Color statusColor;
  final bool closed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6900).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: closed
                  ? const Color(0xFFFF9C66).withValues(alpha: 0.5)
                  : const Color(0xFFFF6900),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTypography.subheadline(const Color(0xFF1A1A1A))
                          .copyWith(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: AppTypography.caption2(const Color(0xFF6D756E))
                      .copyWith(fontSize: 11, height: 1.5),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  statusLabel,
                  style: AppTypography.caption1(statusColor).copyWith(
                    fontSize: 12,
                    letterSpacing: 0.275,
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

class _EmergencyContactsSection extends StatelessWidget {
  const _EmergencyContactsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ผู้ติดต่อฉุกเฉิน',
          style: AppTypography.headline(const Color(0xFF1A1A1A)).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const _ContactRow(
          name: 'ใจดี วงศ์สุวรรณ',
          relation: 'ลูกสาว',
          phone: '082-345-6789',
          imagePath: 'assets/images/family/jaidee.png',
        ),
        const SizedBox(height: 8),
        const _ContactRow(
          name: 'ธวัตชัย วงศ์สุวรรณ',
          relation: 'ลูกชาย',
          phone: '082-345-6789',
          imagePath: 'assets/images/family/somchai.png',
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.name,
    required this.relation,
    required this.phone,
    required this.imagePath,
  });
  final String name;
  final String relation;
  final String phone;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CupertinoColors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1D8B6B), Color(0xFF166C53)],
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style:
                      AppTypography.subheadline(const Color(0xFF1A1A1A))
                          .copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$relation • $phone',
                  style: AppTypography.caption2(const Color(0xFF1A1A1A))
                      .copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2CA989),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 40,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.phone_fill,
              color: Color(0xFFE4F5F0),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
