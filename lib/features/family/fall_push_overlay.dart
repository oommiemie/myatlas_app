import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/widgets/press_effect.dart';
import 'care_giver_screen.dart';
import 'fall_alert.dart';

/// Wraps [child] with a top-pinned push-notification-style banner that drops
/// down whenever a new fall alert is added to [fallAlertsStore]. Banners
/// auto-dismiss after a few seconds, can be tapped to open the alert sheet,
/// or swiped up to dismiss.
class FallPushOverlay extends StatefulWidget {
  const FallPushOverlay({super.key, required this.child});
  final Widget child;

  @override
  State<FallPushOverlay> createState() => _FallPushOverlayState();
}

class _FallPushOverlayState extends State<FallPushOverlay> {
  // Names that have already been surfaced as a banner this session.
  final Set<String> _shown = <String>{};
  final List<_BannerData> _queue = <_BannerData>[];
  _BannerData? _current;

  @override
  void initState() {
    super.initState();
    fallAlertsStore.addListener(_onStoreChange);
    // Surface any alerts that were already in the store at boot.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onStoreChange();
    });
  }

  @override
  void dispose() {
    fallAlertsStore.removeListener(_onStoreChange);
    super.dispose();
  }

  void _onStoreChange() {
    final store = fallAlertsStore.value;
    for (final entry in store.entries) {
      if (_shown.contains(entry.key)) continue;
      final member = _resolveMember(entry.key);
      if (member == null) continue;
      _shown.add(entry.key);
      _queue.add(_BannerData(member: member, alert: entry.value));
    }
    // Drop names that are no longer active so a re-trigger surfaces again.
    _shown.removeWhere((name) => !store.containsKey(name));
    _maybeShowNext();
  }

  FamilyMember? _resolveMember(String name) {
    for (final m in kFamilyMembers) {
      if (m.name == name) return m;
    }
    return null;
  }

  void _maybeShowNext() {
    if (_current != null || _queue.isEmpty) return;
    setState(() => _current = _queue.removeAt(0));
  }

  void _onBannerDismissed() {
    setState(() => _current = null);
    _maybeShowNext();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: _current == null
              ? const SizedBox.shrink()
              : _PushBanner(
                  key: ValueKey(_current!.member.name),
                  data: _current!,
                  onDismissed: _onBannerDismissed,
                ),
        ),
      ],
    );
  }
}

class _BannerData {
  const _BannerData({required this.member, required this.alert});
  final FamilyMember member;
  final FallAlert alert;
}

class _PushBanner extends StatefulWidget {
  const _PushBanner({super.key, required this.data, required this.onDismissed});
  final _BannerData data;
  final VoidCallback onDismissed;

  @override
  State<_PushBanner> createState() => _PushBannerState();
}

class _PushBannerState extends State<_PushBanner>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _pulse;
  Timer? _autoDismiss;
  double _dragDy = 0;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      reverseDuration: const Duration(milliseconds: 260),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _autoDismiss = Timer(const Duration(seconds: 6), _dismiss);
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _autoDismiss?.cancel();
    await _enter.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  void _open() {
    _autoDismiss?.cancel();
    showFallAlertSheet(
      context,
      member: widget.data.member,
      alert: widget.data.alert,
    );
    _dismiss();
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'เมื่อสักครู่';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    return '${diff.inHours} ชั่วโมงที่แล้ว';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return AnimatedBuilder(
      animation: _enter,
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(_enter.value);
        // Slide from above the screen down to its resting position; clamp at
        // 0 so an upward drag doesn't pull the banner past the resting spot.
        final dragOffset = _dragDy.clamp(-200.0, 0.0);
        return Transform.translate(
          offset: Offset(0, (1 - t) * -180 + dragOffset),
          child: Opacity(
            opacity: t,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, topInset + 8, 10, 0),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (d) {
                  if (d.delta.dy < 0 || _dragDy < 0) {
                    setState(() => _dragDy += d.delta.dy);
                  }
                },
                onVerticalDragEnd: (d) {
                  if (_dragDy < -40 || (d.primaryVelocity ?? 0) < -300) {
                    _dismiss();
                  } else {
                    setState(() => _dragDy = 0);
                  }
                },
                child: PressEffect(
                  onTap: _open,
                  haptic: HapticKind.medium,
                  scale: 0.98,
                  borderRadius: BorderRadius.circular(22),
                  child: _buildCard(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    final firstName = widget.data.member.name.split(' ').first;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final p = _pulse.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color:
                      const Color(0xFFBC1B06).withValues(alpha: 0.4 + 0.3 * p),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBC1B06)
                        .withValues(alpha: 0.30 + 0.20 * p),
                    blurRadius: 22 + 8 * p,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBadge(t: p),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'MYATLAS',
                              style: TextStyle(
                                color: CupertinoColors.white
                                    .withValues(alpha: 0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.white
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _timeAgo(widget.data.alert.detectedAt),
                              style: TextStyle(
                                color: CupertinoColors.white
                                    .withValues(alpha: 0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ตรวจพบการล้มของ $firstName',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.data.alert.location} · แตะเพื่อดูรายละเอียด',
                          style: TextStyle(
                            color:
                                CupertinoColors.white.withValues(alpha: 0.78),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 42 * (0.7 + 0.3 * t),
            height: 42 * (0.7 + 0.3 * t),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFBC1B06).withValues(alpha: 0.30 * (1 - t)),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B5A), Color(0xFFBC1B06)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBC1B06).withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: CupertinoColors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
