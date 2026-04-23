import 'package:flutter/cupertino.dart';

import '../family/care_giver_screen.dart';
import '../health/health_screen.dart';
import '../health/widgets/custom_tab_bar.dart';
import '../me/me_screen.dart';
import '../medicine/medicine_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 1; // Health tab by default

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_tabIndex) {
      case 2:
        body = const MedicineScreen();
        break;
      case 3:
        body = const CareGiverScreen();
        break;
      case 4:
        body = const MeScreen();
        break;
      default:
        body = const HealthScreen();
    }
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: body),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomTabBar(
              currentIndex: _tabIndex,
              onTap: (i) => setState(() => _tabIndex = i),
              items: const [
                TabItem(CupertinoIcons.house, 'หน้าหลัก'),
                TabItem(CupertinoIcons.heart, 'สุขภาพ'),
                TabItem(CupertinoIcons.capsule, 'ทานยา'),
                TabItem(CupertinoIcons.person_2, 'ครอบครัว'),
                TabItem(CupertinoIcons.person_crop_circle, 'ฉัน'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
