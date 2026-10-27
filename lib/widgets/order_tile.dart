import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';

/// Label status pesanan (menunggu atau selesai).
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final active = order.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.amberSoft : AppColors.greenSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.schedule_rounded : Icons.check_rounded,
            size: 14,
            color: active ? AppColors.amberText : const Color(0xFF166534),
          ),
          const SizedBox(width: 4),
          Text(
            order.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: active ? AppColors.amberText : const Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu kartu pesanan di halaman Pesanan.
class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
    required this.onShowCode,
    this.onEdit,
    this.onCancel,
    this.onPickedUp,
  });

  final OrderModel order;
  final VoidCallback onShowCode;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onPickedUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: appCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.code,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              OrderStatusChip(order: order),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.itemsSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Ambil ${order.pickupTime} · ${formatRupiah(order.total)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          if (order.note.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Catatan: ${order.note}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              OutlinedButton.icon(
                onPressed: onShowCode,
                icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                label: const Text('Kode'),
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Ubah'),
                ),
              if (onPickedUp != null)
                FilledButton.tonalIcon(
                  onPressed: onPickedUp,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Diambil'),
                ),
              if (onCancel != null)
                TextButton.icon(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(foregroundColor: AppColors.red),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Batalkan'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
