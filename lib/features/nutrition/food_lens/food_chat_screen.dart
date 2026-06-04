import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/liquid_glass_button.dart';
import '../../../core/widgets/press_effect.dart';
import '../data/meal_store.dart';

Future<void> showFoodChat(
  BuildContext context, {
  required MealAnalysis analysis,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.5),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => _FoodChatScreen(analysis: analysis),
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

class _FoodChatScreen extends StatefulWidget {
  const _FoodChatScreen({required this.analysis});
  final MealAnalysis analysis;

  @override
  State<_FoodChatScreen> createState() => _FoodChatScreenState();
}

class _FoodChatScreenState extends State<_FoodChatScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_Msg(
      role: _Role.bot,
      text: 'สวัสดีครับ! ฉันคือผู้ช่วย AI ด้านสุขภาพ\n'
          'ฉันได้วิเคราะห์ ${widget.analysis.name} ของคุณแล้ว '
          'ถามอะไรเพิ่มเติมเกี่ยวกับโภชนาการได้เลยครับ 🍽️',
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _ask(String question) {
    final trimmed = question.trim();
    if (trimmed.isEmpty || _thinking) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(
        _Msg(role: _Role.user, text: trimmed, timestamp: DateTime.now()),
      );
      _controller.clear();
      _thinking = true;
    });
    _scrollToEnd();
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _Msg(
            role: _Role.bot,
            text: _mockReply(trimmed),
            timestamp: DateTime.now(),
          ),
        );
        _thinking = false;
      });
      _scrollToEnd();
    });
  }

  String _mockReply(String q) {
    final lower = q.toLowerCase();
    final a = widget.analysis;
    if (lower.contains('ความดัน') || lower.contains('โซเดียม') ||
        lower.contains('เค็ม')) {
      return '${a.name} มีโซเดียมจากน้ำพริกเผา/น้ำปลา '
          'หากคุมความดันอยู่ แนะนำลดน้ำซุปและไม่จิ้มน้ำปลาเพิ่ม '
          'ปริมาณโซเดียมโดยประมาณอยู่ระดับปานกลาง-สูงครับ';
    }
    if (lower.contains('เบาหวาน') || lower.contains('น้ำตาล')) {
      return 'มื้อนี้คาร์บอยู่ที่ ${a.carbs} g ซึ่งไม่สูงมาก '
          'น้ำตาลในเครื่องปรุง ${a.sugar} g '
          'เหมาะสำหรับผู้เป็นเบาหวาน หากทานกับข้าวขาวควรแบ่งครึ่ง '
          'และจับคู่ผักเพิ่มเติม';
    }
    if (lower.contains('โปรตีน') || lower.contains('กล้ามเนื้อ')) {
      return 'มื้อนี้ให้โปรตีน ${a.protein} g ส่วนใหญ่มาจากกุ้ง '
          'เพียงพอสำหรับมื้อเดียว ถ้าออกกำลังกายควรทาน 1.6-2 g '
          'ต่อน้ำหนักตัว 1 kg/วัน';
    }
    if (lower.contains('แคล') || lower.contains('ลดน้ำหนัก')) {
      return 'มื้อนี้ ${a.calories} kcal คิดเป็น '
          '${(a.calories / 2200 * 100).round()}% ของพลังงานต่อวัน '
          'ถ้ากำลังลดน้ำหนัก แนะนำเลี่ยงข้าวคู่ + ลดน้ำซุปลงครึ่งหนึ่ง';
    }
    if (lower.contains('ทดแทน') || lower.contains('แทน') ||
        lower.contains('แนะนำ')) {
      return 'เมนูทดแทนที่ดีต่อสุขภาพใกล้เคียง: '
          '• ต้มยำเห็ดรวม (โปรตีนน้อยแต่ไฟเบอร์สูง)\n'
          '• แกงเลียงกุ้งสด (โซเดียมต่ำ)\n'
          '• ปลานึ่งมะนาว (โปรตีนสูง ไขมันต่ำ)';
    }
    return 'จากการวิเคราะห์ ${a.name}: '
        'แคลอรี่ ${a.calories} kcal, โปรตีน ${a.protein} g, '
        'คาร์บ ${a.carbs} g, ไขมัน ${a.fat} g '
        'ถามเฉพาะเรื่องไหนเพิ่ม เช่น "เหมาะกับเบาหวานไหม", '
        '"ผลต่อความดัน", "เปลี่ยนเป็นเมนูอื่นได้ไหม"';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      resizeToAvoidBottomInset: false,
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA).withValues(alpha: 0.96),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(38)),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.white.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative gradient blobs in background
                  const Positioned(
                    top: -40,
                    left: -60,
                    child: _Blob(
                      size: 220,
                      color: Color(0x33A855F7),
                    ),
                  ),
                  const Positioned(
                    top: 100,
                    right: -80,
                    child: _Blob(
                      size: 260,
                      color: Color(0x303B82F6),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 38,
                        height: 5,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF1A1A1A).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: SizedBox(
                          height: 44,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const _AiHeaderBadge(),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'ผู้ช่วย AI สุขภาพ',
                                        style: TextStyle(
                                          color: Color(0xFF1A1A1A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                              Text(
                                widget.analysis.name,
                                style: const TextStyle(
                                  color: Color(0xFF6D756E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: LiquidGlassButton(
                              icon: CupertinoIcons.xmark,
                              iconColor: const Color(0xFF1A1A1A),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _messages.length + (_thinking ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _messages.length && _thinking) {
                          return const _TypingBubble();
                        }
                        return _Bubble(msg: _messages[i]);
                      },
                    ),
                  ),
                      _Suggestions(onTap: _ask),
                      _Composer(
                        controller: _controller,
                        focus: _focus,
                        onSend: () => _ask(_controller.text),
                        bottomPadding: keyboard > 0 ? keyboard : 0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _AiHeaderBadge extends StatelessWidget {
  const _AiHeaderBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9333EA).withValues(alpha: 0.30),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(
        CupertinoIcons.sparkles,
        color: CupertinoColors.white,
        size: 14,
      ),
    );
  }
}

enum _Role { user, bot }

class _Msg {
  _Msg({required this.role, required this.text, required this.timestamp});
  final _Role role;
  final String text;
  final DateTime timestamp;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == _Role.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) const _BotAvatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF1D8B6B)
                    : CupertinoColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: const Color(0xFF747480).withValues(alpha: 0.12),
                      ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser
                      ? CupertinoColors.white
                      : const Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9333EA).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(
        CupertinoIcons.sparkles,
        color: CupertinoColors.white,
        size: 15,
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BotAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: const Color(0xFF747480).withValues(alpha: 0.12),
              ),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final t = ((_ctrl.value - i * 0.18) % 1.0).clamp(0.0, 1.0);
                  final scale = 0.6 + 0.4 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
                  return Padding(
                    padding: EdgeInsets.only(right: i == 2 ? 0 : 4),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const questions = [
      'เหมาะกับเบาหวานไหม?',
      'ผลต่อความดัน?',
      'โปรตีนเพียงพอไหม?',
      'แนะนำเมนูทดแทน',
      'ลดน้ำหนักทานได้ไหม?',
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: questions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(questions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF9333EA).withValues(alpha: 0.06),
                  const Color(0xFF3B82F6).withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color(0xFF9333EA).withValues(alpha: 0.30),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              questions[i],
              style: const TextStyle(
                color: Color(0xFF5B21B6),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focus,
    required this.onSend,
    required this.bottomPadding,
  });
  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSend;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        bottomPadding > 0 ? bottomPadding + 10 : safeBottom + 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF747480).withValues(alpha: 0.15),
                ),
              ),
              child: CupertinoTextField.borderless(
                controller: controller,
                focusNode: focus,
                placeholder: 'พิมพ์คำถาม…',
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => onSend(),
                padding: const EdgeInsets.symmetric(vertical: 10),
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                placeholderStyle: TextStyle(
                  color: const Color(0xFF8E8E93).withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PressEffect(
            onTap: onSend,
            haptic: HapticKind.light,
            borderRadius: BorderRadius.circular(100),
            scale: 0.92,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9333EA).withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.arrow_up,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
