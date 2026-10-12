import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../health/widgets/health_detail_app_bar.dart';

/// ขั้นหนึ่งในเส้นทางการรับบริการ — มาจากเหตุการณ์ที่ agent อ่านจาก HOSxP
/// (visit_opened, dept_queued, lab_ordered, lab_reported, rx_ordered, visit_closed)
class VisitStep {
  const VisitStep({
    required this.title,
    this.time,
    this.detail,
    this.stage = 0,
    this.push = false,
  });

  final String title;

  /// เวลาที่เกิดขึ้น — null = ยังไม่ถึงขั้นนี้
  final String? time;
  final String? detail;

  /// ช่วงใหญ่ที่ขั้นนี้สังกัด (ใช้กับแถบความคืบหน้า 6 ช่วง)
  final int stage;

  /// ขั้นที่ส่ง push ให้ผู้ป่วย (ต้องลุกไปทำอะไร) — ขั้นอื่นแสดงในแอปอย่างเดียว
  final bool push;

  bool get done => time != null;
}

/// การรับบริการที่กำลังเกิดขึ้นวันนี้ (หนึ่ง visit)
class VisitJourney {
  const VisitJourney({
    required this.hospitalName,
    required this.vn,
    required this.queueNo,
    required this.steps,
    required this.updatedAt,
    required this.nextAction,
    required this.nextLabel,
    required this.nextValue,
    required this.nextNote,
  });

  final String hospitalName;
  final String vn;
  final int queueNo;
  final List<VisitStep> steps;
  final String updatedAt;

  /// สิ่งที่ผู้ป่วยต้องทำต่อ — สั้น ชัด อ่านแล้วลุกไปทำได้เลย
  final String nextAction;

  /// ป้ายเล็กเหนือค่าหลัก เช่น "ห้องตรวจ"
  final String nextLabel;

  /// ค่าหลักตัวใหญ่ เช่น "056"
  final String nextValue;
  final String nextNote;

  /// รับบริการเสร็จแล้ว
  bool get finished => stage == stages.length - 1;

  /// ช่วงใหญ่ 6 ช่วงที่ผู้ป่วยเข้าใจง่าย
  static const stages = [
    'เปิด visit',
    'คัดกรอง',
    'แล็บ',
    'ห้องตรวจ',
    'รับยา',
    'เสร็จสิ้น',
  ];

  /// ขั้นล่าสุดที่เกิดขึ้นแล้ว
  VisitStep get current => steps.lastWhere((s) => s.done);

  /// ช่วงใหญ่ปัจจุบัน (0-5)
  int get stage => current.stage;

  /// สิ่งที่ผู้ป่วยต้องทำในแต่ละช่วง
  static const stageTodo = [
    'ยื่นบัตรที่จุดคัดกรอง',
    'รอพยาบาลซักประวัติ',
    'รอผลตรวจแล็บ',
    'รอเรียกชื่อหน้าห้องตรวจ',
    'ไปรับยาที่ห้องจ่ายยา',
    'กลับบ้านได้ ดูวันนัดครั้งหน้า',
  ];

  static const stageIcons = [
    Icons.how_to_reg_rounded,
    Icons.monitor_heart_rounded,
    Icons.science_rounded,
    Icons.medical_services_rounded,
    Icons.medication_rounded,
    Icons.home_rounded,
  ];

  /// นาทีที่รับบริการมาแล้ว (เปิด visit ถึงอัปเดตล่าสุด)
  int get elapsedMinutes {
    int m(String t) {
      final p = t.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    return m(updatedAt) - m(steps.first.time!);
  }
}

/// ทุกขั้นของ visit ตัวอย่าง (อิงเคสจริงในภาพ Patient Flow Trace 7 ต.ค. 2569
/// เรียงลำดับใหม่ให้เดินตามช่วงสำหรับสาธิต) — ขั้นที่ยังไม่ถึงจะไม่มีเวลา
const _demoSteps = [
  VisitStep(
    title: 'เปิด visit',
    time: '13:07',
    detail: 'VN 691007130727 · คิว 336',
    stage: 0,
    push: true,
  ),
  VisitStep(title: 'ซักประวัติ / คัดกรอง', time: '13:11', stage: 1),
  VisitStep(title: 'สั่งตรวจแล็บ', time: '13:14', stage: 2),
  VisitStep(title: 'ห้องแล็บรับตัวอย่างแล้ว', time: '13:16', stage: 2),
  VisitStep(title: 'ผลแล็บออกแล้ว', time: '13:24', stage: 2),
  VisitStep(
    title: 'ย้ายไปรอที่ห้องตรวจ 056',
    time: '13:26',
    detail: 'รอเจ้าหน้าที่เรียกชื่อ',
    stage: 3,
    push: true,
  ),
  VisitStep(
    title: 'ไปรับยา',
    time: '13:48',
    detail: 'ห้องจ่ายยา 1 · คิวยา 112',
    stage: 4,
    push: true,
  ),
  VisitStep(
    title: 'จบการรับบริการ',
    time: '14:02',
    detail: 'นัดครั้งหน้า 7 พ.ย. 69',
    stage: 5,
    push: true,
  ),
];

/// สิ่งที่ต้องทำต่อของแต่ละช่วง: (ทำอะไร, ป้ายเล็ก, ค่าหลัก, หมายเหตุ)
const _demoNext = [
  ('ไปจุดคัดกรอง', 'คิวของคุณ', '336', 'ยื่นบัตรประชาชน'),
  ('รอซักประวัติ', 'จุดคัดกรอง', 'OPD', 'วัดความดัน'),
  ('รอผลแล็บ', 'อีกประมาณ', '15 นาที', 'นั่งรอได้เลย'),
  ('ไปรอหน้าห้อง', 'ห้องตรวจ', '056', 'รอเรียกชื่อ'),
  ('ไปรับยา', 'ห้องจ่ายยา', '1', 'คิวยา 112'),
  ('กลับบ้านได้', 'นัดครั้งหน้า', '7 พ.ย.', 'ดูในนัดหมาย'),
];

/// ภาพของ visit ตัวอย่าง ณ ช่วง [stage]
/// TODO(integration): รับจาก HFT Cloud ที่ agent ของ รพ. ส่งขึ้นมา
VisitJourney demoVisitJourney(int stage) {
  final steps = [
    for (final s in _demoSteps)
      s.stage <= stage
          ? s
          : VisitStep(
              title: s.title,
              detail: s.detail,
              stage: s.stage,
              push: s.push,
            ),
  ];
  final next = _demoNext[stage];
  return VisitJourney(
    hospitalName: 'รพ.แปลงยาว',
    vn: '691007130727',
    queueNo: 336,
    updatedAt: steps.lastWhere((s) => s.done).time!,
    nextAction: next.$1,
    nextLabel: next.$2,
    nextValue: next.$3,
    nextNote: next.$4,
    steps: steps,
  );
}

/// โหมดสาธิต Live Activity — เริ่มที่ช่วงแรก แล้วเลื่อนไปช่วงถัดไปทุก 2 นาที
/// ครบทุกช่วงแล้ววนกลับมาเริ่มใหม่ ให้เห็นหน้าตาตอนใช้งานจริงทุกขั้น
class VisitJourneyDemo {
  VisitJourneyDemo._() {
    _timer = Timer.periodic(interval, (_) {
      _stage = (_stage + 1) % VisitJourney.stages.length;
      journey.value = demoVisitJourney(_stage);
    });
  }

  static final instance = VisitJourneyDemo._();

  static const interval = Duration(minutes: 2);

  int _stage = 0;
  late final Timer _timer;
  final ValueNotifier<VisitJourney> journey = ValueNotifier(
    demoVisitJourney(0),
  );

  /// เผื่อปิดโหมดสาธิตเมื่อต่อข้อมูลจริง
  void dispose() => _timer.cancel();
}

/// เขียวหลักของแอป และสีตัวอักษรเข้มโทนเดียวกัน
const _brand = Color(0xFF1D8B6B);
const _brandInk = Color(0xFF0D453E);

/// จุดเขียวกระพริบ บอกว่าเป็นข้อมูลสด
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.size = 8, this.color = _brand});

  final double size;
  final Color color;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s * 2,
      height: s * 2,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // วงกระจายออกแล้วจางหาย
              Container(
                width: s + s * t,
                height: s + s * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.45 * (1 - t)),
                ),
              ),
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// หน้าเส้นทางการรับบริการวันนี้ — ทุกขั้นตั้งแต่เปิด visit จนกลับบ้าน
class VisitJourneyScreen extends StatefulWidget {
  const VisitJourneyScreen({super.key});

  @override
  State<VisitJourneyScreen> createState() => _VisitJourneyScreenState();
}

class _VisitJourneyScreenState extends State<VisitJourneyScreen> {
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void dispose() {
    VisitJourneyDemo.instance.journey.removeListener(_onChange);
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // สถานะเปลี่ยนเองระหว่างเปิดหน้านี้อยู่ (ข้อมูลสด)
    VisitJourneyDemo.instance.journey.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final j = VisitJourneyDemo.instance.journey.value;
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
                      child: ListView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        children: [
                          _SummaryCard(journey: j),
                          const SizedBox(height: 16),
                          _Timeline(journey: j),
                          const SizedBox(height: 16),
                          Text(
                            'ข้อมูลจากระบบ HOSxP ของโรงพยาบาล '
                            'อัปเดตอัตโนมัติภายในไม่กี่วินาทีหลังเจ้าหน้าที่บันทึก',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(
                                0xFF1A1A1A,
                              ).withValues(alpha: 0.5),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
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
                title: 'เส้นทางการรับบริการ',
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

/// การ์ดสรุปบนสุด — โรงพยาบาล VN คิว และขั้นตอนตอนนี้
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.journey});
  final VisitJourney journey;

  @override
  Widget build(BuildContext context) {
    final j = journey;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: CupertinoColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiveDot(),
              const SizedBox(width: 4),
              Text(
                j.finished ? 'รับบริการเสร็จแล้ว' : 'กำลังรับบริการ',
                style: TextStyle(
                  color: _brandInk.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'อัปเดต ${j.updatedAt} น.',
                style: TextStyle(
                  color: _brandInk.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      j.current.title,
                      style: const TextStyle(
                        color: _brandInk,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                        height: 1.3,
                      ),
                    ),
                    if (j.current.detail != null)
                      Text(
                        j.current.detail!,
                        style: TextStyle(
                          color: _brandInk.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'คิว',
                    style: TextStyle(
                      color: _brandInk.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${j.queueNo}',
                    style: const TextStyle(
                      color: _brandInk,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      fontVariations: [FontVariation('wght', 800)],
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StageBar(stage: j.stage),
          const SizedBox(height: 16),
          // สิ่งที่ต้องทำต่อ แบบคำเต็ม (บน banner ย่อให้พอดีการ์ด)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: _brand,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    VisitJourney.stageIcons[j.stage],
                    size: 20,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ต้องทำต่อ',
                        style: TextStyle(
                          color: _brandInk.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${j.nextAction} · ${j.nextLabel} ${j.nextValue}',
                        style: const TextStyle(
                          color: _brandInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontVariations: [FontVariation('wght', 700)],
                          height: 1.3,
                        ),
                      ),
                      Text(
                        j.nextNote,
                        style: TextStyle(
                          color: _brandInk.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _brandInk.withValues(alpha: 0.08)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.local_hospital_rounded,
                size: 16,
                color: _brandInk.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${j.hospitalName} · VN ${j.vn}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _brandInk.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// แถบ 6 ช่วงพร้อมชื่อใต้แต่ละช่วง
class _StageBar extends StatelessWidget {
  const _StageBar({required this.stage});
  final int stage;

  @override
  Widget build(BuildContext context) {
    const names = VisitJourney.stages;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < names.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i <= stage
                        ? _brand
                        : _brandInk.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  names[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _brandInk.withValues(alpha: i <= stage ? 0.85 : 0.4),
                    fontSize: 10,
                    fontWeight: i == stage ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// ทุกขั้นตามเวลาจริง — ขั้นที่เสร็จติ๊กเขียว ขั้นปัจจุบันจุดสด ขั้นถัดไปสีเทา
class _Timeline extends StatelessWidget {
  const _Timeline({required this.journey});
  final VisitJourney journey;

  static const _ink = Color(0xFF1A1A1A);
  static const _green = Color(0xFF1D8B6B);
  static const _gray = Color(0xFFC4CBD3);

  @override
  Widget build(BuildContext context) {
    final steps = journey.steps;
    final currentIndex = steps.lastIndexWhere((s) => s.done);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ขั้นตอนวันนี้',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++)
            _row(steps[i], i, currentIndex, i == steps.length - 1),
        ],
      ),
    );
  }

  Widget _row(VisitStep s, int i, int current, bool last) {
    final isCurrent = i == current;
    final pending = !s.done;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                s.time ?? '—',
                style: TextStyle(
                  color: pending ? _gray : _ink.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 24,
            child: Column(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: isCurrent
                      ? const Center(child: LiveDot(size: 10, color: _green))
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pending ? CupertinoColors.white : _green,
                            border: Border.all(
                              color: pending ? _gray : _green,
                              width: 2,
                            ),
                          ),
                          child: pending
                              ? null
                              : const Icon(
                                  CupertinoIcons.checkmark,
                                  size: 12,
                                  color: CupertinoColors.white,
                                ),
                        ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: i < current ? _green : _gray,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: TextStyle(
                      color: pending ? _ink.withValues(alpha: 0.4) : _ink,
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      fontVariations: [
                        FontVariation('wght', isCurrent ? 700 : 500),
                      ],
                    ),
                  ),
                  if (s.detail != null)
                    Text(
                      s.detail!,
                      style: TextStyle(
                        color: _ink.withValues(alpha: pending ? 0.3 : 0.6),
                        fontSize: 12,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
