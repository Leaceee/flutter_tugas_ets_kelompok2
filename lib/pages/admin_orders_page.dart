import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../widgets/state_views.dart';

/// Panel demo untuk penjual/Admin mengonfirmasi uang tunai dan pengambilan.
/// Untuk aplikasi produksi, lindungi halaman ini dengan login dan pemeriksaan role.
class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  Future<void> _confirmCashPayment(
    BuildContext context,
    OrderModel order,
  ) async {
    if (!PaymentMethod.isCash(order.paymentMethod) ||
        order.paymentStatus == PaymentStatus.paid ||
        order.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi pembayaran tunai'),
        content: Text(
          'Pastikan uang sebesar ${formatRupiah(order.total)} untuk '
          'pesanan ${order.code} sudah diterima dari pelanggan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Belum'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, sudah diterima'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.markPaymentReceived(order.id!);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Pembayaran ${order.code} dikonfirmasi.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal mengonfirmasi pembayaran.')),
      );
    }
  }

  Future<void> _confirmPickedUp(
    BuildContext context,
    OrderModel order,
  ) async {
    if (order.paymentStatus != PaymentStatus.paid ||
        !order.isActive ||
        order.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tandai pesanan selesai?'),
        content: Text(
          'Pastikan pesanan ${order.code} sudah diserahkan kepada pelanggan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, sudah diambil'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.markPickedUp(order.id!);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Pesanan ${order.code} ditandai selesai.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status pesanan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel Admin',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang pesanan',
            onPressed: provider.isLoading
                ? null
                : () => context.read<OrderProvider>().loadOrders(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _body(context, provider),
      ),
    );
  }

  Widget _body(BuildContext context, OrderProvider provider) {
    if (provider.isLoading && provider.orders.isEmpty) {
      return const LoadingView(message: 'Memuat pesanan...');
    }
    if (provider.error != null) {
      return ErrorView(
        message: provider.error!,
        onRetry: () => context.read<OrderProvider>().loadOrders(),
      );
    }
    if (provider.orders.isEmpty) {
      return const EmptyView(
        icon: Icons.receipt_long_rounded,
        title: 'Belum ada pesanan',
        subtitle: 'Pesanan pelanggan akan muncul di sini.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<OrderProvider>().loadOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = provider.orders[index];
          final isPaid = order.paymentStatus == PaymentStatus.paid;
          final isCash = PaymentMethod.isCash(order.paymentMethod);

          return Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _StatusPill(
                        text: order.status,
                        color: order.isActive ? AppColors.orange : AppColors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(order.itemsSummary),
                  const SizedBox(height: 4),
                  Text(
                    'Pemesan: ${order.customerName} · NIM ${order.nim}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  Text(
                    'Ambil ${order.pickupTime} · ${formatRupiah(order.total)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.green.withValues(alpha: 0.09)
                          : AppColors.orange.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPaid ? Icons.check_circle_outline : Icons.schedule_rounded,
                          size: 17,
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
                  if (order.isActive && isCash && !isPaid) ...[
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () => _confirmCashPayment(context, order),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Konfirmasi Pembayaran Tunai'),
                    ),
                  ] else if (order.isActive && isPaid) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _confirmPickedUp(context, order),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Tandai Sudah Diambil'),
                    ),
                  ] else if (!order.isActive) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Pesanan telah selesai.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
