import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

class PrescriptionSummary extends StatelessWidget {
  final int itemCount;
  final bool allSaved;
  final VoidCallback? onSaveAll;

  const PrescriptionSummary({
    super.key,
    required this.itemCount,
    required this.allSaved,
    this.onSaveAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              children: [
                const Text(
                  'ใบสั่งยาทั้งหมด',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$itemCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ' ', style: TextStyle(fontSize: 10)),
                      const TextSpan(
                        text: 'รายการ',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SavePillButton(
            label: allSaved ? 'บันทึกแล้ว' : 'บันทึกทั้งหมด',
            saved: allSaved,
            onTap: itemCount == 0 || allSaved ? null : onSaveAll,
          ),
        ],
      ),
    );
  }
}

/// Pill button matching "ทานทั้งหมด" style (sun → check icon).
class SavePillButton extends StatelessWidget {
  final String label;
  final bool saved;
  final VoidCallback? onTap;

  const SavePillButton({
    super.key,
    required this.label,
    required this.saved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: saved ? AppColors.success600 : Colors.transparent,
          border:
              saved ? null : Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: Center(
                child: saved
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
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: saved
                      ? const Color(0xFFFCFCFC)
                      : const Color(0xFF18181B),
                  height: 20 / 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
