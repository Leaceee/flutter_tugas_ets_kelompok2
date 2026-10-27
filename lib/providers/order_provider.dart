import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../services/database_helper.dart';

/// State pesanan. Semua operasi CRUD lewat provider ini ke DatabaseHelper.
class OrderProvider extends ChangeNotifier {
  OrderProvider({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);

  List<OrderModel> get activeOrders =>
      _orders.where((o) => o.isActive).toList();

  List<OrderModel> get historyOrders =>
      _orders.where((o) => !o.isActive).toList();

  OrderModel? get latestActive {
    final active = activeOrders;
    return active.isEmpty ? null : active.first;
  }

  // READ
  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _db.getOrders();
    } catch (_) {
      _error = 'Gagal memuat pesanan. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE
  Future<OrderModel> placeOrder({
    required String customerName,
    required String nim,
    required String pickupTime,
    required String paymentMethod,
    required String note,
    required List<CartItem> items,
  }) async {
    final total = items.fold<double>(0, (sum, e) => sum + e.subtotal);
    final draft = OrderModel(
      code: 'KNT-0000',
      customerName: customerName,
      nim: nim,
      pickupTime: pickupTime,
      paymentMethod: paymentMethod,
      // QRIS di versi ETS ini masih simulasi. Pembayaran tunai dicatat belum
      // dibayar sampai penjual menerima uang saat pengambilan.
      paymentStatus: PaymentMethod.isCash(paymentMethod)
          ? PaymentStatus.unpaid
          : PaymentStatus.paid,
      note: note,
      total: total,
      status: OrderStatus.waiting,
      createdAt: DateTime.now(),
      items: items
          .map((e) => OrderItem(
                name: e.product.name,
                price: e.product.price,
                qty: e.qty,
                option: e.option,
              ))
          .toList(),
    );
    final saved = await _db.insertOrder(draft);
    _orders = [saved, ..._orders];
    notifyListeners();
    return saved;
  }

  // UPDATE: ubah data pesanan
  Future<void> updateOrder(OrderModel updated) async {
    await _db.updateOrder(updated);
    _orders = _orders.map((o) => o.id == updated.id ? updated : o).toList();
    notifyListeners();
  }

  // UPDATE: konfirmasi uang tunai telah diterima oleh penjual/Admin.
  Future<void> markPaymentReceived(int id) async {
    await _db.updateOrderPaymentStatus(id, PaymentStatus.paid);
    _orders = _orders
        .map((o) => o.id == id ? o.copyWith(paymentStatus: PaymentStatus.paid) : o)
        .toList();
    notifyListeners();
  }

  // UPDATE: tandai sudah diambil
  Future<void> markPickedUp(int id) async {
    await _db.updateOrderStatus(id, OrderStatus.done);
    _orders = _orders
        .map((o) => o.id == id ? o.copyWith(status: OrderStatus.done) : o)
        .toList();
    notifyListeners();
  }

  // DELETE: batalkan pesanan
  Future<void> cancelOrder(int id) async {
    await _db.deleteOrder(id);
    _orders = _orders.where((o) => o.id != id).toList();
    notifyListeners();
  }
}
