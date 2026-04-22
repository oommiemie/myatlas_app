import 'package:flutter/cupertino.dart';

enum TreatmentType { inpatient, outpatient }

extension TreatmentTypeTheme on TreatmentType {
  String get label =>
      this == TreatmentType.inpatient ? 'ผู้ป่วยใน' : 'ผู้ป่วยนอก';

  /// Strong brand color for header gradient and active tab.
  Color get primary => this == TreatmentType.inpatient
      ? const Color(0xFF7C3AED)
      : const Color(0xFF0088FF);

  /// Darker shade for gradient bottom.
  Color get primaryDark => this == TreatmentType.inpatient
      ? const Color(0xFF5B21B6)
      : const Color(0xFF0061B8);

  /// Pale background for type pill.
  Color get pillBg => this == TreatmentType.inpatient
      ? const Color(0xFFEDE9FE)
      : const Color(0xFFE0F2FE);
}

class LabItem {
  const LabItem({
    required this.name,
    required this.status,
    required this.values,
  });
  final String name;
  final LabStatus status;
  final List<({String k, String v})> values;
}

enum LabStatus { normal, watch, abnormal }

extension LabStatusTheme on LabStatus {
  String get label => switch (this) {
        LabStatus.normal => 'ปกติ',
        LabStatus.watch => 'เฝ้าระวัง',
        LabStatus.abnormal => 'ผิดปกติ',
      };
  Color get color => switch (this) {
        LabStatus.normal => const Color(0xFF17C964),
        LabStatus.watch => const Color(0xFFF59E0B),
        LabStatus.abnormal => const Color(0xFFFF383C),
      };
}

class XrayResult {
  const XrayResult({required this.name, required this.note, required this.status});
  final String name;
  final String note;
  final LabStatus status;
}

class Medication {
  const Medication({
    required this.name,
    required this.dose,
    required this.frequency,
    this.image,
  });
  final String name;
  final String dose;
  final String frequency;
  final String? image; // optional asset path
}

class VitalSigns {
  const VitalSigns({
    required this.bp,
    required this.temp,
    required this.heartRate,
    required this.spo2,
    required this.respirationRate,
    required this.weight,
    required this.height,
  });
  final String bp;
  final String temp;
  final String heartRate;
  final String spo2;
  final String respirationRate;
  final String weight;
  final String height;
}

class Treatment {
  const Treatment({
    required this.id,
    required this.date,
    required this.hospital,
    required this.department,
    required this.type,
    required this.patient,
    required this.diagnosis,
    required this.recommendations,
    required this.labs,
    required this.xrays,
    required this.medications,
    required this.vitals,
  });

  final String id;
  final DateTime date;
  final String hospital;
  final String department;
  final TreatmentType type;
  final String patient;
  final String diagnosis;
  final List<String> recommendations;
  final List<LabItem> labs;
  final List<XrayResult> xrays;
  final List<Medication> medications;
  final VitalSigns vitals;
}

const _thMonthsShort = <String>[
  'ม.ค', 'ก.พ', 'มี.ค', 'เม.ย', 'พ.ค', 'มิ.ย',
  'ก.ค', 'ส.ค', 'ก.ย', 'ต.ค', 'พ.ย', 'ธ.ค',
];
const _thMonthsLong = <String>[
  'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
  'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
];

String formatShortDate(DateTime d) => '${d.day} ${_thMonthsShort[d.month - 1]} ${(d.year + 543) % 100}';
String formatLongMonth(DateTime d) => '${_thMonthsLong[d.month - 1]} ${(d.year + 543) % 100}';
String formatShortMonth(DateTime d) => _thMonthsShort[d.month - 1];
String formatDayMonthYear(DateTime d) =>
    '${d.day} ${_thMonthsLong[d.month - 1]} ${(d.year + 543) % 100}';

// Sample data matching the Figma designs.
const _diagText =
    'ผู้ป่วยมีอาการปวดท้องบริเวณลิ้นปี่ แสบร้อนหรือจุกแน่นท้อง '
    'โดยเฉพาะขณะท้องว่างหรือหลังรับประทานอาหาร '
    'อาจเกิดจากการระคายเคืองของเยื่อบุกระเพาะ เช่น '
    'การรับประทานอาหารไม่ตรงเวลา ความเครียด '
    'หรือการทานอาหารรสจัด';
const _recommendations = [
  'รับประทานอาหารให้ตรงเวลา และหลีกเลี่ยงการปล่อยให้หิวจัด',
  'งดอาหารรสเผ็ด เปรี้ยวจัด คาเฟอีน และแอลกอฮอล์',
  'ลดความเครียด และพักผ่อนให้เพียงพอ',
  'หากอาการไม่ดีขึ้น ควรพบแพทย์เพื่อตรวจเพิ่มเติม',
];

final List<Treatment> sampleTreatments = [
  Treatment(
    id: 't1',
    date: DateTime(2026, 3, 25),
    hospital: 'โรงพยาบาลสมาร์ทเฮลธ์',
    department: 'อายุรกรรม',
    type: TreatmentType.inpatient,
    patient: 'ณัฐพงษ์ ทดลอง',
    diagnosis: _diagText,
    recommendations: _recommendations,
    labs: [
      LabItem(name: 'ระดับน้ำตาลในเลือด (Blood Glucose)', status: LabStatus.normal, values: const [
        (k: 'Fasting Blood Glucose:', v: '92 mg/dL'),
      ]),
      LabItem(name: 'การทำงานของต่อมไทรอยด์ (Thyroid Function Te...)', status: LabStatus.normal, values: const [
        (k: 'TSH:', v: '2.8 μIU/mL'),
        (k: 'T3:', v: '110 ng/dL'),
        (k: 'T4:', v: '1.1 μg/dL'),
      ]),
      LabItem(name: 'ไขมันในเลือด (Lipid Profile)', status: LabStatus.watch, values: const [
        (k: 'Total Cholesterol:', v: '195 mg/dL'),
        (k: 'HDL:', v: '55 mg/dL'),
        (k: 'LDL:', v: '120 mg/dL'),
        (k: 'Triglycerides:', v: '165 mg/dL'),
      ]),
    ],
    xrays: const [
      XrayResult(name: 'ผลตรวจปอด (Chest X-ray)', note: 'ไม่พบความผิดปกติของปอดและหัวใจ', status: LabStatus.normal),
    ],
    medications: const [
      Medication(name: 'Omeprazole 20 mg', dose: '14 เม็ด', frequency: 'รับประทานวันละ 1 ครั้ง ก่อนอาหารเช้า 30 นาที'),
      Medication(name: 'Aluminum Hydroxide + Magnesium', dose: '1 ขวด (150 ml)', frequency: 'รับประทานหลังอาหาร วันละ 3 ครั้ง หรือเมื่อมีอาการ'),
      Medication(name: 'Domperidone 10 mg', dose: '15 เม็ด', frequency: 'รับประทานก่อนอาหาร วันละ 3 ครั้ง'),
    ],
    vitals: const VitalSigns(
      bp: '150/77',
      temp: '36',
      heartRate: '72',
      spo2: '95',
      respirationRate: '16',
      weight: '60',
      height: '175',
    ),
  ),
  Treatment(
    id: 't2',
    date: DateTime(2026, 3, 24),
    hospital: 'โรงพยาบาลเฮลธ์โฟล',
    department: 'อายุรกรรม',
    type: TreatmentType.outpatient,
    patient: 'ณัฐพงษ์ ทดลอง',
    diagnosis: _diagText,
    recommendations: _recommendations,
    labs: [],
    xrays: const [],
    medications: const [],
    vitals: const VitalSigns(
      bp: '128/72', temp: '36.5', heartRate: '76', spo2: '98', respirationRate: '16', weight: '60', height: '175',
    ),
  ),
  Treatment(
    id: 't3',
    date: DateTime(2026, 2, 10),
    hospital: 'โรงพยาบาลสมาร์ทเฮลธ์',
    department: 'อายุรกรรม',
    type: TreatmentType.inpatient,
    patient: 'ณัฐพงษ์ ทดลอง',
    diagnosis: _diagText,
    recommendations: _recommendations,
    labs: [],
    xrays: const [],
    medications: const [],
    vitals: const VitalSigns(
      bp: '135/80', temp: '36.8', heartRate: '80', spo2: '97', respirationRate: '18', weight: '60', height: '175',
    ),
  ),
  Treatment(
    id: 't4',
    date: DateTime(2026, 1, 10),
    hospital: 'โรงพยาบาลสมาร์ทเฮลธ์',
    department: 'อายุรกรรม',
    type: TreatmentType.inpatient,
    patient: 'ณัฐพงษ์ ทดลอง',
    diagnosis: _diagText,
    recommendations: _recommendations,
    labs: [],
    xrays: const [],
    medications: const [],
    vitals: const VitalSigns(
      bp: '140/85', temp: '37.2', heartRate: '88', spo2: '96', respirationRate: '20', weight: '60', height: '175',
    ),
  ),
  Treatment(
    id: 't5',
    date: DateTime(2026, 1, 3),
    hospital: 'โรงพยาบาลเฮลธ์โฟล',
    department: 'อายุรกรรม',
    type: TreatmentType.outpatient,
    patient: 'ณัฐพงษ์ ทดลอง',
    diagnosis: _diagText,
    recommendations: _recommendations,
    labs: [],
    xrays: const [],
    medications: const [],
    vitals: const VitalSigns(
      bp: '125/78', temp: '36.6', heartRate: '74', spo2: '98', respirationRate: '16', weight: '60', height: '175',
    ),
  ),
  Treatment(
    id: 't6',
    date: DateTime(2025, 12, 10),
    hospital: 'โรงพยาบาลสมาร์ทเฮลธ์',
    department: 'อายุรกรรม',
    type: TreatmentType.inpatient,
    patient: 'ณัฐพงษ์ ทดลอง',
    diagnosis: _diagText,
    recommendations: _recommendations,
    labs: [],
    xrays: const [],
    medications: const [],
    vitals: const VitalSigns(
      bp: '138/82', temp: '37.0', heartRate: '82', spo2: '97', respirationRate: '18', weight: '60', height: '175',
    ),
  ),
];
