import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_button.dart';
import 'press_effect.dart';

/// Floating frosted-glass option picker matching the medicine reminder sheet.
///
/// - radius 38 on all corners
/// - header: X (left) + title (center) + green check (right)
/// - drag handle at top
/// - rows with selected checkmark on the right (AnimatedSwitcher fade+scale)
/// - user taps a row to mark; the green check button confirms
Future<String?> showAppOptionSheet({
  required BuildContext context,
  required String title,
  required String selected,
  required List<String> options,
}) {
  return showCupertinoModalPopup<String>(
    context: context,
    barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
    builder: (ctx) {
      String temp = selected;
      return Padding(
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
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    title,
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
                                Navigator.of(ctx).pop(temp);
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
                              for (int i = 0; i < options.length; i++) ...[
                                PressEffect(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setInner(() => temp = options[i]);
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
                                            options[i],
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
                                          child: temp == options[i]
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
                                if (i != options.length - 1)
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
      );
    },
  );
}
