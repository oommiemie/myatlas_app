import 'package:flutter/material.dart';

import 'data/mock_data.dart';
import 'widgets/detail_sheet_parts.dart';

Future<void> showHomeVisitAppointmentDetailSheet(
  BuildContext context, {
  required AppointmentItem item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HomeVisitAppointmentDetailSheet(item: item),
  );
}

class _HomeVisitAppointmentDetailSheet extends StatelessWidget {
  final AppointmentItem item;

  const _HomeVisitAppointmentDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;
    final detail = item.homeVisitDetail!;
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
                title: 'ใบนัดเยี่ยมบ้าน',
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
                              label: 'ประเภทการเยี่ยม',
                              value: item.tag.label),
                          DetailSummaryEntry(
                              label: 'เจ้าหน้าที่',
                              value: detail.staffName),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DetailInfoCard(
                        title: 'สาเหตุการส่งเยี่ยม',
                        fields: [
                          DetailInnerField(
                              label: 'รายละเอียด',
                              value: detail.sendReason),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DetailInfoCard(
                        title: 'วัตถุประสงค์การเยี่ยม',
                        fields: [
                          DetailInnerField(
                              label: 'รายละเอียด',
                              value: detail.objective),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DetailInfoCard(
                        title: 'ปัญหาสุขภาพ',
                        fields: [
                          DetailInnerField(
                              label: 'รายละเอียด',
                              value: detail.healthProblem),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DetailInfoCard(
                        title: 'ข้อมูลทางการแพทย์',
                        fields: [
                          DetailInnerField(
                              label: 'รายละเอียด',
                              value: detail.medicalInfo),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DetailInfoCard(
                        title: 'ข้อมูลด้านสังคมและสิ่งแวดล้อม',
                        fields: [
                          for (final e in detail.socialInfo)
                            DetailInnerField(label: e.key, value: e.value),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DetailInfoCard(
                        title: 'บันทึกการเยี่ยมบ้าน',
                        fields: [
                          for (final e in detail.visitNotes)
                            DetailInnerField(label: e.key, value: e.value),
                        ],
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
