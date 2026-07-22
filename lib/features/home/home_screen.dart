import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Scaffold;

import '../../core/theme/app_colors.dart';
import '../family/care_giver_screen.dart';
import '../family/family_devices.dart';
import '../health/data/health_data.dart';
import '../health/health_screen.dart'
    show HealthSummarySections, HomeActivityPair;
import '../health/sleep_detail_screen.dart';
import '../nutrition/food_lens/food_lens_flow.dart';
import '../nutrition/nutrition_detail_screen.dart';
import 'widgets/ai_advice_card.dart';
import 'widgets/header_clouds.dart';
import 'widgets/home_hospital_queue_card.dart';
import 'widgets/home_sleep_card.dart';
import 'widgets/home_summary_dashboard.dart';
import 'widgets/home_votagex_hero.dart';
import 'widgets/home_water_intake_card.dart';
import 'widgets/home_workout_streak_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HealthRepository _repo = HealthRepository(seed: 7);
  late final HealthData _healthData = _repo.load();

  final Set<DeviceKind> _userDevices = {
    DeviceKind.smartwatch,
    DeviceKind.cgm,
  };

  // Page-load entrance — staggered fade-up, matching the other screens.
  // Initialized inline (and started) so it survives hot reload, which doesn't
  // re-run initState.
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _stagger(int index, int total, Widget child) {
    final start = (index / total) * 0.5;
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
            offset: Offset(0, (1 - t) * 18),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
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

    final topInset = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Fixed header background — stays put while the content scrolls over
          // it (no rounded corners on any side). Clouds drift across the sky.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset + 360,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: const [
                  Image(
                    image: AssetImage('assets/header-bg.webp'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  HeaderClouds(),
                ],
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _stagger(
                0,
                3,
                _HeroSection(
                  statusDevice: watch,
                  workoutDays: workoutDays,
                  workoutResults: workoutResults,
                ),
              ),
          // Content sheet — stacks over the header with rounded top corners.
          Container(
            transform: Matrix4.translationValues(0, -48, 0),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // AI advice — sits BEHIND the food-analysis section.
                _stagger(1, 3, const AiAdviceCard()),
                // Food-analysis section onward — its own rounded container that
                // overlaps upward so the AI card peeks out behind it.
                _stagger(
                  2,
                  3,
                  Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.bgPrimary,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x16000000),
                          blurRadius: 14,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    child: HealthSummarySections(
              data: _healthData,
              // Home uses the dashboard grid's compact meal card instead of the
              // full-width food-analysis section.
              showNutrition: false,
              afterActivity: Column(
                children: [
                  const HomeHospitalQueueCard(),
                  const SizedBox(height: 16),
                  // Dashboard grid (pulled from the Paiboon fork): meal-analysis
                  // card on the left, smart-watch + family stacked on the right.
                  HomeSummaryDashboard(
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) =>
                            NutritionDetailScreen(data: _healthData),
                      ),
                    ),
                    onScanTap: () => openFoodLens(context),
                    onFamilyTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const CareGiverScreen(),
                      ),
                    ),
                    onWatchTap: () => showManageDevicesSheet(
                      context,
                      selected: _userDevices,
                      onChanged: (next) =>
                          setState(() => _userDevices
                            ..clear()
                            ..addAll(next)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Steps + activity-rings pair (ก้าวเดิน / กิจกรรม), row 2 of
                  // the grid.
                  HomeActivityPair(data: _healthData),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  // Sleep summary — score, stage breakdown, sleep debt, bedtime
                  // consistency. Tapping opens the full sleep detail screen.
                  HomeSleepCard(
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const SleepDetailScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
              // Empty state: never used yet — the start invitation card.
              // HIDDEN for now (kept on purpose, do not delete). Un-comment &
              // slot it back in (e.g. as another afterActivity) to show.
              // HomeWorkoutStreakCard(workoutDays: {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    this.statusDevice,
    this.workoutDays = const {},
    this.workoutResults = const {},
  });

  final HomeHeroDevice? statusDevice;
  final Set<DateTime> workoutDays;
  final Map<DateTime, (int, int)> workoutResults;

  @override
  Widget build(BuildContext context) {
    return HomeVotagexHero(
      welcomeName: 'คุณณัฐพงษ์',
      statusDevice: statusDevice,
      workoutDays: workoutDays,
      workoutResults: workoutResults,
    );
  }
}
