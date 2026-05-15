import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/skeleton_box.dart';
import 'add_family_member_sheet.dart';
import 'fall_alert.dart';
import 'family_detail_screen.dart';
import '../../core/widgets/liquid_glass_button.dart';

enum FamilyMemberStatus { allSafe, attentionNeeded }

typedef _MemberStatus = FamilyMemberStatus;

class FamilyMember {
  const FamilyMember({
    required this.name,
    required this.age,
    required this.bloodType,
    required this.batteryPercent,
    required this.imagePath,
    required this.status,
    required this.heartRate,
    required this.spo2,
    required this.cgm,
    required this.steps,
    required this.stepsGoal,
    required this.stepsWeek,
  });
  final String name;
  final int age;
  final String bloodType;
  final int batteryPercent;
  final String imagePath;
  final _MemberStatus status;
  final int heartRate;
  final int spo2;
  final int cgm;
  final int steps;
  final int stepsGoal;
  final List<int> stepsWeek; // จ-อา (7 ค่า ก้าว/วัน)
}

const kFamilyMembers = <FamilyMember>[
  FamilyMember(
    name: 'สมศรี วงศ์สุวรรณ',
    age: 60,
    bloodType: 'A',
    batteryPercent: 68,
    imagePath: 'assets/images/family/somsri.png',
    status: _MemberStatus.allSafe,
    heartRate: 72,
    spo2: 95,
    cgm: 120,
    steps: 6420,
    stepsGoal: 8000,
    stepsWeek: [5800, 6200, 7100, 5400, 6800, 7400, 6420],
  ),
  FamilyMember(
    name: 'ใจดี วงศ์สุวรรณ',
    age: 35,
    bloodType: 'AB',
    batteryPercent: 82,
    imagePath: 'assets/images/family/jaidee.png',
    status: _MemberStatus.allSafe,
    heartRate: 72,
    spo2: 95,
    cgm: 120,
    steps: 8240,
    stepsGoal: 10000,
    stepsWeek: [9100, 7800, 8500, 9400, 7200, 8900, 8240],
  ),
  FamilyMember(
    name: 'สมชาย วงศ์สุวรรณ',
    age: 65,
    bloodType: 'B',
    batteryPercent: 24,
    imagePath: 'assets/images/family/somchai.png',
    status: _MemberStatus.attentionNeeded,
    heartRate: 112,
    spo2: 92,
    cgm: 168,
    steps: 3120,
    stepsGoal: 6000,
    stepsWeek: [2800, 3400, 2600, 3800, 2900, 3500, 3120],
  ),
  FamilyMember(
    name: 'ปรีชา วงศ์สุวรรณ',
    age: 70,
    bloodType: 'B',
    batteryPercent: 15,
    imagePath: 'assets/images/family/preecha.png',
    status: _MemberStatus.attentionNeeded,
    heartRate: 98,
    spo2: 91,
    cgm: 184,
    steps: 1850,
    stepsGoal: 5000,
    stepsWeek: [1600, 2200, 1400, 1900, 1700, 2300, 1850],
  ),
  FamilyMember(
    name: 'มินตรา วงศ์สุวรรณ',
    age: 28,
    bloodType: 'O',
    batteryPercent: 76,
    imagePath: 'assets/images/family/mintra.png',
    status: _MemberStatus.allSafe,
    heartRate: 68,
    spo2: 98,
    cgm: 102,
    steps: 9650,
    stepsGoal: 10000,
    stepsWeek: [10200, 9800, 11400, 8900, 10600, 9200, 9650],
  ),
];

/// Patients the nurse takes care of. Reuses [FamilyMember] so cards render
/// identically to the family list.
const kNursePatients = <FamilyMember>[
  FamilyMember(
    name: 'คุณสมหวัง ใจดี',
    age: 72,
    bloodType: 'A',
    batteryPercent: 54,
    imagePath: 'assets/images/family/somchai.png',
    status: _MemberStatus.allSafe,
    heartRate: 76,
    spo2: 96,
    cgm: 132,
    steps: 3120,
    stepsGoal: 5000,
    stepsWeek: [2800, 3400, 2900, 3700, 3100, 3500, 3120],
  ),
  FamilyMember(
    name: 'คุณวิภา รักษ์สุขภาพ',
    age: 68,
    bloodType: 'B',
    batteryPercent: 41,
    imagePath: 'assets/images/family/somsri.png',
    status: _MemberStatus.attentionNeeded,
    heartRate: 92,
    spo2: 93,
    cgm: 168,
    steps: 1480,
    stepsGoal: 5000,
    stepsWeek: [1200, 1500, 1100, 1600, 1300, 1700, 1480],
  ),
  FamilyMember(
    name: 'คุณประยูร นพรัตน์',
    age: 75,
    bloodType: 'O',
    batteryPercent: 79,
    imagePath: 'assets/images/family/preecha.png',
    status: _MemberStatus.allSafe,
    heartRate: 70,
    spo2: 97,
    cgm: 118,
    steps: 4250,
    stepsGoal: 6000,
    stepsWeek: [3800, 4500, 4100, 4700, 4000, 4300, 4250],
  ),
  FamilyMember(
    name: 'คุณมานี ภักดี',
    age: 80,
    bloodType: 'AB',
    batteryPercent: 22,
    imagePath: 'assets/images/family/jaidee.png',
    status: _MemberStatus.attentionNeeded,
    heartRate: 96,
    spo2: 90,
    cgm: 192,
    steps: 920,
    stepsGoal: 4000,
    stepsWeek: [800, 1100, 700, 1200, 900, 1000, 920],
  ),
];

enum CareGiverTab { family, nurse }

class CareGiverScreen extends StatefulWidget {
  const CareGiverScreen({super.key});

  @override
  State<CareGiverScreen> createState() => _CareGiverScreenState();
}

class _CareGiverScreenState extends State<CareGiverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late List<FamilyMember> _sortedMembers;
  CareGiverTab _selectedTab = CareGiverTab.family;
  bool _loading = true;
  Timer? _skeletonTimer;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _sortedMembers = _computeSorted();
    fallAlertsStore.addListener(_onAlertChange);
    _skeletonTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _loading = false);
      _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    fallAlertsStore.removeListener(_onAlertChange);
    _entryCtrl.dispose();
    super.dispose();
  }

  void _onAlertChange() {
    if (!mounted) return;
    setState(() => _sortedMembers = _computeSorted());
  }

  List<FamilyMember> _computeSorted() {
    final source = _selectedTab == CareGiverTab.family
        ? kFamilyMembers
        : kNursePatients;
    final store = fallAlertsStore.value;
    final list = [...source];
    list.sort((a, b) {
      final aAlert = store.containsKey(a.name);
      final bAlert = store.containsKey(b.name);
      if (aAlert == bAlert) {
        return source.indexOf(a).compareTo(source.indexOf(b));
      }
      return aAlert ? -1 : 1;
    });
    return list;
  }

  void _onTabChanged(CareGiverTab tab) {
    if (tab == _selectedTab) return;
    setState(() {
      _selectedTab = tab;
      _sortedMembers = _computeSorted();
    });
    _entryCtrl
      ..reset()
      ..forward();
  }

  Widget _staggered(int index, int total, Widget child) {
    final start = (index / (total * 1.8)).clamp(0.0, 0.9);
    final end = (start + 0.6).clamp(0.0, 1.0);
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
            offset: Offset(0, (1 - t) * 28),
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
    if (_loading) return const _CareGiverSkeleton();
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('ครอบครัว'),
            backgroundColor: bg.withValues(alpha: 0.85),
            border: null,
            trailing: LiquidGlassButton(
              icon: CupertinoIcons.plus,
              onTap: () => showAddFamilyMemberSheet(context),
              size: 36,
              iconSize: 20,
              iconColor: const Color(0xFF1D8B6B),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _CareGiverTabBar(
                selected: _selectedTab,
                onChanged: _onTabChanged,
                familyCount: kFamilyMembers.length,
                nurseCount: kNursePatients.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i >= _sortedMembers.length) return null;
                  final m = _sortedMembers[i];
                  return Padding(
                    key: ValueKey(m.name),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _staggered(
                      i,
                      _sortedMembers.length,
                      FamilyMemberCard(
                        member: m,
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => FamilyDetailScreen(member: m),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _sortedMembers.length,
                findChildIndexCallback: (key) {
                  if (key is ValueKey<String>) {
                    final idx = _sortedMembers
                        .indexWhere((m) => m.name == key.value);
                    return idx == -1 ? null : idx;
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FamilyMemberCard extends StatefulWidget {
  const FamilyMemberCard({super.key, required this.member, this.onTap});
  final FamilyMember member;
  final VoidCallback? onTap;

  @override
  State<FamilyMemberCard> createState() => _FamilyMemberCardState();
}

class _FamilyMemberCardState extends State<FamilyMemberCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  FamilyMember get member => widget.member;
  VoidCallback? get onTap => widget.onTap;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, FallAlert>>(
      valueListenable: fallAlertsStore,
      builder: (_, store, __) => _buildCard(context, store.containsKey(member.name)),
    );
  }

  Widget _buildCard(BuildContext context, bool hasFallAlert) {
    final isAttention = member.status == _MemberStatus.attentionNeeded;
    final showRed = isAttention || hasFallAlert;
    final gradientColors = showRed
        ? const [Color(0x80FF9C66), Color(0x80BC1B06)]
        : const [Color(0x8068C7AD), Color(0x801D8B6B)];
    final statusColor = hasFallAlert
        ? const Color(0xFFBC1B06)
        : (isAttention
            ? const Color(0xFFFF383C)
            : const Color(0xFF166C53));
    final statusText =
        hasFallAlert ? 'พบการล้ม' : (isAttention ? 'ต้องดูแล' : 'ปลอดภัยดี');
    final statusIcon = hasFallAlert
        ? CupertinoIcons.exclamationmark_triangle_fill
        : CupertinoIcons.checkmark_shield_fill;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: CupertinoColors.white),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
              ),
            ),
          ),
          // Person image on right
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
              width: 150,
              height: 210,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.3],
                  colors: [
                    Color(0x00000000),
                    Color(0xFF000000),
                  ],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  member.imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBadge(
                      label: statusText,
                      color: statusColor,
                      icon: statusIcon,
                      filled: hasFallAlert,
                      pulse: hasFallAlert ? _pulse : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      member.name,
                      style: AppTypography.headline(const Color(0xFF1A1A1A))
                          .copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Opacity(
                      opacity: 0.7,
                      child: Row(
                        children: [
                          _InfoText('อายุ ${member.age} ปี'),
                          const _DividerDot(),
                          _InfoText('หมู่เลือด ${member.bloodType}'),
                          const _DividerDot(),
                          const Icon(
                            CupertinoIcons.battery_75_percent,
                            size: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                          const SizedBox(width: 4),
                          _InfoText('${member.batteryPercent}%'),
                        ],
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MetricEntry(
                              icon: CupertinoIcons.waveform_path_ecg,
                              label: 'อัตราการเต้นหัวใจ',
                              value: member.heartRate.toString(),
                              unit: 'bpm',
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _MetricEntry(
                              icon: CupertinoIcons.sun_max,
                              label: 'ออกซิเจนในเลือด',
                              value: member.spo2.toString(),
                              unit: '%',
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _MetricEntry(
                              icon: CupertinoIcons.drop,
                              label: 'น้ำตาลต่อเนื่อง',
                              value: member.cgm.toString(),
                              unit: 'mg/dl',
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
    );

    final wrapped = hasFallAlert
        ? AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              // Eased value gives a sharper on/off "blink" feel rather than
              // a slow breathe.
              final t = Curves.easeInOut.transform(_pulse.value);
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBC1B06)
                          .withValues(alpha: 0.25 + 0.45 * t),
                      blurRadius: 10 + 14 * t,
                      spreadRadius: 0.5 + 2 * t,
                    ),
                  ],
                ),
                child: card,
              );
            },
          )
        : card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.heavyImpact();
        if (hasFallAlert) {
          clearFallAlertFor(member.name);
          AppToast.success(context, 'ล้างแจ้งเตือนการล้มแล้ว');
        } else {
          triggerFallAlertFor(member.name, location: 'ห้องนอน');
          AppToast.warning(
            context,
            'จำลองแจ้งเตือนการล้ม · ${member.name.split(' ').first}',
          );
        }
      },
      child: wrapped,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    this.icon = CupertinoIcons.checkmark_shield_fill,
    this.filled = false,
    this.pulse,
  });
  final String label;
  final Color color;
  final IconData icon;
  final bool filled;
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    if (pulse == null) return _build(1.0);
    return AnimatedBuilder(
      animation: pulse!,
      builder: (_, __) => _build(pulse!.value),
    );
  }

  Widget _build(double t) {
    final bg = filled ? color : const Color(0xFFF5F5F5);
    final fg = filled ? CupertinoColors.white : color;
    return Container(
      height: filled ? 28 : 24,
      padding: EdgeInsets.symmetric(horizontal: filled ? 12 : 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35 + 0.25 * t),
                  blurRadius: 10 + 6 * t,
                  spreadRadius: 0.5 + 1.5 * t,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: filled ? 13 : 12, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption1(fg).copyWith(
              fontSize: filled ? 13 : 12,
              fontWeight: filled ? FontWeight.w800 : FontWeight.w600,
              height: 16 / 12,
              letterSpacing: filled ? 0.3 : 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.caption2(const Color(0xFF1A1A1A)).copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}

class _DividerDot extends StatelessWidget {
  const _DividerDot();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 1,
        height: 8,
        child: ColoredBox(color: Color(0xFF1A1A1A)),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: CupertinoColors.white.withValues(alpha: 0.3),
    );
  }
}

class _MetricEntry extends StatelessWidget {
  const _MetricEntry({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: CupertinoColors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTypography.caption2(CupertinoColors.white).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  height: 1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
              style: AppTypography.headline(CupertinoColors.white).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                unit,
                style: AppTypography.caption2(CupertinoColors.white).copyWith(
                  fontSize: 10,
                  letterSpacing: -0.6,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CareGiverTabBar extends StatelessWidget {
  const _CareGiverTabBar({
    required this.selected,
    required this.onChanged,
    required this.familyCount,
    required this.nurseCount,
  });

  final CareGiverTab selected;
  final ValueChanged<CareGiverTab> onChanged;
  final int familyCount;
  final int nurseCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFD4D4D4).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(100),
      ),
      child: SizedBox(
        height: 40,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segW = constraints.maxWidth / 2;
            final selIdx = selected == CareGiverTab.family ? 0 : 1;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutQuint,
                  left: selIdx * segW,
                  top: 0,
                  bottom: 0,
                  width: segW,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    _CareGiverTabSegment(
                      icon: CupertinoIcons.person_2_fill,
                      label: 'ครอบครัว',
                      count: familyCount,
                      selected: selected == CareGiverTab.family,
                      onTap: () => onChanged(CareGiverTab.family),
                    ),
                    _CareGiverTabSegment(
                      icon: CupertinoIcons.heart_circle_fill,
                      label: 'พยาบาล',
                      count: nurseCount,
                      selected: selected == CareGiverTab.nurse,
                      onTap: () => onChanged(CareGiverTab.nurse),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CareGiverTabSegment extends StatelessWidget {
  const _CareGiverTabSegment({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = selected ? const Color(0xFF1D8B6B) : const Color(0xFF6D756E);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: tone),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF1D8B6B)
                      : const Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1D8B6B)
                      : const Color(0xFFB0B4B1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

class _CareGiverSkeleton extends StatelessWidget {
  const _CareGiverSkeleton();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: SkeletonHost(
        builder: (_, shimmer) => SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(shimmer: shimmer, width: 120, height: 32),
                  SkeletonBox(
                      shimmer: shimmer,
                      width: 36,
                      height: 36,
                      borderRadius: 100),
                ],
              ),
              const SizedBox(height: 12),
              SkeletonBox(shimmer: shimmer, height: 40, borderRadius: 100),
              const SizedBox(height: 24),
              for (int i = 0; i < 4; i++) ...[
                SkeletonBox(
                    shimmer: shimmer, height: 168, borderRadius: 24),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
