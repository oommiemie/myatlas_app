import 'package:flutter/cupertino.dart';

import '../../core/theme/app_typography.dart';
import '../../core/widgets/press_effect.dart';
import '../health/widgets/health_detail_app_bar.dart';

const _assets = 'assets/images/insurance';

/// พื้นแผ่นเนื้อหา — สีเดียวกับพื้นภาพประกอบ (#FAFAFA) ให้ภาพกลืนไปกับพื้น
const _sheetColor = Color(0xFFFAFAFA);

/// บริษัทประกัน — ข้อมูลและโลโก้ชุดเดียวกับตู้ Kiosk
class Insurer {
  const Insurer({
    required this.name,
    required this.short,
    required this.logo,
    this.cover = false,
  });

  final String name;
  final String short;
  final String logo;

  /// โลโก้พื้นเต็มให้ครอบเต็มวง (cover) — อื่น ๆ วางกลางเว้นขอบ
  final bool cover;
}

const kInsurerMTL = Insurer(
  name: 'บริษัท เมืองไทยประกันชีวิต จำกัด (มหาชน)',
  short: 'MTL',
  logo: '$_assets/ins_logo_a.png',
);
const kInsurerTL = Insurer(
  name: 'บริษัท ไทยประกันชีวิต จำกัด (มหาชน)',
  short: 'TL',
  logo: '$_assets/ins_logo_b.png',
  cover: true,
);
const kInsurerAIA = Insurer(
  name: 'บริษัท เอไอเอ จำกัด',
  short: 'AIA',
  logo: '$_assets/ins_logo_c.png',
);

/// แบบประกันหนึ่งแบบ (ข้อมูลเดียวกับ RecommendedPlans / OtherPlans ของ Kiosk)
class InsurancePlanOffer {
  const InsurancePlanOffer(this.co, this.tag, this.name, this.cov, this.price);

  final Insurer co;
  final String tag;
  final String name;
  final String cov;

  /// เบี้ยเริ่มต้น บาท/ปี
  final String price;
}

const _forYou = <InsurancePlanOffer>[
  InsurancePlanOffer(
    kInsurerMTL,
    'ประกันสุขภาพ',
    'Health Plus',
    'ค่ารักษาผู้ป่วยใน สูงสุด 500,000 บาท/ปี',
    '12,000',
  ),
  InsurancePlanOffer(
    kInsurerTL,
    'ประกันสุขภาพ',
    'Health Care Lite',
    'ค่ารักษาผู้ป่วยใน สูงสุด 200,000 บาท/ปี',
    '6,500',
  ),
  InsurancePlanOffer(
    kInsurerAIA,
    'ประกันชีวิต',
    'Life Protect 20',
    'ทุนประกัน 1,000,000 บาท ระยะ 20 ปี',
    '18,000',
  ),
];

const _others = <InsurancePlanOffer>[
  InsurancePlanOffer(
    kInsurerTL,
    'ประกันสุขภาพ',
    'Cancer Care',
    'คุ้มครองโรคมะเร็งทุกระยะ สูงสุด 1,000,000 บาท',
    '3,200',
  ),
  InsurancePlanOffer(
    kInsurerAIA,
    'ประกันอุบัติเหตุ',
    'Accident Shield',
    'ค่ารักษาจากอุบัติเหตุ สูงสุด 100,000 บาท/ครั้ง',
    '1,800',
  ),
  InsurancePlanOffer(
    kInsurerMTL,
    'ประกันโรคร้ายแรง',
    'Critical Illness 30',
    'จ่ายเงินก้อนเมื่อตรวจพบ 30 โรคร้ายแรง',
    '7,400',
  ),
  InsurancePlanOffer(
    kInsurerAIA,
    'ประกันชีวิต',
    'Saving Life 15',
    'ออมทรัพย์พร้อมคุ้มครองชีวิต ระยะ 15 ปี',
    '24,000',
  ),
  InsurancePlanOffer(
    kInsurerMTL,
    'ประกันสุขภาพ',
    'OPD Care',
    'ค่ารักษาผู้ป่วยนอก ครั้งละ 1,500 บาท 30 ครั้ง/ปี',
    '4,900',
  ),
  InsurancePlanOffer(
    kInsurerTL,
    'ประกันสุขภาพ',
    'Senior Health 60+',
    'ค่ารักษาผู้ป่วยใน สูงสุด 300,000 บาท/ปี',
    '21,500',
  ),
  InsurancePlanOffer(
    kInsurerAIA,
    'ประกันชีวิต',
    'Life Care 99',
    'คุ้มครองชีวิตถึงอายุ 99 ปี ทุน 500,000 บาท',
    '15,800',
  ),
  InsurancePlanOffer(
    kInsurerMTL,
    'ประกันสุขภาพ',
    'Family Health',
    'คุ้มครองทั้งครอบครัว สูงสุด 4 คน',
    '28,000',
  ),
];

/// หน้า "ประกันชีวิต" — แพ็กเกจแนะนำสำหรับผู้ใช้ และรายการประกันอื่น ๆ
class LifeInsuranceScreen extends StatefulWidget {
  const LifeInsuranceScreen({super.key});

  @override
  State<LifeInsuranceScreen> createState() => _LifeInsuranceScreenState();
}

class _LifeInsuranceScreenState extends State<LifeInsuranceScreen> {
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void dispose() {
    _scrollOffset.dispose();
    super.dispose();
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
                      color: _sheetColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.depth == 0 &&
                            (n is ScrollUpdateNotification ||
                                n is ScrollStartNotification)) {
                          _scrollOffset.value = n.metrics.pixels;
                        }
                        return false;
                      },
                      child: ListView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.paddingOf(context).bottom + 24,
                        ),
                        children: const [
                          _ForYouSection(),
                          _OthersHeader(),
                          _PlanGrid(items: _others),
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
                title: 'ประกันชีวิต',
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

/// หัวข้อของแต่ละส่วน: ป้ายเล็ก + หัวข้อใหญ่ + คำอธิบาย
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.label,
    required this.title,
    required this.subtitle,
    this.titleGradient,
  });

  final String label;
  final String title;
  final String subtitle;

  /// ไล่สีตัวอักษรหัวข้อจากซ้ายไปขวา — ไม่มีจะใช้สีเข้ม #0E0E0E
  final List<Color>? titleGradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.subheadline(
            const Color(0xCC1A1A1A),
          ).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        _title(),
        const SizedBox(height: 8),
        Text(subtitle, style: AppTypography.footnote(const Color(0x99000000))),
      ],
    );
  }

  Widget _title() {
    final style = AppTypography.title2(const Color(0xFF0E0E0E));
    final gradient = titleGradient;
    if (gradient == null) return Text(title, style: style);
    // ไล่สีด้วย foreground paint ที่ตัวอักษรโดยตรง (bg-clip-text ใน Figma)
    // ไม่ใช้ ShaderMask เพราะวรรณยุกต์ที่ยื่นเหนือบรรทัด เช่น ้ ใน "ทั้ง"
    // อยู่นอกกรอบ mask แล้วไม่ถูกไล่สี
    final painter = TextPainter(
      text: TextSpan(text: title, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final shader = LinearGradient(
      colors: gradient,
    ).createShader(Offset.zero & painter.size);
    painter.dispose();
    // TextStyle ห้ามมีทั้ง color และ foreground — สร้างใหม่โดยไม่ใส่ color
    return Text(
      title,
      style: TextStyle(
        fontFamily: style.fontFamily,
        fontFamilyFallback: style.fontFamilyFallback,
        fontVariations: style.fontVariations,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
        height: style.height,
        letterSpacing: style.letterSpacing,
        foreground: Paint()..shader = shader,
      ),
    );
  }
}

/// ส่วนบน: "สำหรับคุณ / ประกันทั้งหมด" ภาพตัวแทนประกัน และการ์ดแนะนำ
/// ที่เลื่อนแนวนอนทับภาพอยู่
class _ForYouSection extends StatelessWidget {
  const _ForYouSection();

  /// ขอบบนของภาพ — ต่อจากใต้คำอธิบาย "แพ็กเกจสำหรับคุณ"
  static const double _imageTop = 96;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Figma วางการ์ดใบแรกที่ x = 216 บนจอกว้าง 440 — คงสัดส่วนไว้
    final listLeft = width * 216 / 440;
    final cardWidth = _PlanCard.railWidth(context);
    final cardHeight = _PlanCard.heightOf(context);
    // ตาม Figma 1517-10899: ภาพกว้าง 260/440 ของจอ วางซ้ายใต้หัวข้อ
    // และลอดใต้การ์ดใบแรก ขอบล่างของภาพ เฟด และการ์ดตรงกันพอดี
    // ตาม Figma: กว้าง 260/440 ของจอ
    final imageWidth = width * 260 / 440 - 8;
    final imageHeight = imageWidth * 183 / 260;
    final cardBottom = _imageTop + imageHeight;
    // การ์ดอยู่กึ่งกลางแนวตั้งของทั้งส่วน (ความสูงส่วน = cardBottom + 16)
    final cardTop = (cardBottom + 16 - cardHeight) / 2;
    // เฟดเริ่มต่ำกว่าขอบบนภาพ 40/183 ของความสูงภาพ
    final fadeTop = _imageTop + imageHeight * 40 / 183;

    return SizedBox(
      height: cardBottom + 16,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: -2,
            top: _imageTop,
            width: imageWidth,
            height: imageHeight,
            child: Image.asset('$_assets/agent.jpg', fit: BoxFit.cover),
          ),
          Positioned(
            left: -2,
            right: 0,
            top: fadeTop,
            height: cardBottom - fadeTop,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FAFAFA), _sheetColor],
                  stops: [0.36, 0.88],
                ),
              ),
            ),
          ),
          // พื้นขาวใต้การ์ดต่อจากเฟด เพื่อไม่ให้เห็นขอบภาพด้านล่าง
          Positioned(
            left: 0,
            right: 0,
            top: cardBottom,
            bottom: 0,
            child: const ColoredBox(color: _sheetColor),
          ),
          const Positioned(
            left: 16,
            top: 16,
            child: _SectionTitle(
              label: 'สำหรับคุณ',
              title: 'ประกันทั้งหมด',
              titleGradient: [Color(0xFF004AB5), Color(0xFF00ACB3)],
              subtitle: 'แพ็กเกจสำหรับคุณ',
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            // เผื่อพื้นที่บน-ล่างให้เงาการ์ดไม่ถูกตัด
            top: cardTop - 8,
            height: cardHeight + 24,
            // การ์ดที่เลื่อนไปทางซ้ายจะจางหายก่อนถึงหัวข้อ ไม่ทับข้อความ
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => LinearGradient(
                colors: const [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                stops: [
                  ((listLeft - 32) / rect.width).clamp(0.0, 1.0),
                  ((listLeft - 4) / rect.width).clamp(0.0, 1.0),
                ],
              ).createShader(rect),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(listLeft, 8, 16, 16),
                itemCount: _forYou.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, i) => SizedBox(
                  width: cardWidth,
                  child: _PlanCard(plan: _forYou[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// หัวข้อส่วนล่าง "ทั้งหมด / รายการอื่นๆ" พร้อมภาพครอบครัวทางขวา
class _OthersHeader extends StatelessWidget {
  const _OthersHeader();

  /// ความกว้างภาพครอบครัว — คนในภาพนี้วาดเล็กกว่าภาพตัวแทนประกันด้านบน
  /// ~1.25 เท่า (วัดขนาดหัวบนจอจริง) จึงกว้างกว่าภาพบน 1.25 เท่า
  /// ให้คนในสองภาพขนาดเท่ากัน
  static double imageWidthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width * 260 / 440 * 1.25 - 8;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        // ภาพล้นลงไปถึงขอบบนของการ์ดแถวแรก (ระยะ 12 ของ _PlanGrid)
        clipBehavior: Clip.none,
        children: [
          // ภาพจบที่ขอบล่างของส่วนพอดี และจางเป็นโปร่งใสด้วย mask ของตัวภาพเอง
          // (ไม่ใช้แผ่นเฟดทับ ซึ่งทำให้เห็นรอยตัดของภาพที่ขอบล่าง)
          Positioned(
            right: -60,
            top: -20,
            width: imageWidthOf(context),
            height: 132,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
                stops: [0.55, 1.0],
              ).createShader(rect),
              child: Image.asset(
                '$_assets/family.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          const Positioned(
            left: 16,
            top: 16,
            child: _SectionTitle(
              label: 'ทั้งหมด',
              title: 'รายการอื่นๆ',
              subtitle: 'เลือกซื้อประกันที่คุณสนใจ',
            ),
          ),
        ],
      ),
    );
  }
}

/// ตารางการ์ดประกัน 2 คอลัมน์
class _PlanGrid extends StatelessWidget {
  const _PlanGrid({required this.items});
  final List<InsurancePlanOffer> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _PlanCard(plan: items[i])),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < items.length
                      ? _PlanCard(plan: items[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// การ์ดแบบประกัน — พอร์ตจาก PlanCard ของตู้ Kiosk (Parts.kt / insurance.html)
/// ผิวไข่มุก ขอบทองไล่จางจากมุมซ้ายบน โลโก้ในวงกลมขาว ป้ายประเภทสีทอง
/// ย่อสัดส่วนจากการ์ดตู้ 348 px ลงครึ่งหนึ่งให้พอดีจอมือถือ
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final InsurancePlanOffer plan;

  /// ความกว้างการ์ดในแถวเลื่อนแนวนอน — ราว 42% ของจอ ให้เห็นใบถัดไปโผล่มา
  static double railWidth(BuildContext context) =>
      (MediaQuery.sizeOf(context).width * 0.42).clamp(148.0, 200.0);

  /// ความสูงพอดีเนื้อหา (โลโก้ ชื่อ คำอธิบาย 2 บรรทัด เบี้ย) และขยายตาม
  /// ขนาดตัวอักษรที่ผู้ใช้ตั้งไว้
  static double heightOf(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(152);
  static const double _radius = 16;

  static const _ink = Color(0xFF14265A);
  static const _inkMuted = Color(0xFF5B6B8A);
  static const _inkSoft = Color(0xFF8494AE);
  static const _goldText = Color(0xFF8A6420);
  static const _goldTint = Color(0x1FBF913A);

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: () {},
      child: Container(
        height: heightOf(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          gradient: const LinearGradient(
            // linear-gradient(176deg, …) ของตู้ — เกือบบนลงล่าง เอียงเล็กน้อย
            begin: Alignment(-0.07, -1),
            end: Alignment(0.07, 1),
            colors: [Color(0xFFFFFFFF), Color(0xFFFDFCFA), Color(0xFFF8F5EF)],
            stops: [0, 0.52, 1],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A14265A),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            BoxShadow(
              color: Color(0x0F14265A),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        foregroundDecoration: const GoldRingDecoration(radius: _radius),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InsurerLogo(co: plan.co, size: 36, inset: 5),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _goldTint,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    plan.tag,
                    style: const TextStyle(
                      color: _goldText,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontVariations: [FontVariation('wght', 700)],
                height: 1.25,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              plan.cov,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _inkMuted,
                fontSize: 11,
                // ตัวเลข (Nunito แบบ variable) หนาขึ้น — ตัวอักษรไทยไม่เปลี่ยน
                fontVariations: [FontVariation('wght', 700)],
                height: 1.4,
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  'เบี้ยเริ่มต้น',
                  style: TextStyle(color: _inkSoft, fontSize: 10),
                ),
                const SizedBox(width: 4),
                Text(
                  plan.price,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontVariations: [FontVariation('wght', 800)],
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'บาท/ปี',
                  style: TextStyle(color: _inkSoft, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// โลโก้บริษัทในวงกลมขาว + วงแหวนทอง (InsurerLogo / creamDisc ของตู้)
class InsurerLogo extends StatelessWidget {
  const InsurerLogo({
    super.key,
    required this.co,
    required this.size,
    required this.inset,
  });

  final Insurer co;
  final double size;
  final double inset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          // วงแหวนทอง 1.5 px + รัศมีเรืองจาง 7 px รอบวง
          BoxShadow(color: Color(0x6BBF913A), spreadRadius: 1),
          BoxShadow(color: Color(0x0FBF913A), spreadRadius: 4),
          BoxShadow(
            color: Color(0x1F785C1E),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: co.cover
          ? Image.asset(co.logo, width: size, height: size, fit: BoxFit.cover)
          : Image.asset(
              co.logo,
              width: size - inset * 2,
              height: size - inset * 2,
              fit: BoxFit.contain,
            ),
    );
  }
}

/// ขอบทองไล่สีแบบการ์ดตู้: เข้มสุดที่มุมซ้ายบน จางลงจนแทบหายที่มุมขวาล่าง
/// พร้อมแถบแสงสะท้อนสองแถบใกล้มุม และเรืองจาง ๆ รอบขอบ
class GoldRingDecoration extends Decoration {
  const GoldRingDecoration({required this.radius});
  final double radius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      GoldRingPainter(radius);
}

class GoldRingPainter extends BoxPainter {
  GoldRingPainter(this.radius);
  final double radius;

  static const _ring = Color(0xFFD9A546);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final size = cfg.size;
    if (size == null) return;
    const stroke = 1.5;
    final rect = offset & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(stroke / 2),
      Radius.circular(radius - stroke / 2),
    );
    // จุดศูนย์กลางไล่สี (14,14) ของตู้ ย่อครึ่งเป็น (7,7)
    final c = rect.topLeft + const Offset(7, 7);
    final far = (rect.bottomRight - c).distance;

    final ring = RadialGradient(
      center: Alignment(
        (c.dx - rect.center.dx) / (rect.width / 2),
        (c.dy - rect.center.dy) / (rect.height / 2),
      ),
      radius: far / rect.shortestSide,
      colors: [
        Color.lerp(_ring, CupertinoColors.white, 0.12)!,
        _ring,
        _ring.withValues(alpha: 0.55),
        _ring.withValues(alpha: 0.2),
        _ring.withValues(alpha: 0.08),
        _ring.withValues(alpha: 0.02),
      ],
      stops: const [0, 0.0625, 0.196, 0.446, 0.714, 1],
    );
    final gloss = RadialGradient(
      center: ring.center,
      radius: ring.radius,
      colors: const [
        Color(0x8CFFFFFF),
        Color(0x00FFFFFF),
        Color(0x00FFFFFF),
        Color(0xF2FFFAEB),
        Color(0x00FFFFFF),
        Color(0x00FFFFFF),
        Color(0x8CFFFAEB),
        Color(0x00FFFFFF),
        Color(0x00FFFFFF),
      ],
      stops: const [0, 0.03, 0.06, 0.10, 0.17, 0.24, 0.30, 0.38, 1],
    );

    // เรืองจาง ๆ (drop-shadow 0 0 2px สีขอบ .45)
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = ring.createShader(rect)
        ..color = const Color(0x73FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = ring.createShader(rect),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = gloss.createShader(rect),
    );
  }
}
