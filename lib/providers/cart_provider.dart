import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/menu_product.dart';

/// State keranjang belanja. Semua perhitungan ada di sini, bukan di widget.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  int get totalItems => _items.fold<int>(0, (sum, e) => sum + e.qty);

  double get totalPrice => _items.fold<double>(0, (sum, e) => sum + e.subtotal);

  /// Waktu penyiapan terlama di keranjang. Tiap produk punya nilai sendiri
  /// (override prepMinutes), jadi tidak perlu mengecek jenis produknya.
  int get earliestPrepMinutes {
    if (_items.isEmpty) return 0;
    return _items
        .map((e) => e.product.prepMinutes)
        .reduce((a, b) => a > b ? a : b);
  }

  void add(MenuProduct product, String option, {int qty = 1}) {
    final index = _items.indexWhere((e) => e.sameAs(product, option));
    if (index >= 0) {
      _items[index].qty = _items[index].qty + qty;
    } else {
      _items.add(CartItem(product: product, option: option, qty: qty));
    }
    notifyListeners();
  }

  void increase(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index].qty = _items[index].qty + 1;
    notifyListeners();
  }

  void decrease(int index) {
    if (index < 0 || index >= _items.length) return;
    if (_items[index].qty <= 1) {
      _items.removeAt(index);
    } else {
      _items[index].qty = _items[index].qty - 1;
    }
    notifyListeners();
  }

  void remove(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
