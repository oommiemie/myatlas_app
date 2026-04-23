import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/services/app_settings_service.dart';
import '../../core/services/app_strings.dart';
import '../../core/widgets/liquid_glass_button.dart';
import '../../core/widgets/press_effect.dart';

class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);
  final _settings = AppSettingsService.instance;

  List<String> _fontSizeLabelsFor(BuildContext c) => [
        tr(c, 'เล็กมาก', 'Very Small'),
        tr(c, 'เล็ก', 'Small'),
        tr(c, 'กลาง', 'Medium'),
        tr(c, 'ใหญ่', 'Large'),
        tr(c, 'ใหญ่มาก', 'Very Large'),
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
            offset: Offset(0, (1 - t) * 18),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  String get _languageLabel =>
      _settings.locale.value.languageCode == 'en' ? 'English' : 'ไทย';

  Future<void> _pickLanguage() async {
    final choice = await showCupertinoModalPopup<String>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
      builder: (ctx) => _LanguageSheet(current: _languageLabel),
    );
    if (choice != null && choice != _languageLabel) {
      _settings.setLocale(
        choice == 'English'
            ? const Locale('en', 'US')
            : const Locale('th', 'TH'),
      );
      setState(() {});
    }
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
                top: MediaQuery.paddingOf(context).top + 56 + 12,
                bottom: 40,
              ),
              children: [
                _stagger(
                  0,
                  3,
                  ValueListenableBuilder<AppThemeMode>(
                    valueListenable: _settings.themeMode,
                    builder: (_, theme, __) => _Section(
                      title: tr(context, 'โหมดมืด', 'Dark mode'),
                      child: Column(
                        children: [
                          _ThemeOption(
                            icon: CupertinoIcons.moon_fill,
                            iconColor: const Color(0xFF2563EB),
                            label: tr(context, 'สว่าง', 'Light'),
                            selected: theme == AppThemeMode.light,
                            onTap: () =>
                                _settings.setThemeMode(AppThemeMode.light),
                          ),
                          const _Divider(),
                          _ThemeOption(
                            icon: CupertinoIcons.moon_stars_fill,
                            iconColor: const Color(0xFF475569),
                            label: tr(context, 'มืด', 'Dark'),
                            selected: theme == AppThemeMode.dark,
                            onTap: () =>
                                _settings.setThemeMode(AppThemeMode.dark),
                          ),
                          const _Divider(),
                          _ThemeOption(
                            icon: CupertinoIcons.circle_lefthalf_fill,
                            iconColor: const Color(0xFFD97706),
                            label: tr(context, 'ตามอุปกรณ์', 'System'),
                            selected: theme == AppThemeMode.system,
                            onTap: () =>
                                _settings.setThemeMode(AppThemeMode.system),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _stagger(
                  1,
                  3,
                  _Section(
                    title: tr(context, 'เปลี่ยนภาษา', 'Language'),
                    child: PressEffect(
                      onTap: _pickLanguage,
                      haptic: HapticKind.selection,
                      scale: 0.99,
                      dim: 0.96,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: CupertinoColors.white,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF2563EB),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.globe,
                                color: CupertinoColors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tr(context, 'ภาษา', 'Language'),
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.275,
                                ),
                              ),
                            ),
                            Text(
                              _languageLabel,
                              style: const TextStyle(
                                color: Color(0xFF6D756E),
                                fontSize: 16,
                                letterSpacing: 0.275,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              CupertinoIcons.chevron_forward,
                              size: 12,
                              color: Color(0xFF6D756E),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _stagger(
                  2,
                  3,
                  ValueListenableBuilder<double>(
                    valueListenable: _settings.textScale,
                    builder: (_, __, ___) {
                      final idx = _settings.fontSizeIndex;
                      return _Section(
                        title: tr(context, 'ขนาดแบบอักษร', 'Text Size'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: CupertinoColors.white,
                          child: Column(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _fontSizeLabelsFor(context)[idx],
                                  key: ValueKey(idx),
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _FontSizeSlider(
                                value: idx,
                                onChanged: (v) {
                                  if (v != idx) {
                                    HapticFeedback.selectionClick();
                                    _settings.setFontSizeIndex(v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                title: tr(context, 'การแสดงผล', 'Display'),
                scrollOffset: offset,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF747480).withValues(alpha: 0.08),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        color: const Color(0xFFE9EFEA),
      );
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      haptic: HapticKind.selection,
      scale: 0.99,
      dim: 0.96,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: CupertinoColors.white,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: CupertinoColors.white, size: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.275,
                ),
              ),
            ),
            _RadioMark(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF1D8B6B) : CupertinoColors.white,
        border: Border.all(
          color: selected
              ? const Color(0xFF1D8B6B)
              : const Color(0xFF1A1A1A).withValues(alpha: 0.2),
          width: 1.4,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white,
              ),
            )
          : null,
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  const _FontSizeSlider({required this.value, required this.onChanged});
  final int value; // 0..4
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'A',
          style: TextStyle(
            color: Color(0xFF6D756E),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 28,
            child: LayoutBuilder(
              builder: (_, c) {
                final trackW = c.maxWidth;
                final segW = trackW / 4;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) {
                    final idx = (d.localPosition.dx / segW)
                        .round()
                        .clamp(0, 4);
                    onChanged(idx);
                  },
                  onHorizontalDragUpdate: (d) {
                    final idx = (d.localPosition.dx / segW)
                        .round()
                        .clamp(0, 4);
                    onChanged(idx);
                  },
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Track
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Fill
                      FractionallySizedBox(
                        widthFactor: value / 4,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2CA989),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      // Ticks
                      for (int i = 0; i < 5; i++)
                        Positioned(
                          left: segW * i - 2,
                          top: 17,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CupertinoColors.systemGrey.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                        ),
                      // Knob
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        left: (segW * value).clamp(0, trackW) - 19,
                        child: Container(
                          width: 38,
                          height: 24,
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black
                                    .withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 0.5),
                              ),
                              BoxShadow(
                                color: CupertinoColors.black
                                    .withValues(alpha: 0.12),
                                blurRadius: 13,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'A',
          style: TextStyle(
            color: Color(0xFF6D756E),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current});
  final String current;

  static const _options = ['ไทย', 'English'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(38),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Text(
                      tr(context, 'เลือกภาษา', 'Select Language'),
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (int i = 0; i < _options.length; i++) ...[
                            PressEffect(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.of(context).pop(_options[i]);
                              },
                              haptic: HapticKind.none,
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
                                        _options[i],
                                        style: const TextStyle(
                                          color: Color(0xFF1A1A1A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.275,
                                        ),
                                      ),
                                    ),
                                    if (current == _options[i])
                                      const Icon(
                                        CupertinoIcons.check_mark,
                                        size: 20,
                                        color: Color(0xFF1D8B6B),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (i != _options.length - 1)
                              Container(
                                height: 1,
                                color: const Color(0xFFE5E5E5),
                              ),
                          ],
                        ],
                      ),
                    ),
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
