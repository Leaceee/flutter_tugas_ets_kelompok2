/// Mengubah angka menjadi format rupiah, misalnya 28000 menjadi "Rp 28.000".
String formatRupiah(num value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'Rp $buffer';
}

String twoDigits(int value) => value.toString().padLeft(2, '0');

/// Contoh hasil: "26 Okt 2026, 12.04".
String formatDateTime(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}, '
      '${twoDigits(date.hour)}.${twoDigits(date.minute)}';
}
