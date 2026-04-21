import 'package:flutter/foundation.dart';

class MealEntry {
  MealEntry({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.time,
    required this.calories,
    required this.grams,
    this.imagePath,
    this.assetImage,
    this.description,
    this.protein = 20,
    this.carbs = 40,
    this.fat = 15,
    this.fiber = 3.5,
    this.sugar = 8,
    this.tips = const [],
    this.warning = '',
  });

  final String id;
  final String name;
  final String nameEn;
  final DateTime time;
  final int calories;
  final int grams;
  final String? imagePath;
  final String? assetImage;
  final String? description;
  final int protein;
  final int carbs;
  final int fat;
  final double fiber;
  final int sugar;
  final List<String> tips;
  final String warning;
}

class MealStore {
  MealStore._();

  static final MealStore instance = MealStore._();

  final ValueNotifier<List<MealEntry>> meals = ValueNotifier(_seed());

  static List<MealEntry> _seed() {
    final today = DateTime.now();
    DateTime at(int h, int m) =>
        DateTime(today.year, today.month, today.day, h, m);
    return [
      MealEntry(
        id: 'seed-breakfast',
        name: 'โจ๊กหมู + ไข่ลวก',
        nameEn: 'Pork Congee with Soft-Boiled Egg',
        time: at(7, 30),
        calories: 380,
        grams: 320,
        assetImage: 'assets/images/meal_pork_congee.png',
        description:
            'โจ๊กข้าวสวยต้มกับน้ำซุปกระดูกหมู ใส่หมูสับลูกชิ้นเล็ก ไข่ลวกยางมะตูม โรยขิงฝอย ต้นหอม ผักชี พริกไทย เป็นมื้อเช้าอบอุ่นท้อง โปรตีนดี คาร์บย่อยง่าย',
        protein: 18,
        carbs: 52,
        fat: 8,
        fiber: 2,
        sugar: 3,
        tips: [
          'ย่อยง่าย เหมาะมื้อเช้า',
          'โปรตีนจากหมูและไข่ ฟื้นร่างกาย',
          'ขิง/พริกไทย ช่วยกระตุ้นการย่อย',
          'น้ำซุปเติมน้ำในร่างกาย',
          'คาร์บให้พลังงานเริ่มวัน',
        ],
        warning:
            'โซเดียมจากซุป/น้ำปลาอาจสูง ผู้ความดันควรระวัง และไข่ลวกควรมั่นใจว่าสะอาด',
      ),
      MealEntry(
        id: 'seed-snack-am',
        name: 'กาแฟลาเต้ + ขนมปังโฮลวีท',
        nameEn: 'Latte with Whole Wheat Toast',
        time: at(10, 0),
        calories: 220,
        grams: 260,
        assetImage: 'assets/images/meal_basil_chicken.png',
        description:
            'กาแฟลาเต้ร้อนนมสด + ขนมปังโฮลวีทปิ้งทาเนยถั่ว ของว่างให้พลังงานกลางเช้า คาเฟอีนกระตุ้นการเผาผลาญ เส้นใยจากโฮลวีทอยู่ท้องนาน',
        protein: 9,
        carbs: 32,
        fat: 7,
        fiber: 3,
        sugar: 9,
        tips: [
          'คาเฟอีน กระตุ้นการเผาผลาญ',
          'ใยอาหารจากโฮลวีท อยู่ท้องนาน',
          'เนยถั่วให้ไขมันดี',
          'นมให้แคลเซียม + โปรตีน',
          'พลังงานปานกลาง ไม่หนักเกิน',
        ],
        warning:
            'นมและขนมปังอาจมีน้ำตาลเพิ่ม ผู้แพ้แล็คโตสเปลี่ยนเป็นนมถั่วเหลืองได้',
      ),
      MealEntry(
        id: 'seed-lunch',
        name: 'กะเพราไก่ไข่ดาว',
        nameEn: 'Basil Chicken with Fried Egg over Rice',
        time: at(12, 15),
        calories: 680,
        grams: 420,
        assetImage: 'assets/images/meal_basil_chicken.png',
        description:
            'ข้าวสวยกะเพราไก่สับราดไข่ดาวกรอบ ใบกะเพราสด พริกขี้หนู กระเทียม น้ำปลาน้อย เสิร์ฟพร้อมแตงกวา โปรตีนสูง คาร์บปานกลาง',
        protein: 32,
        carbs: 62,
        fat: 24,
        fiber: 2.5,
        sugar: 4,
        tips: [
          'โปรตีนจากไก่และไข่ เสริมกล้าม',
          'ใบกะเพรามีสารต้านอนุมูลอิสระ',
          'พริกขี้หนู กระตุ้นการเผาผลาญ',
          'คาร์บพลังงานสำหรับตอนบ่าย',
          'แตงกวาเพิ่มน้ำและกากใย',
        ],
        warning:
            'โซเดียมจากน้ำปลาค่อนข้างสูง และไข่ดาวทอดน้ำมันเพิ่มไขมัน ผู้ต้องคุมไขมัน/ความดันควรลดน้ำปลา',
      ),
      MealEntry(
        id: 'seed-snack-pm',
        name: 'สลัดผลไม้โยเกิร์ต',
        nameEn: 'Yogurt Fruit Bowl',
        time: at(15, 30),
        calories: 180,
        grams: 240,
        assetImage: 'assets/images/salad_bowl.png',
        description:
            'โยเกิร์ตกรีกไขมันต่ำ + สตรอเบอร์รี บลูเบอร์รี กล้วย โรยกราโนล่าและน้ำผึ้งนิดหน่อย วิตามินและโปรไบโอติกส์สูง ของว่างคลีน',
        protein: 10,
        carbs: 28,
        fat: 4,
        fiber: 4.5,
        sugar: 18,
        tips: [
          'โปรไบโอติกส์ดีต่อระบบทางเดินอาหาร',
          'เบอร์รี่อุดมสารต้านอนุมูลอิสระ',
          'วิตามิน C สูง เสริมภูมิ',
          'ใยอาหารจากผลไม้ช่วยขับถ่าย',
          'แคลเซียมจากโยเกิร์ต บำรุงกระดูก',
        ],
        warning:
            'น้ำตาลธรรมชาติจากผลไม้ + น้ำผึ้งรวมกันสูง ผู้เบาหวานควรลดกล้วย/น้ำผึ้ง',
      ),
      MealEntry(
        id: 'seed-dinner',
        name: 'สลัดอกไก่ย่าง',
        nameEn: 'Grilled Chicken Breast Salad',
        time: at(18, 45),
        calories: 320,
        grams: 380,
        assetImage: 'assets/images/salad_bowl.png',
        description:
            'อกไก่ย่างสมุนไพรหั่นชิ้น ผักรวมออแกนิก มะเขือเทศเชอรี่ แตงกวา หอมแดงแยก น้ำสลัดบัลซามิก เมนูมื้อเย็นคลีน โปรตีนสูง คาร์บต่ำมาก',
        protein: 36,
        carbs: 14,
        fat: 12,
        fiber: 5,
        sugar: 6,
        tips: [
          'โปรตีนสูง เสริมกล้ามเนื้อตอนเย็น',
          'ใยอาหารสูง ช่วยขับถ่าย',
          'วิตามิน C + ไลโคปีน จากผัก',
          'คาร์บต่ำ เหมาะคุมน้ำหนัก',
          'ไขมันต่ำ ดีต่อหัวใจ',
        ],
        warning:
            'น้ำสลัดบัลซามิกอาจมีน้ำตาล/โซเดียม ผู้ป่วยไตควรระวังโปรตีนสูง',
      ),
      MealEntry(
        id: 'seed-evening',
        name: 'ต้มยำกุ้งน้ำใส',
        nameEn: 'Clear Tom Yum Goong',
        time: at(20, 0),
        calories: 160,
        grams: 350,
        assetImage: 'assets/images/meal_pork_congee.png',
        description:
            'ต้มยำกุ้งน้ำใส (ไม่ใส่นม/กะทิ) กุ้งแม่น้ำ 4 ตัว เห็ดฟาง มะเขือเทศ ข่า ตะไคร้ ใบมะกรูด พริกขี้หนูน้อย มะนาว สมุนไพรต้านอักเสบ',
        protein: 22,
        carbs: 10,
        fat: 5,
        fiber: 3.5,
        sugar: 3,
        tips: [
          'โปรตีนกุ้งคุณภาพดี',
          'สมุนไพร (ข่า ตะไคร้ ใบมะกรูด) ต้านอักเสบ',
          'แคลอรี่ต่ำ เหมาะมื้อเย็น',
          'มะนาว/วิตามิน C ช่วยดูดซึม',
          'น้ำซุปใสเติมน้ำร่างกาย',
        ],
        warning:
            'รสเผ็ดอาจระคายกระเพาะ ผู้แพ้กุ้งห้ามทาน และควรระวังโซเดียมจากน้ำปลา',
      ),
    ];
  }

  void add(MealEntry entry) {
    final list = [entry, ...meals.value];
    list.sort((a, b) => b.time.compareTo(a.time));
    meals.value = list;
  }

  void removeById(String id) {
    meals.value = meals.value.where((m) => m.id != id).toList();
  }

  List<MealEntry> todayMeals() {
    final now = DateTime.now();
    return meals.value.where((m) {
      return m.time.year == now.year &&
          m.time.month == now.month &&
          m.time.day == now.day;
    }).toList();
  }

  int todayCalories() =>
      todayMeals().fold<int>(0, (sum, m) => sum + m.calories);
  int todayCount() => todayMeals().length;
}

class MealAnalysis {
  const MealAnalysis({
    required this.name,
    required this.nameEn,
    required this.calories,
    required this.grams,
    required this.description,
    this.protein = 20,
    this.carbs = 40,
    this.fat = 15,
    this.fiber = 3.5,
    this.sugar = 8,
    this.tips = const [],
    this.warning = '',
  });

  final String name;
  final String nameEn;
  final int calories;
  final int grams;
  final String description;
  final int protein;
  final int carbs;
  final int fat;
  final double fiber;
  final int sugar;
  final List<String> tips;
  final String warning;
}

const List<MealAnalysis> kMealAnalysisOptions = [
  MealAnalysis(
    name: 'สลัดอกไก่ย่าง',
    nameEn: 'Grilled Chicken Breast Salad',
    calories: 250,
    grams: 300,
    description:
        'ตรวจพบจาน สลัดอกไก่ย่าง ประกอบด้วยอกไก่ลอกหนังย่างชิ้นชั้นประมาณ 100-120 กรัม ผักกาดคอสสด มะเขือเทศราชินีประมาณ 5 ลูก แตงกวาสไลด์ หอมแดงแยก และโรสแมรีตกแต่งเพื่อกลิ่นหอม เสิร์ฟคู่กับน้ำเลมอนผ่าน เป็นเมนูที่มี โปรตีนสูง และ คาร์โบไฮเดรตต่ำมาก',
    protein: 32,
    carbs: 12,
    fat: 10,
    fiber: 4.5,
    sugar: 5,
    tips: [
      'โปรตีนสูง เสริมกล้ามเนื้อ',
      'ใยอาหารสูง ช่วยขับถ่าย',
      'วิตามิน C สูง เสริมภูมิ',
      'พลังงานต่ำ เหมาะคุมน้ำหนัก',
      'ไขมันต่ำ ดีต่อหัวใจ',
    ],
    warning:
        'โปรตีนค่อนข้างสูง (ผู้ป่วยไตควรระวัง) น้ำสลัดอาจมีโซเดียม/น้ำตาล ผักดิบอาจระคายกระเพาะ และควรดื่มน้ำให้เพียงพอเนื่องจากใยอาหารสูง',
  ),
  MealAnalysis(
    name: 'ข้าวผัดกุ้ง',
    nameEn: 'Shrimp Fried Rice',
    calories: 520,
    grams: 380,
    description:
        'ตรวจพบจาน ข้าวผัดกุ้ง ประกอบด้วยข้าวสวย กุ้งตัวกลางประมาณ 6 ตัว ไข่ ต้นหอม และซอสปรุงรส เสิร์ฟพร้อมมะนาวและแตงกวา เป็นเมนูที่มี คาร์โบไฮเดรตสูง และ โซเดียมปานกลาง',
    protein: 22,
    carbs: 68,
    fat: 18,
    fiber: 2.5,
    sugar: 4,
    tips: [
      'โปรตีนจากกุ้ง-ไข่ ช่วยฟื้นกล้ามเนื้อ',
      'คาร์โบไฮเดรตให้พลังงานระหว่างวัน',
      'ใยอาหารค่อนข้างน้อย เพิ่มผักได้',
      'ควรจำกัดปริมาณหากต้องคุมน้ำหนัก',
      'ทานคู่มะนาวช่วยย่อย',
    ],
    warning:
        'โซเดียมค่อนข้างสูงจากซีอิ๊ว/น้ำปลา ผู้มีความดันควรระวัง คาร์โบไฮเดรตสูง ควรทานคู่สลัด/ผักลวกเพื่อลด GI',
  ),
  MealAnalysis(
    name: 'ส้มตำไทย',
    nameEn: 'Thai Papaya Salad',
    calories: 150,
    grams: 280,
    description:
        'ตรวจพบจาน ส้มตำไทย ประกอบด้วยมะละกอเส้นสด มะเขือเทศ ถั่วลิสงคั่ว พริกขี้หนู น้ำปลา น้ำตาลปี๊บ น้ำมะนาว เป็นเมนูที่มี กากใยสูง และ แคลอรี่ต่ำ',
    protein: 4,
    carbs: 22,
    fat: 5,
    fiber: 6,
    sugar: 14,
    tips: [
      'กากใยสูง ช่วยระบบขับถ่าย',
      'แคลอรี่ต่ำ เหมาะคุมน้ำหนัก',
      'วิตามิน C จากมะละกอช่วยเสริมภูมิ',
      'ถั่วลิสงให้ไขมันดี + โปรตีน',
      'รสเผ็ดกระตุ้นการเผาผลาญ',
    ],
    warning:
        'โซเดียมและน้ำตาลสูงจากน้ำปลา/น้ำตาลปี๊บ ผู้ป่วยเบาหวาน/ความดันควรระวัง ผู้มีแผลในกระเพาะไม่ควรทานรสจัดเกินไป',
  ),
  MealAnalysis(
    name: 'ต้มยำกุ้ง',
    nameEn: 'Tom Yum Goong',
    calories: 180,
    grams: 400,
    description:
        'ตรวจพบจาน ต้มยำกุ้ง ประกอบด้วยกุ้งแม่น้ำ เห็ดฟาง มะเขือเทศ ข่า ตะไคร้ ใบมะกรูด น้ำพริกเผา น้ำมะนาว เป็นเมนูที่มี โปรตีนสูง และ เผ็ดร้อน เหมาะกับการกระตุ้นระบบเผาผลาญ',
    protein: 20,
    carbs: 10,
    fat: 8,
    fiber: 3,
    sugar: 4,
    tips: [
      'โปรตีนคุณภาพดีจากกุ้ง',
      'สมุนไพรไทย ต้านการอักเสบ',
      'แคลอรี่ต่ำ เหมาะคุมน้ำหนัก',
      'ช่วยอุ่นร่างกาย ลดหวัด',
      'น้ำซุปใสไม่มีกะทิ ไขมันต่ำ',
    ],
    warning:
        'รสจัด/เผ็ด อาจระคายกระเพาะ ผู้แพ้กุ้งควรหลีกเลี่ยง และน้ำพริกเผาอาจมีน้ำตาลและโซเดียม',
  ),
  MealAnalysis(
    name: 'แกงเขียวหวานไก่',
    nameEn: 'Green Curry Chicken',
    calories: 420,
    grams: 350,
    description:
        'ตรวจพบจาน แกงเขียวหวานไก่ ประกอบด้วยไก่สะโพกหั่นเต๋า มะเขือเปราะ ใบโหระพา กะทิ และพริกแกงเขียวหวาน เป็นเมนูที่มี ไขมันปานกลาง-สูง และควรทานคู่กับข้าวไม่เยอะ',
    protein: 24,
    carbs: 18,
    fat: 28,
    fiber: 3.5,
    sugar: 6,
    tips: [
      'โปรตีนจากไก่ช่วยสร้างเนื้อเยื่อ',
      'เครื่องแกงสมุนไพรต้านอักเสบ',
      'กะทิให้ไขมันอิ่มตัวระดับปานกลาง',
      'มะเขือ-ใบโหระพาเพิ่มกากใย',
      'ควรทานคู่ข้าวในปริมาณเหมาะสม',
    ],
    warning:
        'ไขมันอิ่มตัวสูงจากกะทิ ผู้มีคอเลสเตอรอลสูง/โรคหัวใจควรระวัง และควรเลี่ยงการราดน้ำแกงเยอะเกินไป',
  ),
];

MealAnalysis pickAnalysis() {
  final i = DateTime.now().millisecondsSinceEpoch % kMealAnalysisOptions.length;
  return kMealAnalysisOptions[i];
}
