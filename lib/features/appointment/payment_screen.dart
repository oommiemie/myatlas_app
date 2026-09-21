import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/press_effect.dart';
import '../health/widgets/health_detail_app_bar.dart';
import '../me/profile_screen.dart' show ProfileAvatarImage;

/// หน้าชำระค่าบริการจากโรงพยาบาล (Figma 1523:9650)
/// หัวไล่สีเขียวอ่อน แล้วมีแผ่นใบเสร็จซ้อนขึ้นมา ภายในมี QR สำหรับชำระเงิน
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.receiptAt,
    this.patientName = 'นายณัฐพงษ์ ทดสอบทดสอบ',
    this.patientId = '1101XXXXX6871',
    this.hospitalName = 'โรงพยาบาลทดสอบทดสอบ',
    this.hospitalId = '1101XXXXX6871',
    this.hospitalLogoUrl,
    this.coverage = 'UC (ไม่จ่าย 30 บ.) ในเครือข่าย',
    this.serviceCode = 'PG0060001',
    this.totalBaht = 10000,
    this.coveredBaht = 50,
    this.payableBaht = 9950,
  });

  final DateTime? receiptAt;
  final String patientName;
  final String patientId;
  final String hospitalName;
  final String hospitalId;

  /// โลโก้โรงพยาบาลจากระบบ ถ้ายังไม่มีจะใช้ภาพโรงพยาบาลมาตรฐานแทน
  final String? hospitalLogoUrl;
  final String coverage;
  final String serviceCode;
  final int totalBaht;
  final int coveredBaht;
  final int payableBaht;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  /// แถวโรงพยาบาลพับเก็บได้ ปุ่มลูกศรอยู่ระหว่างสองแถว
  bool _expanded = true;

  /// ระยะเลื่อนของเนื้อหา ใช้ให้แถบหัวค่อย ๆ เบลอเหมือนหน้าอื่น
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

  @override
  void dispose() {
    _scrollOffset.dispose();
    super.dispose();
  }

  static const _thMonths = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  String get _receiptLabel {
    final t = widget.receiptAt ?? DateTime(2026, 7, 31, 10, 0, 32);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.day} ${_thMonths[t.month - 1]} ${(t.year + 543) % 100} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)} น.';
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return CupertinoPageScaffold(
      backgroundColor: _bgPrimary,
      child: Stack(
        children: [
          // หัวไล่สีเขียวอ่อน อยู่ชั้นหลังสุด
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 206,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE4F5F0), Color(0xFFF4F8F5)],
                ),
              ),
            ),
          ),
          // แผ่นใบเสร็จอยู่กับที่ เลื่อนได้เฉพาะเนื้อหาข้างใน
          Positioned(
            left: 0,
            right: 0,
            top: top + 68,
            bottom: 0,
            child: _receiptSheet(bottom),
          ),
          // แถบหัวชุดเดียวกับหน้ารายละเอียดอื่นในแอป (เบลอเมื่อเลื่อน)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (_, offset, _) => HealthDetailAppBar(
                title: 'ชำระค่าบริการ',
                scrollOffset: offset,
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// แผ่นใบเสร็จ — มุมบนโค้ง 24 พื้นไล่จากครีมอ่อนไปขาว
  Widget _receiptSheet(double bottom) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFCFFF8), CupertinoColors.white],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // แผ่นอยู่กับที่ เลื่อนได้เฉพาะเนื้อหาข้างใน
      clipBehavior: Clip.antiAlias,
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (n) {
          _scrollOffset.value = n.metrics.pixels;
          return false;
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(0, 16, 0, bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _receiptHeader(),
              const SizedBox(height: 16),
              _partyBand(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _qrCard(),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _saveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// หัวใบเสร็จ — ขีดเขียวด้านซ้าย ชื่อใบเสร็จ และเวลา
  Widget _receiptHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ขีดเขียวหน้าหัวข้อ
          Container(width: 8, height: 47, color: _brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ใบเสร็จชำระเงิน',
                  style: TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _receiptLabel,
                  style: const TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: CupertinoColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// แถบข้อมูลคู่สัญญา — ภาพประกอบเต็มความกว้างอยู่ชั้นหลัง
  /// แล้วไล่จางเป็นสีขาวครึ่งล่าง ตามแบบ (Figma 1523:9658)
  Widget _partyBand() {
    return SizedBox(
      height: 143,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [CupertinoColors.white, Color(0x00FFFFFF)],
                  stops: [0.5, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.3,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      'assets/payment.png',
                      height: 143,
                      fit: BoxFit.cover,
                      alignment: Alignment.topRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(left: 16, right: 16, top: 0, child: _partyRows()),
        ],
      ),
    );
  }

  /// สองแถว: ผู้รับบริการ และโรงพยาบาล พร้อมปุ่มพับ
  Widget _partyRows() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _partyRow(
          widget.patientName,
          widget.patientId,
          avatar: const ProfileAvatarImage(),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: SizedBox(
            height: 32,
            width: 48,
            child: Center(
              child: AnimatedRotation(
                turns: _expanded ? 0 : 0.5,
                duration: const Duration(milliseconds: 200),
                // ลูกศรลงมีขีดใต้ สื่อว่ายุบ/ขยายรายการด้านล่าง
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  size: 20,
                  color: _ink,
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: _expanded
              ? _partyRow(
                  widget.hospitalName,
                  widget.hospitalId,
                  avatar: _hospitalLogo(),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  /// โลโก้โรงพยาบาล — โหลดจาก URL ของระบบ ถ้าโหลดไม่ได้ใช้ภาพสำรอง
  Widget _hospitalLogo() {
    final url = widget.hospitalLogoUrl;
    if (url == null || url.isEmpty) return _hospitalFallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _hospitalFallback(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _hospitalFallback(),
    );
  }

  /// ไม่มีโลโก้ → ไอคอนอาคารโรงพยาบาลที่มีกากบาทบนตัวอาคาร
  Widget _hospitalFallback() => const ColoredBox(
    color: Color(0xFFE4F1EC),
    child: Center(
      child: Icon(Icons.local_hospital_rounded, size: 26, color: _brandPrimary),
    ),
  );

  Widget _partyRow(String name, String id, {Widget? avatar}) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD9D9D9),
          ),
          child: avatar,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  leadingDistribution: TextLeadingDistribution.even,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                id,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontVariations: const [FontVariation('wght', 700)],
                  height: 1.4,
                  letterSpacing: 0.2,
                  color: CupertinoColors.black.withValues(alpha: 0.75),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// การ์ด QR — สิทธิการรักษา รหัสบริการ QR และยอดเงินสามบรรทัด
  Widget _qrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7D7D7), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labeledLine('สิทธิการรักษา', widget.coverage),
          const SizedBox(height: 8),
          _labeledLine('รหัสบริการ', widget.serviceCode),
          const SizedBox(height: 16),
          Center(child: PaymentQrMark(seed: widget.serviceCode)),
          const SizedBox(height: 16),
          _amountRow('ค่าใช้จ่ายทั้งหมด', widget.totalBaht, _ink),
          const SizedBox(height: 4),
          _amountRow(
            'ค่าใช้จ่ายตามสิทธิที่ได้',
            -widget.coveredBaht,
            _amountRed,
          ),
          const SizedBox(height: 4),
          _amountRow('ค่าใช้จ่ายที่ต้องจ่ายเพิ่ม', widget.payableBaht, _ink),
        ],
      ),
    );
  }

  Widget _labeledLine(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontFamily: _fontThai,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.black.withValues(alpha: 0.6),
            ),
          ),
          TextSpan(
            text: ' : $value',
            style: const TextStyle(
              fontFamily: _fontThai,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, int baht, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: _fontThai,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
              leadingDistribution: TextLeadingDistribution.even,
              color: CupertinoColors.black.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _thousands(baht),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontVariations: const [FontVariation('wght', 800)],
                height: 1.3,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                'บาท',
                style: TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _saveButton() {
    // ปุ่มหลักทรงเดียวกับที่ใช้ทั้งแอป: สูง 48 แคปซูล สี primary600
    return PressEffect(
      onTap: () => AppToast.success(context, 'บันทึก QR Code ลงรูปภาพแล้ว'),
      rippleShape: BoxShape.rectangle,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary600,
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Text(
          'บันทึก QR Code',
          style: TextStyle(
            fontFamily: _fontThai,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFCFCFC),
          ),
        ),
      ),
    );
  }
}

const _bgPrimary = Color(0xFFF6F4F1);
const _brandPrimary = AppColors.primary600;
const _ink = AppColors.textPrimary;
const _amountRed = Color(0xFFFF383C);
const _fontThai = 'IBM Plex Sans Thai Looped';

/// ใส่จุลภาคคั่นหลักพัน เช่น 10000 → 10,000
String _thousands(int value) {
  final digits = value.abs().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return value < 0 ? '-$digits' : digits;
}

/// ลาย QR ของใบเสร็จ ใช้ซ้ำได้ทั้งหน้าชำระเงินและการ์ดย่อหน้าแรก
class PaymentQrMark extends StatelessWidget {
  const PaymentQrMark({super.key, required this.seed, this.size = 178});

  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _QrPlaceholder(seed)),
  );
}

/// QR จำลองสำหรับงานดีไซน์ — ลายคงที่ต่อรหัสบริการหนึ่งค่า
/// เมื่อมี payload จริงจากระบบให้สลับไปใช้ไลบรารีสร้าง QR แทน
class _QrPlaceholder extends CustomPainter {
  _QrPlaceholder(this.seed);
  final String seed;

  static const _modules = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _modules;
    final paint = Paint()..color = CupertinoColors.black;
    final rng = math.Random(seed.hashCode);

    bool isFinder(int x, int y) =>
        (x < 7 && y < 7) ||
        (x >= _modules - 7 && y < 7) ||
        (x < 7 && y >= _modules - 7);

    for (var y = 0; y < _modules; y++) {
      for (var x = 0; x < _modules; x++) {
        if (isFinder(x, y)) continue;
        if (rng.nextBool()) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }

    void finder(int ox, int oy) {
      canvas.drawRect(
        Rect.fromLTWH(ox * cell, oy * cell, cell * 7, cell * 7),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, cell * 5, cell * 5),
        Paint()..color = CupertinoColors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, cell * 3, cell * 3),
        paint,
      );
    }

    finder(0, 0);
    finder(_modules - 7, 0);
    finder(0, _modules - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPlaceholder old) => old.seed != seed;
}
