import 'package:flutter/material.dart';

/// Sleep summary — a sleep score, last-night's stage breakdown (deep / REM /
/// light / awake), accumulated sleep debt and bedtime consistency. None of this
/// exists in the app yet, despite Apple Watch already tracking sleep stages.
class HomeSleepCard extends StatelessWidget {
  const HomeSleepCard({
    super.key,
    this.score = 82,
    // Minutes per stage for last night.
    this.deepMin = 78,
    this.remMin = 96,
    this.lightMin = 222,
    this.awakeMin = 12,
    this.sleepDebtMin = -192, // negative = behind on sleep (−3h 12m)
    this.bedtime = '23:14',
    this.bedtimeVarianceMin = 38,
    this.onTap,
  });

  final int score;
  final int deepMin;
  final int remMin;
  final int lightMin;
  final int awakeMin;
  final int sleepDebtMin;
  final String bedtime;
  final int bedtimeVarianceMin;
  final VoidCallback? onTap;

  static const _ink = Color(0xFF1A1A2E);
  static const _muted = Color(0xFF8A97A3);

  static const _deep = Color(0xFF5E35B1);
  static const _rem = Color(0xFFAF52DE);
  static const _light = Color(0xFFB39DDB);
  static const _awake = Color(0xFFD9D2E0);

  int get _totalMin => deepMin + remMin + lightMin + awakeMin;

  String _fmt(int minutes) {
    final m = minutes.abs();
    final h = m ~/ 60;
    final mm = m % 60;
    if (h == 0) return '$mm น.';
    return '$h ชม. ${mm.toString().padLeft(2, '0')} น.';
  }

  Color get _scoreColor {
    if (score >= 80) return const Color(0xFF1D8B6B);
    if (score >= 60) return const Color(0xFFEAAA08);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    final stages = <(String, int, Color)>[
      ('ลึก', deepMin, _deep),
      ('REM', remMin, _rem),
      ('เบา', lightMin, _light),
      ('ตื่น', awakeMin, _awake),
    ];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_rem, _deep],
                    ),
                  ),
                  child: const Icon(Icons.nightlight_round,
                      color: Colors.white, size: 13),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'การนอนเมื่อคืน',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.275,
                      color: Color(0xFF6D756E),
                      height: 1.33,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 22, color: _muted),
              ],
            ),
            const SizedBox(height: 12),
            // Score + total time
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score.toString(),
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    color: _scoreColor,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6, left: 2),
                  child: Text(
                    '/100',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _muted,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _fmt(_totalMin),
                      style: const TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const Text(
                      'นอนทั้งหมด',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 11,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Stacked stage bar
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, t, __) => Row(
                  children: [
                    for (final s in stages)
                      Expanded(
                        flex: (s.$2 * t * 100).round().clamp(1, 1 << 30),
                        child: Container(height: 12, color: s.$3),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Stage legend
            Row(
              children: [
                for (int i = 0; i < stages.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(child: _StageLegend(
                    label: stages[i].$1,
                    duration: _fmt(stages[i].$2),
                    color: stages[i].$3,
                  )),
                ],
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFEFF1F0)),
            const SizedBox(height: 12),
            // Sleep debt + bedtime consistency
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'หนี้การนอน 5 วัน',
                    value: '−${_fmt(sleepDebtMin)}',
                    valueColor: const Color(0xFFEAAA08),
                  ),
                ),
                Container(width: 1, height: 36, color: const Color(0xFFEFF1F0)),
                Expanded(
                  child: _StatTile(
                    icon: Icons.schedule,
                    title: 'เข้านอนสม่ำเสมอ',
                    value: '$bedtime ± $bedtimeVarianceMin น.',
                    valueColor: _ink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageLegend extends StatelessWidget {
  const _StageLegend({
    required this.label,
    required this.duration,
    required this.color,
  });

  final String label;
  final String duration;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6D756E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          duration,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF8A97A3)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 11,
                    color: Color(0xFF8A97A3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Google Sans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
