import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  bool _confirmed = false;
  String? _reason;

  static const _reasons = <String>[
    'ไม่ได้ใช้งานแอปแล้ว',
    'ข้อมูลส่วนตัวไม่ปลอดภัย',
    'ใช้งานแอปอื่นแทน',
    'ปัญหาในการใช้งาน',
    'อื่นๆ',
  ];

  static const _consequences = <({IconData icon, String text})>[
    (
      icon: CupertinoIcons.trash_fill,
      text: 'ข้อมูลสุขภาพ การนัดหมาย และประวัติทั้งหมดจะถูกลบถาวร',
    ),
    (
      icon: CupertinoIcons.link,
      text: 'การเชื่อมต่อบัญชี Google / Facebook / Apple จะถูกยกเลิก',
    ),
    (
      icon: CupertinoIcons.clock_fill,
      text: 'คุณจะไม่สามารถกู้คืนข้อมูลได้ภายหลังการลบ',
    ),
    (
      icon: CupertinoIcons.arrow_down_circle_fill,
      text: 'สามารถดาวน์โหลดข้อมูลก่อนลบได้ในหน้า ความเป็นส่วนตัว',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    _scrollOffset.dispose();
    super.dispose();
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

  Future<void> _confirmDelete() async {
    HapticFeedback.heavyImpact();
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('ลบบัญชีถาวร?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'การลบบัญชีจะไม่สามารถกู้คืนได้ คุณต้องการดำเนินการต่อหรือไม่?',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบบัญชี'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFEE2E2).withValues(alpha: 0.6),
                    const Color(0xFFF4F8F5).withValues(alpha: 0),
                  ],
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
                bottom: 140,
              ),
              children: [
                _stagger(
                  0,
                  5,
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB91C1C)
                                  .withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          CupertinoIcons.exclamationmark_triangle_fill,
                          color: CupertinoColors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                ),
                _stagger(
                  1,
                  5,
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          'ลบบัญชีของคุณ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'การลบบัญชีจะเป็นการสิ้นสุดการใช้งานอย่างถาวร โปรดอ่านรายละเอียดด้านล่างก่อนดำเนินการต่อ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6D756E),
                            fontSize: 14,
                            height: 22 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _stagger(
                  2,
                  5,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                CupertinoIcons.exclamationmark_circle_fill,
                                color: Color(0xFFEF4444),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'สิ่งที่คุณจะเสีย',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (int i = 0; i < _consequences.length; i++) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    _consequences[i].icon,
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.75),
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _consequences[i].text,
                                    style: const TextStyle(
                                      color: Color(0xFF4B5563),
                                      fontSize: 13.5,
                                      height: 20 / 13.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (i != _consequences.length - 1)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _stagger(
                  3,
                  5,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding:
                                EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'เหตุผลในการลบบัญชี (ไม่บังคับ)',
                              style: TextStyle(
                                color: Color(0xFF6D756E),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          for (int i = 0; i < _reasons.length; i++) ...[
                            PressEffect(
                              onTap: () => setState(() => _reason = _reasons[i]),
                              haptic: HapticKind.selection,
                              scale: 0.99,
                              dim: 0.96,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                color: CupertinoColors.white,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _reasons[i],
                                        style: const TextStyle(
                                          color: Color(0xFF1A1A1A),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _reason == _reasons[i]
                                            ? const Color(0xFFEF4444)
                                            : CupertinoColors.white,
                                        border: Border.all(
                                          color: _reason == _reasons[i]
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF1A1A1A)
                                                  .withValues(alpha: 0.22),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: _reason == _reasons[i]
                                          ? Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: CupertinoColors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (i != _reasons.length - 1)
                              Container(
                                height: 1,
                                color: const Color(0xFFE5E5E5),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _stagger(
                  4,
                  5,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PressEffect(
                      onTap: () => setState(() => _confirmed = !_confirmed),
                      haptic: HapticKind.selection,
                      scale: 0.99,
                      dim: 0.96,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _confirmed
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFE5E5E5),
                            width: _confirmed ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: _confirmed
                                    ? const Color(0xFFEF4444)
                                    : CupertinoColors.white,
                                border: Border.all(
                                  color: _confirmed
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF1A1A1A)
                                          .withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _confirmed
                                  ? const Icon(
                                      CupertinoIcons.check_mark,
                                      color: CupertinoColors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'ฉันเข้าใจว่าการลบบัญชีไม่สามารถกู้คืนได้ และยืนยันที่จะลบบัญชีของฉัน',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 14,
                                  height: 20 / 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                title: 'ลบบัญชี',
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
              enabled: _confirmed,
              onSubmit: _confirmDelete,
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
              child: PressEffect(
                onTap: enabled ? onSubmit : () {},
                haptic: enabled ? HapticKind.heavy : HapticKind.none,
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
                            colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                          )
                        : LinearGradient(
                            colors: [
                              const Color(0xFFEF4444).withValues(alpha: 0.35),
                              const Color(0xFFEF4444).withValues(alpha: 0.35),
                            ],
                          ),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color: const Color(0xFFB91C1C)
                                  .withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'ลบบัญชีถาวร',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
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
