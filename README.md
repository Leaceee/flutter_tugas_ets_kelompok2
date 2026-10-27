# Kantin Online

Aplikasi Flutter untuk ETS mata kuliah Pengembangan Sistem Teknologi Bergerak (Mobile).
Mahasiswa memilih menu kantin, membayar lewat aplikasi (simulasi), lalu mendapat struk
dan kode order yang ditunjukkan ke penjual saat mengambil pesanan.

## Menjalankan

```bash
flutter create kantin_online
cd kantin_online
# salin isi folder ini ke dalam proyek: lib/, test/, pubspec.yaml, analysis_options.yaml
# (timpa file yang sudah ada)
flutter pub get
flutter analyze
flutter test
flutter run
```

Kalau data lama ingin diulang dari awal, hapus aplikasi dari emulator lalu jalankan lagi
(database dibuat ulang beserta 8 menu bawaan).

## Struktur folder

```
lib/
├── main.dart                  MultiProvider, tema, halaman awal
├── models/                    abstract class dan turunannya
│   ├── menu_product.dart      abstract class MenuProduct (blueprint)
│   ├── food_product.dart      turunan 1, prepMinutes = 10, level pedas
│   ├── drink_product.dart     turunan 2, prepMinutes = 3, pilihan suhu
│   ├── cart_item.dart
│   └── order_model.dart       OrderModel, OrderItem, OrderStatus
├── services/
│   ├── database_helper.dart   singleton SQLite, CRUD async
│   └── order_code_service.dart  kode order dan slot waktu ambil
├── providers/                 state dan logika bisnis (ChangeNotifier)
│   ├── menu_provider.dart
│   ├── cart_provider.dart
│   └── order_provider.dart
├── pages/
│   ├── main_page.dart         NavigationBar, 3 halaman utama
│   ├── home_page.dart
│   ├── menu_page.dart
│   ├── product_detail_page.dart
│   ├── cart_page.dart
│   ├── checkout_page.dart     form pembayaran (mode tambah dan ubah)
│   ├── receipt_page.dart
│   └── orders_page.dart
├── widgets/                   komponen yang dipakai ulang
└── utils/                     validators, format, tema
test/                          unit test (model, validator, keranjang, kode order, format)
```

## Pemetaan ke indikator ETS

| Indikator | Lokasi |
|---|---|
| Abstract class, 2 turunan, override | `models/menu_product.dart`, `food_product.dart`, `drink_product.dart` (override `prepMinutes`, `optionLabel`, `options`, `type`) |
| Encapsulation | atribut `_id`, `_name`, `_price`, dst. dengan getter dan constructor di semua model |
| Struktur folder | `models`, `pages`, `widgets`, `providers`, `services` |
| Layout | `Container`, `Row`, `Column`, `Expanded`, `Flexible`, `Stack` (`active_order_card.dart`, `product_detail_page.dart`), `ListView.builder` (`cart_page.dart`, `orders_page.dart`), `GridView.builder` (`menu_page.dart`) |
| Responsif | halaman bisa di-scroll, teks dalam `Row` memakai `Expanded` dan `ellipsis`, grid memakai `SliverGridDelegateWithMaxCrossAxisExtent`, header menu berubah di landscape |
| 3 halaman, navigasi | `main_page.dart` dengan `NavigationBar` |
| Navigator dan passing data | Menu ke Detail (`MenuProduct`), Keranjang ke Pembayaran (`List<CartItem>`), Pembayaran ke Struk (`OrderModel`), Pesanan ke Ubah (`OrderModel`) |
| Provider | `MenuProvider`, `CartProvider`, `OrderProvider` dengan `context.watch` dan `context.read` |
| Pemisahan logika | tidak ada pemanggilan `DatabaseHelper` di `pages/` dan `widgets/` |
| SQLite, singleton, CRUD | `services/database_helper.dart`: Create (`insertOrder`), Read (`getMenu`, `getOrders`), Update (`updateOrder`, `updateOrderStatus`), Delete (`deleteOrder`) |
| Loading, kosong, error | `widgets/state_views.dart`, dipakai di Menu, Keranjang, dan Pesanan |
| Form, GlobalKey, TextFormField | `pages/checkout_page.dart` |
| Validasi (5 jenis) | wajib diisi, panjang minimal (nama), tipe angka (NIM, PIN), rentang panjang (NIM 8 sampai 12), panjang maksimal (catatan 50), panjang tepat (PIN 4 digit) |
| Input pilihan | `DropdownButtonFormField` (waktu ambil), `CheckboxListTile` (konfirmasi), `SegmentedButton` (metode bayar) |
| UX form | `keyboardType: number`, `obscureText` pada PIN, tombol menjadi indikator loading saat memproses, `SnackBar` |

## Naskah demo (urutan video)

1. **Beranda.** Tunjukkan kartu "Belum ada pesanan aktif" dan daftar populer.
2. **Menu (GridView).** Cari "mie", pindah kategori Minuman, hapus pencarian. Tunjukkan tampilan loading saat pertama dibuka.
3. **Tampilan error.** Di Menu, tekan titik tiga lalu "Simulasikan error (demo)". Tunjukkan pesan error dan tombol "Coba lagi". Matikan lewat titik tiga yang sama ("Matikan simulasi error").
4. **Detail menu.** Ketuk Ayam geprek. Tunjukkan label "Siap sekitar 10 mnt" (minuman: 3 mnt). Itu hasil override `prepMinutes` tiap turunan. Pilih level pedas, jumlah 1, tambah ke keranjang.
5. **Tambah minuman** dari tombol plus di kartu. Buka Keranjang. Tunjukkan teks "Paling cepat siap 10 menit" (diambil dari produk terlama), ubah jumlah, lalu "Lanjut bayar".
6. **Validasi form.** Isi nama "ab" (minimal 3), NIM "1234-567" (tanda minus membuat NIM bukan angka murni; di emulator bisa juga mengetik huruf lewat keyboard laptop), kosongkan waktu ambil, PIN "12" (harus 4 digit), jangan centang konfirmasi, lalu tekan Bayar. Tunjukkan semua pesan error, lalu perbaiki satu per satu.
7. **Bayar.** Tombol berubah menjadi indikator loading, lalu muncul struk dan kode order. Tekan "Selesai", lalu buka tab Beranda: kartu pesanan aktif menampilkan kode order.
8. **Pesanan.** Tab Aktif: ubah waktu ambil (Update), tandai "Diambil" (Update status), lalu lihat di tab Riwayat. Buat pesanan kedua lalu "Batalkan" (Delete).
9. **Layar kecil dan landscape.** Putar emulator ke landscape di setiap halaman, tunjukkan tidak ada garis overflow kuning-hitam.
10. **Data permanen.** Tutup aplikasi sepenuhnya lalu buka lagi. Pesanan masih ada karena tersimpan di SQLite.

## Catatan

- Pembayaran adalah simulasi. PIN hanya divalidasi bentuknya (4 digit) dan tidak disimpan.
- Pola di struk mirip QR tetapi hanya tampilan. Yang dibaca penjual adalah teks kodenya (misalnya `KNT-0042`).
- Kolom NIM sengaja tidak memfilter karakter, supaya pesan validasi "NIM harus berupa angka" bisa didemokan.
- Unit test berjalan dengan `flutter test` dan mencakup model, validator, keranjang, kode order, dan format.
