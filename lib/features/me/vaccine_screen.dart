import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../health/widgets/health_detail_app_bar.dart';

class VaccineRecord {
  const VaccineRecord({
    required this.name,
    required this.date,
    required this.doseLabel,
    required this.lotNumber,
    required this.hospital,
  });
  final String name;
  final DateTime date;
  final String doseLabel;
  final String lotNumber;
  final String hospital;
}

const _thMonthsShort = <String>[
  'ม.ค', 'ก.พ', 'มี.ค', 'เม.ย', 'พ.ค', 'มิ.ย',
  'ก.ค', 'ส.ค', 'ก.ย', 'ต.ค', 'พ.ย', 'ธ.ค',
];
const _thMonthsLong = <String>[
  'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
  'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
];

String _formatShortMonth(DateTime d) => _thMonthsShort[d.month - 1];
String _formatLongMonth(DateTime d) =>
    '${_thMonthsLong[d.month - 1]} ${(d.year + 543) % 100}';

final List<VaccineRecord> _sampleVaccines = [
  VaccineRecord(
    name: 'COVID-19 (Pfizer)',
    date: DateTime(2024, 3, 15),
    doseLabel: 'เข็มที่ 3 (Booster)',
    lotNumber: 'หมายเลขล็อต PF-458921',
    hospital: 'โรงพยาบาลเวชศาสตร์เขตเมือง',
  ),
  VaccineRecord(
    name: 'วัคซีนไข้หวัดใหญ่ (Influenza)',
    date: DateTime(2024, 2, 10),
    doseLabel: 'ประจำปี',
    lotNumber: 'หมายเลขล็อต FLU-778899',
    hospital: 'คลินิกสุขภาพ',
  ),
  VaccineRecord(
    name: 'วัคซีนบาดทะยัก (Tetanus)',
    date: DateTime(2024, 1, 20),
    doseLabel: 'Booster',
    lotNumber: 'หมายเลขล็อต TT-445566',
    hospital: 'โรงพยาบาลชุมชน',
  ),
  VaccineRecord(
    name: 'COVID-19 (Moderna)',
    date: DateTime(2024, 1, 1),
    doseLabel: 'เข็มที่ 3',
    lotNumber: 'หมายเลขล็อต MD-32091394',
    hospital: 'โรงพยาบาลเอสวีไลฟ์',
  ),
];

class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen>
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
    final items = [..._sampleVaccines]
      ..sort((a, b) => b.date.compareTo(a.date));
    final groups = <String, List<VaccineRecord>>{};
    for (final v in items) {
      final key = _formatLongMonth(v.date);
      groups.putIfAbsent(key, () => []).add(v);
    }

    int flatIndex = 0;
    final total = items.length;

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
                      child: ListView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        children: [
                          for (final group in groups.entries) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(4, 4, 0, 8),
                              child: Text(
                                group.key,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            for (int i = 0; i < group.value.length; i++) ...[
                              _stagger(
                                flatIndex++,
                                total,
                                _VaccineRow(
                                  record: group.value[i],
                                  isLast: i == group.value.length - 1,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ],
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
                title: 'ประวัติการฉีดวัคซีน',
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

class _VaccineRow extends StatelessWidget {
  const _VaccineRow({required this.record, required this.isLast});
  final VaccineRecord record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatShortMonth(record.date),
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.23,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.date.day}',
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.23,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFE5E5E5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: _VaccineCard(record: record),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccineCard extends StatelessWidget {
  const _VaccineCard({required this.record});
  final VaccineRecord record;

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
            top: -14,
            right: -14,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.55,
                child: Opacity(
                  opacity: 0.28,
                  child: SvgPicture.asset(
                    'assets/images/me/syringe.svg',
                    width: 92,
                    height: 92,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF3B82F6),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  record.name,
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
                      _InfoRow(
                        leading: const _SymbolDot.syringe(),
                        text: record.doseLabel,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        leading: const _SymbolDot.letter('L'),
                        text: record.lotNumber,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        leading: const _SymbolDot.plus(),
                        text: record.hospital,
                      ),
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
  const _InfoRow({required this.leading, required this.text});
  final Widget leading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
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

enum _SymbolKind { syringe, letter, plus }

class _SymbolDot extends StatelessWidget {
  const _SymbolDot.syringe()
      : kind = _SymbolKind.syringe,
        letter = null;
  const _SymbolDot.letter(String l)
      : kind = _SymbolKind.letter,
        letter = l;
  const _SymbolDot.plus()
      : kind = _SymbolKind.plus,
        letter = null;

  final _SymbolKind kind;
  final String? letter;

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
      child: switch (kind) {
        _SymbolKind.syringe => SvgPicture.asset(
            'assets/images/me/syringe.svg',
            width: 6.5,
            height: 6.5,
            colorFilter: const ColorFilter.mode(
              CupertinoColors.white,
              BlendMode.srcIn,
            ),
          ),
        _SymbolKind.letter => Text(
            letter!,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        _SymbolKind.plus => const Icon(
            CupertinoIcons.add,
            size: 8,
            color: CupertinoColors.white,
          ),
      },
    );
  }
}
