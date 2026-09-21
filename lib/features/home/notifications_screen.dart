import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../core/theme/app_colors.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';
import '../appointment/appointment_screen.dart';
import '../appointment/payment_screen.dart';
import '../health/data/health_data.dart';
import '../nutrition/nutrition_detail_screen.dart';

/// ประเภทการแจ้งเตือน ใช้ทั้งกรองด้วยชิปด้านบนและเลือกสี/ไอคอนของการ์ด
enum NotificationKind { medicine, meal, appointment, call, payment }

/// รายการย่อยใต้เนื้อหา เช่น ชื่อแพทย์ โรงพยาบาล หรือเหตุผลของนัด
class NotificationDetail {
  const NotificationDetail(this.icon, this.text);
  final IconData icon;
  final String text;
}

class NotificationItem {
  const NotificationItem({
    required this.kind,
    required this.timeLabel,
    required this.message,
    this.unread = false,
    this.tags = const [],
    this.details = const [],
    this.avatarAsset,
    this.callerName,
    this.callLabel,
  });

  final NotificationKind kind;
  final String timeLabel;
  final String message;
  final bool unread;

  /// ชิปรายการยา (แจ้งเตือนทานยา)
  final List<String> tags;

  /// บรรทัดข้อมูลเพิ่มเติมใต้ข้อความ (แจ้งเตือนนัด)
  final List<NotificationDetail> details;

  /// การ์ดแจ้งเตือนการโทร — รูปผู้โทรและข้อความสถานะ
  final String? avatarAsset;
  final String? callerName;
  final String? callLabel;
}

/// หน้ารวมการแจ้งเตือน (Figma 209:18527)
/// หัวไล่สีเขียวอ่อน + ชิปกรองประเภท แล้วตามด้วยการ์ดแจ้งเตือน
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.items});

  final List<NotificationItem>? items;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// null = ทั้งหมด
  NotificationKind? _filter;

  List<NotificationItem> get _items => widget.items ?? kMockNotifications;

  List<NotificationItem> get _visible => _filter == null
      ? _items
      : _items.where((n) => n.kind == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.bgPrimary,
      child: Column(
        children: [
          // หัวหน้า — ไล่เขียวอ่อนจางหายไปกับพื้น
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, top + 8, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x3393D7C4), Color(0x00FFFFFF)],
              ),
            ),
            child: Row(
              children: [
                LiquidGlassButton(
                  icon: CupertinoIcons.chevron_back,
                  onTap: () => Navigator.of(context).maybePop(),
                  size: 44,
                  iconSize: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'การแจ้งเตือน',
                  style: TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // ชิปกรองประเภท
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip(null, CupertinoIcons.bell_fill, 'ทั้งหมด'),
                const SizedBox(width: 10),
                _filterChip(
                  NotificationKind.medicine,
                  Icons.medication_rounded,
                  'ยา',
                ),
                const SizedBox(width: 10),
                _filterChip(
                  NotificationKind.meal,
                  Icons.restaurant_rounded,
                  'มื้ออาหาร',
                ),
                const SizedBox(width: 10),
                _filterChip(
                  NotificationKind.appointment,
                  CupertinoIcons.calendar,
                  'นัดหมาย',
                ),
                const SizedBox(width: 10),
                _filterChip(
                  NotificationKind.call,
                  CupertinoIcons.phone_fill,
                  'การโทร',
                ),
                const SizedBox(width: 10),
                _filterChip(
                  NotificationKind.payment,
                  Icons.receipt_long_rounded,
                  'ค่าบริการ',
                ),
              ],
            ),
          ),
          Expanded(
            child: _visible.isEmpty
                ? _emptyState()
                : ListView.separated(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 24),
                    itemCount: _visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _card(_visible[i]),
                  ),
          ),
        ],
      ),
    );
  }

  /// ชิปกรอง — ตัวที่เลือกกางออกโชว์ชื่อหมวด ตัวอื่นย่อเหลือเฉพาะไอคอน
  Widget _filterChip(NotificationKind? kind, IconData icon, String label) {
    final selected = _filter == kind;
    return PressEffect(
      onTap: () => setState(() => _filter = kind),
      rippleShape: BoxShape.rectangle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? _linkBlue
              : CupertinoColors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected
                  ? CupertinoColors.white
                  : AppColors.textPrimary.withValues(alpha: 0.7),
            ),
            // ชื่อหมวดค่อย ๆ กางออกเฉพาะชิปที่เลือก
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: _fontThai,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CupertinoIcons.bell_slash,
          size: 32,
          color: AppColors.textPrimary.withValues(alpha: 0.25),
        ),
        const SizedBox(height: 10),
        Text(
          'ยังไม่มีการแจ้งเตือนประเภทนี้',
          style: TextStyle(
            fontFamily: _fontThai,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
  );

  /// เปิดหน้าที่เกี่ยวข้องกับการแจ้งเตือนใบนั้น
  ///
  /// ปลายทางที่เป็นแท็บใน tab bar (ยา, ครอบครัว) จะปิดหน้านี้แล้วส่ง
  /// ประเภทกลับไปให้ตัวเรียกสลับแท็บ เพื่อให้ tab bar ด้านล่างยังอยู่
  /// ส่วนหน้าที่ไม่ใช่แท็บจึงค่อย push ทับ
  void _open(NotificationItem n) {
    switch (n.kind) {
      case NotificationKind.medicine:
      case NotificationKind.call:
        Navigator.of(context).pop(n.kind);
      case NotificationKind.meal:
        Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (_) =>
                NutritionDetailScreen(data: HealthRepository().load()),
          ),
        );
      case NotificationKind.appointment:
        Navigator.of(context).push(
          CupertinoPageRoute<void>(builder: (_) => const AppointmentScreen()),
        );
      case NotificationKind.payment:
        Navigator.of(
          context,
        ).push(CupertinoPageRoute<void>(builder: (_) => const PaymentScreen()));
    }
  }

  /// การ์ดแจ้งเตือนหนึ่งใบ — หัวแถว (ไอคอน ประเภท เวลา) แล้วตามด้วยเนื้อหา
  Widget _card(NotificationItem n) {
    final tone = _toneFor(n.kind);
    return PressEffect(
      onTap: () => _open(n),
      rippleShape: BoxShape.rectangle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone.color.withValues(alpha: 0.2),
                  ),
                  child: Icon(tone.icon, size: 13, color: tone.color),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    tone.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: _fontThai,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: 0.275,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // จุดแดง = ยังไม่อ่าน
                if (n.unread) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF383C),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  n.timeLabel,
                  style: const TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.275,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            if (n.message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                n.message,
                style: const TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  letterSpacing: 0.275,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
            if (n.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final t in n.tags) _tag(t)],
              ),
            ],
            if (n.details.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final d in n.details)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Opacity(
                        opacity: 0.8,
                        child: Icon(
                          d.icon,
                          size: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          d.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: _fontThai,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (n.callerName != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary600, Color(0xFF166C53)],
                      ),
                    ),
                    child: n.avatarAsset == null
                        ? const Icon(
                            CupertinoIcons.person_fill,
                            size: 22,
                            color: CupertinoColors.white,
                          )
                        : Image.asset(n.avatarAsset!, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          n.callerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: _fontThai,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.43,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.phone_arrow_down_left,
                              size: 13,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              n.callLabel ?? 'โทรหาคุณ',
                              style: const TextStyle(
                                fontFamily: _fontThai,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                letterSpacing: 0.275,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: _fontThai,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.275,
        color: AppColors.textPrimary,
      ),
    ),
  );

  _Tone _toneFor(NotificationKind kind) => switch (kind) {
    NotificationKind.medicine => const _Tone(
      'แจ้งเตือนทานยา',
      Icons.medication_rounded,
      AppColors.primary600,
    ),
    NotificationKind.meal => const _Tone(
      'แจ้งเตือนทานอาหาร',
      Icons.restaurant_rounded,
      Color(0xFF2563EB),
    ),
    NotificationKind.appointment => const _Tone(
      'แจ้งเตือนนัด',
      CupertinoIcons.calendar,
      Color(0xFF7C3AED),
    ),
    NotificationKind.call => const _Tone(
      'แจ้งเตือนการโทร',
      CupertinoIcons.phone_fill,
      Color(0xFFBE123C),
    ),
    NotificationKind.payment => const _Tone(
      'แจ้งเตือนค่าบริการ',
      Icons.receipt_long_rounded,
      Color(0xFFD97706),
    ),
  };
}

class _Tone {
  const _Tone(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

const _fontThai = 'IBM Plex Sans Thai Looped';
const _linkBlue = Color(0xFF2463EB);

/// ข้อมูลจำลองจนกว่าจะมี API แจ้งเตือนจริง
const kMockNotifications = <NotificationItem>[
  NotificationItem(
    kind: NotificationKind.payment,
    timeLabel: '31 ก.ค. 69',
    message: 'มีค่าบริการรอชำระ 9,950 บาท ชำระผ่านแอปได้เลย ไม่ต้องรอคิว',
    unread: true,
    details: [
      NotificationDetail(
        Icons.local_hospital_rounded,
        'โรงพยาบาลสมเด็จพระยุพราชบ้านดุง',
      ),
      NotificationDetail(
        CupertinoIcons.info_circle_fill,
        'รหัสบริการ PG0060001',
      ),
    ],
  ),
  NotificationItem(
    kind: NotificationKind.medicine,
    timeLabel: '11:00 น.',
    message: 'ถึงเวลาทานยาก่อนอาหารสำหรับมื้อเที่ยงของคุณแล้ว',
    unread: true,
    tags: ['Omeprazole 20 mg', 'Domperidone 10 mg', '+2'],
  ),
  NotificationItem(
    kind: NotificationKind.meal,
    timeLabel: '06:20 น.',
    message: 'บันทึกมื้ออาหารของคุณก่อนเริ่มทาน เพื่อวิเคราะห์โภชนาการ',
  ),
  NotificationItem(
    kind: NotificationKind.appointment,
    timeLabel: '06:00 น.',
    message: 'วันนี้คุณมีนัดกับเจ้าหน้าที่เยี่ยมบ้านเวลา 09:00 น.',
    details: [
      NotificationDetail(Icons.medical_services_rounded, 'นพ.วิชัย สุขใจ'),
      NotificationDetail(CupertinoIcons.info_circle_fill, 'ติดตามสุขภาพ'),
    ],
  ),
  NotificationItem(
    kind: NotificationKind.call,
    timeLabel: 'เมื่อวาน 11:00 น.',
    message: '',
    avatarAsset: 'assets/doctormuscott.png',
    callerName: 'นพ. ศักย์ชัย ประเสริฐศักดิ์',
    callLabel: 'โทรหาคุณ',
  ),
  NotificationItem(
    kind: NotificationKind.appointment,
    timeLabel: '12 มี.ค. 69',
    message: 'วันนี้คุณมีนัดพบแพทย์เวลา 09:00 น.',
    details: [
      NotificationDetail(Icons.medical_services_rounded, 'นพ.วิชัย สุขใจ'),
      NotificationDetail(Icons.local_hospital_rounded, 'โรงพยาบาลเสรีโฟล'),
      NotificationDetail(CupertinoIcons.info_circle_fill, 'คุณมีนัดตรวจสุขภาพ'),
    ],
  ),
];
