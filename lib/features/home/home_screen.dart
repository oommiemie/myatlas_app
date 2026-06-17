import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Scaffold;

import '../../core/theme/app_colors.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../family/family_devices.dart';
import '../health/data/health_data.dart';
import '../health/health_screen.dart' show HealthSummarySections;
import 'widgets/home_votagex_hero.dart';
import 'widgets/home_water_intake_card.dart';
import 'widgets/home_workout_streak_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HealthRepository _repo = HealthRepository(seed: 7);
  late final HealthData _healthData = _repo.load();

  final Set<DeviceKind> _userDevices = {
    DeviceKind.smartwatch,
    DeviceKind.cgm,
  };

  void _openDevicePairing() {
    showManageDevicesSheet(
      context,
      selected: _userDevices,
      onChanged: (next) {
        setState(() {
          _userDevices
            ..clear()
            ..addAll(next);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Top-right action — Bluetooth (pair devices). The "arrange" button now
    // lives inline with the "สัญญาณชีพ" section heading.
    final heroActions = LiquidGlassButton(
      icon: Icons.bluetooth,
      onTap: _openDevicePairing,
      size: 40,
      iconSize: 20,
      iconColor: const Color(0xFF1D8B6B),
    );

    // The connected watch shown (left-aligned) with model + status + battery.
    final watch = _userDevices.contains(DeviceKind.smartwatch)
        ? HomeHeroDevice(
            icon: Icons.watch,
            color: DeviceKind.smartwatch.tone,
            name: DeviceKind.smartwatch.label,
            battery: 85,
          )
        : null;

    // Sample workout days — a 6-day streak ending today (shows flames + badge).
    final now2 = DateTime.now();
    final workoutDays = <DateTime>{
      for (var i = 0; i < 6; i++)
        DateTime(now2.year, now2.month, now2.day - i),
    };
    // Per-day dance results (score, accuracy %) for the donut.
    final workoutResults = <DateTime, (int, int)>{
      DateTime(now2.year, now2.month, now2.day): (1280, 94),
      DateTime(now2.year, now2.month, now2.day - 1): (1175, 91),
      DateTime(now2.year, now2.month, now2.day - 2): (1340, 96),
      DateTime(now2.year, now2.month, now2.day - 3): (990, 84),
      DateTime(now2.year, now2.month, now2.day - 4): (1210, 92),
      DateTime(now2.year, now2.month, now2.day - 5): (1080, 88),
    };

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _HeroSection(
            trailing: heroActions,
            statusDevice: watch,
            workoutDays: workoutDays,
            workoutResults: workoutResults,
          ),
          // Health summary UI moved onto the Home page. The workout-streak card
          // is slotted in right under the activity (ก้าวเดินและกิจกรรม) block.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: HealthSummarySections(
              data: _healthData,
              // Workout-streak card + water-intake card, stacked below the
              // activity block.
              afterActivity: Column(
                children: [
                  // Interactive demo: today not done yet (start button is
                  // tappable → opens the clip picker), with past workout days,
                  // a missed day, and upcoming days — tapping around the week
                  // shows every state (flame/score, rest, start, future).
                  HomeWorkoutStreakCard(
                    // 16th (yesterday) intentionally has no workout → rest day.
                    // day-2..4 are consecutive (streak → Aerobic2). day-6 is a
                    // lone workout with no neighbours (not a streak → Aerobic1).
                    workoutDays: {
                      DateTime(now2.year, now2.month, now2.day - 2),
                      DateTime(now2.year, now2.month, now2.day - 3),
                      DateTime(now2.year, now2.month, now2.day - 4),
                      DateTime(now2.year, now2.month, now2.day - 6),
                    },
                    dayResults: {
                      DateTime(now2.year, now2.month, now2.day - 2): (1260, 93),
                      DateTime(now2.year, now2.month, now2.day - 3): (1040, 86),
                      DateTime(now2.year, now2.month, now2.day - 4): (1320, 95),
                      DateTime(now2.year, now2.month, now2.day - 6): (910, 81),
                    },
                  ),
                  const SizedBox(height: 16),
                  // Water-intake tracker — settable goal, ml per glass, tap to
                  // stamp glasses.
                  const HomeWaterIntakeCard(initialGlasses: 3),
                ],
              ),
            ),
          ),
          // Empty state: never used yet — the start invitation card.
          // HIDDEN for now (kept on purpose, do not delete). Un-comment & slot
          // it back in (e.g. as another afterActivity) to show.
          // HomeWorkoutStreakCard(workoutDays: {}),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    this.trailing,
    this.statusDevice,
    this.workoutDays = const {},
    this.workoutResults = const {},
  });

  final Widget? trailing;
  final HomeHeroDevice? statusDevice;
  final Set<DateTime> workoutDays;
  final Map<DateTime, (int, int)> workoutResults;

  @override
  Widget build(BuildContext context) {
    return HomeVotagexHero(
      welcomeName: 'คุณณัฐพงษ์',
      trailing: trailing,
      statusDevice: statusDevice,
      workoutDays: workoutDays,
      workoutResults: workoutResults,
    );
  }
}
