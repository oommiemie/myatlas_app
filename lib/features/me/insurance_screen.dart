import 'package:flutter/cupertino.dart';

import '../health/widgets/health_detail_app_bar.dart';

enum _DotIcon { plus, letterN, info, briefcase, crossCase, calendar }

class _InfoItem {
  const _InfoItem({required this.icon, required this.text});
  final _DotIcon icon;
  final String text;
}

class InsurancePlan {
  const InsurancePlan({
    required this.title,
    required this.image,
    required this.items,
  });
  final String title;
  final String image;
  final List<_InfoItem> items;
}

const _samplePlans = <InsurancePlan>[
  InsurancePlan(
    title: 'สิทธิหลักประกันสุขภาพแห่งชาติ (บัตรทอง)',
    image: 'assets/images/me/insurance_goldcard.png',
    items: [
      _InfoItem(icon: _DotIcon.plus, text: 'โรงพยาบาลเสรีโฟล'),
      _InfoItem(icon: _DotIcon.letterN, text: 'เลขสิทธิ 1234-5678-9012'),
      _InfoItem(
        icon: _DotIcon.info,
        text: 'ครอบคลุม ตรวจรักษาทั่วไป / ยาพื้นฐาน / ผ่าตัดตามสิทธิ',
      ),
    ],
  ),
  InsurancePlan(
    title: 'ประกันสังคม',
    image: 'assets/images/me/insurance_sso.png',
    items: [
      _InfoItem(icon: _DotIcon.plus, text: 'โรงพยาบาลเสรีโฟล'),
      _InfoItem(icon: _DotIcon.letterN, text: 'เลขสิทธิ 1234-5678-9012'),
      _InfoItem(
        icon: _DotIcon.info,
        text: 'ครอบคลุม ค่ารักษาพยาบาล / คลอดบุตร / ทันตกรรมบางรายการ',
      ),
    ],
  ),
  InsurancePlan(
    title: 'ประกันสุขภาพเอกชน',
    image: 'assets/images/me/insurance_axa.png',
    items: [
      _InfoItem(icon: _DotIcon.briefcase, text: 'AXA Insurance'),
      _InfoItem(icon: _DotIcon.crossCase, text: 'แผนประกัน Smart Care Plus'),
      _InfoItem(icon: _DotIcon.letterN, text: 'เลขกรมธรรม์ AXA-55667788'),
      _InfoItem(icon: _DotIcon.calendar, text: 'วันหมดอายุ 31/12/2568'),
      _InfoItem(
        icon: _DotIcon.info,
        text: 'ความคุ้มครอง ห้องพักเดี่ยว / OPD / IPD / ค่าผ่าตัด',
      ),
    ],
  ),
];

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  Widget _stagger(int i, int total, Widget child) {
    final start = (i / total) * 0.6;
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
    const items = _samplePlans;

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
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F8F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
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
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, i) => _stagger(
                          i,
                          items.length,
                          _PlanCard(plan: items[i]),
                        ),
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
                title: 'สิทธิการรักษา/ประกัน',
                scrollOffset: offset,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final InsurancePlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.08),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.asset(plan.image, fit: BoxFit.cover),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 100, 16),
                child: Text(
                  plan.title,
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < plan.items.length; i++) ...[
                        _InfoRow(item: plan.items[i]),
                        if (i != plan.items.length - 1)
                          const SizedBox(height: 8),
                      ],
                    ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});
  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _SymbolDot(icon: item.icon),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.text,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0.14,
            ),
          ),
        ),
      ],
    );
  }
}

class _SymbolDot extends StatelessWidget {
  const _SymbolDot({required this.icon});
  final _DotIcon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: CupertinoColors.black.withValues(alpha: 0.75),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: switch (icon) {
        _DotIcon.plus => const Icon(
            CupertinoIcons.add,
            size: 8,
            color: CupertinoColors.white,
          ),
        _DotIcon.letterN => const Text(
            'N',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        _DotIcon.info => const Text(
            'i',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              height: 1,
            ),
          ),
        _DotIcon.briefcase => const Icon(
            CupertinoIcons.briefcase_fill,
            size: 7,
            color: CupertinoColors.white,
          ),
        _DotIcon.crossCase => const Icon(
            CupertinoIcons.bandage_fill,
            size: 7,
            color: CupertinoColors.white,
          ),
        _DotIcon.calendar => const Icon(
            CupertinoIcons.calendar,
            size: 7,
            color: CupertinoColors.white,
          ),
      },
    );
  }
}
