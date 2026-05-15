import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';

/// One row a user can choose to show / hide / reorder on the
/// "สรุปสุขภาพ" screen's vital signs section.
enum HealthMetricKey {
  bloodPressure(
    label: 'ความดันโลหิต',
    icon: CupertinoIcons.heart_fill,
    tone: Color(0xFFB7185E),
    unit: 'mmHg',
    hint: 'เช่น 120/80',
  ),
  bmi(
    label: 'น้ำหนัก',
    icon: CupertinoIcons.chart_pie_fill,
    tone: AppColors.nutrition,
    unit: 'kg',
    hint: 'เช่น 60',
  ),
  temperature(
    label: 'อุณหภูมิ',
    icon: CupertinoIcons.thermometer,
    tone: AppColors.mindfulness,
    unit: '°C',
    hint: 'เช่น 36.5',
  ),
  sleep(
    label: 'การนอน',
    icon: CupertinoIcons.moon_fill,
    tone: AppColors.sleep,
    unit: 'ชม.',
    hint: 'เช่น 7.5',
  ),
  heartRate(
    label: 'อัตราการเต้นหัวใจ',
    icon: CupertinoIcons.waveform_path_ecg,
    tone: AppColors.health,
    unit: 'bpm',
    hint: 'เช่น 72',
  ),
  cgm(
    label: 'น้ำตาลต่อเนื่อง',
    icon: CupertinoIcons.drop_fill,
    tone: AppColors.sleep,
    unit: 'mg/dl',
    hint: 'เช่น 120',
  ),
  waist(
    label: 'รอบเอว',
    icon: CupertinoIcons.circle_fill,
    tone: AppColors.nutrition,
    unit: 'นิ้ว',
    hint: 'เช่น 32',
  ),
  spo2(
    label: 'ออกซิเจนในเลือด',
    icon: CupertinoIcons.wind,
    tone: AppColors.mindfulness,
    unit: '%',
    hint: 'เช่น 98',
  ),
  bloodSugar(
    label: 'น้ำตาลในเลือด',
    icon: CupertinoIcons.drop_fill,
    tone: AppColors.health,
    unit: 'mg/dl',
    hint: 'เช่น 100',
  );

  const HealthMetricKey({
    required this.label,
    required this.icon,
    required this.tone,
    required this.unit,
    required this.hint,
  });

  final String label;
  final IconData icon;
  final Color tone;
  final String unit;
  final String hint;
}

/// Immutable snapshot of user preferences for the vital signs section.
class HealthMetricPrefs {
  const HealthMetricPrefs({required this.order, required this.pinned});

  /// Full ordering of every metric (whether pinned or not). The pinned
  /// subset is rendered on the screen in this order.
  final List<HealthMetricKey> order;

  /// Keys the user has chosen to display on the screen.
  final Set<HealthMetricKey> pinned;

  HealthMetricPrefs copyWith({
    List<HealthMetricKey>? order,
    Set<HealthMetricKey>? pinned,
  }) =>
      HealthMetricPrefs(
        order: order ?? this.order,
        pinned: pinned ?? this.pinned,
      );

  static HealthMetricPrefs initial() => HealthMetricPrefs(
        order: List<HealthMetricKey>.from(HealthMetricKey.values),
        pinned: HealthMetricKey.values.toSet(),
      );
}

/// Mock global store — in a real app this would persist via
/// SharedPreferences or a backend.
final ValueNotifier<HealthMetricPrefs> healthMetricPrefsStore =
    ValueNotifier<HealthMetricPrefs>(HealthMetricPrefs.initial());
