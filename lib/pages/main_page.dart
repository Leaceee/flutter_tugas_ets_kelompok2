import 'package:flutter/material.dart';

import 'home_page.dart';
import 'menu_page.dart';
import 'orders_page.dart';

/// Halaman induk dengan NavigationBar untuk tiga halaman utama.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(onOpenMenu: () => setState(() => _index = 1)),
      const MenuPage(),
      const OrdersPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
          ),
        ],
      ),
    );
  }
}
