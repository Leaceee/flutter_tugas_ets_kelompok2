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
