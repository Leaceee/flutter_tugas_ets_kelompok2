/// Status pesanan yang dipakai di seluruh aplikasi.
class OrderStatus {
  OrderStatus._();
  static const String waiting = 'Menunggu diambil';
  static const String done = 'Selesai';
}

/// Metode pembayaran yang tersedia pada aplikasi Kantin Online.
class PaymentMethod {
  PaymentMethod._();

  static const String qris = 'QRIS';
  static const String cashOnPickup = 'Tunai saat Pengambilan';

  static bool isCash(String method) => method == cashOnPickup;
}

/// Status pembayaran dipisahkan dari status pesanan.
class PaymentStatus {
  PaymentStatus._();

  static const String paid = 'Sudah Dibayar';
  static const String unpaid = 'Belum Dibayar';
}

/// Rincian satu produk di dalam pesanan (salinan harga saat dibeli).
class OrderItem {
  final String _name;
  final double _price;
  final int _qty;
  final String _option;

  OrderItem({
    required String name,
    required double price,
    required int qty,
    required String option,
  })  : _name = name,
        _price = price,
        _qty = qty,
        _option = option;

  String get name => _name;
  double get price => _price;
  int get qty => _qty;
  String get option => _option;
  double get subtotal => _price * _qty;

  Map<String, Object?> toMap(int orderId) {
    return {
      'order_id': orderId,
      'product_name': _name,
      'price': _price,
      'qty': _qty,
      'option_label': _option,
    };
  }

  factory OrderItem.fromMap(Map<String, Object?> map) {
    return OrderItem(
      name: map['product_name'] as String,
      price: (map['price'] as num).toDouble(),
      qty: map['qty'] as int,
      option: map['option_label'] as String,
    );
  }
}

class OrderModel {
  final int? _id;
  final String _code;
  final String _customerName;
  final String _nim;
  final String _pickupTime;
  final String _paymentMethod;
  final String _paymentStatus;
  final String _note;
  final double _total;
  final String _status;
  final DateTime _createdAt;
  final List<OrderItem> _items;

  OrderModel({
    int? id,
    required String code,
    required String customerName,
    required String nim,
    required String pickupTime,
    required String paymentMethod,
    String? paymentStatus,
    String note = '',
    required double total,
    required String status,
    required DateTime createdAt,
    List<OrderItem> items = const [],
  })  : _id = id,
        _code = code,
        _customerName = customerName,
        _nim = nim,
        _pickupTime = pickupTime,
        _paymentMethod = paymentMethod,
        _paymentStatus = paymentStatus ??
            (PaymentMethod.isCash(paymentMethod) ? PaymentStatus.unpaid : PaymentStatus.paid),
        _note = note,
        _total = total,
        _status = status,
        _createdAt = createdAt,
        _items = List<OrderItem>.of(items);

  int? get id => _id;
  String get code => _code;
  String get customerName => _customerName;
  String get nim => _nim;
  String get pickupTime => _pickupTime;
  String get paymentMethod => _paymentMethod;
  String get paymentStatus => _paymentStatus;
  String get note => _note;
  double get total => _total;
  String get status => _status;
  DateTime get createdAt => _createdAt;
  List<OrderItem> get items => List<OrderItem>.unmodifiable(_items);

  bool get isActive => _status == OrderStatus.waiting;

  String get itemsSummary =>
      _items.map((e) => '${e.qty}x ${e.name}').join(', ');

  OrderModel copyWith({
    int? id,
    String? code,
    String? customerName,
    String? nim,
    String? pickupTime,
    String? paymentMethod,
    String? paymentStatus,
    String? note,
    double? total,
    String? status,
    List<OrderItem>? items,
  }) {
    return OrderModel(
      id: id ?? _id,
      code: code ?? _code,
      customerName: customerName ?? _customerName,
      nim: nim ?? _nim,
      pickupTime: pickupTime ?? _pickupTime,
      paymentMethod: paymentMethod ?? _paymentMethod,
      paymentStatus: paymentStatus ?? _paymentStatus,
      note: note ?? _note,
      total: total ?? _total,
      status: status ?? _status,
      createdAt: _createdAt,
      items: items ?? _items,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (_id != null) 'id': _id,
      'code': _code,
      'customer_name': _customerName,
      'nim': _nim,
      'pickup_time': _pickupTime,
      'payment_method': _paymentMethod,
      'payment_status': _paymentStatus,
      'note': _note,
      'total': _total,
      'status': _status,
      'created_at': _createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, Object?> map, List<OrderItem> items) {
    return OrderModel(
      id: map['id'] as int?,
      code: map['code'] as String,
      customerName: map['customer_name'] as String,
      nim: map['nim'] as String,
      pickupTime: map['pickup_time'] as String,
      paymentMethod: map['payment_method'] as String,
      paymentStatus: map['payment_status'] as String? ??
          ((map['payment_method'] as String) == PaymentMethod.cashOnPickup
              ? PaymentStatus.unpaid
              : PaymentStatus.paid),
      note: (map['note'] as String?) ?? '',
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      items: items,
    );
  }
}
