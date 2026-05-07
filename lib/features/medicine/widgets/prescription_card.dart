import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../prescription_detail_screen.dart';
import 'prescription_summary.dart';

class PrescriptionItem {
  final String hospital;
  final String serviceDate;
  final String symptoms;

  const PrescriptionItem({
    required this.hospital,
    required this.serviceDate,
    required this.symptoms,
  });
}

class PrescriptionCard extends StatelessWidget {
  final PrescriptionItem item;
  final List<MedicineDetailItem> medicines;
  final bool saved;
  final VoidCallback? onSave;

  const PrescriptionCard({
    super.key,
    required this.item,
    this.medicines = const [],
    this.saved = false,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SideBadge(),
        const SizedBox(width: 10),
        Expanded(child: _buildCard()),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 1,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.hospital,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 10, height: 1.3),
                        children: [
                          const TextSpan(
                            text: 'อาการแรกรับ : ',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                          TextSpan(
                            text: item.symptoms,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SavePillButton(
                label: saved ? 'บันทึกแล้ว' : 'บันทึก',
                saved: saved,
                onTap: saved ? null : onSave,
              ),
            ],
          ),
          if (medicines.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (int i = 0; i < medicines.length; i++) ...[
              MedicineDetailCard(item: medicines[i]),
              if (i < medicines.length - 1) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _SideBadge extends StatelessWidget {
  const _SideBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -100.5,
            top: -0.5,
            child: SvgPicture.asset(
              'assets/svg/ellipse7.svg',
              width: 147,
              height: 147,
            ),
          ),
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ใบสั่งยา',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      shadows: [
                        Shadow(
                          color: Color(0x0D000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
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
