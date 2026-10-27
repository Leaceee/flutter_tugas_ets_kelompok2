import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../widgets/food_illustration.dart';
import '../widgets/state_views.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => context.read<CartProvider>().clear(),
              child: const Text('Kosongkan'),
            ),
        ],
      ),
      body: SafeArea(
        child: cart.isEmpty
            ? EmptyView(
                icon: Icons.shopping_bag_outlined,
                title: 'Keranjang masih kosong',
                subtitle: 'Pilih menu dulu, ya.',
                actionLabel: 'Lihat menu',
                onAction: () => Navigator.of(context).pop(),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) =>
                          _CartTile(item: cart.items[index], index: index),
                    ),
                  ),
                  _SummaryBar(cart: cart),
                ],
              ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item, required this.index});

  final CartItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: appCard(radius: 18),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: artTint(product.art),
              borderRadius: BorderRadius.circular(14),
            ),
            child: FoodIllustration(art: product.art, size: 42),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${product.optionLabel}: ${item.option}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                Text(
                  formatRupiah(item.subtotal),
                  style: const TextStyle(
                    color: AppColors.orangeDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Kurangi',
            onPressed: () => context.read<CartProvider>().decrease(index),
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          Text(
            '${item.qty}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          IconButton(
            tooltip: 'Tambah',
            onPressed: () => context.read<CartProvider>().increase(index),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Paling cepat siap ${cart.earliestPrepMinutes} menit',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text('Total', style: TextStyle(color: AppColors.muted)),
              ),
              Text(
                formatRupiah(cart.totalPrice),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CheckoutPage(items: cart.items),
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Lanjut bayar',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
