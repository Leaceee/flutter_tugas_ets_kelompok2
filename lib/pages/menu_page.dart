import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/cart_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';
import 'cart_page.dart';
import 'product_detail_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final cart = context.watch<CartProvider>();
    final landscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Opsi demo',
            onSelected: (_) => context.read<MenuProvider>().toggleSimulateError(),
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'error',
                child: Text(
                  menu.simulateError
                      ? 'Matikan simulasi error'
                      : 'Simulasikan error (demo)',
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: landscape
                  ? Row(
                      children: [
                        Expanded(flex: 2, child: _searchField(context)),
                        const SizedBox(width: 12),
                        Expanded(flex: 3, child: _categoryChips(context, menu)),
                      ],
                    )
                  : Column(
                      children: [
                        _searchField(context),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _categoryChips(context, menu),
                        ),
                      ],
                    ),
            ),
            Expanded(child: _content(context, menu)),
            if (!cart.isEmpty)
              CartBar(
                itemCount: cart.totalItems,
                total: cart.totalPrice,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CartPage()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return TextField(
      onChanged: (value) => context.read<MenuProvider>().search(value),
      decoration: const InputDecoration(
        hintText: 'Cari makanan atau minuman',
        prefixIcon: Icon(Icons.search_rounded),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      ),
    );
  }

  Widget _categoryChips(BuildContext context, MenuProvider menu) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in menu.categories) ...[
            ChoiceChip(
              label: Text(c),
              selected: menu.category == c,
              showCheckmark: false,
              selectedColor: AppColors.orange,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: menu.category == c ? Colors.white : AppColors.muted,
              ),
              onSelected: (_) => context.read<MenuProvider>().setCategory(c),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _content(BuildContext context, MenuProvider menu) {
    if (menu.isLoading) {
      return const LoadingView(message: 'Memuat menu...');
    }
    if (menu.error != null) {
      return ErrorView(
        message: menu.error!,
        onRetry: () => context.read<MenuProvider>().loadMenu(),
      );
    }
    final products = menu.products;
    if (products.isEmpty) {
      return const EmptyView(
        icon: Icons.search_off_rounded,
        title: 'Menu tidak ditemukan',
        subtitle: 'Coba kata kunci atau kategori lain.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 196,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => openProductDetail(context, product),
          onAdd: () => quickAddToCart(context, product),
        );
      },
    );
  }
}
