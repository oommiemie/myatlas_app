import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart'
    show
        CupertinoButton,
        CupertinoDatePicker,
        CupertinoDatePickerMode,
        CupertinoIcons,
        showCupertinoModalPopup;
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

  /// แสดงเฉพาะแถบปฏิทิน ตัดกรอบการ์ด หัวข้อ และภาพประกอบออก
  /// ใช้เมื่อยกไปวางเป็นหัวของหน้าอื่น
  final bool calendarOnly;

  /// ปุ่มที่วางไว้หน้าชื่อเดือน (เช่น ปุ่มย้อนกลับของหน้าจอ) — ใช้กับ
  /// calendarOnly เท่านั้น เพราะโหมดนี้ชื่อเดือนทำหน้าที่เป็นชื่อหน้าไปด้วย
  final Widget? leading;

  /// แจ้งหน้าจอที่ครอบอยู่เมื่อผู้ใช้เลือกวันอื่น เพื่อให้สลับเนื้อหาด้านล่างได้
  final ValueChanged<DateTime>? onDaySelected;

  /// วันที่ให้เลือกค้างไว้ตอนสร้าง — ใช้ตอนเปิดหน้ารายละเอียดให้ตรงกับวัน
  /// ที่ผู้ใช้เลือกไว้ในหน้าหลัก ถ้าไม่ส่งมาจะใช้วันนี้
  final DateTime? initialDay;

  const HomeWorkoutStreakCard({
    super.key,
    this.workoutDays = const {},
    this.onStartTap,
    this.dayResults = const {},
    this.calendarOnly = false,
    this.leading,
    this.onDaySelected,
    this.initialDay,
  });

  @override
  State<HomeWorkoutStreakCard> createState() => _HomeWorkoutStreakCardState();
}

class _HomeWorkoutStreakCardState extends State<HomeWorkoutStreakCard> {
  static const _ink = Color(0xFF1A1A2E);
  static const _flameTop = Color(0xFFF7A555); // ส้มอ่อน
  static const _flameBottom = Color(0xFFFB6618); // ส้มเข้ม
  static const _thWeekLabels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  // Currently selected day (the focused chip) — defaults to today.
  late DateTime _selected;

  // Week pager — each page is one week; swiping moves week-by-week with a
  // slide animation. A large base index lets the user page both directions.
  static const int _basePage = 10000;
  late final PageController _weekController;

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
    _selected = widget.initialDay ?? DateTime(now.year, now.month, now.day);
    // เปิดหน้ามาที่สัปดาห์ของวันที่เลือก ไม่ใช่สัปดาห์ปัจจุบันเสมอไป
    final monday = _selected.subtract(Duration(days: _selected.weekday - 1));
    final weeks = monday.difference(_mondayOfCurrentWeek()).inDays ~/ 7;
    _weekController = PageController(initialPage: _basePage + weeks);
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

  /// Length of the consecutive workout run that contains [d] (0 if [d] is a
  /// rest day).
  int _consecutiveRun(DateTime d) {
    if (!_didWorkout(d)) return 0;
    var len = 1;
    for (
      var p = d.subtract(const Duration(days: 1));
      _didWorkout(p);
      p = p.subtract(const Duration(days: 1))
    ) {
      len++;
    }
    for (
      var n = d.add(const Duration(days: 1));
      _didWorkout(n);
      n = n.add(const Duration(days: 1))
    ) {
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

    // โหมดปฏิทินล้วน — คืนเฉพาะแถบปฏิทิน ไม่มีกรอบการ์ดและภาพประกอบ
    if (widget.calendarOnly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            // ชื่อเดือนอยู่กึ่งกลางแถวจริงๆ ไม่ใช่กึ่งกลางพื้นที่ที่เหลือ
            // จึงวางซ้อนกัน: แถวปุ่มอยู่ชั้นล่าง ชื่อเดือนลอยกึ่งกลางชั้นบน
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    if (widget.leading != null) widget.leading!,
                    const Spacer(),
                    _streakPill(),
                  ],
                ),
                IgnorePointer(
                  ignoring: false,
                  child: Center(child: _monthHeader()),
                ),
              ],
            ),
          ),
          _calendarPanel(today),
        ],
      );
    }

    // Title reflects the SELECTED day's status.
    final bool selDone = _didWorkout(_selected);
    final bool isToday = _same(_selected, today);
    final bool isFuture = _selected.isAfter(today);

    final String title;
    if (empty) {
      title = 'เริ่มออกกำลังกายกันเลย!';
    } else if (isToday) {
      if (!doneToday) {
        title = 'มาออกกำลังกายกันเถอะ';
      } else if (streak >= 3) {
        title = 'ต่อเนื่องมาแล้ว $streak วัน';
      } else {
        title = 'ชนะใจตัวเองได้สำเร็จ';
      }
    } else if (isFuture) {
      title = 'พักเติมพลังแล้วมาลุยกันใหม่!';
    } else if (selDone) {
      // Past workout day — different title when it's part of a streak.
      if (_isStreakDay(_selected)) {
        title = 'ต่อเนื่องมาแล้ว ${_consecutiveRun(_selected)} วัน';
      } else {
        title = 'ชนะใจตัวเองได้สำเร็จ';
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
    final bool isAerobic2 =
        !empty && !isToday && selDone && _isStreakDay(_selected);
    final bool isStartLike = empty || isRest;
    // ค่าเดียวกับฝั่ง React (HomeWorkoutStreakCard.tsx บรรทัด 279)
    final double heroHeight = (isStartLike || isAerobic2) ? 146 : 132;
    final String heroImage = empty
        ? 'assets/startaerobic.png'
        : isToday
        ? 'assets/Aerobic1.png'
        : isRest
        ? 'assets/rest.png'
        : isAerobic2
        ? 'assets/Aerobic2.png'
        : 'assets/Aerobic1.png';

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
          // ภาพประกอบอยู่หลังแถบปฏิทิน โผล่ที่มุมขวาบน กล่องขนาดคงที่ทำให้
          // การสลับภาพเป็นการ crossfade เฉยๆ ไม่ทำให้ layout ขยับ
          Positioned(
            top: -4,
            right: -10,
            child: IgnorePointer(
              child: SizedBox(
                width: 160,
                height: 160,
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
                    // ปล่อยความกว้างตามอัตราส่วนจริงของไฟล์ เทียบเท่า
                    // width = height * aspect ของฝั่ง React
                    child: OverflowBox(
                      alignment: Alignment.topRight,
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
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
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header (padded)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openDetail,
                child: Padding(
                  // เว้นขวา 108 เท่า HEAD_RESERVE ของฝั่ง React กันข้อความชนภาพ
                  padding: const EdgeInsets.fromLTRB(16, 16, 108, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // บรรทัดเดียวเสมอ (15 x 1.2) ความสูงส่วนขาวจึงคงที่
                      // ไม่ว่าจะเลือกวันไหน การ์ดไม่กระเด้ง
                      SizedBox(
                        height: 18,
                        width: double.infinity,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _famFamily,
                            fontFamilyFallback: _famFallback,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: _ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: _famFamily,
                              fontFamilyFallback: _famFallback,
                              fontSize: 12,
                              color: Color(0xFF5B6B7A),
                            ),
                          ),
                          const SizedBox(width: 2),
                          // บอกว่าการ์ดนี้เข้าไปดูรายละเอียดต่อได้
                          const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 12,
                            color: Color(0xFF9AA7B4),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                        borderRadius: const BorderRadius.all(
                          Radius.circular(24),
                        ),
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
  // Opens the clip picker. Prefers the injected callback (so a host screen can
  // override routing); otherwise pushes the picker directly so the flow works
  // even where no callback is wired (e.g. the mockup cards).
  void _handleStart() => _openDetail();

  /// เปิดหน้ารายละเอียดโดยค้างไว้ที่วันที่กำลังเลือกอยู่ ไม่ว่าจะเป็นวันไหน
  void _openDetail() {
    if (widget.onStartTap != null) {
      widget.onStartTap!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutClipPickerScreen(
          workoutDays: widget.workoutDays,
          dayResults: widget.dayResults,
          initialDay: _selected,
        ),
      ),
    );
  }

  /// สัปดาห์ที่กำลังมองเห็นอยู่ตอนนี้ (ไม่ใช่วันที่เลือก) — ใช้บอกเดือนบนหัว
  DateTime _visibleWeekStart() {
    final page = _weekController.hasClients && _weekController.page != null
        ? _weekController.page!.round()
        : _basePage;
    return _weekStartForPage(page);
  }

  /// หัวเดือน/ปี กดเพื่อกระโดดไปเดือนอื่นได้ เพราะการปัดทีละสัปดาห์
  /// ใช้ย้อนไกลๆ ไม่ไหว
  Widget _monthHeader() {
    // ใช้วันพฤหัสของสัปดาห์เป็นตัวตัดสินเดือน สัปดาห์ที่คาบสองเดือนจะได้
    // เดือนที่มีวันมากกว่า
    final d = _visibleWeekStart().add(const Duration(days: 3));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickMonth,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '${_thMonths[d.month - 1]} ${d.year + 543}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _famFamily,
                fontFamilyFallback: _famFallback,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// แคปซูลจำนวนวันที่ออกกำลังกายต่อเนื่อง วางท้ายแถวชื่อเดือน
  Widget _streakPill() {
    final streak = _streak();
    final onStreak = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: onStreak
                  ? const [_flameTop, _flameBottom]
                  : const [Color(0xFFC4B3A3), Color(0xFFB7A595)],
            ).createShader(b),
            child: const Icon(
              CupertinoIcons.flame_fill,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$streak',
            style: TextStyle(
              fontFamily: _famFamily,
              fontFamilyFallback: _famFallback,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              // Nunito เป็นฟอนต์แบบแปรผัน ตั้ง fontWeight อย่างเดียวไม่ขยับแกน
              fontVariations: const [FontVariation('wght', 900)],
              height: 1.0,
              color: onStreak ? _ink : const Color(0xFFB7A595),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth() async {
    final visible = _visibleWeekStart().add(const Duration(days: 3));
    DateTime temp = DateTime(visible.year, visible.month);
    final now = DateTime.now();

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F8FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('ยกเลิก'),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _jumpToMonth(temp);
                      },
                      child: const Text('เลือก'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.monthYear,
                  initialDateTime: temp,
                  minimumDate: DateTime(now.year - 5),
                  maximumDate: DateTime(now.year + 1, 12),
                  onDateTimeChanged: (v) => temp = v,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// เลื่อนแถบสัปดาห์ไปยังเดือนที่เลือก และเลือกวันที่ 1 ของเดือนนั้นให้
  void _jumpToMonth(DateTime month) {
    final target = DateTime(month.year, month.month, 1);
    final monday = target.subtract(Duration(days: target.weekday - 1));
    final weeks = monday.difference(_mondayOfCurrentWeek()).inDays ~/ 7;
    setState(() => _selected = target);
    widget.onDaySelected?.call(target);
    if (_weekController.hasClients) {
      _weekController.animateToPage(
        _basePage + weeks,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _calendarPanel(DateTime today) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // โหมดปฏิทินล้วนวางบนพื้นหน้าจอโดยตรง จึงไม่ต้องมีพื้นสีของตัวเอง
        color: widget.calendarOnly
            ? null
            : const Color(0xFFFFF4EC), // white with a soft orange tint
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      padding: widget.calendarOnly
          ? const EdgeInsets.symmetric(vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // วงล้อคะแนนของวันที่เลือก แสดงทุกวัน — เฉพาะการ์ดหน้าหลักเท่านั้น
          // หน้ารายละเอียดให้ปฏิทินกินเต็มความกว้างเหมือนเดิม
          if (!widget.calendarOnly) ...[
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
                child: _danceStats(_resultFor(_selected)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Dance result for [day], or null when there's none.
  (int score, int accuracy)? _resultFor(DateTime d) {
    for (final e in widget.dayResults.entries) {
      if (_same(e.key, d)) return e.value;
    }
    return null;
  }

  /// วงล้อคะแนนของวันที่เลือก — แสดงทุกวัน วันที่ไม่ได้ออกกำลังกายจะเป็น
  /// วงแหวนเปล่าและคะแนน 0 เพื่อให้ตำแหน่งและความสูงของการ์ดคงที่
  Widget _danceStats((int score, int accuracy)? result) {
    const size = 66.0;
    final r = result ?? (0, 0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring sweeps to the accuracy on appearance.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: r.$2 / 100),
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
                tween: Tween(begin: 0, end: r.$1.toDouble()),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, v, __) => Text(
                  _formatInt(v.round()),
                  style: TextStyle(
                    fontFamily: _famFamily,
                    fontFamilyFallback: _famFallback,
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
                  fontFamily: _famFamily,
                  fontFamilyFallback: _famFallback,
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

  static String _formatInt(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Widget _weekRow(List<DateTime> week, DateTime today) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [for (final day in week) Expanded(child: _dayCell(day, today))],
    );
    // โหมดปฏิทินล้วนวาง PageView เต็มความกว้างจอ ระยะขอบจึงต้องอยู่ในหน้า
    // ไม่ใช่ครอบ PageView ไม่งั้นสัปดาห์ถัดไปจะโผล่มาแบบดูเหมือนโดนตัด
    if (!widget.calendarOnly) return row;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: row,
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
      onTap: () {
        setState(() => _selected = day);
        widget.onDaySelected?.call(day);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Weekday label
          Text(
            _thWeekLabels[day.weekday - 1],
            style: TextStyle(
              fontFamily: _famFamily,
              fontFamilyFallback: _famFallback,
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
                      fontFamily: _famFamily,
                      fontFamilyFallback: _famFallback,
                      fontSize: 13,
                      fontWeight: isFocus ? FontWeight.w800 : FontWeight.w600,
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
                fontFamily: _famFamily,
                fontFamilyFallback: _famFallback,
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
  const _DashedCircle({
    required this.size,
    this.color = const Color(0xFFE3B59C),
  });
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
    const orange = Color(0xFFFB6618);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          // Ring fills over the first ~70%, the check fades/scales in after.
          final ringP = Curves.easeOut.transform(
            (_c.value / 0.7).clamp(0.0, 1.0),
          );
          final checkP = ((_c.value - 0.62) / 0.38).clamp(0.0, 1.0);
          return Stack(
            alignment: Alignment.center,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
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
                            colors: [Color(0xFFF7A555), Color(0xFFFB6618)],
                          ).createShader(b),
                          child: Icon(
                            CupertinoIcons.flame_fill,
                            size: widget.size * 0.62,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.check_rounded,
                          size: widget.size * 0.62,
                          color: orange,
                        ),
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
      ..color = const Color(0xFFFB6618)
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
        colors: [Color(0xFFF7A555), Color(0xFFFB6618)],
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
