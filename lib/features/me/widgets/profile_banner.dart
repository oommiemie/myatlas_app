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
      borderRadius: BorderRadius.circular(c ? 28 : 32),
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
          // subtle inner border
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: light
                        ? CupertinoColors.black.withValues(alpha: 0.06)
                        : CupertinoColors.white.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: c
                ? const EdgeInsets.fromLTRB(16, 14, 16, 12)
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
                            SizedBox(height: c ? 4 : 6),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: c ? 7 : 8,
                                    vertical: c ? 2 : 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: light
                                        ? CupertinoColors.black
                                            .withValues(alpha: 0.05)
                                        : CupertinoColors.white
                                            .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
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
                                            Text(
                                              widget.watchBattery != null
                                                  ? '${widget.watchName} · ${widget.watchBattery}%'
                                                  : widget.watchName!,
                                              style: const TextStyle(
                                                color: Color(0xFF3E453F),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        )
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
                                                    ? const Color(0xFF3E453F)
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
                      )
                    else
                      const _FamilyCluster(),
                  ],
                ),
                SizedBox(height: c ? 10 : 16),
                // Home card shows an AI medicine reminder; the Me page keeps the
                // age / sex / blood-group stat row.
                if (c)
                  const _AiAlertCarousel()
                else
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
  static final bool _testEmpty = false;

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
