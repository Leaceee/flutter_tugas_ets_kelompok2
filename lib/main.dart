import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'pages/main_page.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/order_provider.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SQLite untuk aplikasi desktop.
  if (!kIsWeb &&
      (Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const KantinApp());
}

class KantinApp extends StatelessWidget {
  const KantinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MenuProvider()..loadMenu(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider()..loadOrders(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Kantin Online',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const MainPage(),
      ),
    );
  }
}