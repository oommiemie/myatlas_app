import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/widgets/press_effect.dart';
import 'call_service.dart';
import 'care_giver_screen.dart';

enum CallType { voice, video }

enum CallDirection { incoming, outgoing }

Future<void> showCallScreen(
  BuildContext context, {
  required FamilyMember member,
  required CallType type,
  required CallDirection direction,
  Duration startElapsed = Duration.zero,
  bool startConnected = false,
  bool startMuted = false,
  bool startPaused = false,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => _CallScreen(
        member: member,
        type: type,
        direction: direction,
        startElapsed: startElapsed,
        startConnected: startConnected,
        startMuted: startMuted,
        startPaused: startPaused,
      ),
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: anim,
                  curve: Curves.fastEaseInToSlowEaseOut,
                  reverseCurve: Curves.easeInCubic,
                ),
              ),
          child: child,
        );
      },
    ),
  );
}

Future<void> showCallMenu(
  BuildContext context, {
  required FamilyMember member,
}) async {
  final choice = await showCupertinoModalPopup<_CallChoice>(
    context: context,
    builder: (ctx) => CupertinoActionSheet(
      title: Text('โทรหา ${member.name}'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(_CallChoice.outgoingVoice),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                CupertinoIcons.phone_fill,
                color: Color(0xFF2CA989),
                size: 20,
              ),
              SizedBox(width: 8),
              Text('สายเสียง'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(_CallChoice.outgoingVideo),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                CupertinoIcons.videocam_fill,
                color: Color(0xFF2CA989),
                size: 22,
              ),
              SizedBox(width: 8),
              Text('สายวิดีโอ'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(_CallChoice.incomingVoice),
          child: const Text('จำลองสายเรียกเข้า (Voice)'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(_CallChoice.incomingVideo),
          child: const Text('จำลองสายเรียกเข้า (Video)'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.of(ctx).pop(),
        child: const Text('ยกเลิก'),
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  await showCallScreen(
    context,
    member: member,
    type: choice.type,
    direction: choice.direction,
  );
}

enum _CallChoice {
  outgoingVoice(CallType.voice, CallDirection.outgoing),
  outgoingVideo(CallType.video, CallDirection.outgoing),
  incomingVoice(CallType.voice, CallDirection.incoming),
  incomingVideo(CallType.video, CallDirection.incoming);

  const _CallChoice(this.type, this.direction);
  final CallType type;
  final CallDirection direction;
}

enum _CallStage { ringing, connected }

class _CallScreen extends StatefulWidget {
  const _CallScreen({
    required this.member,
    required this.type,
    required this.direction,
    this.startElapsed = Duration.zero,
    this.startConnected = false,
    this.startMuted = false,
    this.startPaused = false,
  });
  final FamilyMember member;
  final CallType type;
  final CallDirection direction;
  final Duration startElapsed;
  final bool startConnected;
  final bool startMuted;
  final bool startPaused;

  @override
  State<_CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<_CallScreen> {
  late _CallStage _stage;
  late CallType _type;
  late Duration _elapsed;
  Timer? _timer;
  late bool _muted;
  final bool _cameraOn = true;
  late bool _paused;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _elapsed = widget.startElapsed;
    _muted = widget.startMuted;
    _paused = widget.startPaused;
    if (widget.startConnected) {
      _stage = _CallStage.connected;
      _startTimer();
    } else {
      _stage = _CallStage.ringing;
      if (widget.direction == CallDirection.outgoing) {
        Future.delayed(const Duration(seconds: 3), _connect);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_paused) {
        setState(() => _elapsed += const Duration(seconds: 1));
      }
    });
  }

  void _minimize() {
    CallService.instance.minimize(
      ActiveCall(
        member: widget.member,
        type: _type,
        elapsed: _elapsed,
        muted: _muted,
        paused: _paused,
      ),
    );
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  void _connect() {
    if (!mounted || _stage != _CallStage.ringing) return;
    setState(() => _stage = _CallStage.connected);
    _startTimer();
  }

  void _end() {
    _timer?.cancel();
    CallService.instance.clear();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatElapsed() {
    final h = _elapsed.inHours;
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '00:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _type == CallType.video;
    final isConnectedVideoCamOn =
        isVideo && _stage == _CallStage.connected && _cameraOn;
    return ColoredBox(
      color: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isConnectedVideoCamOn)
            Image.asset(widget.member.imagePath, fit: BoxFit.cover)
          else
            _BlurredBackground(imagePath: widget.member.imagePath),
          Container(color: CupertinoColors.black.withValues(alpha: 0.28)),
          SafeArea(
            child: _stage == _CallStage.connected
                ? _buildConnected(isVideo)
                : widget.direction == CallDirection.outgoing
                ? _buildVoiceOutgoing(isVideo)
                : _buildIncoming(isVideo),
          ),
        ],
      ),
    );
  }

  // --- Voice outgoing (Calling...) — single end button, Figma 341:26897 ---
  Widget _buildVoiceOutgoing(bool isVideo) {
    return Column(
      children: [
        const SizedBox(height: 64),
        _CallAvatar(imagePath: widget.member.imagePath, size: 140),
        const SizedBox(height: 16),
        const Text(
          'Calling...',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.member.name,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: _CallCircleButton(
            icon: CupertinoIcons.xmark,
            color: const Color(0xFFFF3B30),
            haptic: HapticKind.heavy,
            onTap: _end,
            size: 64,
          ),
        ),
      ],
    );
  }

  // --- Incoming — accept + decline, Figma 176:6974 ---
  Widget _buildIncoming(bool isVideo) {
    return Column(
      children: [
        const SizedBox(height: 64),
        _CallAvatar(imagePath: widget.member.imagePath, size: 140),
        const SizedBox(height: 16),
        Text(
          isVideo ? 'สายวิดีโอ' : 'กำลังโทร...',
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.member.name,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CallCircleButton(
                icon: isVideo
                    ? CupertinoIcons.videocam_fill
                    : CupertinoIcons.phone_fill,
                color: const Color(0xFF2CA989),
                onTap: _connect,
                size: 64,
              ),
              _CallCircleButton(
                icon: CupertinoIcons.xmark,
                color: const Color(0xFFFF3B30),
                haptic: HapticKind.heavy,
                onTap: _end,
                size: 64,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Connected call (voice + video share the same layout) ---
  Widget _buildConnected(bool isVideo) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(widget.member.imagePath, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.member.name,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatElapsed(),
                      style: TextStyle(
                        color: CupertinoColors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isVideo) ...[
                _RoundIconButton(
                  icon: CupertinoIcons.switch_camera,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
              ],
              _RoundIconButton(
                icon: CupertinoIcons.fullscreen_exit,
                onTap: _minimize,
              ),
            ],
          ),
        ),
        if (!isVideo) ...[
          const SizedBox(height: 48),
          _CallAvatar(imagePath: widget.member.imagePath, size: 160),
          const SizedBox(height: 16),
          Text(
            widget.member.name,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const Spacer(),
        // PIP only when video mode is on
        if (isVideo)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 20),
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CupertinoColors.white.withValues(alpha: 0.25),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/family/jaidee.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        _buildConnectedControls(isVideo),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConnectedControls(bool isVideo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RoundIconButton(
            icon: CupertinoIcons.videocam_fill,
            onTap: () => setState(
              () => _type = isVideo ? CallType.voice : CallType.video,
            ),
            size: 48,
            highlighted: isVideo,
          ),
          _RoundIconButton(
            icon: _muted
                ? CupertinoIcons.mic_slash_fill
                : CupertinoIcons.mic_fill,
            onTap: () => setState(() => _muted = !_muted),
            size: 48,
          ),
          _CallCircleButton(
            icon: CupertinoIcons.phone_down_fill,
            color: const Color(0xFFFF3B30),
            haptic: HapticKind.heavy,
            onTap: _end,
            size: 60,
          ),
          _RoundIconButton(
            icon: CupertinoIcons.volume_up,
            onTap: () {},
            size: 48,
          ),
          _RoundIconButton(
            icon: _paused
                ? CupertinoIcons.play_fill
                : CupertinoIcons.pause_fill,
            onTap: () => setState(() => _paused = !_paused),
            size: 48,
          ),
        ],
      ),
    );
  }
}

class _BlurredBackground extends StatelessWidget {
  const _BlurredBackground({required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(imagePath, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            color: CupertinoColors.black.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

class _CallAvatar extends StatelessWidget {
  const _CallAvatar({required this.imagePath, this.size = 140});
  final String imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}

class _CallCircleButton extends StatefulWidget {
  const _CallCircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.iconColor = CupertinoColors.white,
    this.size = 62,
    this.haptic = HapticKind.medium,
  });
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  final double size;
  final HapticKind haptic;

  @override
  State<_CallCircleButton> createState() => _CallCircleButtonState();
}

class _CallCircleButtonState extends State<_CallCircleButton>
    with TickerProviderStateMixin {
  final List<AnimationController> _ripples = [];

  void _triggerRipple() {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ripples.add(ctrl);
    ctrl.forward().whenComplete(() {
      _ripples.remove(ctrl);
      ctrl.dispose();
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _ripples) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ripples = List<AnimationController>.unmodifiable(_ripples);
    return SizedBox(
      width: widget.size * 1.9,
      height: widget.size * 1.9,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ripple layers behind the button
          for (final c in ripples)
            AnimatedBuilder(
              animation: c,
              builder: (_, __) {
                final t = c.value;
                final curve = Curves.easeOut.transform(t);
                final diameter = widget.size + (widget.size * 1.6) * curve;
                return IgnorePointer(
                  child: Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withValues(alpha: (1 - t) * 0.45),
                    ),
                  ),
                );
              },
            ),
          PressEffect(
            haptic: widget.haptic,
            scale: 0.88,
            rippleShape: BoxShape.circle,
            playClick: true,
            onTap: () {
              _triggerRipple();
              widget.onTap();
            },
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.size * 0.42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.highlighted = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      rippleShape: BoxShape.circle,
      playClick: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: highlighted
              ? CupertinoColors.white
              : CupertinoColors.white.withValues(alpha: 0.18),
          border: Border.all(
            color: CupertinoColors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(
          icon,
          color: highlighted ? const Color(0xFF1A1A1A) : CupertinoColors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
