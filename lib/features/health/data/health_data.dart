import 'dart:math';

class DailyPoint {
  const DailyPoint(this.date, this.value);
  final DateTime date;
  final double value;
}

class WeeklySeries {
  const WeeklySeries(this.points);

  final List<DailyPoint> points;

  List<double> get values => [for (final p in points) p.value];
  List<DateTime> get dates => [for (final p in points) p.date];
  double get latest => points.last.value;
  double get min => values.reduce((a, b) => a < b ? a : b);
  double get max => values.reduce((a, b) => a > b ? a : b);
  double get average =>
      values.fold<double>(0, (a, b) => a + b) / values.length;

  int get latestIndex => points.length - 1;

  int indexOfDate(DateTime d) {
    for (int i = 0; i < points.length; i++) {
      final p = points[i].date;
      if (p.year == d.year && p.month == d.month && p.day == d.day) {
        return i;
      }
    }
    return -1;
  }

  int get todayIndex {
    final i = indexOfDate(DateTime.now());
    return i >= 0 ? i : latestIndex;
  }

  double get todayValue => points[todayIndex].value;
}

class DualWeeklySeries {
  const DualWeeklySeries({
    required this.primary,
    required this.secondary,
  });

  final WeeklySeries primary;
  final WeeklySeries secondary;
}

class MealSummary {
  const MealSummary({
    required this.tagline,
    required this.name,
    required this.calories,
    required this.mealsEaten,
  });

  final String tagline;
  final String name;
  final int calories;
  final int mealsEaten;
}

class ActivityRings {
  const ActivityRings({
    required this.move,
    required this.moveGoal,
    required this.exercise,
    required this.exerciseGoal,
    required this.stand,
    required this.standGoal,
  });

  final int move;
  final int moveGoal;
  final int exercise;
  final int exerciseGoal;
  final int stand;
  final int standGoal;
}

class HealthData {
  const HealthData({
    required this.generatedAt,
    required this.meal,
    required this.bloodPressure,
    required this.bmi,
    required this.weightKg,
    required this.heightCm,
    required this.temperature,
    required this.sleep,
    required this.heartRate,
    required this.cgm,
    required this.waist,
    required this.spO2,
    required this.bloodSugar,
    required this.steps,
    required this.activeEnergy,
    required this.activity,
    required this.aiTip,
    required this.dailyCalories,
    required this.calorieTarget,
  });

  final DateTime generatedAt;
  final MealSummary meal;
  final DualWeeklySeries bloodPressure;
  final double bmi;
  final double weightKg;
  final double heightCm;
  final WeeklySeries temperature;
  final WeeklySeries sleep;
  final WeeklySeries heartRate;
  final WeeklySeries cgm;
  final WeeklySeries waist;
  final WeeklySeries spO2;
  final WeeklySeries bloodSugar;
  final WeeklySeries steps;
  final WeeklySeries activeEnergy;
  final ActivityRings activity;
  final String aiTip;
  final WeeklySeries dailyCalories;
  final int calorieTarget;
}

class HealthRepository {
  HealthRepository({int? seed})
      : _rand = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

  final Random _rand;

  HealthData load({DateTime? now}) {
    final today = now ?? DateTime.now();
    final weekdayZeroBased = today.weekday % 7;
    final sunday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: weekdayZeroBased));
    final dates = List.generate(
      7,
      (i) => DateTime(sunday.year, sunday.month, sunday.day + i),
    );

    WeeklySeries walk({
      required double start,
      required double step,
      required double minV,
      required double maxV,
      int decimals = 1,
    }) {
      var v = start;
      final points = <DailyPoint>[];
      for (int i = 0; i < 7; i++) {
        final delta = (_rand.nextDouble() - 0.5) * 2 * step;
        v = (v + delta).clamp(minV, maxV).toDouble();
        final rounded = double.parse(v.toStringAsFixed(decimals));
        points.add(DailyPoint(dates[i], rounded));
      }
      return WeeklySeries(points);
    }

    final sys = walk(start: 122, step: 5, minV: 105, maxV: 150);
    final dia = walk(start: 78, step: 3, minV: 65, maxV: 95);
    final temp =
        walk(start: 36.5, step: 0.12, minV: 36.1, maxV: 37.1, decimals: 1);
    final sleep =
        walk(start: 7.2, step: 0.7, minV: 4.5, maxV: 9.0, decimals: 1);
    final hr = walk(start: 70, step: 3, minV: 58, maxV: 92, decimals: 0);
    final cgm = walk(start: 108, step: 8, minV: 80, maxV: 160, decimals: 0);
    final waist = walk(
        start: 30.2, step: 0.15, minV: 29.5, maxV: 31.2, decimals: 1);
    final spO2 = walk(start: 97, step: 0.6, minV: 94, maxV: 99, decimals: 0);
    final bloodSugar =
        walk(start: 112, step: 7, minV: 85, maxV: 160, decimals: 0);
    final steps =
        walk(start: 7200, step: 1400, minV: 1800, maxV: 12500, decimals: 0);
    final energy =
        walk(start: 380, step: 85, minV: 120, maxV: 620, decimals: 0);
    final dailyCalories =
        walk(start: 1900, step: 180, minV: 1450, maxV: 2400, decimals: 0);

    return HealthData(
      generatedAt: today,
      meal: const MealSummary(
        tagline: 'วิเคราะห์อาหาร',
        name: 'อยากรู้ว่าอาหารนี้ดีต่อสุขภาพแค่ไหน? สแกนเลย!',
        calories: 1250,
        mealsEaten: 2,
      ),
      bloodPressure: DualWeeklySeries(primary: sys, secondary: dia),
      bmi: 19.5,
      weightKg: 60,
      heightCm: 175,
      temperature: temp,
      sleep: sleep,
      heartRate: hr,
      cgm: cgm,
      waist: waist,
      spO2: spO2,
      bloodSugar: bloodSugar,
      steps: steps,
      activeEnergy: energy,
      activity: const ActivityRings(
        move: 420,
        moveGoal: 600,
        exercise: 22,
        exerciseGoal: 30,
        stand: 8,
        standGoal: 12,
      ),
      aiTip:
          'Based on your recent health data, consider incorporating more fiber-rich foods like whole grains, fruits, and vegetables into your diet. Maintaining regular physical activity can also help improve your overall well-being.',
      dailyCalories: dailyCalories,
      calorieTarget: 2200,
    );
  }
}
