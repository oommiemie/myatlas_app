import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/liquid_glass_button.dart';

/// Shared scaffold for every profile edit sheet.
/// Shows an X / title / green check header, a large colored icon bubble,
/// then the provided [child] content.
class EditSheetScaffold extends StatelessWidget {
  const EditSheetScaffold({
    super.key,
    required this.title,
    required this.iconColor,
    required this.icon,
    required this.child,
    required this.onSave,
  });

  final String title;
  final Color iconColor;
  final IconData icon;
  final Widget child;

  /// When null the save button is rendered gray and is non-interactive.
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: const Color(0xFFF2F2F7),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      LiquidGlassButton(
                        icon: CupertinoIcons.xmark,
                        iconColor: const Color(0xFF1A1A1A),
                        onTap: () => Navigator.of(context).pop(),
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
                        iconColor: onSave != null
                            ? CupertinoColors.white
                            : const Color(0xFFBDBDBD),
                        tint: onSave != null ? const Color(0xFF1D8B6B) : null,
                        onTap: onSave == null
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                onSave!();
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: CupertinoColors.white, size: 38),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Show any edit sheet with a slide-up animation and dimmed backdrop.
Future<T?> showEditSheet<T>(
  BuildContext context,
  Widget Function(BuildContext) builder,
) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      barrierLabel: 'edit-sheet',
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, anim, sec) => builder(ctx),
      transitionsBuilder: (ctx, anim, sec, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: child);
      },
    ),
  );
}
