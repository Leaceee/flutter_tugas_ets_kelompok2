import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/order_tile.dart';
import '../widgets/state_views.dart';
import 'admin_orders_page.dart';
import 'checkout_page.dart';
import 'receipt_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _tab = 0;

  void _openReceipt(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ReceiptPage(order: order)),
    );
  }

  void _openEdit(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CheckoutPage.edit(order: order)),
    );
  }

  Future<void> _confirmCancel(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan pesanan?'),
        content: Text(
          'Pesanan ${order.code} akan dihapus dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Ya, batalkan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.cancelOrder(order.id!);
      messenger.showSnackBar(
        SnackBar(content: Text('Pesanan ${order.code} dibatalkan')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal membatalkan pesanan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Panel Admin (demo)',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AdminOrdersPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  segments: <ButtonSegment<int>>[
                    ButtonSegment<int>(
                      value: 0,
                      label: Text('Aktif (${provider.activeOrders.length})'),
                    ),
                    const ButtonSegment<int>(value: 1, label: Text('Riwayat')),
                  ],
                  selected: <int>{_tab},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) =>
                      setState(() => _tab = selection.first),
                ),
              ),
            ),
            Expanded(child: _content(provider)),
          ],
        ),
      ),
    );
  }

  Widget _content(OrderProvider provider) {
    if (provider.isLoading && provider.orders.isEmpty) {
      return const LoadingView(message: 'Memuat pesanan...');
    }
    if (provider.error != null) {
      return ErrorView(
        message: provider.error!,
        onRetry: () => context.read<OrderProvider>().loadOrders(),
      );
    }

    final showActive = _tab == 0;
    final list = showActive ? provider.activeOrders : provider.historyOrders;
    if (list.isEmpty) {
      return EmptyView(
        icon: Icons.receipt_long_rounded,
        title: showActive ? 'Belum ada pesanan aktif' : 'Riwayat masih kosong',
        subtitle: showActive
            ? 'Pesanan aktif akan muncul di sini, termasuk pesanan tunai yang belum dibayar.'
            : 'Pesanan yang sudah selesai akan tersimpan di sini.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<OrderProvider>().loadOrders(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final order = list[index];
          final isPaid = order.paymentStatus == PaymentStatus.paid;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OrderTile(
                  order: order,
                  onShowCode: () => _openReceipt(order),
                  onEdit: order.isActive ? () => _openEdit(order) : null,
                  // Status pengambilan dikelola melalui Panel Admin.
                  onPickedUp: null,
                  onCancel: order.isActive ? () => _confirmCancel(order) : null,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6, left: 4, right: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? AppColors.green.withValues(alpha: 0.08)
                        : AppColors.orange.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPaid
                            ? Icons.check_circle_outline_rounded
                            : Icons.schedule_rounded,
                        size: 18,
                        color: isPaid ? AppColors.green : AppColors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${order.paymentMethod} · ${order.paymentStatus}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
