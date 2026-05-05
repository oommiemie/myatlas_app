import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/skeleton_box.dart';
import '../appointment/data/mock_data.dart' as appt;
import 'widgets/home_ai_tips_card.dart';
import 'widgets/home_latest_meal_card.dart';
import 'widgets/home_medicine_reminder.dart';
import 'widgets/home_promo_banner.dart';
import 'widgets/home_upcoming_appointments.dart';
import 'widgets/home_user_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  bool _loading = true;
  Timer? _skeletonTimer;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _skeletonTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _loading = false);
      _enter.forward();
    });
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
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
    if (_loading) {
      return const _HomeSkeleton();
    }
    final upcoming =
        appt.hospitalAppointments.byBucket[appt.AppointmentBucket.soon] ??
            const [];
    final sections = <Widget>[
      const _HeroSection(),
      const HomePromoBanner(items: _samplePromoBanners),
      const HomeAiTipsCard(),
      const HomeMedicineReminder(
        reminders: [
          MedicineReminder(
            mealLabel: 'มื้อเช้า',
            time: '06:20 น.',
            name: 'Metformin 500 mg',
            description:
                'รับประทาน ครั้งละ 1 เม็ด วันละ 3 ครั้ง (เช้า-กลางวัน-เย็น)',
            foodTiming: 'ก่อนอาหาร',
          ),
          MedicineReminder(
            mealLabel: 'มื้อกลางวัน',
            time: '12:30 น.',
            name: 'Metformin 500 mg',
            description:
                'รับประทาน ครั้งละ 1 เม็ด วันละ 3 ครั้ง (หลังอาหารกลางวัน)',
            foodTiming: 'หลังอาหาร',
          ),
          MedicineReminder(
            mealLabel: 'มื้อเย็น',
            time: '18:00 น.',
            name: 'Atorvastatin 20 mg',
            description:
                'รับประทาน ครั้งละ 1 เม็ด วันละ 1 ครั้ง (หลังอาหารเย็น)',
            foodTiming: 'หลังอาหาร',
          ),
          MedicineReminder(
            mealLabel: 'ก่อนนอน',
            time: '21:00 น.',
            name: 'Aspirin 81 mg',
            description: 'รับประทาน ครั้งละ 1 เม็ด วันละ 1 ครั้ง (ก่อนนอน)',
          ),
        ],
      ),
      const HomeLatestMealCard(),
      HomeUpcomingAppointments(items: upcoming),
      const SizedBox(height: 120),
    ];
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: sections.length,
        itemBuilder: (_, i) => _stagger(i, sections.length, sections[i]),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE4F5F0), AppColors.bgPrimary],
          stops: [0.0, 0.5],
        ),
      ),
      padding: EdgeInsets.only(top: statusBarHeight),
      child: const HomeUserHeader(
        date: '12 ม.ค. 69',
        name: 'คุณณัฐพงษ์',
        hasUnread: true,
      ),
    );
  }
}

const _samplePromoBanners = <PromoBannerItem>[
  PromoBannerItem(imageAsset: 'assets/banner.png'),
  PromoBannerItem(imageAsset: 'assets/banner.png'),
  PromoBannerItem(imageAsset: 'assets/banner.png'),
];

// ── Skeleton loading ──────────────────────────────────────────────────────────

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SkeletonHost(
        builder: (_, shimmer) => ListView(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE4F5F0), AppColors.bgPrimary],
                  stops: [0.0, 0.5],
                ),
              ),
              padding: EdgeInsets.only(top: statusBarHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Row(
                  children: [
                    SkeletonBox(
                        shimmer: shimmer,
                        width: 56,
                        height: 56,
                        borderRadius: 100),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                              shimmer: shimmer, width: 80, height: 12),
                          const SizedBox(height: 8),
                          SkeletonBox(
                              shimmer: shimmer, width: 160, height: 18),
                        ],
                      ),
                    ),
                    SkeletonBox(
                        shimmer: shimmer,
                        width: 36,
                        height: 36,
                        borderRadius: 100),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: AspectRatio(
                aspectRatio: 5 / 2,
                child: SkeletonBox(shimmer: shimmer, borderRadius: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                      shimmer: shimmer,
                      width: 160,
                      height: 32,
                      borderRadius: 100),
                  const SizedBox(height: 16),
                  SkeletonBox(shimmer: shimmer, height: 14),
                  const SizedBox(height: 8),
                  SkeletonBox(shimmer: shimmer, height: 14, width: 280),
                  const SizedBox(height: 8),
                  SkeletonBox(shimmer: shimmer, height: 14, width: 240),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: SkeletonBox(shimmer: shimmer, height: 12)),
                      const SizedBox(width: 4),
                      SkeletonBox(shimmer: shimmer, width: 70, height: 12),
                      const SizedBox(width: 4),
                      SkeletonBox(shimmer: shimmer, width: 70, height: 12),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: SkeletonBox(
                              shimmer: shimmer,
                              height: 56,
                              borderRadius: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: SkeletonBox(
                              shimmer: shimmer,
                              height: 56,
                              borderRadius: 16)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(shimmer: shimmer, width: 120, height: 16),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonBox(
                          shimmer: shimmer,
                          width: 280,
                          height: 163,
                          borderRadius: 24),
                      const SizedBox(width: 12),
                      SkeletonBox(
                          shimmer: shimmer,
                          width: 60,
                          height: 163,
                          borderRadius: 24),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SkeletonBox(
                  shimmer: shimmer, height: 120, borderRadius: 24),
            ),
          ],
        ),
      ),
    );
  }
}
