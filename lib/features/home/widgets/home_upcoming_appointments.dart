import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/thai_date.dart';
import '../../appointment/data/mock_data.dart';
import '../../appointment/hospital_appointment_detail_sheet.dart';

const String _appointmentSlipSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
  <path d="M1.5 2H22.5" stroke="#0369A1" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M1.5 7H14.5" stroke="#0891B2" stroke-width="2" stroke-linecap="round" stroke-opacity="0.7"/>
  <path d="M1.5 12H14.5" stroke="#0891B2" stroke-width="2" stroke-linecap="round" stroke-opacity="0.7"/>
  <path d="M1.5 17H14.5" stroke="#0891B2" stroke-width="2" stroke-linecap="round" stroke-opacity="0.7"/>
  <path d="M1.5 22H14.5" stroke="#0891B2" stroke-width="2" stroke-linecap="round" stroke-opacity="0.7"/>
</svg>
''';

class HomeUpcomingAppointments extends StatelessWidget {
  final List<AppointmentItem> items;

  const HomeUpcomingAppointments({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final next = items.first;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppColors.bgPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'นัดที่จะถึง',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _UpcomingCard(item: next),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final AppointmentItem item;

  const _UpcomingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showHospitalAppointmentDetailSheet(context, item: item),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0891B2).withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 120, 8),
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0891B2), Color(0xFF0369A1)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row(
                            CupertinoIcons.square_grid_3x2_fill,
                            item.subLeft,
                          ),
                          const SizedBox(height: 12),
                          _row(
                            CupertinoIcons.calendar,
                            '${ThaiDate.format(item.date)}  ${item.time} น.',
                          ),
                          const SizedBox(height: 12),
                          _row(
                            CupertinoIcons.person_fill,
                            item.subRight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            Positioned(
              top: 16,
              right: 12,
              child: _AppointmentSlipThumbnail(
                onTap: () => showHospitalAppointmentDetailSheet(
                  context,
                  item: item,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.white.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
              letterSpacing: 0.14,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentSlipThumbnail extends StatelessWidget {
  final VoidCallback onTap;

  const _AppointmentSlipThumbnail({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: 84,
                height: 84,
                child: Center(
                  child: SvgPicture.string(
                    _appointmentSlipSvg,
                    width: 70,
                    height: 70,
                  ),
                ),
              ),
            ),
            Container(height: 1, color: const Color(0xFFE5E5E5)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'ดูใบนัด',
                style: TextStyle(color: Color(0xFF6D756E), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
