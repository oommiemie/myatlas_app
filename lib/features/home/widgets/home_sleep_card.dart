import 'package:flutter/material.dart';

const _ink = Color(0xFF1A1A2E);
const _muted = Color(0xFF8A97A3);

const _deep = Color(0xFF5E35B1);
const _rem = Color(0xFFAF52DE);
const _light = Color(0xFFB39DDB);
const _awake = Color(0xFFD9D2E0);

String _fmt(int minutes) {
  final m = minutes.abs();
  final h = m ~/ 60;
  final mm = m % 60;
  if (h == 0) return '$mm น.';
  return '$h ชม. ${mm.toString().padLeft(2, '0')} น.';
}

const _hairline = Color(0xFFEFF1F0);

/// Surface for each of the three sleep widgets. Shares the white background of
/// the surrounding [_GroupShell] — the widgets are separated by hairline rules,
/// not by colour or elevation.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

/// White elevated card wrapping all three sleep widgets into one group.
class _GroupShell extends StatelessWidget {
  const _GroupShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // No padding here — each child pads itself, so the dividers between them
    // can run edge to edge.
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

/// Sleep summary — a sleep score, last-night's stage breakdown (deep / REM /
/// light / awake), accumulated sleep debt and bedtime consistency. Composes the
/// three sleep widgets: a tappable summary on top, two read-only stats below.
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

  @override
  Widget build(BuildContext context) {
    return _GroupShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeSleepSummaryCard(
            score: score,
            deepMin: deepMin,
            remMin: remMin,
            lightMin: lightMin,
            awakeMin: awakeMin,
            onTap: onTap,
          ),
          const Divider(height: 1, thickness: 1, color: _hairline),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: HomeSleepDebtCard(sleepDebtMin: sleepDebtMin)),
                const VerticalDivider(width: 1, thickness: 1, color: _hairline),
                Expanded(
                  child: HomeBedtimeCard(
                    bedtime: bedtime,
                    bedtimeVarianceMin: bedtimeVarianceMin,
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

/// Last night's score, total time and stage breakdown. Tapping opens the full
/// sleep detail screen.
class HomeSleepSummaryCard extends StatelessWidget {
  const HomeSleepSummaryCard({
    super.key,
    this.score = 82,
    this.deepMin = 78,
    this.remMin = 96,
    this.lightMin = 222,
    this.awakeMin = 12,
    this.onTap,
  });

  final int score;
  final int deepMin;
  final int remMin;
  final int lightMin;
  final int awakeMin;
  final VoidCallback? onTap;

  int get _totalMin => deepMin + remMin + lightMin + awakeMin;

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
      child: _CardShell(
        padding: const EdgeInsets.all(16),
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
                    '/100 คะแนน',
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
          ],
        ),
      ),
    );
  }
}

/// Explains a stat when the tile is tapped. These tiles never navigate, so the
/// tooltip is the whole of their interaction.
class _InfoTooltip extends StatelessWidget {
  const _InfoTooltip({required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 8),
      preferBelow: false,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _ink.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Google Sans',
        fontSize: 12,
        height: 1.55,
        color: Colors.white,
      ),
      child: child,
    );
  }
}

const _infoIcon = Icon(Icons.info_outline, size: 13, color: _muted);

/// Accumulated sleep debt over the last 5 days. Read-only — tapping explains
/// the number rather than navigating.
class HomeSleepDebtCard extends StatelessWidget {
  const HomeSleepDebtCard({super.key, this.sleepDebtMin = -192});

  final int sleepDebtMin;

  @override
  Widget build(BuildContext context) {
    return _InfoTooltip(
      message: 'หนี้การนอน คือชั่วโมงที่คุณนอนขาดจากเป้าหมาย '
          'สะสมรวมกันตลอด 5 วันที่ผ่านมา\n\n'
          'ตอนนี้คุณนอนขาดไป ${_fmt(sleepDebtMin)} '
          'ลองเข้านอนเร็วขึ้นวันละ 30–40 นาที เพื่อทยอยชดเชย '
          'การนอนชดเชยรวดเดียวในวันหยุดช่วยได้ไม่เท่าการทยอยคืน',
      child: _CardShell(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: _StatTile(
          icon: Icons.account_balance_wallet_outlined,
          title: 'หนี้การนอน 5 วัน',
          value: '−${_fmt(sleepDebtMin)}',
          valueColor: const Color(0xFFEAAA08),
          trailing: _infoIcon,
        ),
      ),
    );
  }
}

/// Average bedtime and how much it varies. Read-only — tapping explains the
/// number rather than navigating.
class HomeBedtimeCard extends StatelessWidget {
  const HomeBedtimeCard({
    super.key,
    this.bedtime = '23:14',
    this.bedtimeVarianceMin = 38,
  });

  final String bedtime;
  final int bedtimeVarianceMin;

  @override
  Widget build(BuildContext context) {
    return _InfoTooltip(
      message: 'เข้านอนสม่ำเสมอ วัดจากเวลาเข้านอนเฉลี่ยของคุณ '
          'และค่าความแกว่งจากเวลานั้น\n\n'
          'ช่วง 5 วันที่ผ่านมาคุณเข้านอนราว $bedtime น. '
          'โดยแกว่งขึ้นลงเฉลี่ย $bedtimeVarianceMin นาที\n\n'
          'ยิ่งค่าความแกว่งน้อย นาฬิกาชีวภาพยิ่งนิ่ง '
          'หลับง่ายขึ้นและตื่นสดชื่นขึ้น แม้ชั่วโมงนอนจะเท่าเดิม',
      child: _CardShell(
        padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
        child: _StatTile(
          icon: Icons.schedule,
          title: 'เข้านอนสม่ำเสมอ',
          value: '$bedtime ± $bedtimeVarianceMin น.',
          valueColor: _ink,
          trailing: _infoIcon,
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
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color valueColor;

  /// Sits after the title — e.g. an info affordance.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF8A97A3)),
            const SizedBox(width: 4),
            // Expanded, not Flexible — the title takes the slack so `trailing`
            // is pushed to the right edge of the tile.
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  fontSize: 11,
                  color: Color(0xFF8A97A3),
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!,
            ],
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
    );
  }
}
