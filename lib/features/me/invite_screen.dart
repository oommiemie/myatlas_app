import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/app_toast.dart';
import '../../core/widgets/press_effect.dart';
import '../health/widgets/health_detail_app_bar.dart';

/// Referral state for the signed-in user. Mock data for now — swap for the
/// real API once the referral endpoint exists.
class InviteInfo {
  const InviteInfo({
    required this.code,
    required this.joinedCount,
    required this.pendingCount,
    required this.recent,
  });

  /// The user's personal invite code.
  final String code;

  /// People who accepted the invite and finished sign-up.
  final int joinedCount;

  /// People who opened the link but have not finished sign-up.
  final int pendingCount;

  final List<InviteFriend> recent;
}

class InviteFriend {
  const InviteFriend({
    required this.name,
    required this.dateLabel,
    required this.joined,
  });

  final String name;
  final String dateLabel;

  /// false = opened the link but has not finished sign-up yet.
  final bool joined;
}

const kDefaultInvite = InviteInfo(
  code: 'ATLS-7K2M-9QX4',
  joinedCount: 7,
  pendingCount: 2,
  recent: [
    InviteFriend(name: 'สมชาย ใจดี', dateLabel: '21 ก.ค. 2569', joined: true),
    InviteFriend(name: 'มาลี ศรีสุข', dateLabel: '19 ก.ค. 2569', joined: true),
    InviteFriend(
      name: 'ปรีชา วงศ์ทอง',
      dateLabel: '18 ก.ค. 2569',
      joined: false,
    ),
    InviteFriend(
      name: 'วิภา แสงจันทร์',
      dateLabel: '15 ก.ค. 2569',
      joined: true,
    ),
    InviteFriend(
      name: 'ธนา รุ่งเรือง',
      dateLabel: '12 ก.ค. 2569',
      joined: true,
    ),
  ],
);

/// Mock of the quota-reached state, for previewing the reward CTA.
const kFullInvite = InviteInfo(
  code: 'ATLS-7K2M-9QX4',
  joinedCount: 10,
  pendingCount: 0,
  recent: [],
);

const _kAccent = Color(0xFF1D8B6B);

// ─────────────────────────────────────────────────────────────────────────────
// Card shown in the "ฉัน" screen
// ─────────────────────────────────────────────────────────────────────────────
/// Referral card in the style of a 3D weather card: big illustration on the
/// left, the headline stat top-right, and the pitch as a short forecast-like
/// line at the bottom.
class InviteCard extends StatelessWidget {
  const InviteCard({super.key, this.info = kDefaultInvite});

  final InviteInfo info;

  static const _gradTop = Color(0xFF93B9F8);
  static const _gradBottom = Color(0xFF5E8BEF);

  @override
  Widget build(BuildContext context) {
    // Quota reached — the CTA flips from inviting to claiming the reward.
    final full = info.joinedCount >= 10;
    return PressEffect(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute<void>(builder: (_) => InviteScreen(info: info)),
      ),
      haptic: HapticKind.selection,
      scale: 0.98,
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          // Card background — a separate layer so the gift art can sit
          // between it and the content instead of covering the CTA.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                // Quota reached flips the card to the reward's gold — same
                // metal as the grand-reward tile on the detail screen.
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  // Starts at the tile-gold midtone, not its pale highlight —
                  // the white copy in the top-left needs the contrast.
                  colors: full
                      ? const [Color(0xFFE7BC5C), Color(0xFFC28F38)]
                      : const [_gradTop, _gradBottom],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (full ? const Color(0xFFC28F38) : _gradBottom)
                        .withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          // Gift-box art follows the state: closed box while inviting,
          // opened box once the reward is ready. Sits behind the content
          // layer so it can never cover the CTA.
          Positioned(
            right: 16,
            top: 12,
            child: Image.asset(
              full ? 'assets/claim-reward.png' : 'assets/get-reward.png',
              width: 92,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
            // Single reading path: headline, one supporting line, then one
            // stat line with the CTA — no competing blocks.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 88),
                  child: Text(
                    'ชวนเพื่อนใช้ MyAtlas',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      fontVariations: [FontVariation('wght', 800)],
                      height: 1.25,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.only(right: 88),
                  child: Text(
                    'ส่งโค้ด แล้วดูแลสุขภาพไปด้วยกัน',
                    style: TextStyle(
                      color: CupertinoColors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${info.joinedCount}/10',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    fontVariations: [
                                      FontVariation('wght', 900),
                                    ],
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                const TextSpan(text: ' คนเข้าร่วมแล้ว'),
                              ],
                            ),
                            style: TextStyle(
                              color: CupertinoColors.white.withValues(
                                alpha: 0.92,
                              ),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Progress toward the 10-person quota.
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: SizedBox(
                              height: 5,
                              child: Stack(
                                children: [
                                  Container(
                                    color: CupertinoColors.white.withValues(
                                      alpha: 0.30,
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: (info.joinedCount / 10).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    child: Container(
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      // When full, the gold CTA claims right away: it pushes
                      // the detail screen with the claim popup auto-opened.
                      onTap: full
                          ? () => Navigator.of(context).push(
                              CupertinoPageRoute<void>(
                                builder: (_) =>
                                    InviteScreen(info: info, autoClaim: true),
                              ),
                            )
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          // White either way — on the gold card the gold
                          // pill would vanish into the background.
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              full ? 'รับรางวัล' : 'ชวนเลย',
                              style: TextStyle(
                                color: full
                                    ? const Color(0xFFB8862B)
                                    : _gradBottom,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                fontVariations: const [
                                  FontVariation('wght', 800),
                                ],
                                height: 1.0,
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
          // 3D illustration overflowing the card's top-left corner — the
          // Stack does not clip, so the part outside the card stays visible.
        ],
      ),
    );
  }
}

/// Reward strip: one card per invited person (1–10), scrolling horizontally.
/// The final count (10) carries the gift artwork; the numbers in
/// between show a plain person marker.
class _RewardStagesCard extends StatelessWidget {
  const _RewardStagesCard({required this.joined});

  final int joined;

  @override
  Widget build(BuildContext context) {
    // Two fixed rows of five — no scrolling.
    return Column(
      children: [
        for (int row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (int col = 0; col < 5; col++) ...[
                if (col > 0) const SizedBox(width: 8),
                Expanded(
                  child: _RewardStageTile(
                    count: row * 5 + col + 1,
                    joined: joined,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// One person-count card. Milestones show the reward box in its state;
/// non-milestones show a person marker that fills in once reached.
class _RewardStageTile extends StatelessWidget {
  const _RewardStageTile({required this.count, required this.joined});

  final int count;
  final int joined;

  /// Person-counts whose reward was already claimed — mock until the API.
  static const _claimedCounts = <int>{};

  /// Milestone → index into [_rewards]; null for plain counts.
  int? get _milestone {
    final i = _stages.indexOf(count);
    return i == -1 ? null : i;
  }

  bool get _reached => joined >= count;

  bool get _claimable =>
      _milestone != null && _reached && !_claimedCounts.contains(count);

  bool get _claimed =>
      _milestone != null && _reached && _claimedCounts.contains(count);

  /// Standard luminance grayscale — used to grey out claimed gift art.
  static const _grayscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Claimable opens the claim popup; already-claimed re-opens it
      // read-only so the reward can still be looked up.
      onTap: _claimable || _claimed
          ? () => showClaimRewardPopup(
              context,
              reward: _rewards[_milestone!],
              claimed: _claimed,
            )
          : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        decoration: BoxDecoration(
          // Reached tiles are grey (metal when claimable); anything not
          // yet reached stays white.
          color: _claimable
              ? null
              : _reached
              ? const Color(0xFFE3E3E3)
              : CupertinoColors.white,
          gradient: !_claimable
              ? null
              : _milestone == _stages.length - 1
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF9E4A0),
                    Color(0xFFE7BC5C),
                    Color(0xFFC28F38),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF93B9F8), Color(0xFF5E8BEF)],
                ),
          borderRadius: BorderRadius.circular(16),
          // White (unreached) tiles keep a hairline.
          border: !_reached
              ? Border.all(
                  color: const Color(0xFF747480).withValues(alpha: 0.08),
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: _milestone != null
                  ? ColorFiltered(
                      colorFilter: _claimed
                          ? _grayscale
                          : const ColorFilter.mode(
                              Color(0x00000000),
                              BlendMode.dst,
                            ),
                      child: Image.asset(
                        _reached
                            ? (_claimed
                                  ? 'assets/claim-reward.png'
                                  : 'assets/get-reward.png')
                            : 'assets/default-reward.png',
                        fit: BoxFit.contain,
                      ),
                    )
                  : Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Grey either way; reached is just a shade darker.
                          color: const Color(
                            0xFF747480,
                          ).withValues(alpha: _reached ? 0.16 : 0.08),
                        ),
                        alignment: Alignment.center,
                        // Invited slots show a paper plane — the invite flew.
                        // Slots not yet reached show their number instead.
                        child: _reached
                            ? const Icon(
                                CupertinoIcons.paperplane_fill,
                                size: 16,
                                color: Color(0xFF6B7280),
                              )
                            : Text(
                                '$count',
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  fontVariations: [FontVariation('wght', 900)],
                                  height: 1.0,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            // Fixed-height slot: the claimable tile swaps its number for a
            // claim button; everything else shows the count.
            SizedBox(
              height: 20,
              child: Center(
                child: _claimable
                    ? Container(
                        width: 40,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // Follows the card: deep gold on the gold card,
                          // deep blue on the blue one.
                          color: _milestone == _stages.length - 1
                              ? const Color(0xFFB8862B)
                              : const Color(0xFF3D66C9),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'รับ',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontVariations: [FontVariation('wght', 800)],
                            height: 1.0,
                          ),
                        ),
                      )
                    : Text(
                        // Status per slot: claimed milestones read "claimed",
                        // reached plain counts "invited", the rest "invite".
                        _claimed
                            ? 'รับแล้ว'
                            : _reached
                            ? 'ชวนแล้ว'
                            : 'เชิญ',
                        style: TextStyle(
                          color: _reached
                              ? const Color(0xFF3E453F)
                              : const Color(0xFF9CA3AF),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          // Nunito is variable — fontWeight alone doesn't
                          // move its wght axis.
                          fontVariations: const [FontVariation('wght', 900)],
                          height: 1.0,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Invites needed per reward milestone — the reward is earned only when
/// the full quota of 10 is reached.
const _stages = [10];

/// Mock reward per milestone, shown in the claim popup.
const _rewards = ['ตรวจสุขภาพฟรี 1 ครั้ง'];

// ─────────────────────────────────────────────────────────────────────────────
// Detail screen
// ─────────────────────────────────────────────────────────────────────────────

class InviteScreen extends StatefulWidget {
  const InviteScreen({
    super.key,
    this.info = kDefaultInvite,
    this.autoClaim = false,
  });

  final InviteInfo info;

  /// Opens the claim popup right after entering — used by the gold
  /// "รับรางวัล" CTA on the Me-page card so the tap delivers immediately.
  final bool autoClaim;

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    if (widget.autoClaim) {
      // Let the page settle before the popup pops over it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          showClaimRewardPopup(context, reward: _rewards.last);
        });
      });
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.info.code));
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    AppToast.success(context, 'คัดลอกโค้ดแล้ว');
  }

  Widget _stagger(int i, int total, Widget child) {
    final start = (i / total) * 0.6;
    final end = (start + 0.55).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 18),
          child: c,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final sections = <Widget>[
      _CodeCard(code: info.code, joined: info.joinedCount, onCopy: _copyCode),
      _RewardStagesCard(joined: info.joinedCount),
      const _HowItWorksCard(),
    ];

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DetailHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(
                  height: HealthDetailAppBar.safeAreaContentHeight,
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F8F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n is ScrollUpdateNotification ||
                            n is ScrollStartNotification) {
                          _scrollOffset.value = n.metrics.pixels;
                        }
                        return false;
                      },
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        itemCount: sections.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) =>
                            _stagger(i, sections.length, sections[i]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (_, offset, __) => HealthDetailAppBar(
                title: 'ชวนเพื่อน',
                scrollOffset: offset,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero card: the invite code itself, plus the two ways to pass it on.
/// Invite-code hero, laid out like a reminder card: colored header with the
/// title and status chips, and a white inner card carrying the code itself.
class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.code,
    required this.joined,
    required this.onCopy,
  });

  final String code;
  final int joined;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF93B9F8), Color(0xFF5E8BEF)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'โค้ดเชิญของคุณ',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Same treatment as the Me-page card: stat line with the
                    // number leading, progress bar underneath.
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$joined/10',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              fontVariations: [FontVariation('wght', 900)],
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const TextSpan(text: ' คนเข้าร่วมแล้ว'),
                        ],
                      ),
                      style: TextStyle(
                        color: CupertinoColors.white.withValues(alpha: 0.92),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: (joined / 10).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // White code block, flush to the card's edges — the outer
              // card's clip rounds its bottom corners.
              Container(
                decoration: const BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
                child: Row(
                  children: [
                    // Tapping the code itself (or the inline icon) copies it.
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onCopy,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  code,
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    fontVariations: [
                                      FontVariation('wght', 900),
                                    ],
                                    letterSpacing: 1.2,
                                    height: 1.0,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  CupertinoIcons.doc_on_doc,
                                  size: 12,
                                  color: Color(0xFF6D756E),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'แตะรหัสเพื่อคัดลอก',
                              style: TextStyle(
                                color: Color(0xFF6D756E),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Opens the invite QR sheet (save / share).
                    _CircleAction(
                      icon: CupertinoIcons.qrcode,
                      iconColor: const Color(0xFF3E453F),
                      onTap: () => showInviteQrSheet(context, code: code),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small outlined circular icon button in the white code row. The icon swap
/// pops in with a scale+fade, and the ring tints while highlighted.
class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.88,
      rippleShape: BoxShape.circle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF9CA3AF).withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 340),
          // Sequenced, not crossfaded: the Interval keeps each icon at scale 0
          // through half the timeline, so the old icon fully folds shut
          // before the new one springs open.
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: CurvedAnimation(
              parent: anim,
              curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
          child: Icon(
            icon,
            key: ValueKey(icon.codePoint),
            size: 15,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// The three steps, numbered because the order genuinely matters.
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  static const _steps = [
    'ส่งโค้ดให้เพื่อน หรือให้เพื่อนสแกน QR Code',
    'เพื่อนกรอกโค้ดตอนสมัครใช้งาน MyAtlas',
    'เมื่อสมัครสำเร็จ ยอดการเชิญของคุณจะเพิ่มขึ้น',
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'วิธีชวนเพื่อน',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == _steps.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kAccent.withValues(alpha: 0.12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: _kAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        _steps[i],
                        style: const TextStyle(
                          color: Color(0xFF3E453F),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invite QR sheet
// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen sheet with the user's invite QR — titled for inviting (not the
/// family connect flow), with save-to-device and share actions.
Future<void> showInviteQrSheet(BuildContext context, {required String code}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => _InviteQrSheet(code: code),
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

class _InviteQrSheet extends StatefulWidget {
  const _InviteQrSheet({required this.code});

  final String code;

  @override
  State<_InviteQrSheet> createState() => _InviteQrSheetState();
}

class _InviteQrSheetState extends State<_InviteQrSheet> {
  int _tab = 0; // 0 = My QR, 1 = Scan

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.fastEaseInToSlowEaseOut,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    final isQr = child.key == const ValueKey('qr');
                    final begin = isQr
                        ? const Offset(-0.15, 0)
                        : const Offset(0.15, 0);
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: begin,
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.center,
                    children: [...previous, if (current != null) current],
                  ),
                  child: _tab == 0
                      ? _InviteMyQrView(
                          key: const ValueKey('qr'),
                          code: widget.code,
                        )
                      : const _InviteScanView(key: ValueKey('scan')),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: Center(
                  child: _InviteTabs(
                    selected: _tab,
                    onChange: (i) => setState(() => _tab = i),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteSheetHeader extends StatelessWidget {
  const _InviteSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'ชวนเพื่อนด้วย QR',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: PressEffect(
                onTap: () => Navigator.of(context).pop(),
                haptic: HapticKind.selection,
                scale: 0.9,
                rippleShape: BoxShape.circle,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.white.withValues(alpha: 0.2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 16,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteMyQrView extends StatelessWidget {
  const _InviteMyQrView({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF93B9F8), Color(0xFF5E8BEF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -160,
            left: -80,
            child: Container(
              width: 640,
              height: 640,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    CupertinoColors.white.withValues(alpha: 0.25),
                    CupertinoColors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _InviteSheetHeader(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: CupertinoColors.white.withValues(alpha: 0.18),
                          width: 0.8,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/family/my_qr.png',
                            fit: BoxFit.contain,
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: CupertinoColors.white,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              CupertinoIcons.gift_fill,
                              color: Color(0xFF5E8BEF),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      code,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontVariations: [FontVariation('wght', 900)],
                        letterSpacing: 1.6,
                        height: 1.0,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ให้เพื่อนสแกนเพื่อสมัครด้วยโค้ดของคุณ',
                      style: TextStyle(
                        color: CupertinoColors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Save / share — same width as the QR card above.
                    SizedBox(
                      width: 260,
                      child: Row(
                        children: [
                          Expanded(
                            child: _QrSheetButton(
                              icon: CupertinoIcons.arrow_down_to_line,
                              label: 'บันทึกรูป',
                              filled: false,
                              onTap: () => AppToast.success(
                                context,
                                'บันทึกรูปลงเครื่องแล้ว',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QrSheetButton(
                              icon: CupertinoIcons.share,
                              label: 'แชร์',
                              filled: true,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 110),
            ],
          ),
        ],
      ),
    );
  }
}

class _InviteScanView extends StatelessWidget {
  const _InviteScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF333333),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [Color(0xFF555555), Color(0xFF1A1A1A)],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _InviteSheetHeader(),
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: _InviteScanFramePainter(),
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white.withValues(
                              alpha: 0.12,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ],
      ),
    );
  }
}

class _InviteScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const corner = 34.0;
    const radius = 24.0;
    final w = size.width;
    final h = size.height;

    Path corner1 = Path()
      ..moveTo(0, corner)
      ..lineTo(0, radius)
      ..arcToPoint(
        const Offset(radius, 0),
        radius: const Radius.circular(radius),
      )
      ..lineTo(corner, 0);
    Path corner2 = Path()
      ..moveTo(w - corner, 0)
      ..lineTo(w - radius, 0)
      ..arcToPoint(Offset(w, radius), radius: const Radius.circular(radius))
      ..lineTo(w, corner);
    Path corner3 = Path()
      ..moveTo(w, h - corner)
      ..lineTo(w, h - radius)
      ..arcToPoint(Offset(w - radius, h), radius: const Radius.circular(radius))
      ..lineTo(w - corner, h);
    Path corner4 = Path()
      ..moveTo(corner, h)
      ..lineTo(radius, h)
      ..arcToPoint(Offset(0, h - radius), radius: const Radius.circular(radius))
      ..lineTo(0, h - corner);

    canvas.drawPath(corner1, paint);
    canvas.drawPath(corner2, paint);
    canvas.drawPath(corner3, paint);
    canvas.drawPath(corner4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InviteTabs extends StatelessWidget {
  const _InviteTabs({required this.selected, required this.onChange});

  final int selected;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFD4D4D4).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(100),
      ),
      child: SizedBox(
        height: 36,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segW = constraints.maxWidth / 2;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutQuint,
                  left: selected * segW,
                  top: 0,
                  bottom: 0,
                  width: segW,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (int i = 0; i < 2; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChange(i),
                          child: Center(
                            child: Text(
                              i == 0 ? 'QR ของฉัน' : 'สแกน',
                              style: TextStyle(
                                color: i == selected
                                    ? const Color(0xFF5E8BEF)
                                    : const Color(0xFF1A1A1A),
                                fontSize: 15,
                                fontWeight: i == selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                letterSpacing: -0.23,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QrSheetButton extends StatelessWidget {
  const _QrSheetButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? const Color(0xFF5E8BEF) : CupertinoColors.white;
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.96,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled
              ? CupertinoColors.white
              : CupertinoColors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Claim-reward popup
// ─────────────────────────────────────────────────────────────────────────────

/// Centre popup when claiming a reward: the opened gift box pops in over a
/// blurred barrier, names the reward, and confirms with one button.
Future<void> showClaimRewardPopup(
  BuildContext context, {
  required String reward,
  bool claimed = false,
}) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'claim-reward',
    barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (_, __, ___) =>
        _ClaimRewardPopup(reward: reward, claimed: claimed),
    transitionBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: curved, child: child),
      );
    },
  );
}

class _ClaimRewardPopup extends StatelessWidget {
  const _ClaimRewardPopup({required this.reward, this.claimed = false});

  final String reward;

  /// True when re-opening an already-claimed reward just to view it.
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The opened box — the moment itself.
            Image.asset(
              'assets/claim-reward.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              claimed ? 'รางวัลที่ได้รับ' : 'ยินดีด้วย!',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontVariations: [FontVariation('wght', 800)],
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'คุณได้รับ $reward',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6D756E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            PressEffect(
              onTap: () {
                Navigator.of(context).pop();
                if (!claimed) AppToast.success(context, 'เก็บรางวัลแล้ว');
              },
              haptic: HapticKind.selection,
              scale: 0.96,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: double.infinity,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF93B9F8), Color(0xFF5E8BEF)],
                  ),
                ),
                child: Text(
                  claimed ? 'ปิด' : 'เก็บรางวัล',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontVariations: [FontVariation('wght', 800)],
                    height: 1.0,
                  ),
                ),
              ),
            ),
            if (!claimed) ...[
              const SizedBox(height: 8),
              PressEffect(
                onTap: () => Navigator.of(context).pop(),
                haptic: HapticKind.selection,
                scale: 0.96,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: double.infinity,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Text(
                    'ไว้ทีหลัง',
                    style: TextStyle(
                      color: Color(0xFF6D756E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
