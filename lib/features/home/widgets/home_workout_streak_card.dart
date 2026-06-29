import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../core/services/app_settings_service.dart';
import '../workout_clip_picker_screen.dart';

// Resolve the user-selected font so this card follows the Display setting.
AppFontSpec get _spec => AppSettingsService.instance.fontSpec;
String get _famFamily => _spec.family;
List<String> get _famFallback => _spec.fallback;

/// Workout-streak calendar card.
///
/// Concept: the app lets you dance along to workout clips and scores your
/// accuracy. This card shows which days of the week you worked out — each
/// active day gets a flame behind the date. Keeping a streak (5+ consecutive
/// days) shows a growing "streak" badge to encourage the user to keep going.
/// Days with no workout show a plain number; if there's no workout at all the
/// card shows an invitation to start.
class HomeWorkoutStreakCard extends StatefulWidget {
  final Set<DateTime> workoutDays;
  final VoidCallback? onStartTap;

  /// Per-day dance result — date → (score, accuracy %). The donut shows the
  /// selected day's result and updates when another day is tapped.
  final Map<DateTime, (int score, int accuracy)> dayResults;

  const HomeWorkoutStreakCard({
    super.key,
    this.workoutDays = const {},
    this.onStartTap,
    this.dayResults = const {},
  });

  @override
  State<HomeWorkoutStreakCard> createState() => _HomeWorkoutStreakCardState();
}

class _HomeWorkoutStreakCardState extends State<HomeWorkoutStreakCard> {
  static const _ink = Color(0xFF1A1A2E);
  static const _flameTop = Color(0xFFFF9500); // orange
  static const _flameBottom = Color(0xFFFF3B30); // red
  static const _thWeekLabels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  // Currently selected day (the focused chip) — defaults to today.
  late DateTime _selected;

  // Week pager — each page is one week; swiping moves week-by-week with a
  // slide animation. A large base index lets the user page both directions.
  static const int _basePage = 10000;
  final PageController _weekController =
      PageController(initialPage: _basePage);

  static const _thMonths = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _weekController.dispose();
    super.dispose();
  }

  DateTime _mondayOfCurrentWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  DateTime _weekStartForPage(int page) =>
      _mondayOfCurrentWeek().add(Duration(days: (page - _basePage) * 7));

  /// Selected date as "วัน เดือน ปี" (Buddhist year), e.g. "17 มิถุนายน 2569".
  String _formatThaiDate(DateTime d) =>
      '${d.day} ${_thMonths[d.month - 1]} ${d.year + 543}';

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _didWorkout(DateTime d) => widget.workoutDays.any((w) => _same(w, d));

  /// Dance result for [day], or null when there's none.
  (int score, int accuracy)? _resultFor(DateTime d) {
    for (final e in widget.dayResults.entries) {
      if (_same(e.key, d)) return e.value;
    }
    return null;
  }

  /// Length of the consecutive workout run that contains [d] (0 if [d] is a
  /// rest day).
  int _consecutiveRun(DateTime d) {
    if (!_didWorkout(d)) return 0;
    var len = 1;
    for (var p = d.subtract(const Duration(days: 1));
        _didWorkout(p);
        p = p.subtract(const Duration(days: 1))) {
      len++;
    }
    for (var n = d.add(const Duration(days: 1));
        _didWorkout(n);
        n = n.add(const Duration(days: 1))) {
      len++;
    }
    return len;
  }

  /// A workout day is a "streak" day (flame) when it's part of a run of 3+
  /// consecutive workout days. A shorter run shows the exercise-person icon.
  bool _isStreakDay(DateTime d) => _consecutiveRun(d) >= 3;

  /// Consecutive workout days ending today (if today is done) or yesterday
  /// (if today is not done yet — the streak is still alive).
  int _streak() {
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!_didWorkout(day)) {
      day = day.subtract(const Duration(days: 1));
    }
    var s = 0;
    while (_didWorkout(day)) {
      s++;
      day = day.subtract(const Duration(days: 1));
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final empty = widget.workoutDays.isEmpty;
    final streak = _streak();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final doneToday = _didWorkout(today);

    // Title reflects the SELECTED day's status.
    final bool selDone = _didWorkout(_selected);
    final bool isToday = _same(_selected, today);
    final bool isFuture = _selected.isAfter(today);

    final String title;
    if (empty) {
      title = 'เริ่มออกกำลังกายกันเลย!';
    } else if (isToday) {
      if (!doneToday) {
        title = 'มาออกกำลังกายของวันนี้กันเถอะ';
      } else if (streak >= 3) {
        title = 'ออกกำลังกายต่อเนื่องมา $streak วันแล้ว';
      } else {
        title = 'วันนี้คุณชนะใจตัวเองได้สำเร็จ';
      }
    } else if (isFuture) {
      title = 'พักเติมพลังแล้วมาลุยกันใหม่!';
    } else if (selDone) {
      // Past workout day — different title when it's part of a streak.
      if (_isStreakDay(_selected)) {
        title =
            'ออกกำลังกายต่อเนื่องมา ${_consecutiveRun(_selected)} วันแล้ว';
      } else {
        title = 'วันนี้คุณชนะใจตัวเองได้สำเร็จ';
      }
    } else {
      // Past day with no workout — missed.
      title = 'วันนี้พลาดไป ครั้งหน้าเอาใหม่!';
    }
    // Description shows the selected day's date (วัน เดือน ปี).
    final String subtitle = _formatThaiDate(_selected);

    // Decorative artwork follows the SELECTED day: never worked out yet →
    // StartAerobic, today → Aerobic1, a rest day → Rest, a workout day that's
    // part of a streak → Aerobic2, a lone workout (no streak) → Aerobic1.
    final bool isRest = !empty && !isToday && !selDone;
    final bool isAerobic2 = !empty && !isToday && selDone && _isStreakDay(_selected);
    final String heroImage = empty
        ? 'assets/startaerobic.png'
        : isToday
            ? 'assets/Aerobic1.png'
            : isRest
                ? 'assets/rest.png'
                : isAerobic2
                    ? 'assets/Aerobic2.png'
                    : 'assets/Aerobic1.png';
    // startaerobic, rest and Aerobic2 are 16px larger than the default Aerobic1.
    // All anchor to the same top-right corner inside a fixed-size box so the
    // crossfade between images doesn't shift the layout.
    final bool isStartLike = empty || isRest;
    final double heroHeight = (isStartLike || isAerobic2) ? 166 : 150;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative aerobic figures — behind the calendar panel (the panel
          // overlaps them in front); they peek out at the top-right. A
          // fixed-size box keeps the footprint constant so swapping images only
          // crossfades (no layout shift/jitter when the selected day changes).
          Positioned(
            top: -4,
            right: -10,
            child: IgnorePointer(
              child: SizedBox(
                width: 180,
                height: 180,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Align(
                    key: ValueKey(heroImage),
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      heroImage,
                      height: heroHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header (padded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: _famFamily, fontFamilyFallback: _famFallback,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: _famFamily, fontFamilyFallback: _famFallback,
                        fontSize: 12,
                        color: Color(0xFF5B6B7A),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 14),
          if (empty)
            // No workout yet: calendar panel, blur + gradient overlay, and the
            // "start" button on top.
            Stack(
              children: [
                _calendarPanel(today),
                Positioned.fill(
                  // ClipRRect confines the blur to the calendar panel only
                  // (otherwise BackdropFilter blurs up to the card's clip).
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Button pinned to the bottom, 12px from each edge.
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _startButton(),
                ),
              ],
            )
              else
                _calendarPanel(today),
            ],
          ),
        ],
      ),
    );
  }

  // Selected day's result as a donut: ring = accuracy %, score in the center.
  // When the selected day has no workout the center shows a start prompt:
  // tappable (today + not done) or disabled (a future day); a past day with no
  // workout just reads "พัก".
  Widget _danceStats(
    (int score, int accuracy)? result, {
    bool canStart = false,
    bool isFuture = false,
  }) {
    const size = 66.0;
    final hasResult = result != null;
    // No workout → no donut ring, just the exercise icon button (or "พัก").
    if (!hasResult) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: _restIcon(canStart: canStart, isFuture: isFuture),
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring sweeps to the accuracy on appearance.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: result.$2 / 100),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => CustomPaint(
              size: const Size.square(size),
              painter: _DonutPainter(v),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score counts up.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: result.$1.toDouble()),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, v, __) => Text(
                  _formatInt(v.round()),
                  style: TextStyle(
                    fontFamily: _famFamily, fontFamilyFallback: _famFallback,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'คะแนน',
                style: TextStyle(
                  fontFamily: _famFamily, fontFamilyFallback: _famFallback,
                  fontSize: 8,
                  color: Color(0xFFB58A6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Center content for a day with no workout — a bare exercise icon button.
  //  • canStart (today, not done) → orange, tappable, routes to the clip picker.
  //  • isFuture → muted, disabled (the day hasn't arrived).
  //  • otherwise (past, missed) → a plain "พัก".
  Widget _restIcon({required bool canStart, required bool isFuture}) {
    if (!canStart && !isFuture) {
      // A past day with no workout → a muted "resting" icon in a circle.
      return Container(
        width: 66,
        height: 66,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF1E4D8),
        ),
        child: const Icon(
          Icons.self_improvement,
          size: 32,
          color: Color(0xFFB58A6B),
        ),
      );
    }
    // A filled circular button so it clearly reads as tappable.
    return GestureDetector(
      onTap: canStart ? _handleStart : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 66,
        height: 66,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: canStart
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_flameTop, _flameBottom],
                )
              : null,
          color: canStart ? null : const Color(0xFFE7DACE),
          boxShadow: canStart
              ? [
                  BoxShadow(
                    color: _flameBottom.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.sports_gymnastics,
          size: 34,
          color: canStart ? Colors.white : const Color(0xFFB7A595),
        ),
      ),
    );
  }

  static String _formatInt(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  // Opens the clip picker. Prefers the injected callback (so a host screen can
  // override routing); otherwise pushes the picker directly so the flow works
  // even where no callback is wired (e.g. the mockup cards).
  void _handleStart() {
    if (widget.onStartTap != null) {
      widget.onStartTap!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WorkoutClipPickerScreen()),
    );
  }

  Widget _calendarPanel(DateTime today) {
    final showStats = widget.dayResults.isNotEmpty;
    // Start is allowed only on today when not yet done. A future day shows the
    // "เริ่มออกกำลังกาย" prompt but stays disabled (the day hasn't arrived).
    final canStart = _same(_selected, today) && !_didWorkout(_selected);
    final isFuture = _selected.isAfter(today);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF4EC), // white with a soft orange tint
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Swipeable weeks — each page is one week, slides on swipe.
          Expanded(
            child: SizedBox(
              height: 78,
              child: PageView.builder(
                controller: _weekController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (_) => setState(() {}),
                itemBuilder: (context, page) {
                  final start = _weekStartForPage(page);
                  final days = List.generate(
                    7,
                    (i) => DateTime(start.year, start.month, start.day + i),
                  );
                  return _weekRow(days, today);
                },
              ),
            ),
          ),
          if (showStats) ...[
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1).animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_selected),
                child: _danceStats(
                  _resultFor(_selected),
                  canStart: canStart,
                  isFuture: isFuture,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _weekRow(List<DateTime> week, DateTime today) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final day in week) Expanded(child: _dayCell(day, today)),
      ],
    );
  }

  Widget _dayCell(DateTime day, DateTime today) {
    final active = _didWorkout(day);
    final isToday = _same(day, today);
    final isFocus = _same(day, _selected);

    final Widget indicator;
    if (active && isToday) {
      // Finished today → animated ring; completes into a flame when it's part
      // of a streak, otherwise a checkmark.
      indicator = _CompletedRing(size: 22, streak: _isStreakDay(day));
    } else if (active) {
      // Past workout day: flame when on a streak, exercise-person when it's a
      // lone workout (streak broken / restarted).
      indicator = Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFocus ? Colors.white : const Color(0xFFFFDCC4),
          shape: BoxShape.circle,
        ),
        child: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_flameTop, _flameBottom],
          ).createShader(b),
          child: Icon(
            _isStreakDay(day)
                ? CupertinoIcons.flame_fill
                : Icons.sports_gymnastics,
            size: _isStreakDay(day) ? 14 : 15,
            color: Colors.white,
          ),
        ),
      );
    } else if (isToday) {
      // Today, not worked out yet → exercise icon in a circle (matches the
      // workout-day chips: white bg when focused, soft orange otherwise).
      indicator = Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFocus ? Colors.white : const Color(0xFFFFDCC4),
          shape: BoxShape.circle,
        ),
        child: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_flameTop, _flameBottom],
          ).createShader(b),
          child: const Icon(
            Icons.sports_gymnastics,
            size: 15,
            color: Colors.white,
          ),
        ),
      );
    } else if (day.isBefore(today)) {
      // Past day with no workout → a muted "rest" icon in a circle.
      indicator = Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFocus ? Colors.white : const Color(0xFFF1E4D8),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.self_improvement,
          size: 14,
          color: Color(0xFFB58A6B),
        ),
      );
    } else {
      // Future day → dashed placeholder (hasn't happened yet).
      indicator = _DashedCircle(
        size: 18,
        color: isFocus ? Colors.white : const Color(0xFFE3B59C),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected = day),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Weekday label
          Text(
            _thWeekLabels[day.weekday - 1],
            style: TextStyle(
              fontFamily: _famFamily, fontFamilyFallback: _famFallback,
              fontSize: 11,
              color: Color(0xFFB58A6B),
            ),
          ),
          const SizedBox(height: 8),
          // Fixed-height zone so all cells (and labels) line up. Only the
          // focused (selected) day gets the orange capsule; others have no bg.
          SizedBox(
            width: 34,
            height: 54,
            child: Container(
              decoration: isFocus
                  ? BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_flameTop, _flameBottom],
                      ),
                      borderRadius: BorderRadius.circular(17),
                    )
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontFamily: _famFamily, fontFamilyFallback: _famFallback,
                      fontSize: 13,
                      fontWeight:
                          isFocus ? FontWeight.w800 : FontWeight.w600,
                      color: isFocus ? Colors.white : _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  indicator,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _startButton() {
    return GestureDetector(
      onTap: _handleStart,
      child: Container(
        width: double.infinity,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_flameTop, _flameBottom],
          ),
          boxShadow: [
            BoxShadow(
              color: _flameBottom.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_gymnastics, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'เริ่มเต้นเลย',
              style: TextStyle(
                fontFamily: _famFamily, fontFamilyFallback: _famFallback,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small dashed-outline circle shown on days with no workout.
class _DashedCircle extends StatelessWidget {
  const _DashedCircle({required this.size, this.color = const Color(0xFFE3B59C)});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DashedCirclePainter(color),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 1,
    );
    const dashes = 14;
    const sweep = (2 * 3.1415926535 / dashes);
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) => old.color != color;
}

/// "Completed today" indicator: an orange ring sweeps around the circle (like a
/// loader) then reveals a checkmark.
class _CompletedRing extends StatefulWidget {
  const _CompletedRing({required this.size, this.streak = false});
  final double size;
  final bool streak;

  @override
  State<_CompletedRing> createState() => _CompletedRingState();
}

class _CompletedRingState extends State<_CompletedRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF5A2C);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          // Ring fills over the first ~70%, the check fades/scales in after.
          final ringP =
              Curves.easeOut.transform((_c.value / 0.7).clamp(0.0, 1.0));
          final checkP = ((_c.value - 0.62) / 0.38).clamp(0.0, 1.0);
          return Stack(
            alignment: Alignment.center,
            children: [
              const DecoratedBox(
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: SizedBox.expand(),
              ),
              CustomPaint(
                size: Size.square(widget.size),
                painter: _RingPainter(ringP),
              ),
              Opacity(
                opacity: checkP,
                child: Transform.scale(
                  scale: 0.5 + 0.5 * checkP,
                  // Flame when on a streak; checkmark otherwise.
                  child: widget.streak
                      ? ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFF9500), Color(0xFFFF3B30)],
                          ).createShader(b),
                          child: Icon(CupertinoIcons.flame_fill,
                              size: widget.size * 0.62, color: Colors.white),
                        )
                      : Icon(Icons.check_rounded,
                          size: widget.size * 0.62, color: orange),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Donut: light track + orange progress arc (accuracy %).
class _DonutPainter extends CustomPainter {
  _DonutPainter(this.progress);
  final double progress;

  static const double _twoPi = 6.283185307179586;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final track = Paint()
      ..color = const Color(0xFFF1CFBA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF9500), Color(0xFFFF3B30)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -_twoPi / 4,
      _twoPi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;

  static const double _twoPi = 6.283185307179586;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.4;
    final track = Paint()
      ..color = const Color(0xFFFFE0CC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = const Color(0xFFFF5A2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -_twoPi / 4, // start at top
      _twoPi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
