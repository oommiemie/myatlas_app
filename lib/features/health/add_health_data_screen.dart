import 'package:flutter/cupertino.dart';

import '../../core/widgets/app_toast.dart';
import 'health_metric_prefs.dart';
import 'widgets/add_vital_sign_sheet.dart';
import 'widgets/measure_animations.dart';

/// Open the manual-entry page directly (skipping the manual / device
/// picker) for [initial]. Reused by the + buttons on the summary screen.
Future<void> showAddHealthDataScreen(
  BuildContext context, {
  required HealthMetricKey initial,
}) async {
  final cfg = _configFor(initial);
  final result = await showAddVitalSignSheet(
    context,
    title: cfg.title,
    icon: cfg.icon,
    color: cfg.color,
    fields: cfg.fields,
  );
  if (result != null && context.mounted) {
    AppToast.success(context, cfg.successMessage);
  }
}

class _AddCfg {
  const _AddCfg({
    required this.title,
    required this.icon,
    required this.color,
    required this.animation,
    required this.fields,
    required this.successMessage,
  });
  final String title;
  final IconData icon;
  final Color color;
  final MeasureAnimationKind animation;
  final List<VitalFieldConfig> fields;
  final String successMessage;
}

_AddCfg _configFor(HealthMetricKey k) {
  switch (k) {
    case HealthMetricKey.bloodPressure:
      return const _AddCfg(
        title: 'เพิ่มความดันโลหิต',
        icon: CupertinoIcons.heart_fill,
        color: Color(0xFFBE123C),
        animation: MeasureAnimationKind.pressureCuff,
        fields: [
          VitalFieldConfig(
            label: 'ค่าบน (Systolic)',
            placeholder: '120',
            unit: 'mmHg',
          ),
          VitalFieldConfig(
            label: 'ค่าล่าง (Diastolic)',
            placeholder: '80',
            unit: 'mmHg',
          ),
        ],
        successMessage: 'บันทึกค่าความดันแล้ว',
      );
    case HealthMetricKey.bmi:
      return const _AddCfg(
        title: 'เพิ่มดัชนีมวลกาย',
        icon: CupertinoIcons.chart_bar_alt_fill,
        color: Color(0xFF1D8B6B),
        animation: MeasureAnimationKind.scale,
        fields: [
          VitalFieldConfig(
            label: 'น้ำหนัก',
            placeholder: '65',
            unit: 'kg',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          VitalFieldConfig(
            label: 'ส่วนสูง',
            placeholder: '170',
            unit: 'cm',
          ),
        ],
        successMessage: 'บันทึกดัชนีมวลกายแล้ว',
      );
    case HealthMetricKey.temperature:
      return const _AddCfg(
        title: 'เพิ่มอุณหภูมิ',
        icon: CupertinoIcons.thermometer,
        color: Color(0xFF2563EB),
        animation: MeasureAnimationKind.thermometer,
        fields: [
          VitalFieldConfig(
            label: 'อุณหภูมิ',
            placeholder: '36.5',
            unit: '°C',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        successMessage: 'บันทึกอุณหภูมิแล้ว',
      );
    case HealthMetricKey.sleep:
      return const _AddCfg(
        title: 'เพิ่มการนอน',
        icon: CupertinoIcons.moon_zzz_fill,
        color: Color(0xFF6366F1),
        animation: MeasureAnimationKind.sleep,
        fields: [
          VitalFieldConfig(
            label: 'ชั่วโมงนอน',
            placeholder: '8',
            unit: 'ชม.',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        successMessage: 'บันทึกการนอนแล้ว',
      );
    case HealthMetricKey.heartRate:
      return const _AddCfg(
        title: 'เพิ่มอัตราการเต้นหัวใจ',
        icon: CupertinoIcons.heart_fill,
        color: Color(0xFFBE123C),
        animation: MeasureAnimationKind.ecg,
        fields: [
          VitalFieldConfig(
            label: 'อัตราการเต้นหัวใจ',
            placeholder: '72',
            unit: 'bpm',
          ),
        ],
        successMessage: 'บันทึกอัตราการเต้นหัวใจแล้ว',
      );
    case HealthMetricKey.cgm:
      return const _AddCfg(
        title: 'เพิ่มค่าน้ำตาลต่อเนื่อง',
        icon: CupertinoIcons.waveform_path_ecg,
        color: Color(0xFFF59E0B),
        animation: MeasureAnimationKind.sugarDrop,
        fields: [
          VitalFieldConfig(
            label: 'น้ำตาลต่อเนื่อง (CGM)',
            placeholder: '100',
            unit: 'mg/dL',
          ),
        ],
        successMessage: 'บันทึกค่าน้ำตาลต่อเนื่องแล้ว',
      );
    case HealthMetricKey.waist:
      return const _AddCfg(
        title: 'เพิ่มรอบเอว',
        icon: CupertinoIcons.rectangle_compress_vertical,
        color: Color(0xFF9333EA),
        animation: MeasureAnimationKind.tape,
        fields: [
          VitalFieldConfig(
            label: 'รอบเอว',
            placeholder: '82',
            unit: 'cm',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        successMessage: 'บันทึกรอบเอวแล้ว',
      );
    case HealthMetricKey.spo2:
      return const _AddCfg(
        title: 'เพิ่มออกซิเจนในเลือด',
        icon: CupertinoIcons.heart_circle_fill,
        color: Color(0xFF0891B2),
        animation: MeasureAnimationKind.pulseOx,
        fields: [
          VitalFieldConfig(
            label: 'ออกซิเจนในเลือด',
            placeholder: '98',
            unit: '%',
          ),
        ],
        successMessage: 'บันทึกออกซิเจนในเลือดแล้ว',
      );
    case HealthMetricKey.bloodSugar:
      return const _AddCfg(
        title: 'เพิ่มน้ำตาลในเลือด',
        icon: CupertinoIcons.drop_fill,
        color: Color(0xFFEA580C),
        animation: MeasureAnimationKind.sugarDrop,
        fields: [
          VitalFieldConfig(
            label: 'น้ำตาลในเลือด',
            placeholder: '100',
            unit: 'mg/dL',
          ),
        ],
        successMessage: 'บันทึกค่าน้ำตาลแล้ว',
      );
  }
}
