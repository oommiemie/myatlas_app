import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';
import 'call_screen.dart';
import 'care_giver_screen.dart';

/// A single active fall alert for one family member.
class FallAlert {
  const FallAlert({required this.detectedAt, required this.location});
  final DateTime detectedAt;
  final String location;
}

/// Mock global store for active fall alerts, keyed by member name.
/// Both the family list and detail screens listen to this so they react
/// in real time when the alert is triggered, acknowledged, or dismissed.
final ValueNotifier<Map<String, FallAlert>> fallAlertsStore =
    ValueNotifier<Map<String, FallAlert>>(_seed());

Map<String, FallAlert> _seed() => {
      'ปรีชา วงศ์สุวรรณ': FallAlert(
        detectedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        location: 'ห้องน้ำ ชั้น 2',
      ),
    };

FallAlert? fallAlertFor(String memberName) =>
    fallAlertsStore.value[memberName];

void clearFallAlertFor(String memberName) {
  final next = {...fallAlertsStore.value}..remove(memberName);
  fallAlertsStore.value = next;
}

void triggerFallAlertFor(String memberName, {String location = 'ห้องนอน'}) {
  fallAlertsStore.value = {
    ...fallAlertsStore.value,
    memberName: FallAlert(detectedAt: DateTime.now(), location: location),
  };
  HapticFeedback.heavyImpact();
}

String _timeAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return 'เมื่อสักครู่';
  if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
  if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
  return '${diff.inDays} วันที่แล้ว';
}

/// Animated red banner shown above the profile card when [member] has an
/// active fall alert. Tapping it opens [showFallAlertSheet].
class FallAlertBanner extends StatefulWidget {
  const FallAlertBanner({super.key, required this.member});
  final FamilyMember member;

  @override
  State<FallAlertBanner> createState() => _FallAlertBannerState();
}

class _FallAlertBannerState extends State<FallAlertBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, FallAlert>>(
      valueListenable: fallAlertsStore,
      builder: (_, store, __) {
        final alert = store[widget.member.name];
        if (alert == null) return const SizedBox.shrink();
        return PressEffect(
          onTap: () => showFallAlertSheet(
            context,
            member: widget.member,
            alert: alert,
          ),
          haptic: HapticKind.medium,
          scale: 0.985,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              final t = _pulse.value;
              return Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFE9E5), Color(0xFFFFD0C8)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFBC1B06)
                        .withValues(alpha: 0.45 + 0.25 * t),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBC1B06)
                          .withValues(alpha: 0.18 + 0.12 * t),
                      blurRadius: 18 + 6 * t,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _PulsingDot(t: t),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ตรวจพบการล้ม',
                            style: AppTypography.headline(
                                    const Color(0xFFBC1B06))
                                .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${alert.location} · ${_timeAgo(alert.detectedAt)}',
                            style: AppTypography.caption2(
                                    const Color(0xFF6D2010))
                                .copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBC1B06),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ดูรายละเอียด',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: CupertinoColors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 36 * (0.6 + 0.4 * t),
            height: 36 * (0.6 + 0.4 * t),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFBC1B06).withValues(alpha: 0.18 * (1 - t)),
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFBC1B06),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.exclamationmark,
              color: CupertinoColors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet showing fall details + emergency actions.
Future<void> showFallAlertSheet(
  BuildContext context, {
  required FamilyMember member,
  required FallAlert alert,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) =>
          _FallAlertSheet(member: member, alert: alert),
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

class _FallAlertSheet extends StatefulWidget {
  const _FallAlertSheet({required this.member, required this.alert});
  final FamilyMember member;
  final FallAlert alert;

  @override
  State<_FallAlertSheet> createState() => _FallAlertSheetState();
}

class _FallAlertSheetState extends State<_FallAlertSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  Future<void> _markSafe() async {
    HapticFeedback.mediumImpact();
    clearFallAlertFor(widget.member.name);
    if (!mounted) return;
    Navigator.of(context).pop();
    AppToast.success(context, 'ยืนยันแล้วว่าปลอดภัย');
  }

  void _callMember() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    showCallScreen(
      context,
      member: widget.member,
      type: CallType.voice,
      direction: CallDirection.outgoing,
    );
  }

  void _callEmergency() {
    HapticFeedback.heavyImpact();
    AppToast.warning(context, 'กำลังเชื่อมต่อสายด่วน 1669…');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final firstName = widget.member.name.split(' ').first;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBFA).withValues(alpha: 0.96),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text(
                            'แจ้งเตือนการล้ม',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: LiquidGlassButton(
                              icon: CupertinoIcons.xmark,
                              iconColor: const Color(0xFF1A1A1A),
                              onTap: _close,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + bottomInset),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) =>
                              _BigPulseIcon(t: _pulse.value),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'ตรวจพบการล้มของ $firstName',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'กรุณาตรวจสอบความปลอดภัยทันที',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF1A1A1A)
                                .withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _DetailCard(
                          alert: widget.alert,
                          member: widget.member,
                        ),
                        const SizedBox(height: 18),
                        _PrimaryActionButton(
                          icon: CupertinoIcons.phone_fill,
                          label: 'โทร 1669 (กู้ชีพ)',
                          color: const Color(0xFFBC1B06),
                          onTap: _callEmergency,
                        ),
                        const SizedBox(height: 10),
                        _PrimaryActionButton(
                          icon: CupertinoIcons.phone_circle_fill,
                          label: 'โทรหา $firstName',
                          color: const Color(0xFF1D8B6B),
                          onTap: _callMember,
                        ),
                        const SizedBox(height: 10),
                        _SecondaryActionButton(
                          label: 'ยืนยันว่าปลอดภัยแล้ว',
                          onTap: _markSafe,
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
    );
  }
}

class _BigPulseIcon extends StatelessWidget {
  const _BigPulseIcon({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 92 * (0.7 + 0.3 * t),
            height: 92 * (0.7 + 0.3 * t),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFBC1B06).withValues(alpha: 0.16 * (1 - t)),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B5A), Color(0xFFBC1B06)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBC1B06)
                      .withValues(alpha: 0.4 + 0.2 * t),
                  blurRadius: 22 + 6 * t,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: CupertinoColors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.alert, required this.member});
  final FallAlert alert;
  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _Row(
            icon: CupertinoIcons.location_solid,
            iconColor: const Color(0xFFBC1B06),
            label: 'ตำแหน่ง',
            value: alert.location,
          ),
          const _Divider(),
          _Row(
            icon: CupertinoIcons.time_solid,
            iconColor: const Color(0xFF6D756E),
            label: 'เวลา',
            value: _timeAgo(alert.detectedAt),
          ),
          const _Divider(),
          _Row(
            icon: CupertinoIcons.heart_fill,
            iconColor: const Color(0xFFEF6B7A),
            label: 'หัวใจ',
            value: '${member.heartRate} bpm',
          ),
          const _Divider(),
          _Row(
            icon: CupertinoIcons.wind,
            iconColor: const Color(0xFF0BA5EC),
            label: 'ออกซิเจนในเลือด',
            value: '${member.spo2}%',
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6D756E),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFF747480).withValues(alpha: 0.08),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      scale: 0.97,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.32),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: CupertinoColors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      scale: 0.97,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF747480).withValues(alpha: 0.15),
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.checkmark_shield_fill,
              color: Color(0xFF1D8B6B),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
