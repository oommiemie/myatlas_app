import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_typography.dart';
import '../../core/widgets/large_title_header.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';
import '../appointment/appointment_screen.dart';
import '../health/health_assessment_screen.dart';
import 'allergy_screen.dart';
import 'behavior_screen.dart';
import 'chronic_disease_screen.dart';
import 'dental_screen.dart';
import 'insurance_screen.dart';
import 'invite_screen.dart';
import 'opd/opd_registry_screen.dart';
import 'settings_screen.dart';
import 'treatment/treatment_screen.dart';
import 'vaccine_screen.dart';
import 'widgets/profile_banner.dart';

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
          LargeTitleHeader(
            title: 'ฉัน',
            backgroundColor: bg,
            action: LiquidGlassButton(
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
              child: _stagger(0, 4, const ProfileBanner()),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                // Referral summary — sits right under the profile so the count
                // is visible without scrolling.
                _stagger(
                  1,
                  5,
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: InviteCard(),
                  ),
                ),
                // Mockup: quota reached — reward CTA. Remove before release.
                _stagger(
                  1,
                  5,
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: InviteCard(info: kFullInvite),
                  ),
                ),
                // Redeem entry point for users who closed the first-run popup.
                _stagger(
                  1,
                  5,
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: EnterInviteCodeCard(),
                  ),
                ),
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
                        title: 'ลงทะเบียนผู้ป่วยนอก',
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      height: 1.3,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 13,
                  color: Color(0xFF6D756E),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 16),
              child: Text(
                entry.subtitle,
                style: const TextStyle(
                  color: Color(0xFF6D756E),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
