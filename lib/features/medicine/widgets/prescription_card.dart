import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

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
  final VoidCallback? onTapDetails;

  const PrescriptionCard({
    super.key,
    required this.item,
    this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FileIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.hospital,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.43,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 3.5),
                    child: Text(
                      'วันที่รับบริการ : ${item.serviceDate}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'อาการแรกรับ : ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        height: 1.25,
                      ),
                    ),
                    TextSpan(
                      text: item.symptoms,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _DetailsButton(onTap: onTapDetails),
            ],
          ),
        ),
      ],
    );
  }
}

class _FileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary600.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/svg/icon_file_dock.svg',
        width: 16,
        height: 16,
      ),
    );
  }
}

class _DetailsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _DetailsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primary600,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: const Text(
            'ดูรายละเอียด',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFCFCFC),
              height: 20 / 12,
            ),
          ),
        ),
      ),
    );
  }
}
