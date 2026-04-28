import 'package:flutter/cupertino.dart';

import '../../../core/widgets/liquid_glass_button.dart';
import '../../../core/widgets/press_effect.dart';
import '../../health/widgets/health_detail_app_bar.dart';
import 'opd_create_flow.dart';
import 'opd_data.dart';

class OpdRegistryScreen extends StatefulWidget {
  const OpdRegistryScreen({super.key});

  @override
  State<OpdRegistryScreen> createState() => _OpdRegistryScreenState();
}

class _OpdRegistryScreenState extends State<OpdRegistryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
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
          child: Transform.translate(offset: Offset(0, (1 - t) * 14), child: c),
        );
      },
      child: child,
    );
  }

  Future<void> _addEntry() async {
    final result = await Navigator.of(context, rootNavigator: true)
        .push<OpdEntry>(
      PageRouteBuilder<OpdEntry>(
        opaque: false,
        barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
        barrierDismissible: true,
        barrierLabel: 'opd-create',
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, anim, sec) => const OpdCreateFlow(),
        transitionsBuilder: (ctx, anim, sec, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
    if (result != null) {
      OpdStore.instance.add(result);
      setState(() {});
    }
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
                  child: ValueListenableBuilder<List<OpdEntry>>(
                    valueListenable: OpdStore.instance.entries,
                    builder: (_, entries, __) {
                      final active = entries
                          .where((e) => e.status == OpdStatus.active)
                          .toList();
                      final history = entries
                          .where((e) => e.status != OpdStatus.active)
                          .toList();
                      return NotificationListener<ScrollNotification>(
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
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
                        children: [
                          if (active.isEmpty)
                            _stagger(
                              0,
                              3,
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                                child: _HeroCtaCard(onTap: _addEntry),
                              ),
                            )
                          else
                            _stagger(
                              0,
                              3,
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _ActiveCard(entry: active.first),
                              ),
                            ),
                          if (active.isEmpty)
                            _stagger(
                              1,
                              3,
                              const Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16, 4, 16, 16),
                                child: _StepsStrip(),
                              ),
                            ),
                          _stagger(
                            2,
                            3,
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(4, 4, 0, 10),
                                    child: Text(
                                      'ประวัติ',
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  if (history.isEmpty)
                                    const _EmptyHistoryCard()
                                  else
                                    for (int i = 0;
                                        i < history.length;
                                        i++) ...[
                                      _HistoryCard(entry: history[i]),
                                      if (i != history.length - 1)
                                        const SizedBox(height: 12),
                                    ],
                                ],
                              ),
                            ),
                          ),
                        ],
                        ),
                      );
                    },
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
                title: 'ลงทะเบียนผู้ป่วยนอก',
                scrollOffset: offset,
                onBack: () => Navigator.of(context).pop(),
                action: LiquidGlassButton(
                  icon: CupertinoIcons.plus,
                  onTap: _addEntry,
                  size: 40,
                  iconSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCtaCard extends StatelessWidget {
  const _HeroCtaCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.medium,
      scale: 0.98,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0891B2), Color(0xFF0369A1)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0369A1).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: -40,
              bottom: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.sparkles,
                            size: 12,
                            color: CupertinoColors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'เริ่มต้นใช้งาน',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ลงทะเบียน OPD',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'คัดกรองด้วยตัวเอง\nรับ QR Code ยื่นที่โรงพยาบาลได้เลย',
                            style: TextStyle(
                              color: CupertinoColors.white
                                  .withValues(alpha: 0.85),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CupertinoColors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: CupertinoColors.white.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        CupertinoIcons.qrcode,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'เริ่มลงทะเบียน',
                        style: TextStyle(
                          color: Color(0xFF0369A1),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        CupertinoIcons.arrow_right,
                        size: 14,
                        color: Color(0xFF0369A1),
                      ),
                    ],
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

class _StepsStrip extends StatelessWidget {
  const _StepsStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _StepItem(
              icon: CupertinoIcons.square_list_fill,
              color: Color(0xFF1D8B6B),
              label: 'คัดกรอง\nด้วยตนเอง',
            ),
          ),
          _StepArrow(),
          Expanded(
            child: _StepItem(
              icon: CupertinoIcons.qrcode,
              color: Color(0xFF0891B2),
              label: 'รับ\nQR Code',
            ),
          ),
          _StepArrow(),
          Expanded(
            child: _StepItem(
              icon: CupertinoIcons.building_2_fill,
              color: Color(0xFFFB923C),
              label: 'ยื่นที่\nโรงพยาบาล',
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.3,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _StepArrow extends StatelessWidget {
  const _StepArrow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Icon(
        CupertinoIcons.chevron_right,
        size: 12,
        color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            ),
            alignment: Alignment.center,
            child: Icon(
              CupertinoIcons.doc_text_search,
              size: 26,
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'ยังไม่มีประวัติ',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ประวัติลงทะเบียน OPD จะแสดงที่นี่',
            style: TextStyle(
              color: Color(0xFF6D756E),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.entry});
  final OpdEntry entry;

  String _fmtDate(DateTime d) {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year + 543}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 120, 8),
                child: Text(
                  entry.patientName,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
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
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0891B2), Color(0xFF0369A1)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(
                        CupertinoIcons.square_grid_3x2_fill,
                        'CID ${entry.cid}',
                      ),
                      const SizedBox(height: 12),
                      _row(
                        CupertinoIcons.calendar,
                        _fmtDate(entry.registeredAt),
                      ),
                      const SizedBox(height: 12),
                      _row(CupertinoIcons.info_circle_fill, entry.status.label),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 12,
            child: _QrThumbnail(),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: CupertinoColors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
              letterSpacing: 0.14,
            ),
          ),
        ),
      ],
    );
  }
}

class _QrThumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 84,
              height: 84,
              child: CustomPaint(painter: _QrStylizedPainter()),
            ),
          ),
          Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ดูแบบเต็ม',
              style: TextStyle(color: Color(0xFF6D756E), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrStylizedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1A1A1A);
    final dot = size.width / 18;
    // Three corner finders
    void finder(Offset origin) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(origin.dx, origin.dy, dot * 7, dot * 7),
          Radius.circular(dot),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            origin.dx + dot,
            origin.dy + dot,
            dot * 5,
            dot * 5,
          ),
          Radius.circular(dot * 0.7),
        ),
        Paint()..color = CupertinoColors.white,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            origin.dx + dot * 2,
            origin.dy + dot * 2,
            dot * 3,
            dot * 3,
          ),
          Radius.circular(dot * 0.5),
        ),
        paint,
      );
    }

    finder(Offset(dot, dot));
    finder(Offset(size.width - dot * 8, dot));
    finder(Offset(dot, size.height - dot * 8));

    // Random-ish dot pattern
    const seed = <int>[
      0x1a, 0x2e, 0x4f, 0x73, 0x88, 0xa5, 0xc2, 0xd9, 0xe6, 0xf2,
      0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0, 0x12, 0x34, 0x56,
    ];
    for (int y = 0; y < 18; y++) {
      for (int x = 0; x < 18; x++) {
        if ((x < 8 && y < 8) || (x > 10 && y < 8) || (x < 8 && y > 10)) {
          continue;
        }
        final v = seed[(x * 3 + y * 5) % seed.length];
        if ((v & (1 << ((x + y) % 8))) != 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x * dot, y * dot, dot * 0.9, dot * 0.9),
              Radius.circular(dot * 0.3),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});
  final OpdEntry entry;

  String _fmtDate(DateTime d) {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year + 543}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              entry.patientName,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
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
                  _row(
                    CupertinoIcons.square_grid_3x2_fill,
                    'CID ${entry.cid}',
                  ),
                  const SizedBox(height: 12),
                  _row(CupertinoIcons.calendar, _fmtDate(entry.registeredAt)),
                  const SizedBox(height: 12),
                  _row(CupertinoIcons.info_circle_fill, entry.status.label),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              letterSpacing: 0.14,
            ),
          ),
        ),
      ],
    );
  }
}
