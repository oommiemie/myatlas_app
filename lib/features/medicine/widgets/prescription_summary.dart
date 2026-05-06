import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

class PrescriptionSummary extends StatefulWidget {
  final int itemCount;
  final VoidCallback? onAcknowledge;

  const PrescriptionSummary({
    super.key,
    required this.itemCount,
    this.onAcknowledge,
  });

  @override
  State<PrescriptionSummary> createState() => _PrescriptionSummaryState();
}

class _PrescriptionSummaryState extends State<PrescriptionSummary> {
  bool _acknowledged = false;

  void _handleTap() {
    if (_acknowledged) return;
    setState(() => _acknowledged = true);
    widget.onAcknowledge?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'รายการใบสั่งยาทั้งหมด',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${widget.itemCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ' ', style: TextStyle(fontSize: 11)),
                      const TextSpan(
                        text: 'รายการ',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _AcknowledgeButton(
            acknowledged: _acknowledged,
            onTap: widget.itemCount == 0 ? null : _handleTap,
          ),
        ],
      ),
    );
  }
}

class _AcknowledgeButton extends StatelessWidget {
  final bool acknowledged;
  final VoidCallback? onTap;

  const _AcknowledgeButton({required this.acknowledged, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: acknowledged ? AppColors.success600 : Colors.transparent,
          border: acknowledged
              ? null
              : Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: Center(
                child: acknowledged
                    ? SvgPicture.asset(
                        'assets/svg/icon_done_check.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFCFCFC),
                          BlendMode.srcIn,
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/svg/icon_pending_sun.svg',
                        width: 14,
                        height: 14,
                      ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              acknowledged ? 'เพิ่มในตารางแล้ว' : 'รับทราบ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: acknowledged
                    ? const Color(0xFFFCFCFC)
                    : const Color(0xFF18181B),
                height: 20 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
