import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';
import 'assessment/assessment_config.dart';
import 'assessment/assessment_runner_screen.dart';
import 'widgets/health_detail_app_bar.dart';

/// A single assessment the user can take (Figma tab 1).
class _AssessmentTemplate {
  const _AssessmentTemplate({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.minutes,
    required this.image,
  });
  final String id;
  final String title;
  final int questionCount;
  final int minutes;
  final String image;
}

/// A past assessment result (Figma tab 2).
class _AssessmentRecord {
  const _AssessmentRecord({
    required this.templateId,
    required this.title,
    required this.date,
    required this.score,
    required this.maxScore,
    required this.level,
    required this.levelLabel,
    required this.resultSummary,
    required this.recommendation,
    required this.image,
  });
  final String templateId;
  final String title;
  final DateTime date;
  final int score;
  final int maxScore;
  final _AssessmentLevel level;
  final String levelLabel;
  final String resultSummary;
  final String recommendation;
  final String image;
}

enum _AssessmentLevel { normal, watch, risk }

extension on _AssessmentLevel {
  Color get color {
    switch (this) {
      case _AssessmentLevel.normal:
        return const Color(0xFF1D8B6B);
      case _AssessmentLevel.watch:
        return const Color(0xFFD97706);
      case _AssessmentLevel.risk:
        return const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case _AssessmentLevel.normal:
        return CupertinoIcons.checkmark_seal_fill;
      case _AssessmentLevel.watch:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case _AssessmentLevel.risk:
        return CupertinoIcons.exclamationmark_octagon_fill;
    }
  }
}

const _imgBase = 'assets/images/assessment';

const _templates = <_AssessmentTemplate>[
  _AssessmentTemplate(
    id: 'dyspnea',
    title: 'เกณฑ์การให้คะแนนภาวะหายใจลำบาก',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/dyspnea.png',
  ),
  _AssessmentTemplate(
    id: 'asthma',
    title: 'ประเมินการควบคุมโรคหืด',
    questionCount: 1,
    minutes: 1,
    image: '$_imgBase/asthma.png',
  ),
  _AssessmentTemplate(
    id: 'cv-risk',
    title: 'ประเมินความเสี่ยงโรคหัวใจและหลอดเลือด',
    questionCount: 1,
    minutes: 1,
    image: '$_imgBase/cv-risk.png',
  ),
  _AssessmentTemplate(
    id: 'bp-risk',
    title: 'ประเมินความเสี่ยงโรคความดันโลหิต',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/bp-risk.png',
  ),
  _AssessmentTemplate(
    id: 'diabetes-risk',
    title: 'ประเมินความเสี่ยงโรคเบาหวาน',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/diabetes-risk.png',
  ),
  _AssessmentTemplate(
    id: 'mental',
    title: 'ประเมินสุขภาพจิต',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/mental.png',
  ),
  _AssessmentTemplate(
    id: 'adl',
    title: 'แบบประเมินกิจวัตรประจำวัน ADL',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/adl.png',
  ),
  _AssessmentTemplate(
    id: 'inhomesss',
    title: 'แบบประเมิน INHOMESSS',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/inhomesss.png',
  ),
  _AssessmentTemplate(
    id: 'palliative',
    title: 'แบบประเมินผู้ป่วย Palliative Care',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/palliative.png',
  ),
  _AssessmentTemplate(
    id: 'crisis',
    title: 'แบบประเมินผู้ประสบภาวะวิกฤต',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/crisis.png',
  ),
  _AssessmentTemplate(
    id: 'screen-35',
    title: 'แบบคัดกรองภาวะเสี่ยง 35 ปีขึ้นไป',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/screen-35.png',
  ),
  _AssessmentTemplate(
    id: 'esas',
    title: 'แบบประเมิน ESAS',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/esas.png',
  ),
  _AssessmentTemplate(
    id: 'barthel',
    title: 'แบบประเมิน Barthel Index Score',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/barthel.png',
  ),
  _AssessmentTemplate(
    id: 'caregiver',
    title: 'แบบประเมินภาระการดูแลผู้ป่วยที่บ้าน',
    questionCount: 6,
    minutes: 5,
    image: '$_imgBase/dyspnea.png',
  ),
];

List<_AssessmentRecord> _mockHistory() {
  final now = DateTime.now();
  return [
    _AssessmentRecord(
      templateId: 'dyspnea',
      title: 'เกณฑ์การให้คะแนนภาวะหายใจลำบาก',
      date: DateTime(now.year, now.month, 25),
      score: 5,
      maxScore: 10,
      level: _AssessmentLevel.normal,
      levelLabel: 'ปกติ',
      resultSummary:
          'การหายใจของคุณอยู่ในเกณฑ์ปกติ ไม่มีสัญญาณของภาวะหายใจลำบากที่น่ากังวล ระบบทางเดินหายใจทำงานได้ดีในขณะพักและขณะทำกิจวัตรประจำวัน',
      recommendation:
          'ออกกำลังกายเบา ๆ สม่ำเสมอ เช่น เดินเร็ว 30 นาที/วัน หลีกเลี่ยงควันบุหรี่และฝุ่น PM2.5 หมั่นสังเกตอาการ หากมีหายใจลำบากผิดปกติ ควรปรึกษาแพทย์',
      image: '$_imgBase/dyspnea.png',
    ),
    _AssessmentRecord(
      templateId: 'dyspnea',
      title: 'เกณฑ์การให้คะแนนภาวะหายใจลำบาก',
      date: DateTime(now.year, now.month, 25),
      score: 5,
      maxScore: 10,
      level: _AssessmentLevel.normal,
      levelLabel: 'ปกติ',
      resultSummary:
          'ผลลัพธ์อยู่ในเกณฑ์ปกติเช่นเดียวกับการประเมินครั้งที่ผ่านมา แสดงถึงความคงที่ของระบบทางเดินหายใจในช่วง 2 สัปดาห์ที่ผ่านมา',
      recommendation:
          'รักษาพฤติกรรมเดิม ออกกำลังกายและดูแลสุขภาพปอดต่อเนื่อง นัดประเมินซ้ำอีก 3 เดือนข้างหน้าหากไม่มีอาการผิดปกติ',
      image: '$_imgBase/dyspnea.png',
    ),
    _AssessmentRecord(
      templateId: 'asthma',
      title: 'ประเมินการควบคุมโรคหืด',
      date: DateTime(now.year, now.month, 23),
      score: 8,
      maxScore: 25,
      level: _AssessmentLevel.watch,
      levelLabel: 'ควรเฝ้าระวัง',
      resultSummary:
          'อาการหืดยังควบคุมได้ไม่เต็มที่ พบมีอาการตอนกลางคืนและต้องใช้ยาพ่นฉุกเฉินบางครั้งในช่วง 4 สัปดาห์ที่ผ่านมา',
      recommendation:
          'ใช้ยาพ่นควบคุมตามที่แพทย์สั่งสม่ำเสมอ หลีกเลี่ยงสิ่งกระตุ้น เช่น ฝุ่น ขนสัตว์ อากาศเย็น ถ้าต้องใช้ยาพ่นฉุกเฉินมากกว่า 2 ครั้ง/สัปดาห์ ควรกลับไปพบแพทย์',
      image: '$_imgBase/asthma.png',
    ),
    _AssessmentRecord(
      templateId: 'mental',
      title: 'ประเมินสุขภาพจิต',
      date: DateTime(now.year, now.month, 20),
      score: 12,
      maxScore: 27,
      level: _AssessmentLevel.watch,
      levelLabel: 'เริ่มมีสัญญาณเครียด',
      resultSummary:
          'พบสัญญาณของภาวะซึมเศร้าระดับปานกลาง มีอารมณ์หดหู่และเหนื่อยล้าเกิดขึ้นเกือบทุกวัน ส่งผลต่อสมาธิและการนอนในระดับเล็กน้อย',
      recommendation:
          'จัดเวลาพักผ่อน ทำกิจกรรมที่ชอบ และพูดคุยกับคนใกล้ชิด ลองฝึกหายใจหรือสมาธิ 10 นาที/วัน หากอาการต่อเนื่องเกิน 2 สัปดาห์ แนะนำปรึกษานักจิตวิทยาหรือจิตแพทย์',
      image: '$_imgBase/mental.png',
    ),
    _AssessmentRecord(
      templateId: 'diabetes-risk',
      title: 'ประเมินความเสี่ยงโรคเบาหวาน',
      date: DateTime(now.year, now.month - 1, 18),
      score: 9,
      maxScore: 20,
      level: _AssessmentLevel.watch,
      levelLabel: 'เสี่ยงปานกลาง',
      resultSummary:
          'มีปัจจัยเสี่ยงของการเป็นเบาหวานในระดับปานกลาง เช่น รอบเอวและดัชนีมวลกายสูงกว่าเกณฑ์ ในครอบครัวมีผู้ป่วยเบาหวาน',
      recommendation:
          'ควบคุมอาหาร ลดน้ำตาลและแป้งขัดสี ออกกำลังกายแบบคาร์ดิโอ 150 นาที/สัปดาห์ ตรวจน้ำตาลในเลือดทุก 6 เดือนเพื่อติดตามอย่างใกล้ชิด',
      image: '$_imgBase/diabetes-risk.png',
    ),
  ];
}

class HealthAssessmentScreen extends StatefulWidget {
  const HealthAssessmentScreen({super.key});

  @override
  State<HealthAssessmentScreen> createState() => _HealthAssessmentScreenState();
}

class _HealthAssessmentScreenState extends State<HealthAssessmentScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0; // 0 = templates, 1 = history
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void dispose() {
    _scrollOffset.dispose();
    super.dispose();
  }

  void _setTab(int next) {
    if (_tab == next) return;
    HapticFeedback.selectionClick();
    setState(() {
      _tab = next;
      _scrollOffset.value = 0;
    });
  }

  void _startAssessment(_AssessmentTemplate t) {
    HapticFeedback.lightImpact();
    final config = kAssessmentConfigs[t.id];
    if (config != null) {
      showAssessmentRunner(context, config);
      return;
    }
    AppToast.info(context, 'เปิดแบบประเมิน: ${t.title}');
  }

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _AssessmentTabBar(
                    selected: _tab,
                    onChange: _setTab,
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is ScrollUpdateNotification ||
                          n is ScrollStartNotification) {
                        _scrollOffset.value = n.metrics.pixels;
                      }
                      return false;
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.02),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _tab == 0
                          ? _TemplatesList(
                              key: const ValueKey('templates'),
                              onStart: _startAssessment,
                            )
                          : _HistoryList(
                              key: const ValueKey('history'),
                              records: _mockHistory(),
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
                title: 'แบบประเมินสุขภาพ',
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

// ── Tab bar (glass pill) ────────────────────────────────────────────────────

class _AssessmentTabBar extends StatelessWidget {
  const _AssessmentTabBar({
    required this.selected,
    required this.onChange,
  });
  final int selected;
  final ValueChanged<int> onChange;

  static const _labels = ['แบบประเมิน', 'ประวัติ'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFD4D4D4).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final slot = constraints.maxWidth / _labels.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: const Cubic(0.34, 1.36, 0.64, 1.0),
                left: slot * selected,
                top: 0,
                bottom: 0,
                width: slot,
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
                  for (int i = 0; i < _labels.length; i++)
                    Expanded(
                      child: PressEffect(
                        onTap: () => onChange(i),
                        scale: 0.96,
                        haptic: HapticKind.none,
                        ripple: false,
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          height: double.infinity,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: TextStyle(
                                color: i == selected
                                    ? const Color(0xFF0088FF)
                                    : const Color(0xFF1A1A1A),
                                fontSize: 15,
                                fontWeight: i == selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                letterSpacing: -0.2,
                              ),
                              child: Text(_labels[i]),
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
    );
  }
}

// ── Tab 1: Assessment templates ─────────────────────────────────────────────

class _TemplatesList extends StatelessWidget {
  const _TemplatesList({super.key, required this.onStart});
  final ValueChanged<_AssessmentTemplate> onStart;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: _templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _TemplateCard(
        template: _templates[i],
        onStart: () => onStart(_templates[i]),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onStart,
  });
  final _AssessmentTemplate template;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onStart,
      scale: 0.98,
      haptic: HapticKind.none,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF747480).withValues(alpha: 0.08),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: _CornerDecoration(image: template.image),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 56),
                    child: Text(
                      template.title,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: 0.7,
                    child: Row(
                      children: [
                        _MetaItem(
                          icon: CupertinoIcons.doc_text,
                          text: 'จำนวน ${template.questionCount} ข้อ',
                        ),
                        Container(
                          width: 1,
                          height: 10,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 10),
                          color:
                              const Color(0xFF1A1A1A).withValues(alpha: 0.2),
                        ),
                        _MetaItem(
                          icon: CupertinoIcons.clock,
                          text: '${template.minutes} นาที',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StartButton(onTap: onStart),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF1A1A1A)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 10,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      scale: 0.96,
      haptic: HapticKind.selection,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4BA0FF), Color(0xFF2E86F5)],
          ),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: CupertinoColors.white.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E86F5).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'ทำแบบประเมิน',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  const _CornerDecoration({required this.image});
  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Image.asset(image, fit: BoxFit.cover),
    );
  }
}

// ── Tab 2: History list ─────────────────────────────────────────────────────

class _HistoryList extends StatelessWidget {
  const _HistoryList({super.key, required this.records});
  final List<_AssessmentRecord> records;

  static const _thaiMonths = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];
  static const _thaiMonthsShort = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มีประวัติการประเมิน',
          style: TextStyle(
            color: Color(0xFF6D756E),
            fontSize: 14,
          ),
        ),
      );
    }

    final groups = <String, List<_AssessmentRecord>>{};
    final orderedKeys = <String>[];
    for (final r in records) {
      final key = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}';
      if (!groups.containsKey(key)) {
        orderedKeys.add(key);
        groups[key] = [];
      }
      groups[key]!.add(r);
    }

    final widgets = <Widget>[];
    for (final key in orderedKeys) {
      final parts = key.split('-');
      final month = int.parse(parts[1]);
      final year = int.parse(parts[0]);
      final thaiYear = (year + 543) % 100;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            '${_thaiMonths[month - 1]} ${thaiYear.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      final items = groups[key]!;
      for (int i = 0; i < items.length; i++) {
        final r = items[i];
        widgets.add(
          _HistoryRow(
            record: r,
            dayLabel: r.date.day.toString(),
            monthShort: _thaiMonthsShort[r.date.month - 1]
                .replaceAll('.', ''),
            showConnector: i < items.length - 1,
          ),
        );
      }
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: widgets,
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.record,
    required this.dayLabel,
    required this.monthShort,
    required this.showConnector,
  });
  final _AssessmentRecord record;
  final String dayLabel;
  final String monthShort;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthShort,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayLabel,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color:
                              const Color(0xFF1A1A1A).withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showConnector ? 16 : 0),
              child: PressEffect(
                onTap: () => _showAssessmentResultSheet(context, record),
                haptic: HapticKind.selection,
                scale: 0.98,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF747480).withValues(alpha: 0.08),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: _CornerDecoration(image: record.image),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 56),
                              child: Text(
                                record.title,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: record.level.color,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'S',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${record.score} คะแนน',
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}

// ── Result sheet ────────────────────────────────────────────────────────────

void _showAssessmentResultSheet(
  BuildContext context,
  _AssessmentRecord record,
) {
  HapticFeedback.selectionClick();
  Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      barrierLabel: 'assessment-result',
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => _AssessmentResultSheet(record: record),
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
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

class _AssessmentResultSheet extends StatelessWidget {
  const _AssessmentResultSheet({required this.record});

  final _AssessmentRecord record;

  static const _thaiMonthsShort = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      resizeToAvoidBottomInset: false,
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA).withValues(alpha: 0.92),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(38)),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.white.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text(
                            'ผลประเมิน',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: LiquidGlassButton(
                              icon: CupertinoIcons.xmark,
                              iconColor: const Color(0xFF1A1A1A),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      children: [
                        _ResultHeader(record: record),
                        const SizedBox(height: 20),
                        _ResultScoreCard(record: record),
                        const SizedBox(height: 20),
                        _ResultSection(
                          title: 'ผลการประเมิน',
                          icon: CupertinoIcons.doc_text_search,
                          body: record.resultSummary,
                        ),
                        const SizedBox(height: 14),
                        _ResultSection(
                          title: 'คำแนะนำ',
                          icon: CupertinoIcons.lightbulb_fill,
                          body: record.recommendation,
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
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.record});
  final _AssessmentRecord record;

  @override
  Widget build(BuildContext context) {
    final date = _AssessmentResultSheet._thaiMonthsShort;
    final thaiYear = (record.date.year + 543) % 100;
    final dateStr = '${record.date.day} ${date[record.date.month - 1]} '
        '${thaiYear.toString().padLeft(2, '0')}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: record.level.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(6),
          child: Image.asset(record.image, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.title,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.clock,
                    size: 12,
                    color: Color(0xFF6D756E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ประเมินเมื่อ $dateStr',
                    style: const TextStyle(
                      color: Color(0xFF6D756E),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
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
}

class _ResultScoreCard extends StatelessWidget {
  const _ResultScoreCard({required this.record});
  final _AssessmentRecord record;

  @override
  Widget build(BuildContext context) {
    final color = record.level.color;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const Text(
              'คะแนน',
              style: TextStyle(
                color: Color(0xFF6D756E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  record.score.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '/ ${record.maxScore}',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: color.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(record.level.icon, size: 15, color: color),
                  const SizedBox(width: 7),
                  Text(
                    record.levelLabel,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
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
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.icon,
    required this.body,
  });
  final String title;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1D8B6B)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.55,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
