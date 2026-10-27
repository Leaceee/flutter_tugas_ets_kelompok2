import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/format.dart';

/// Bilah ringkasan keranjang di bagian bawah halaman menu.
class CartBar extends StatelessWidget {
  const CartBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  final int itemCount;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Material(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$itemCount item',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        formatRupiah(total),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Keranjang',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
