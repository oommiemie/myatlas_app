import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';
import '../health/widgets/health_detail_app_bar.dart';

class BehaviorScreen extends StatefulWidget {
  const BehaviorScreen({super.key});

  @override
  State<BehaviorScreen> createState() => _BehaviorScreenState();
}

class _BehaviorScreenState extends State<BehaviorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);
  bool _trackNutrition = true;

  DateTime _morning = DateTime(2026, 1, 1, 6, 20);
  DateTime _noon = DateTime(2026, 1, 1, 12, 0);
  DateTime _evening = DateTime(2026, 1, 1, 19, 0);
  DateTime _night = DateTime(2026, 1, 1, 22, 0);
  Duration _reminderBefore = const Duration(minutes: 30);

  static const _reminderOptions = <({Duration value, String label})>[
    (value: Duration(minutes: 5), label: '5 นาที'),
    (value: Duration(minutes: 10), label: '10 นาที'),
    (value: Duration(minutes: 20), label: '20 นาที'),
    (value: Duration(minutes: 30), label: '30 นาที'),
    (value: Duration(hours: 1), label: '1 ชั่วโมง'),
  ];

  String get _reminderLabel =>
      _reminderOptions
          .firstWhere(
            (o) => o.value == _reminderBefore,
            orElse: () => _reminderOptions.first,
          )
          .label;

  Future<void> _pickReminder() async {
    Duration temp = _reminderBefore;
    await showCupertinoModalPopup<void>(
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
                child: StatefulBuilder(
                  builder: (ctx, setInner) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          width: 36,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A)
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            LiquidGlassButton(
                              icon: CupertinoIcons.xmark,
                              iconColor: const Color(0xFF1A1A1A),
                              onTap: () => Navigator.of(ctx).pop(),
                            ),
                            const Expanded(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    'เตือนให้ทานก่อน',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            LiquidGlassButton(
                              icon: CupertinoIcons.check_mark,
                              iconColor: CupertinoColors.white,
                              tint: const Color(0xFF1D8B6B),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() => _reminderBefore = temp);
                                Navigator.of(ctx).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < _reminderOptions.length;
                                  i++) ...[
                                PressEffect(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setInner(() =>
                                        temp = _reminderOptions[i].value);
                                  },
                                  haptic: HapticKind.none,
                                  scale: 0.99,
                                  dim: 0.96,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    color: CupertinoColors.white,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _reminderOptions[i].label,
                                            style: const TextStyle(
                                              color: Color(0xFF1A1A1A),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.275,
                                            ),
                                          ),
                                        ),
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                              milliseconds: 180),
                                          child: temp ==
                                                  _reminderOptions[i].value
                                              ? const Icon(
                                                  CupertinoIcons.check_mark,
                                                  key: ValueKey('on'),
                                                  size: 20,
                                                  color: Color(0xFF1D8B6B),
                                                )
                                              : const SizedBox(
                                                  key: ValueKey('off'),
                                                  width: 20,
                                                  height: 20,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (i != _reminderOptions.length - 1)
                                  Container(
                                    height: 1,
                                    color: const Color(0xFFE5E5E5),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} น.';

  Future<void> _pickTime({
    required String label,
    required DateTime initial,
    required ValueChanged<DateTime> onSet,
  }) async {
    DateTime temp = initial;
    await showCupertinoModalPopup<void>(
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
                    // iOS-style grabber handle
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          LiquidGlassButton(
                            icon: CupertinoIcons.xmark,
                            iconColor: const Color(0xFF1A1A1A),
                            onTap: () => Navigator.of(ctx).pop(),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          LiquidGlassButton(
                            icon: CupertinoIcons.check_mark,
                            iconColor: CupertinoColors.white,
                            tint: const Color(0xFF1D8B6B),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              onSet(temp);
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: initial,
                        use24hFormat: true,
                        minuteInterval: 1,
                        backgroundColor: const Color(0x00000000),
                        onDateTimeChanged: (v) => temp = v,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
    final start = (i / total) * 0.5;
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
            child: DetailHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Column(
            children: [
              const SizedBox(height: HealthDetailAppBar.safeAreaContentHeight),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F8F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: NotificationListener<ScrollNotification>(
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    children: [
                    _stagger(
                      0,
                      3,
                      _IntroCard(
                        morning: _morning,
                        noon: _noon,
                        evening: _evening,
                        night: _night,
                        format: _fmt,
                        onEditMorning: () => _pickTime(
                          label: 'เมื้อเช้า',
                          initial: _morning,
                          onSet: (v) => setState(() => _morning = v),
                        ),
                        onEditNoon: () => _pickTime(
                          label: 'เมื้อกลางวัน',
                          initial: _noon,
                          onSet: (v) => setState(() => _noon = v),
                        ),
                        onEditEvening: () => _pickTime(
                          label: 'เมื้อเย็น',
                          initial: _evening,
                          onSet: (v) => setState(() => _evening = v),
                        ),
                        onEditNight: () => _pickTime(
                          label: 'เวลานอน',
                          initial: _night,
                          onSet: (v) => setState(() => _night = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _stagger(
                      1,
                      3,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(
                          'กำหนด',
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    _stagger(
                      2,
                      3,
                      Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _SettingRow(
                              iconColor: const Color(0xFF1D8B6B),
                              icon: CupertinoIcons.capsule_fill,
                              label: 'เตือนให้ทานก่อน',
                              value: _reminderLabel,
                              onTap: _pickReminder,
                            ),
                            Container(
                              height: 1,
                              color: const Color(0xFFE5E5E5),
                            ),
                            _ToggleRow(
                              iconColor: const Color(0xFF2563EB),
                              icon: CupertinoIcons.square_fill_line_vertical_square_fill,
                              label: 'ติดตามโภชนาการ',
                              value: _trackNutrition,
                              onChanged: (v) =>
                                  setState(() => _trackNutrition = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ],
                    ),
                  ),
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
              builder: (_, offset, __) => HealthDetailAppBar(
                title: 'พฤติกรรมผู้ใช้งาน',
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

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.morning,
    required this.noon,
    required this.evening,
    required this.night,
    required this.format,
    required this.onEditMorning,
    required this.onEditNoon,
    required this.onEditEvening,
    required this.onEditNight,
  });
  final DateTime morning;
  final DateTime noon;
  final DateTime evening;
  final DateTime night;
  final String Function(DateTime) format;
  final VoidCallback onEditMorning;
  final VoidCallback onEditNoon;
  final VoidCallback onEditEvening;
  final VoidCallback onEditNight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'ให้เราช่วยดูแลสุขภาพของคุณ เพียงตั้งเวลาอาหารและเวลานอน ระบบจะช่วยเตือนทุกอย่างให้ตรงเวลา',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0.14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 300,
              height: 300,
              child: _DayPie(
                morningLabel: 'เมื้อเช้า ${format(morning)}',
                noonLabel: 'เมื้อกลางวัน ${format(noon)}',
                eveningLabel: 'เมื้อเย็น ${format(evening)}',
                nightLabel: 'เวลานอน ${format(night)}',
                onEditMorning: onEditMorning,
                onEditNoon: onEditNoon,
                onEditEvening: onEditEvening,
                onEditNight: onEditNight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPie extends StatelessWidget {
  const _DayPie({
    required this.morningLabel,
    required this.noonLabel,
    required this.eveningLabel,
    required this.nightLabel,
    required this.onEditMorning,
    required this.onEditNoon,
    required this.onEditEvening,
    required this.onEditNight,
  });
  final String morningLabel;
  final String noonLabel;
  final String eveningLabel;
  final String nightLabel;
  final VoidCallback onEditMorning;
  final VoidCallback onEditNoon;
  final VoidCallback onEditEvening;
  final VoidCallback onEditNight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          left: 0,
          top: 0,
          child: _Quadrant(
            corner: _QuadrantCorner.topLeft,
            gradientBegin: Alignment.bottomRight,
            gradientEnd: Alignment.topLeft,
            colors: [Color(0xFFB9E6FE), Color(0xFF7CD4FD)],
            orb: _OrbStyle.sun,
          ),
        ),
        const Positioned(
          right: 0,
          top: 0,
          child: _Quadrant(
            corner: _QuadrantCorner.topRight,
            gradientBegin: Alignment.bottomLeft,
            gradientEnd: Alignment.topRight,
            colors: [Color(0xFFFFD6AE), Color(0xFFFF9C66)],
            orb: _OrbStyle.noon,
          ),
        ),
        const Positioned(
          left: 0,
          bottom: 0,
          child: _Quadrant(
            corner: _QuadrantCorner.bottomLeft,
            gradientBegin: Alignment.topRight,
            gradientEnd: Alignment.bottomLeft,
            colors: [Color(0xFF065986), Color(0xFF0B4A6F)],
            orb: _OrbStyle.moon,
          ),
        ),
        const Positioned(
          left: 0,
          bottom: 0,
          width: 150,
          height: 150,
          child: _NightStars(),
        ),
        const Positioned(
          right: 0,
          bottom: 0,
          child: _Quadrant(
            corner: _QuadrantCorner.bottomRight,
            gradientBegin: Alignment.topLeft,
            gradientEnd: Alignment.bottomRight,
            colors: [Color(0xFFC7D2FE), Color(0xFF818CF8)],
            orb: _OrbStyle.dusk,
          ),
        ),
        // Time pills — tappable, anchored near the centerline with gap.
        Positioned(
          top: 96,
          right: 160,
          child: _TimePill(text: morningLabel, onTap: onEditMorning),
        ),
        Positioned(
          top: 96,
          left: 160,
          child: _TimePill(text: noonLabel, onTap: onEditNoon),
        ),
        Positioned(
          top: 230,
          right: 160,
          child: _TimePill(text: nightLabel, onTap: onEditNight),
        ),
        Positioned(
          top: 230,
          left: 160,
          child: _TimePill(text: eveningLabel, onTap: onEditEvening),
        ),
      ],
    );
  }
}

enum _QuadrantCorner { topLeft, topRight, bottomLeft, bottomRight }

enum _OrbStyle { sun, noon, moon, dusk }

class _Quadrant extends StatelessWidget {
  const _Quadrant({
    required this.corner,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.colors,
    required this.orb,
  });

  final _QuadrantCorner corner;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final List<Color> colors;
  final _OrbStyle orb;

  BorderRadius get _radius => switch (corner) {
        _QuadrantCorner.topLeft => const BorderRadius.only(
            topLeft: Radius.circular(1000),
          ),
        _QuadrantCorner.topRight => const BorderRadius.only(
            topRight: Radius.circular(1000),
          ),
        _QuadrantCorner.bottomLeft => const BorderRadius.only(
            bottomLeft: Radius.circular(1000),
          ),
        _QuadrantCorner.bottomRight => const BorderRadius.only(
            bottomRight: Radius.circular(1000),
          ),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: _radius,
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: colors,
          stops: const [0.3, 1.0],
        ),
        border: Border.all(color: CupertinoColors.white, width: 1),
      ),
      child: _OrbDecoration(orb: orb),
    );
  }
}

class _OrbDecoration extends StatefulWidget {
  const _OrbDecoration({required this.orb});
  final _OrbStyle orb;

  @override
  State<_OrbDecoration> createState() => _OrbDecorationState();
}

class _OrbDecorationState extends State<_OrbDecoration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = Curves.easeOutCubic.transform(_ctrl.value);
          final opacity = t;
          double translateY = 0;
          double scale = 1;

          switch (widget.orb) {
            case _OrbStyle.sun:
              // Morning: sun rises from below
              translateY = (1 - t) * 40;
              break;
            case _OrbStyle.noon:
              // Noon: sun expands outward
              scale = 0.4 + 0.6 * t;
              break;
            case _OrbStyle.dusk:
              // Evening: sun drifts down into place
              translateY = -(1 - t) * 40;
              break;
            case _OrbStyle.moon:
              // Night: moon rises from below
              translateY = (1 - t) * 40;
              break;
          }

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, translateY),
              child: Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: _buildOrb(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrb() {
    switch (widget.orb) {
      case _OrbStyle.sun:
        return _concentricOrb(
          outer: CupertinoColors.white.withValues(alpha: 0.5),
          mid: CupertinoColors.white.withValues(alpha: 0.55),
          inner: const Color(0xFFFFFDF0),
        );
      case _OrbStyle.noon:
        return _concentricOrb(
          outer: const Color(0xFFFFFCDB).withValues(alpha: 0.5),
          mid: const Color(0xFFFFFCDB).withValues(alpha: 0.55),
          inner: CupertinoColors.white,
        );
      case _OrbStyle.moon:
        return _concentricOrb(
          outer: CupertinoColors.white.withValues(alpha: 0.2),
          mid: CupertinoColors.white.withValues(alpha: 0.28),
          inner: CupertinoColors.white.withValues(alpha: 0.95),
          crescent: true,
        );
      case _OrbStyle.dusk:
        return _concentricOrb(
          outer: const Color(0xFFE3D8F8).withValues(alpha: 0.5),
          mid: const Color(0xFFE3D8F8).withValues(alpha: 0.55),
          inner: CupertinoColors.white,
        );
    }
  }

  Widget _concentricOrb({
    required Color outer,
    required Color mid,
    required Color inner,
    bool crescent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: outer,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: mid,
        ),
        child: crescent
            ? ClipOval(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: inner,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -6,
                      top: -4,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0B4A6F),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inner,
                ),
              ),
      ),
    );
  }
}

class _NightStars extends StatefulWidget {
  const _NightStars();

  @override
  State<_NightStars> createState() => _NightStarsState();
}

class _NightStarsState extends State<_NightStars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Positions (x, y) within 150x150 quadrant; size in px.
  static const _stars = <({double x, double y, double size, double begin})>[
    (x: 22, y: 28, size: 2.5, begin: 0.10),
    (x: 48, y: 12, size: 1.8, begin: 0.20),
    (x: 82, y: 22, size: 2.2, begin: 0.30),
    (x: 110, y: 36, size: 1.6, begin: 0.45),
    (x: 128, y: 60, size: 2.0, begin: 0.55),
    (x: 14, y: 58, size: 1.6, begin: 0.40),
    (x: 30, y: 92, size: 1.8, begin: 0.65),
    (x: 102, y: 88, size: 2.4, begin: 0.70),
    (x: 132, y: 112, size: 1.6, begin: 0.80),
    (x: 64, y: 44, size: 1.4, begin: 0.25),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;
          return Stack(
            children: [
              for (final s in _stars)
                Positioned(
                  left: s.x,
                  top: s.y,
                  child: Opacity(
                    opacity: ((t - s.begin) / (1 - s.begin)).clamp(0.0, 1.0),
                    child: Container(
                      width: s.size,
                      height: s.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CupertinoColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.white
                                .withValues(alpha: 0.6),
                            blurRadius: s.size * 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.text, this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap ?? () {},
      haptic: onTap != null ? HapticKind.selection : HapticKind.none,
      scale: onTap != null ? 0.94 : 1.0,
      dim: onTap != null ? 0.92 : 1.0,
      borderRadius: BorderRadius.circular(100),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.black.withValues(alpha: 0.30),
                  CupertinoColors.black.withValues(alpha: 0.38),
                ],
              ),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.18),
                width: 0.6,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.clock,
                  size: 14,
                  color: CupertinoColors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1,
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;
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
                  color: Color(0xFF6D756E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.275,
              ),
            ),
            const SizedBox(width: 10),
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

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final Color iconColor;
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                color: Color(0xFF6D756E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: const Color(0xFF34C759),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
