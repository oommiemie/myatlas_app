import '../theme/time_period.dart';
import '../widgets/meal_section.dart';
import '../widgets/prescription_card.dart';
import '../prescription_detail_screen.dart';

class PeriodMedicines {
  final List<MedicineItem> beforeMeal;
  final List<MedicineItem> afterMeal;

  const PeriodMedicines({
    required this.beforeMeal,
    required this.afterMeal,
  });

  int get count => beforeMeal.length + afterMeal.length;

  static const empty = PeriodMedicines(beforeMeal: [], afterMeal: []);
}

class MedicineDayData {
  final Map<TimePeriod, PeriodMedicines> byPeriod;

  const MedicineDayData({required this.byPeriod});

  PeriodMedicines medicinesFor(TimePeriod p) =>
      byPeriod[p] ?? PeriodMedicines.empty;

  int countFor(TimePeriod p) => medicinesFor(p).count;

  int get morningCount => countFor(TimePeriod.morning);
  int get dayCount => countFor(TimePeriod.day);
  int get eveningCount => countFor(TimePeriod.evening);
  int get bedtimeCount => countFor(TimePeriod.bedtime);

  bool get isEmpty => byPeriod.values.every((p) => p.count == 0);

  static const empty = MedicineDayData(byPeriod: {});
}

class PrescriptionDayData {
  final List<PrescriptionItem> prescriptions;
  final Map<String, List<MedicineDetailItem>> detailByHospital;

  const PrescriptionDayData({
    required this.prescriptions,
    required this.detailByHospital,
  });

  static const empty =
      PrescriptionDayData(prescriptions: [], detailByHospital: {});
}

DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);

const _mucosolvan = MedicineItem(
  name: 'Mucosolvan Tab.30',
  description:
      'รับประทาน ครั้งละ 1 เม็ด วันละ 3 ครั้ง \n(เช้า-กลางวัน-เย็น)',
);
const _paracetamol500 = MedicineItem(
  name: 'Paracetamol 500 mg',
  description: 'รับประทาน ครั้งละ 1 เม็ด ทุก 4-6 ชม.\nหรือเมื่อปวด',
);
const _loraZepam = MedicineItem(
  name: 'LoraZepam 1 mg',
  description: 'รับประทาน ครั้งละ 1 เม็ด ก่อนนอน',
);
const _warfarin = MedicineItem(
  name: 'Warfarin 3 mg',
  description: 'รับประทาน ครั้งละ 1 เม็ด ก่อนนอน จ.-ศ.',
);
const _vitaminB = MedicineItem(
  name: 'Vitamin B Complex',
  description: 'รับประทาน ครั้งละ 1 เม็ด หลังอาหารเช้า',
);
const _omeprazole = MedicineItem(
  name: 'Omeprazole 20 mg',
  description: 'รับประทาน ครั้งละ 1 เม็ด ก่อนอาหาร 30 นาที',
);
const _amoxicillin = MedicineItem(
  name: 'Amoxicillin 500 mg',
  description: 'รับประทาน ครั้งละ 1 เม็ด ทุก 8 ชม.',
);
const _cetirizine = MedicineItem(
  name: 'Cetirizine 10 mg',
  description: 'รับประทาน ครั้งละ 1 เม็ด ก่อนนอน',
);

final Map<DateTime, MedicineDayData> _medicineByDate = {
  _key(DateTime(2026, 4, 20)): const MedicineDayData(
    byPeriod: {
      TimePeriod.morning: PeriodMedicines(
        beforeMeal: [_omeprazole],
        afterMeal: [_vitaminB, _mucosolvan],
      ),
      TimePeriod.day: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_mucosolvan, _amoxicillin, _paracetamol500],
      ),
      TimePeriod.evening: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_mucosolvan, _amoxicillin],
      ),
      TimePeriod.bedtime: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_warfarin, _cetirizine],
      ),
    },
  ),
  _key(DateTime(2026, 4, 21)): const MedicineDayData(
    byPeriod: {
      TimePeriod.morning: PeriodMedicines(
        beforeMeal: [_omeprazole],
        afterMeal: [_vitaminB, _paracetamol500],
      ),
      TimePeriod.day: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_amoxicillin, _paracetamol500, _mucosolvan],
      ),
      TimePeriod.evening: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_mucosolvan, _amoxicillin],
      ),
      TimePeriod.bedtime: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_warfarin, _loraZepam],
      ),
    },
  ),
  _key(DateTime(2026, 4, 22)): const MedicineDayData(
    byPeriod: {
      TimePeriod.morning: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_vitaminB],
      ),
      TimePeriod.day: PeriodMedicines(
        beforeMeal: [_omeprazole],
        afterMeal: [_amoxicillin],
      ),
      TimePeriod.evening: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_amoxicillin],
      ),
      TimePeriod.bedtime: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_cetirizine],
      ),
    },
  ),
  _key(DateTime(2026, 4, 23)): const MedicineDayData(
    byPeriod: {
      TimePeriod.morning: PeriodMedicines(
        beforeMeal: [_omeprazole],
        afterMeal: [_vitaminB, _mucosolvan, _paracetamol500],
      ),
      TimePeriod.day: PeriodMedicines(
        beforeMeal: [_omeprazole],
        afterMeal: [_mucosolvan, _amoxicillin, _paracetamol500],
      ),
      TimePeriod.evening: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_mucosolvan, _amoxicillin, _paracetamol500, _vitaminB],
      ),
      TimePeriod.bedtime: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_warfarin, _loraZepam, _cetirizine, _amoxicillin],
      ),
    },
  ),
  _key(DateTime(2026, 4, 24)): const MedicineDayData(
    byPeriod: {
      TimePeriod.morning: PeriodMedicines(
        beforeMeal: [_omeprazole],
        afterMeal: [_vitaminB],
      ),
      TimePeriod.day: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_mucosolvan, _paracetamol500, _amoxicillin],
      ),
      TimePeriod.evening: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_mucosolvan, _amoxicillin],
      ),
      TimePeriod.bedtime: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_warfarin, _cetirizine, _loraZepam],
      ),
    },
  ),
  _key(DateTime(2026, 4, 25)): const MedicineDayData(
    byPeriod: {
      TimePeriod.morning: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_vitaminB],
      ),
      TimePeriod.day: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_paracetamol500],
      ),
      TimePeriod.evening: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_mucosolvan],
      ),
      TimePeriod.bedtime: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_loraZepam],
      ),
    },
  ),
  _key(DateTime(2026, 4, 28)): const MedicineDayData(
    byPeriod: {
      TimePeriod.morning: PeriodMedicines(
        beforeMeal: [_omeprazole],
        afterMeal: [_vitaminB, _mucosolvan],
      ),
      TimePeriod.day: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_paracetamol500, _amoxicillin],
      ),
      TimePeriod.evening: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_mucosolvan, _amoxicillin, _paracetamol500],
      ),
      TimePeriod.bedtime: PeriodMedicines(
        beforeMeal: [],
        afterMeal: [_warfarin, _cetirizine],
      ),
    },
  ),
};

const _paracetamolDetail = MedicineDetailItem(
  name: 'Paracetamol 500 mg',
  dosage:
      'รับประทานครั้งละ 1 เม็ด ทุก 4-6 ชม.\nหรือ เมื่อมีอาการปวด ห้ามทานติดต่อกันเกิน 5 วัน',
  pillCount: 10,
  startDate: '14/05/68',
);
const _loraZepamDetail = MedicineDetailItem(
  name: 'LoraZepam 1 mg',
  dosage: 'รับประทานครั้งละ 1 เม็ด',
  pillCount: 30,
  startDate: '14/05/68',
);
const _warfarinDetail = MedicineDetailItem(
  name: 'Warfarin 3 mg',
  dosage: 'รับประทานครั้งละ 1 เม็ด ก่อนนอน จ.-ศ.',
  pillCount: 30,
  startDate: '14/05/68',
);

final Map<DateTime, PrescriptionDayData> _prescriptionByDate = {
  _key(DateTime(2026, 4, 20)): const PrescriptionDayData(
    prescriptions: [
      PrescriptionItem(
        hospital: 'โรงพยาบาลเฮลธ์',
        serviceDate: '14/05/68',
        symptoms: 'ปวดหัว มีไข้ ไอ',
      ),
      PrescriptionItem(
        hospital: 'โรงพยาบาลเฮลธ์',
        serviceDate: '01/04/68',
        symptoms: 'ปวดท้อง คลื่นไส้',
      ),
    ],
    detailByHospital: {
      'โรงพยาบาลเฮลธ์': [_paracetamolDetail, _loraZepamDetail, _warfarinDetail],
    },
  ),
  _key(DateTime(2026, 4, 21)): const PrescriptionDayData(
    prescriptions: [
      PrescriptionItem(
        hospital: 'โรงพยาบาลเอกชัย',
        serviceDate: '21/04/69',
        symptoms: 'ไข้หวัด ไอ',
      ),
    ],
    detailByHospital: {
      'โรงพยาบาลเอกชัย': [_paracetamolDetail],
    },
  ),
  _key(DateTime(2026, 4, 23)): const PrescriptionDayData(
    prescriptions: [
      PrescriptionItem(
        hospital: 'คลินิกคุณหมอสมชาย',
        serviceDate: '22/04/69',
        symptoms: 'แพ้อากาศ จาม',
      ),
      PrescriptionItem(
        hospital: 'โรงพยาบาลเฮลธ์',
        serviceDate: '15/03/69',
        symptoms: 'กระเพาะ',
      ),
      PrescriptionItem(
        hospital: 'โรงพยาบาลบางโพ',
        serviceDate: '10/03/69',
        symptoms: 'เช็คประจำปี',
      ),
    ],
    detailByHospital: {
      'คลินิกคุณหมอสมชาย': [_loraZepamDetail],
      'โรงพยาบาลเฮลธ์': [_paracetamolDetail, _warfarinDetail],
      'โรงพยาบาลบางโพ': [_paracetamolDetail],
    },
  ),
};

MedicineDayData medicineFor(DateTime date) {
  return _medicineByDate[_key(date)] ?? MedicineDayData.empty;
}

PrescriptionDayData prescriptionFor(DateTime date) {
  return _prescriptionByDate[_key(date)] ?? PrescriptionDayData.empty;
}

Set<DateTime> get markedDates {
  return {..._medicineByDate.keys, ..._prescriptionByDate.keys};
}
