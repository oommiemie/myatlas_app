import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/widgets/app_toast.dart';
import '../../appointment/data/mock_data.dart';
import '../../medicine/theme/time_period.dart';
import '../../medicine/widgets/decorative_elements.dart';

// Sparkle icon from Figma (node 923:5161).
const String _kSparkleSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
    'viewBox="0 0 24 24" fill="none"><path d="M12.8458 3.581C12.7108 3.231 '
    '12.3748 3 11.9998 3C11.8167 3.00049 11.638 3.05621 11.4871 3.15986C11.3362 '
    '3.26351 11.22 3.41029 11.1538 3.581L9.5038 7.872C9.36105 8.24321 9.14193 '
    '8.58029 8.86062 8.86142C8.57931 9.14256 8.24209 9.36148 7.8708 9.504L3.5808 '
    '11.154C3.40963 11.2196 3.26238 11.3356 3.1585 11.4866C3.05463 11.6377 '
    '2.99902 11.8167 2.99902 12C2.99902 12.1833 3.05463 12.3623 3.1585 '
    '12.5134C3.26238 12.6644 3.40963 12.7804 3.5808 12.846L7.8718 14.496C8.24301 '
    '14.6388 8.58009 14.8579 8.86123 15.1392C9.14236 15.4205 9.36128 15.7577 '
    '9.5038 16.129L11.1538 20.419C11.2194 20.5902 11.3354 20.7374 11.4864 '
    '20.8413C11.6375 20.9452 11.8165 21.0008 11.9998 21.0008C12.1831 21.0008 '
    '12.3621 20.9452 12.5132 20.8413C12.6642 20.7374 12.7802 20.5902 12.8458 '
    '20.419L14.4958 16.128C14.6386 15.7568 14.8577 15.4197 15.139 15.1386C15.4203 '
    '14.8574 15.7575 14.6385 16.1288 14.496L20.4188 12.846C20.59 12.7804 20.7372 '
    '12.6644 20.8411 12.5134C20.945 12.3623 21.0006 12.1833 21.0006 12C21.0006 '
    '11.8167 20.945 11.6377 20.8411 11.4866C20.7372 11.3356 20.59 11.2196 20.4188 '
    '11.154L16.1278 9.504C15.7569 9.36071 15.4201 9.14139 15.139 8.86015C14.858 '
    '8.57891 14.6389 8.24198 14.4958 7.871L12.8458 3.581Z" fill="white"/></svg>';

// Family "care heart" icon (Figma node 1120:44122) — the heart path filled
// solid (not outline) so the gradient shader applies as a solid shape.
const String _kFamilyHeartSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" '
    'viewBox="0 0 18 18"><path d="M14.625 9.42877L8.99998 14.9998L3.37498 '
    '9.42877C3.00396 9.06773 2.71171 8.63378 2.51664 8.15424C2.32157 7.67471 '
    '2.2279 7.15998 2.24153 6.64247C2.25517 6.12495 2.3758 5.61587 2.59585 '
    '5.14727C2.8159 4.67867 3.13058 4.26071 3.5201 3.9197C3.90961 3.5787 '
    '4.36551 3.32203 4.85909 3.16588C5.35267 3.00972 5.87324 2.95745 6.38801 '
    '3.01237C6.90278 3.06728 7.40061 3.22818 7.85014 3.48495C8.29967 3.74171 '
    '8.69117 4.08877 8.99998 4.50427C9.31013 4.09178 9.70208 3.74776 10.1513 '
    '3.49372C10.6005 3.23968 11.0974 3.0811 11.6107 3.02791C12.124 2.97471 '
    '12.6428 3.02804 13.1346 3.18456C13.6263 3.34108 14.0805 3.59742 14.4686 '
    '3.93754C14.8568 4.27766 15.1706 4.69423 15.3903 5.16119C15.61 5.62814 '
    '15.731 6.13543 15.7457 6.6513C15.7604 7.16717 15.6684 7.68051 15.4756 '
    '8.1592C15.2827 8.6379 14.9932 9.07163 14.625 9.43327Z" fill="white"/></svg>';

// White "cradling hand" detail lines drawn on top of the solid heart so the
// glyph reads as a filled icon (not a thin outline).
const String _kFamilyHeartDetailSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" '
    'viewBox="0 0 18 18" fill="none"><path d="M8.99989 4.5L6.53014 '
    '6.96975C6.38953 7.1104 6.31055 7.30113 6.31055 7.5C6.31055 7.69887 '
    '6.38953 7.8896 6.53014 8.03025L6.93739 8.4375C7.45489 8.955 8.29489 8.955 '
    '8.81239 8.4375L9.56239 7.6875C10.0099 7.23995 10.617 6.98852 11.2499 '
    '6.98852C11.8828 6.98852 12.4898 7.23995 12.9374 7.6875L14.6249 9.375" '
    'stroke="white" stroke-width="1.3" stroke-linecap="round" '
    'stroke-linejoin="round"/><path d="M9.375 11.625L10.875 13.125" '
    'stroke="white" stroke-width="1.3" stroke-linecap="round" '
    'stroke-linejoin="round"/><path d="M11.25 9.75L12.75 11.25" stroke="white" '
    'stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/></svg>';

const List<String> _thMonth = [
  'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
  'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
];

// ── Medication slot data ─────────────────────────────────────────────────────

class _MedSlot {
  const _MedSlot({
    required this.id,
    required this.time,
    required this.meal,
    required this.name,
    required this.advice,
    required this.period,
  });
  final String id;
  final String time; // e.g. 06:20 น.
  final String meal; // ก่อนอาหาร / หลังอาหาร
  final String name;
  final String advice; // left-side AI advice
  final TimePeriod period;
}

const String _medName = 'Mucosolvan Tab.30';

const List<_MedSlot> _kMedSlots = [
  _MedSlot(
    id: 'morning',
    time: '06:20 น.',
    meal: 'ก่อนอาหาร',
    name: _medName,
    advice: 'มื้อเช้า · ก่อนอาหาร — ทาน Mucosolvan 1 เม็ด ก่อนอาหารเช้า '
        'ประมาณ 30 นาที ดื่มน้ำตามมากๆ เพื่อให้ยาดูดซึมดี',
    period: TimePeriod.morning,
  ),
  _MedSlot(
    id: 'day',
    time: '12:30 น.',
    meal: 'หลังอาหาร',
    name: _medName,
    advice: 'มื้อกลางวัน · หลังอาหาร — ทานยา 1 เม็ดหลังอาหารกลางวันทันที '
        'หากลืมให้ข้ามมื้อนั้นไป อย่าทานเพิ่มเป็น 2 เท่า',
    period: TimePeriod.day,
  ),
  _MedSlot(
    id: 'evening',
    time: '18:00 น.',
    meal: 'หลังอาหาร',
    name: _medName,
    advice: 'มื้อเย็น · หลังอาหาร — ทานยา 1 เม็ดหลังอาหารเย็น และไม่ควร'
        'หยุดยาเองแม้อาการจะดีขึ้น',
    period: TimePeriod.evening,
  ),
];

// ── Card ─────────────────────────────────────────────────────────────────────

class ActivityRecommendation {
  const ActivityRecommendation({
    required this.title,
    required this.badge,
    required this.image,
    this.subtitle,
    this.fit = BoxFit.cover,
  });
  final String title;
  final String? subtitle;
  final String badge;
  final String image;
  final BoxFit fit;
}

class _Page {
  const _Page({
    required this.label,
    required this.title,
    required this.body,
    required this.right,
    required this.grad,
    required this.ink,
    this.isAi = false,
    this.isFamily = false,
    this.action,
    this.onAction,
    this.actionDone = false,
    this.accent = const Color(0xFF12A892),
  });
  final String label;
  final String title;
  final String body;
  final Widget right;
  final List<Color> grad; // [deep, bright] backdrop tones
  final Color ink; // dark, hue-tinted text colour
  final bool isAi; // AI advice (sparkle) vs reminder (bell)
  final bool isFamily; // family card → care-heart icon
  final String? action; // CTA shown under the left text; null → none
  final VoidCallback? onAction; // null → not tappable (e.g. already done)
  final bool actionDone; // completed style (check)
  final Color accent; // button colour (page-tone, vivid)
}

// Two-tone backdrops (deep → bright) that harmonise with each card while
// keeping the (light) card distinct from the background.
// Light pastel backdrops (tint → lighter) suited to dark text; the bottom
// fades into the sheet background.
const Map<TimePeriod, List<Color>> _kGradForPeriod = {
  TimePeriod.morning: [Color(0xFFB9E0F7), Color(0xFFEAF6FD)],
  TimePeriod.day: [Color(0xFFF8DCB9), Color(0xFFFDF2E5)],
  TimePeriod.evening: [Color(0xFFDDD4F1), Color(0xFFF2EDFA)],
  TimePeriod.bedtime: [Color(0xFFC2DFEF), Color(0xFFEAF3F9)],
};
const List<Color> _kApptGrad = [Color(0xFFC6E9E2), Color(0xFFEBF7F4)];

// Near-black text tinted with each card's hue.
const Map<TimePeriod, Color> _kInkForPeriod = {
  TimePeriod.morning: Color(0xFF11375E),
  TimePeriod.day: Color(0xFF5E3415),
  TimePeriod.evening: Color(0xFF332658),
  TimePeriod.bedtime: Color(0xFF0B3550),
};
const Color _kApptInk = Color(0xFF0D453E);

// Vivid accent (button) per topic — same hue as the page, bright not dark.
const Map<TimePeriod, Color> _kAccentForPeriod = {
  TimePeriod.morning: Color(0xFF2E8BE6),
  TimePeriod.day: Color(0xFFE5860D),
  TimePeriod.evening: Color(0xFF7A5BD0),
  TimePeriod.bedtime: Color(0xFF1E78B0),
};
const Color _kApptAccent = Color(0xFF12A892);

// Family (add members) palette — soft rose, warm "care" tone.
const List<Color> _kFamilyGrad = [Color(0xFFF6D6DD), Color(0xFFFCEDF1)];
const Color _kFamilyInk = Color(0xFF5E2738);
const Color _kFamilyAccent = Color(0xFFE5618A);

// AI advice (med usage) and AI health-summary palettes.
const List<Color> _kAiUsageGrad = [Color(0xFFDAD6F3), Color(0xFFEFEDFB)];
const Color _kAiUsageInk = Color(0xFF2E2A63);
const List<Color> _kHealthGrad = [Color(0xFFCDEDDC), Color(0xFFEBF8F1)];
const Color _kHealthInk = Color(0xFF114B35);

const Map<TimePeriod, String> _kMealName = {
  TimePeriod.morning: 'มื้อเช้า',
  TimePeriod.day: 'มื้อกลางวัน',
  TimePeriod.evening: 'มื้อเย็น',
  TimePeriod.bedtime: 'ก่อนนอน',
};

/// "คำแนะนำจาก AI" — swiping the right carousel updates the left content.
/// Medication cards are split by time slot and can be marked as taken.
class AiAdviceCard extends StatefulWidget {
  const AiAdviceCard({super.key});

  @override
  State<AiAdviceCard> createState() => _AiAdviceCardState();
}

class _AiAdviceCardState extends State<AiAdviceCard> {
  final Set<String> _taken = {};
  Timer? _auto;

  // Number of distinct pages (stable; content loops via modulo).
  int get _pageCount {
    var n = _kMedSlots.length + 2; // med slots + 2 AI pages
    if (_firstSoon(hospitalAppointments) != null) n++;
    if (_firstSoon(homeVisitAppointments) != null) n++;
    return n;
  }

  // Start far in so the user can also swipe backwards; multiple of count → 1st.
  late final int _initialPage = _pageCount * 1000;
  late final PageController _ctrl =
      PageController(viewportFraction: 0.96, initialPage: _initialPage);
  late int _index = _initialPage;

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  void _startAuto() {
    _auto?.cancel();
    _auto = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_ctrl.hasClients) return;
      // Always move forward → seamless wrap to the first page.
      _ctrl.animateToPage(
        _index + 1,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAuto() => _auto?.cancel();

  @override
  void dispose() {
    _auto?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _recordMed(_MedSlot slot) {
    if (_taken.contains(slot.id)) return;
    setState(() => _taken.add(slot.id));
    AppToast.success(context, 'บันทึกการทานยาแล้ว');
  }

  String _when(AppointmentItem a) =>
      '${a.date.day} ${_thMonth[a.date.month - 1]} · ${a.time} น.';

  AppointmentItem? _firstSoon(AppointmentBundle b) {
    final s = b.byBucket[AppointmentBucket.soon];
    return (s != null && s.isNotEmpty) ? s.first : null;
  }

  List<_Page> _buildPages() {
    final pages = <_Page>[];

    // 1) AI — general medication-use advice.
    pages.add(_Page(
      isAi: true,
      label: 'คำแนะนำจาก AI',
      title: 'วิธีใช้ยาให้ถูกต้อง',
      body: 'ผู้ป่วยเบาหวานที่ฉีดอินซูลิน ควรฉีดใต้ผิวหนังบริเวณหน้าท้อง '
          'สลับตำแหน่งทุกครั้ง เก็บยาในตู้เย็น และตรวจระดับน้ำตาลก่อนฉีดทุกมื้อ',
      grad: _kAiUsageGrad,
      ink: _kAiUsageInk,
      right: const _AiBotCard(grad: _kAiUsageGrad),
    ));

    // 2) AI — health summary from the Health page data.
    pages.add(_Page(
      isAi: true,
      label: 'สรุปสุขภาพจาก AI',
      title: 'ภาพรวมสุขภาพของคุณ',
      body: 'จากข้อมูลสุขภาพล่าสุด น้ำหนักและ BMI อยู่ในเกณฑ์ดี ความดันปกติ '
          'แต่การนอนยังน้อยกว่าเป้าหมาย แนะนำพักผ่อนให้พอและออกกำลังสม่ำเสมอ',
      grad: _kHealthGrad,
      ink: _kHealthInk,
      right: const _AiBotCard(grad: _kHealthGrad),
    ));

    // 3) Family — add members (locked behind a package).
    pages.add(_Page(
      label: 'ครอบครัว',
      isFamily: true,
      title: 'ดูแลคนที่คุณรักกับเรา',
      body: 'ติดตามสุขภาพ ตำแหน่ง แจ้งเตือนการล้ม และโทรหากันได้ทุกเมื่อ',
      grad: _kFamilyGrad,
      ink: _kFamilyInk,
      action: 'Family Package',
      accent: _kFamilyAccent,
      onAction: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Family Package'),
            behavior: SnackBarBehavior.floating,
          ));
      },
      right: const _FamilyReminderCard(),
    ));

    // 4) Medication reminders by time slot (reminder, not AI).
    for (final s in _kMedSlots) {
      final taken = _taken.contains(s.id);
      pages.add(_Page(
        label: 'แจ้งเตือนการทานยา',
        title: '${_kMealName[s.period]} · ${s.time}',
        body: 'ถึงเวลาทานยา ${s.name}\n'
            'ครั้งละ 1 เม็ด · ${s.meal}',
        grad: _kGradForPeriod[s.period]!,
        ink: _kInkForPeriod[s.period]!,
        action: taken ? 'บันทึกแล้ว' : 'บันทึกการทานยา',
        onAction: taken ? null : () => _recordMed(s),
        actionDone: taken,
        accent: _kAccentForPeriod[s.period]!,
        right: _MedReminderCard(slot: s),
      ));
    }

    // 2) Appointment reminders — hospital + home visit (reminder, not AI).
    final hosp = _firstSoon(hospitalAppointments);
    if (hosp != null) {
      pages.add(_Page(
        label: 'แจ้งเตือนนัดหมาย',
        title: 'นัดหมายโรงพยาบาล',
        body: '${hosp.title} · ${hosp.subLeft}\n${_when(hosp)}\n${hosp.subRight}',
        grad: _kApptGrad,
        ink: _kApptInk,
        action: 'ทำแบบประเมิน',
        accent: _kApptAccent,
        onAction: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text('ทำแบบประเมิน'),
              behavior: SnackBarBehavior.floating,
            ));
        },
        right: _RecommendationCard(
          data: ActivityRecommendation(
            title: '${hosp.date.day} ${_thMonth[hosp.date.month - 1]}',
            subtitle: '${hosp.time} น.',
            badge: 'โรงพยาบาล',
            image: 'assets/bgappointment.png',
          ),
        ),
      ));
    }
    final home = _firstSoon(homeVisitAppointments);
    if (home != null) {
      pages.add(_Page(
        label: 'แจ้งเตือนนัดหมาย',
        title: 'นัดหมายเยี่ยมบ้าน',
        body: '${home.title}\n${_when(home)}\n${home.subRight} · ${home.subLeft}',
        grad: _kApptGrad,
        ink: _kApptInk,
        right: _RecommendationCard(
          data: ActivityRecommendation(
            title: '${home.date.day} ${_thMonth[home.date.month - 1]}',
            subtitle: '${home.time} น.',
            badge: 'เยี่ยมบ้าน',
            image: 'assets/bgvisitappointment.png',
          ),
        ),
      ));
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();
    final page = pages[_index % pages.length];
    final deep = page.grad[0];
    final bright = page.grad[1];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        // Vertical two-tone sheen whose bottom fades into the sheet background
        // so the section melts in and doesn't read as a big block.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            deep,
            bright,
            bright.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.72, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
      child: SizedBox(
        height: 196,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 53, child: _advice(page)),
            const SizedBox(width: 12),
            Expanded(flex: 47, child: _carousel(pages)),
          ],
        ),
      ),
    );
  }

  static Widget _topLeftLayout(
      Widget? currentChild, List<Widget> previousChildren) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }

  Widget _advice(_Page page) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Match the carousel card's top inset so the heading lines up.
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // AI pages → sparkle; family → care-heart; reminders → bell.
            // (All replay their one-shot animation per page via the key.)
            page.isAi
                ? _SparkleIcon(key: ValueKey('sparkle$_index'))
                : page.isFamily
                    ? _FamilyIcon(key: ValueKey('fam$_index'))
                    : _BellIcon(key: ValueKey('bell$_index')),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                layoutBuilder: _topLeftLayout,
                child: Column(
                  key: ValueKey('head$_index'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        page.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: page.ink.withValues(alpha: 0.66),
                          fontWeight: FontWeight.w700,
                          fontVariations: const [FontVariation('wght', 700)],
                          height: 1.1,
                        ),
                      ),
                    ),
                    Text(
                      page.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: page.ink,
                        fontWeight: FontWeight.w800,
                        fontVariations: const [FontVariation('wght', 800)],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Flexible(
          // Instant swap (no AnimatedSwitcher) so the body height doesn't
          // briefly grow during transitions and shove the button around.
          child: Text(
            page.body,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: page.ink.withValues(alpha: 0.86),
              fontWeight: FontWeight.w600,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
        ),
        if (page.action != null) ...[
          const SizedBox(height: 14),
          _ActionButton(
            key: ValueKey('act$_index'),
            label: page.action!,
            onTap: page.onAction,
            done: page.actionDone,
            color: page.accent,
          ),
        ],
      ],
    );
  }

  Widget _carousel(List<_Page> pages) {
    // Pause auto-scroll while a finger is on the carousel; resume on release.
    return Listener(
      onPointerDown: (_) => _stopAuto(),
      onPointerUp: (_) => _startAuto(),
      onPointerCancel: (_) => _startAuto(),
      child: PageView.builder(
        controller: _ctrl,
        padEnds: false,
        physics: const BouncingScrollPhysics(),
      onPageChanged: (i) => setState(() => _index = i),
      // Infinite: content loops via modulo so the last page flows to the first.
      itemCount: null,
      itemBuilder: (_, i) {
        final p = pages[i % pages.length];
        // AI pages: same footprint as other cards; the bot overhangs from
        // inside _AiBotCard (which carries its own shadow).
        if (p.isAi) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(3, 6, 12, 8),
            child: p.right,
          );
        }
        // Inner padding leaves room for the card shadow (PageView clips its
        // viewport, so the shadow must render inside the page bounds).
        return Padding(
          padding: const EdgeInsets.fromLTRB(3, 6, 12, 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: p.right,
          ),
        );
      },
      ),
    );
  }
}

/// Left CTA button ("ทำแบบประเมิน" / "บันทึกการทานยา") — gentle slide+fade in
/// once when its page appears.
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.done,
    required this.color,
  });
  final String label;
  final VoidCallback? onTap;
  final bool done;
  final Color color;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final onTap = widget.onTap;
    final done = widget.done;
    final color = widget.color;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 10), child: child),
        );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            decoration: BoxDecoration(
              // Pending → vivid page-tone CTA; done → soft tinted chip.
              color: done ? color.withValues(alpha: 0.16) : color,
              borderRadius: BorderRadius.circular(100),
              boxShadow: done
                  ? null
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (done) ...[
                  Icon(Icons.check_rounded, size: 15, color: color),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: done ? color : Colors.white,
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

/// Bell icon that shakes once (damped swing) when a reminder page appears.
class _BellIcon extends StatefulWidget {
  const _BellIcon({super.key});

  @override
  State<_BellIcon> createState() => _BellIconState();
}

class _BellIconState extends State<_BellIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..forward();

  static const _gold = Color(0xFFFFC93C);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _particle(int i, double dist, double opacity) {
    final a = -math.pi / 2 + i * (math.pi / 3);
    final size = 2.0 + 2.5 * opacity;
    return Transform.translate(
      offset: Offset(math.cos(a) * dist, math.sin(a) * dist),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFD24D),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) {
          final v = _c.value;
          final pt = Curves.easeOut.transform(v);
          final dist = 18 * pt;
          final pOp = (1 - pt).clamp(0.0, 1.0) * 0.95;
          final flash = (1 - (v / 0.45).clamp(0.0, 1.0)) * 0.5;
          final pop = Curves.elasticOut.transform(v.clamp(0.0, 1.0));
          // Damped swing — bell shakes then settles.
          final swing = math.sin(v * math.pi * 6) * 0.35 * (1 - v);
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: flash,
                child: Transform.scale(
                  scale: 1 + 1.2 * Curves.easeOut.transform(v),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [_gold, Color(0x00FFC93C)],
                        stops: [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              if (pOp > 0.01)
                for (int i = 0; i < 6; i++) _particle(i, dist, pOp),
              Transform.rotate(
                angle: swing,
                alignment: Alignment.topCenter,
                child: Transform.scale(
                  scale: (0.2 + 0.8 * pop).clamp(0.0, 1.2),
                  child: child,
                ),
              ),
            ],
          );
        },
        // Metallic gold gradient for a realistic bell.
        child: ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6B11E), Color(0xFFE2890C), Color(0xFFB5650A)],
          ).createShader(r),
          blendMode: BlendMode.srcIn,
          child: const Icon(Icons.notifications_active_rounded,
              size: 24, color: Colors.white),
        ),
      ),
    );
  }
}

/// Care-heart icon for the family card — solid rose heart that pops in with a
/// heartbeat + particle burst (same one-shot style as the sparkle/bell).
class _FamilyIcon extends StatefulWidget {
  const _FamilyIcon({super.key});

  @override
  State<_FamilyIcon> createState() => _FamilyIconState();
}

class _FamilyIconState extends State<_FamilyIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..forward();

  static const _rose = Color(0xFFF26A93);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _particle(int i, double dist, double opacity) {
    final a = -math.pi / 2 + i * (math.pi / 3);
    final size = 2.0 + 2.5 * opacity;
    return Transform.translate(
      offset: Offset(math.cos(a) * dist, math.sin(a) * dist),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF98FB0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) {
          final v = _c.value;
          final pt = Curves.easeOut.transform(v);
          final dist = 18 * pt;
          final pOp = (1 - pt).clamp(0.0, 1.0) * 0.95;
          final flash = (1 - (v / 0.45).clamp(0.0, 1.0)) * 0.5;
          final pop = Curves.elasticOut.transform(v.clamp(0.0, 1.0));
          // Damped heartbeat wobble layered over the spring-in.
          final beat = 0.12 * math.sin(v * math.pi * 5) * (1 - v);
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: flash,
                child: Transform.scale(
                  scale: 1 + 1.2 * Curves.easeOut.transform(v),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [_rose, Color(0x00F26A93)],
                        stops: [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              if (pOp > 0.01)
                for (int i = 0; i < 6; i++) _particle(i, dist, pOp),
              Transform.scale(
                scale: ((0.2 + 0.8 * pop) * (1 + beat)).clamp(0.0, 1.3),
                child: child,
              ),
            ],
          );
        },
        // Solid rose-gradient heart with white cradling-hand detail on top.
        child: Stack(
          alignment: Alignment.center,
          children: [
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF98FB0), Color(0xFFE5618A), Color(0xFFC74570)],
              ).createShader(r),
              blendMode: BlendMode.srcIn,
              child: SvgPicture.string(_kFamilyHeartSvg, width: 24, height: 24),
            ),
            SvgPicture.string(_kFamilyHeartDetailSvg, width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}

/// Sparkle icon with a gentle continuous pulse + twinkle (AI pages).
class _SparkleIcon extends StatefulWidget {
  const _SparkleIcon({super.key});

  @override
  State<_SparkleIcon> createState() => _SparkleIconState();
}

class _SparkleIconState extends State<_SparkleIcon>
    with SingleTickerProviderStateMixin {
  // Plays once (no loop) when this AI page appears.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..forward();

  static const _aura = Color(0xFF2BC8E6); // cyan glow (not purple)

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _particle(int i, double dist, double opacity) {
    final a = -math.pi / 2 + i * (math.pi / 3); // 6 dirs
    final size = 2.0 + 2.5 * opacity;
    return Transform.translate(
      offset: Offset(math.cos(a) * dist, math.sin(a) * dist),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF45E3F5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) {
          final v = _c.value;
          // Particles burst outward and fade.
          final pt = Curves.easeOut.transform(v);
          final dist = 18 * pt;
          final pOp = (1 - pt).clamp(0.0, 1.0) * 0.95;
          // Soft cyan flash behind, quick in/out.
          final flash = (1 - (v / 0.45).clamp(0.0, 1.0)) * 0.5;
          // Sparkle springs in + a small overshoot, then a gentle twinkle.
          final pop = Curves.elasticOut.transform(v.clamp(0.0, 1.0));
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: flash,
                child: Transform.scale(
                  scale: 1 + 1.2 * Curves.easeOut.transform(v),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [_aura, Color(0x002BC8E6)],
                        stops: [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              if (pOp > 0.01)
                for (int i = 0; i < 6; i++) _particle(i, dist, pOp),
              Transform.scale(scale: (0.2 + 0.8 * pop).clamp(0.0, 1.2), child: child),
            ],
          );
        },
        // Gradient sparkle (cyan → blue) to match the aura.
        child: ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF45E3F5), Color(0xFF2B7DE6)],
          ).createShader(r),
          blendMode: BlendMode.srcIn,
          child: SvgPicture.string(_kSparkleSvg, width: 24, height: 24),
        ),
      ),
    );
  }
}

/// AI-analysis card: same card style as other topics, but the AiBOT bursts out
/// of the card's left/top edge (head + arm + hand overhang; body stays inside).
class _AiBotCard extends StatelessWidget {
  const _AiBotCard({required this.grad});
  final List<Color> grad; // [deep, bright] — card colour follows the backdrop

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Card — inset on the left so the bot's pointing hand overhangs it.
            Positioned(
              left: w * 0.16,
              top: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [grad[1], grad[0]],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // AiBOT — overhangs the card top-left a touch (Figma proportions),
            // right/bottom flush to the card.
            Positioned(
              left: -0.068 * w,
              top: -0.04 * h,
              width: 1.068 * w,
              height: 1.044 * h,
              child: const Image(
                image: AssetImage('assets/AiBOT2.png'),
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Medication reminder card (per time slot) ─────────────────────────────────

class _MedReminderCard extends StatelessWidget {
  const _MedReminderCard({required this.slot});
  final _MedSlot slot;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Per-period background: real colour + decoration, positioned to
          // match the Figma card (sun/deco at 47,-100 size 220x240 on a 177 card).
          Positioned.fill(child: _background()),
          // Time + meal-timing badges — wrap to a new line if they overflow.
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _pill(slot.time),
                _pill(slot.meal),
              ],
            ),
          ),
          // Med name as a pill (same style as the time/meal badges), bottom-left.
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  slot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontVariations: [FontVariation('wght', 800)],
                    color: Color(0xFF3A3A3A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Per-period colour + decoration laid out per the Figma card (group at
  // 47,-100 sized 220x240 on a 177-wide card), scaled to the actual width.
  Widget _background() {
    final color = TimePeriodTheme.of(slot.period).backgroundColor;
    return LayoutBuilder(
      builder: (context, c) {
        final s = c.maxWidth / 177.0;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            ColoredBox(color: color),
            Positioned(
              left: 47 * s,
              top: -100 * s,
              width: 220 * s,
              height: 240 * s,
              child: _deco(220 * s, 240 * s),
            ),
          ],
        );
      },
    );
  }

  Widget _deco(double w, double h) {
    switch (slot.period) {
      case TimePeriod.morning:
        return DecorativeElements(size: w);
      case TimePeriod.day:
        return SvgPicture.asset('assets/svg/deco_day_rainbow.svg',
            width: w, height: h, fit: BoxFit.contain);
      case TimePeriod.evening:
        return SvgPicture.asset('assets/svg/deco_evening_frame1.svg',
            width: w, height: h, fit: BoxFit.contain);
      case TimePeriod.bedtime:
        return SvgPicture.asset('assets/svg/deco_bedtime_moon.svg',
            width: w, height: h, fit: BoxFit.contain);
    }
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            fontVariations: [FontVariation('wght', 800)],
            color: Color(0xFF3A3A3A),
          ),
        ),
      );
}



// ── Image recommendation card (appointment / activities) ─────────────────────

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.data});
  final ActivityRecommendation data;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFB0D7D6)),
          Padding(
            padding: data.fit == BoxFit.contain
                ? const EdgeInsets.fromLTRB(14, 36, 14, 28)
                : EdgeInsets.zero,
            child: Image.asset(
              data.image,
              fit: data.fit,
              alignment: data.fit == BoxFit.cover
                  ? Alignment.topCenter
                  : Alignment.center,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.62,
              widthFactor: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x0007A19D), Color(0xE607A19D)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                data.badge,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Right-side visual for the family card — the package promo illustration,
/// matching the other reminder cards' look.
class _FamilyReminderCard extends StatelessWidget {
  const _FamilyReminderCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFF7DCE3)),
          Image.asset(
            'assets/bgpacket.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          // Bottom gradient to seat the badge.
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
                    colors: [Color(0x00E5618A), Color(0xCCE5618A)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ครอบครัว',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
