import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/drink_product.dart';
import '../models/food_product.dart';
import '../models/menu_product.dart';
import '../models/order_model.dart';
import 'order_code_service.dart';

/// Mengelola koneksi SQLite. Memakai pola singleton: seluruh aplikasi
/// berbagi satu instance dan satu koneksi database.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  static const String _dbName = 'kantin_online.db';
  static const int _dbVersion = 2;

  Future<Database>? _opening;

  Future<Database> get database async {
    _opening ??= _open();
    try {
      return await _opening!;
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Versi lama selalu menampilkan pesan pembayaran berhasil. Pertahankan
      // status tersebut untuk QRIS lama, tetapi ubah pilihan Saldo lama menjadi
      // tunai saat pengambilan agar sesuai dengan konsep pembayaran yang baru.
      await db.execute(
        "ALTER TABLE orders ADD COLUMN payment_status TEXT NOT NULL DEFAULT 'Sudah Dibayar'",
      );
      await db.execute(
        "UPDATE orders SET payment_method = 'Tunai saat Pengambilan', payment_status = 'Belum Dibayar' WHERE payment_method = 'Saldo'",
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE menu_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        art TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        nim TEXT NOT NULL,
        pickup_time TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        payment_status TEXT NOT NULL DEFAULT 'Belum Dibayar',
        note TEXT NOT NULL DEFAULT '',
        total REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        qty INTEGER NOT NULL,
        option_label TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');
    await _seedMenu(db);
  }

  Future<void> _seedMenu(Database db) async {
    final products = <MenuProduct>[
      FoodProduct(
        name: 'Ayam geprek',
        price: 15000,
        category: 'Makanan',
        description:
            'Ayam goreng tepung dengan sambal bawang, nasi hangat, dan lalapan segar.',
        art: 'plate',
      ),
      FoodProduct(
        name: 'Mie ayam',
        price: 13000,
        category: 'Makanan',
        description: 'Mie kenyal dengan topping ayam kecap, sawi, dan kuah kaldu.',
        art: 'bowl',
      ),
      FoodProduct(
        name: 'Nasi goreng',
        price: 14000,
        category: 'Makanan',
        description: 'Nasi goreng bumbu kampung dengan telur dan kerupuk.',
        art: 'plate',
      ),
      FoodProduct(
        name: 'Soto ayam',
        price: 14000,
        category: 'Makanan',
        description: 'Soto ayam kuah bening dengan suwiran ayam dan telur.',
        art: 'bowl',
      ),
      DrinkProduct(
        name: 'Es teh manis',
        price: 5000,
        category: 'Minuman',
        description: 'Teh seduh segar dengan gula dan es batu.',
        art: 'tea',
      ),
      DrinkProduct(
        name: 'Kopi susu',
        price: 12000,
        category: 'Minuman',
        description: 'Kopi dengan susu segar, manisnya pas untuk menemani kuliah.',
        art: 'coffee',
      ),
      DrinkProduct(
        name: 'Es jeruk',
        price: 6000,
        category: 'Minuman',
        description: 'Perasan jeruk asli dengan es batu.',
        art: 'tea',
      ),
      DrinkProduct(
        name: 'Teh tarik',
        price: 8000,
        category: 'Minuman',
        description: 'Teh susu kental dengan buih lembut di atasnya.',
        art: 'coffee',
      ),
    ];
    final batch = db.batch();
    for (final product in products) {
      batch.insert('menu_items', product.toMap());
    }
    await batch.commit(noResult: true);
  }

  // READ: menu

  Future<List<MenuProduct>> getMenu() async {
    final db = await database;
    final rows = await db.query('menu_items', orderBy: 'id ASC');
    return rows.map(MenuProduct.fromMap).toList();
  }

  // CREATE: pesanan beserta rinciannya dalam satu transaksi

  Future<OrderModel> insertOrder(OrderModel order) async {
    final db = await database;
    return db.transaction<OrderModel>((txn) async {
      final id = await txn.insert('orders', order.toMap());
      final code = OrderCodeService.codeFromId(id);
      await txn.update(
        'orders',
        {'code': code},
        where: 'id = ?',
        whereArgs: [id],
      );
      for (final item in order.items) {
        await txn.insert('order_items', item.toMap(id));
      }
      return order.copyWith(id: id, code: code);
    });
  }

  // READ: pesanan

  Future<List<OrderModel>> getOrders() async {
    final db = await database;
    final rows = await db.query('orders', orderBy: 'id DESC');
    final result = <OrderModel>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final itemRows = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [id],
        orderBy: 'id ASC',
      );
      result.add(
        OrderModel.fromMap(row, itemRows.map(OrderItem.fromMap).toList()),
      );
    }
    return result;
  }

  // UPDATE

  Future<int> updateOrder(OrderModel order) async {
    final db = await database;
    return db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> updateOrderStatus(int id, String status) async {
    final db = await database;
    return db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateOrderPaymentStatus(int id, String paymentStatus) async {
    final db = await database;
    return db.update(
      'orders',
      {'payment_status': paymentStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE

  Future<void> deleteOrder(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('order_items', where: 'order_id = ?', whereArgs: [id]);
      await txn.delete('orders', where: 'id = ?', whereArgs: [id]);
    });
  }
}
