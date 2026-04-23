import 'package:flutter/cupertino.dart';

/// Unified text field style used across the app's forms.
///
/// - height 44, radius 16, white background
/// - focused border green #1D8B6B + soft shadow
/// - value font 16 / w500 / letterSpacing 0.3
/// - optional [unit] suffix and auto-scroll when focused inside a scrollable
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.placeholder = '',
    this.keyboardType,
    this.unit,
    this.enabled = true,
    this.obscureText = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
  });

  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final String? unit;
  final bool enabled;
  final bool obscureText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;

  static const double kHeight = 44;
  static const Color kFocusColor = Color(0xFF1D8B6B);
  static const Color kBorderColor = Color(0xFFE5E5E5);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focus;
  late final bool _ownsFocus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ownsFocus = widget.focusNode == null;
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (!mounted) return;
    if (_focus.hasFocus != _focused) {
      setState(() => _focused = _focus.hasFocus);
    }
    if (_focus.hasFocus) {
      Future.delayed(const Duration(milliseconds: 280), () {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0.2,
        );
      });
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_handleFocus);
    if (_ownsFocus) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final single = (widget.maxLines ?? 1) == 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      constraints: BoxConstraints(
        minHeight: AppTextField.kHeight,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: single ? 0 : 10,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(
          color: _focused
              ? AppTextField.kFocusColor
              : AppTextField.kBorderColor,
          width: _focused ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppTextField.kFocusColor.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: single
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              autofocus: widget.autofocus,
              placeholder: widget.placeholder,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              placeholderStyle: const TextStyle(
                color: Color(0xFFA5ACA6),
                fontSize: 16,
              ),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(),
            ),
          ),
          if (widget.unit != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                widget.unit!,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
