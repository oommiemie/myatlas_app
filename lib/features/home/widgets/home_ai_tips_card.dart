import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeAiTipsCard extends StatelessWidget {
  final String tip;
  final int normalCount;
  final int mediumCount;
  final int highCount;

  const HomeAiTipsCard({
    super.key,
    this.tip =
        'จากข้อมูลสุขภาพล่าสุด พบความดันโลหิตและระดับน้ำตาลในเลือดอยู่ในช่วงเสี่ยง แนะนำให้ลดอาหารเค็มและน้ำตาล เพิ่มผักใบเขียวและธัญพืชไม่ขัดสี พร้อมออกกำลังกายระดับปานกลางอย่างน้อย 30 นาที/วัน 5 วัน/สัปดาห์',
    this.normalCount = 5,
    this.mediumCount = 2,
    this.highCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.bgPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'คำแนะนำจาก AI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 20 / 14,
              letterSpacing: 0.14,
            ),
          ),
          const SizedBox(height: 16),
          _RiskBars(
            normal: normalCount,
            medium: mediumCount,
            high: highCount,
          ),
          const SizedBox(height: 16),
          const _HealthMetricsRow(),
        ],
      ),
    );
  }
}

class _RiskBars extends StatelessWidget {
  final int normal;
  final int medium;
  final int high;

  const _RiskBars({
    required this.normal,
    required this.medium,
    required this.high,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: normal,
          child: _BarBlock(
            label: 'ปกติ $normal',
            color: AppColors.success600,
          ),
        ),
        const SizedBox(width: 4),
        _BarBlock(
          label: 'ปานกลาง $medium',
          color: const Color(0xFFEAAA08),
          width: 70,
        ),
        const SizedBox(width: 4),
        _BarBlock(
          label: 'เสี่ยง $high',
          color: const Color(0xFFE62E05),
          width: 70,
        ),
      ],
    );
  }
}

class _BarBlock extends StatelessWidget {
  final String label;
  final Color color;
  final double? width;

  const _BarBlock({
    required this.label,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
    if (width != null) return SizedBox(width: width, child: column);
    return column;
  }
}

class _HealthMetricsRow extends StatelessWidget {
  const _HealthMetricsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HealthMetricChip(
          icon: Icons.monitor_heart_outlined,
          label: 'ความดันโลหิต',
          value: '145/95',
          unit: 'mmHg',
          iconBg: const Color(0xFFBC1B06),
        ),
        const SizedBox(width: 8),
        _HealthMetricChip(
          icon: Icons.water_drop_outlined,
          label: 'ค่าน้ำตาลในเลือด',
          value: '168',
          unit: 'mg/dL',
          iconBg: const Color(0xFFBC1B06),
        ),
      ],
    );
  }
}

class _HealthMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color iconBg;

  const _HealthMetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE62E05),
                  ),
                ),
                const TextSpan(text: ' ', style: TextStyle(fontSize: 10)),
                TextSpan(
                  text: unit,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
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
