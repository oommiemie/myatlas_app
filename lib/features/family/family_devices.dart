import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';

/// Devices a caregiver can pair to track a family member's health data.
enum DeviceKind {
  cgm(
    'เครื่องวัดน้ำตาลแบบต่อเนื่อง',
    'Dexcom · Libre · Medtronic Guardian',
    CupertinoIcons.drop_fill,
    Color(0xFFAF52DE),
  ),
  watch(
    'สมาร์ทวอทช์',
    'Apple Watch · Galaxy Watch · Garmin',
    CupertinoIcons.heart_circle_fill,
    Color(0xFFEF6B7A),
  ),
  bp(
    'เครื่องวัดความดัน',
    'Omron · iHealth · Xiaomi Mi BP',
    CupertinoIcons.heart_fill,
    Color(0xFFBE123C),
  ),
  spo2(
    'เครื่องวัดออกซิเจนปลายนิ้ว',
    'Pulse oximeter ทั่วไป',
    CupertinoIcons.wind,
    Color(0xFF0BA5EC),
  ),
  scale(
    'เครื่องชั่งน้ำหนัก',
    'Tanita · Withings · Mi Scale',
    CupertinoIcons.chart_pie_fill,
    Color(0xFF1D8B6B),
  ),
  thermometer(
    'เครื่องวัดอุณหภูมิ',
    'Infrared / digital thermometer',
    CupertinoIcons.thermometer,
    Color(0xFFEA580C),
  );

  const DeviceKind(this.label, this.brands, this.icon, this.tone);
  final String label;
  final String brands;
  final IconData icon;
  final Color tone;
}

/// Bottom sheet that lets the caregiver pair / unpair devices for a
/// family member. Mutates the [selected] set in place via [onChanged].
Future<void> showManageDevicesSheet(
  BuildContext context, {
  required Set<DeviceKind> selected,
  required ValueChanged<Set<DeviceKind>> onChanged,
  String memberName = '',
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => _ManageDevicesSheet(
        initial: selected,
        onChanged: onChanged,
        memberName: memberName,
      ),
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: anim,
              curve: Curves.fastEaseInToSlowEaseOut,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
          child: child,
        );
      },
    ),
  );
}

class _ManageDevicesSheet extends StatefulWidget {
  const _ManageDevicesSheet({
    required this.initial,
    required this.onChanged,
    required this.memberName,
  });
  final Set<DeviceKind> initial;
  final ValueChanged<Set<DeviceKind>> onChanged;
  final String memberName;

  @override
  State<_ManageDevicesSheet> createState() => _ManageDevicesSheetState();
}

class _ManageDevicesSheetState extends State<_ManageDevicesSheet> {
  late final Set<DeviceKind> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initial};
  }

  void _toggle(DeviceKind kind) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(kind)) {
        _selected.remove(kind);
      } else {
        _selected.add(kind);
        AppToast.success(context, 'เริ่มเชื่อมต่อ ${kind.label}');
      }
    });
  }

  void _save() {
    HapticFeedback.mediumImpact();
    widget.onChanged({..._selected});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final topInset = MediaQuery.paddingOf(context).top;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      resizeToAvoidBottomInset: false,
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA).withValues(alpha: 0.94),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(38)),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.white.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 38,
                      height: 5,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF1A1A1A).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text(
                            'จัดการอุปกรณ์',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: LiquidGlassButton(
                              icon: CupertinoIcons.xmark,
                              iconColor: const Color(0xFF1A1A1A),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: LiquidGlassButton(
                              icon: CupertinoIcons.check_mark,
                              iconColor: CupertinoColors.white,
                              tint: const Color(0xFF1D8B6B),
                              onTap: _save,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.memberName.isEmpty
                          ? 'เลือกอุปกรณ์ที่ใช้ติดตามข้อมูลสุขภาพ'
                          : 'เลือกอุปกรณ์ที่ใช้ติดตามข้อมูลของ ${widget.memberName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6D756E),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        16 + bottomInset,
                      ),
                      itemCount: DeviceKind.values.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final k = DeviceKind.values[i];
                        return DeviceTile(
                          kind: k,
                          connected: _selected.contains(k),
                          onTap: () => _toggle(k),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable tile showing a single device kind with connect/disconnect state.
class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.kind,
    required this.connected,
    required this.onTap,
  });
  final DeviceKind kind;
  final bool connected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.none,
      scale: 0.98,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: connected
              ? kind.tone.withValues(alpha: 0.08)
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: connected
                ? kind.tone.withValues(alpha: 0.5)
                : const Color(0xFF747480).withValues(alpha: 0.1),
            width: connected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kind.tone.withValues(alpha: connected ? 0.18 : 0.1),
              ),
              alignment: Alignment.center,
              child: Icon(kind.icon, color: kind.tone, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kind.label,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    kind.brands,
                    style: const TextStyle(
                      color: Color(0xFF6D756E),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (c, a) =>
                  ScaleTransition(scale: a, child: c),
              child: connected
                  ? Container(
                      key: const ValueKey('connected'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: kind.tone,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            CupertinoIcons.check_mark,
                            color: CupertinoColors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'เชื่อมแล้ว',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      key: const ValueKey('connect'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kind.tone.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'เชื่อมต่อ',
                        style: TextStyle(
                          color: kind.tone,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
