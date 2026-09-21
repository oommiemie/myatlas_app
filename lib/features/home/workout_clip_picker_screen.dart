import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/material.dart'
    show Icons, ScaffoldMessenger, SnackBar, SnackBarBehavior;

/// A single aerobic dance clip the user can pick to work out to.
class _WorkoutClip {
  const _WorkoutClip({
    required this.title,
    required this.level,
    required this.minutes,
    required this.kcal,
    required this.colors,
    required this.icon,
    required this.image,
    this.score = 100,
    this.accuracy = 90,
  });

  final String title;
  final String level;
  final int minutes;
  final int kcal;
  final List<Color> colors; // thumbnail gradient
  final IconData icon;

  /// ภาพประกอบคลิป — ใช้ภาพ 3D ที่มีในโปรเจ็กต์ไปก่อนจนกว่าจะมีภาพปกจริง
  final String image;

  /// คะแนนและความแม่นยำล่าสุดของคลิปนี้ — mock จนกว่าจะมีข้อมูลจริง
  final int score;
  final int accuracy;

  /// ข้อมูลสำหรับหน้ารายละเอียดคลิป — ใส่ค่าเริ่มต้นไว้ให้ทุกคลิปใช้ร่วมกัน
  /// จนกว่าจะมีข้อมูลจริงจากหลังบ้าน
  String get description =>
      'คลิปออกกำลังกายระดับ$level ใช้เวลา $minutes นาที เผาผลาญราว $kcal '
      'แคลอรี่ ทำตามได้ที่บ้านโดยไม่ต้องใช้อุปกรณ์ เหมาะกับผู้ที่เพิ่งเริ่มต้น '
      'และผู้ที่อยากขยับร่างกายสั้นๆ ในแต่ละวัน';
  List<String> get previews => const [
    'วอร์มอัพเบาๆ ปลุกร่างกายให้ตื่น',
    'ท่าหลัก เน้นจังหวะและการหายใจ',
    'คูลดาวน์ ยืดเหยียดผ่อนคลาย',
  ];
}

const _clips = <_WorkoutClip>[
  _WorkoutClip(
    title: 'แอโรบิกพื้นฐาน วอร์มอัพ',
    level: 'เริ่มต้น',
    minutes: 15,
    kcal: 120,
    colors: [Color(0xFFF7A555), Color(0xFFFB6618)],
    icon: Icons.self_improvement,
    score: 860,
    accuracy: 92,
    image: 'assets/exercise_cover.png',
  ),
  _WorkoutClip(
    title: 'เต้นจังหวะสนุก ขยับทั้งตัว',
    level: 'ปานกลาง',
    minutes: 20,
    kcal: 180,
    colors: [Color(0xFFFF6B6B), Color(0xFFEE4D9B)],
    icon: Icons.music_note,
    score: 4320,
    accuracy: 55,
    image: 'assets/exercise_cover.png',
  ),
  _WorkoutClip(
    title: 'คาร์ดิโอเข้มข้น เผาผลาญ',
    level: 'ขั้นสูง',
    minutes: 30,
    kcal: 280,
    colors: [Color(0xFF7A5CFF), Color(0xFF4D7BEE)],
    icon: Icons.local_fire_department,
    score: 12500,
    accuracy: 28,
    image: 'assets/exercise_cover.png',
  ),
  _WorkoutClip(
    title: 'แดนซ์ป็อป สุดมันส์',
    level: 'ปานกลาง',
    minutes: 25,
    kcal: 220,
    colors: [Color(0xFF22C1C3), Color(0xFF1D8B6B)],
    icon: Icons.flash_on,
    score: 975,
    accuracy: 74,
    image: 'assets/exercise_cover.png',
  ),
  _WorkoutClip(
    title: 'ยืดเส้นคูลดาวน์ ผ่อนคลาย',
    level: 'เริ่มต้น',
    minutes: 10,
    kcal: 60,
    colors: [Color(0xFF5AC8FA), Color(0xFF4AB99C)],
    icon: Icons.spa,
    score: 10000,
    accuracy: 40,
    image: 'assets/exercise_cover.png',
  ),
];

const _bgPrimary = Color(0xFFF6F4F1);

// สีจากดีไซน์ Figma (node 1449:5848)
const _heroTop = Color(0xFFF7A555);
const _heroBottom = Color(0xFFFB6618);
const _statValue = Color(0xFF0064BD);
const _clipTeal = Color(0xFFB0D7D6);
const _clipTealDeep = Color(0xFF07A19D);
const _hairline = Color(0xFFDCDCDC);

/// เกณฑ์สีของความแม่นยำ ต่ำกว่า 40 แดง 40-69 ส้ม ตั้งแต่ 70 เขียว
Color _accuracyTone(int accuracy) {
  if (accuracy < 40) return const Color(0xFFE32213);
  if (accuracy < 70) return const Color(0xFFEFA83A);
  return const Color(0xFF3E9B1E);
}

const _fontThai = 'IBM Plex Sans Thai Looped';

/// ใส่จุลภาคคั่นหลักพัน เช่น 10000 → 10,000
/// คะแนนสะสมขึ้นถึงหลักหมื่นได้ ตัวเลขยาวจึงต้องอ่านง่าย
String _thousands(num value) {
  final text = value is int ? '$value' : value.toStringAsFixed(1);
  final parts = text.split('.');
  final digits = parts.first.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return parts.length > 1 ? '$digits.${parts[1]}' : digits;
}

const _ink = Color(0xFF1A1A2E);

// Header gradient (workout flame) — mirrors the nutrition detail layout.
/// หน้าออกกำลังกาย — ตามดีไซน์ Figma node 1449:5848
/// หัวไล่สีส้มคลุมปฏิทินรายสัปดาห์ คลิปแนะนำ และแถบคะแนนของวันที่เลือก
/// จากนั้นเป็นแผ่นเนื้อหา: การ์ดสรุป และรายการคลิปให้เลือก
class WorkoutClipPickerScreen extends StatefulWidget {
  const WorkoutClipPickerScreen({
    super.key,
    this.workoutDays = const {},
    this.dayResults = const {},
    this.initialDay,
  });

  /// วันที่ให้เปิดค้างไว้ตอนเข้าหน้า — ส่งมาจากวันที่เลือกอยู่ในการ์ดหน้าหลัก
  final DateTime? initialDay;

  /// วันที่ออกกำลังกายแล้ว — ส่งต่อจากการ์ดในหน้าหลักเพื่อให้หัวหน้านี้ตรงกัน
  final Set<DateTime> workoutDays;
  final Map<DateTime, (int score, int accuracy)> dayResults;

  @override
  State<WorkoutClipPickerScreen> createState() =>
      _WorkoutClipPickerScreenState();
}

class _WorkoutClipPickerScreenState extends State<WorkoutClipPickerScreen> {
  static const _thWeekLabels = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];

  /// ตัวย่อเดือนตามราชบัณฑิต ใช้กับป้ายวันที่และตารางปี
  static const _thMonthsShort = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  late DateTime _selected;

  /// ช่วงเวลาของการ์ดสรุป 0=วัน 1=สัปดาห์ 2=เดือน 3=ปี
  int _period = 1;

  /// วันที่เจาะดูในแท็บเดือน กดวันเดิมซ้ำเพื่อกลับไปดูทั้งเดือน
  DateTime? _dayFocus;

  /// คลิปแนะนำที่กำลังแสดง เลื่อนซ้ายขวาเพื่อเลือกคลิปอื่นได้
  int _recommendIndex = 0;

  /// ตัวคุมแถบคลิปแนะนำ สร้างใหม่เมื่อความกว้างเปลี่ยน
  /// เพราะสัดส่วน viewport ต้องพอดีการ์ดหนึ่งใบ
  PageController? _recommendCtrl;
  double _recommendFraction = 0;

  /// หน้ากลางของปฏิทินแบบเลื่อนได้ ใช้เลขใหญ่เพื่อให้เลื่อนย้อนได้มาก
  static const _basePage = 5000;

  /// วันอ้างอิงของหน้ากลาง หน้าอื่นคำนวณจากระยะห่างจากหน้านี้
  late DateTime _pageBase;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = widget.initialDay ?? DateTime(now.year, now.month, now.day);
    _pageBase = _selected;
    _pageCtrl = PageController(initialPage: _basePage);
  }

  @override
  void dispose() {
    _recommendCtrl?.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _didWorkout(DateTime d) => widget.workoutDays.any((w) => _same(w, d));

  /// สัปดาห์ของวันที่เลือก เริ่มวันจันทร์
  List<DateTime> get _week {
    final start = _selected.subtract(Duration(days: _selected.weekday - 1));
    return List.generate(
      7,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
  }

  /// จำนวนวันต่อเนื่องล่าสุด นับถอยจากวันนี้
  int get _currentStreak {
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!_didWorkout(day)) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (_didWorkout(day)) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// สถิติต่อเนื่องสูงสุดที่เคยทำได้
  int get _bestStreak {
    final days =
        widget.workoutDays.map((d) => DateTime(d.year, d.month, d.day)).toList()
          ..sort();
    var best = 0, run = 0;
    DateTime? prev;
    for (final d in days) {
      run = (prev != null && d.difference(prev).inDays == 1) ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  /// วันอยู่ในช่วงของ tab ที่เลือกหรือไม่
  bool _inPeriod(DateTime d) {
    switch (_period) {
      case 0:
        return _same(d, _selected);
      case 1:
        final week = _week;
        return !d.isBefore(week.first) &&
            !d.isAfter(week.last.add(const Duration(days: 1)));
      case 2:
        final focus = _dayFocus;
        if (focus != null) return _same(d, focus);
        return d.year == _selected.year && d.month == _selected.month;
      default:
        return d.year == _selected.year;
    }
  }

  /// เวลารวมในช่วงที่เลือก ประเมินจากจำนวนวัน (mock จนกว่าจะมีข้อมูลจริง)
  int get _totalMinutes => widget.workoutDays.where(_inPeriod).length * 20;

  /// คะแนนรวมในช่วงที่เลือก หน่วยพันคะแนน (mock จนกว่าจะมีข้อมูลจริง)
  double get _totalScore =>
      widget.dayResults.entries
          .where((e) => _inPeriod(e.key))
          .fold<int>(0, (a, e) => a + e.value.$1) /
      100;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgPrimary,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          children: [
            _hero(context),
            // แผ่นเนื้อหาซ้อนขึ้นทับหัวเล็กน้อยตามดีไซน์
            Transform.translate(
              offset: const Offset(0, -24),
              child: _infoContainer(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── หัวหน้าจอ ──────────────────────────────────────────────────────────────
  Widget _hero(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_heroTop, _heroBottom],
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: top + 8),
              // แถบบน: ปุ่มย้อนกลับ + ชื่อหน้า
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'ออกกำลังกาย',
                        style: TextStyle(
                          fontFamily: _fontThai,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _GlassCircle(
                          icon: CupertinoIcons.chevron_back,
                          onTap: () => Navigator.of(context).maybePop(),
                          onLight: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SegmentedTabs(
                  tabs: const ['วัน', 'สัปดาห์', 'เดือน', 'ปี'],
                  selected: _period,
                  onChange: (i) => setState(() {
                    _period = i;
                    _dayFocus = null;
                    _pageBase = _selected;
                    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(_basePage);
                  }),
                  onColor: true,
                ),
              ),
              const SizedBox(height: 16),
              _periodTitle(),
              const SizedBox(height: 12),
              _calendar(),
              // เว้น 16 ที่มองเห็น + 24 ที่แผ่นเนื้อหาซ้อนทับ
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  /// ช่วงวันที่ที่กำลังดูอยู่ ใช้ปี พ.ศ. สองหลัก
  String get _periodRangeLabel {
    final y = (_selected.year + 543) % 100;
    switch (_period) {
      case 2:
        final focus = _dayFocus;
        if (focus != null) {
          return '${focus.day} ${_thMonthsShort[focus.month - 1]} $y';
        }
        return '${_thMonthsShort[_selected.month - 1]} $y';
      case 3:
        return '${_selected.year + 543}';
      case 1:
        final w = _week;
        final head = w.first.month == w.last.month
            ? '${w.first.day}'
            : '${w.first.day} ${_thMonthsShort[w.first.month - 1]}';
        return '$head - ${w.last.day} ${_thMonthsShort[w.last.month - 1]} $y';
      default:
        return '${_selected.day} ${_thMonthsShort[_selected.month - 1]} $y';
    }
  }

  /// ป้ายช่วงเวลาที่กำลังดู วางต่อจากแท็บ
  Widget _periodTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ข้อมูลของวันที่',
            style: TextStyle(
              fontFamily: _fontThai,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
              leadingDistribution: TextLeadingDistribution.even,
              color: Color(0xCCFFFFFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _periodRangeLabel,
            style: const TextStyle(
              fontFamily: _fontThai,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
              leadingDistribution: TextLeadingDistribution.even,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// วันอ้างอิงของหน้าที่ index กำหนด นับจากหน้ากลาง
  DateTime _refForPage(int index) {
    final delta = index - _basePage;
    switch (_period) {
      case 2:
        return DateTime(_pageBase.year, _pageBase.month + delta, 1);
      case 3:
        return DateTime(_pageBase.year + delta, _pageBase.month, 1);
      default:
        return _pageBase.add(Duration(days: 7 * delta));
    }
  }

  /// ความสูงของปฏิทินแต่ละแบบ ต้องคงที่เพราะอยู่ใน PageView
  double get _calendarHeight {
    switch (_period) {
      case 2:
        // เดือนมี 5 หรือ 6 แถวไม่เท่ากัน คิดความสูงจากเดือนที่แสดงจริง
        // ไม่งั้นเดือน 5 แถวจะเหลือช่องว่างใต้ปฏิทิน
        final lead = DateTime(_selected.year, _selected.month).weekday - 1;
        final days = DateTime(_selected.year, _selected.month + 1, 0).day;
        final rows = ((lead + days) / 7).ceil();
        return 16 + rows * 58;
      case 3:
        return 186;
      default:
        return 80;
    }
  }

  /// ปฏิทินเลื่อนตามนิ้วแบบ PageView เปลี่ยนช่วงเวลาได้ทุกแท็บ
  Widget _calendar() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        height: _calendarHeight,
        child: PageView.builder(
          controller: _pageCtrl,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (i) {
            HapticFeedback.selectionClick();
            setState(() {
              _dayFocus = null;
              final ref = _refForPage(i);
              // แท็บวัน/สัปดาห์ คงวันในสัปดาห์เดิมไว้ ช่วงอื่นเริ่มที่วันที่ 1
              _selected = _period >= 2
                  ? ref
                  : ref.add(Duration(days: _selected.weekday - 1));
            });
          },
          itemBuilder: (context, i) => _calendarBody(_refForPage(i)),
        ),
      ),
    );
  }

  Widget _calendarBody(DateTime ref) {
    switch (_period) {
      case 2:
        return _monthGrid(ref);
      case 3:
        return _yearGrid(ref);
      default:
        return _weekStrip(ref);
    }
  }

  /// ตารางรายวันของเดือนอ้างอิง
  Widget _monthGrid(DateTime ref) {
    final month = DateTime(ref.year, ref.month);
    final lead = month.weekday - 1; // ให้จันทร์เป็นคอลัมน์แรก
    final days = DateTime(ref.year, ref.month + 1, 0).day;
    final cells = <Widget?>[
      ...List<Widget?>.filled(lead, null),
      for (var d = 1; d <= days; d++)
        _monthCell(DateTime(ref.year, ref.month, d)),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              for (final l in _thWeekLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      l,
                      style: TextStyle(
                        fontFamily: _fontThai,
                        fontSize: 11,
                        height: 1.3,
                        color: CupertinoColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (var r = 0; r < cells.length ~/ 7; r++)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: Center(
                        child: cells[r * 7 + c] ?? const SizedBox(height: 54),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// ช่องวันในตารางเดือน ใช้ภาษาเดียวกับแถบสัปดาห์
  Widget _monthCell(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final focus = _dayFocus;
    final isFocus = focus != null && _same(day, focus);
    final isToday = _same(day, today);
    final done = _didWorkout(day);

    final Widget indicator;
    if (done) {
      indicator = _dayBadge(
        isFocus: isFocus,
        size: 20,
        bg: const Color(0xFFFFDCC4),
        child: const Icon(
          CupertinoIcons.flame_fill,
          size: 14,
          color: _heroBottom,
        ),
      );
    } else if (isToday) {
      indicator = _dayBadge(
        isFocus: isFocus,
        size: 20,
        bg: const Color(0xFFFFDCC4),
        child: const Icon(
          Icons.sports_gymnastics,
          size: 15,
          color: _heroBottom,
        ),
      );
    } else if (day.isBefore(today)) {
      indicator = _dayBadge(
        isFocus: isFocus,
        size: 20,
        bg: const Color(0xFFF1E4D8),
        child: const Icon(
          Icons.self_improvement,
          size: 14,
          color: Color(0xFFB58A6B),
        ),
      );
    } else {
      indicator = SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: _DottedRing(
            color: isFocus ? CupertinoColors.white : const Color(0xFFE3B59C),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        // กดวันเดิมซ้ำ = เลิกเจาะ กลับไปดูข้อมูลทั้งเดือน
        _dayFocus = isFocus ? null : day;
        _selected = day;
      }),
      child: SizedBox(
        width: 34,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isFocus
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_heroTop, _heroBottom],
                  )
                : null,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 13,
                  fontWeight: isFocus ? FontWeight.w800 : FontWeight.w600,
                  color: CupertinoColors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 6),
              indicator,
            ],
          ),
        ),
      ),
    );
  }

  Widget _yearGrid(DateTime ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var r = 0; r < 3; r++)
            Padding(
              padding: EdgeInsets.only(top: r == 0 ? 0 : 8),
              child: Row(
                children: [
                  for (var c = 0; c < 4; c++) ...[
                    if (c > 0) const SizedBox(width: 8),
                    Expanded(child: _yearCell(ref.year, r * 4 + c + 1)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// ช่องเดือนในตารางปี ใช้แคปซูลไล่สีส้มเหมือนช่องวัน
  Widget _yearCell(int year, int month) {
    final count = widget.workoutDays
        .where((d) => d.year == year && d.month == month)
        .length;
    final isFocus = _selected.year == year && _selected.month == month;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected = DateTime(year, month, 1)),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isFocus
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_heroTop, _heroBottom],
                )
              : null,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _thMonthsShort[month - 1],
              style: TextStyle(
                fontFamily: _fontThai,
                fontSize: 13,
                fontWeight: isFocus ? FontWeight.w800 : FontWeight.w600,
                height: 1.3,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count วัน',
              style: TextStyle(
                fontFamily: _fontThai,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: CupertinoColors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekStrip(DateTime ref) {
    final start = ref.subtract(Duration(days: ref.weekday - 1));
    final week = List.generate(
      7,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++) _dayCell(week[i], _thWeekLabels[i]),
        ],
      ),
    );
  }

  /// ช่องวันในแถบสัปดาห์ ใช้รูปแบบเดียวกับการ์ดหน้าหลัก
  Widget _dayCell(DateTime day, String label) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isFocus = _same(day, _selected);
    final isToday = _same(day, today);
    final done = _didWorkout(day);

    final Widget indicator;
    if (done) {
      indicator = _dayBadge(
        isFocus: isFocus,
        bg: const Color(0xFFFFDCC4),
        child: const Icon(
          CupertinoIcons.flame_fill,
          size: 14,
          color: _heroBottom,
        ),
      );
    } else if (isToday) {
      indicator = _dayBadge(
        isFocus: isFocus,
        bg: const Color(0xFFFFDCC4),
        child: const Icon(
          Icons.sports_gymnastics,
          size: 15,
          color: _heroBottom,
        ),
      );
    } else if (day.isBefore(today)) {
      indicator = _dayBadge(
        isFocus: isFocus,
        bg: const Color(0xFFF1E4D8),
        child: const Icon(
          Icons.self_improvement,
          size: 14,
          color: Color(0xFFB58A6B),
        ),
      );
    } else {
      indicator = SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: _DottedRing(
            color: isFocus ? CupertinoColors.white : const Color(0xFFE3B59C),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected = day),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: _fontThai,
              fontSize: 11,
              height: 1.3,
              color: CupertinoColors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 34,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isFocus
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_heroTop, _heroBottom],
                      )
                    : null,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontFamily: _fontThai,
                      fontSize: 13,
                      fontWeight: isFocus ? FontWeight.w800 : FontWeight.w600,
                      color: CupertinoColors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
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

  /// วงกลมสถานะใต้ตัวเลขวัน พื้นขาวเมื่อวันนั้นถูกเลือก
  Widget _dayBadge({
    required bool isFocus,
    required Color bg,
    required Widget child,
    double size = 20,
  }) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFocus ? CupertinoColors.white : bg,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }

  /// การ์ดสถิติรวม
  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _statRows(),
    );
  }

  /// การ์ดคลิปแนะนำวันนี้ แยกใบจากการ์ดสถิติ
  Widget _recommendCard() {
    return Container(
      width: double.infinity,
      color: CupertinoColors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _recommendRow(_clips[_recommendIndex]),
    );
  }

  /// คลิปแนะนำวันนี้ (Figma 1484:7078)
  /// ซ้าย: ภาพย่อ ป้าย ชื่อคลิป คะแนน — ขวา: การ์ดคลิปพร้อมปุ่มเริ่ม
  Widget _recommendRow(_WorkoutClip clip) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        // การ์ดคลิปเตี้ยกว่าคอลัมน์ซ้าย จัดให้อยู่กึ่งกลางการ์ดขาว
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'แนะนำวันนี้ · ${clip.minutes} นาที',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: Color(0xCC252525),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clip.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // เกจครึ่งวงกลมสองชั้น (Figma 1486:7266) 170x91
                    SizedBox(
                      width: 170,
                      height: 91,
                      child: CustomPaint(
                        painter: _ScoreGauge(
                          scoreRatio: (clip.score / 10000).clamp(0.0, 1.0),
                          accuracyRatio: (clip.accuracy / 100).clamp(0.0, 1.0),
                          accuracyColor: _accuracyTone(clip.accuracy),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // กว้างเท่าปลายหลอดวงนอก (กล่องเกจ 170 ลบครึ่งเส้น 11)
                    // ท้ายคำว่า "ความแม่นยำ" จึงตรงกับปลายหลอดพอดี
                    SizedBox(
                      width: 168,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _recommendStat('คะแนน', _thousands(clip.score), null),
                          _recommendStat(
                            'ความแม่นยำ',
                            '${clip.accuracy}',
                            '%',
                            color: _accuracyTone(clip.accuracy),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // แถบการ์ดคลิปเลื่อนแนวนอน ทะลุออกนอกขอบขวาตามแบบ
          Expanded(
            child: SizedBox(
              height: 182,
              // เลื่อนแบบหน้าต่อหน้า สแนปทีละใบ เหมือนแบนเนอร์หน้าแรก
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const itemExtent = 151.0 + 8.0;
                  final fraction = (itemExtent / constraints.maxWidth).clamp(
                    0.1,
                    1.0,
                  );
                  if (_recommendCtrl == null ||
                      (fraction - _recommendFraction).abs() > 0.001) {
                    _recommendCtrl?.dispose();
                    _recommendFraction = fraction;
                    _recommendCtrl = PageController(
                      viewportFraction: fraction,
                      initialPage: _recommendIndex,
                    );
                  }
                  return PageView.builder(
                    controller: _recommendCtrl,
                    padEnds: false,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _clips.length,
                    onPageChanged: (i) => setState(() => _recommendIndex = i),
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _recommendClipCard(_clips[i], i),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// การ์ดคลิปในแถบแนะนำ แตะเพื่อดูรายละเอียด
  Widget _recommendClipCard(_WorkoutClip clip, int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _recommendIndex = index);
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => _ClipReadyScreen(clip: clip)),
        );
      },
      child: SizedBox(
        width: 151,
        height: 182,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: _clipTeal),
              Image.asset(clip.image, fit: BoxFit.cover),
              const Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.62,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00FFFFFF), _clipTealDeep],
                        stops: [0.0, 0.9],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _heroBottom,
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  // สามเหลี่ยมเล่นเอียงซ้าย ขยับขวาให้ดูอยู่กลาง
                  child: Transform.translate(
                    offset: const Offset(1.5, 0),
                    child: const Icon(
                      CupertinoIcons.play_fill,
                      size: 16,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _hairline),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// คะแนนหนึ่งช่องในการ์ดแนะนำ (Figma 1484:7159)
  Widget _recommendStat(
    String label,
    String value,
    String? unit, {
    Color color = _statValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: _fontThai,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
            leadingDistribution: TextLeadingDistribution.even,
            color: CupertinoColors.black.withValues(alpha: 0.8),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontVariations: const [FontVariation('wght', 800)],
                height: 1.2,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.black.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── แผ่นเนื้อหา ────────────────────────────────────────────────────────────
  Widget _infoContainer(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // การ์ดสรุปกินเต็มความกว้าง ไม่เว้นขอบซ้ายขวา
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottom + 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryCard(),
          const SizedBox(height: 16),
          _recommendCard(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _highlightSection(),
          ),
        ],
      ),
    );
  }

  /// แถวสถิติใต้ปฏิทิน
  Widget _statRows() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statItem(
                  Icons.timer_outlined,
                  'เวลาที่ออกรวม',
                  _thousands(_totalMinutes),
                  'นาที',
                  const [_statValue, Color(0xFF2FA1FF)],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statItem(
                  CupertinoIcons.chart_bar_alt_fill,
                  'คะแนนรวม',
                  _thousands(_totalScore),
                  'คะแนน',
                  const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  Icons.local_fire_department,
                  'ต่อเนื่องล่าสุด',
                  '$_currentStreak',
                  'วัน',
                  // ไล่เหลือง→ส้ม→แดง ให้ดูเป็นเปลวไฟจริง
                  const [
                    Color(0xFFFFC107),
                    Color(0xFFFF7A00),
                    Color(0xFFFF3B30),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statItem(
                  Icons.workspace_premium,
                  'ต่อเนื่องสูงสุด',
                  '$_bestStreak',
                  'วัน',
                  // เหรียญรางวัล ไล่ทองอ่อน→ทองเข้ม
                  const [Color(0xFFFFD166), Color(0xFFD9962A)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    IconData icon,
    String label,
    String value,
    String unit,
    List<Color> iconColors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ไอคอนไล่สีในตัวเอง ตัวเลขคงสีน้ำเงินชุดเดียวกันไม่ให้แย่งกัน
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: iconColors,
          ).createShader(b),
          child: Icon(icon, size: 28, color: CupertinoColors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.black.withValues(alpha: 0.8),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontVariations: [FontVariation('wght', 800)],
                      height: 1.1,
                      color: Color(0xFF1B1B1B),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      unit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: _fontThai,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _highlightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'อยากเต้นคลิปไหนเลือกได้เลย',
          style: TextStyle(
            fontFamily: _fontThai,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'AI จะวัดคะแนนความแม่นยำจากการเต้น',
          style: TextStyle(
            fontFamily: _fontThai,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF525252).withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        // เรียงสองคอลัมน์ตามดีไซน์
        for (var i = 0; i < _clips.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ClipCard(clip: _clips[i])),
              const SizedBox(width: 16),
              Expanded(
                child: i + 1 < _clips.length
                    ? _ClipCard(clip: _clips[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// วงกลมเส้นประ ใช้เป็นเครื่องหมายวันที่ยังไม่ได้ออกกำลังกาย
class _DottedRing extends CustomPainter {
  const _DottedRing({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = color;
    const dashes = 12;
    const sweep = 3.14159 * 2 / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DottedRing old) => old.color != color;
}

/// Frosted-glass circular button used in the gradient header.
class _GlassCircle extends StatelessWidget {
  const _GlassCircle({
    required this.icon,
    required this.onTap,
    this.onLight = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: onLight
                    ? CupertinoColors.white
                    : CupertinoColors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: onLight
                      ? const Color(0xFF747480).withValues(alpha: 0.12)
                      : CupertinoColors.white.withValues(alpha: 0.35),
                  width: 0.5,
                ),
                gradient: onLight
                    ? null
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          CupertinoColors.white.withValues(alpha: 0.30),
                          CupertinoColors.white.withValues(alpha: 0.05),
                        ],
                      ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: onLight ? _ink : CupertinoColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// การ์ดคลิป ตามดีไซน์ Figma — ภาพเต็มใบ ไล่สีเข้มด้านล่าง
/// แผงข้อมูลฝ้าโปร่งแสงคลุมครึ่งล่าง และปุ่มเริ่มวงกลมมุมบนซ้าย
class _ClipCard extends StatelessWidget {
  const _ClipCard({required this.clip});
  final _WorkoutClip clip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(
        context,
      ).push(CupertinoPageRoute(builder: (_) => _ClipReadyScreen(clip: clip))),
      child: SizedBox(
        height: 227,
        // ตัดมุมที่ตัวเนื้อหาโดยตรง แล้ววาดเส้นขอบทับทีหลัง ถ้าใส่ border
        // กับ clip ใน Container เดียวกัน เนื้อหาจะถูกตัดที่ขอบนอกของเส้น
        // ทำให้สีพื้นโผล่เป็นเสี้ยวที่มุม
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          // ตัดทุกอย่างที่ล้นออกนอกการ์ด เช่น วงล้อที่ยื่นพ้นขอบซ้าย
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              const ColoredBox(color: _clipTeal),
              // ภาพปกคลิป ครอปเต็มใบ
              Positioned.fill(
                child: IgnorePointer(
                  child: Image.asset(clip.image, fit: BoxFit.cover),
                ),
              ),
              // ไล่สีดำจางขึ้นจากขอบล่าง ให้ตัวหนังสืออ่านออก
              const Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.5,
                  widthFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xB3000000)],
                        stops: [0.0, 0.9],
                      ),
                    ),
                  ),
                ),
              ),
              // ชื่อคลิป + ปุ่มเริ่ม แล้วต่อด้วยแผงคะแนนพื้นอ่อน
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  clip.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: _fontThai,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                    leadingDistribution:
                                        TextLeadingDistribution.even,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                                Text(
                                  'คลิปเต้น',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: _fontThai,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                    leadingDistribution:
                                        TextLeadingDistribution.even,
                                    color: CupertinoColors.white.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ปุ่มเริ่มเล่นคลิป
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _heroBottom,
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.black.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            // สามเหลี่ยมเล่นเอียงซ้าย ขยับขวาให้ดูอยู่กลาง
                            child: Transform.translate(
                              offset: const Offset(1.5, 0),
                              child: const Icon(
                                CupertinoIcons.play_fill,
                                size: 16,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // แผงคะแนน (Figma 1483:6936) พื้นไล่ขาว → ฟ้าอ่อน
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      // ตัดส่วนของวงล้อที่ล้นออกนอกแผง
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [CupertinoColors.white, Color(0xFFD9EDFE)],
                          stops: [0.065, 0.935],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          // เกจตะแคง เปิดปากไปทางขวา (Figma 1493:6239)
                          Transform.translate(
                            offset: const Offset(-8, 0),
                            // จองพื้นที่ 41 แต่วาดวงล้อใหญ่ 64
                            // ส่วนที่ล้นถูกแผงคะแนนตัดออก
                            child: SizedBox(
                              width: 32,
                              height: 41,
                              child: OverflowBox(
                                maxHeight: 64,
                                child: SizedBox(
                                  width: 32,
                                  height: 64,
                                  child: CustomPaint(
                                    painter: _ScoreGauge(
                                      scoreRatio: (clip.score / 10000).clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      accuracyRatio: (clip.accuracy / 100)
                                          .clamp(0.0, 1.0),
                                      accuracyColor: _accuracyTone(
                                        clip.accuracy,
                                      ),
                                      stroke: 11,
                                      // วงในขนาดเท่าเดิม แต่เลื่อนซ้าย
                                      // ให้ห่างจากวงนอก 8
                                      gap: 3,
                                      innerShift: 5,
                                      vertical: true,
                                      trackColor: CupertinoColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ดันตัวเลขไปชิดขวา แต่กันที่ให้พอสำหรับคะแนน
                          // หลักหมื่นและความแม่นยำ 100%
                          const Spacer(),
                          _clipStat(
                            'คะแนน',
                            _thousands(clip.score),
                            null,
                            _statValue,
                            minWidth: 56,
                          ),
                          const SizedBox(width: 10),
                          _clipStat(
                            'แม่นยำ',
                            '${clip.accuracy}',
                            '%',
                            _accuracyTone(clip.accuracy),
                            minWidth: 46,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // เส้นขอบวาดทับชั้นบนสุด จึงคมและไม่เบียดเนื้อหา
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _hairline),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ตัวเลขหนึ่งช่องในแผงคะแนนของการ์ดคลิป
  Widget _clipStat(
    String label,
    String value,
    String? unit,
    Color color, {
    double minWidth = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: _fontThai,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.3,
            leadingDistribution: TextLeadingDistribution.even,
            color: CupertinoColors.black.withValues(alpha: 0.8),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontVariations: const [FontVariation('wght', 800)],
                    height: 1.3,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ClipReadyScreen extends StatefulWidget {
  const _ClipReadyScreen({required this.clip});
  final _WorkoutClip clip;

  @override
  State<_ClipReadyScreen> createState() => _ClipReadyScreenState();
}

class _ClipReadyScreenState extends State<_ClipReadyScreen> {
  @override
  Widget build(BuildContext context) {
    final clip = widget.clip;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return CupertinoPageScaffold(
      backgroundColor: _bgPrimary,
      child: Stack(
        children: [
          // เลื่อนทั้งหน้าเป็นผืนเดียว ปกเลื่อนขึ้นไปพร้อมเนื้อหา
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              children: [
                // ── ปกคลิป ──────────────────────────────────────────────
                SizedBox(
                  height: 320,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: _clipTeal),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Image.asset(clip.image, fit: BoxFit.cover),
                        ),
                      ),
                      // ไล่สีเขียวเข้มขึ้นจากล่าง ชุดเดียวกับการ์ดคลิป
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x00FFFFFF), _clipTealDeep],
                                stops: [0.0, 0.9],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── แผ่นเนื้อหาซ้อนขึ้นมาทับปก ───────────────────────────
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _bgPrimary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    // การ์ดกินเต็มความกว้าง ระยะขอบอยู่ในแต่ละส่วนแทน
                    padding: EdgeInsets.fromLTRB(0, 0, 0, bottom + 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // การ์ดหัวเรื่อง โค้งเฉพาะมุมบนให้รับกับแผ่น
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _titleBlock(clip),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Flexible(
                                    child: _detailStat(
                                      'คะแนนที่ได้',
                                      _thousands(clip.score),
                                      null,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: _detailStat(
                                      'ความแม่นยำ',
                                      '${clip.accuracy}',
                                      '%',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _chips(clip),
                              const SizedBox(height: 16),
                              Text(
                                clip.description,
                                style: TextStyle(
                                  fontFamily: _fontThai,
                                  fontSize: 13,
                                  height: 1.6,
                                  color: CupertinoColors.black.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ตัวอย่างคลิป',
                            style: TextStyle(
                              fontFamily: _fontThai,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: clip.previews.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) =>
                                _previewCard(clip.previews[i], clip.image),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ปุ่มย้อนกลับลอยอยู่กับที่ ไม่เลื่อนตามเนื้อหา
          Positioned(
            top: top + 8,
            left: 16,
            child: _GlassCircle(
              icon: CupertinoIcons.chevron_back,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }

  /// หัวการ์ด — ป้ายเวลา/ระดับ ชื่อคลิป และปุ่มเริ่มทางขวา
  Widget _titleBlock(_WorkoutClip clip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${clip.minutes} นาที · ${clip.level}',
                style: const TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  leadingDistribution: TextLeadingDistribution.even,
                  color: Color(0xCC252525),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                clip.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  leadingDistribution: TextLeadingDistribution.even,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // ปุ่มเริ่มออกกำลังกาย สีส้มชุดเดียวกับหน้าออกกำลังกาย
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _start(context),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _heroBottom,
              boxShadow: [
                BoxShadow(
                  color: _heroBottom.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            // สามเหลี่ยมเล่นเอียงซ้าย ขยับขวาให้ดูอยู่กลางจริง
            child: Transform.translate(
              offset: const Offset(1.5, 0),
              child: const Icon(
                CupertinoIcons.play_fill,
                size: 18,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// สถิติหนึ่งช่อง รูปแบบเดียวกับการ์ดแนะนำในหน้าออกกำลังกาย
  Widget _detailStat(String label, String value, String? unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: _fontThai,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
            leadingDistribution: TextLeadingDistribution.even,
            color: CupertinoColors.black.withValues(alpha: 0.8),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontVariations: const [FontVariation('wght', 800)],
                  height: 1.2,
                  color: _statValue,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.black.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _chips(_WorkoutClip clip) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [_chip(clip.level), _chip('${clip.kcal} แคลอรี่')],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _bgPrimary,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _hairline),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: _fontThai,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.black.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  /// การ์ดตัวอย่างคลิป ใช้ภาษาภาพเดียวกับการ์ดคลิปในหน้าออกกำลังกาย
  Widget _previewCard(String caption, String image) {
    return SizedBox(
      width: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: _clipTeal),
            Image.asset(image, fit: BoxFit.cover),
            const Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.62,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00FFFFFF), _clipTealDeep],
                      stops: [0.0, 0.9],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _heroBottom,
                ),
                child: Transform.translate(
                  offset: const Offset(1, 0),
                  child: const Icon(
                    CupertinoIcons.play_fill,
                    size: 13,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: CupertinoColors.white,
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _hairline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _start(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กำลังเริ่มคลิป… (ตัวอย่างการเชื่อมต่อ)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// แถบเลือกช่วงเวลา รูปแบบเดียวกับหน้ารายละเอียดสุขภาพอื่น ๆ
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.tabs,
    required this.selected,
    required this.onChange,
    this.onColor = false,
  });

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChange;

  /// วางบนพื้นสีเข้ม จึงใช้รางขาวโปร่งแทนรางเทา
  final bool onColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 4.0;
        final segmentWidth = (constraints.maxWidth - padding * 2) / tabs.length;
        return Container(
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: onColor
                ? CupertinoColors.white.withValues(alpha: 0.22)
                : const Color(0xFFD4D4D4).withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(100),
          ),
          child: SizedBox(
            height: 36,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutQuint,
                  left: selected * segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (int i = 0; i < tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChange(i),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                fontFamily: _fontThai,
                                fontSize: 15,
                                height: 1.5,
                                leadingDistribution:
                                    TextLeadingDistribution.even,
                                fontWeight: i == selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: i == selected
                                    ? _heroBottom
                                    : (onColor
                                          ? CupertinoColors.white
                                          : const Color(0xFF1A1A1A)),
                              ),
                              child: Text(tabs[i]),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// เกจครึ่งวงกลมสองชั้น (Figma 1486:7266)
/// ชั้นนอกคือคะแนน ชั้นในคือความแม่นยำ
class _ScoreGauge extends CustomPainter {
  const _ScoreGauge({
    required this.scoreRatio,
    required this.accuracyRatio,
    required this.accuracyColor,
    this.stroke = 22,
    this.gap = 7.5,
    this.vertical = false,
    this.trackColor = const Color(0xFFE6E6E6),
    this.innerShift = 0,
  });

  final double scoreRatio;
  final double accuracyRatio;

  /// สีของวงใน คิดจากเกณฑ์ความแม่นยำ
  final Color accuracyColor;

  /// ความหนาเส้นและช่องไฟระหว่างวงนอกกับวงใน
  final double stroke;
  final double gap;

  /// true = ครึ่งวงกลมตะแคง ปลายหลอดชี้ไปทางซ้าย (Figma 1493:6239)
  final bool vertical;

  /// สีรางของหลอด
  final Color trackColor;

  /// เลื่อนจุดศูนย์กลางของวงในไปทางซ้าย เพิ่มระยะห่างโดยวงไม่เล็กลง
  final double innerShift;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = vertical
        ? size.height / 2 - stroke / 2
        : size.width / 2 - stroke / 2;
    final center = vertical
        ? Offset(stroke / 2, size.height / 2)
        : Offset(size.width / 2, size.height - stroke / 2);
    _arc(canvas, center, outer, 1, trackColor);
    _arc(canvas, center, outer, scoreRatio, _statValue);

    final inner = outer - stroke - gap;
    final innerCenter = Offset(center.dx - innerShift, center.dy);
    _arc(canvas, innerCenter, inner, 1, trackColor);
    // วงในเริ่มจากปลายอีกด้าน ให้ดูเหมือนวิ่งสวนทางกับวงนอก
    _arc(
      canvas,
      innerCenter,
      inner,
      accuracyRatio,
      accuracyColor,
      fromRight: true,
    );
  }

  void _arc(
    Canvas canvas,
    Offset center,
    double radius,
    double ratio,
    Color color, {
    bool fromRight = false,
  }) {
    if (ratio <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    // แนวตั้งกวาดผ่านด้านขวา ปลายหลอดชี้ไปทางซ้ายทั้งคู่
    final start = vertical
        ? (fromRight ? math.pi / 2 : -math.pi / 2)
        : (fromRight ? 0.0 : math.pi);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      (fromRight ? -1 : 1) * math.pi * ratio,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreGauge old) =>
      old.scoreRatio != scoreRatio ||
      old.accuracyRatio != accuracyRatio ||
      old.accuracyColor != accuracyColor ||
      old.stroke != stroke ||
      old.gap != gap ||
      old.vertical != vertical ||
      old.trackColor != trackColor ||
      old.innerShift != innerShift;
}
