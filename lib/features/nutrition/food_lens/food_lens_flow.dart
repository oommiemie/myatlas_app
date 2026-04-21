import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_typography.dart';
import '../data/meal_store.dart';

const _fallbackImage = 'assets/images/meal_basil_chicken.png';

void openFoodLens(BuildContext context) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      fullscreenDialog: true,
      builder: (_) => const FoodLensCameraScreen(),
    ),
  );
}

const _foodHeroTag = 'food-lens-photo';

Widget _foodImageWidget(String? path,
    {BoxFit fit = BoxFit.cover, String? assetOverride}) {
  if (path != null) {
    return Image.file(File(path), fit: fit);
  }
  return Image.asset(assetOverride ?? _fallbackImage, fit: fit);
}

Widget _foodImageHero(String? path,
    {BoxFit fit = BoxFit.cover, String? assetOverride, Object? tag}) {
  final heroTag = tag ?? _foodHeroTag;
  return Hero(
    tag: heroTag,
    flightShuttleBuilder: (_, animation, __, ___, ____) {
      return _foodImageWidget(path,
          fit: fit, assetOverride: assetOverride);
    },
    child: _foodImageWidget(path, fit: fit, assetOverride: assetOverride),
  );
}

class FoodLensCameraScreen extends StatefulWidget {
  const FoodLensCameraScreen({super.key});

  @override
  State<FoodLensCameraScreen> createState() => _FoodLensCameraScreenState();
}

class _FoodLensCameraScreenState extends State<FoodLensCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 88,
      );
      if (!mounted) return;
      if (file == null) {
        setState(() => _busy = false);
        return;
      }
      await Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => _PreviewScreen(imagePath: file.path),
        ),
      );
      if (mounted) setState(() => _busy = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('ไม่สามารถเปิดกล้อง'),
          content: Text('$e'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_fallbackImage, fit: BoxFit.cover),
          Container(color: CupertinoColors.black.withValues(alpha: 0.35)),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  leading: _GlassIcon(
                    icon: CupertinoIcons.xmark,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  title: 'Food Lens',
                ),
                const Spacer(),
                const _ViewfinderFrame(),
                const Spacer(),
                _BottomActions(
                  onGallery: () => _pick(ImageSource.gallery),
                  onCapture: () => _pick(ImageSource.camera),
                  onFlash: () {},
                  busy: _busy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.leading, required this.title});
  final Widget leading;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          leading,
          Expanded(
            child: Center(
              child: Text(
                title,
                style: AppTypography.callout(CupertinoColors.white).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _ViewfinderFrame extends StatelessWidget {
  const _ViewfinderFrame();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: CupertinoColors.white.withValues(alpha: 0.75),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.icon, required this.onTap, this.size = 36});
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.white.withValues(alpha: 0.22),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: CupertinoColors.white, size: size * 0.45),
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onGallery,
    required this.onCapture,
    required this.onFlash,
    required this.busy,
  });
  final VoidCallback onGallery;
  final VoidCallback onCapture;
  final VoidCallback onFlash;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: onGallery,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                image: const DecorationImage(
                  image: AssetImage(_fallbackImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Spacer(),
          _CaptureButton(onTap: onCapture, busy: busy),
          const Spacer(),
          _GlassIcon(
            icon: CupertinoIcons.bolt_fill,
            onTap: onFlash,
            size: 40,
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.onTap,
    this.icon = Icons.photo_camera,
    this.busy = false,
  });
  final VoidCallback onTap;
  final IconData icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE4F0), Color(0xFFE4E0FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: CupertinoColors.white,
          ),
          alignment: Alignment.center,
          child: busy
              ? const CupertinoActivityIndicator(radius: 12)
              : Icon(icon, color: const Color(0xFF1A1A1A), size: 30),
        ),
      ),
    );
  }
}

class _PreviewScreen extends StatelessWidget {
  const _PreviewScreen({required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: _foodImageHero(imagePath)),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Food Lens',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      const Spacer(),
                      _CaptureButton(
                        icon: Icons.auto_awesome,
                        onTap: () => _goAnalyzing(context),
                      ),
                      const Spacer(),
                      _GlassIcon(
                        icon: CupertinoIcons.xmark,
                        size: 40,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goAnalyzing(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) =>
            _AnalyzingScreen(imagePath: imagePath),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _AnalyzingScreen extends StatefulWidget {
  const _AnalyzingScreen({required this.imagePath});
  final String imagePath;

  @override
  State<_AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<_AnalyzingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _rotate;
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _rotate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      final analysis = pickAnalysis();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => FoodLensResultsScreen(
            imagePath: widget.imagePath,
            analysis: analysis,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _rotate.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: _foodImageHero(widget.imagePath)),
          Container(color: CupertinoColors.black.withValues(alpha: 0.32)),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _rotate,
              builder: (_, __) => CustomPaint(
                painter: _AuraPainter(phase: _rotate.value),
                size: Size.infinite,
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _rotate,
              builder: (_, __) => CustomPaint(
                painter: _ConicBorderPainter(phase: _rotate.value),
                size: Size.infinite,
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulse, _rotate]),
              builder: (_, __) {
                final pulseT = Curves.easeInOutCubic.transform(_pulse.value);
                final zoom = 0.78 + 0.32 * pulseT;
                final angle = _rotate.value * 2 * pi;
                return Transform.rotate(
                  angle: angle,
                  child: Transform.scale(
                    scale: zoom,
                    child: SvgPicture.asset(
                      'assets/images/sparkle.svg',
                      width: 160,
                      height: 160,
                      colorFilter: const ColorFilter.mode(
                        CupertinoColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: AnimatedBuilder(
              animation: _shimmer,
              builder: (_, __) => Center(
                child: Opacity(
                  opacity: 0.7 + 0.3 * _shimmer.value,
                  child: Text(
                    'กำลังวิเคราะห์โภชนาการ...',
                    style: AppTypography.callout(CupertinoColors.white)
                        .copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuraPainter extends CustomPainter {
  _AuraPainter({required this.phase});
  final double phase;

  static const _blobs = [
    _AuraBlob(color: Color(0xFFFF6B9D), anchor: Alignment(-1.0, -1.0)),
    _AuraBlob(color: Color(0xFF7EC8FF), anchor: Alignment(1.0, -0.2)),
    _AuraBlob(color: Color(0xFFE4B5FF), anchor: Alignment(-0.2, 1.0)),
    _AuraBlob(color: Color(0xFFFFD685), anchor: Alignment(1.0, 1.0)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _blobs.length; i++) {
      final blob = _blobs[i];
      final t = phase * 2 * pi + i * pi / 2;
      final drift = Offset(cos(t) * 24, sin(t * 0.85) * 20);
      final center = blob.anchor.alongSize(size) + drift;
      final breath = 0.9 + 0.1 * sin(t * 0.7);
      final r = (size.shortestSide * 0.65) * breath;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = blob.color.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuraPainter old) => old.phase != phase;
}

class _AuraBlob {
  const _AuraBlob({required this.color, required this.anchor});
  final Color color;
  final Alignment anchor;
}

class _ConicBorderPainter extends CustomPainter {
  _ConicBorderPainter({required this.phase});
  final double phase;

  static const _colors = [
    Color(0xFFFF6B9D),
    Color(0xFFE4B5FF),
    Color(0xFF7EC8FF),
    Color(0xFF95F0C4),
    Color(0xFFFFD685),
    Color(0xFFFF6B9D),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 10.0;
    final rect = Rect.fromLTRB(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(60));
    final shader = SweepGradient(
      colors: _colors,
      transform: GradientRotation(phase * 2 * pi),
    ).createShader(rect);

    // Outer halo — wide blur
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 36
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32),
    );
    // Mid glow
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Sharp thin colored rim
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // White inner highlight
    canvas.drawRRect(
      rrect.deflate(1.0),
      Paint()
        ..color = CupertinoColors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant _ConicBorderPainter old) =>
      old.phase != phase;
}

class FoodLensResultsScreen extends StatefulWidget {
  const FoodLensResultsScreen({
    super.key,
    this.imagePath,
    this.assetImage,
    this.analysis,
    this.readOnly = false,
    this.heroTag,
  });
  final String? imagePath;
  final String? assetImage;
  final MealAnalysis? analysis;
  final bool readOnly;
  final Object? heroTag;

  @override
  State<FoodLensResultsScreen> createState() => _FoodLensResultsScreenState();
}

class _FoodLensResultsScreenState extends State<FoodLensResultsScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      _scrollOffset.value = _scrollCtrl.offset;
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  MealAnalysis get _a =>
      widget.analysis ?? kMealAnalysisOptions.first;

  void _save(BuildContext context) {
    final a = _a;
    MealStore.instance.add(
      MealEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: a.name,
        nameEn: a.nameEn,
        time: DateTime.now(),
        calories: a.calories,
        grams: a.grams,
        imagePath: widget.imagePath,
        assetImage: widget.imagePath == null ? _fallbackImage : null,
        description: a.description,
        protein: a.protein,
        carbs: a.carbs,
        fat: a.fat,
        fiber: a.fiber,
        sugar: a.sugar,
        tips: a.tips,
        warning: a.warning,
      ),
    );
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('บันทึกสำเร็จ'),
        content: Text('${a.name} ถูกเพิ่มลงในบันทึกอาหารวันนี้แล้ว'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = _a;
    final kcalProgress = (a.calories / 2200).clamp(0.0, 1.0);
    final progressPct = (kcalProgress * 100).round();
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 550,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (_, offset, child) {
                final overscroll = offset < 0 ? -offset : 0.0;
                final scrollUp = offset > 0 ? offset : 0.0;
                final scale = 1 + overscroll / 240;
                return Transform.translate(
                  offset: Offset(0, -scrollUp),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                );
              },
              child: _ResultsHeader(
                imagePath: widget.imagePath,
                assetImage: widget.assetImage,
                heroTag: widget.heroTag,
                analysis: a,
              ),
            ),
          ),
          ListView(
            controller: _scrollCtrl,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 550),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _NutrientStatCard(
                    value: '${a.calories}',
                    unit: 'kcl',
                    label: 'แคลอรี่ (kcal)',
                    progress: kcalProgress,
                    progressLabel: '$progressPct% ของเป้าหมายต่อวัน',
                    gradient: const [
                      Color(0xFFFF9C66),
                      Color(0xFFBC1B06),
                    ],
                    ellipseColor: const Color(0xFFBC1B06),
                    badgeAsset: 'assets/images/stat_kcal.png',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NutrientStatCard(
                    value: '${a.grams}',
                    unit: 'g',
                    label: 'น้ำหนักโดยประมาณ (g)',
                    subLabel: '${a.name} (${a.nameEn})',
                    gradient: const [
                      Color(0xFF3B82F6),
                      Color(0xFF1D4ED8),
                    ],
                    ellipseColor: const Color(0xFF1D4ED8),
                    badgeAsset: 'assets/images/stat_salad.png',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _VitalSummaryCard(
              onSeeMore: () => showVitalSignsSheet(context),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _MacronutrientCard(analysis: a),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _NutritionTipsCard(analysis: a),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WarningCard(analysis: a),
          ),
              const SizedBox(height: 32),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (_, offset, __) => _PinnedTopBar(
                scrollOffset: offset,
                title: widget.readOnly ? 'Nutrition' : 'Food Lens',
                leadingIcon: widget.readOnly
                    ? CupertinoIcons.chevron_back
                    : CupertinoIcons.xmark,
                onClose: () => widget.readOnly
                    ? Navigator.of(context).pop()
                    : Navigator.of(context).popUntil((r) => r.isFirst),
                onConfirm: widget.readOnly ? null : () => _save(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveCircleIcon extends StatelessWidget {
  const _AdaptiveCircleIcon({
    required this.icon,
    required this.progress,
    required this.onTap,
  });
  final IconData icon;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = progress > 0.5;
    final bgColor = isLight
        ? CupertinoColors.white
        : CupertinoColors.white.withValues(alpha: 0.22);
    final iconColor =
        isLight ? const Color(0xFF1A1A1A) : CupertinoColors.white;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: isLight
              ? Border.all(
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.08),
                  width: 0.5,
                )
              : Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.35),
                  width: 0.5,
                ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: isLight
                ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                : ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Center(
              child: Icon(icon, color: iconColor, size: 22, weight: 700),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinnedTopBar extends StatelessWidget {
  const _PinnedTopBar({
    required this.onClose,
    required this.title,
    this.onConfirm,
    this.leadingIcon = CupertinoIcons.xmark,
    this.scrollOffset = 0,
  });
  final double scrollOffset;
  final VoidCallback onClose;
  final String title;
  final VoidCallback? onConfirm;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final progress = (scrollOffset / 160).clamp(0.0, 1.0);
    final barHeight = top + 6 + 44 + 6;
    final titleColor = Color.lerp(
      CupertinoColors.white,
      const Color(0xFF1A1A1A),
      progress,
    )!;
    return Stack(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22 * progress,
              sigmaY: 22 * progress,
            ),
            child: Container(
              height: barHeight,
              color: const Color(0xFFF4F8F5)
                  .withValues(alpha: 0.80 * progress),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: progress,
            child: Container(
              height: 0.5,
              color: CupertinoColors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: top + 6,
            left: 14,
            right: 14,
          ),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    shadows: progress < 0.5
                        ? [
                            Shadow(
                              color: CupertinoColors.black
                                  .withValues(alpha: 0.35 * (1 - progress)),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
            Align(
              alignment: Alignment.centerLeft,
              child: _AdaptiveCircleIcon(
                icon: leadingIcon,
                progress: progress,
                onTap: onClose,
              ),
            ),
            if (onConfirm != null)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2CA989),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2CA989)
                              .withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.check_mark,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MacronutrientCard extends StatelessWidget {
  const _MacronutrientCard({required this.analysis});
  final MealAnalysis analysis;

  List<_MacroItem> get _items => [
        _MacroItem('โปรตีน', '${analysis.protein}g', const Color(0xFF3B82F6)),
        _MacroItem(
            'คาร์โบไฮเดรต', '${analysis.carbs}g', const Color(0xFF22C55E)),
        _MacroItem('ไขมัน', '${analysis.fat}g', const Color(0xFFF59E0B)),
        _MacroItem('ใยอาหาร', '${_trim(analysis.fiber)}g',
            const Color(0xFFEF4444)),
      ];

  _MacroItem get _sugarItem => _MacroItem(
      'น้ำตาล', '${analysis.sugar}g', const Color(0xFFA855F7));

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'สารอาหารหลัก',
              style: AppTypography.callout(const Color(0xFF1A1A1A))
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _PiePainter(
                      values: [
                        for (final m in _items) _valueOf(m.value),
                      ],
                      colors: [for (final m in _items) m.color],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      for (final m in _items) _row(m),
                      const SizedBox(height: 6),
                      Container(
                        height: 1,
                        color: const Color(0xFFE5E5E5),
                      ),
                      const SizedBox(height: 6),
                      _row(_sugarItem),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static double _valueOf(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  Widget _row(_MacroItem m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: m.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              m.label,
              style: AppTypography.callout(const Color(0xFF1A1A1A))
                  .copyWith(fontSize: 14),
            ),
          ),
          Text(
            m.value,
            style: AppTypography.callout(const Color(0xFF1A1A1A)).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroItem {
  const _MacroItem(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.values, required this.colors});
  final List<double> values;
  final List<Color> colors;

  static Color _shift(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + delta).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return;

    canvas.drawCircle(
      center.translate(0, 3),
      radius,
      Paint()
        ..color = CupertinoColors.black.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    double start = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      final base = colors[i];
      final light = _shift(base, 0.14);
      final dark = _shift(base, -0.10);
      final paint = Paint()
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + sweep,
          colors: [light, base, dark],
          tileMode: TileMode.clamp,
        ).createShader(rect);
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }

    start = -pi / 2;
    final dividerPaint = Paint()
      ..color = CupertinoColors.white.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      final end = Offset(
        center.dx + radius * cos(start),
        center.dy + radius * sin(start),
      );
      canvas.drawLine(center, end, dividerPaint);
      start += sweep;
    }

    canvas.drawCircle(
      center,
      radius * 0.58,
      Paint()
        ..shader = RadialGradient(
          colors: [
            CupertinoColors.white,
            const Color(0xFFF8F8F9),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.58)),
    );
    canvas.drawCircle(
      center,
      radius * 0.58,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = CupertinoColors.black.withValues(alpha: 0.05),
    );
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.values != values || old.colors != colors;
}

class _NutritionTipsCard extends StatelessWidget {
  const _NutritionTipsCard({required this.analysis});
  final MealAnalysis analysis;

  List<String> get _tips =>
      analysis.tips.isNotEmpty ? analysis.tips : const [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'คำแนะนำด้านโภชนาการ',
              style: AppTypography.callout(const Color(0xFF1A1A1A))
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.sparkles,
                          size: 17, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'วิเคราะห์ข้อมูลตาม My Atlas ของคุณ',
                          style: AppTypography.callout(
                                  const Color(0xFF1A1A1A))
                              .copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _chip('BMI: 19.5'),
                      _divider(),
                      _chip('BP: 150/77'),
                      _divider(),
                      _chip('SpO₂: 95%'),
                      _divider(),
                      _chip('น้ำตาล: 120 mg/dL'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 16, 16),
            child: Column(
              children: [
                for (int i = 0; i < _tips.length; i++) ...[
                  _tipRow(i + 1, _tips[i]),
                  if (i != _tips.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) => Flexible(
        child: Text(
          text,
          style: AppTypography.caption2(const Color(0xFF6D756E))
              .copyWith(fontSize: 10),
          overflow: TextOverflow.ellipsis,
        ),
      );

  Widget _divider() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 1,
        height: 8,
        color: const Color(0xFFE5E5E5),
      );

  Widget _tipRow(int num, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF9B5CF6), Color(0xFF6B28D9)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$num',
            style: AppTypography.caption2(CupertinoColors.white).copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.callout(const Color(0xFF1A1A1A))
                .copyWith(fontSize: 14, height: 20 / 14),
          ),
        ),
      ],
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.analysis});
  final MealAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFFF383C);
    final text = analysis.warning.isNotEmpty
        ? analysis.warning
        : 'ตรวจสอบปริมาณก่อนทานเสมอ';
    return Container(
      decoration: BoxDecoration(
        color: danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CupertinoColors.white, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.exclamationmark_triangle_fill,
                  size: 16, color: danger),
              const SizedBox(width: 8),
              Text(
                'ข้อควรระวัง',
                style: AppTypography.callout(danger)
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: AppTypography.callout(danger)
                .copyWith(fontSize: 14, height: 20 / 14),
          ),
        ],
      ),
    );
  }
}


class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.analysis,
    this.imagePath,
    this.assetImage,
    this.heroTag,
  });
  final String? imagePath;
  final String? assetImage;
  final Object? heroTag;
  final MealAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 550,
      child: Stack(
        children: [
          Positioned.fill(
            child: _foodImageHero(
              imagePath,
              assetOverride: assetImage,
              tag: heroTag,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withValues(alpha: 0.55),
                    CupertinoColors.black.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withValues(alpha: 0.0),
                    CupertinoColors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1D8B6B),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.restaurant,
                                color: CupertinoColors.white, size: 14),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              analysis.name,
                              style: AppTypography.title2(
                                      CupertinoColors.white)
                                  .copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                shadows: const [
                                  Shadow(
                                    color: Color(0x26000000),
                                    offset: Offset(0, 4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        analysis.nameEn,
                        style: AppTypography.subheadline(
                          CupertinoColors.white,
                        ).copyWith(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      width: double.infinity,
                      color: CupertinoColors.white.withValues(alpha: 0.10),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        analysis.description,
                        style: AppTypography.callout(CupertinoColors.white)
                            .copyWith(fontSize: 14, height: 20 / 14),
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

class _NutrientStatCard extends StatelessWidget {
  const _NutrientStatCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.gradient,
    this.badgeAsset,
    this.ellipseColor,
    this.subLabel,
    this.progress,
    this.progressLabel,
  });

  final String value;
  final String unit;
  final String label;
  final String? subLabel;
  final double? progress;
  final String? progressLabel;
  final List<Color> gradient;
  final String? badgeAsset;
  final Color? ellipseColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: CupertinoColors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      gradient.first.withValues(alpha: 0.55),
                      gradient.last.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: CupertinoColors.black.withValues(alpha: 0.05),
              ),
            ),
            if (ellipseColor != null)
              Positioned(
                right: -50,
                top: 45,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ellipseColor!.withValues(alpha: 0.40),
                        ellipseColor!.withValues(alpha: 0.0),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
            if (badgeAsset != null)
              Positioned(
                right: 6,
                top: 0,
                child: Image.asset(
                  badgeAsset!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: AppTypography.title1(CupertinoColors.white)
                            .copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          unit,
                          style: AppTypography.caption2(CupertinoColors.white)
                              .copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.caption1(CupertinoColors.white)
                            .copyWith(fontSize: 11, height: 1.1),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (progress != null) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressBar(
                            progress: progress!.clamp(0.0, 1.0),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progressLabel ?? '',
                          style: AppTypography.caption2(
                            CupertinoColors.white.withValues(alpha: 0.85),
                          ).copyWith(fontSize: 10),
                        ),
                      ],
                      if (subLabel != null)
                        Text(
                          subLabel!,
                          style: AppTypography.caption2(
                            CupertinoColors.white.withValues(alpha: 0.85),
                          ).copyWith(fontSize: 10, height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LinearProgressBar extends StatelessWidget {
  const LinearProgressBar({super.key, required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class _VitalSummaryCard extends StatelessWidget {
  const _VitalSummaryCard({required this.onSeeMore});
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSeeMore,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: CupertinoColors.white,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 2,
              top: 2,
              width: 102,
              height: 102,
              child: Image.asset(
                'assets/images/vital_decor.png',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'วิเคราะห์ร่วม Vital Signs',
                          style: AppTypography.callout(
                                  const Color(0xFF1A1A1A))
                              .copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                        ),
                      ),
                      GestureDetector(
                        onTap: onSeeMore,
                        behavior: HitTestBehavior.opaque,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              height: 24,
                              alignment: Alignment.center,
                              color: CupertinoColors.white
                                  .withValues(alpha: 0.5),
                              child: Text(
                                'ดูเพิ่มเติม',
                                style: AppTypography.caption2(
                                        const Color(0xFF6D756E))
                                    .copyWith(
                                  fontSize: 12,
                                  letterSpacing: 0.275,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const _HealthRatingCard(
                  title: 'ดีมาก',
                  description: 'ทานได้แต่ควรควบคุมปริมาณ',
                  stats: [
                    _RatingStat('น้ำหนัก', '60', Icons.fitness_center),
                    _RatingStat('BMI', '19.5', Icons.monitor_weight),
                    _RatingStat('กิจกรรม', 'ปานกลาง', Icons.adjust),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _HealthRatingCard extends StatelessWidget {
  const _HealthRatingCard({
    required this.title,
    required this.description,
    required this.stats,
  });

  final String title;
  final String description;
  final List<_RatingStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF2CA989).withValues(alpha: 0.88),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.check_mark_circled_solid,
                        color: CupertinoColors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: AppTypography.title3(CupertinoColors.white)
                          .copyWith(
                              fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.caption1(
                    CupertinoColors.white.withValues(alpha: 0.92),
                  ).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                for (int i = 0; i < stats.length; i++) ...[
                  if (i > 0)
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFFE5E5E5),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Icon(stats[i].icon,
                                  size: 14,
                                  color: const Color(0xFF3E453F)),
                              const SizedBox(width: 6),
                              Text(
                                stats[i].label,
                                style: AppTypography.caption2(
                                  const Color(0xFF3E453F),
                                ).copyWith(
                                    fontSize: 10,
                                    letterSpacing: 0.275),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            stats[i].value,
                            style: AppTypography.callout(
                                    const Color(0xFF3E453F))
                                .copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStat {
  const _RatingStat(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

void showVitalSignsSheet(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const _VitalSignsSheet(),
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: anim,
              curve: Curves.fastEaseInToSlowEaseOut,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
          child: child,
        );
      },
    ),
  );
}

class _VitalSignsSheet extends StatelessWidget {
  const _VitalSignsSheet();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F5).withValues(alpha: 0.94),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.white.withValues(alpha: 0.7),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A)
                              .withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 40),
                          Expanded(
                            child: Center(
                              child: Text(
                                'วิเคราะห์ร่วม Vital Signs',
                                style: AppTypography.headline(
                                  const Color(0xFF1A1A1A),
                                ).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1A1A1A)
                                    .withValues(alpha: 0.06),
                              ),
                              child: const Icon(
                                CupertinoIcons.xmark,
                                color: Color(0xFF1A1A1A),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: const [
                          _HealthRatingCard(
                            title: 'ดีมาก',
                            description: 'ทานได้แต่ควรควบคุมปริมาณ',
                            stats: [
                              _RatingStat(
                                  'น้ำหนัก', '60', Icons.fitness_center),
                              _RatingStat(
                                  'BMI', '19.5', Icons.monitor_weight),
                              _RatingStat(
                                  'กิจกรรม', 'ปานกลาง', Icons.adjust),
                            ],
                          ),
                          SizedBox(height: 12),
                          _VitalDetailCard(
                            iconBg: Color(0xFFBE123C),
                            icon: Icons.monitor_heart_rounded,
                            title: 'ความดันโลหิต',
                            value: 'ค่าปัจจุบัน: 120/80 mmHg',
                            status: '(ปกติ)',
                            statusColor: Color(0xFF1D8B6B),
                            tint: Color(0x0DE62E05),
                            badgeText: 'ควรระวัง',
                            badgeColor: Color(0x33E62E05),
                            badgeTextColor: Color(0xFFE62E05),
                            description:
                                'โซเดียม 39% DV — ค่าความดันของคุณปกติ แต่ควรระวังไม่ให้ได้รับโซเดียมเกินจากมื้ออื่น',
                            note: 'รักษาระดับโซเดียมให้สมดุลตลอดทั้งวัน',
                          ),
                          SizedBox(height: 12),
                          _VitalDetailCard(
                            iconBg: Color(0xFFDB2777),
                            icon: CupertinoIcons.drop_fill,
                            title: 'น้ำตาลในเลือด',
                            value: 'ค่าปัจจุบัน: 120 mg/dL',
                            status: '(ปกติ)',
                            statusColor: Color(0xFF1D8B6B),
                            tint: Color(0x0D4CA30D),
                            badgeText: 'ปลอดภัย',
                            badgeColor: Color(0x334CA30D),
                            badgeTextColor: Color(0xFF4CA30D),
                            description:
                                'ค่าปัจจุบันของคุณอยู่ในเกณฑ์ดีมาก อาหารจานนี้ที่มีคาร์โบไฮเดรตต่ำ (และมีกากใยสูงจากผัก) จะช่วยรักษาระดับน้ำตาลให้คงที่ได้ดีเยี่ยมครับ',
                            note: 'รักษาสมดุลคาร์บตลอดวัน',
                          ),
                          SizedBox(height: 12),
                          _VitalDetailCard(
                            iconBg: Color(0xFFBE123C),
                            icon: CupertinoIcons.waveform_path_ecg,
                            title: 'Heart Rate',
                            value: 'ค่าปัจจุบัน: 72 bpm',
                            status: '(ปกติ)',
                            statusColor: Color(0xFF1D8B6B),
                            tint: Color(0x0D4CA30D),
                            badgeText: 'ปลอดภัย',
                            badgeColor: Color(0x334CA30D),
                            badgeTextColor: Color(0xFF4CA30D),
                            description:
                                'อัตราการเต้นหัวใจปกติ อาหารนี้ไม่มีผลกระทบต่อหัวใจโดยตรง',
                            note:
                                'รักษาสุขภาพหัวใจด้วยการออกกำลังกายสม่ำเสมอ',
                          ),
                          SizedBox(height: 12),
                          _VitalDetailCard(
                            iconBg: Color(0xFF0EA5E9),
                            icon: Icons.bubble_chart_rounded,
                            title: 'SpO₂',
                            value: 'ค่าปัจจุบัน: 95%',
                            status: '(ปกติ)',
                            statusColor: Color(0xFF1D8B6B),
                            tint: Color(0x0D4CA30D),
                            badgeText: 'ปลอดภัย',
                            badgeColor: Color(0x334CA30D),
                            badgeTextColor: Color(0xFF4CA30D),
                            description:
                                'ค่าออกซิเจนปกติ ไม่มีข้อจำกัดด้านอาหาร',
                            note:
                                'รักษาระดับด้วยการออกกำลังกายและหายใจลึก',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VitalDetailCard extends StatelessWidget {
  const _VitalDetailCard({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.value,
    required this.status,
    required this.statusColor,
    required this.tint,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.description,
    required this.note,
  });
  final Color iconBg;
  final IconData icon;
  final String title;
  final String value;
  final String status;
  final Color statusColor;
  final Color tint;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final String description;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5F5F5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon,
                          color: CupertinoColors.white, size: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppTypography.caption1(
                        const Color(0xFF6D756E),
                      ).copyWith(
                        fontSize: 12,
                        letterSpacing: 0.275,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      value,
                      style: AppTypography.subheadline(
                        const Color(0xFF1A1A1A),
                      ).copyWith(
                        fontSize: 14,
                        height: 1.43,
                        letterSpacing: 0.14,
                      ),
                    ),
                    Text(
                      status,
                      style: AppTypography.caption1(statusColor).copyWith(
                        fontSize: 12,
                        letterSpacing: 0.12,
                        height: 1.67,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color:
                            CupertinoColors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: AppTypography.caption1(badgeTextColor)
                          .copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.275,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTypography.subheadline(
                      const Color(0xFF1A1A1A),
                    ).copyWith(
                      fontSize: 14,
                      height: 1.43,
                      letterSpacing: 0.14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: const Color(0xFFE5E5E5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE5E5E5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'i',
                          style: AppTypography.caption2(
                            const Color(0xFF6D756E),
                          ).copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          style: AppTypography.caption2(
                            const Color(0xFF1A1A1A),
                          ).copyWith(
                            fontSize: 10,
                            height: 2,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
