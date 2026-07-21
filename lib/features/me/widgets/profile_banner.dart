import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/press_effect.dart';
import '../../appointment/appointment_screen.dart';
import '../../appointment/data/mock_data.dart';
import '../../nutrition/food_lens/food_lens_flow.dart';
import '../../shell/main_shell.dart';
import '../profile_screen.dart' show ProfileScreen, ProfileAvatarImage;

/// Personal-info banner used on the Me page (and embedded in the Home header):
/// mesh-gradient card with the wellness-ring avatar, name, location and the
/// age / sex / blood-group stat row.
class ProfileBanner extends StatefulWidget {
  const ProfileBanner({
    super.key,
    this.compact = false,
    this.watchName,
    this.watchConnected = false,
    this.watchBattery,
  });

  /// Compact layout for the Home header: no edit button, smaller avatar/text
  /// and a tighter stat row.
  final bool compact;

  /// Watch info shown (compact only) in place of the location chip — a status
  /// dot (green = connected) + the watch name/battery.
  final String? watchName;
  final bool watchConnected;
  final int? watchBattery;

  @override
  State<ProfileBanner> createState() => _ProfileBannerState();
}

class _ProfileBannerState extends State<ProfileBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ringCtrl.forward());
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.compact;
    final light = c; // compact (Home) = white/grey theme; Me page = green
    return ClipRRect(
      borderRadius: BorderRadius.circular(c ? 34 : 32),
      child: Stack(
        children: [
          Positioned.fill(child: _MeshGradient(light: light)),
          // shimmer highlight on top
          Positioned(
            left: -40,
            top: -60,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.4,
                child: Container(
                  width: 320,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        CupertinoColors.white.withValues(alpha: 0),
                        CupertinoColors.white.withValues(alpha: light ? 0.5 : 0.18),
                        CupertinoColors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: c
                ? const EdgeInsets.fromLTRB(16, 14, 16, 14)
                : const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WellnessAvatar(
                      progress: _ringCtrl,
                      // Compact avatar matches the family cluster height (66)
                      // so the left & right sections share the same bottom edge.
                      size: c ? 66 : 84,
                      light: light,
                    ),
                    SizedBox(width: c ? 12 : 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GOOD MORNING',
                              style: TextStyle(
                                color: light
                                    ? const Color(0xFF8A97A3)
                                    : CupertinoColors.white
                                        .withValues(alpha: 0.7),
                                fontSize: c ? 9 : 11,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: c ? 2 : 4),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'คุณณัฐพงษ์',
                                    style: AppTypography.headline(
                                      light
                                          ? const Color(0xFF1A1A2E)
                                          : CupertinoColors.white,
                                    ).copyWith(
                                      fontSize: c ? 15 : 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      height: 1.1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: c ? 14 : 17,
                                  color: light
                                      ? const Color(0xFF1D8B6B)
                                      : const Color(0xFFB6F0DA),
                                ),
                              ],
                            ),
                            SizedBox(height: c ? 9 : 6),
                            Row(
                              children: [
                                Container(
                                  padding: !(c && widget.watchName == null)
                                      ? EdgeInsets.symmetric(
                                          horizontal: c ? 7 : 8,
                                          vertical: c ? 2 : 3,
                                        )
                                      : EdgeInsets.zero,
                                  decoration: !(c && widget.watchName == null)
                                      ? BoxDecoration(
                                          color: light
                                              ? CupertinoColors.black
                                                  .withValues(alpha: 0.05)
                                              : CupertinoColors.white
                                                  .withValues(alpha: 0.18),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        )
                                      : null,
                                  child: (c && widget.watchName != null)
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Connection status dot.
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: widget.watchConnected
                                                    ? const Color(0xFF22C55E)
                                                    : const Color(0xFFB0B7BD),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text.rich(
                                              TextSpan(
                                                style: const TextStyle(
                                                  color: Color(0xFF3E453F),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                children: _emphasizeDigits(
                                                  widget.watchConnected
                                                      ? widget.watchName!
                                                      : 'ไม่มีการเชื่อมต่อ',
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : c
                                          // Home card → BMS "made by" credit.
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                  'assets/logobms.png',
                                                  height: 13,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(width: 5),
                                                const Text(
                                                  'Bangkok Medical Software',
                                                  style: TextStyle(
                                                    color: Color(0xFF3E453F),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            )
                                          // Me (green) card → location chip.
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  CupertinoIcons.location_solid,
                                                  size: 10,
                                                  color: light
                                                      ? const Color(0xFF6D756E)
                                                      : CupertinoColors.white,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  'กรุงเทพฯ',
                                                  style: TextStyle(
                                                    color: light
                                                        ? const Color(
                                                            0xFF3E453F)
                                                        : CupertinoColors.white,
                                                    fontSize: c ? 10 : 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Home card: watch on the right, with a connection badge.
                    // Hidden when no watchName is supplied.
                    if (c && widget.watchName != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 6, top: 2),
                        child: _WatchStatus(
                          connected: widget.watchConnected,
                          battery: widget.watchBattery,
                        ),
                      ),
                    if (!c)
                      PressEffect(
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ),
                        haptic: HapticKind.selection,
                        rippleShape: BoxShape.circle,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color:
                                  CupertinoColors.white.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.pencil,
                            color: CupertinoColors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    // (Family cluster removed from the right of the card.)
                  ],
                ),
                // Me page keeps the age / sex / blood-group stat row; the Home
                // card ends after the avatar row (so top/bottom padding match).
                if (!c) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: light
                              ? CupertinoColors.black.withValues(alpha: 0.04)
                              : CupertinoColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: light
                                ? CupertinoColors.black.withValues(alpha: 0.06)
                                : CupertinoColors.white.withValues(alpha: 0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ProfileStat(
                                icon: CupertinoIcons.gift_fill,
                                value: '27',
                                label: 'อายุ',
                                compact: c,
                                light: light,
                              ),
                            ),
                            _StatDivider(light: light),
                            Expanded(
                              child: _ProfileStat(
                                icon: CupertinoIcons.person_fill,
                                value: 'ชาย',
                                label: 'เพศ',
                                compact: c,
                                light: light,
                              ),
                            ),
                            _StatDivider(light: light),
                            Expanded(
                              child: _ProfileStat(
                                icon: CupertinoIcons.drop_fill,
                                value: 'O+',
                                label: 'กรุ๊ปเลือด',
                                compact: c,
                                light: light,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _AiKind { medication, appointment, meal }

/// One AI notification shown in the orange carousel.
class _AiNotif {
  const _AiNotif({
    required this.icon,
    required this.title,
    required this.body,
    required this.kind,
  });
  final IconData icon;
  final String title;
  final String body;
  final _AiKind kind;
}

/// Orange AI-notification card with an auto-sliding vertical carousel — the
/// container stays, only the inner content slides (and the user can swipe
/// up/down). The icon changes per topic. No close button.
class _AiAlertCarousel extends StatefulWidget {
  const _AiAlertCarousel();

  @override
  State<_AiAlertCarousel> createState() => _AiAlertCarouselState();
}

class _AiAlertCarouselState extends State<_AiAlertCarousel> {
  static const _thMonth = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  // TEST: set to false to show real notifications again.
  static final bool _testEmpty = true;

  List<_AiNotif> _buildNotifs() {
    if (_testEmpty) return const [];

    // Pull the soonest hospital appointment for the appointment reminder.
    final soon = hospitalAppointments.byBucket[AppointmentBucket.soon];
    final appt = (soon != null && soon.isNotEmpty) ? soon.first : null;
    final apptTitle = appt == null
        ? 'แจ้งเตือนนัดหมาย'
        : 'นัดหมาย · ${appt.date.day} ${_thMonth[appt.date.month - 1]} ${appt.time} น.';
    final apptBody = appt == null
        ? 'ดูรายการนัดหมายของคุณ'
        : '${appt.title} · ${appt.subLeft} · ${appt.subRight}';

    return [
      const _AiNotif(
        icon: CupertinoIcons.alarm_fill,
        title: 'ถึงเวลาทานยา · 12:30 น.',
        body: 'Metformin 500 mg — รับประทาน 1 เม็ด หลังอาหารกลางวัน พร้อมน้ำ 1 แก้ว',
        kind: _AiKind.medication,
      ),
      _AiNotif(
        icon: CupertinoIcons.calendar,
        title: apptTitle,
        body: apptBody,
        kind: _AiKind.appointment,
      ),
      const _AiNotif(
        icon: CupertinoIcons.camera_fill,
        title: 'ถึงเวลามื้อกลางวัน',
        body: 'ถ่ายรูปอาหารเพื่อสแกนแคลอรี่และบันทึกมื้ออาหารอัตโนมัติ',
        kind: _AiKind.meal,
      ),
    ];
  }

  void _open(BuildContext context, _AiKind kind) {
    switch (kind) {
      case _AiKind.medication:
        // Switch the bottom-nav to the "ทานยา" tab (index 2).
        MainShell.switchTab(context, 2);
      case _AiKind.appointment:
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => const AppointmentScreen()),
        );
      case _AiKind.meal:
        openFoodLens(context);
    }
  }

  final PageController _controller = PageController();
  int _page = 0;
  int _active = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      _page++;
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifs = _buildNotifs();
    // No notifications → show nothing.
    if (notifs.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEF9510), Color(0xFFD06E04)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD06E04).withValues(alpha: 0.32),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: PageView.builder(
                controller: _controller,
                scrollDirection: Axis.vertical,
                onPageChanged: (i) =>
                    setState(() => _active = i % notifs.length),
                itemBuilder: (_, i) => _content(notifs[i % notifs.length]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Vertical dot indicator — active dot is elongated.
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < notifs.length; i++) ...[
                if (i > 0) const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 4,
                  height: i == _active ? 12 : 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white
                        .withValues(alpha: i == _active ? 1 : 0.45),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _content(_AiNotif n) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(context, n.kind),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.white.withValues(alpha: 0.25),
            ),
            child: Icon(n.icon, size: 15, color: CupertinoColors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  n.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: CupertinoColors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  n.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontSize: 11.5,
                    color: CupertinoColors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshGradient extends StatelessWidget {
  const _MeshGradient({required this.light});
  final bool light;

  @override
  Widget build(BuildContext context) {
    if (light) {
      // White → light-grey card (Home).
      return Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFEDEFF2)],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(1.1, 1.0),
                radius: 1.1,
                colors: [
                  const Color(0xFFD7DBE0).withValues(alpha: 0.6),
                  const Color(0xFFD7DBE0).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      );
    }
    // Original green mesh (Me page).
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2BB892), Color(0xFF12624A)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1.0, -1.0),
              radius: 1.2,
              colors: [
                const Color(0xFF7FE7C4).withValues(alpha: 0.5),
                const Color(0xFF7FE7C4).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.1, 1.0),
              radius: 1.0,
              colors: [
                const Color(0xFF0E4F3B).withValues(alpha: 0.55),
                const Color(0xFF0E4F3B).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.9, -0.8),
              radius: 0.8,
              colors: [
                const Color(0xFF4ED2EA).withValues(alpha: 0.35),
                const Color(0xFF4ED2EA).withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WellnessAvatar extends StatelessWidget {
  const _WellnessAvatar({
    required this.progress,
    this.size = 84,
    this.light = false,
  });
  final Animation<double> progress;
  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.76;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: progress,
            builder: (_, __) => CustomPaint(
              size: Size(size, size),
              painter: _WellnessRingPainter(
                value: 0.78 * progress.value,
                light: light,
              ),
            ),
          ),
          Container(
            width: inner,
            height: inner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.white,
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: const ClipOval(
              child: ProfileAvatarImage(fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class _WellnessRingPainter extends CustomPainter {
  _WellnessRingPainter({required this.value, this.light = false});
  final double value;
  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 3;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = light
          ? const Color(0xFF1A1A2E).withValues(alpha: 0.08)
          : CupertinoColors.white.withValues(alpha: 0.2);
    canvas.drawCircle(center, radius, track);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -1.5708,
        endAngle: 4.7124,
        colors: light
            ? const [Color(0xFF2BB892), Color(0xFF4ED2EA), Color(0xFF2BB892)]
            : const [Color(0xFFB6F0DA), Color(0xFFFFFFFF), Color(0xFFB6F0DA)],
      ).createShader(rect);

    const start = -1.5708; // -90deg, top
    final sweep = 6.2832 * value.clamp(0.0, 1.0);
    canvas.drawArc(rect, start, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant _WellnessRingPainter old) =>
      old.value != value || old.light != light;
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
    this.compact = false,
    this.light = false,
  });
  final IconData icon;
  final String value;
  final String label;
  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final c = compact;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: c ? 12 : 14,
          color: light
              ? const Color(0xFF1D8B6B)
              : CupertinoColors.white.withValues(alpha: 0.85),
        ),
        SizedBox(height: c ? 4 : 6),
        Text(
          value,
          style: TextStyle(
            color: light ? const Color(0xFF1A1A2E) : CupertinoColors.white,
            fontSize: c ? 14 : 16,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: c ? 1 : 2),
        Text(
          label,
          style: TextStyle(
            color: light
                ? const Color(0xFF6D756E)
                : CupertinoColors.white.withValues(alpha: 0.75),
            fontSize: c ? 10 : 11,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: light
          ? CupertinoColors.black.withValues(alpha: 0.08)
          : CupertinoColors.white.withValues(alpha: 0.2),
    );
  }
}

/// 2×2 cluster of rounded family tiles, each on its own coloured background,
/// + a "+N" count badge — like the reference. Slight shadows for depth.
// ignore: unused_element
class _FamilyCluster extends StatelessWidget {
  const _FamilyCluster();

  static const _extra = 3; // remaining members
  static const _big = 34.0;
  static const _small = 27.0;
  static const _radius = 11.0;

  static const _bgPurple = [Color(0xFFB07CE8), Color(0xFF8A55D6)];
  static const _bgTeal = [Color(0xFF5BC8E8), Color(0xFF3FA3D8)];
  static const _bgPink = [Color(0xFFF7A1C4), Color(0xFFEE6FA8)];
  static const _bgBadge = [Color(0xFFF06AAE), Color(0xFFC0379B)];

  Widget _shell({
    required double size,
    required Widget child,
    required List<Color> colors,
  }) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: CupertinoColors.white, width: 1.6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _tile(String asset, List<Color> colors, double size) {
    return _shell(
      size: size,
      colors: colors,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius - 1.6),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }

  Widget _badge(double size) {
    return _shell(
      size: size,
      colors: _bgBadge,
      child: Text(
        '+$_extra',
        style: TextStyle(
          color: CupertinoColors.white,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Left column: big top-left + small bottom-left.
    // Right column (shifted up): small top-right + big "+3" badge.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Tap → switch to the "ครอบครัว" tab (index 3).
      onTap: () => MainShell.switchTab(context, 3),
      child: SizedBox(
        width: _big + 6 + _big,
        height: 66,
        child: Stack(
          clipBehavior: Clip.none,
        children: [
          // bottom-left, small (right edge aligned with top-left's right edge)
          Positioned(
            left: _big - _small,
            top: 38,
            child: _tile('assets/images/family/pat.png', _bgPink, _small),
          ),
          // top-left, big (top edge aligned with top-right)
          Positioned(
            left: 0,
            top: 0,
            child: _tile('assets/images/family/somchai.png', _bgPurple, _big),
          ),
          // top-right, small (left edge aligned with bottom-right badge)
          Positioned(
            right: _big - _small,
            top: 0,
            child: _tile('assets/images/family/somsri.png', _bgTeal, _small),
          ),
          // bottom-right, big badge (bottom edge aligned with bottom-left)
          Positioned(
            right: 0,
            top: 38 + _small - _big,
            child: _badge(_big),
          ),
        ],
        ),
      ),
    );
  }
}

/// Family members row (Figma 1015:17557) — "เพิ่ม" button + member avatars
/// with dashed rounded borders and a name label above each.
class FamilyRow extends StatelessWidget {
  const FamilyRow({super.key});

  static const _members = <List<String>>[
    ['แม่', 'assets/images/family/fam_mae.png'],
    ['ยาย', 'assets/images/family/fam_yai.png'],
    ['เจน', 'assets/images/family/fam_jane.png'],
  ];

  static const _dash = Color(0xFFAEB6B0); // grey frames on the light card
  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _box(
            child: const Center(
              child: Icon(CupertinoIcons.add, color: _dash, size: 20),
            ),
          ),
          for (final m in _members) ...[
            const SizedBox(width: 12),
            _box(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  m[1],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _box({required Widget child}) {
    return SizedBox(
      width: _size,
      height: _size,
      child: CustomPaint(
        foregroundPainter: _DashedRRectPainter(radius: 14, color: _dash),
        // Equal padding on every side so the photo sits inset in the frame.
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: child,
        ),
      ),
    );
  }
}

/// Apple Watch shown on the Home profile card with a connection badge:
/// green check when connected, red cross when not.
class _WatchStatus extends StatelessWidget {
  const _WatchStatus({required this.connected, this.battery});
  final bool connected;
  final int? battery;

  @override
  Widget build(BuildContext context) {
    // Box matches the watch image's aspect (235x400) so the screen overlay
    // lines up with no letter-boxing.
    return SizedBox(
      width: 34,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/watch.png'),
              fit: BoxFit.contain,
            ),
          ),
          // Status fills the watch screen. Biased a hair left so it reads
          // centred against the digital crown's visual weight on the right.
          Positioned(
            left: 4.0,
            top: 14.0,
            width: 24,
            height: 30,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: connected
                    ? const Color(0xFF17C964)
                    : const Color(0xFFFF383C),
                borderRadius: BorderRadius.circular(4),
              ),
              child: connected
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        battery != null ? '$battery%' : '✓',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -0.2,
                        ),
                      ),
                    )
                  : const Icon(
                      CupertinoIcons.xmark,
                      size: 13,
                      weight: 900,
                      color: CupertinoColors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Locked "family" feature shown on the Home header: the member avatars sit
/// blurred behind a frosted overlay, with an invitation + "buy package" CTA.
/// (Business model — adding family members requires a paid package.)
class FamilyUpsellCard extends StatelessWidget {
  const FamilyUpsellCard({super.key, this.onBuy});
  final VoidCallback? onBuy;

  static const _base = Color(0xFFEFF2F1); // light, matches the profile card
  static const _green = Color(0xFF1D8B6B);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Square top corners — the top tucks under the profile card.
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Stack(
        children: [
          // Teaser avatars (don't drive the card height).
          Positioned.fill(
            child: Container(
              color: _base,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: const FamilyRow(),
            ),
          ),
          // Light frost — blurs just enough that the add-family UI is still
          // visible behind (same gentle treatment as the dance card).
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Container(color: const Color(0x40EFF2F1)),
            ),
          ),
          // Top-down scrim: near-solid where the text sits, fading down so the
          // blurred avatars still peek through at the bottom.
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xF7EFF2F1), Color(0x40EFF2F1)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Invitation + buy-package CTA on top of the frost.
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 34, 12, 16),
            child: Row(
              children: [
                PressEffect(
                  onTap: onBuy ?? () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2CB48E), _green],
                      ),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: _green.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'ซื้อแพ็กเกจ',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'เพิ่มสมาชิกครอบครัว',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'อัปเกรดแพ็กเกจเพื่อดูแลคนที่คุณรัก',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6D756E)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Splits a label into spans, rendering the numeric runs (e.g. "10", "85%")
/// in a heavier weight so they stand out in the watch tag.
List<InlineSpan> _emphasizeDigits(String s) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'\d+%?');
  var last = 0;
  for (final m in re.allMatches(s)) {
    if (m.start > last) spans.add(TextSpan(text: s.substring(last, m.start)));
    spans.add(TextSpan(
      text: m.group(0),
      style: const TextStyle(fontWeight: FontWeight.w800),
    ));
    last = m.end;
  }
  if (last < s.length) spans.add(TextSpan(text: s.substring(last)));
  return spans;
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.radius, required this.color});
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;
    final rrect =
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    const dash = 4.0, gap = 3.5;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.radius != radius || old.color != color;
}
