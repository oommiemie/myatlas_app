import 'package:flutter/cupertino.dart';

import '../health/widgets/health_detail_app_bar.dart';

enum ChronicStatus { treating, watching, controlled }

extension _ChronicStatusTheme on ChronicStatus {
  String get label => switch (this) {
        ChronicStatus.treating => 'กำลังรักษา',
        ChronicStatus.watching => 'เฝ้าระวัง',
        ChronicStatus.controlled => 'ควบคุมได้',
      };
  Color get color => switch (this) {
        ChronicStatus.treating => const Color(0xFF17C964),
        ChronicStatus.watching => const Color(0xFFEA580C),
        ChronicStatus.controlled => const Color(0xFFEAB308),
      };
}

class ChronicDisease {
  const ChronicDisease({
    required this.name,
    required this.status,
    required this.date,
    required this.doctor,
    required this.note,
  });
  final String name;
  final ChronicStatus status;
  final String date;
  final String doctor;
  final String note;
}

const _sampleDiseases = <ChronicDisease>[
  ChronicDisease(
    name: 'เบาหวาน (Diabetes Mellitus)',
    status: ChronicStatus.treating,
    date: '12/03/2564',
    doctor: 'นพ.สมชาย ใจดี',
    note: 'ควบคุมระดับน้ำตาลด้วยยาและอาหาร',
  ),
  ChronicDisease(
    name: 'โรคหัวใจ (Heart Disease)',
    status: ChronicStatus.watching,
    date: '05/08/2563',
    doctor: 'นพ.วิชัย สุขใจ',
    note: 'มีประวัติหลอดเลือดหัวใจตีบเล็กน้อย',
  ),
  ChronicDisease(
    name: 'ความดันโลหิตสูง',
    status: ChronicStatus.controlled,
    date: '20/01/2562',
    doctor: 'พญ.กานต์ชนก ดีงาม',
    note: 'รับประทานยาต่อเนื่อง ความดันอยู่ในเกณฑ์',
  ),
];

class ChronicDiseaseScreen extends StatefulWidget {
  const ChronicDiseaseScreen({super.key});

  @override
  State<ChronicDiseaseScreen> createState() => _ChronicDiseaseScreenState();
}

class _ChronicDiseaseScreenState extends State<ChronicDiseaseScreen>
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
    final items = _sampleDiseases;

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
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) => _stagger(
                          i,
                          items.length,
                          _DiseaseCard(disease: items[i]),
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
                title: 'โรคประจำตัว',
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

class _DiseaseCard extends StatelessWidget {
  const _DiseaseCard({required this.disease});
  final ChronicDisease disease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    disease.name,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusPill(status: disease.status),
              ],
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
                  _InfoRow(
                    icon: CupertinoIcons.calendar,
                    text: disease.date,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: CupertinoIcons.heart_circle_fill,
                    text: disease.doctor,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: CupertinoIcons.info_circle_fill,
                    text: disease.note,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              height: 1.4,
              letterSpacing: 0.14,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final ChronicStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.1),
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
    );
  }
}
