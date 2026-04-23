import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum AppToastType { success, error, info, warning }

/// Top-anchored, frosted-glass toast shown above everything.
///
/// Slides down from the top with ease-out-cubic, holds for ~2s,
/// then slides up and removes itself. Only one toast exists at a time —
/// calling show() while another is on screen replaces it instantly.
class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static _ToastOverlayState? _state;

  static void success(BuildContext context, String message) =>
      _show(context, message: message, type: AppToastType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message: message, type: AppToastType.error);

  static void info(BuildContext context, String message) =>
      _show(context, message: message, type: AppToastType.info);

  static void warning(BuildContext context, String message) =>
      _show(context, message: message, type: AppToastType.warning);

  static void _show(
    BuildContext context, {
    required String message,
    required AppToastType type,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    HapticFeedback.lightImpact();

    final existing = _state;
    if (existing != null) {
      existing.replace(message: message, type: type, duration: duration);
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastOverlay(
        key: const ValueKey('app_toast_overlay'),
        initialMessage: message,
        initialType: type,
        initialDuration: duration,
        onStateCreated: (s) => _state = s,
        onDismissed: () {
          entry.remove();
          if (_entry == entry) _entry = null;
          _state = null;
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    super.key,
    required this.initialMessage,
    required this.initialType,
    required this.initialDuration,
    required this.onStateCreated,
    required this.onDismissed,
  });

  final String initialMessage;
  final AppToastType initialType;
  final Duration initialDuration;
  final ValueChanged<_ToastOverlayState> onStateCreated;
  final VoidCallback onDismissed;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;
  late String _message;
  late AppToastType _type;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _message = widget.initialMessage;
    _type = widget.initialType;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _anim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onStateCreated(this);
      _ctrl.forward();
      _armHide(widget.initialDuration);
    });
  }

  void _armHide(Duration duration) {
    _hideTimer?.cancel();
    _hideTimer = Timer(duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    _hideTimer?.cancel();
    await _ctrl.reverse();
    widget.onDismissed();
  }

  void replace({
    required String message,
    required AppToastType type,
    required Duration duration,
  }) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _type = type;
    });
    _armHide(duration);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: top + 10,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) {
          return Transform.translate(
            offset: Offset(0, -40 * (1 - _anim.value)),
            child: Opacity(opacity: _anim.value, child: child),
          );
        },
        child: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: GestureDetector(
              onTap: _dismiss,
              behavior: HitTestBehavior.opaque,
              child: _ToastCard(message: _message, type: _type),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.message, required this.type});
  final String message;
  final AppToastType type;

  ({IconData icon, Color color}) get _visual {
    switch (type) {
      case AppToastType.success:
        return (icon: CupertinoIcons.checkmark_alt, color: const Color(0xFF1D8B6B));
      case AppToastType.error:
        return (icon: CupertinoIcons.xmark, color: const Color(0xFFE62E05));
      case AppToastType.warning:
        return (icon: CupertinoIcons.exclamationmark, color: const Color(0xFFD97706));
      case AppToastType.info:
        return (icon: CupertinoIcons.info, color: const Color(0xFF0891B2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
          decoration: BoxDecoration(
            color: CupertinoColors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: v.color,
                ),
                alignment: Alignment.center,
                child: Icon(v.icon, size: 14, color: CupertinoColors.white),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
