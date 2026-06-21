import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/order_model.dart';
import '../cubit/order_cubit.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

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

  String _formatDate(DateTime date) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827)),
        ),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          final cubit = context.read<OrderCubit>();
          final isProcessing = state.isProcessing;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status pesanan ───────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.orderId.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(order.createdAt),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Daftar produk ────────────────────────────────────
                _SectionCard(
                  title: 'Produk Dipesan',
                  child: Column(
                    children: order.items.map((item) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8),
                              child: item.imageUrl.isNotEmpty
                                  ? Image.network(
                                      item.imageUrl,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) =>
                                              _imgFallback(),
                                    )
                                  : _imgFallback(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                    ),
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
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
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Rincian pembayaran ───────────────────────────────
                _SectionCard(
                  title: 'Rincian Pembayaran',
                  child: Column(
                    children: [
                      _PriceRow(
                          label: 'Subtotal',
                          value: _formatPrice(
                              order.totalAmount - order.platformFee)),
                      const SizedBox(height: 6),
                      _PriceRow(
                          label: 'Biaya Platform',
                          value: _formatPrice(order.platformFee)),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Color(0xFFE5E7EB)),
                      ),
                      _PriceRow(
                        label: 'Total Pembayaran',
                        value: _formatPrice(order.totalAmount),
                        isBold: true,
                        valueColor: const Color(0xFF0D9E72),
                      ),
                      const SizedBox(height: 8),
                      _PriceRow(
                        label: 'Metode Pembayaran',
                        value: order.paymentMethod,
                      ),
                    ],
                  ),
                ),

                if (order.notes != null &&
                    order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Catatan',
                    child: Text(
                      order.notes!,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF374151)),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Action buttons ───────────────────────────────────
                if (order.status == OrderStatus.pending) ...[
                  // Konfirmasi pesanan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                              await cubit.confirmOrder(order.orderId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Pesanan dikonfirmasi!'),
                                  backgroundColor:
                                      Color(0xFF0D9E72),
                                  behavior:
                                      SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9E72),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5))
                          : const Text(
                              'Konfirmasi Pesanan',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Batalkan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isProcessing
                          ? null
                          : () => _showCancelDialog(
                              context, cubit),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(
                            color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Batalkan Pesanan',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],

                if (order.status == OrderStatus.processing)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.inventory_2_outlined,
                            color: Color(0xFF2563EB), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Penjual sedang memproses pesanan Anda.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (order.status == OrderStatus.completed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.verified_rounded,
                            color: Color(0xFF0D9E72), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pesanan telah selesai. Terima kasih!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF0D9E72),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pesanan?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827))),
        content: const Text(
            'Pesanan ini akan dibatalkan.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await cubit.cancelOrder(order.orderId);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Batalkan',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFE1F5EE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
            child: Text('🛍️', style: TextStyle(fontSize: 20))),
      );
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
