import 'package:flutter/material.dart';

import 'data/mock_data.dart';
import 'widgets/detail_sheet_parts.dart';

Future<void> showHospitalAppointmentDetailSheet(
  BuildContext context, {
  required AppointmentItem item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HospitalAppointmentDetailSheet(item: item),
  );
}

class _HospitalAppointmentDetailSheet extends StatelessWidget {
  final AppointmentItem item;

  const _HospitalAppointmentDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;
    return Container(
      height: mediaHeight * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(38),
          topRight: Radius.circular(38),
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DetailSheetHeader(
                title: 'ใบนัดโรงพยาบาล',
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailDateChip(date: item.date),
                      const SizedBox(height: 16),
                      DetailSummaryRow(
                        entries: [
                          DetailSummaryEntry(
                              label: 'เวลา', value: '${item.time} น.'),
                          DetailSummaryEntry(
                              label: 'สถานที่ตรวจ', value: item.title),
                          DetailSummaryEntry(
                              label: 'แผนก', value: item.subLeft),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DetailInfoCard(
                        title: 'แพทย์',
                        fields: [
                          DetailInnerField(
                              label: 'รายละเอียด', value: item.subRight),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DetailInfoCard(
                        title: 'สาเหตุการนัด',
                        fields: [
                          DetailInnerField(
                              label: 'รายละเอียด', value: item.tag.label),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DetailBulletCard(
                        title: 'การเตรียมตัวก่อนมาพบแพทย์',
                        items: item.preparation,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 107,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00FFFFFF),
                      Color(0xE6FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: DetailAcknowledgeButton(
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
