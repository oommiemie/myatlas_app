import 'package:flutter/cupertino.dart';

enum AssessmentLevel { normal, watch, risk }

class AssessmentOption {
  const AssessmentOption({
    required this.label,
    required this.score,
    required this.emoji,
    required this.color,
  });
  final String label;
  final int score;
  final String emoji;
  final Color color;
}

class AssessmentQuestion {
  const AssessmentQuestion({required this.text, required this.options});
  final String text;
  final List<AssessmentOption> options;
}

class AssessmentBand {
  const AssessmentBand({
    required this.maxScore,
    required this.level,
    required this.label,
    required this.summary,
    required this.recommendation,
  });
  final int maxScore;
  final AssessmentLevel level;
  final String label;
  final String summary;
  final String recommendation;
}

class AssessmentConfig {
  const AssessmentConfig({
    required this.id,
    required this.title,
    required this.image,
    required this.intro,
    required this.estimatedMinutes,
    required this.questions,
    required this.bands,
  });
  final String id;
  final String title;
  final String image;
  final String intro;
  final int estimatedMinutes;
  final List<AssessmentQuestion> questions;
  final List<AssessmentBand> bands;

  int get maxScore {
    var total = 0;
    for (final q in questions) {
      var best = 0;
      for (final o in q.options) {
        if (o.score > best) best = o.score;
      }
      total += best;
    }
    return total;
  }

  AssessmentBand bandFor(int score) {
    for (final b in bands) {
      if (score <= b.maxScore) return b;
    }
    return bands.last;
  }
}

// ── Shared option sets ──────────────────────────────────────────────────────

const _frequency = <AssessmentOption>[
  AssessmentOption(
    label: 'ไม่เคยเลย',
    score: 0,
    emoji: '😌',
    color: Color(0xFF1D8B6B),
  ),
  AssessmentOption(
    label: 'นาน ๆ ครั้ง',
    score: 1,
    emoji: '🙂',
    color: Color(0xFF4CAF50),
  ),
  AssessmentOption(
    label: 'บางครั้ง',
    score: 2,
    emoji: '😐',
    color: Color(0xFFD97706),
  ),
  AssessmentOption(
    label: 'บ่อย',
    score: 3,
    emoji: '😟',
    color: Color(0xFFEA580C),
  ),
  AssessmentOption(
    label: 'ตลอดเวลา',
    score: 4,
    emoji: '😣',
    color: Color(0xFFDC2626),
  ),
];

const _yesNo = <AssessmentOption>[
  AssessmentOption(
    label: 'ไม่ใช่',
    score: 0,
    emoji: '✅',
    color: Color(0xFF1D8B6B),
  ),
  AssessmentOption(
    label: 'ใช่',
    score: 1,
    emoji: '⚠️',
    color: Color(0xFFDC2626),
  ),
];

const _adl = <AssessmentOption>[
  AssessmentOption(
    label: 'ทำเองได้',
    score: 0,
    emoji: '💪',
    color: Color(0xFF1D8B6B),
  ),
  AssessmentOption(
    label: 'ต้องมีคนช่วยบ้าง',
    score: 1,
    emoji: '🤝',
    color: Color(0xFFD97706),
  ),
  AssessmentOption(
    label: 'ทำไม่ได้',
    score: 2,
    emoji: '🚫',
    color: Color(0xFFDC2626),
  ),
];

const _severity = <AssessmentOption>[
  AssessmentOption(
    label: 'ไม่มีเลย',
    score: 0,
    emoji: '😌',
    color: Color(0xFF1D8B6B),
  ),
  AssessmentOption(
    label: 'เล็กน้อย',
    score: 1,
    emoji: '🙂',
    color: Color(0xFF4CAF50),
  ),
  AssessmentOption(
    label: 'ปานกลาง',
    score: 2,
    emoji: '😐',
    color: Color(0xFFD97706),
  ),
  AssessmentOption(
    label: 'มาก',
    score: 3,
    emoji: '😟',
    color: Color(0xFFEA580C),
  ),
  AssessmentOption(
    label: 'รุนแรง',
    score: 4,
    emoji: '😣',
    color: Color(0xFFDC2626),
  ),
];

AssessmentQuestion _q(String text) =>
    AssessmentQuestion(text: text, options: _frequency);
AssessmentQuestion _yq(String text) =>
    AssessmentQuestion(text: text, options: _yesNo);
AssessmentQuestion _aq(String text) =>
    AssessmentQuestion(text: text, options: _adl);
AssessmentQuestion _sq(String text) =>
    AssessmentQuestion(text: text, options: _severity);

// ── Configs ────────────────────────────────────────────────────────────────

const _imgBase = 'assets/images/assessment';

final Map<String, AssessmentConfig> kAssessmentConfigs = {
  // 1. Dyspnea ───────────────────────────────────────────────────────────────
  'dyspnea': AssessmentConfig(
    id: 'dyspnea',
    title: 'เกณฑ์การให้คะแนนภาวะหายใจลำบาก',
    image: '$_imgBase/dyspnea.png',
    intro:
        'ตอบคำถาม 6 ข้อสั้น ๆ เกี่ยวกับการหายใจในชีวิตประจำวันของคุณ',
    estimatedMinutes: 5,
    questions: [
      _q('คุณรู้สึกเหนื่อยขณะเดินบนพื้นราบบ่อยแค่ไหน?'),
      _q('คุณรู้สึกเหนื่อยเมื่อขึ้นบันได 1-2 ชั้นบ่อยแค่ไหน?'),
      _q('คุณต้องหยุดพักหายใจระหว่างทำกิจวัตรประจำวันบ่อยแค่ไหน?'),
      _q('คุณรู้สึกหายใจไม่ทันตอนกลางคืนบ่อยแค่ไหน?'),
      _q('คุณรู้สึกแน่นหน้าอกเมื่อตื่นเช้าบ่อยแค่ไหน?'),
      _q('อาการหายใจลำบากรบกวนชีวิตประจำวันบ่อยแค่ไหน?'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 6,
        level: AssessmentLevel.normal,
        label: 'ปกติ',
        summary:
            'การหายใจของคุณอยู่ในเกณฑ์ปกติ ไม่พบสัญญาณของภาวะหายใจลำบากที่น่ากังวล ระบบทางเดินหายใจทำงานได้ดีในชีวิตประจำวัน',
        recommendation:
            'ออกกำลังกายเบา ๆ สม่ำเสมอ เช่น เดินเร็ว 30 นาที/วัน หลีกเลี่ยงควันบุหรี่และฝุ่น PM2.5 หมั่นสังเกตอาการและกลับมาประเมินซ้ำในอีก 3 เดือน',
      ),
      AssessmentBand(
        maxScore: 15,
        level: AssessmentLevel.watch,
        label: 'ควรเฝ้าระวัง',
        summary:
            'พบสัญญาณของภาวะหายใจลำบากในระดับเล็กน้อยถึงปานกลาง อาจรบกวนกิจวัตรประจำวันบางช่วง',
        recommendation:
            'หลีกเลี่ยงสิ่งกระตุ้น เช่น ควันบุหรี่ ฝุ่น ออกกำลังกายเบา ๆ ฝึกหายใจเข้า-ออกลึก หากอาการไม่ดีขึ้นใน 2 สัปดาห์ ควรพบแพทย์เพื่อตรวจเพิ่มเติม',
      ),
      AssessmentBand(
        maxScore: 24,
        level: AssessmentLevel.risk,
        label: 'เสี่ยงสูง',
        summary:
            'พบอาการหายใจลำบากในระดับที่อาจกระทบต่อสุขภาพอย่างชัดเจน ควรเข้ารับการตรวจประเมินโดยแพทย์เพื่อหาสาเหตุและวางแผนการรักษา',
        recommendation:
            'แนะนำให้พบแพทย์โดยเร็วเพื่อตรวจสมรรถภาพปอดและระบบหัวใจ ระหว่างนี้ควรพักผ่อนและหลีกเลี่ยงการออกแรงหนัก หากมีอาการเฉียบพลัน เช่น เจ็บหน้าอก ริมฝีปากเขียว ให้ไป ER ทันที',
      ),
    ],
  ),

  // 2. Asthma control ──────────────────────────────────────────────────────
  'asthma': AssessmentConfig(
    id: 'asthma',
    title: 'ประเมินการควบคุมโรคหืด',
    image: '$_imgBase/asthma.png',
    intro:
        'คำถามเดียวสั้น ๆ ช่วยประเมินว่าอาการหืดของคุณถูกควบคุมดีเพียงใด',
    estimatedMinutes: 1,
    questions: [
      AssessmentQuestion(
        text: 'ใน 4 สัปดาห์ที่ผ่านมา อาการหืดของคุณควบคุมได้ดีแค่ไหน?',
        options: [
          AssessmentOption(
            label: 'ควบคุมได้ดีมาก',
            score: 0,
            emoji: '🌿',
            color: Color(0xFF1D8B6B),
          ),
          AssessmentOption(
            label: 'ควบคุมได้ดี',
            score: 1,
            emoji: '🙂',
            color: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'ควบคุมได้บางส่วน',
            score: 2,
            emoji: '😐',
            color: Color(0xFFD97706),
          ),
          AssessmentOption(
            label: 'ควบคุมไม่ได้',
            score: 3,
            emoji: '😣',
            color: Color(0xFFDC2626),
          ),
        ],
      ),
    ],
    bands: [
      AssessmentBand(
        maxScore: 0,
        level: AssessmentLevel.normal,
        label: 'ควบคุมได้ดี',
        summary: 'อาการหืดของคุณถูกควบคุมได้ดีในช่วงที่ผ่านมา',
        recommendation:
            'ใช้ยาตามแพทย์สั่งสม่ำเสมอ หลีกเลี่ยงสิ่งกระตุ้น ตรวจสุขภาพประจำปีตามนัด',
      ),
      AssessmentBand(
        maxScore: 1,
        level: AssessmentLevel.watch,
        label: 'ควรเฝ้าระวัง',
        summary:
            'อาการหืดยังคงควบคุมได้ดี แต่อาจมีอาการเล็กน้อยเป็นครั้งคราว',
        recommendation:
            'ตรวจสอบเทคนิคการใช้ยาพ่นให้ถูกวิธี บันทึกอาการและสิ่งกระตุ้น ปรึกษาแพทย์หากอาการเปลี่ยนแปลง',
      ),
      AssessmentBand(
        maxScore: 3,
        level: AssessmentLevel.risk,
        label: 'ควบคุมไม่เพียงพอ',
        summary:
            'พบว่าอาการหืดยังควบคุมไม่เพียงพอ ต้องการการทบทวนแผนการรักษา',
        recommendation:
            'ควรพบแพทย์ทันทีเพื่อปรับยา ตรวจสอบอาการกำเริบ และวางแผนการจัดการอาการ',
      ),
    ],
  ),

  // 3. Cardiovascular risk ─────────────────────────────────────────────────
  'cv-risk': AssessmentConfig(
    id: 'cv-risk',
    title: 'ประเมินความเสี่ยงโรคหัวใจและหลอดเลือด',
    image: '$_imgBase/cv-risk.png',
    intro:
        'คำถามเดียวสั้น ๆ เกี่ยวกับอาการทางหัวใจที่พบในช่วงที่ผ่านมา',
    estimatedMinutes: 1,
    questions: [
      AssessmentQuestion(
        text:
            'ใน 1 เดือนที่ผ่านมา คุณมีอาการเจ็บหน้าอก/ใจสั่น/เหนื่อยผิดปกติบ่อยแค่ไหน?',
        options: [
          AssessmentOption(
            label: 'ไม่มีเลย',
            score: 0,
            emoji: '❤️',
            color: Color(0xFF1D8B6B),
          ),
          AssessmentOption(
            label: 'นาน ๆ ครั้ง',
            score: 1,
            emoji: '🙂',
            color: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'บ่อยครั้ง',
            score: 2,
            emoji: '😟',
            color: Color(0xFFEA580C),
          ),
          AssessmentOption(
            label: 'ทุกวัน',
            score: 3,
            emoji: '😣',
            color: Color(0xFFDC2626),
          ),
        ],
      ),
    ],
    bands: [
      AssessmentBand(
        maxScore: 0,
        level: AssessmentLevel.normal,
        label: 'ปกติ',
        summary:
            'ไม่พบอาการที่บ่งชี้ความเสี่ยงโรคหัวใจและหลอดเลือดในช่วงที่ผ่านมา',
        recommendation:
            'ดูแลสุขภาพหัวใจด้วยการออกกำลังกาย 150 นาที/สัปดาห์ กินอาหารที่มีไขมันดี ตรวจความดันและไขมันในเลือดประจำปี',
      ),
      AssessmentBand(
        maxScore: 1,
        level: AssessmentLevel.watch,
        label: 'ควรเฝ้าระวัง',
        summary:
            'มีอาการเล็กน้อยที่อาจเชื่อมโยงกับระบบหัวใจและหลอดเลือด',
        recommendation:
            'บันทึกอาการ ลดความเครียด ออกกำลังกายสม่ำเสมอ ตรวจคลื่นไฟฟ้าหัวใจและไขมันในเลือดใน 3 เดือน',
      ),
      AssessmentBand(
        maxScore: 3,
        level: AssessmentLevel.risk,
        label: 'เสี่ยงสูง',
        summary:
            'พบอาการที่น่ากังวลเกี่ยวกับระบบหัวใจและหลอดเลือดบ่อยครั้ง',
        recommendation:
            'ควรพบแพทย์โรคหัวใจโดยเร็ว เพื่อทำ EKG/Echo/Exercise Stress Test หากเกิดเจ็บหน้าอกเฉียบพลัน มึนงง หรือเหงื่อแตกให้ไป ER ทันที',
      ),
    ],
  ),

  // 4. Blood pressure risk ─────────────────────────────────────────────────
  'bp-risk': AssessmentConfig(
    id: 'bp-risk',
    title: 'ประเมินความเสี่ยงโรคความดันโลหิต',
    image: '$_imgBase/bp-risk.png',
    intro: 'ตอบ "ใช่" หรือ "ไม่ใช่" 6 ข้อ เพื่อประเมินความเสี่ยงของคุณ',
    estimatedMinutes: 5,
    questions: [
      _yq('คุณมีอายุมากกว่า 40 ปีหรือไม่?'),
      _yq('คนในครอบครัว (พ่อแม่ พี่น้อง) มีความดันโลหิตสูงหรือไม่?'),
      _yq('คุณสูบบุหรี่หรือดื่มแอลกอฮอล์เป็นประจำหรือไม่?'),
      _yq('คุณกินอาหารเค็มหรือรสจัดเป็นประจำหรือไม่?'),
      _yq('คุณเครียดหรือนอนน้อยกว่า 6 ชั่วโมงเป็นประจำหรือไม่?'),
      _yq('คุณออกกำลังกายน้อยกว่า 150 นาที/สัปดาห์หรือไม่?'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 1,
        level: AssessmentLevel.normal,
        label: 'ความเสี่ยงต่ำ',
        summary: 'ปัจจัยเสี่ยงต่อความดันโลหิตสูงของคุณอยู่ในระดับต่ำ',
        recommendation:
            'รักษาพฤติกรรมปัจจุบัน ตรวจความดันโลหิตปีละครั้ง บริโภคโซเดียมไม่เกิน 2,000 มก./วัน',
      ),
      AssessmentBand(
        maxScore: 3,
        level: AssessmentLevel.watch,
        label: 'ความเสี่ยงปานกลาง',
        summary:
            'พบปัจจัยเสี่ยงบางอย่างที่อาจนำไปสู่ความดันโลหิตสูงในอนาคต',
        recommendation:
            'ปรับพฤติกรรม ลดอาหารเค็ม งดบุหรี่ ออกกำลังกายสม่ำเสมอ ตรวจความดันโลหิตทุก 3-6 เดือน',
      ),
      AssessmentBand(
        maxScore: 6,
        level: AssessmentLevel.risk,
        label: 'ความเสี่ยงสูง',
        summary:
            'มีปัจจัยเสี่ยงสะสมหลายข้อ ควรได้รับการตรวจและติดตามความดันโลหิตอย่างใกล้ชิด',
        recommendation:
            'พบแพทย์เพื่อตรวจความดัน ไขมันในเลือด และการทำงานของไต ปรับพฤติกรรมอย่างจริงจังและติดตามทุก 1-3 เดือน',
      ),
    ],
  ),

  // 5. Diabetes risk ───────────────────────────────────────────────────────
  'diabetes-risk': AssessmentConfig(
    id: 'diabetes-risk',
    title: 'ประเมินความเสี่ยงโรคเบาหวาน',
    image: '$_imgBase/diabetes-risk.png',
    intro: 'ตอบ "ใช่" หรือ "ไม่ใช่" 6 ข้อ เกี่ยวกับปัจจัยเสี่ยงเบาหวาน',
    estimatedMinutes: 5,
    questions: [
      _yq('คุณมีอายุมากกว่า 45 ปีหรือไม่?'),
      _yq('พ่อแม่ พี่น้องของคุณเป็นเบาหวานหรือไม่?'),
      _yq('ดัชนีมวลกาย (BMI) ของคุณมากกว่า 25 หรือรอบเอวเกินเกณฑ์หรือไม่?'),
      _yq('คุณรู้สึกหิวน้ำบ่อยหรือปัสสาวะบ่อยกว่าปกติหรือไม่?'),
      _yq('คุณเหนื่อยง่าย หิวบ่อย หรือหิวหลังมื้ออาหารเร็วกว่าปกติหรือไม่?'),
      _yq('คุณออกกำลังกายน้อยกว่า 3 ครั้ง/สัปดาห์หรือไม่?'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 1,
        level: AssessmentLevel.normal,
        label: 'ความเสี่ยงต่ำ',
        summary: 'ปัจจัยเสี่ยงเบาหวานของคุณอยู่ในระดับต่ำ',
        recommendation:
            'รักษาพฤติกรรมสุขภาพ ตรวจระดับน้ำตาลในเลือดปีละครั้ง กินผักผลไม้ให้หลากหลาย',
      ),
      AssessmentBand(
        maxScore: 3,
        level: AssessmentLevel.watch,
        label: 'ความเสี่ยงปานกลาง',
        summary:
            'พบปัจจัยเสี่ยงบางอย่างที่ควรปรับเปลี่ยนเพื่อป้องกันเบาหวาน',
        recommendation:
            'ลดน้ำตาลและแป้งขัดสี เพิ่มการเคลื่อนไหว ตรวจน้ำตาลในเลือดทุก 6 เดือน ควบคุมน้ำหนักให้อยู่ในเกณฑ์',
      ),
      AssessmentBand(
        maxScore: 6,
        level: AssessmentLevel.risk,
        label: 'ความเสี่ยงสูง',
        summary:
            'มีปัจจัยเสี่ยงหลายข้อ ควรตรวจคัดกรองและติดตามน้ำตาลในเลือดอย่างใกล้ชิด',
        recommendation:
            'พบแพทย์เพื่อตรวจ FBS / HbA1c วางแผนควบคุมน้ำหนักและโภชนาการ ออกกำลังกายแบบคาร์ดิโอ 150 นาที/สัปดาห์',
      ),
    ],
  ),

  // 6. Mental health (PHQ-like) ────────────────────────────────────────────
  'mental': AssessmentConfig(
    id: 'mental',
    title: 'ประเมินสุขภาพจิต',
    image: '$_imgBase/mental.png',
    intro:
        'ใน 2 สัปดาห์ที่ผ่านมา คุณมีอาการต่อไปนี้บ่อยเพียงใด? ตอบเพียง 6 ข้อสั้น ๆ',
    estimatedMinutes: 5,
    questions: [
      _q('รู้สึกเบื่อ ไม่สนุก หรือไม่อยากทำสิ่งที่เคยชอบ'),
      _q('รู้สึกเศร้า ซึมเซา หรือสิ้นหวัง'),
      _q('นอนไม่หลับ หรือหลับมากเกินไป'),
      _q('รู้สึกเหนื่อยล้าและไม่มีเรี่ยวแรง'),
      _q('รู้สึกกินน้อย หรือกินมากผิดปกติ'),
      _q('รู้สึกว่าตัวเองไร้ค่า หรือเป็นภาระต่อคนอื่น'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 4,
        level: AssessmentLevel.normal,
        label: 'ปกติ',
        summary:
            'สุขภาพจิตของคุณอยู่ในเกณฑ์ดี ไม่พบสัญญาณของภาวะซึมเศร้าที่น่ากังวล',
        recommendation:
            'รักษาสมดุลชีวิต พักผ่อน ทำกิจกรรมที่ชอบ พบปะเพื่อน ๆ ฝึกหายใจหรือสมาธิ 10 นาที/วัน',
      ),
      AssessmentBand(
        maxScore: 14,
        level: AssessmentLevel.watch,
        label: 'เริ่มมีสัญญาณเครียด',
        summary:
            'พบสัญญาณของความเครียดหรือซึมเศร้าระดับเล็กน้อยถึงปานกลาง อาจกระทบต่อการใช้ชีวิตในบางด้าน',
        recommendation:
            'พูดคุยกับคนที่ไว้วางใจ จัดเวลาพักและทำกิจกรรมที่ผ่อนคลาย หากอาการต่อเนื่องเกิน 2 สัปดาห์ แนะนำปรึกษาสายด่วนสุขภาพจิต 1323 หรือนักจิตวิทยา',
      ),
      AssessmentBand(
        maxScore: 24,
        level: AssessmentLevel.risk,
        label: 'เสี่ยงซึมเศร้า',
        summary:
            'พบสัญญาณภาวะซึมเศร้าในระดับที่ควรได้รับการประเมินและดูแลโดยผู้เชี่ยวชาญ',
        recommendation:
            'แนะนำพบจิตแพทย์หรือนักจิตวิทยาโดยเร็ว หากมีความคิดทำร้ายตัวเอง โปรดโทร 1323 ทันที คุณไม่ต้องเผชิญเรื่องนี้คนเดียว',
      ),
    ],
  ),

  // 7. ADL ─────────────────────────────────────────────────────────────────
  'adl': AssessmentConfig(
    id: 'adl',
    title: 'แบบประเมินกิจวัตรประจำวัน ADL',
    image: '$_imgBase/adl.png',
    intro:
        'ประเมินความสามารถในการทำกิจวัตรประจำวัน 6 ด้านหลัก ตอบตามความเป็นจริง',
    estimatedMinutes: 5,
    questions: [
      _aq('การรับประทานอาหาร'),
      _aq('การอาบน้ำและทำความสะอาดร่างกาย'),
      _aq('การแต่งตัว/เปลี่ยนเสื้อผ้า'),
      _aq('การเดินหรือเคลื่อนย้ายในบ้าน'),
      _aq('การใช้ห้องน้ำ'),
      _aq('การลุก/ย้ายจากเตียงไปยังเก้าอี้'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 2,
        level: AssessmentLevel.normal,
        label: 'ช่วยเหลือตัวเองได้ดี',
        summary:
            'คุณช่วยเหลือตัวเองในกิจวัตรประจำวันได้เป็นอย่างดี ไม่ต้องพึ่งพาผู้อื่น',
        recommendation:
            'ดูแลสุขภาพต่อเนื่อง ออกกำลังกายเพื่อรักษาความแข็งแรงของกล้ามเนื้อ ป้องกันการหกล้ม',
      ),
      AssessmentBand(
        maxScore: 7,
        level: AssessmentLevel.watch,
        label: 'ต้องการความช่วยเหลือบางส่วน',
        summary:
            'คุณต้องพึ่งพาผู้อื่นในบางกิจวัตร ควรได้รับการดูแลใกล้ชิดในบางกิจกรรม',
        recommendation:
            'ฝึกกายภาพบำบัดและการทรงตัว จัดสภาพแวดล้อมในบ้านให้ปลอดภัย มีราวจับ/พื้นกันลื่น ปรึกษานักกายภาพเพื่อวางแผนฟื้นฟู',
      ),
      AssessmentBand(
        maxScore: 12,
        level: AssessmentLevel.risk,
        label: 'ต้องการการดูแลเต็มที่',
        summary:
            'คุณต้องการความช่วยเหลือในกิจวัตรประจำวันส่วนใหญ่ ควรมีผู้ดูแลใกล้ชิด',
        recommendation:
            'ปรึกษาทีมแพทย์และนักกายภาพบำบัดเพื่อวางแผนดูแลระยะยาว พิจารณาเครื่องช่วยเดินหรือเตียงพิเศษ ติดต่อบริการดูแลผู้สูงอายุในชุมชน',
      ),
    ],
  ),

  // 8. INHOMESSS ───────────────────────────────────────────────────────────
  'inhomesss': AssessmentConfig(
    id: 'inhomesss',
    title: 'แบบประเมิน INHOMESSS (สภาพบ้าน)',
    image: '$_imgBase/inhomesss.png',
    intro:
        'ประเมินความปลอดภัยและความเหมาะสมของสภาพบ้านสำหรับผู้อยู่อาศัย',
    estimatedMinutes: 5,
    questions: [
      _yq('มีอุปสรรคในการเดินในบ้าน เช่น พื้นขรุขระ พรมหลุด สายไฟระเกะระกะ?'),
      _yq('โภชนาการในบ้านไม่ครบถ้วน/ขาดผัก-ผลไม้?'),
      _yq('ห้องน้ำไม่มีราวจับหรือพื้นลื่น?'),
      _yq('รับประทานยาเองโดยไม่มีผู้ตรวจทาน?'),
      _yq('อยู่บ้านคนเดียวโดยไม่มีคนคอยดูแล?'),
      _yq('ขาดระบบเตือนภัย เช่น สัญญาณเตือนไฟไหม้ หรือไม่สามารถติดต่อฉุกเฉินได้?'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 1,
        level: AssessmentLevel.normal,
        label: 'สภาพบ้านเหมาะสม',
        summary:
            'สภาพบ้านโดยรวมปลอดภัยและเหมาะสมกับผู้อยู่อาศัย ความเสี่ยงน้อย',
        recommendation:
            'คงสภาพปัจจุบัน ตรวจสอบระบบเตือนภัยและไฟฟ้าปีละครั้ง เตรียมหมายเลขฉุกเฉินไว้ใกล้มือ',
      ),
      AssessmentBand(
        maxScore: 3,
        level: AssessmentLevel.watch,
        label: 'มีจุดที่ควรปรับ',
        summary:
            'พบจุดเสี่ยงบางจุดที่ควรแก้ไขเพื่อความปลอดภัยของผู้อยู่อาศัย',
        recommendation:
            'ปรับสภาพแวดล้อม เช่น ติดราวจับห้องน้ำ เพิ่มไฟฟ้าส่องสว่าง เก็บสายไฟ/พรมให้เรียบร้อย ดูแลโภชนาการให้ครบหมู่',
      ),
      AssessmentBand(
        maxScore: 6,
        level: AssessmentLevel.risk,
        label: 'เสี่ยงสูง',
        summary:
            'สภาพบ้านมีจุดเสี่ยงหลายข้อที่อาจส่งผลต่อความปลอดภัยและสุขภาพของผู้อยู่อาศัย',
        recommendation:
            'ปรึกษานักสังคมสงเคราะห์หรือ อสม. ประจำพื้นที่เพื่อวางแผนปรับสภาพบ้าน พิจารณาติดตั้งระบบฉุกเฉินและหาผู้ดูแลร่วม',
      ),
    ],
  ),

  // 9. Palliative ──────────────────────────────────────────────────────────
  'palliative': AssessmentConfig(
    id: 'palliative',
    title: 'แบบประเมินผู้ป่วย Palliative Care',
    image: '$_imgBase/palliative.png',
    intro:
        'ประเมินอาการทางกาย/ใจ 6 ด้าน เพื่อวางแผนดูแลประคับประคอง',
    estimatedMinutes: 5,
    questions: [
      _sq('ความเจ็บปวดที่รู้สึก'),
      _sq('ความเหนื่อยอ่อน'),
      _sq('คลื่นไส้/เบื่ออาหาร'),
      _sq('ความวิตกกังวล'),
      _sq('หายใจลำบาก'),
      _sq('ภาวะซึมเศร้า/เศร้าใจ'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 6,
        level: AssessmentLevel.normal,
        label: 'อาการคุมได้ดี',
        summary:
            'อาการโดยรวมอยู่ในระดับที่จัดการได้ ไม่กระทบคุณภาพชีวิตมากนัก',
        recommendation:
            'ดูแลตามแผนเดิม ติดตามอาการเป็นประจำ พูดคุยกับทีมแพทย์หากอาการใดเปลี่ยนแปลง',
      ),
      AssessmentBand(
        maxScore: 14,
        level: AssessmentLevel.watch,
        label: 'ต้องปรับการดูแล',
        summary:
            'พบอาการในระดับปานกลาง ควรทบทวนแผนการดูแลเพื่อบรรเทาอาการ',
        recommendation:
            'ปรึกษาทีมดูแลประคับประคองเพื่อปรับยาและการพยาบาล ใช้เทคนิคผ่อนคลายหรือ mindfulness ช่วยเสริม',
      ),
      AssessmentBand(
        maxScore: 24,
        level: AssessmentLevel.risk,
        label: 'ต้องการการดูแลเร่งด่วน',
        summary:
            'อาการรุนแรงส่งผลต่อคุณภาพชีวิตและคนดูแล ควรได้รับการประเมินโดยทีมผู้เชี่ยวชาญ',
        recommendation:
            'แจ้งทีมแพทย์/พยาบาลประจำเพื่อเยี่ยมบ้านหรือปรับแผนการรักษาโดยเร็ว พิจารณาเข้าสถานพยาบาลหากอาการไม่ดีขึ้น',
      ),
    ],
  ),

  // 10. Crisis (IES-R spirit) ──────────────────────────────────────────────
  'crisis': AssessmentConfig(
    id: 'crisis',
    title: 'แบบประเมินผู้ประสบภาวะวิกฤต',
    image: '$_imgBase/crisis.png',
    intro:
        'ใน 1 สัปดาห์ที่ผ่านมา คุณมีอาการต่อไปนี้บ่อยเพียงใด?',
    estimatedMinutes: 5,
    questions: [
      _q('ภาพเหตุการณ์ผุดขึ้นมาในความคิดหรือฝันร้าย'),
      _q('หลีกเลี่ยงการพูดคุยหรือนึกถึงเหตุการณ์'),
      _q('รู้สึกตกใจง่ายหรือระแวง'),
      _q('รู้สึกหดหู่หรือไร้ความหวัง'),
      _q('สมาธิลดลง ทำงานหรือเรียนได้ยากขึ้น'),
      _q('ขาดการติดต่อกับเพื่อนหรือครอบครัว'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 6,
        level: AssessmentLevel.normal,
        label: 'ปรับตัวได้ดี',
        summary:
            'คุณกำลังฟื้นตัวจากเหตุการณ์ได้ดี มีอาการน้อยและจัดการได้',
        recommendation:
            'รักษากิจวัตรปกติ พูดคุยกับคนที่ไว้วางใจ ฝึกหายใจและออกกำลังกายเพื่อคลายเครียด',
      ),
      AssessmentBand(
        maxScore: 15,
        level: AssessmentLevel.watch,
        label: 'ยังต้องการการดูแล',
        summary:
            'มีสัญญาณของภาวะเครียดหลังเหตุการณ์ในระดับปานกลาง ควรหาแหล่งสนับสนุน',
        recommendation:
            'เข้าร่วมกลุ่มพูดคุยหรือพบนักจิตวิทยาเพื่อบำบัดระยะสั้น ลดการใช้สื่อที่กระตุ้นความทรงจำ',
      ),
      AssessmentBand(
        maxScore: 24,
        level: AssessmentLevel.risk,
        label: 'เสี่ยง PTSD',
        summary:
            'อาการรุนแรงส่งผลกระทบต่อชีวิตประจำวัน ควรได้รับการประเมินเรื่องภาวะ PTSD',
        recommendation:
            'พบจิตแพทย์หรือนักจิตวิทยาคลินิกโดยเร็ว หากมีความคิดทำร้ายตัวเอง โปรดโทรสายด่วน 1323 ทันที',
      ),
    ],
  ),

  // 11. Screening 35+ ──────────────────────────────────────────────────────
  'screen-35': AssessmentConfig(
    id: 'screen-35',
    title: 'แบบคัดกรองภาวะเสี่ยง 35 ปีขึ้นไป',
    image: '$_imgBase/screen-35.png',
    intro: 'ประเมินความเสี่ยงโรคเรื้อรังสำหรับผู้อายุ 35 ปีขึ้นไป',
    estimatedMinutes: 5,
    questions: [
      _yq('คุณสูบบุหรี่หรือเคยสูบในช่วง 1 ปีที่ผ่านมาหรือไม่?'),
      _yq('ดื่มแอลกอฮอล์มากกว่า 2 แก้ว/วันหรือไม่?'),
      _yq('ค่า BMI ของคุณมากกว่า 25 หรือไม่?'),
      _yq('คนในครอบครัวเป็นเบาหวาน ความดันสูง หรือโรคหัวใจหรือไม่?'),
      _yq('ออกกำลังกายน้อยกว่า 3 ครั้ง/สัปดาห์?'),
      _yq('ตรวจสุขภาพครั้งล่าสุดเกิน 1 ปีแล้วหรือยัง?'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 1,
        level: AssessmentLevel.normal,
        label: 'ความเสี่ยงต่ำ',
        summary: 'ปัจจัยเสี่ยงของคุณโดยรวมอยู่ในเกณฑ์ดี',
        recommendation:
            'ตรวจสุขภาพประจำปี รักษาพฤติกรรมสุขภาพดีต่อเนื่อง โภชนาการครบถ้วน นอนเพียงพอ',
      ),
      AssessmentBand(
        maxScore: 3,
        level: AssessmentLevel.watch,
        label: 'ควรเฝ้าระวัง',
        summary:
            'พบปัจจัยเสี่ยงบางข้อที่ควรปรับเปลี่ยนเพื่อป้องกันโรคเรื้อรัง',
        recommendation:
            'ปรับพฤติกรรม เริ่มออกกำลังกาย ลดบุหรี่/แอลกอฮอล์ คุมน้ำหนัก ตรวจสุขภาพประจำปี',
      ),
      AssessmentBand(
        maxScore: 6,
        level: AssessmentLevel.risk,
        label: 'ความเสี่ยงสูง',
        summary:
            'มีปัจจัยเสี่ยงสะสมหลายข้อ ควรได้รับการตรวจคัดกรองโรคเรื้อรังโดยแพทย์',
        recommendation:
            'นัดพบแพทย์เพื่อตรวจคัดกรองเบาหวาน ความดัน ไขมัน และโรคหัวใจ วางแผนปรับพฤติกรรมอย่างเป็นระบบ',
      ),
    ],
  ),

  // 12. ESAS ───────────────────────────────────────────────────────────────
  'esas': AssessmentConfig(
    id: 'esas',
    title: 'แบบประเมิน ESAS',
    image: '$_imgBase/esas.png',
    intro:
        'Edmonton Symptom Assessment — ประเมินระดับอาการ 6 ด้านในช่วงวันนี้',
    estimatedMinutes: 5,
    questions: [
      _sq('ความเจ็บปวด'),
      _sq('ความเหนื่อยล้า'),
      _sq('คลื่นไส้'),
      _sq('ภาวะซึมเศร้า'),
      _sq('ความวิตกกังวล'),
      _sq('ความเบื่ออาหาร'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 6,
        level: AssessmentLevel.normal,
        label: 'อาการเบา',
        summary:
            'อาการโดยรวมอยู่ในระดับเบา สามารถจัดการได้ด้วยตนเองหรือแผนเดิม',
        recommendation:
            'ติดตามอาการเป็นประจำ บันทึกการเปลี่ยนแปลง แจ้งทีมแพทย์หากอาการใดรุนแรงขึ้น',
      ),
      AssessmentBand(
        maxScore: 14,
        level: AssessmentLevel.watch,
        label: 'อาการปานกลาง',
        summary: 'บางอาการอยู่ในระดับปานกลาง ควรปรึกษาทีมผู้ดูแลเพื่อปรับการรักษา',
        recommendation:
            'ทบทวนยาและวิธีบรรเทากับทีมแพทย์/พยาบาล เสริมเทคนิคผ่อนคลาย เช่น สมาธิ นวด อบอุ่นร่างกาย',
      ),
      AssessmentBand(
        maxScore: 24,
        level: AssessmentLevel.risk,
        label: 'อาการรุนแรง',
        summary:
            'อาการรุนแรงหลายด้าน กระทบต่อคุณภาพชีวิตอย่างชัดเจน',
        recommendation:
            'ติดต่อทีมแพทย์/พยาบาลประจำโดยเร็ว เพื่อประเมินและปรับแผนการรักษา อาจต้องเข้ารับการดูแลที่สถานพยาบาล',
      ),
    ],
  ),

  // 13. Barthel Index ──────────────────────────────────────────────────────
  'barthel': AssessmentConfig(
    id: 'barthel',
    title: 'แบบประเมิน Barthel Index',
    image: '$_imgBase/barthel.png',
    intro: 'ประเมินความสามารถในการช่วยเหลือตัวเอง 6 ด้านหลัก',
    estimatedMinutes: 5,
    questions: [
      _aq('การควบคุมการขับถ่ายปัสสาวะ'),
      _aq('การควบคุมการขับถ่ายอุจจาระ'),
      _aq('การล้างหน้า แปรงฟัน หวีผม'),
      _aq('การใช้ห้องน้ำ'),
      _aq('การเดิน/ใช้รถเข็น'),
      _aq('การขึ้นลงบันได'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 2,
        level: AssessmentLevel.normal,
        label: 'พึ่งพาตัวเองได้',
        summary: 'คุณช่วยเหลือตัวเองได้เกือบทุกกิจวัตร ความจำเป็นต้องพึ่งพาต่ำ',
        recommendation:
            'คงความสามารถไว้ด้วยการออกกำลังกายและกายภาพบำบัดเบา ๆ ป้องกันการหกล้ม',
      ),
      AssessmentBand(
        maxScore: 7,
        level: AssessmentLevel.watch,
        label: 'ต้องการความช่วยเหลือบางส่วน',
        summary:
            'ต้องพึ่งพาผู้อื่นในบางกิจกรรม ควรมีแผนการฟื้นฟูและปรับสภาพแวดล้อม',
        recommendation:
            'ฝึกกายภาพบำบัดต่อเนื่อง จัดห้องน้ำและทางเดินให้ปลอดภัย ใช้อุปกรณ์ช่วย เช่น walker หากจำเป็น',
      ),
      AssessmentBand(
        maxScore: 12,
        level: AssessmentLevel.risk,
        label: 'ต้องการการดูแลเต็มรูปแบบ',
        summary:
            'ไม่สามารถช่วยเหลือตัวเองในกิจวัตรส่วนใหญ่ ต้องมีผู้ดูแลใกล้ชิด',
        recommendation:
            'วางแผนการดูแลระยะยาวกับทีมแพทย์/พยาบาล จัดหาเครื่องช่วยและผู้ดูแลประจำ ปรึกษาบริการดูแลผู้สูงอายุในชุมชน',
      ),
    ],
  ),

  // 14. Caregiver burden ───────────────────────────────────────────────────
  'caregiver': AssessmentConfig(
    id: 'caregiver',
    title: 'แบบประเมินภาระการดูแลผู้ป่วยที่บ้าน',
    image: '$_imgBase/dyspnea.png',
    intro:
        'สำหรับผู้ดูแล — ประเมินภาระจากการดูแลผู้ป่วยใน 1 เดือนที่ผ่านมา',
    estimatedMinutes: 5,
    questions: [
      _q('คุณรู้สึกว่าการดูแลใช้เวลามากจนกระทบชีวิตส่วนตัว'),
      _q('คุณรู้สึกเหนื่อยล้าหรือหมดเรี่ยวแรง'),
      _q('คุณรู้สึกเครียดเมื่ออยู่กับผู้ป่วย'),
      _q('คุณรู้สึกโดดเดี่ยวหรือขาดคนช่วยแบ่งเบา'),
      _q('คุณกังวลเกี่ยวกับอนาคตการดูแล'),
      _q('คุณรู้สึกว่าสุขภาพของตัวเองแย่ลงตั้งแต่เริ่มดูแล'),
    ],
    bands: [
      AssessmentBand(
        maxScore: 6,
        level: AssessmentLevel.normal,
        label: 'ภาระน้อย',
        summary:
            'คุณจัดการภาระการดูแลได้ดี ยังรักษาสมดุลชีวิตของตัวเองได้',
        recommendation:
            'รักษาสมดุลชีวิต หาเวลาพักผ่อนและทำกิจกรรมของตัวเอง เข้าร่วมกลุ่มสนับสนุนผู้ดูแลเป็นครั้งคราว',
      ),
      AssessmentBand(
        maxScore: 15,
        level: AssessmentLevel.watch,
        label: 'เริ่มแบกรับภาระหนัก',
        summary:
            'ภาระในการดูแลเริ่มส่งผลต่อชีวิตและสุขภาพของคุณ ควรจัดการก่อนจะลุกลาม',
        recommendation:
            'แบ่งงานกับสมาชิกในครอบครัวหรือหาผู้ช่วย ใช้บริการดูแลชั่วคราว (respite care) เพื่อพักผ่อน พบแพทย์เพื่อดูแลสุขภาพตัวเอง',
      ),
      AssessmentBand(
        maxScore: 24,
        level: AssessmentLevel.risk,
        label: 'ภาวะหมดไฟสูง',
        summary:
            'คุณมีภาวะเสี่ยงหมดไฟจากการดูแลสูง ส่งผลต่อสุขภาพกายและใจ',
        recommendation:
            'ติดต่อขอความช่วยเหลือจากหน่วยบริการสุขภาพในพื้นที่ เข้าร่วมกลุ่มสนับสนุน หาเวลาพบจิตแพทย์/นักจิตวิทยาเพื่อดูแลจิตใจตนเอง คุณสำคัญเท่ากับผู้ที่ดูแล',
      ),
    ],
  ),
};
