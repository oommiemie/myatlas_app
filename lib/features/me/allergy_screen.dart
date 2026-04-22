import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';

enum Severity { mild, moderate, severe }

class AllergyEntry {
  const AllergyEntry({
    required this.name,
    required this.imagePath,
    required this.severity,
    required this.symptoms,
  });
  final String name;
  final String imagePath;
  final Severity severity;
  final String symptoms;
}

const _drugAllergies = <AllergyEntry>[
  AllergyEntry(
    name: 'Penicillin',
    imagePath: 'assets/images/allergy/penicillin.png',
    severity: Severity.severe,
    symptoms: 'หายใจลำบาก, ความดันโลหิตต่ำ, หน้าบวม',
  ),
  AllergyEntry(
    name: 'Aspirin',
    imagePath: 'assets/images/allergy/aspirin.png',
    severity: Severity.moderate,
    symptoms: 'ผื่นคันลมพิษ (Urticaria), ตาบวม',
  ),
  AllergyEntry(
    name: 'Ibuprofen',
    imagePath: 'assets/images/allergy/ibuprofen.png',
    severity: Severity.mild,
    symptoms: 'คลื่นไส้, มีผื่นแดงเล็กน้อยตามตัว',
  ),
];

const _foodAllergies = <AllergyEntry>[
  AllergyEntry(
    name: 'อาหารทะเล (กุ้ง)',
    imagePath: 'assets/images/allergy/shrimp.png',
    severity: Severity.severe,
    symptoms: 'แน่นหน้าอก, คันคออย่างรุนแรง, หมดสติ',
  ),
  AllergyEntry(
    name: 'ถั่วลิสง',
    imagePath: 'assets/images/allergy/peanut.png',
    severity: Severity.severe,
    symptoms: 'ปากบวม, อาเจียน, ผื่นแพ้ลามเร็ว',
  ),
  AllergyEntry(
    name: 'นมวัว (Lactose)',
    imagePath: 'assets/images/allergy/milk.png',
    severity: Severity.mild,
    symptoms: 'ท้องอืด, ถ่ายเหลว, ปวดท้อง',
  ),
];

class AllergyScreen extends StatefulWidget {
  const AllergyScreen({super.key});

  @override
  State<AllergyScreen> createState() => _AllergyScreenState();
}

class _AllergyScreenState extends State<AllergyScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0; // 0 = drug, 1 = food
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
    final items = _tab == 0 ? _drugAllergies : _foodAllergies;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE57B8B), Color(0xFFC8465F)],
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      LiquidGlassButton(
                        icon: CupertinoIcons.chevron_back,
                        iconColor: const Color(0xFF1A1A1A),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ข้อมูลแพ้ยา/แพ้อาหาร',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F8F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 40),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _SegmentedTabs(
                          selected: _tab,
                          onChange: (i) {
                            HapticFeedback.selectionClick();
                            setState(() => _tab = i);
                            _enter
                              ..reset()
                              ..forward();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, anim) {
                            final slide = Tween<Offset>(
                              begin: Offset(_tab == 0 ? -0.08 : 0.08, 0),
                              end: Offset.zero,
                            ).animate(anim);
                            return FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: slide,
                                child: child,
                              ),
                            );
                          },
                          layoutBuilder: (current, _) =>
                              current ?? const SizedBox.shrink(),
                          child: Column(
                            key: ValueKey<int>(_tab),
                            children: [
                              for (int i = 0; i < items.length; i++) ...[
                                _stagger(
                                  i,
                                  items.length,
                                  _AllergyCard(entry: items[i]),
                                ),
                                if (i != items.length - 1)
                                  const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selected, required this.onChange});
  final int selected;
  final ValueChanged<int> onChange;

  static const _labels = ['แพ้ยา', 'แพ้อาหาร'];
  static const _indicatorCurve = Cubic(0.34, 1.36, 0.64, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFD4D4D4).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: _indicatorCurve,
                left: selected * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < _labels.length; i++)
                    Expanded(
                      child: _TabPill(
                        label: _labels[i],
                        active: selected == i,
                        onTap: () => onChange(i),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      borderRadius: BorderRadius.circular(100),
      scale: 0.97,
      child: SizedBox(
        height: 36,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            style: TextStyle(
              color: active
                  ? const Color(0xFF0088FF)
                  : const Color(0xFF1A1A1A),
              fontSize: 15,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: -0.23,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _AllergyCard extends StatelessWidget {
  const _AllergyCard({required this.entry});
  final AllergyEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CupertinoColors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(entry.imagePath, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.name,
                    style: const TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _SeverityPill(severity: entry.severity),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    entry.symptoms,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      height: 20 / 14,
                      letterSpacing: 0.14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({required this.severity});
  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      Severity.severe => ('รุนแรงมาก', const Color(0xFFFF383C)),
      Severity.moderate => ('ปานกลาง', const Color(0xFFEA580C)),
      Severity.mild => ('น้อย', const Color(0xFF17C964)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.275,
        ),
      ),
    );
  }
}
