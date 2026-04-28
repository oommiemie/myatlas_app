import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/home_ai_tips_card.dart';
import 'widgets/home_latest_meal_card.dart';
import 'widgets/home_medicine_reminder.dart';
import 'widgets/home_user_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ListView(
        padding: EdgeInsets.zero,
        children: const [
          _HeroSection(),
          HomeAiTipsCard(),
          HomeMedicineReminder(
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
          HomeLatestMealCard(),
          SizedBox(height: 120),
        ],
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
