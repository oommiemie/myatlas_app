import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../me/profile_screen.dart' show ProfileAvatarImage;
// Kept for the hidden hero streak card below — un-comment with it to restore.
// import 'home_workout_streak_card.dart';

/// A calendar appointment shown in the hero. Two kinds are supported: hospital
/// appointments and home-visit appointments (each gets its own artwork).
class HomeHeroAppointment {
  final DateTime date;
  final String title;
  final bool isHomeVisit;

  const HomeHeroAppointment({
    required this.date,
    required this.title,
    this.isHomeVisit = false,
  });
}

/// A connected device shown in the hero's device row.
class HomeHeroDevice {
  final IconData icon;
  final Color color;
  final String name; // model, e.g. "Apple Watch Series 10"
  final int battery; // 0–100
  final bool connected;
  const HomeHeroDevice({
    required this.icon,
    required this.color,
    this.name = '',
    this.battery = 100,
    this.connected = true,
  });
}

/// Home hero: a sky background with a greeting header (avatar + time-of-day
/// greeting + name + actions) and a "Today" block (date chip, big heading and
/// an avatar/joined row).
class HomeVotagexHero extends StatefulWidget {
  /// The user's name, shown prominently under the greeting.
  final String welcomeName;

  /// Appointments — today's one (if any) becomes the big heading's second line
  /// and selects the background artwork.
  final List<HomeHeroAppointment> appointments;

  /// Heading second line when today has no appointment.
  final String emptyLabel;

  /// Widget shown top-right (e.g. action buttons).
  final Widget? trailing;

  /// The connected watch shown (left-aligned) with model + status + battery.
  final HomeHeroDevice? statusDevice;

  /// Days the user worked out (for the workout-streak calendar card).
  final Set<DateTime> workoutDays;
  final VoidCallback? onStartWorkout;
  final Map<DateTime, (int score, int accuracy)> workoutResults;

  final VoidCallback? onAvatarTap;

  const HomeVotagexHero({
    super.key,
    this.welcomeName = 'Traveler',
    this.appointments = const [],
    this.emptyLabel = 'ภาพรวมของคุณ',
    this.trailing,
    this.statusDevice,
    this.workoutDays = const {},
    this.onStartWorkout,
    this.workoutResults = const {},
    this.onAvatarTap,
  });

  @override
  State<HomeVotagexHero> createState() => _HomeVotagexHeroState();
}

class _HomeVotagexHeroState extends State<HomeVotagexHero> {
  static const _ink = Color(0xFF1A1A2E);

  static const _thWeekdays = [
    'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์',
  ];
  static const _thMonths = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  late final DateTime _today;

  // Watch details are collapsed by default; tapping the watch icon reveals them
  // and they auto-collapse after a short reading window.
  bool _watchOpen = false;
  Timer? _watchTimer;

  // Reading window for the watch details (model + status + battery): ~glance
  // reading time plus the open animation and a small buffer.
  static const _watchAutoCollapse = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    super.dispose();
  }

  void _toggleWatch() {
    _watchTimer?.cancel();
    setState(() => _watchOpen = !_watchOpen);
    if (_watchOpen) {
      _watchTimer = Timer(_watchAutoCollapse, () {
        if (mounted) setState(() => _watchOpen = false);
      });
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'สวัสดีตอนเช้า';
    if (h < 16) return 'สวัสดีตอนบ่าย';
    if (h < 19) return 'สวัสดีตอนเย็น';
    return 'สวัสดีตอนค่ำ';
  }

  String _dateLabel() {
    final w = _thWeekdays[_today.weekday - 1];
    return '$w, ${_today.day} ${_thMonths[_today.month - 1]} ${_today.year + 543}';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        // Background — a soft green-blue (teal) gradient that fades into the
        // app background colour.
        const Positioned.fill(
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFB3E5DC), // soft teal (เขียวอมฟ้า อ่อนๆ)
                  Color(0xFFF4F8F5), // app bgPrimary — blends with the page
                ],
                stops: [0.0, 0.9],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopRow(),
              const SizedBox(height: 20),
              _buildTodayBlock(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(), // profile photo, far left
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _greeting(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5B6B7A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.welcomeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: Color(0xFF06173D),
                ),
              ),
            ],
          ),
        ),
        // Right-aligned cluster: watch pill + Bluetooth button.
        if (widget.statusDevice != null) ...[
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: _glassWatchPill(widget.statusDevice!),
          ),
        ],
        if (widget.trailing != null) ...[
          const SizedBox(width: 8),
          widget.trailing!,
        ],
      ],
    );
  }

  // Watch device as a liquid-glass pill (same translucent style as the
  // Bluetooth button). Collapsed = just the watch icon; tapping it reveals the
  // model + status + battery.
  Widget _glassWatchPill(HomeHeroDevice device) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            // Same translucent glass as the Bluetooth button.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.75),
                  Colors.white.withValues(alpha: 0.55),
                ],
              ),
            ),
            // Animate the width as the details slide out.
            child: AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Watch icon on the glass — same size as the Bluetooth button.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleWatch,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Thin connection ring (green = connected, red = not),
                        // shown only while collapsed.
                        border: _watchOpen
                            ? null
                            : Border.all(
                                color: device.connected
                                    ? const Color(0xFF1D8B6B)
                                    : const Color(0xFFE62E05),
                                width: 1.2,
                              ),
                      ),
                      child: Icon(
                        device.icon,
                        size: 20,
                        // Icon: green when connected, grey when disconnected.
                        color: device.connected
                            ? const Color(0xFF1D8B6B)
                            : const Color(0xFFA3A3A3),
                      ),
                    ),
                  ),
                  if (_watchOpen) ...[
                    Flexible(child: _watchInfo(device)),
                    const SizedBox(width: 12),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: widget.onAvatarTap,
      child: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: const ClipOval(
          child: ProfileAvatarImage(fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildTodayBlock() {
    const secondLine = 'กิจกรรมของคุณ';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Date chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            _dateLabel(),
            style: const TextStyle(
              fontFamily: 'Google Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Big heading
        Text(
          secondLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: _ink,
          ),
        ),
        // Workout-streak calendar card.
        // HIDDEN for now (kept on purpose, do not delete). Un-comment to show.
        // const SizedBox(height: 16),
        // HomeWorkoutStreakCard(
        //   workoutDays: widget.workoutDays,
        //   onStartTap: widget.onStartWorkout,
        //   dayResults: widget.workoutResults,
        // ),
      ],
    );
  }

  Widget _watchInfo(HomeHeroDevice device) {
    final ok = device.connected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Watch model (top)
        Text(
          device.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: _ink,
          ),
        ),
        const SizedBox(height: 2),
        // Connection status + battery (bottom) — scales down so it never
        // overflows the available width.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: ok
                      ? const Color(0xFF1D8B6B)
                      : const Color(0xFFA3A3A3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ok ? 'เชื่อมต่อ' : 'หลุด',
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  fontSize: 11,
                  color: Color(0xFF5B6B7A),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.battery_full,
                size: 13,
                color: device.battery <= 20
                    ? const Color(0xFFE62E05)
                    : const Color(0xFF5B6B7A),
              ),
              const SizedBox(width: 1),
              Text(
                '${device.battery}%',
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  fontSize: 11,
                  color: Color(0xFF5B6B7A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
