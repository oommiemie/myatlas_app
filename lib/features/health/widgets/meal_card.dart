import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/liquid_glass_button.dart';

class MealCard extends StatefulWidget {
  const MealCard({
    super.key,
    required this.tagline,
    required this.name,
    required this.calories,
    required this.carbs,
    this.onScan,
  });

  final String tagline;
  final String name;
  final String calories;
  final String carbs;
  final VoidCallback? onScan;

  static const _primary600 = Color(0xFF1D8B6B);
  static const _primary900 = Color(0xFF093327);
  static const _borderDefault = Color(0xFFE5E5E5);
  static const _textSecondary = Color(0xFF3E453F);
  static const _neutral500 = Color(0xFF737373);

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [0.164, 1.0],
            colors: [MealCard._primary600, MealCard._primary900],
          ),
          border: Border.all(color: MealCard._borderDefault, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 1,
            ),
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -22,
              top: -22,
              width: 130,
              height: 130,
              child: _AnimatedSalad(entryCtrl: _entryCtrl),
            ),
            Column(
              children: [
                _TopRow(
                  tagline: widget.tagline,
                  name: widget.name,
                  onScan: widget.onScan,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: MealCard._borderDefault, width: 0.5),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Nutrient(
                            icon: CupertinoIcons.flame_fill,
                            iconBg: const Color(0xFFFF6B3D),
                            label: 'แคลอรี่วันนี้',
                            value: widget.calories,
                            unit: 'kcl',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: MealCard._borderDefault,
                        ),
                        Expanded(
                          child: _Nutrient(
                            icon: Icons.restaurant,
                            iconBg: MealCard._primary600,
                            iconSize: 10,
                            label: 'เมื่ออาหารที่ทาน',
                            value: widget.carbs,
                            unit: 'เมื่อ',
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
      ),
    );
  }
}

class _AnimatedSalad extends StatelessWidget {
  const _AnimatedSalad({required this.entryCtrl});

  final AnimationController entryCtrl;

  static const double _baseAngle = 22.11 * pi / 180;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entryCtrl,
      builder: (_, child) {
        final t = entryCtrl.value.clamp(0.0, 1.0);
        final entry = Curves.easeOutBack.transform(t);
        final fadeIn = Curves.easeOut.transform(t);
        final entryDx = (1 - entry) * -36;
        final entryDy = (1 - entry) * -44;
        final entryScale = 0.55 + 0.45 * entry;

        return Transform.translate(
          offset: Offset(entryDx, entryDy),
          child: Transform.rotate(
            angle: _baseAngle,
            child: Transform.scale(
              scale: entryScale,
              child: Opacity(opacity: fadeIn, child: child),
            ),
          ),
        );
      },
      child: Image.asset(
        'assets/images/salad.png',
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.tagline,
    required this.name,
    required this.onScan,
  });

  final String tagline;
  final String name;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(90, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tagline,
                  style: AppTypography.caption2(
                    CupertinoColors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: AppTypography.subheadline(
                    CupertinoColors.white.withValues(alpha: 0.95),
                  ).copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          LiquidGlassButton(
            icon: CupertinoIcons.camera_fill,
            onTap: onScan,
          ),
        ],
      ),
    );
  }
}


class _Nutrient extends StatelessWidget {
  const _Nutrient({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.unit,
    this.iconSize = 9,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String value;
  final String unit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBg,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: iconSize, color: CupertinoColors.white),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption2(MealCard._textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTypography.callout(CupertinoColors.black).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6,
                height: 1,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                unit,
                style: AppTypography.caption2(MealCard._neutral500)
                    .copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
