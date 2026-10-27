import 'package:flutter/material.dart';

import '../models/menu_product.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import 'food_illustration.dart';

/// Kartu produk untuk grid menu dan daftar populer.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  final MenuProduct product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: appCard(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 84,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: artTint(product.art),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: FoodIllustration(art: product.art, size: 60),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatRupiah(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.orangeDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(11),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
