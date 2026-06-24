import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  });
  final String label;
  final String title;
  final String body;
  final Widget right;
  final List<Color> grad; // [deep, bright] backdrop tones
  final Color ink; // dark, hue-tinted text colour
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

/// "คำแนะนำจาก AI" — swiping the right carousel updates the left content.
/// Medication cards are split by time slot and can be marked as taken.
class AiAdviceCard extends StatefulWidget {
  const AiAdviceCard({super.key});

  @override
  State<AiAdviceCard> createState() => _AiAdviceCardState();
}

class _AiAdviceCardState extends State<AiAdviceCard> {
  final PageController _ctrl = PageController(viewportFraction: 0.9);
  int _index = 0;
  final Set<String> _taken = {};

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _recordMed(_MedSlot slot) {
    if (_taken.contains(slot.id)) return;
    setState(() => _taken.add(slot.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('บันทึกการทานยาแล้ว'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  List<_Page> _buildPages() {
    final pages = <_Page>[
      for (final s in _kMedSlots)
        _Page(
          label: 'ผลวิเคราะห์',
          title: 'คำแนะนำการใช้ยา',
          body: s.advice,
          grad: _kGradForPeriod[s.period]!,
          ink: _kInkForPeriod[s.period]!,
          right: _MedReminderCard(
            slot: s,
            taken: _taken.contains(s.id),
            onRecord: () => _recordMed(s),
          ),
        ),
    ];

    // Nearest hospital appointment — fixed text, not AI.
    final soon = hospitalAppointments.byBucket[AppointmentBucket.soon];
    final appt = (soon != null && soon.isNotEmpty) ? soon.first : null;
    final apptWhen = appt == null
        ? ''
        : '${appt.date.day} ${_thMonth[appt.date.month - 1]} · ${appt.time} น.';
    pages.add(_Page(
      label: 'นัดหมายที่ใกล้ถึง',
      title: 'นัดหมายถัดไป',
      grad: _kApptGrad,
      ink: _kApptInk,
      body: appt == null
          ? 'ไม่มีนัดหมายที่กำลังจะถึง'
          : '${appt.title} · ${appt.subLeft}\n$apptWhen\n${appt.subRight}',
      right: _RecommendationCard(
        data: ActivityRecommendation(
          title: appt == null
              ? 'นัดหมาย'
              : '${appt.date.day} ${_thMonth[appt.date.month - 1]}',
          subtitle: appt == null ? null : '${appt.time} น.',
          badge: 'นัดหมาย',
          image: 'assets/appt_scene.png',
        ),
      ),
    ));
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();
    final page = pages[_index.clamp(0, pages.length - 1)];
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.string(
              _kSparkleSvg,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(page.ink, BlendMode.srcIn),
            ),
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
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            layoutBuilder: _topLeftLayout,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                page.body,
                key: ValueKey('body$_index'),
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
          ),
        ),
      ],
    );
  }

  Widget _carousel(List<_Page> pages) {
    return PageView.builder(
      controller: _ctrl,
      padEnds: false,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (i) => setState(() => _index = i),
      itemCount: pages.length,
      // Inner padding leaves room for the card shadow (PageView clips its
      // viewport, so the shadow must render inside the page bounds).
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.fromLTRB(3, 6, 12, 8),
        child: DecoratedBox(
          // Soft shadow so the card stands clear of the backdrop.
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
          child: pages[i].right,
        ),
      ),
    );
  }
}

// ── Medication reminder card (per time slot) ─────────────────────────────────

class _MedReminderCard extends StatelessWidget {
  const _MedReminderCard({
    required this.slot,
    required this.taken,
    required this.onRecord,
  });
  final _MedSlot slot;
  final bool taken;
  final VoidCallback onRecord;

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
          // White summary panel — flush to the card edges, med name only.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      slot.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RecordButton(taken: taken, onTap: onRecord),
                ],
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

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.taken, required this.onTap});
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: taken ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          // Same icons as the medicine screen (pending sun / done check).
          child: taken
              ? SvgPicture.asset('assets/svg/icon_done_check.svg',
                  width: 24, height: 24)
              : SvgPicture.asset(
                  'assets/svg/icon_pending_sun.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFA5ACA6),
                    BlendMode.srcIn,
                  ),
                ),
        ),
      ),
    );
  }
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
          Positioned(
            left: 14,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    fontVariations: [FontVariation('wght', 900)],
                    shadows: [Shadow(color: Color(0x80000000), blurRadius: 6)],
                  ),
                ),
                if (data.subtitle != null)
                  Text(
                    data.subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      fontVariations: [FontVariation('wght', 800)],
                      shadows: [Shadow(color: Color(0x80000000), blurRadius: 6)],
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
