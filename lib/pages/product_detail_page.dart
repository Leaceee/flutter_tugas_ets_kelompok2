import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/menu_product.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../widgets/food_illustration.dart';

/// Membuka halaman detail dan mengirim objek produk (passing data).
void openProductDetail(BuildContext context, MenuProduct product) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProductDetailPage(product: product),
    ),
  );
}

/// Menambah produk ke keranjang dengan pilihan bawaan (pilihan pertama).
void quickAddToCart(BuildContext context, MenuProduct product) {
  context.read<CartProvider>().add(product, product.options.first);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${product.name} ditambahkan ke keranjang'),
      duration: const Duration(seconds: 1),
    ),
  );
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final MenuProduct product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late String _option;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _option = widget.product.options.first;
  }

  void _addToCart() {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    context.read<CartProvider>().add(widget.product, _option, qty: _qty);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 230,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: artTint(p.art),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: FoodIllustration(art: p.art, size: 150),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Kembali',
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        label: p.category,
                        background: AppColors.orangeSoft,
                        color: AppColors.orangeDark,
                      ),
                      _InfoChip(
                        label: p.prepLabel,
                        background: const Color(0xFFF3F4F6),
                        color: const Color(0xFF4B5563),
                        icon: Icons.schedule_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatRupiah(p.price),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orangeDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p.description,
                    style: const TextStyle(color: AppColors.muted, height: 1.45),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    p.optionLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in p.options)
                        ChoiceChip(
                          label: Text(option),
                          selected: _option == option,
                          showCheckmark: false,
                          selectedColor: AppColors.peach,
                          onSelected: (_) => setState(() => _option = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Jumlah',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Kurangi',
                        onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$_qty',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Tambah',
                        onPressed: () => setState(() => _qty++),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _addToCart,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Tambah · ${formatRupiah(p.price * _qty)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.background,
    required this.color,
    this.icon,
  });

  final String label;
  final Color background;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
