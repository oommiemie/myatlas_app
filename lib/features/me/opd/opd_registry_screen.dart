import 'package:flutter/cupertino.dart';

import '../../../core/widgets/liquid_glass_button.dart';
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
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFB923C), Color(0xFFC2410C)],
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
                      const Expanded(
                        child: Text(
                          'OPD Registry',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      LiquidGlassButton(
                        icon: CupertinoIcons.plus,
                        iconColor: const Color(0xFF1A1A1A),
                        onTap: _addEntry,
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
                  child: ValueListenableBuilder<List<OpdEntry>>(
                    valueListenable: OpdStore.instance.entries,
                    builder: (_, entries, __) {
                      final active = entries
                          .where((e) => e.status == OpdStatus.active)
                          .toList();
                      final history = entries
                          .where((e) => e.status != OpdStatus.active)
                          .toList();
                      return ListView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
                        children: [
                          if (active.isEmpty)
                            _stagger(
                              0,
                              2,
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _EmptyActiveCard(onTap: _addEntry),
                              ),
                            )
                          else
                            _stagger(
                              0,
                              2,
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _ActiveCard(entry: active.first),
                              ),
                            ),
                          _stagger(
                            1,
                            2,
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'ประวัติ',
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (history.isEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white,
                                        borderRadius:
                                            BorderRadius.circular(24),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'ยังไม่มีประวัติ',
                                        style: TextStyle(
                                          color: Color(0xFF6D756E),
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
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
                      );
                    },
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

class _EmptyActiveCard extends StatelessWidget {
  const _EmptyActiveCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF0891B2).withValues(alpha: 0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0891B2), Color(0xFF0369A1)],
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.plus,
                color: CupertinoColors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ลงทะเบียน OPD',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'กรอกข้อมูลคัดกรองเพื่อขอ QR Code',
              style: TextStyle(color: Color(0xFF6D756E), fontSize: 13),
            ),
          ],
        ),
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
