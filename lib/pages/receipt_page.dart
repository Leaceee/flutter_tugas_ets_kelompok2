import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../widgets/order_code_view.dart';
import '../widgets/order_tile.dart';

/// Struk pesanan. QR pada metode QRIS di versi ETS ini tetap merupakan
/// QR identitas pesanan, bukan QR pembayaran dari penyedia pembayaran.
class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key, required this.order, this.justPaid = false});

  final OrderModel order;

  /// True hanya ketika checkout baru saja menyelesaikan simulasi pembayaran QRIS.
  final bool justPaid;

  bool get _isCash => PaymentMethod.isCash(order.paymentMethod);
  bool get _isPaid => order.paymentStatus == PaymentStatus.paid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !justPaid,
        title: Text(
          justPaid ? 'Konfirmasi pembayaran' : 'Struk pesanan',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            children: [
              if (justPaid) _successHeader(),
              Container(
                decoration: appCard(radius: 24),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: _isCash ? _cashOrderCode() : _qrisOrderCode(),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: _DashedLine(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          for (final item in order.items)
                            _row(
                              '${item.qty}x ${item.name}'
                              '${item.option.isEmpty ? '' : ' (${item.option})'}',
                              formatRupiah(item.subtotal),
                            ),
                          const Divider(height: 20),
                          _row('Total', formatRupiah(order.total), bold: true),
                          const SizedBox(height: 8),
                          _row('Ambil', '${order.pickupTime} · Kantin Teknik'),
                          _row('Pemesan', order.customerName),
                          _row('NIM', order.nim),
                          _row('Metode bayar', order.paymentMethod),
                          _row('Status pembayaran', order.paymentStatus),
                          _row('Status pesanan', order.status),
                          if (order.note.isNotEmpty) _row('Catatan', order.note),
                          _row('Dibuat', formatDateTime(order.createdAt)),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OrderStatusChip(order: order),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_isCash) _cashPaymentNotice(),
              if (!_isCash) _qrisDemoNotice(),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  justPaid ? 'Selesai' : 'Tutup',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qrisOrderCode() {
    return Column(
      children: [
        OrderCodeView(code: order.code, size: 132),
        const SizedBox(height: 10),
        Text(
          order.code,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Kode pesanan — tunjukkan kepada penjual',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }

  /// Untuk pembayaran tunai, tampilkan kode sebagai teks, tanpa QR/barcode.
  Widget _cashOrderCode() {
    return Column(
      children: [
        const Icon(
          Icons.receipt_long_rounded,
          size: 42,
          color: AppColors.orange,
        ),
        const SizedBox(height: 8),
        Text(
          order.code,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kode pesanan',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Tunjukkan kode ini kepada penjual dan bayar tunai saat mengambil pesanan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _cashPaymentNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.payments_outlined, color: AppColors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isPaid
                  ? 'Pembayaran tunai sudah dikonfirmasi.'
                  : 'Belum dibayar. Siapkan ${formatRupiah(order.total)} dan bayarkan kepada penjual saat mengambil pesanan.',
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrisDemoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Catatan demo ETS: QR yang tampil adalah QR identitas pesanan, bukan QR pembayaran QRIS. Pembayaran QRIS pada aplikasi ini masih disimulasikan dan belum terhubung ke penyedia pembayaran.',
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _successHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pembayaran QRIS (simulasi) berhasil',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            '${formatRupiah(order.total)} · QRIS',
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: bold ? style : style.copyWith(color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 10).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            count,
            (_) => const SizedBox(
              width: 5,
              height: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE5D8CC)),
              ),
            ),
          ),
        );
      },
    );
  }
}
