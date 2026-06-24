import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Icons, Material, InkWell, ScaffoldMessenger, SnackBar, SnackBarBehavior;

/// A single aerobic dance clip the user can pick to work out to.
class _WorkoutClip {
  const _WorkoutClip({
    required this.title,
    required this.level,
    required this.minutes,
    required this.kcal,
    required this.colors,
    required this.icon,
  });

  final String title;
  final String level;
  final int minutes;
  final int kcal;
  final List<Color> colors; // thumbnail gradient
  final IconData icon;
}

const _clips = <_WorkoutClip>[
  _WorkoutClip(
    title: 'แอโรบิกพื้นฐาน วอร์มอัพ',
    level: 'เริ่มต้น',
    minutes: 15,
    kcal: 120,
    colors: [Color(0xFFFF9500), Color(0xFFFF5A2C)],
    icon: Icons.self_improvement,
  ),
  _WorkoutClip(
    title: 'เต้นจังหวะสนุก ขยับทั้งตัว',
    level: 'ปานกลาง',
    minutes: 20,
    kcal: 180,
    colors: [Color(0xFFFF6B6B), Color(0xFFEE4D9B)],
    icon: Icons.music_note,
  ),
  _WorkoutClip(
    title: 'คาร์ดิโอเข้มข้น เผาผลาญ',
    level: 'ขั้นสูง',
    minutes: 30,
    kcal: 280,
    colors: [Color(0xFF7A5CFF), Color(0xFF4D7BEE)],
    icon: Icons.local_fire_department,
  ),
  _WorkoutClip(
    title: 'แดนซ์ป็อป สุดมันส์',
    level: 'ปานกลาง',
    minutes: 25,
    kcal: 220,
    colors: [Color(0xFF22C1C3), Color(0xFF1D8B6B)],
    icon: Icons.flash_on,
  ),
  _WorkoutClip(
    title: 'ยืดเส้นคูลดาวน์ ผ่อนคลาย',
    level: 'เริ่มต้น',
    minutes: 10,
    kcal: 60,
    colors: [Color(0xFF5AC8FA), Color(0xFF4AB99C)],
    icon: Icons.spa,
  ),
];

const _bgPrimary = Color(0xFFF4F8F5);
const _ink = Color(0xFF1A1A2E);
// Header gradient (workout flame) — mirrors the nutrition detail layout.
const _headerTop = Color(0xFFFF9500);
const _headerBottom = Color(0xFFE03A12);

/// Clip picker — the screen reached by tapping "เริ่มออกกำลังกาย". Lets the user
/// choose an aerobic clip; selecting one proceeds to the ready/confirm screen.
/// Laid out like the nutrition detail screen: a gradient header with a glass
/// back button over a rounded content sheet.
class WorkoutClipPickerScreen extends StatelessWidget {
  const WorkoutClipPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgPrimary,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_headerTop, _headerBottom],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                  title: 'เลือกคลิปออกกำลังกาย',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Container(
                      color: _bgPrimary,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
                        children: [
                          const Text(
                            'เลือกคลิปที่อยากเต้นวันนี้',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Thai Looped',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'เต้นตามคลิป ระบบจะวัดคะแนนความแม่นยำให้',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Thai Looped',
                              fontSize: 13,
                              color: Color(0xFF6D756E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (final clip in _clips) ...[
                            _ClipCard(clip: clip),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
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

/// Gradient-header bar: glass back button + white title (nutrition style).
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Row(
        children: [
          _GlassCircle(icon: CupertinoIcons.chevron_back, onTap: onBack),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Thai Looped',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted-glass circular button used in the gradient header.
class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.35),
                  width: 0.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.white.withValues(alpha: 0.30),
                    CupertinoColors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(icon, size: 20, color: CupertinoColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClipCard extends StatelessWidget {
  const _ClipCard({required this.clip});
  final _WorkoutClip clip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CupertinoColors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => _ClipReadyScreen(clip: clip)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: clip.colors,
                  ),
                ),
                child: Icon(clip.icon, color: CupertinoColors.white, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      clip.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _pill(Icons.schedule, '${clip.minutes} นาที'),
                        const SizedBox(width: 6),
                        _pill(Icons.local_fire_department, '${clip.kcal} kcal'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ระดับ: ${clip.level}',
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontSize: 12,
                        color: Color(0xFF6D756E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EA),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFFF5A2C)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai Looped',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF5A2C),
            ),
          ),
        ],
      ),
    );
  }
}

/// Confirmation screen after picking a clip — proves the flow can proceed.
class _ClipReadyScreen extends StatelessWidget {
  const _ClipReadyScreen({required this.clip});
  final _WorkoutClip clip;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgPrimary,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_headerTop, _headerBottom],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                  title: 'พร้อมเริ่มหรือยัง?',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Container(
                      color: _bgPrimary,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          Center(
                            child: Container(
                              width: 160,
                              height: 160,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: clip.colors,
                                ),
                              ),
                              child: Icon(clip.icon,
                                  color: CupertinoColors.white, size: 72),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            clip.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Thai Looped',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${clip.minutes} นาที • ${clip.kcal} kcal • ระดับ ${clip.level}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Thai Looped',
                              fontSize: 14,
                              color: Color(0xFF6D756E),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'กำลังเริ่มคลิป… (ตัวอย่างการเชื่อมต่อ)'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF9500), Color(0xFFFF3B30)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF3B30)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.sports_gymnastics,
                                      color: CupertinoColors.white, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'เริ่มเต้นเลย',
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Thai Looped',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}
