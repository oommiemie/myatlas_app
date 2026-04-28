import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../data/mock_data.dart';
import '../home_visit_appointment_detail_sheet.dart';
import '../hospital_appointment_detail_sheet.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentItem item;
  final bool isSoon;

  const AppointmentCard({
    super.key,
    required this.item,
    this.isSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => item.homeVisitDetail != null
          ? showHomeVisitAppointmentDetailSheet(context, item: item)
          : showHospitalAppointmentDetailSheet(context, item: item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeChip(time: item.time, isSoon: isSoon),
          const SizedBox(width: 10),
          Expanded(child: _GradientInfoCard(item: item)),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final bool isSoon;

  const _TimeChip({required this.time, required this.isSoon});

  static const _decoSoonInner = Color(0xCCFAFEF5);
  static const _decoSoonOuter = Color(0x0D4CA30D);
  static const _decoFutureInner = Color(0xCCFFF4ED);
  static const _decoFutureOuter = Color(0x0DE62E05);

  @override
  Widget build(BuildContext context) {
    final iconAsset = isSoon
        ? 'assets/svg/icon_clock_soon.svg'
        : 'assets/svg/icon_clock_future.svg';
    final decoInner = isSoon ? _decoSoonInner : _decoFutureInner;
    final decoOuter = isSoon ? _decoSoonOuter : _decoFutureOuter;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.borderDefault,
            width: 0.5,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -100.5,
              top: -0.5,
              width: 147,
              height: 147,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [decoInner, decoOuter],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconAsset,
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.0,
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

class _GradientInfoCard extends StatelessWidget {
  final AppointmentItem item;

  const _GradientInfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: item.gradient,
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 20 / 16,
                  ),
                ),
                const SizedBox(height: 4),
                Opacity(
                  opacity: 0.7,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.subLeft,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                            height: 16 / 10,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: AppColors.textPrimary,
                      ),
                      Flexible(
                        child: Text(
                          item.subRight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                            height: 16 / 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _TagChip(label: item.tag.label, textColor: item.tagTextColor),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color textColor;

  const _TagChip({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/icon_shield_track.svg',
            width: 12,
            height: 12,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
