import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';

class MedicineDetailItem {
  final String name;
  final String dosage;
  final int pillCount;
  final String startDate;

  const MedicineDetailItem({
    required this.name,
    required this.dosage,
    required this.pillCount,
    required this.startDate,
  });
}

Future<void> showPrescriptionDetailSheet(
  BuildContext context, {
  required String serviceDate,
  required String hospital,
  required String symptoms,
  required String coverage,
  required List<MedicineDetailItem> medicines,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PrescriptionDetailSheet(
      serviceDate: serviceDate,
      hospital: hospital,
      symptoms: symptoms,
      coverage: coverage,
      medicines: medicines,
    ),
  );
}

class _PrescriptionDetailSheet extends StatelessWidget {
  final String serviceDate;
  final String hospital;
  final String symptoms;
  final String coverage;
  final List<MedicineDetailItem> medicines;

  const _PrescriptionDetailSheet({
    required this.serviceDate,
    required this.hospital,
    required this.symptoms,
    required this.coverage,
    required this.medicines,
  });

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;
    return Container(
      height: mediaHeight * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _SheetHeader(
            title: 'ใบสั่งยา',
            onClose: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateChip(date: serviceDate),
                  const SizedBox(height: 16),
                  _SummaryInfoRow(
                    hospital: hospital,
                    symptoms: symptoms,
                    coverage: coverage,
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < medicines.length; i++) ...[
                    _MedicineDetailCard(item: medicines[i]),
                    if (i < medicines.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: _ConfirmButton(
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _SheetHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Stack(
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: _CircleCloseButton(onTap: onClose),
          ),
        ],
      ),
    );
  }
}

class _CircleCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CircleCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.close,
          size: 22,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String date;

  const _DateChip({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      decoration: BoxDecoration(
        color: AppColors.dateChip,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/icon_calendar.svg',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 4),
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xE6FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryInfoRow extends StatelessWidget {
  final String hospital;
  final String symptoms;
  final String coverage;

  const _SummaryInfoRow({
    required this.hospital,
    required this.symptoms,
    required this.coverage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _InfoCol(label: 'สถานที่', value: hospital),
          const _VDivider(),
          _InfoCol(label: 'อาการแรกรับ', value: symptoms),
          const _VDivider(),
          _InfoCol(label: 'สิทธิ์รักษา', value: coverage),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.borderDefault,
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineDetailCard extends StatelessWidget {
  final MedicineDetailItem item;

  const _MedicineDetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/medicine.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
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
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.43,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PillCountBadge(count: item.pillCount),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.dosage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.34,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'วันที่เริ่มทาน : ${item.startDate}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA5ACA6),
                    height: 1.34,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillCountBadge extends StatelessWidget {
  final int count;

  const _PillCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x334CA30D),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        '$count เม็ด',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.success600,
          height: 1.25,
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ConfirmButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary600,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: const Text(
          'ยืนยันตามใบสั่งยา',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFCFCFC),
            height: 1.25,
          ),
        ),
      ),
    );
  }
}
