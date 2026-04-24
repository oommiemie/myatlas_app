import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/press_effect.dart';
import 'add_vital_sign_sheet.dart';
import 'measure_animations.dart';
import 'measure_from_device_sheet.dart';

/// Unified entry point for "add measurement" — first asks the user whether
/// to enter manually or pair with a device, then opens the right flow.
Future<VitalMeasurement?> showAddMeasurement(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color color,
  required List<VitalFieldConfig> fields,
  required MeasureAnimationKind animation,
}) async {
  final method = await _showMethodPicker(context, color);
  if (method == null || !context.mounted) return null;
  if (method == _AddMethod.manual) {
    return showAddVitalSignSheet(
      context,
      title: title,
      icon: icon,
      color: color,
      fields: fields,
    );
  }
  return showMeasureFromDeviceSheet(
    context,
    title: title,
    icon: icon,
    color: color,
    fields: fields,
    animation: animation,
  );
}

enum _AddMethod { manual, device }

Future<_AddMethod?> _showMethodPicker(BuildContext context, Color accent) {
  return showCupertinoModalPopup<_AddMethod>(
    context: context,
    barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FA).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(38),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(
                      'เลือกวิธีเพิ่มข้อมูล',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      'กรอกเองหรือเชื่อมต่อกับอุปกรณ์',
                      style: TextStyle(
                        color: Color(0xFF6D756E),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MethodCard(
                            icon: CupertinoIcons.pencil_ellipsis_rectangle,
                            title: 'กรอกเอง',
                            subtitle: 'บันทึกข้อมูลที่วัดเรียบร้อยแล้ว',
                            color: accent,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(ctx).pop(_AddMethod.manual);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MethodCard(
                            icon: CupertinoIcons.bluetooth,
                            title: 'เชื่อมต่ออุปกรณ์',
                            subtitle: 'เริ่มวัดจากอุปกรณ์ที่รองรับ',
                            color: accent,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(ctx).pop(_AddMethod.device);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.none,
      scale: 0.97,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF6D756E),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
