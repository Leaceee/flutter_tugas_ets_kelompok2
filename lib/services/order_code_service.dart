import '../utils/format.dart';

/// Logika kecil untuk kode order dan slot waktu ambil.
class OrderCodeService {
  OrderCodeService._();

  /// Contoh: 42 menjadi "KNT-0042".
  static String codeFromId(int id) {
    return 'KNT-${id.toString().padLeft(4, '0')}';
  }

  /// Membuat daftar jam ambil kelipatan [stepMinutes], dimulai dari waktu
  /// paling cepat (sekarang + [prepMinutes]) yang dibulatkan ke atas.
  static List<String> pickupSlots(
    DateTime now,
    int prepMinutes, {
    int count = 6,
    int stepMinutes = 15,
  }) {
    var earliest = now.add(Duration(minutes: prepMinutes));
    if (earliest.second > 0 || earliest.millisecond > 0) {
      earliest = earliest.add(const Duration(minutes: 1));
    }
    final totalMinutes = earliest.hour * 60 + earliest.minute;
    final start = ((totalMinutes + stepMinutes - 1) ~/ stepMinutes) * stepMinutes;
    return List<String>.generate(count, (i) {
      final minutes = (start + i * stepMinutes) % (24 * 60);
      return '${twoDigits(minutes ~/ 60)}.${twoDigits(minutes % 60)}';
    });
  }
}
