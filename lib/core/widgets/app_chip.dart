import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'press_effect.dart';

/// Animated choice chip used in forms.
///
/// - Unselected: white fill with hairline border
/// - Selected: gradient + shadow + white check/radio icon in a glassy bubble
/// - 240ms easeOutCubic transitions on color, border, shadow, icon, weight
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = const Color(0xFF1D8B6B),
    this.showRadio = false,
    this.haptic = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final bool showRadio;
  final bool haptic;

  static const _curve = Curves.easeOutCubic;
  static const _duration = Duration(milliseconds: 240);

  @override
  Widget build(BuildContext context) {
    final selectedIcon = showRadio
        ? CupertinoIcons.largecircle_fill_circle
        : CupertinoIcons.checkmark_alt;
    return PressEffect(
      onTap: () {
        if (haptic) HapticFeedback.selectionClick();
        onTap();
      },
      haptic: HapticKind.none,
      scale: 0.94,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(selectedColor, CupertinoColors.white, 0.08)!,
                    selectedColor,
                  ],
                )
              : null,
          color: selected ? null : CupertinoColors.white,
          border: Border.all(
            color: selected
                ? selectedColor.withValues(alpha: 0)
                : const Color(0xFF1A1A1A).withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: _duration,
              curve: _curve,
              child: AnimatedSwitcher(
                duration: _duration,
                switchInCurve: _curve,
                switchOutCurve: _curve,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: selected
                    ? Padding(
                        key: const ValueKey('on'),
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white
                                .withValues(alpha: 0.25),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            selectedIcon,
                            size: 11,
                            color: CupertinoColors.white,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('off'), width: 0),
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: _duration,
              curve: _curve,
              style: TextStyle(
                color: selected
                    ? CupertinoColors.white
                    : const Color(0xFF3E453F),
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red-tinted removable chip used for dangerous/highlighted items
/// (allergies, chronic diseases, etc.).
class AppDangerChip extends StatelessWidget {
  const AppDangerChip({
    super.key,
    required this.label,
    required this.onRemove,
    this.color = const Color(0xFFE62E05),
  });

  final String label;
  final VoidCallback onRemove;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6).copyWith(
        right: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          PressEffect(
            onTap: onRemove,
            haptic: HapticKind.selection,
            rippleShape: BoxShape.circle,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white.withValues(alpha: 0.6),
              ),
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.xmark,
                size: 10,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
