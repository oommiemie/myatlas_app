import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  final _subjectCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  final List<String> _photos = [];

  bool get _canSubmit =>
      _subjectCtrl.text.trim().isNotEmpty ||
      _detailCtrl.text.trim().isNotEmpty ||
      _photos.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
    _subjectCtrl.addListener(() => setState(() {}));
    _detailCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _enter.dispose();
    _scrollOffset.dispose();
    _subjectCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('เพิ่มภาพ'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(ImageSource.camera),
            child: const Text('ถ่ายภาพ'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(ImageSource.gallery),
            child: const Text('เลือกจากคลังภาพ'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('ยกเลิก'),
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    try {
      final x = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (x != null) {
        setState(() => _photos.add(x.path));
      }
    } catch (_) {
      // ignore cancellation/permissions
    }
  }

  void _removePhoto(int i) {
    HapticFeedback.selectionClick();
    setState(() => _photos.removeAt(i));
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    AppToast.success(context, 'ส่งรายงานปัญหาแล้ว');
    Navigator.of(context).pop();
  }

  Widget _stagger(int i, int total, Widget child) {
    final start = (i / total) * 0.55;
    final end = (start + 0.55).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) {
        final t = anim.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE4F5F0), Color(0xFFF4F8F5)],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollUpdateNotification ||
                  n is ScrollStartNotification) {
                _scrollOffset.value = n.metrics.pixels;
              }
              return false;
            },
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 56 + 8,
                bottom: 120,
              ),
              children: [
                _stagger(
                  0,
                  4,
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEA580C)
                                  .withValues(alpha: 0.30),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          CupertinoIcons.exclamationmark_bubble_fill,
                          color: CupertinoColors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),
                _stagger(
                  1,
                  4,
                  const Center(
                    child: Text(
                      'รายงานปัญหาการใช้งาน',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _stagger(
                  2,
                  4,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _subjectCtrl,
                          placeholder: 'เรื่อง',
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _detailCtrl,
                          placeholder: 'รายละเอียด....',
                          maxLines: 10,
                          minLines: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                _stagger(
                  3,
                  4,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 129.33 / 130,
                      children: [
                        _AddPhotoTile(onTap: _pickPhoto),
                        for (int i = 0; i < _photos.length; i++)
                          _PhotoTile(
                            path: _photos[i],
                            onRemove: () => _removePhoto(i),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollOffset,
              builder: (_, offset, __) => _PinnedTopBar(
                title: 'รายงานปัญหาการใช้งาน',
                scrollOffset: offset,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SubmitBar(
              enabled: _canSubmit,
              onSubmit: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.97,
      borderRadius: BorderRadius.circular(24),
      child: DottedBorder(
        child: Container(
          color: const Color(0xFFFAFAF9),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 28,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Back photo frame
                    Positioned(
                      left: 0,
                      top: 4,
                      child: Container(
                        width: 26,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF8C8C8C),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Front photo frame (with mountain+sun inside)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 24,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: CupertinoColors.white,
                          border: Border.all(
                            color: const Color(0xFF8C8C8C),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.sun_max,
                          size: 9,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                    // Plus badge (orange)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEA580C),
                          border: Border.all(
                            color: const Color(0xFFFAFAF9),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          CupertinoIcons.add,
                          size: 9,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'เพิ่มภาพ',
                style: TextStyle(
                  color: Color(0xFF6D756E),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedBorder extends StatelessWidget {
  const DottedBorder({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(24),
    );
    final paint = Paint()
      ..color = const Color(0xFFD4D4D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Approximate dashed effect by drawing short arcs around the rrect.
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final seg = metric.extractPath(dist, dist + 6);
        canvas.drawPath(seg, paint);
        dist += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter old) => false;
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(File(path), fit: BoxFit.cover),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: PressEffect(
              onTap: onRemove,
              haptic: HapticKind.selection,
              scale: 0.9,
              rippleShape: BoxShape.circle,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.black.withValues(alpha: 0.4),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: CupertinoColors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.enabled, required this.onSubmit});
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CupertinoColors.white.withValues(alpha: 0),
                CupertinoColors.white.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: _SubmitButton(enabled: enabled, onTap: onSubmit),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: enabled ? onTap : () {},
      haptic: enabled ? HapticKind.medium : HapticKind.none,
      scale: enabled ? 0.97 : 1.0,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2FCFA5), Color(0xFF1D8B6B)],
                )
              : LinearGradient(
                  colors: [
                    const Color(0xFF1D8B6B).withValues(alpha: 0.35),
                    const Color(0xFF1D8B6B).withValues(alpha: 0.35),
                  ],
                ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF1D8B6B).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: const Text(
          'ส่งรายงาน',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _PinnedTopBar extends StatelessWidget {
  const _PinnedTopBar({
    required this.title,
    required this.scrollOffset,
    required this.onBack,
  });
  final String title;
  final double scrollOffset;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final progress = (scrollOffset / 60).clamp(0.0, 1.0);
    final barHeight = top + 6 + 44 + 6;
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
              color:
                  const Color(0xFFF4F8F5).withValues(alpha: 0.80 * progress),
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
          padding: EdgeInsets.only(top: top + 6, left: 14, right: 14),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.chevron_back,
                    onTap: onBack,
                    size: 40,
                    iconSize: 18,
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
