import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../../core/services/live_activity_service.dart';
import '../../health/widgets/health_detail_app_bar.dart';

class HospitalQueueInfo {
  final String hospitalName;
  final String queueCode;
  final String patientName;
  final String servicePoint;
  final String dateLabel;
  final String time;
  final String insurance;
  final String department;
  final String room;
  final int waitCount;
  final String statusMessage;

  const HospitalQueueInfo({
    required this.hospitalName,
    required this.queueCode,
    required this.patientName,
    required this.servicePoint,
    required this.dateLabel,
    required this.time,
    required this.insurance,
    required this.department,
    required this.room,
    required this.waitCount,
    required this.statusMessage,
  });
}

const _defaultQueue = HospitalQueueInfo(
  hospitalName: 'โรงพยาบาลสมเด็จพระยุพราชบ้านดุง',
  queueCode: 'A005',
  patientName: 'คุณ ณัฐพงษ์ นันทชัย',
  servicePoint: 'จุดชักประวัติ',
  dateLabel: '22 ก.ค. 2569',
  time: '14:39 น.',
  insurance: 'ชำระเงินครบ',
  department: 'อายุรกรรม',
  room: '022 ห้องจ่ายยา OPD',
  waitCount: 2,
  statusMessage:
      'คิวของท่านใกล้จะถึงแล้ว กรุณาเตรียมตัวเพื่อเข้ารับบริการในเร็ว ๆ นี้',
);

class HomeHospitalQueueCard extends StatelessWidget {
  const HomeHospitalQueueCard({super.key, this.info = _defaultQueue});

  final HospitalQueueInfo info;

  static const _grad = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFEFF6FA)],
  );

  void _showDetails(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => _QueueDetailScreen(info: info)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDetails(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: _grad,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1E88E5),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          size: 16,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'คิวรับบริการโรงพยาบาล',
                        style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    info.hospitalName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_solid,
                        size: 11,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        info.servicePoint,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 11,
                          color: CupertinoColors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'รอ ${info.waitCount} คิว',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _QueueBadge(code: info.queueCode),
          ],
        ),
      ),
    );
  }
}

/// Wait-count copy, tiered so a short wait reads as "you're nearly up" instead
/// of just showing another number to count down.
///
///   0 queues  -> ถึงคิวแล้ว
///   1 queue   -> คิวต่อไปคือคุณ
///   2+        -> เหลืออีก N คิว   ("เหลือ" frames the queue as draining, which
///                                  reads shorter than the neutral "อีก")
class _WaitCopy extends StatelessWidget {
  const _WaitCopy({
    required this.waitCount,
    required this.accent,
    required this.numberSize,
    required this.labelSize,
    required this.messageSize,
  });

  final int waitCount;
  final Color accent;
  final double numberSize;
  final double labelSize;
  final double messageSize;

  @override
  Widget build(BuildContext context) {
    // Every state renders inside a box as tall as the tallest one (the number),
    // so switching copy never changes the bar's height.
    return SizedBox(
      height: numberSize,
      child: Align(
        alignment: Alignment.centerLeft,
        // widthFactor keeps the box hugging its copy — without it Align takes
        // all the width it is offered.
        widthFactor: 1,
        child: waitCount <= 1 ? _message() : _countdown(),
      ),
    );
  }

  Widget _message() {
    return Text(
      waitCount <= 0 ? 'ถึงคิวแล้ว' : 'คิวต่อไปคือคุณ',
      maxLines: 1,
      style: TextStyle(
        color: accent,
        fontSize: messageSize,
        fontWeight: FontWeight.w800,
        fontVariations: const [FontVariation('wght', 800)],
        height: 1.0,
      ),
    );
  }

  Widget _countdown() {
    final label = TextStyle(
      color: const Color(0xFF3E453F),
      fontSize: labelSize,
      fontWeight: FontWeight.w600,
      height: 1.0,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('เหลืออีก', style: label),
        const SizedBox(width: 5),
        // Only the number swaps, sliding up as the queue counts down.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => ClipRect(
            child: FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.8),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
          ),
          child: Text(
            '$waitCount',
            key: ValueKey(waitCount),
            style: TextStyle(
              color: accent,
              fontSize: numberSize,
              fontWeight: FontWeight.w900,
              fontVariations: const [FontVariation('wght', 900)],
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text('คิว', style: label),
      ],
    );
  }
}

/// Grab-style "ongoing order" bar: a compact card that floats just above the
/// bottom navbar while the queue is active. Tapping it opens the full detail
/// screen, same as the in-feed card.
class FloatingQueueBar extends StatefulWidget {
  const FloatingQueueBar({super.key, this.info = _defaultQueue});

  final HospitalQueueInfo info;

  @override
  State<FloatingQueueBar> createState() => _FloatingQueueBarState();
}

class _FloatingQueueBarState extends State<FloatingQueueBar>
    with SingleTickerProviderStateMixin {
  // Slides up into place on first show, and survives hot reload.
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..forward();

  bool _pressed = false;

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _open() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute<void>(
        builder: (_) => _QueueDetailScreen(info: widget.info),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    // Solid light surface — the bar sits on top of the feed, so it stays quiet
    // and lets the accent colour do the signalling.
    const accent = Color(0xFF1E88E5);
    final anim = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 28),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: _open,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 140),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF747480).withValues(alpha: 0.12),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              // IntrinsicHeight lets the queue-code box stretch to the same
              // height as the text column beside it.
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Context line: where the queue is being served.
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.location_solid,
                                size: 10,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  info.servicePoint,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          // The answer to "how much longer?" — the loudest
                          // thing in the bar.
                          _WaitCopy(
                            waitCount: info.waitCount,
                            accent: accent,
                            numberSize: 28,
                            labelSize: 13,
                            messageSize: 19,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            info.hospitalName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // The patient's own queue code — their identity in the queue,
                    // boxed off so it reads as a separate fact.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'คิวของคุณ',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            info.queueCode,
                            style: const TextStyle(
                              color: Color(0xFF1E88E5),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontVariations: [FontVariation('wght', 900)],
                              letterSpacing: 0.5,
                              height: 1.0,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
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
  }
}

class _QueueBadge extends StatelessWidget {
  const _QueueBadge({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FC3F7), Color(0xFF1E88E5)],
        ),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.14),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33093327),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'คิวของท่าน'.toUpperCase(),
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.65),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              code,
              maxLines: 1,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                height: 1.0,
                fontFeatures: [FontFeature.tabularFigures()],
                shadows: [Shadow(color: Color(0x66FFFFFF), blurRadius: 12)],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _DashedDivider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ดูรายละเอียด',
                style: TextStyle(
                  color: CupertinoColors.white.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                CupertinoIcons.chevron_right,
                size: 10,
                color: CupertinoColors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        const dashW = 4.0;
        const gapW = 3.0;
        final n = (c.maxWidth / (dashW + gapW)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            n,
            (_) => Container(
              width: dashW,
              height: 1,
              color: CupertinoColors.white.withValues(alpha: 0.28),
            ),
          ),
        );
      },
    );
  }
}

class _QueueDetailScreen extends StatefulWidget {
  const _QueueDetailScreen({required this.info});
  final HospitalQueueInfo info;

  @override
  State<_QueueDetailScreen> createState() => _QueueDetailScreenState();
}

class _QueueDetailScreenState extends State<_QueueDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);
  final _live = LiveActivityService.instance;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enter.forward();
      _startLiveActivity();
    });
  }

  Future<void> _startLiveActivity() async {
    final info = widget.info;
    await _live.start(
      hospitalName: info.hospitalName,
      queueCode: info.queueCode,
      servicePoint: info.servicePoint,
      waitCount: info.waitCount,
      etaLabel: '~${info.waitCount * 6} นาที',
      step: 1,
      statusLabel: 'กำลังรอเรียก',
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    _scrollOffset.dispose();
    super.dispose();
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
      builder: (_, c) {
        final t = anim.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 18), child: c),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final sections = <Widget>[
      _QueueHeroCard(info: info),
      _SectionCard(
        title: 'ข้อมูลผู้รับบริการ',
        child: Column(
          children: [
            _DetailRow(
              icon: CupertinoIcons.person_fill,
              iconColor: const Color(0xFF1D8B6B),
              label: 'ผู้ป่วย',
              value: info.patientName,
            ),
            _DetailRow(
              icon: CupertinoIcons.creditcard_fill,
              iconColor: const Color(0xFF1D8B6B),
              label: 'สิทธิการรักษา',
              value: info.insurance,
            ),
          ],
        ),
      ),
      _SectionCard(
        title: 'จุดรับบริการ',
        child: Column(
          children: [
            _DetailRow(
              icon: CupertinoIcons.location_solid,
              iconColor: const Color(0xFFDC2626),
              label: 'จุดรับบริการ',
              value: info.servicePoint,
            ),
            _DetailRow(
              icon: CupertinoIcons.plus_app_fill,
              iconColor: const Color(0xFFE32616),
              label: 'แผนก',
              value: info.department,
            ),
            _DetailRow(
              icon: CupertinoIcons.square_grid_2x2_fill,
              iconColor: const Color(0xFF7C3AED),
              label: 'ห้อง',
              value: info.room,
            ),
          ],
        ),
      ),
      _SectionCard(
        title: 'วันเวลา',
        child: Column(
          children: [
            _DetailRow(
              icon: CupertinoIcons.calendar,
              iconColor: const Color(0xFFEA580C),
              label: 'วันที่',
              value: info.dateLabel,
            ),
            _DetailRow(
              icon: CupertinoIcons.time_solid,
              iconColor: const Color(0xFF2563EB),
              label: 'เวลา',
              value: info.time,
            ),
          ],
        ),
      ),
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
                title: 'รายละเอียดคิว',
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

class _QueueHeroCard extends StatelessWidget {
  const _QueueHeroCard({required this.info});
  final HospitalQueueInfo info;

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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E88E5),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 22,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'โรงพยาบาล',
                      style: TextStyle(
                        color: Color(0xFF6D756E),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.hospitalName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Queue code block — light blue tint, matching the floating bar's
          // theme instead of the old solid gradient.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF1E88E5).withValues(alpha: 0.08),
            ),
            child: Column(
              children: [
                const Text(
                  'คิวของท่าน',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                // The queue code is the patient's own number — it never
                // changes, so it is rendered statically.
                Text(
                  info.queueCode,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    fontVariations: [FontVariation('wght', 900)],
                    color: Color(0xFF1E88E5),
                    letterSpacing: 3,
                    height: 1.0,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.location_solid,
                      size: 11,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      info.servicePoint,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // "Queues ahead" pill — its own element below the queue card.
          Center(child: _WaitPill(waitCount: info.waitCount)),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

/// Tinted pill under the queue code on the detail screen, carrying the same
/// wait copy as the floating bar.
class _WaitPill extends StatelessWidget {
  const _WaitPill({required this.waitCount});
  final int waitCount;

  @override
  Widget build(BuildContext context) {
    // Same treatment as the floating bar: quiet tinted surface, accent-coloured
    // copy carrying the meaning.
    const accent = Color(0xFF1E88E5);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: accent.withValues(alpha: 0.09),
      ),
      // The pill hugs its copy, so animate the width change too — the height
      // is already fixed by _WaitCopy.
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: _WaitCopy(
          waitCount: waitCount,
          accent: accent,
          numberSize: 22,
          labelSize: 13,
          messageSize: 15,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 24px solid circle + white icon — the app-wide convention for the
          // chip in front of a label (settings, family, health, nutrition).
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 13, color: CupertinoColors.white),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6D756E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
