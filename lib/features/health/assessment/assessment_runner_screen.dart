import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/liquid_glass_button.dart';
import '../../../core/widgets/press_effect.dart';
import 'assessment_config.dart';

Future<void> showAssessmentRunner(
  BuildContext context,
  AssessmentConfig config,
) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    CupertinoPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => AssessmentRunnerScreen(config: config),
    ),
  );
}

class AssessmentRunnerScreen extends StatefulWidget {
  const AssessmentRunnerScreen({super.key, required this.config});
  final AssessmentConfig config;

  @override
  State<AssessmentRunnerScreen> createState() => _AssessmentRunnerScreenState();
}

class _AssessmentRunnerScreenState extends State<AssessmentRunnerScreen> {
  /// 0 = intro, 1..N = questions, N+1 = result
  int _stage = 0;
  late final List<int?> _answers;
  bool _forward = true;

  int get _totalQuestions => widget.config.questions.length;
  int get _resultStage => _totalQuestions + 1;
  int get _totalScore {
    var total = 0;
    for (int i = 0; i < _answers.length; i++) {
      final opt = _answers[i];
      if (opt != null) {
        total += widget.config.questions[i].options[opt].score;
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.config.questions.length, null);
  }

  void _go(int next) {
    if (next == _stage) return;
    setState(() {
      _forward = next > _stage;
      _stage = next;
    });
  }

  void _selectOption(int qIndex, int optIndex) {
    HapticFeedback.lightImpact();
    setState(() {
      _answers[qIndex] = optIndex;
    });
    Future<void>.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      _go(_stage + 1);
    });
  }

  Future<void> _confirmExit() async {
    final yes = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('ออกจากแบบประเมิน?'),
        content: const Text('ผลตอบที่ทำไว้จะหายไปทั้งหมด'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ทำต่อ'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ออก'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleClose() {
    final hasAnswers = _answers.any((v) => v != null);
    if (_stage == _resultStage || _stage == 0 || !hasAnswers) {
      Navigator.of(context).pop();
    } else {
      _confirmExit();
    }
  }

  void _saveResult() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    AppToast.success(context, 'บันทึกผลการประเมินแล้ว');
  }

  void _restart() {
    HapticFeedback.selectionClick();
    setState(() {
      _stage = 0;
      _forward = false;
      for (int i = 0; i < _answers.length; i++) {
        _answers[i] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isQuestion = _stage >= 1 && _stage <= _totalQuestions;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _RunnerTopBar(
              isQuestion: isQuestion,
              questionIndex: _stage - 1,
              totalQuestions: _totalQuestions,
              onBack: _stage > 0 && _stage <= _totalQuestions
                  ? () => _go(_stage - 1)
                  : null,
              onClose: _handleClose,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) {
                  final beginX = _forward ? 0.18 : -0.18;
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(beginX, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: _buildStage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStage() {
    if (_stage == 0) {
      return _IntroStage(
        key: const ValueKey('intro'),
        config: widget.config,
        onStart: () => _go(1),
      );
    }
    if (_stage == _resultStage) {
      final band = widget.config.bandFor(_totalScore);
      return _ResultStage(
        key: const ValueKey('result'),
        score: _totalScore,
        maxScore: widget.config.maxScore,
        band: band,
        onRestart: _restart,
        onSave: _saveResult,
      );
    }
    final qIndex = _stage - 1;
    return _QuestionStage(
      key: ValueKey('q$qIndex'),
      index: qIndex,
      total: _totalQuestions,
      question: widget.config.questions[qIndex],
      selected: _answers[qIndex],
      onSelect: (optIndex) => _selectOption(qIndex, optIndex),
    );
  }
}

// ── Top bar ─────────────────────────────────────────────────────────────────

class _RunnerTopBar extends StatelessWidget {
  const _RunnerTopBar({
    required this.isQuestion,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onBack,
    required this.onClose,
  });

  final bool isQuestion;
  final int questionIndex;
  final int totalQuestions;
  final VoidCallback? onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isQuestion)
                  Text(
                    '${questionIndex + 1} / $totalQuestions',
                    style: const TextStyle(
                      color: Color(0xFF6D756E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                if (onBack != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LiquidGlassButton(
                      icon: CupertinoIcons.chevron_back,
                      iconColor: const Color(0xFF1A1A1A),
                      onTap: onBack!,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.xmark,
                    iconColor: const Color(0xFF1A1A1A),
                    onTap: onClose,
                  ),
                ),
              ],
            ),
          ),
          if (isQuestion) ...[
            const SizedBox(height: 8),
            _ProgressBar(progress: (questionIndex + 1) / totalQuestions),
          ],
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF26A37E), Color(0xFF1D8B6B)],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D8B6B).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
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

// ── Intro stage ─────────────────────────────────────────────────────────────

class _IntroStage extends StatelessWidget {
  const _IntroStage({
    super.key,
    required this.config,
    required this.onStart,
  });
  final AssessmentConfig config;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE4E8),
            ),
            padding: const EdgeInsets.all(18),
            child: Image.asset(config.image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 28),
          Text(
            config.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              config.intro,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6D756E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _MetaPills(
            questionCount: config.questions.length,
            minutes: config.estimatedMinutes,
          ),
          const Spacer(flex: 2),
          PressEffect(
            onTap: onStart,
            haptic: HapticKind.medium,
            scale: 0.97,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF26A37E), Color(0xFF157F5E)],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D8B6B).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'เริ่มทำแบบประเมิน',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'ข้อมูลของคุณจะถูกเก็บไว้อย่างปลอดภัย',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPills extends StatelessWidget {
  const _MetaPills({required this.questionCount, required this.minutes});
  final int questionCount;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _MetaPill(
          icon: CupertinoIcons.doc_text,
          label: '$questionCount คำถาม',
        ),
        const SizedBox(width: 10),
        _MetaPill(
          icon: CupertinoIcons.clock,
          label: 'ประมาณ $minutes นาที',
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFEDEDF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF6D756E)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question stage ──────────────────────────────────────────────────────────

class _QuestionStage extends StatelessWidget {
  const _QuestionStage({
    super.key,
    required this.index,
    required this.total,
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  final int index;
  final int total;
  final AssessmentQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'คำถามที่ ${index + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1D8B6B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              question.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.4,
                letterSpacing: 0.1,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _OptionCard(
                option: question.options[i],
                selected: selected == i,
                onTap: () => onSelect(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final AssessmentOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = option.color;
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.none,
      scale: 0.98,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? tone.withValues(alpha: 0.12)
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? tone
                : const Color(0xFF747480).withValues(alpha: 0.12),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: tone.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: selected ? 0.18 : 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                option.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  color: selected ? tone : const Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            AnimatedScale(
              scale: selected ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: tone,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.check_mark,
                  color: CupertinoColors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result stage ────────────────────────────────────────────────────────────

class _ResultStage extends StatelessWidget {
  const _ResultStage({
    super.key,
    required this.score,
    required this.maxScore,
    required this.band,
    required this.onRestart,
    required this.onSave,
  });

  final int score;
  final int maxScore;
  final AssessmentBand band;
  final VoidCallback onRestart;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              _ResultHeroCard(
                score: score,
                maxScore: maxScore,
                band: band,
              ),
              const SizedBox(height: 20),
              _ResultBlock(
                title: 'ผลการประเมิน',
                icon: CupertinoIcons.doc_text_search,
                body: band.summary,
              ),
              const SizedBox(height: 14),
              _ResultBlock(
                title: 'คำแนะนำ',
                icon: CupertinoIcons.lightbulb_fill,
                body: band.recommendation,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: PressEffect(
                  onTap: onRestart,
                  haptic: HapticKind.selection,
                  scale: 0.97,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(100),
                      border:
                          Border.all(color: const Color(0xFFE5E5E5)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'ทำใหม่',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: PressEffect(
                  onTap: onSave,
                  haptic: HapticKind.medium,
                  scale: 0.97,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF26A37E), Color(0xFF157F5E)],
                      ),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D8B6B)
                              .withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'บันทึกผล',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Color _bandColor(AssessmentLevel level) {
  switch (level) {
    case AssessmentLevel.normal:
      return const Color(0xFF1D8B6B);
    case AssessmentLevel.watch:
      return const Color(0xFFD97706);
    case AssessmentLevel.risk:
      return const Color(0xFFDC2626);
  }
}

IconData _bandIcon(AssessmentLevel level) {
  switch (level) {
    case AssessmentLevel.normal:
      return CupertinoIcons.checkmark_seal_fill;
    case AssessmentLevel.watch:
      return CupertinoIcons.exclamationmark_triangle_fill;
    case AssessmentLevel.risk:
      return CupertinoIcons.exclamationmark_octagon_fill;
  }
}

class _ResultHeroCard extends StatelessWidget {
  const _ResultHeroCard({
    required this.score,
    required this.maxScore,
    required this.band,
  });
  final int score;
  final int maxScore;
  final AssessmentBand band;

  @override
  Widget build(BuildContext context) {
    final color = _bandColor(band.level);
    final icon = _bandIcon(band.level);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 12),
            const Text(
              'คะแนนของคุณ',
              style: TextStyle(
                color: Color(0xFF6D756E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  score.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '/ $maxScore',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: color.withValues(alpha: 0.28)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 7),
                  Text(
                    band.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
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
}

class _ResultBlock extends StatelessWidget {
  const _ResultBlock({
    required this.title,
    required this.icon,
    required this.body,
  });
  final String title;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1D8B6B)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.55,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
