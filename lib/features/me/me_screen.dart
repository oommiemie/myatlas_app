import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_typography.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';
import '../appointment/appointment_screen.dart';
import '../health/health_assessment_screen.dart';
import 'allergy_screen.dart';
import 'behavior_screen.dart';
import 'chronic_disease_screen.dart';
import 'dental_screen.dart';
import 'insurance_screen.dart';
import 'opd/opd_registry_screen.dart';
import 'profile_screen.dart' show ProfileScreen, ProfileAvatarImage;
import 'settings_screen.dart';
import 'treatment/treatment_screen.dart';
import 'vaccine_screen.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _stagger(int index, int total, Widget child) {
    final start = (index / total) * 0.5;
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
    const bg = Color(0xFFF4F8F5);
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('ฉัน'),
            backgroundColor: bg.withValues(alpha: 0.85),
            border: null,
            trailing: LiquidGlassButton(
              icon: CupertinoIcons.gear,
              onTap: () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              ),
              size: 36,
              iconSize: 18,
              iconColor: const Color(0xFF1D8B6B),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: _stagger(0, 4, const _ProfileBanner()),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _stagger(
                  1,
                  5,
                  _MenuSection(
                    title: 'แบบคัดกรอง/ประเมิน',
                    items: [
                      _MenuEntry(
                        iconColor: const Color(0xFF9333EA),
                        icon: CupertinoIcons.doc_text,
                        title: 'แบบประเมินสุขภาพ',
                        subtitle: 'แบบประเมินสุขภาพ/คัดกรอง',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const HealthAssessmentScreen(),
                          ),
                        ),
                      ),
                      _MenuEntry(
                        iconColor: const Color(0xFFEA580C),
                        icon: CupertinoIcons.waveform_path_ecg,
                        title: 'OPD Registry',
                        subtitle: 'ลงทะเบียนคัดกรองคัดกรองด้วยตนเอง',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const OpdRegistryScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _stagger(
                  2,
                  5,
                  _MenuSection(
                    title: 'นัดหมาย',
                    items: [
                      _MenuEntry(
                        iconColor: const Color(0xFF1D8B6B),
                        icon: CupertinoIcons.calendar,
                        title: 'ใบนัดหมาย',
                        subtitle: 'นัดหมายจากแพทย์และนัดหมายเยี่ยมบ้าน',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const AppointmentScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _stagger(
                  3,
                  5,
                  _MenuSection(
                    title: 'ประวัติสุขภาพ',
                    items: [
                      _MenuEntry(
                        iconColor: const Color(0xFFE32616),
                        icon: CupertinoIcons.bandage_fill,
                        title: 'แพ้ยา/แพ้อาหาร',
                        subtitle: 'ประวัติการแพ้ยาและระดับความรุนแรง',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const AllergyScreen(),
                          ),
                        ),
                      ),
                      _MenuEntry(
                        iconColor: const Color(0xFF7C3AED),
                        icon: CupertinoIcons.plus_app_fill,
                        title: 'ประวัติการรักษา',
                        subtitle: 'ประวัติการรักษาและการใช้ยา',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const TreatmentScreen(),
                          ),
                        ),
                      ),
                      _MenuEntry(
                        iconColor: const Color(0xFFE32616),
                        icon: CupertinoIcons.heart_fill,
                        title: 'โรคประจำตัว',
                        subtitle: 'โรคประจำตัวที่ต้องได้รับการดูแลต่อเนื่อง',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const ChronicDiseaseScreen(),
                          ),
                        ),
                      ),
                      _MenuEntry(
                        iconColor: const Color(0xFF2563EB),
                        svgAsset: 'assets/images/me/syringe.svg',
                        title: 'การได้รับวัคซีน',
                        subtitle: 'ประวัติการรับวัคซีน',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const VaccineScreen(),
                          ),
                        ),
                      ),
                      _MenuEntry(
                        iconColor: const Color(0xFF2563EB),
                        icon: CupertinoIcons.square_favorites_alt_fill,
                        title: 'ข้อมูลทันตกรรม',
                        subtitle: 'ประวัติการตรวจสุขภาพช่องปาก',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const DentalScreen(),
                          ),
                        ),
                      ),
                      _MenuEntry(
                        iconColor: const Color(0xFF1D8B6B),
                        icon: CupertinoIcons.checkmark_shield_fill,
                        title: 'สิทธิการรักษา/ประกัน',
                        subtitle: 'สิทธิ์ในการรับการรักษาพยาบาล',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const InsuranceScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _stagger(
                  4,
                  5,
                  _MenuSection(
                    title: 'พฤติกรรม',
                    items: [
                      _MenuEntry(
                        iconColor: const Color(0xFF9333EA),
                        icon: CupertinoIcons.clock_fill,
                        title: 'พฤติกรรมผู้ใช้งาน',
                        subtitle:
                            'อัพเดทข้อมูลพฤกรรม เพื่อวิเคราะห์การใช้ชีวิตของคุณ',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const BehaviorScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBanner extends StatefulWidget {
  const _ProfileBanner();

  @override
  State<_ProfileBanner> createState() => _ProfileBannerState();
}

class _ProfileBannerState extends State<_ProfileBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ringCtrl.forward());
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            const Positioned.fill(child: _MeshGradient()),
            // shimmer highlight on top
            Positioned(
              left: -40,
              top: -60,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.4,
                  child: Container(
                    width: 320,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          CupertinoColors.white.withValues(alpha: 0),
                          CupertinoColors.white.withValues(alpha: 0.18),
                          CupertinoColors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // inner border for glass feel
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: CupertinoColors.white.withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WellnessAvatar(progress: _ringCtrl),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'GOOD MORNING',
                                style: TextStyle(
                                  color: CupertinoColors.white
                                      .withValues(alpha: 0.7),
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'คุณณัฐพงษ์',
                                      style: AppTypography.headline(
                                        CupertinoColors.white,
                                      ).copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                        height: 1.1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    CupertinoIcons.checkmark_seal_fill,
                                    size: 17,
                                    color: Color(0xFFB6F0DA),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          CupertinoIcons.location_solid,
                                          size: 10,
                                          color: CupertinoColors.white,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'กรุงเทพฯ',
                                          style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      PressEffect(
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ),
                        haptic: HapticKind.selection,
                        rippleShape: BoxShape.circle,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color: CupertinoColors.white
                                  .withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.pencil,
                            color: CupertinoColors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                CupertinoColors.white.withValues(alpha: 0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              child: _ProfileStat(
                                icon: CupertinoIcons.gift_fill,
                                value: '27',
                                label: 'อายุ',
                              ),
                            ),
                            _StatDivider(),
                            Expanded(
                              child: _ProfileStat(
                                icon: CupertinoIcons.person_fill,
                                value: 'ชาย',
                                label: 'เพศ',
                              ),
                            ),
                            _StatDivider(),
                            Expanded(
                              child: _ProfileStat(
                                icon: CupertinoIcons.drop_fill,
                                value: 'O+',
                                label: 'กรุ๊ปเลือด',
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
          ],
        ),
    );
  }
}

class _MeshGradient extends StatelessWidget {
  const _MeshGradient();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2BB892), Color(0xFF12624A)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1.0, -1.0),
              radius: 1.2,
              colors: [
                const Color(0xFF7FE7C4).withValues(alpha: 0.5),
                const Color(0xFF7FE7C4).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.1, 1.0),
              radius: 1.0,
              colors: [
                const Color(0xFF0E4F3B).withValues(alpha: 0.55),
                const Color(0xFF0E4F3B).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.9, -0.8),
              radius: 0.8,
              colors: [
                const Color(0xFF4ED2EA).withValues(alpha: 0.35),
                const Color(0xFF4ED2EA).withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WellnessAvatar extends StatelessWidget {
  const _WellnessAvatar({required this.progress});
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    const size = 84.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: progress,
            builder: (_, __) => CustomPaint(
              size: const Size(size, size),
              painter: _WellnessRingPainter(value: 0.78 * progress.value),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.white,
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: const ClipOval(
              child: ProfileAvatarImage(fit: BoxFit.cover),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: CupertinoColors.white,
                  width: 1.2,
                ),
              ),
              child: const Text(
                '78',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WellnessRingPainter extends CustomPainter {
  _WellnessRingPainter({required this.value});
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 3;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = CupertinoColors.white.withValues(alpha: 0.2);
    canvas.drawCircle(center, radius, track);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -1.5708,
        endAngle: 4.7124,
        colors: [
          Color(0xFFB6F0DA),
          Color(0xFFFFFFFF),
          Color(0xFFB6F0DA),
        ],
      ).createShader(rect);

    const start = -1.5708; // -90deg, top
    final sweep = 6.2832 * value.clamp(0.0, 1.0);
    canvas.drawArc(rect, start, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant _WellnessRingPainter old) =>
      old.value != value;
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.white.withValues(alpha: 0.85),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.75),
            fontSize: 10,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: CupertinoColors.white.withValues(alpha: 0.2),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});
  final String title;
  final List<_MenuEntry> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headline(const Color(0xFF1A1A1A)).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < items.length; i++) ...[
            _MenuCard(entry: items[i]),
            if (i != items.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _MenuEntry {
  const _MenuEntry({
    required this.iconColor,
    this.icon,
    this.svgAsset,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : assert(icon != null || svgAsset != null);
  final Color iconColor;
  final IconData? icon;
  final String? svgAsset;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.entry});
  final _MenuEntry entry;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: entry.onTap ?? () {},
      haptic: HapticKind.selection,
      scale: 0.98,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: CupertinoColors.black.withValues(alpha: 0.03),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.iconColor,
                  ),
                  alignment: Alignment.center,
                  child: entry.svgAsset != null
                      ? SvgPicture.asset(
                          entry.svgAsset!,
                          width: 12,
                          height: 12,
                          colorFilter: const ColorFilter.mode(
                            CupertinoColors.white,
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(
                          entry.icon,
                          color: CupertinoColors.white,
                          size: 12,
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.title,
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 16),
              child: Text(
                entry.subtitle,
                style: const TextStyle(
                  color: Color(0xFF6D756E),
                  fontSize: 12,
                  letterSpacing: 0.275,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
