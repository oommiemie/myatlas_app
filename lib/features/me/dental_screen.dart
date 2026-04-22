import 'package:flutter/cupertino.dart';

import '../../core/widgets/liquid_glass_button.dart';

enum DentalType { cleaning, filling, extraction, checkup, rootcanal, orthodontic }

extension _DentalTypeTheme on DentalType {
  String get label => switch (this) {
        DentalType.cleaning => 'ขูดหินปูน',
        DentalType.filling => 'อุดฟัน',
        DentalType.extraction => 'ถอนฟัน',
        DentalType.checkup => 'ตรวจสุขภาพช่องปาก',
        DentalType.rootcanal => 'รักษารากฟัน',
        DentalType.orthodontic => 'จัดฟัน',
      };
}

class DentalRecord {
  const DentalRecord({
    required this.type,
    required this.date,
    required this.dentist,
    required this.clinic,
    required this.toothPosition,
    required this.note,
  });
  final DentalType type;
  final DateTime date;
  final String dentist;
  final String clinic;
  final String toothPosition;
  final String note;
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

final List<DentalRecord> _sampleDentals = [
  DentalRecord(
    type: DentalType.cleaning,
    date: DateTime(2026, 3, 15),
    dentist: 'ทพ.สมชาย รักษ์ฟัน',
    clinic: 'โรงพยาบาลทันตกรรม',
    toothPosition: 'ทุกซี่',
    note: 'สุขภาพเหงือกดี แนะนำขูดหินปูนทุก 6 เดือน',
  ),
  DentalRecord(
    type: DentalType.filling,
    date: DateTime(2026, 2, 20),
    dentist: 'ทพญ.วรรณา สดใส',
    clinic: 'คลินิกทันตกรรมรอยยิ้ม',
    toothPosition: 'ฟันกรามล่างขวา (ซี่ที่ 46)',
    note: 'อุดฟันผุด้วยวัสดุสีเหมือนฟัน คำแนะนำเลี่ยงเคี้ยวด้านขวา 24 ชม.',
  ),
  DentalRecord(
    type: DentalType.rootcanal,
    date: DateTime(2026, 1, 28),
    dentist: 'ทพ.ณัฐพงษ์ ใจดี',
    clinic: 'โรงพยาบาลสมาร์ทเฮลธ์',
    toothPosition: 'ฟันหน้าบนซ้าย (ซี่ที่ 21)',
    note: 'รักษารากฟันครั้งที่ 2 นัดตรวจติดตาม 1 เดือน',
  ),
  DentalRecord(
    type: DentalType.extraction,
    date: DateTime(2025, 12, 10),
    dentist: 'ทพ.สมศักดิ์ มั่นคง',
    clinic: 'โรงพยาบาลชุมชน',
    toothPosition: 'ฟันคุดล่างขวา',
    note: 'ถอนฟันคุดแบบผ่าตัด หลังทำเย็บแผล 3 เข็ม',
  ),
  DentalRecord(
    type: DentalType.checkup,
    date: DateTime(2025, 12, 5),
    dentist: 'ทพญ.ปิยะดา ทองดี',
    clinic: 'คลินิกทันตกรรม',
    toothPosition: 'ตรวจทั่วไป',
    note: 'ตรวจสุขภาพฟันประจำปี ไม่พบความผิดปกติ',
  ),
];

class DentalScreen extends StatefulWidget {
  const DentalScreen({super.key});

  @override
  State<DentalScreen> createState() => _DentalScreenState();
}

class _DentalScreenState extends State<DentalScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

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
    final items = [..._sampleDentals]
      ..sort((a, b) => b.date.compareTo(a.date));
    final groups = <String, List<DentalRecord>>{};
    for (final r in items) {
      final key = _formatLongMonth(r.date);
      groups.putIfAbsent(key, () => []).add(r);
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
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF38BDF8), Color(0xFF0369A1)],
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      LiquidGlassButton(
                        icon: CupertinoIcons.chevron_back,
                        iconColor: const Color(0xFF1A1A1A),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ประวัติทันตกรรม',
                        style: TextStyle(
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
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F8F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    children: [
                      for (final group in groups.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 0, 8),
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
                            _DentalRow(
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
            ],
          ),
        ],
      ),
    );
  }
}

class _DentalRow extends StatelessWidget {
  const _DentalRow({required this.record, required this.isLast});
  final DentalRecord record;
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
                        fontSize: 9,
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
              child: _DentalCard(record: record),
            ),
          ),
        ],
      ),
    );
  }
}

class _DentalCard extends StatelessWidget {
  const _DentalCard({required this.record});
  final DentalRecord record;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              record.type.label,
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
                        icon: CupertinoIcons.person_fill,
                        text: record.dentist,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: CupertinoIcons.building_2_fill,
                        text: record.clinic,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: CupertinoIcons.location_solid,
                        text: record.toothPosition,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: CupertinoIcons.info_circle_fill,
                        text: record.note,
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
