class ThaiDate {
  static const _monthsFull = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  static String format(DateTime date) {
    return '${date.day} ${_monthsFull[date.month - 1]} ${date.year + 543}';
  }

  static String formatShort(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yy = ((date.year + 543) % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }
}
