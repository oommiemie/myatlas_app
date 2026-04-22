import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../core/widgets/press_effect.dart';
import 'call_screen.dart';
import 'call_service.dart';

/// Wraps [child] with a top-pinned mini call card that appears whenever
/// there is a minimized active call — so it shows across every route.
class MiniCallOverlay extends StatelessWidget {
  const MiniCallOverlay({super.key, required this.child});
  final Widget child;

  void _resume(BuildContext context, ActiveCall call) {
    CallService.instance.clear();
    showCallScreen(
      context,
      member: call.member,
      type: call.type,
      direction: CallDirection.outgoing,
      startConnected: true,
      startElapsed: call.elapsed,
      startMuted: call.muted,
      startPaused: call.paused,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          top: MediaQuery.paddingOf(context).top + 8,
          child: ValueListenableBuilder<ActiveCall?>(
            valueListenable: CallService.instance.minimized,
            builder: (_, call, __) => call == null
                ? const SizedBox.shrink()
                : _MiniCallCard(
                    call: call,
                    onTap: () => _resume(context, call),
                  ),
          ),
        ),
      ],
    );
  }
}

class _MiniCallCard extends StatefulWidget {
  const _MiniCallCard({required this.call, required this.onTap});
  final ActiveCall call;
  final VoidCallback onTap;

  @override
  State<_MiniCallCard> createState() => _MiniCallCardState();
}

class _MiniCallCardState extends State<_MiniCallCard> {
  late Duration _elapsed;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _elapsed = widget.call.elapsed;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || widget.call.paused) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt() {
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final h = _elapsed.inHours;
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: PressEffect(
          onTap: widget.onTap,
          haptic: HapticKind.light,
          scale: 0.97,
          borderRadius: BorderRadius.circular(100),
          playClick: true,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2CA989),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    widget.call.member.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.call.member.name,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _fmt(),
                        style: TextStyle(
                          color: CupertinoColors.white.withValues(alpha: 0.85),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  widget.call.type == CallType.video
                      ? CupertinoIcons.videocam_fill
                      : CupertinoIcons.phone_fill,
                  color: CupertinoColors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.chevron_forward,
                  color: CupertinoColors.white,
                  size: 14,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
