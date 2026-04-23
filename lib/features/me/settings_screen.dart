import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/services/app_strings.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';
import 'about_app_screen.dart';
import 'delete_account_screen.dart';
import 'display_settings_screen.dart';
import 'pin_setup_screen.dart';
import 'privacy_policy_screen.dart';
import 'report_issue_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  Widget _stagger(int i, int total, Widget child) {
    final start = (i / total) * 0.55;
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

  static const _danger = Color(0xFFDC2626);

  Future<void> _showLogoutSheet() async {
    HapticFeedback.selectionClick();
    final ok = await showCupertinoModalPopup<bool>(
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
                    const SizedBox(height: 20),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFB91C1C).withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        CupertinoIcons.square_arrow_right,
                        color: CupertinoColors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr(context, 'ออกจากระบบ?', 'Log out?'),
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        tr(
                          context,
                          'คุณต้องการออกจากระบบใช่หรือไม่? ข้อมูลที่ยังไม่ได้ซิงค์อาจหายไป',
                          'Are you sure you want to log out? Unsynced data may be lost.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF6D756E),
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          _SheetButton(
                            label: tr(context, 'ออกจากระบบ', 'Log Out'),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                            ),
                            textColor: CupertinoColors.white,
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              Navigator.of(ctx).pop(true);
                            },
                          ),
                          const SizedBox(height: 8),
                          _SheetButton(
                            label: tr(context, 'ยกเลิก', 'Cancel'),
                            backgroundColor: CupertinoColors.white,
                            textColor: const Color(0xFF1A1A1A),
                            onTap: () => Navigator.of(ctx).pop(false),
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
    if (ok == true && mounted) {
      // Logout logic placeholder — show confirmation toast / route to login.
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('ออกจากระบบแล้ว'),
          content: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('คุณได้ออกจากระบบเรียบร้อยแล้ว'),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE4F5F0), Color(0xFFF4F8F5)],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollUpdateNotification ||
                  n is ScrollStartNotification) {
                _scrollOffset.value = n.metrics.pixels;
              }
              return false;
            },
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 56 + 12,
                bottom: 40,
              ),
              children: [
                    _stagger(
                      0,
                      5,
                      _Section(
                        title: tr(context, 'ความปลอดภัย', 'Security'),
                        rows: [
                          _SettingRow(
                            iconColor: const Color(0xFF1D8B6B),
                            icon: CupertinoIcons.lock_fill,
                            label: tr(context, 'ตั้งค่า PIN', 'Set PIN'),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute<String>(
                                builder: (_) => const PinSetupScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _stagger(
                      1,
                      4,
                      _Section(
                        title: tr(context, 'แอพและอุปกรณ์', 'Apps & Devices'),
                        rows: [
                          _SettingRow(
                            iconColor: const Color(0xFF7C3AED),
                            icon: CupertinoIcons.circle_lefthalf_fill,
                            label: tr(context, 'การแสดงผล', 'Display'),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const DisplaySettingsScreen(),
                              ),
                            ),
                          ),
                          _SettingRow(
                            iconColor: const Color(0xFF2563EB),
                            icon: CupertinoIcons.device_phone_portrait,
                            label: tr(context, 'การเชื่อมต่ออุปกรณ์',
                                'Connected Devices'),
                            onTap: () {},
                          ),
                          _SettingRow(
                            iconColor: const Color(0xFF0EA5E9),
                            icon: CupertinoIcons.checkmark_shield_fill,
                            label: tr(context, 'นโยบายความเป็นส่วนตัว',
                                'Privacy Policy'),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const PrivacyPolicyScreen(),
                              ),
                            ),
                          ),
                          _SettingRow(
                            iconColor: const Color(0xFF6B7280),
                            icon: CupertinoIcons.app_fill,
                            label: tr(
                                context, 'เกี่ยวกับแอปพลิเคชั่น', 'About App'),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const AboutAppScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _stagger(
                      2,
                      4,
                      _Section(
                        title: tr(context, 'ช่วยเหลือ', 'Help'),
                        rows: [
                          _SettingRow(
                            iconColor: const Color(0xFFF59E0B),
                            icon: CupertinoIcons.exclamationmark_bubble_fill,
                            label: tr(context, 'รายงานปัญหาการใช้งาน',
                                'Report Issue'),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const ReportIssueScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _stagger(
                      3,
                      4,
                      _Section(
                        title: tr(context, 'เข้าสู่ระบบ', 'Account'),
                        rows: [
                          _SettingRow(
                            iconColor: const Color(0xFF9333EA),
                            icon: CupertinoIcons.person_badge_minus_fill,
                            label: tr(context, 'ลบบัญชี', 'Delete Account'),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const DeleteAccountScreen(),
                              ),
                            ),
                          ),
                          _SettingRow(
                            iconColor: _danger,
                            icon: CupertinoIcons.square_arrow_right,
                            label: tr(context, 'ออกจากระบบ', 'Log Out'),
                            onTap: _showLogoutSheet,
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (_, offset, __) => _PinnedTopBar(
                title: tr(context, 'ตั้งค่า', 'Settings'),
                scrollOffset: offset,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedTopBar extends StatelessWidget {
  const _PinnedTopBar({
    required this.title,
    required this.scrollOffset,
    required this.onBack,
  });
  final String title;
  final double scrollOffset;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final progress = (scrollOffset / 60).clamp(0.0, 1.0);
    final barHeight = top + 6 + 44 + 6;
    return Stack(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22 * progress,
              sigmaY: 22 * progress,
            ),
            child: Container(
              height: barHeight,
              color:
                  const Color(0xFFF4F8F5).withValues(alpha: 0.80 * progress),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: progress,
            child: Container(
              height: 0.5,
              color: CupertinoColors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: top + 6, left: 14, right: 14),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.chevron_back,
                    onTap: onBack,
                    size: 40,
                    iconSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.textColor,
    required this.onTap,
    this.gradient,
    this.backgroundColor,
  });
  final String label;
  final Color textColor;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.none,
      scale: 0.97,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(100),
          boxShadow: gradient != null
              ? [
                  BoxShadow(
                    color: const Color(0xFFB91C1C).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});
  final String title;
  final List<_SettingRow> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF747480).withValues(alpha: 0.08),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i != rows.length - 1)
                    Container(
                      height: 1,
                      color: const Color(0xFFE5E5E5),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final Color iconColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.99,
      dim: 0.96,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: CupertinoColors.white,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: CupertinoColors.white, size: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.275,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 12,
              color: Color(0xFF6D756E),
            ),
          ],
        ),
      ),
    );
  }
}
