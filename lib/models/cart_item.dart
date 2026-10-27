import 'menu_product.dart';

/// Satu baris di keranjang: produk, pilihan (level pedas/suhu), dan jumlah.
class CartItem {
  final MenuProduct _product;
  final String _option;
  int _qty;

  CartItem({
    required MenuProduct product,
    required String option,
    int qty = 1,
  })  : _product = product,
        _option = option,
        _qty = qty < 1 ? 1 : qty;

  MenuProduct get product => _product;
  String get option => _option;
  int get qty => _qty;

  set qty(int value) => _qty = value < 1 ? 1 : value;

  double get subtotal => _product.price * _qty;

  /// Dua baris dianggap sama jika produk dan pilihannya sama.
  bool sameAs(MenuProduct product, String option) {
    return _product.id == product.id && _option == option;
  }
}
