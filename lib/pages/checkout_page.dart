import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../services/order_code_service.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import 'receipt_page.dart';

/// Halaman form pembayaran. Dipakai untuk dua mode:
/// - tambah: membuat pesanan baru dari isi keranjang
/// - ubah: mengedit pesanan yang belum diambil (CheckoutPage.edit)
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.items}) : order = null;

  const CheckoutPage.edit({super.key, required this.order})
      : items = const <CartItem>[];

  final List<CartItem> items;
  final OrderModel? order;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  late final TextEditingController _noteController;
  final TextEditingController _pinController = TextEditingController();

  late final List<String> _slots;
  String? _pickup;
  String _payment = PaymentMethod.qris;
  bool _submitting = false;

  bool get _isEdit => widget.order != null;

  late final double _total;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    _nameController = TextEditingController(text: order?.customerName ?? '');
    _nimController = TextEditingController(text: order?.nim ?? '');
    _noteController = TextEditingController(text: order?.note ?? '');
    if (order != null) {
      // Konversi data lama yang masih memakai label 'Saldo'.
      _payment = order.paymentMethod == 'Saldo'
          ? PaymentMethod.cashOnPickup
          : order.paymentMethod;
    }
    // Total dan waktu penyiapan dihitung oleh CartProvider, bukan di widget.
    final cart = context.read<CartProvider>();
    _total = order?.total ?? cart.totalPrice;
    final prep = order == null ? cart.earliestPrepMinutes : 5;
    _slots = OrderCodeService.pickupSlots(DateTime.now(), prep);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _noteController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final orders = context.read<OrderProvider>();
    final cart = context.read<CartProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _submitting = true);
    try {
      final existing = widget.order;
      if (existing != null) {
        final updated = existing.copyWith(
          customerName: _nameController.text.trim(),
          nim: _nimController.text.trim(),
          pickupTime: _pickup ?? existing.pickupTime,
          // Metode bayar dinonaktifkan pada mode edit, sehingga status
          // pembayaran pesanan lama tetap dipertahankan.
          paymentStatus: existing.paymentStatus,
          note: _noteController.text.trim(),
        );
        await orders.updateOrder(updated);
        if (!mounted) return;
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil diperbarui')),
        );
      } else {
        // QRIS belum terhubung ke payment gateway; alurnya hanya simulasi ETS.
        if (_payment == PaymentMethod.qris) {
          await Future<void>.delayed(const Duration(milliseconds: 900));
        }
        final saved = await orders.placeOrder(
          customerName: _nameController.text.trim(),
          nim: _nimController.text.trim(),
          pickupTime: _pickup!,
          paymentMethod: _payment,
          note: _noteController.text.trim(),
          items: widget.items,
        );
        cart.clear();
        if (!mounted) return;
        navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ReceiptPage(
              order: saved,
              justPaid: saved.paymentStatus == PaymentStatus.paid,
            ),
          ),
        );
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _payment == PaymentMethod.qris
                  ? 'Simulasi pembayaran QRIS berhasil.'
                  : 'Pesanan dibuat. Bayar tunai saat pengambilan.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan pesanan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Ubah pesanan' : 'Pembayaran',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              _orderSummary(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama pemesan',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: Validators.name,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
                validator: Validators.nim,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Waktu ambil',
                  prefixIcon: Icon(Icons.schedule_rounded),
                ),
                hint: Text(
                  _isEdit ? 'Tetap ${order!.pickupTime}' : 'Pilih waktu ambil',
                ),
                items: [
                  for (final slot in _slots)
                    DropdownMenuItem<String>(value: slot, child: Text(slot)),
                ],
                onChanged: (value) => setState(() => _pickup = value),
                validator: (value) => _isEdit ? null : Validators.pickup(value),
              ),
              const SizedBox(height: 16),
              const Text(
                'Metode bayar',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: PaymentMethod.qris,
                      label: Text('QRIS'),
                      icon: Icon(Icons.qr_code_2_rounded),
                    ),
                    ButtonSegment<String>(
                      value: PaymentMethod.cashOnPickup,
                      label: Text('Tunai'),
                      icon: Icon(Icons.payments_outlined),
                    ),
                  ],
                  selected: <String>{_payment},
                  showSelectedIcon: false,
                  // Metode pembayaran tidak dapat diubah saat mengedit pesanan.
                  onSelectionChanged: _isEdit
                      ? null
                      : (selection) => setState(() => _payment = selection.first),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _payment == PaymentMethod.qris
                          ? Icons.info_outline_rounded
                          : Icons.payments_outlined,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _payment == PaymentMethod.qris
                            ? 'Mode demo ETS: pembayaran QRIS disimulasikan. Aplikasi belum terhubung ke penyedia pembayaran.'
                            : 'Bayar tunai langsung kepada penjual saat mengambil pesanan. PIN pembayaran tidak diperlukan.',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Catatan untuk penjual',
                  helperText: 'Opsional, maksimal 50 karakter',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: Validators.note,
              ),
              if (!_isEdit && _payment == PaymentMethod.qris) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'PIN pembayaran QRIS (simulasi)',
                    helperText: 'Masukkan 4 digit angka',
                    prefixIcon: Icon(Icons.lock_rounded),
                  ),
                  validator: Validators.pin,
                ),
              ],
              if (!_isEdit) ...[
                const SizedBox(height: 8),
                FormField<bool>(
                  initialValue: false,
                  validator: (value) =>
                      value == true ? null : 'Centang untuk konfirmasi pesanan',
                  builder: (state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        value: state.value ?? false,
                        onChanged: (checked) => state.didChange(checked),
                        title: const Text('Saya memastikan pesanan sudah benar'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.orange,
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            state.errorText!,
                            style: const TextStyle(color: AppColors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _payment == PaymentMethod.cashOnPickup ? 'Total tagihan' : 'Total pembayaran',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                  Text(
                    formatRupiah(_total),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEdit
                            ? 'Simpan perubahan'
                            : _payment == PaymentMethod.cashOnPickup
                                ? 'Buat Pesanan · ${formatRupiah(_total)}'
                                : 'Simulasikan QRIS · ${formatRupiah(_total)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderSummary() {
    final order = widget.order;
    final lines = <String>[
      if (order != null)
        for (final item in order.items) '${item.qty}x ${item.name}'
      else
        for (final item in widget.items) '${item.qty}x ${item.product.name}',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: appCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order != null ? 'Pesanan ${order.code}' : 'Ringkasan pesanan',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          for (final line in lines)
            Text(line, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ),
    );
  }
}