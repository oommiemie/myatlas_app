import 'package:flutter/cupertino.dart';

/// Represents a single OPD registration (ticket).
class OpdEntry {
  OpdEntry({
    required this.id,
    required this.patientName,
    required this.cid,
    required this.registeredAt,
    this.status = OpdStatus.active,
    Map<String, Object?>? form,
  }) : form = form ?? <String, Object?>{};

  final String id;
  final String patientName;
  final String cid;
  final DateTime registeredAt;
  final OpdStatus status;
  final Map<String, Object?> form;
}

enum OpdStatus { active, used, expired }

extension OpdStatusX on OpdStatus {
  String get label => switch (this) {
        OpdStatus.active => 'สามารถใช้ได้อีก 24:00:00',
        OpdStatus.used => 'ใช้ไปแล้ว',
        OpdStatus.expired => 'หมดอายุการใช้งาน',
      };

  Color get tintColor => switch (this) {
        OpdStatus.active => const Color(0xFF0891B2),
        OpdStatus.used => const Color(0xFF6D756E),
        OpdStatus.expired => const Color(0xFFDC2626),
      };
}

/// In-memory store for OPD registrations.
class OpdStore {
  OpdStore._();
  static final OpdStore instance = OpdStore._();

  final ValueNotifier<List<OpdEntry>> entries =
      ValueNotifier<List<OpdEntry>>([]);

  OpdEntry? get activeEntry =>
      entries.value.firstWhere(
        (e) => e.status == OpdStatus.active,
        orElse: () => OpdEntry(
          id: '',
          patientName: '',
          cid: '',
          registeredAt: DateTime.now(),
          status: OpdStatus.expired,
        ),
      ).id.isEmpty
          ? null
          : entries.value.firstWhere((e) => e.status == OpdStatus.active);

  List<OpdEntry> get history =>
      entries.value.where((e) => e.status != OpdStatus.active).toList();

  void add(OpdEntry entry) {
    entries.value = [entry, ...entries.value];
  }
}
