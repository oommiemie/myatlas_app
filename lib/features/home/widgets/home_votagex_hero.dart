import 'package:flutter/material.dart';

import '../../me/widgets/profile_banner.dart';

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
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    // Transparent content — the header-bg image is a fixed layer behind this
    // (in HomeScreen), so it doesn't scroll with the content.
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopRow(),
          const SizedBox(height: 20),
          _buildTodayBlock(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App logo (left).
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF0A296B), Color(0xFF092834)],
          ).createShader(b),
          child: const Text(
            'MY ATLAS',
            style: TextStyle(
              fontFamily: 'Google Sans',
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              height: 1.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Personal-info banner (from the Me page) shown in the header — compact, with
  // the connected-watch status shown in the chip.
  Widget _buildTodayBlock() {
    final d = widget.statusDevice;
    return ProfileBanner(
      compact: true,
      watchName: d?.name,
      watchConnected: d?.connected ?? false,
      watchBattery: d?.battery,
    );
  }
}
