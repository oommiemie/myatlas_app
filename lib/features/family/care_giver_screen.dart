import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/theme/app_typography.dart';
import 'family_detail_screen.dart';

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
}

const _members = <FamilyMember>[
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
  ),
];

class CareGiverScreen extends StatefulWidget {
  const CareGiverScreen({super.key});

  @override
  State<CareGiverScreen> createState() => _CareGiverScreenState();
}

class _CareGiverScreenState extends State<CareGiverScreen>
    with SingleTickerProviderStateMixin {
  int _topTab = 0; // 0 = Family, 1 = Security
  late final AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
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
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Care Giver'),
            backgroundColor: bg.withValues(alpha: 0.85),
            border: null,
            trailing: _LiquidGlassButton(
              icon: CupertinoIcons.plus,
              onTap: () {},
              size: 36,
              iconSize: 20,
              iconColor: const Color(0xFF1D8B6B),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: _FamilySecurityTabs(
                selected: _topTab,
                onChange: (i) => setState(() => _topTab = i),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i >= _members.length) return null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _staggered(
                      i,
                      _members.length,
                      FamilyMemberCard(
                        member: _members[i],
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) =>
                                FamilyDetailScreen(member: _members[i]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _members.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilySecurityTabs extends StatelessWidget {
  const _FamilySecurityTabs({
    required this.selected,
    required this.onChange,
  });
  final int selected;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const tabs = ['Family', 'Security'];
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
                      color: const Color(0xFF1D8B6B),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D8B6B)
                              .withValues(alpha: 0.24),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                                    ? CupertinoColors.white
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

class _LiquidGlassButton extends StatelessWidget {
  const _LiquidGlassButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 20,
    this.iconColor = const Color(0xFF1A1A1A),
  });
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
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
                color: iconColor,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({super.key, required this.member, this.onTap});
  final FamilyMember member;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAttention = member.status == _MemberStatus.attentionNeeded;
    final gradientColors = isAttention
        ? const [Color(0x80FF9C66), Color(0x80BC1B06)]
        : const [Color(0x8068C7AD), Color(0x801D8B6B)];
    final statusColor =
        isAttention ? const Color(0xFFFF383C) : const Color(0xFF166C53);
    final statusText = isAttention ? 'Attention Needed' : 'All Safe';

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
                              label: 'Heart Rate',
                              value: member.heartRate.toString(),
                              unit: 'bpm',
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _MetricEntry(
                              icon: CupertinoIcons.sun_max,
                              label: 'SpO₂',
                              value: member.spo2.toString(),
                              unit: '%',
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _MetricEntry(
                              icon: CupertinoIcons.drop,
                              label: 'CGM',
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
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.checkmark_shield_fill,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption1(color).copyWith(
              fontSize: 12,
              height: 16 / 12,
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
        fontSize: 10,
        height: 16 / 10,
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
            Text(
              label,
              style: AppTypography.caption2(CupertinoColors.white).copyWith(
                fontSize: 10,
                letterSpacing: 0.275,
                height: 16.5 / 10,
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
              style: AppTypography.headline(CupertinoColors.white).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6,
                height: 15 / 14,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                unit,
                style: AppTypography.caption2(CupertinoColors.white).copyWith(
                  fontSize: 8,
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
