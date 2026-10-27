import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../utils/app_theme.dart';

/// Kartu besar di beranda: menampilkan pesanan aktif beserta kodenya.
class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({
    super.key,
    required this.order,
    required this.onShowCode,
    required this.onOrder,
  });

  final OrderModel? order;
  final VoidCallback onShowCode;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final current = order;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.orange, Color(0xFFFF9A4D)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -34,
              top: -34,
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: Color(0x26FFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -24,
              bottom: -46,
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0x1AFFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: current == null ? _empty() : _active(current),
            ),
          ],
        ),
      ),
    );
  }

  Widget _active(OrderModel o) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pesanan aktif',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x3DFFFFFF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                o.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          o.code,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        Text(
          'Ambil ${o.pickupTime} · Kantin Teknik',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 14),
        _WhiteButton(
          icon: Icons.qr_code_2_rounded,
          label: 'Tunjukkan kode',
          onTap: onShowCode,
        ),
      ],
    );
  }

  Widget _empty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Belum ada pesanan aktif',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pilih menu, bayar di aplikasi, lalu ambil pesanan dengan kode order.',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 14),
        _WhiteButton(
          icon: Icons.restaurant_menu_rounded,
          label: 'Lihat menu',
          onTap: onOrder,
        ),
      ],
    );
  }
}

class _WhiteButton extends StatelessWidget {
  const _WhiteButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.orangeDark, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.orangeDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
