import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/menu_provider.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/active_order_card.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'receipt_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenMenu});

  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final menu = context.watch<MenuProvider>();
    final latest = orders.latestActive;
    final activeCount = orders.activeOrders.length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang di',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      Text(
                        'Kantin Teknik',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.peach,
                  child: Icon(Icons.person_rounded, color: AppColors.orangeDark),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: appCard(radius: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group_rounded, size: 16, color: AppColors.orangeDark),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        activeCount == 0
                            ? 'Antrean sepi, pesananmu cepat diproses'
                            : '$activeCount pesananmu sedang dalam antrean',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ActiveOrderCard(
              order: latest,
              onOrder: onOpenMenu,
              onShowCode: () {
                if (latest == null) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReceiptPage(order: latest),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            const Text(
              'Populer hari ini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _popular(context, menu),
          ],
        ),
      ),
    );
  }

  Widget _popular(BuildContext context, MenuProvider menu) {
    if (menu.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
      );
    }
    if (menu.error != null) {
      return Column(
        children: [
          Text(menu.error!, style: const TextStyle(color: AppColors.muted)),
          TextButton(
            onPressed: () => context.read<MenuProvider>().loadMenu(),
            child: const Text('Coba lagi'),
          ),
        ],
      );
    }
    final items = menu.popular;
    if (items.isEmpty) {
      return const Text('Belum ada menu.', style: TextStyle(color: AppColors.muted));
    }
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 196,
              child: ProductCard(
                product: items[i],
                onTap: () => openProductDetail(context, items[i]),
                onAdd: () => quickAddToCart(context, items[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
