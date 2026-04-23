import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/widgets/liquid_glass_button.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  static const _primary = Color(0xFF1D8B6B);

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
    final start = (i / total) * 0.55;
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
            offset: Offset(0, (1 - t) * 14),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  static const _sections =
      <({IconData icon, Color color, String title, String body})>[
    (
      icon: CupertinoIcons.exclamationmark_shield_fill,
      color: Color(0xFFF59E0B),
      title: 'คำเตือนและข้อจำกัด',
      body:
          'แอปนี้มีไว้เพื่อจุดประสงค์ในการให้ข้อมูลเท่านั้น ควรปรึกษาแพทย์เพื่อการวินิจฉัยและการรักษาเสมอ',
    ),
    (
      icon: CupertinoIcons.cloud_fill,
      color: Color(0xFF0EA5E9),
      title: 'การเก็บรวบรวมข้อมูล',
      body:
          'เราอาจรวบรวมข้อมูลดังต่อไปนี้เพื่อให้บริการที่มีประสิทธิภาพแก่คุณ ข้อมูลบัญชีผู้ใช้ ข้อมูลสุขภาพ ข้อมูลอุปกรณ์ ข้อมูลตำแหน่งที่ตั้ง',
    ),
    (
      icon: CupertinoIcons.globe,
      color: Color(0xFF2563EB),
      title: 'วัตถุประสงค์ในการใช้ข้อมูล',
      body:
          'MyAtlas ใช้ข้อมูลของคุณเพื่อติดตามและวิเคราะห์ข้อมูลสุขภาพ เพื่อให้คำแนะนำที่เหมาะสม',
    ),
    (
      icon: CupertinoIcons.link,
      color: Color(0xFF7C3AED),
      title: 'การแชร์ข้อมูล',
      body:
          'เราจะไม่เปิดเผยข้อมูลของคุณแก่บุคคลที่สามโดยไม่ได้รับความยินยอม เว้นแต่ในกรณีที่จำเป็นต้องปฏิบัติตามกฎหมาย หรือให้บริการทางการแพทย์ที่เกี่ยวข้องโดยได้รับความยินยอมจากคุณ',
    ),
    (
      icon: CupertinoIcons.lock_shield_fill,
      color: Color(0xFF1D8B6B),
      title: 'การปกป้องข้อมูลของคุณ',
      body:
          'MyAtlas ใช้มาตรการความปลอดภัยขั้นสูง เช่น การเข้ารหัสข้อมูล และระบบยืนยันตัวตน เพื่อป้องกันการเข้าถึงข้อมูลโดยไม่ได้รับอนุญาต',
    ),
    (
      icon: CupertinoIcons.person_crop_circle_fill_badge_checkmark,
      color: Color(0xFFEC4899),
      title: 'สิทธิของผู้ใช้',
      body:
          'ตรวจสอบ แก้ไข หรือลบข้อมูลส่วนบุคคลของคุณ ปรับเปลี่ยนการตั้งค่าความเป็นส่วนตัวได้ทุกเมื่อ ขอให้เราหยุดใช้หรือแชร์ข้อมูลของคุณในบางกรณี',
    ),
    (
      icon: CupertinoIcons.arrow_2_circlepath,
      color: Color(0xFF475569),
      title: 'การเปลี่ยนแปลงนโยบาย',
      body:
          'เราขอสงวนสิทธิ์ในการปรับปรุงนโยบายนี้เป็นครั้งคราว หากมีการเปลี่ยนแปลงสำคัญ เราจะแจ้งให้คุณทราบผ่านแอปหรือช่องทางอื่นๆ',
    ),
  ];

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
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE4F5F0), Color(0xFFF4F8F5)],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
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
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 56 + 12,
                bottom: 40,
              ),
              children: [
                _stagger(
                  0,
                  9,
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _primary.withValues(alpha: 0.22),
                                    _primary.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.white.withValues(
                                  alpha: 0.7,
                                ),
                                border: Border.all(
                                  color: CupertinoColors.white
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF26A47E),
                                    Color(0xFF12624A),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x5912624A),
                                    blurRadius: 18,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.checkmark_shield_fill,
                                color: CupertinoColors.white,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _stagger(
                  1,
                  9,
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'ข้อมูลของคุณ ความสำคัญของเรา',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'MyAtlas ให้ความสำคัญกับความเป็นส่วนตัวและความปลอดภัยของข้อมูลสุขภาพของผู้ใช้เป็นอันดับหนึ่ง เรามุ่งมั่นที่จะปกป้องข้อมูลส่วนบุคคลของคุณตามมาตรฐานความปลอดภัยสูงสุด',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6D756E),
                            fontSize: 14,
                            height: 22 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < _sections.length; i++)
                  _stagger(
                    i + 2,
                    _sections.length + 2,
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          16, 0, 16, i == _sections.length - 1 ? 0 : 10),
                      child: _PolicyCard(
                        icon: _sections[i].icon,
                        iconColor: _sections[i].color,
                        title: _sections[i].title,
                        body: _sections[i].body,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: Opacity(
                    opacity: 0.6,
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.lock_fill,
                          size: 12,
                          color: _primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'อัปเดตล่าสุด 22 เม.ย 2569',
                          style: TextStyle(
                            color: Color(0xFF6D756E),
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
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
              builder: (_, offset, __) => _PinnedTopBar(
                title: 'นโยบายความเป็นส่วนตัว',
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

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor,
                      Color.lerp(iconColor, CupertinoColors.black, 0.25)!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: CupertinoColors.white, size: 15),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13.5,
              height: 21 / 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedTopBar extends StatelessWidget {
  const _PinnedTopBar({
    required this.title,
    required this.scrollOffset,
    required this.onBack,
  });
  final String title;
  final double scrollOffset;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final progress = (scrollOffset / 60).clamp(0.0, 1.0);
    final barHeight = top + 6 + 44 + 6;
    return Stack(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22 * progress,
              sigmaY: 22 * progress,
            ),
            child: Container(
              height: barHeight,
              color:
                  const Color(0xFFF4F8F5).withValues(alpha: 0.80 * progress),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: progress,
            child: Container(
              height: 0.5,
              color: CupertinoColors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: top + 6, left: 14, right: 14),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.chevron_back,
                    onTap: onBack,
                    size: 40,
                    iconSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
