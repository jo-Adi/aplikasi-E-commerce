import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/cart_model.dart';
import '../../../features/cart/cubit/cart_cubit.dart';
import '../../../features/orders/cubit/order_cubit.dart';
import '../../../features/orders/screens/orders_screen.dart';
import '../widgets/payment_method_tile.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem>? cartItems; // <--- GANTI MENJADI 'CartItem'
  // ...
  // Parameter beli langsung
  final dynamic directProduct;
  final int? directQuantity;

  // 2. Daftarkan semuanya di constructor
  const CheckoutScreen({
    super.key,
    this.cartItems,
    this.directProduct,
    this.directQuantity, Object? product,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'COD';
  final _notesCtrl = TextEditingController();
  bool _isProcessing = false;

  static const _platformFee = 2000.0;

  // Metode pembayaran dummy
  static const _paymentMethods = [
    _PaymentMethod(
      id: 'COD',
      name: 'Bayar di Tempat (COD)',
      subtitle: 'Bayar saat barang tiba',
      icon: Icons.money_rounded,
      color: Color(0xFF0D9E72),
    ),
    _PaymentMethod(
      id: 'TRANSFER_BANK',
      name: 'Transfer Bank',
      subtitle: 'BCA · BRI · Mandiri · BNI',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF2563EB),
    ),
    _PaymentMethod(
      id: 'EWALLET',
      name: 'E-Wallet',
      subtitle: 'OVO · Dana · ShopeePay · GoPay',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  List<CartItem> get _checkoutItems {
    if (widget.directProduct != null) {
      return [
        CartItem(
          productId: widget.directProduct!.productId,
          productName: widget.directProduct!.name,
          storeId: widget.directProduct!.storeId,
          storeName: widget.directProduct!.storeName,
          price: widget.directProduct!.price,
          quantity: widget.directQuantity ?? 1,
          imageUrl: widget.directProduct!.primaryImage,
          maxStock: widget.directProduct!.stock,
        ),
      ];
    }
    return widget.cartItems ??
        context.read<CartCubit>().state.items;
  }

  double get _subtotal =>
      _checkoutItems.fold(0, (sum, i) => sum + i.subtotal);

  double get _total => _subtotal + _platformFee;

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(str[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  Future<void> _onPlaceOrder(BuildContext context) async {
    setState(() => _isProcessing = true);

    final orderCubit = context.read<OrderCubit>();
    final cartCubit = context.read<CartCubit>();

    final orderId = await orderCubit.createOrderFromCart(
      cartItems: _checkoutItems,
      paymentMethod: _selectedPayment,
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
    );

    if (!mounted) return;

    // Kosongkan keranjang jika bukan "Beli Sekarang"
    if (widget.directProduct == null && orderId != null) {
      await cartCubit.clearCart();
      if (!context.mounted) return;
    }

    setState(() => _isProcessing = false);

    if (orderId != null) {
      _showSuccessDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat pesanan. Coba lagi.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE1F5EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF0D9E72), size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pesanan Berhasil! 🎉',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _selectedPayment == 'COD'
                  ? 'Pesanan dikonfirmasi.\nSiapkan pembayaran saat barang tiba.'
                  : _selectedPayment == 'TRANSFER_BANK'
                      ? 'Segera lakukan transfer bank.\nPesanan akan diproses setelah pembayaran dikonfirmasi.'
                      : 'Segera selesaikan pembayaran\nmelalui aplikasi e-wallet Anda.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Kembali ke root dan buka orders
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  OrdersScreen.routeName,
                  (route) => route.isFirst,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9E72),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Lihat Pesanan',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _checkoutItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 18, color: Color(0xFF374151)),
          ),
        ),
        title: const Text('Konfirmasi Pesanan',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Daftar produk ──────────────────────────────────────
            _SectionCard(
              title: 'Produk Dipesan',
              child: Column(
                children: items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.imageUrl.isNotEmpty
                            ? Image.network(item.imageUrl,
                                width: 52, height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _imgFallback())
                            : _imgFallback(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(item.productName,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text(
                              '${_formatPrice(item.price)} × ${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatPrice(item.subtotal),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827)),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // ── Metode pembayaran ──────────────────────────────────
            _SectionCard(
              title: 'Metode Pembayaran',
              child: Column(
                children: _paymentMethods.map((method) {
                  return PaymentMethodTile(
                    method: method,
                    isSelected: _selectedPayment == method.id,
                    onTap: () =>
                        setState(() => _selectedPayment = method.id),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // ── Info pembayaran sesuai metode ──────────────────────
            if (_selectedPayment == 'TRANSFER_BANK')
              _InfoBox(
                icon: Icons.info_outline_rounded,
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFDBEAFE),
                text:
                    'Transfer ke rekening BinMart:\nBCA 1234567890 a.n. PT BinMart Indonesia\n\nSertakan nomor pesanan sebagai berita transfer.',
              ),

            if (_selectedPayment == 'EWALLET')
              _InfoBox(
                icon: Icons.info_outline_rounded,
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFEDE9FE),
                text:
                    'Setelah menekan "Pesan Sekarang", Anda akan mendapatkan kode pembayaran e-wallet via notifikasi.',
              ),

            if (_selectedPayment == 'COD')
              _InfoBox(
                icon: Icons.home_outlined,
                color: const Color(0xFF0D9E72),
                bgColor: const Color(0xFFE1F5EE),
                text:
                    'Siapkan uang tunai saat kurir tiba.\nJumlah yang dibayar sesuai total pesanan.',
              ),

            const SizedBox(height: 14),

            // ── Catatan untuk penjual ──────────────────────────────
            _SectionCard(
              title: 'Catatan (opsional)',
              child: TextField(
                controller: _notesCtrl,
                maxLines: 2,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF111827)),
                decoration: InputDecoration(
                  hintText: 'Contoh: Tolong dikemas rapih...',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF0D9E72), width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Rincian biaya ──────────────────────────────────────
            _SectionCard(
              title: 'Rincian Pembayaran',
              child: Column(
                children: [
                  _PriceRow(
                      label:
                          'Subtotal (${items.length} produk)',
                      value: _formatPrice(_subtotal)),
                  const SizedBox(height: 6),
                  _PriceRow(
                      label: 'Biaya Platform',
                      value: _formatPrice(_platformFee)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Color(0xFFE5E7EB)),
                  ),
                  _PriceRow(
                    label: 'Total Pembayaran',
                    value: _formatPrice(_total),
                    isBold: true,
                    valueColor: const Color(0xFF0D9E72),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Tombol pesan ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _onPlaceOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9E72),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF0D9E72).withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined,
                              size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Pesan Sekarang · ${_formatPrice(_total)}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFE1F5EE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
            child: Text('🛍️', style: TextStyle(fontSize: 20))),
      );
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _PaymentMethod {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String text;

  const _InfoBox({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 12, color: color, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isBold ? 14 : 13,
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold
                    ? const Color(0xFF111827)
                    : const Color(0xFF6B7280))),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 15 : 13,
                fontWeight:
                    isBold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor ?? const Color(0xFF111827))),
      ],
    );
  }
}
