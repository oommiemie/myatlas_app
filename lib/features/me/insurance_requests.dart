import 'package:flutter/cupertino.dart';

import '../health/widgets/health_detail_app_bar.dart';
import 'life_insurance_screen.dart';

/// สถานะคำขอประกันที่ส่งจากตู้บริการ — ตรงกับสถานะบนตู้ Kiosk
enum InsuranceRequestStatus {
  /// บริษัทได้รับข้อมูลแล้ว รอพิจารณา
  received,

  /// ส่งนานกว่าปกติ ตู้บอกว่า "ไม่ต้องรอที่ตู้ ระบบจะแจ้งผลผ่านแอป"
  processing,

  /// บริษัทแจ้งผลพิจารณาแล้ว
  result,
}

/// เก็บรายการไว้ในแอปกี่วันนับจากวันแจ้งผล (หรือวันส่ง ถ้ายังไม่แจ้งผล)
/// พ้นจากนี้รายการจะหายไปเอง — ค่าสมมติ รอฝ่ายกฎหมาย/BMS ยืนยันตาม PDPA
const kRequestRetentionDays = 90;

/// คำขอหนึ่งรายการที่ผู้ใช้ยินยอมส่งข้อมูลจากตู้บริการ
class InsuranceRequest {
  const InsuranceRequest({
    required this.ref,
    required this.plan,
    required this.sentAt,
    required this.kiosk,
    required this.status,
    this.resultAt,
    this.resultNote,
    this.offerPrice,
  });

  final String ref;
  final InsurancePlanOffer plan;
  final DateTime sentAt;
  final String kiosk;
  final InsuranceRequestStatus status;

  /// วันที่บริษัทแจ้งผล (มีเมื่อ status = result)
  final DateTime? resultAt;

  /// คำแนะนำจากบริษัท (มีเมื่อแจ้งผลแล้ว)
  final String? resultNote;

  /// เบี้ยที่บริษัทเสนอเบื้องต้น บาท/ปี
  final String? offerPrice;

  /// ยังอยู่ในระยะเก็บหรือไม่ — พ้นแล้วไม่แสดงในแอป
  bool isRetained(DateTime now) =>
      now.difference(resultAt ?? sentAt).inDays <= kRequestRetentionDays;
}

const _thaiMonths = [
  'ม.ค.',
  'ก.พ.',
  'มี.ค.',
  'เม.ย.',
  'พ.ค.',
  'มิ.ย.',
  'ก.ค.',
  'ส.ค.',
  'ก.ย.',
  'ต.ค.',
  'พ.ย.',
  'ธ.ค.',
];

/// "1 ต.ค. 69" หรือ "1 ต.ค. 69 · 09:12 น." เมื่อ [withTime]
String thaiShortDate(DateTime d, {bool withTime = false}) {
  final date = '${d.day} ${_thaiMonths[d.month - 1]} ${(d.year + 543) % 100}';
  if (!withTime) return date;
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$date · $hh:$mm น.';
}

/// ข้อมูลจำลอง — วันที่อิงจากวันนี้ ให้เห็นครบทุกสถานะเสมอ
/// TODO(integration): รับจากระบบกลาง BMS ที่ตู้ส่งผลมา
List<InsuranceRequest> mockInsuranceRequests([DateTime? today]) {
  final now = today ?? DateTime.now();
  DateTime ago(int days, int h, int m) =>
      DateTime(now.year, now.month, now.day - days, h, m);
  const kiosk = 'ตู้บริการ โรงพยาบาลบ้านลาด';
  return [
    // ส่งนาน — ยังไม่ได้ผล
    InsuranceRequest(
      ref: 'INS-2569-000131',
      plan: const InsurancePlanOffer(
        kInsurerAIA,
        'ประกันชีวิต',
        'Life Protect 20',
        'ทุนประกัน 1,000,000 บาท ระยะ 20 ปี',
        '18,000',
      ),
      sentAt: ago(0, 9, 12),
      kiosk: kiosk,
      status: InsuranceRequestStatus.processing,
    ),
    // แจ้งผลวันนี้
    InsuranceRequest(
      ref: 'INS-2569-000123',
      plan: const InsurancePlanOffer(
        kInsurerMTL,
        'ประกันสุขภาพ',
        'Health Plus',
        'ค่ารักษาผู้ป่วยใน สูงสุด 500,000 บาท/ปี',
        '12,000',
      ),
      sentAt: ago(2, 10, 24),
      resultAt: ago(0, 10, 30),
      kiosk: kiosk,
      status: InsuranceRequestStatus.result,
      resultNote:
          'แบบประกันนี้เหมาะกับข้อมูลสุขภาพของคุณ '
          'คุ้มครองค่ารักษาผู้ป่วยในตามวงเงินเต็มแผน',
      offerPrice: '11,400',
    ),
    // แจ้งผลเมื่อ 27 วันก่อน
    InsuranceRequest(
      ref: 'INS-2569-000098',
      plan: const InsurancePlanOffer(
        kInsurerTL,
        'ประกันสุขภาพ',
        'Cancer Care',
        'คุ้มครองโรคมะเร็งทุกระยะ สูงสุด 1,000,000 บาท',
        '3,200',
      ),
      sentAt: ago(29, 14, 5),
      resultAt: ago(27, 11, 40),
      kiosk: kiosk,
      status: InsuranceRequestStatus.result,
      resultNote: 'เหมาะกับประวัติสุขภาพของคุณ ไม่มีข้อยกเว้นเพิ่มเติม',
      offerPrice: '3,050',
    ),
    // แจ้งผลเมื่อ 49 วันก่อน — ยังอยู่ในระยะเก็บ
    InsuranceRequest(
      ref: 'INS-2569-000071',
      plan: const InsurancePlanOffer(
        kInsurerMTL,
        'ประกันสุขภาพ',
        'OPD Care',
        'ค่ารักษาผู้ป่วยนอก ครั้งละ 1,500 บาท 30 ครั้ง/ปี',
        '4,900',
      ),
      sentAt: ago(50, 9, 30),
      resultAt: ago(49, 16, 0),
      kiosk: kiosk,
      status: InsuranceRequestStatus.result,
      resultNote: 'เหมาะกับการใช้บริการผู้ป่วยนอกของคุณ',
      offerPrice: '4,700',
    ),
    // พ้นระยะเก็บ 90 วัน — ไม่แสดงในแอป
    InsuranceRequest(
      ref: 'INS-2569-000012',
      plan: const InsurancePlanOffer(
        kInsurerAIA,
        'ประกันอุบัติเหตุ',
        'Accident Shield',
        'ค่ารักษาจากอุบัติเหตุ สูงสุด 100,000 บาท/ครั้ง',
        '1,800',
      ),
      sentAt: ago(120, 10, 0),
      resultAt: ago(118, 10, 0),
      kiosk: kiosk,
      status: InsuranceRequestStatus.result,
      offerPrice: '1,750',
    ),
  ];
}

const _ink = Color(0xFF14265A);
const _inkMuted = Color(0xFF5B6B8A);
const _green = Color(0xFF1E9C78);
const _greenDeep = Color(0xFF0F6B51);
const _green050 = Color(0xFFE8F7F2);
const _goldText = Color(0xFF8A6420);
const _goldTint = Color(0x1FBF913A);
const _blueDeep = Color(0xFF0D5BC6);
const _blue050 = Color(0xFFEAF3FD);
const _line = Color(0xFFE5EAF0);

/// ตัวเลขใช้ Nunito แบบ variable — ต้องตั้งแกน wght เองจึงจะหนาตาม
List<FontVariation> _wght(double w) => [FontVariation('wght', w)];

/// การ์ดรายละเอียดคำขอหนึ่งรายการ (ดูอย่างเดียว)
///
/// โลโก้ ชื่อแบบประกัน บริษัท ป้ายสถานะ ขั้นตอน ข้อมูลอ้างอิง และผลพิจารณา
/// การยินยอมทั้งหมดทำที่ตู้บริการ แอปแสดงผลอย่างเดียว
class InsuranceRequestCard extends StatelessWidget {
  const InsuranceRequestCard({super.key, required this.request});

  final InsuranceRequest request;

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InsurerLogo(co: r.plan.co, size: 36, inset: 5),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.plan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontVariations: _wght(700),
                      ),
                    ),
                    Text(
                      r.plan.co.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _inkMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(status: r.status),
            ],
          ),
          ...[
            const SizedBox(height: 16),
            _Steps(status: r.status),
            const SizedBox(height: 16),
            Container(height: 1, color: _line),
            const SizedBox(height: 12),
            _infoRow('ประเภท', r.plan.tag),
            _infoRow('เลขอ้างอิง', r.ref),
            _infoRow('ส่งจาก', r.kiosk),
            _infoRow('วันที่ส่ง', thaiShortDate(r.sentAt, withTime: true)),
            if (r.resultAt != null)
              _infoRow(
                'แจ้งผลเมื่อ',
                thaiShortDate(r.resultAt!, withTime: true),
              ),
            const SizedBox(height: 4),
            if (r.status == InsuranceRequestStatus.result)
              _ResultBox(request: r)
            else
              const Text(
                'ไม่ต้องรอที่ตู้ ระบบจะแจ้งเตือนเมื่อบริษัทแจ้งผล',
                style: TextStyle(color: _inkMuted, fontSize: 12, height: 1.4),
              ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(color: _inkMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontVariations: _wght(700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ป้ายสถานะ — สีเดียวกับ StatusPill ของตู้
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final InsuranceRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (text, bg, fg) = switch (status) {
      InsuranceRequestStatus.received => (
        'บริษัทได้รับแล้ว',
        _blue050,
        _blueDeep,
      ),
      InsuranceRequestStatus.processing => (
        'กำลังดำเนินการ',
        _goldTint,
        _goldText,
      ),
      InsuranceRequestStatus.result => ('แจ้งผลแล้ว', _green050, _greenDeep),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// ขั้นตอน 3 ขั้น: ส่งข้อมูล → บริษัทได้รับ → แจ้งผล
class _Steps extends StatelessWidget {
  const _Steps({required this.status});
  final InsuranceRequestStatus status;

  @override
  Widget build(BuildContext context) {
    // จำนวนขั้นที่เสร็จแล้ว และขั้นที่กำลังรอ (ถ้ามี)
    final done = switch (status) {
      InsuranceRequestStatus.processing => 1,
      InsuranceRequestStatus.received => 2,
      InsuranceRequestStatus.result => 3,
    };
    const labels = ['ส่งข้อมูลแล้ว', 'บริษัทได้รับ', 'แจ้งผล'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(top: 9),
                color: i < done ? _green : _line,
              ),
            ),
          _step(labels[i], i < done, i == done),
        ],
      ],
    );
  }

  Widget _step(String label, bool isDone, bool isCurrent) {
    final color = isDone
        ? _green
        : isCurrent
        ? _goldText
        : const Color(0xFFB8C2D1);
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? _green : CupertinoColors.white,
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(
                  CupertinoIcons.checkmark,
                  size: 12,
                  color: CupertinoColors.white,
                )
              : isCurrent
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDone || isCurrent ? _ink : _inkMuted,
            fontSize: 10,
            fontWeight: isDone || isCurrent ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// กล่องผลพิจารณา — คำแนะนำและเบี้ยที่บริษัทเสนอเบื้องต้น
class _ResultBox extends StatelessWidget {
  const _ResultBox({required this.request});
  final InsuranceRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _green050,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ผลพิจารณาจากบริษัท',
            style: TextStyle(
              color: _greenDeep,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (request.resultNote != null) ...[
            const SizedBox(height: 4),
            Text(
              request.resultNote!,
              style: const TextStyle(color: _ink, fontSize: 12, height: 1.4),
            ),
          ],
          if (request.offerPrice != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  'เบี้ยที่เสนอเบื้องต้น',
                  style: TextStyle(color: _inkMuted, fontSize: 10),
                ),
                const SizedBox(width: 4),
                Text(
                  request.offerPrice!,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontVariations: _wght(800),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'บาท/ปี',
                  style: TextStyle(color: _inkMuted, fontSize: 10),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// หน้ารายละเอียดคำขอหนึ่งรายการ — เปิดจากการแจ้งเตือนประกัน
///
/// คำขอทั้งหมดดูผ่านหน้าแจ้งเตือน (กรองด้วยชิป "ประกัน") ไม่มีหน้ารวมแยก
class InsuranceRequestScreen extends StatelessWidget {
  const InsuranceRequestScreen({super.key, required this.request});

  final InsuranceRequest request;

  /// หาคำขอจากเลขอ้างอิงในการแจ้งเตือน — ไม่พบ (เช่น พ้นระยะเก็บแล้ว) คืน null
  static InsuranceRequest? find(String ref) {
    final now = DateTime.now();
    for (final r in mockInsuranceRequests(now)) {
      if (r.ref == ref && r.isRetained(now)) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                    child: ListView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      children: [InsuranceRequestCard(request: request)],
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
            child: HealthDetailAppBar(
              title: 'รายละเอียดคำขอประกัน',
              scrollOffset: 0,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
