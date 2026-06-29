import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Food-scan viewfinder icon (Figma node 856:5018).
const String _kScanFoodSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<g clip-path="url(#clip0_856_5018)">
<path d="M0 6.81163C0 7.35068 0.433082 7.79172 0.962407 7.79172C1.50376 7.79172 1.93685 7.35068 1.93685 6.81163V4.49616C1.93685 2.94027 2.85113 1.99694 4.39098 1.99694H6.71279C7.24212 1.99694 7.68722 1.54364 7.68722 1.00459C7.68722 0.465543 7.24212 0.0245018 6.71279 0.0245018H4.39098C1.66016 0.0245018 0 1.7274 0 4.49616V6.81163ZM23.5549 6.81163V4.49616C23.5549 1.7274 21.8947 0.0245018 19.1639 0.0245018H16.8301C16.3007 0.0245018 15.8677 0.465543 15.8677 1.00459C15.8677 1.54364 16.3007 1.99694 16.8301 1.99694H19.1639C20.7037 1.99694 21.618 2.94027 21.618 4.49616V6.81163C21.618 7.35068 22.0512 7.79172 22.5805 7.79172C23.1098 7.79172 23.5549 7.35068 23.5549 6.81163ZM0 17.2128V19.5283C0 22.297 1.66016 24 4.39098 24H6.71279C7.24212 24 7.68722 23.5589 7.68722 23.0198C7.68722 22.4808 7.24212 22.0275 6.71279 22.0275H4.39098C2.85113 22.0275 1.93685 21.0841 1.93685 19.5283V17.2128C1.93685 16.6738 1.50376 16.2205 0.962407 16.2205C0.433082 16.2205 0 16.6738 0 17.2128ZM23.5549 17.2128C23.5549 16.6738 23.1098 16.2205 22.5805 16.2205C22.0512 16.2205 21.618 16.6738 21.618 17.2128V19.5283C21.618 21.0841 20.7037 22.0275 19.1639 22.0275H16.8301C16.3007 22.0275 15.8677 22.4808 15.8677 23.0198C15.8677 23.5589 16.3007 24 16.8301 24H19.1639C21.8947 24 23.5549 22.297 23.5549 19.5283V17.2128Z" fill="white"/>
<path d="M19.0384 11.9965C19.0384 15.9616 15.8804 19.193 11.9898 19.193C8.10614 19.193 4.94116 15.9616 4.94116 11.9965C4.94116 8.02431 8.10614 4.8 11.9898 4.8C15.8804 4.8 19.0384 8.02431 19.0384 11.9965ZM10.1793 7.53043L10.1378 10.0633C10.1378 10.1903 10.048 10.2891 9.90284 10.2891C9.77846 10.2891 9.68171 10.1903 9.68171 10.0563L9.71627 7.59393C9.71627 7.41049 9.61952 7.2976 9.45366 7.2976C9.29472 7.2976 9.19107 7.40344 9.18416 7.58687L9.07359 10.1056C9.03904 10.8323 9.26708 11.0793 9.8061 11.3121C9.93048 11.3686 9.99268 11.4814 9.99268 11.6226L9.90975 16.2368C9.90284 16.5754 10.1171 16.7588 10.4488 16.7588C10.7874 16.7588 11.0016 16.5754 10.9878 16.2368L10.9187 11.6226C10.9187 11.4814 10.974 11.3686 11.0983 11.3121C11.6304 11.0793 11.8654 10.8323 11.8309 10.1056L11.7134 7.58687C11.6996 7.40344 11.6097 7.2976 11.4439 7.2976C11.2849 7.2976 11.1882 7.41049 11.1882 7.59393L11.2227 10.0563C11.2227 10.1903 11.126 10.2891 10.9878 10.2891C10.8496 10.2891 10.7528 10.1903 10.7528 10.0633L10.7252 7.53043C10.7252 7.34699 10.6077 7.24821 10.4488 7.24821C10.2898 7.24821 10.1793 7.34699 10.1793 7.53043ZM13.6621 7.52338C13.0125 8.44763 12.5841 10.1833 12.5841 11.8201V12.0953C12.5841 12.3845 12.6946 12.5821 12.895 12.7303L13.1231 12.8995C13.2682 12.9984 13.3373 13.1112 13.3304 13.2665L13.2406 16.2156C13.2337 16.5754 13.4548 16.7588 13.7796 16.7588C14.1251 16.7588 14.3324 16.5896 14.3324 16.258V7.55159C14.3324 7.33993 14.1873 7.24821 14.0422 7.24821C13.897 7.24821 13.7865 7.33288 13.6621 7.52338Z" fill="white"/>
</g>
<defs>
<clipPath id="clip0_856_5018">
<rect width="24" height="24" fill="white"/>
</clipPath>
</defs>
</svg>
''';

/// Dashboard row shown right under the banner (Figma node 885:4888): a tall
/// green "meal analysis" card on the left, and two stacked cards on the right
/// (smart-watch status + family).
class HomeSummaryDashboard extends StatelessWidget {
  const HomeSummaryDashboard({
    super.key,
    this.calories = 800,
    this.calorieTarget = 1500,
    this.weightKg = 67,
    this.heightCm = 175,
    this.bmi = 20.1,
    this.watchName = 'Smart Watch BM 2',
    this.watchBattery = 30,
    this.watchConnected = true,
    this.familyCount = 4,
    // Same members, order and per-status colours as the family page
    // (kFamilyMembers): สมชาย & ปรีชา need attention → warm/red ring.
    this.familyAvatars = const [
      DashboardAvatar('assets/images/family/somsri.png'),
      DashboardAvatar('assets/images/family/jaidee.png'),
      DashboardAvatar('assets/images/family/somchai.png', alert: true),
      DashboardAvatar('assets/images/family/preecha.png', alert: true),
    ],
    this.onTap,
    this.onScanTap,
    this.onWatchTap,
    this.onFamilyTap,
    this.watchFamilyRowOnly = false,
  });

  final int calories;
  final int calorieTarget;
  final int weightKg;
  final int heightCm;
  final double bmi;
  final String watchName;
  final int watchBattery;
  final bool watchConnected;
  final int familyCount;
  final List<DashboardAvatar> familyAvatars;
  final VoidCallback? onTap;
  final VoidCallback? onScanTap;
  final VoidCallback? onWatchTap;
  final VoidCallback? onFamilyTap;

  /// When true, renders ONLY the smart-watch + family cards side-by-side
  /// (family left, watch right) — no meal-analysis card. Used to slot the pair
  /// in below the existing food-scan section on the home screen.
  final bool watchFamilyRowOnly;

  static const _primary600 = Color(0xFF1D8B6B);
  static const _primary900 = Color(0xFF093327);
  static const _primary50 = Color(0xFFE4F5F0);
  static const _success50 = Color(0xFFFAFEF5);
  static const _success600 = Color(0xFF4CA30D);
  static const _neutral500 = Color(0xFF737373);
  static const _textTertiary = Color(0xFF6D756E);
  static const _border = Color(0xFFE5E5E5);

  static const List<BoxShadow> _cardShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    if (watchFamilyRowOnly) {
      return SizedBox(
        height: 92,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _familyCard()),
            const SizedBox(width: 16),
            Expanded(child: _watchCard()),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: SizedBox(
        height: 217,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _mealCard()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _watchCard()),
                  const SizedBox(height: 16),
                  Expanded(child: _familyCard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Left: meal-analysis card ──────────────────────────────────────────────
  Widget _mealCard() {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [_primary600, _primary900],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _border, width: 0.5),
          boxShadow: _cardShadow,
        ),
        child: Stack(
          children: [
            // Salad artwork bleeding out the top-left corner.
            Positioned(
              left: -22,
              top: -30,
              child: Transform.rotate(
                angle: 22.11 * math.pi / 180,
                child: Image.asset('assets/images/salad_top.png',
                    width: 96, height: 96, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Column(
                children: [
                  // Header: title + scan button.
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'วิเคราะห์\nอาหาร 1/16',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.15,
                              color: Color(0xCCFFFFFF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: onScanTap,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: SvgPicture.string(
                              _kScanFoodSvg,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Macronutrient white panel.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border, width: 0.5),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          _CalorieGauge(
                            calories: calories,
                            target: calorieTarget,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _stat('$weightKg', 'kg')),
                              _vDivider(),
                              Expanded(child: _stat('$heightCm', 'cm')),
                              _vDivider(),
                              Expanded(
                                child: _stat(
                                    bmi.toStringAsFixed(1), 'BMI')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 28, color: _border);

  Widget _stat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 14 / 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 12,
            color: _neutral500,
          ),
        ),
      ],
    );
  }

  // ── Right top: smart-watch card ───────────────────────────────────────────
  Widget _watchCard() {
    return GestureDetector(
      onTap: onWatchTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.white, _success50],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
          child: Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: _WatchHalo(battery: (watchBattery / 100).clamp(0.0, 1.0)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      watchName,
                      style: const TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.battery_3_bar,
                            size: 15, color: Color(0xFF222222)),
                        const SizedBox(width: 4),
                        Text(
                          '$watchBattery %',
                          style: const TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 12,
                            color: _textTertiary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.bluetooth,
                            size: 11,
                            color: watchConnected
                                ? _success600
                                : _textTertiary),
                        const SizedBox(width: 3),
                        Text(
                          watchConnected ? 'เชื่อมต่ออยู่' : 'ไม่ได้เชื่อมต่อ',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 9,
                            color: watchConnected
                                ? _success600
                                : _textTertiary,
                          ),
                        ),
                      ],
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

  // ── Right bottom: family card ─────────────────────────────────────────────
  Widget _familyCard() {
    return GestureDetector(
      onTap: onFamilyTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.white, _primary50],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'ครอบครัวของฉัน',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 16, color: Color(0xFF1A1A1A)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'จำนวน $familyCount คน',
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 12,
                      color: _textTertiary,
                    ),
                  ),
                ],
              ),
              _AvatarStack(avatars: familyAvatars),
            ],
          ),
        ),
      ),
    );
  }
}

/// A family avatar with the same per-status background as the family page.
class DashboardAvatar {
  const DashboardAvatar(this.image, {this.alert = false});
  final String image;
  final bool alert;
}

/// Overlapping family avatars — white ring + status-coloured gradient ring +
/// photo, mirroring the family page (kFamilyMembers) avatar treatment.
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.avatars});
  final List<DashboardAvatar> avatars;

  static const double _size = 36;
  static const double _overlap = 8;

  // Same gradients as care_giver_screen: attention → warm/red, else teal-green.
  static const _safe = [Color(0x8068C7AD), Color(0x801D8B6B)];
  static const _attention = [Color(0x80FF9C66), Color(0x80BC1B06)];

  @override
  Widget build(BuildContext context) {
    final step = _size - _overlap;
    return SizedBox(
      height: _size,
      width: _size + step * (avatars.length - 1),
      child: Stack(
        children: [
          for (int i = 0; i < avatars.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: avatars[i].alert ? _attention : _safe,
                  ),
                ),
                // Inset so the gradient shows as a thin ring around the photo.
                padding: const EdgeInsets.all(1.5),
                child: ClipOval(
                  child: Image.asset(avatars[i].image, fit: BoxFit.cover),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Semicircular calorie gauge: grey track + green progress, with the consumed
/// calories and the daily target underneath.
class _CalorieGauge extends StatelessWidget {
  const _CalorieGauge({required this.calories, required this.target});
  final int calories;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = (calories / target).clamp(0.0, 1.0);
    return SizedBox(
      width: 136,
      height: 74,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, p, __) => CustomPaint(
              size: const Size(136, 74),
              painter: _GaugePainter(p),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$calories',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmt(target)} kcal',
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 12,
                    color: Color(0xFF737373),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.progress);
  final double progress;

  // ~190° arc opening at the bottom (endpoints dip just below horizontal),
  // matching the Figma "Ellipse 9" track (136 × 73).
  static const double _start = 175 * math.pi / 180;
  static const double _sweep = 190 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final center = Offset(size.width / 2, size.height - 6);
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = const Color(0xFFEAEDE8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep, false, track);

    final p = progress.clamp(0.0, 1.0);
    if (p > 0) {
      // Lime → green gradient running along the filled portion of the arc.
      final fg = Paint()
        ..shader = SweepGradient(
          startAngle: _start,
          endAngle: _start + _sweep * p,
          colors: const [Color(0xFFC8E6A0), Color(0xFF52A828)],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, _start, _sweep * p, false, fg);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.progress != progress;
}

/// Smart-watch glow: concentric ripple rings around a small watch, with the
/// outer ring acting as a battery progress ring (Figma node 885:4885).
class _WatchHalo extends StatelessWidget {
  const _WatchHalo({required this.battery});

  /// Battery level 0..1 — drives the outer progress ring.
  final double battery;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Rings + glow + battery progress.
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: battery),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => CustomPaint(painter: _WatchHaloPainter(v)),
          ),
        ),
        // Real watch photo in the centre.
        Image.asset(
          'assets/watch.png',
          width: 46,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _WatchHaloPainter extends CustomPainter {
  _WatchHaloPainter(this.battery);
  final double battery;

  static const double _rOuter = 31;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // Smooth radial glow base (white centre fading out — no blur, so it stays
    // perfectly clean).
    canvas.drawCircle(
      c,
      32,
      Paint()
        ..shader = RadialGradient(
          colors: const [Colors.white, Color(0x00FFFFFF)],
          stops: const [0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: 32)),
    );

    // Outer ring = battery progress.
    final ringRect = Rect.fromCircle(center: c, radius: _rOuter);
    // Track.
    canvas.drawArc(
      ringRect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..color = const Color(0xFFEAEDE8),
    );
    // Progress arc from the top, clockwise.
    const start = -math.pi / 2;
    final sweep = battery.clamp(0.0, 1.0) * 2 * math.pi;
    if (sweep > 0) {
      canvas.drawArc(
        ringRect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.8
          ..strokeCap = StrokeCap.round
          ..shader = const SweepGradient(
            startAngle: start,
            endAngle: start + 2 * math.pi,
            colors: [Color(0xFFFFC400), Color(0xFFFFD60A)],
          ).createShader(ringRect),
      );
    }

    // Yellow indicator dot at the tip of the battery progress.
    final tipAngle = start + sweep;
    final tip = c + Offset(math.cos(tipAngle) * _rOuter, math.sin(tipAngle) * _rOuter);
    canvas.drawCircle(tip, 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(tip, 3, Paint()..color = const Color(0xFFFFD60A));
  }

  @override
  bool shouldRepaint(covariant _WatchHaloPainter old) => old.battery != battery;
}
