import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';

/// Devices a user / caregiver can pair to track health data.
///
/// Each device exposes [capabilities] — the list of metrics it can measure
/// (multi-capability devices like smartwatches, loop bands, smart rings).
enum DeviceKind {
  smartwatch(
    'Apple Watch Series 10',
    CupertinoIcons.heart_circle_fill,
    Color(0xFFEF6B7A),
    [
      'หัวใจ',
      'ออกซิเจน',
      'การนอน',
      'ก้าวเดิน',
      'ECG',
      'พลังงานที่ใช้',
    ],
  ),
  loopBand(
    'Mi Smart Band 8',
    CupertinoIcons.circle_grid_hex,
    Color(0xFF6B7AEF),
    ['หัวใจ', 'ออกซิเจน', 'การนอน', 'ก้าวเดิน', 'อุณหภูมิผิว'],
  ),
  smartRing(
    'Oura Ring Gen 3',
    CupertinoIcons.circle,
    Color(0xFFD49A1F),
    ['หัวใจ', 'ออกซิเจน', 'การนอน', 'อุณหภูมิผิว'],
  ),
  cgm(
    'Abbott FreeStyle Libre 3',
    CupertinoIcons.drop_fill,
    Color(0xFFAF52DE),
    ['น้ำตาลต่อเนื่อง'],
  ),
  bp(
    'Omron HEM-7361T',
    CupertinoIcons.heart_fill,
    Color(0xFFBE123C),
    ['ความดัน', 'หัวใจ'],
  ),
  spo2(
    'iHealth POD Air',
    CupertinoIcons.wind,
    Color(0xFF0BA5EC),
    ['ออกซิเจน', 'หัวใจ'],
  ),
  scale(
    'Withings Body+',
    CupertinoIcons.chart_pie_fill,
    Color(0xFF1D8B6B),
    ['น้ำหนัก', 'BMI', 'มวลกล้ามเนื้อ', 'ไขมัน'],
  ),
  thermometer(
    'Braun ThermoScan 7',
    CupertinoIcons.thermometer,
    Color(0xFFEA580C),
    ['อุณหภูมิ'],
  );

  const DeviceKind(
    this.label,
    this.icon,
    this.tone,
    this.capabilities,
  );
  final String label;
  final IconData icon;
  final Color tone;
  final List<String> capabilities;
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

  Widget _buildDeviceList(double bottomInset) {
    final connected =
        DeviceKind.values.where((k) => _selected.contains(k)).toList();
    final available =
        DeviceKind.values.where((k) => !_selected.contains(k)).toList();

    final items = <Object>[
      if (connected.isNotEmpty)
        _SectionHeader(
          label: 'เชื่อมต่อแล้ว',
          count: connected.length,
          tone: const Color(0xFF1D8B6B),
        ),
      ...connected,
      if (available.isNotEmpty) const _ScanningBanner(),
      ...available,
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + bottomInset),
      itemCount: items.length,
      separatorBuilder: (_, i) {
        final cur = items[i];
        // Tighter gap right after a section header or scanning banner.
        if (cur is _SectionHeader || cur is _ScanningBanner) {
          return const SizedBox(height: 6);
        }
        return const SizedBox(height: 10);
      },
      itemBuilder: (_, i) {
        final item = items[i];
        if (item is _SectionHeader) return item;
        if (item is _ScanningBanner) return item;
        final k = item as DeviceKind;
        return DeviceTile(
          kind: k,
          connected: _selected.contains(k),
          onTap: () => _toggle(k),
        );
      },
    );
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
                    child: _buildDeviceList(bottomInset),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF747480).withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kind.tone.withValues(alpha: 0.12),
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
                      if (connected) ...[
                        const SizedBox(height: 4),
                        _StatusLine(kind: kind, connected: connected),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _ConnectChip(kind: kind, connected: connected),
              ],
            ),
            const SizedBox(height: 12),
            _CapabilityChips(kind: kind, connected: connected),
          ],
        ),
      ),
    );
  }
}

class _ConnectChip extends StatelessWidget {
  const _ConnectChip({required this.kind, required this.connected});
  final DeviceKind kind;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    const theme = Color(0xFF1D8B6B);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
      child: connected
          ? Container(
              key: const ValueKey('connected'),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: theme,
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
                  color: theme.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'เชื่อมต่อ',
                style: TextStyle(
                  color: theme,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}

class _CapabilityChips extends StatelessWidget {
  const _CapabilityChips({required this.kind, required this.connected});
  final DeviceKind kind;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final fg = kind.tone;
    final bg = kind.tone.withValues(alpha: 0.10);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final cap in kind.capabilities)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              cap,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
      ],
    );
  }
}

class _ScanningBanner extends StatelessWidget {
  const _ScanningBanner();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CupertinoActivityIndicator(
              radius: 6,
              color: Color(0xFF8E8E93),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'กำลังค้นหาอุปกรณ์ใกล้เคียง…',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Plausible mock battery per device kind for the picker sheet.
int mockBatteryFor(DeviceKind k) {
  switch (k) {
    case DeviceKind.smartwatch:
      return 78;
    case DeviceKind.loopBand:
      return 64;
    case DeviceKind.smartRing:
      return 52;
    case DeviceKind.cgm:
      return 41;
    case DeviceKind.bp:
      return 92;
    case DeviceKind.spo2:
      return 28;
    case DeviceKind.scale:
      return 88;
    case DeviceKind.thermometer:
      return 15;
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.kind, required this.connected});
  final DeviceKind kind;
  final bool connected;

  Color _batteryColor(int pct) {
    if (pct >= 40) return const Color(0xFF1D8B6B);
    if (pct >= 20) return const Color(0xFFFF8904);
    return const Color(0xFFBC1B06);
  }

  IconData _batteryIcon(int pct) {
    if (pct >= 60) return CupertinoIcons.battery_75_percent;
    if (pct >= 20) return CupertinoIcons.battery_25_percent;
    return CupertinoIcons.battery_empty;
  }

  @override
  Widget build(BuildContext context) {
    if (!connected) {
      const tone = Color(0xFF0BA5EC);
      return Row(
        children: const [
          SizedBox(
            width: 10,
            height: 10,
            child: CupertinoActivityIndicator(radius: 5, color: tone),
          ),
          SizedBox(width: 6),
          Text(
            'พบสัญญาณ · พร้อมเชื่อมต่อ',
            style: TextStyle(
              color: tone,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
    }
    final pct = mockBatteryFor(kind);
    final color = _batteryColor(pct);
    return Row(
      children: [
        Icon(_batteryIcon(pct), color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          'แบต $pct%',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.tone,
  });
  final String label;
  final int count;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: tone,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: tone,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
