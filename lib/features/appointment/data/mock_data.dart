import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum AppointmentBucket { soon, week, month }

extension AppointmentBucketLabel on AppointmentBucket {
  String get label {
    switch (this) {
      case AppointmentBucket.soon:
        return 'เร็วๆนี้';
      case AppointmentBucket.week:
        return '1 สัปดาห์';
      case AppointmentBucket.month:
        return '1 เดือน';
    }
  }
}

enum AppointmentTagKind { track, visit }

extension AppointmentTagKindUI on AppointmentTagKind {
  String get label {
    switch (this) {
      case AppointmentTagKind.track:
        return 'ติดตามอาการ';
      case AppointmentTagKind.visit:
        return 'เยี่ยมตามนัด';
    }
  }
}

class HomeVisitDetail {
  final String staffName;
  final String sendReason;
  final String objective;
  final String healthProblem;
  final String medicalInfo;
  final List<MapEntry<String, String>> socialInfo;
  final List<MapEntry<String, String>> visitNotes;

  const HomeVisitDetail({
    required this.staffName,
    required this.sendReason,
    required this.objective,
    required this.healthProblem,
    required this.medicalInfo,
    required this.socialInfo,
    required this.visitNotes,
  });
}

class AppointmentItem {
  final DateTime date;
  final String time;
  final String title;
  final String subLeft;
  final String subRight;
  final List<Color> gradient;
  final AppointmentTagKind tag;
  final Color tagTextColor;
  final List<String> preparation;
  final HomeVisitDetail? homeVisitDetail;

  const AppointmentItem({
    required this.date,
    required this.time,
    required this.title,
    required this.subLeft,
    required this.subRight,
    required this.gradient,
    required this.tag,
    required this.tagTextColor,
    this.preparation = const [
      'กรุณานำยาเดิมมาด้วย (ถ้ามี)',
      'กินข้าวมื้อเข้าให้ทันเวลา 08.00 น.',
      'งด ชา กาแฟ',
    ],
    this.homeVisitDetail,
  });
}

const HomeVisitDetail _pciVisitDetail = HomeVisitDetail(
  staffName: 'เจ้าหน้าที่ทดสอบ',
  sendReason:
      'ติดตามฟื้นฟูสมรรถภาพหัวใจหลัง PCI ครั้งที่ 3 (สัปดาห์ที่ 4)',
  objective:
      'ประเมินระดับ Functional Capacity ด้วย 6-Minute Walk Test, ติดตามการรับประทานยา DAPT ครบ ประเมินภาวะเลือดออกผิดปกติ, ควบคุม BP < 130/80 mmHg, LDL < 55 mg/dL ตามแนวทาง ESC 2023',
  healthProblem:
      'ผู้ป่วยยังมีอาการเหนื่อยเล็กน้อยเมื่อเดินขึ้นบันได (NYHA Class II) ค่า EF 45% ต้องเฝ้าระวังภาวะหัวใจล้มเหลว และมีภาวะโลหิตจาง (Hb 9.3) จากการใช้ยาต้านเกล็ดเลือดคู่',
  medicalInfo:
      'โรคหัวใจขาดเลือดเฉียบพลัน (Acute STEMI) S/P PCI RCA with 1 DES เมื่อ 21/02/69 ชาย 61 ปี โรคร่วม: DM type 2, HT, Dyslipidemia ผลตรวจ 06/03/69: Hb 9.3 g/dL, Hct 27%, WBC 12,830, Platelet 546,000, Cr 0.93 mg/dL, eGFR 88 mL/min/1.73m² Echo (28/02/69): EF 45%, mild MR, regional wall motion abnormality at inferior wall ยาปัจจุบัน: Clopidogrel 75 mg bid, Atorvastatin 40 mg od, Omeprazole 20 mg bid, Aspirin 81 mg od, Ferrous Fumarate 200 mg tid, Spironolactone 25 mg od, Isosorbide SL 5 mg prn',
  socialInfo: [
    MapEntry('จำนวนสมาชิกในบ้าน', '3 คน (ภรรยา, ลูกสาว)'),
    MapEntry('รายได้ครัวเรือน', '18,000 บาท/เดือน'),
    MapEntry('สวัสดิการ', 'บัตรทอง (สิทธิ์ 30 บาท)'),
    MapEntry('ปัญหาสุขภาพจิต/พฤติกรรมเสี่ยง',
        'วิตกกังวลเล็กน้อยเรื่องการกลับไปทำงาน PHQ-2 = 1 คะแนน'),
    MapEntry('ลักษณะสิ่งแวดล้อมบ้าน',
        'บ้านชั้นเดียว พื้นเรียบไม่มีบันได มีห้องน้ำนั่งราบ อากาศถ่ายเทดี ห่างจาก รพ.สต. ประมาณ 3 กม.'),
  ],
  visitNotes: [
    MapEntry('บันทึกการเยี่ยม',
        'ผู้ป่วยอาการทั่วไปดี รู้สึกตัวดี ไม่มีอาการเจ็บหน้าอก 6MWT = 380 เมตร (เพิ่มขึ้นจากครั้งก่อน 40 เมตร) ไม่มีจุดเลือดออกตามตัว ไม่มีอุจจาระดำ'),
    MapEntry('อาการและอาการแสดง',
        'เหนื่อยเล็กน้อยหลังเดินเร็วประมาณ 15 นาที (Borg Scale 3/10) ไม่มี chest pain, orthopnea, PND ขาไม่บวม น้ำหนักคงที่'),
    MapEntry('การพยาบาล',
        'วัด vital signs, ตรวจ capillary refill time ปลายมือปลายเท้าปกติ, ตรวจจุดแทง catheter ที่ข้อมือขวา แผลหายดีไม่บวมแดง, ทำ 6MWT พร้อมจับ SpO2 ระหว่างเดิน'),
    MapEntry('การให้คำแนะนำ',
        'เพิ่มระยะเวลาเดินเป็น 20 นาที/วัน ความเร็วปานกลาง, งดอาหารเค็ม/มัน/ทอด, ทานยา DAPT สม่ำเสมอห้ามหยุดเอง, สังเกตอาการเลือดออกผิดปกติ เช่น ฟกช้ำง่าย เลือดกำเดา อุจจาระดำ, พบแพทย์ทันทีหากเจ็บหน้าอก/เหนื่อยมากขึ้น'),
    MapEntry('การประเมิน',
        'อาการดีขึ้นต่อเนื่อง 6MWT เพิ่มขึ้น BP ควบคุมได้ดี น้ำตาลสูงเล็กน้อยต้องติดตาม แนะนำนัดเจาะเลือดตรวจ HbA1c, Lipid profile ก่อนพบแพทย์ครั้งต่อไป 18/04/69'),
  ],
);

const HomeVisitDetail _genericVisitDetail = HomeVisitDetail(
  staffName: 'เจ้าหน้าที่ทดสอบ',
  sendReason: 'ติดตามอาการผู้ป่วยที่บ้านตามนัดประจำสัปดาห์',
  objective: 'ประเมินสภาพทั่วไป, วัด vital signs, ตรวจติดตามอาการ, ทบทวนการใช้ยา',
  healthProblem: 'ผู้ป่วยมีอาการคงที่ ต้องการการติดตามอาการต่อเนื่องที่บ้าน',
  medicalInfo:
      'ประวัติการรักษาต่อเนื่องจาก รพ.สต. โรคประจำตัวตามบันทึกเวชระเบียน ยาปัจจุบันรับจาก รพ. ครั้งล่าสุด',
  socialInfo: [
    MapEntry('จำนวนสมาชิกในบ้าน', '4 คน'),
    MapEntry('รายได้ครัวเรือน', '15,000 บาท/เดือน'),
    MapEntry('สวัสดิการ', 'บัตรทอง'),
    MapEntry('ปัญหาสุขภาพจิต/พฤติกรรมเสี่ยง', 'ไม่มี'),
    MapEntry('ลักษณะสิ่งแวดล้อมบ้าน', 'บ้านชั้นเดียว อากาศถ่ายเทดี สะอาด'),
  ],
  visitNotes: [
    MapEntry('บันทึกการเยี่ยม', 'ผู้ป่วยอาการคงที่ รู้สึกตัวดี'),
    MapEntry('อาการและอาการแสดง', 'vital signs ปกติ ไม่มีอาการผิดปกติ'),
    MapEntry('การพยาบาล', 'ตรวจ vital signs ทบทวนยาและอาหาร'),
    MapEntry('การให้คำแนะนำ', 'รับประทานยาตามสั่ง ออกกำลังกายสม่ำเสมอ'),
    MapEntry('การประเมิน', 'อาการดีขึ้น นัดติดตามครั้งต่อไปตามแผน'),
  ],
);

class AppointmentBundle {
  final Map<AppointmentBucket, List<AppointmentItem>> byBucket;

  const AppointmentBundle({required this.byBucket});

  int get soonCount => byBucket[AppointmentBucket.soon]?.length ?? 0;
  int get weekCount => byBucket[AppointmentBucket.week]?.length ?? 0;
  int get monthCount => byBucket[AppointmentBucket.month]?.length ?? 0;
  int get total => soonCount + weekCount + monthCount;
}

const _greenGradient = <Color>[
  Color(0x8068C7AD),
  Color(0x801D8B6B),
];
const _redGradient = <Color>[
  Color(0x80FF9C66),
  Color(0x80BC1B06),
];

const _soonTagColor = Color(0xFF166C53);

final AppointmentBundle hospitalAppointments = AppointmentBundle(
  byBucket: {
    AppointmentBucket.soon: [
      AppointmentItem(
        date: DateTime(2026, 4, 24),
        time: '12:30',
        title: 'โรงพยาบาลเฮลธ์',
        subLeft: 'อายุรกรรม',
        subRight: 'น.พ. สุขภาพดี จิตแจ่มใส',
        gradient: _greenGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: _soonTagColor,
      ),
      AppointmentItem(
        date: DateTime(2026, 4, 26),
        time: '09:00',
        title: 'โรงพยาบาลศิริราช',
        subLeft: 'กระดูกและข้อ',
        subRight: 'น.พ. สมชาย ใจดี',
        gradient: _greenGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: _soonTagColor,
      ),
      AppointmentItem(
        date: DateTime(2026, 4, 28),
        time: '14:00',
        title: 'โรงพยาบาลจุฬาฯ',
        subLeft: 'หัวใจและหลอดเลือด',
        subRight: 'พญ. ใจดี มั่งมี',
        gradient: _greenGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: _soonTagColor,
      ),
    ],
    AppointmentBucket.week: [
      AppointmentItem(
        date: DateTime(2026, 5, 1),
        time: '12:30',
        title: 'โรงพยาบาลเฮลธ์',
        subLeft: 'อายุรกรรม',
        subRight: 'น.พ. สุขภาพดี จิตแจ่มใส',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
      ),
      AppointmentItem(
        date: DateTime(2026, 5, 3),
        time: '10:30',
        title: 'โรงพยาบาลราชวิถี',
        subLeft: 'ศัลยกรรม',
        subRight: 'น.พ. ภาคภูมิ สุขเกษม',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
      ),
      AppointmentItem(
        date: DateTime(2026, 5, 5),
        time: '15:00',
        title: 'โรงพยาบาลบำรุงราษฎร์',
        subLeft: 'ผิวหนัง',
        subRight: 'พญ. สวยงาม รุ่งโรจน์',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
      ),
    ],
    AppointmentBucket.month: [
      AppointmentItem(
        date: DateTime(2026, 5, 10),
        time: '09:30',
        title: 'โรงพยาบาลเฮลธ์',
        subLeft: 'ตา',
        subRight: 'พญ. ดวงตา สว่างใส',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
      ),
      AppointmentItem(
        date: DateTime(2026, 5, 17),
        time: '13:00',
        title: 'โรงพยาบาลศิริราช',
        subLeft: 'ทันตกรรม',
        subRight: 'ทพ. ฟันสวย ยิ้มแย้ม',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
      ),
      AppointmentItem(
        date: DateTime(2026, 5, 24),
        time: '12:30',
        title: 'โรงพยาบาลเฮลธ์',
        subLeft: 'อายุรกรรม',
        subRight: 'น.พ. สุขภาพดี จิตแจ่มใส',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
      ),
    ],
  },
);

final AppointmentBundle homeVisitAppointments = AppointmentBundle(
  byBucket: {
    AppointmentBucket.soon: [
      AppointmentItem(
        date: DateTime(2026, 4, 24),
        time: '12:30',
        title: 'ติดตามฟื้นฟูสมรรถภาพหัวใจหลัง PCI...',
        subLeft: 'ผู้ป่วยติดเตียง',
        subRight: 'นาย ความสุข มีดี',
        gradient: _greenGradient,
        tag: AppointmentTagKind.visit,
        tagTextColor: _soonTagColor,
        homeVisitDetail: _pciVisitDetail,
      ),
      AppointmentItem(
        date: DateTime(2026, 4, 26),
        time: '10:00',
        title: 'ทำแผลผู้ป่วยติดเตียง',
        subLeft: 'ผู้สูงอายุ',
        subRight: 'นาง สมใจ จิตใส',
        gradient: _greenGradient,
        tag: AppointmentTagKind.visit,
        tagTextColor: _soonTagColor,
        homeVisitDetail: _genericVisitDetail,
      ),
      AppointmentItem(
        date: DateTime(2026, 4, 28),
        time: '14:30',
        title: 'ตรวจวัดความดัน + เบาหวาน',
        subLeft: 'ผู้สูงอายุ',
        subRight: 'นาย สมพร รักสุขภาพ',
        gradient: _greenGradient,
        tag: AppointmentTagKind.visit,
        tagTextColor: _soonTagColor,
        homeVisitDetail: _genericVisitDetail,
      ),
    ],
    AppointmentBucket.week: [
      AppointmentItem(
        date: DateTime(2026, 5, 1),
        time: '12:30',
        title: 'ติดตามฟื้นฟูสมรรถภาพหัวใจหลัง PCI...',
        subLeft: 'ผู้ป่วยติดเตียง',
        subRight: 'นาย ความสุข มีดี',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
        homeVisitDetail: _pciVisitDetail,
      ),
      AppointmentItem(
        date: DateTime(2026, 5, 3),
        time: '09:00',
        title: 'ล้างไตทางช่องท้อง',
        subLeft: 'ผู้ป่วยติดเตียง',
        subRight: 'นางสาว สุดา ขยัน',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
        homeVisitDetail: _genericVisitDetail,
      ),
      AppointmentItem(
        date: DateTime(2026, 5, 5),
        time: '11:00',
        title: 'ให้อาหารทางสายยาง',
        subLeft: 'ผู้ป่วยติดเตียง',
        subRight: 'นาย สมชัย ชัยชนะ',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
        homeVisitDetail: _genericVisitDetail,
      ),
    ],
    AppointmentBucket.month: [
      AppointmentItem(
        date: DateTime(2026, 5, 10),
        time: '10:30',
        title: 'กายภาพบำบัดเข่า',
        subLeft: 'ผู้สูงอายุ',
        subRight: 'นาง บุญมี สุขใจ',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
        homeVisitDetail: _genericVisitDetail,
      ),
      AppointmentItem(
        date: DateTime(2026, 5, 17),
        time: '15:00',
        title: 'ติดตามแผลผ่าตัด',
        subLeft: 'ผู้ป่วยฟื้นฟู',
        subRight: 'นาย ประยุทธ์ ดีงาม',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
        homeVisitDetail: _genericVisitDetail,
      ),
      AppointmentItem(
        date: DateTime(2026, 5, 24),
        time: '12:30',
        title: 'ติดตามฟื้นฟูสมรรถภาพหัวใจหลัง PCI...',
        subLeft: 'ผู้ป่วยติดเตียง',
        subRight: 'นาย ความสุข มีดี',
        gradient: _redGradient,
        tag: AppointmentTagKind.track,
        tagTextColor: AppColors.health,
        homeVisitDetail: _pciVisitDetail,
      ),
    ],
  },
);
