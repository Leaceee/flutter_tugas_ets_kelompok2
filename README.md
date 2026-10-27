# Kantin Online

Aplikasi Flutter untuk ETS mata kuliah Pengembangan Sistem Teknologi Bergerak (Mobile).
Mahasiswa memilih menu kantin, membuat pesanan, lalu membayar dengan dua cara:

- **QRIS (simulasi):** pembayaran dikonfirmasi lewat PIN dan struk menampilkan QR pesanan dengan status *Sudah Dibayar*.
- **Tunai saat pengambilan:** pesanan dibuat dengan status *Belum Dibayar*. Uang diserahkan ke penjual saat mengambil pesanan, lalu admin mengonfirmasi pembayarannya.

Setelah itu pesanan ditunjukkan ke penjual lewat kode order (misalnya `KNT-0001`).
Penjual memakai **Panel Admin** untuk mengonfirmasi pembayaran tunai dan menandai pesanan sudah diambil.

## Menjalankan

Prasyarat: Flutter terpasang dan emulator Android (atau HP Android) tersedia.
Aplikasi memakai SQLite (`sqflite`) yang hanya berjalan di Android atau iOS, bukan di Chrome.

```bash
flutter pub get
flutter analyze
flutter test
flutter devices        # pastikan ada perangkat Android
flutter run
```

Database dibuat otomatis saat pertama dijalankan beserta 8 menu bawaan.
Data pesanan lama dari versi sebelumnya dimigrasi otomatis ke skema versi 2
(kolom `payment_status`). Untuk mengulang dari awal, hapus aplikasi dari emulator
lalu jalankan lagi.

Jika `flutter test` gagal karena nama paket, ganti `package:kantin_online/` pada file di
`test/` dengan nama proyek yang tertulis di baris `name:` pada `pubspec.yaml`.

## Struktur folder

```
lib/
├── main.dart                    MultiProvider, tema, halaman awal
├── models/                      abstract class dan turunannya
│   ├── menu_product.dart        abstract class MenuProduct (blueprint)
│   ├── food_product.dart        turunan 1, prepMinutes = 10, level pedas
│   ├── drink_product.dart       turunan 2, prepMinutes = 3, pilihan suhu
│   ├── cart_item.dart
│   └── order_model.dart         OrderModel, OrderItem, OrderStatus,
│                                PaymentMethod, PaymentStatus
├── services/
│   ├── database_helper.dart     singleton SQLite, CRUD async, migrasi versi 2
│   └── order_code_service.dart  kode order dan slot waktu ambil
├── providers/                   state dan logika bisnis (ChangeNotifier)
│   ├── menu_provider.dart
│   ├── cart_provider.dart       total harga dan waktu penyiapan terlama
│   └── order_provider.dart      CRUD pesanan, status pembayaran, status pesanan
├── pages/
│   ├── main_page.dart           NavigationBar, 3 halaman utama
│   ├── home_page.dart
│   ├── menu_page.dart
│   ├── product_detail_page.dart
│   ├── cart_page.dart
│   ├── checkout_page.dart       form pembayaran (mode tambah dan ubah)
│   ├── receipt_page.dart        struk: QR untuk QRIS, kode teks untuk tunai
│   ├── orders_page.dart
│   └── admin_orders_page.dart   panel admin: konfirmasi tunai, tandai diambil
├── widgets/                     komponen yang dipakai ulang
└── utils/                       validators, format, tema
test/                            unit test (model, validator, keranjang, kode order, format)
```

## Pemetaan ke indikator ETS

| Indikator | Lokasi |
|---|---|
| Abstract class, 2 turunan, override | `models/menu_product.dart`, `food_product.dart`, `drink_product.dart` (override `prepMinutes`, `optionLabel`, `options`, `type`) |
| Encapsulation | atribut `_id`, `_name`, `_price`, dst. dengan getter dan constructor di semua model |
| Struktur folder | `models`, `pages`, `widgets`, `providers`, `services` |
| Layout | `Container`, `Row`, `Column`, `Expanded`, `Flexible`, `Stack`, `ListView.builder` (keranjang, pesanan, panel admin), `GridView.builder` (menu) |
| Responsif | halaman bisa di-scroll, teks dalam `Row` memakai `Expanded` dan `ellipsis`, grid memakai `SliverGridDelegateWithMaxCrossAxisExtent`, header menu berubah di landscape |
| 3 halaman, navigasi | `main_page.dart` dengan `NavigationBar` (Beranda, Menu, Pesanan) |
| Navigator dan passing data | Menu ke Detail (`MenuProduct`), Keranjang ke Pembayaran (`List<CartItem>`), Pembayaran ke Struk (`OrderModel`), Pesanan ke Ubah (`OrderModel`) |
| Provider | `MenuProvider`, `CartProvider`, `OrderProvider` dengan `context.watch` dan `context.read` |
| Pemisahan logika | total, waktu penyiapan, penentuan status pembayaran (`PaymentMethod.isCash`), dan konfirmasi tunai (`markPaymentReceived`) ada di provider. Tidak ada pemanggilan `DatabaseHelper` di `pages/` dan `widgets/` |
| SQLite, singleton, CRUD | `services/database_helper.dart`: Create (`insertOrder`), Read (`getMenu`, `getOrders`), Update (`updateOrder`, `updateOrderStatus`, `updateOrderPaymentStatus`), Delete (`deleteOrder`). Versi database 2 dengan `onUpgrade` |
| Loading, kosong, error | `widgets/state_views.dart`, dipakai di Menu, Keranjang, Pesanan, dan panel admin |
| Form, GlobalKey, TextFormField | `pages/checkout_page.dart` (nama, NIM, catatan, PIN) |
| Validasi (5 jenis) | wajib diisi (nama, NIM, waktu ambil, konfirmasi), panjang minimal (nama 3 karakter), tipe angka (NIM, PIN), rentang panjang (NIM 8 sampai 12 digit), panjang maksimal (catatan 50 karakter), panjang tepat (PIN 4 digit) |
| Input pilihan | `DropdownButtonFormField` (waktu ambil), `CheckboxListTile` (konfirmasi pesanan), `SegmentedButton` (metode bayar QRIS atau Tunai) |
| UX form | `keyboardType: number` (NIM, PIN), `obscureText` pada PIN QRIS, tombol menjadi indikator loading saat memproses, pengaman klik ganda, `SnackBar` |

## Alur pembayaran

| | QRIS (simulasi) | Tunai saat pengambilan |
|---|---|---|
| Form pembayaran | ada field PIN 4 digit (`obscureText`) | tanpa PIN |
| Status pembayaran saat dibuat | Sudah Dibayar | Belum Dibayar |
| Struk | QR pesanan, kode teks, status Sudah Dibayar | ikon struk, kode teks, catatan bayar tunai saat mengambil |
| Konfirmasi | tidak perlu | admin menekan "Konfirmasi Pembayaran Tunai" setelah uang diterima |
| Pengambilan | admin menekan "Tandai Sudah Diambil" | sama, setelah pembayaran dikonfirmasi |

## Naskah demo (urutan video)

1. **Beranda.** Tunjukkan kartu "Belum ada pesanan aktif" dan daftar populer.
2. **Menu (GridView).** Cari "mie", pindah kategori Minuman, hapus pencarian. Tunjukkan tampilan loading saat pertama dibuka.
3. **Tampilan error.** Di Menu, tekan titik tiga lalu "Simulasikan error (demo)". Tunjukkan pesan error dan tombol "Coba lagi". Matikan lewat titik tiga yang sama ("Matikan simulasi error").
4. **Detail menu.** Ketuk Ayam geprek. Tunjukkan label "Siap sekitar 10 mnt" (minuman: 3 mnt). Itu hasil override `prepMinutes` tiap turunan. Pilih level pedas, jumlah 1, tambah ke keranjang.
5. **Tambah minuman** dari tombol plus di kartu. Buka Keranjang. Tunjukkan teks "Paling cepat siap 10 menit", ubah jumlah, lalu "Lanjut bayar".
6. **Validasi form (QRIS).** Isi nama "ab" (minimal 3), NIM "1234-567" (bukan angka murni), kosongkan waktu ambil, isi catatan lebih dari 50 karakter, PIN "12" (harus 4 digit), jangan centang konfirmasi, lalu tekan tombol bayar. Tunjukkan semua pesan error, lalu perbaiki satu per satu sampai PIN tampil sebagai titik-titik.
7. **Bayar QRIS.** Tombol berubah menjadi indikator loading, lalu muncul struk dengan QR, kode order, dan status Sudah Dibayar. Tekan "Tutup", lalu buka tab Beranda: kartu pesanan aktif menampilkan kode order.
8. **Bayar tunai.** Buat pesanan kedua, pilih **Tunai**. Tunjukkan field PIN hilang. Struk menampilkan status Belum Dibayar tanpa QR.
9. **Panel Admin.** Buka Panel Admin. Pada pesanan tunai, tekan "Konfirmasi Pembayaran Tunai" lalu "Ya, sudah diterima" (status menjadi Sudah Dibayar). Tekan "Tandai Sudah Diambil" lalu "Ya, sudah diambil".
10. **Pesanan.** Tab Aktif: ubah waktu ambil dan catatan (Update), lalu lihat pesanan yang sudah diambil di tab Riwayat. Buat pesanan tambahan lalu "Batalkan" (Delete).
11. **Layar kecil dan landscape.** Putar emulator ke landscape di setiap halaman, tunjukkan tidak ada garis overflow kuning-hitam.
12. **Data permanen.** Tutup aplikasi sepenuhnya lalu buka lagi. Pesanan dan status pembayaran masih ada karena tersimpan di SQLite.

## Catatan

- Pembayaran QRIS adalah simulasi dan belum terhubung ke penyedia pembayaran. PIN hanya divalidasi bentuknya (4 digit) dan tidak disimpan.
- QR di struk hanya tampil untuk pesanan QRIS dan dipakai untuk demo, bukan QR pembayaran sungguhan. Pesanan tunai memakai kode teks (misalnya `KNT-0002`) yang dibaca penjual.
- Pada mode ubah pesanan, metode bayar dan status pembayaran tidak bisa diubah.
- Kolom NIM sengaja tidak memfilter karakter, supaya pesan validasi "NIM harus berupa angka" bisa didemokan.
- Unit test berjalan dengan `flutter test` dan mencakup model, validator, keranjang, kode order, dan format.
