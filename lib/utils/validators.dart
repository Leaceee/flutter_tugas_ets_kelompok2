/// Kumpulan aturan validasi untuk form.
/// Jenis aturan yang dipakai: wajib diisi, panjang minimal, tipe angka,
/// panjang tepat/rentang, dan panjang maksimal.
class Validators {
  Validators._();

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  static String? notEmpty(String? value, {String field = 'Kolom ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }
    return null;
  }

  /// Wajib diisi dan minimal 3 karakter.
  static String? name(String? value) {
    final empty = notEmpty(value, field: 'Nama');
    if (empty != null) return empty;
    if (value!.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  /// Wajib diisi, hanya angka, dan 8 sampai 12 digit.
  static String? nim(String? value) {
    final empty = notEmpty(value, field: 'NIM');
    if (empty != null) return empty;
    final text = value!.trim();
    if (!_digitsOnly.hasMatch(text)) {
      return 'NIM harus berupa angka';
    }
    if (text.length < 8 || text.length > 12) {
      return 'NIM harus 8 sampai 12 digit';
    }
    return null;
  }

  /// Opsional, tetapi maksimal 50 karakter.
  static String? note(String? value) {
    if (value != null && value.trim().length > 50) {
      return 'Catatan maksimal 50 karakter';
    }
    return null;
  }

  /// Wajib diisi, hanya angka, dan tepat 4 digit.
  static String? pin(String? value) {
    final empty = notEmpty(value, field: 'PIN');
    if (empty != null) return empty;
    final text = value!.trim();
    if (!_digitsOnly.hasMatch(text)) {
      return 'PIN harus berupa angka';
    }
    if (text.length != 4) {
      return 'PIN harus 4 digit';
    }
    return null;
  }

  static String? pickup(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pilih waktu ambil';
    }
    return null;
  }
}
