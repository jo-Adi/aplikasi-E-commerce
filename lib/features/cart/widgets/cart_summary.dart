import 'package:flutter/material.dart';

class CartSummary extends StatelessWidget {
  final double totalPrice;
  final int totalItems;
  final bool isCheckingOut;
  final VoidCallback onCheckout;

  const CartSummary({
    super.key,
    required this.totalPrice,
    required this.totalItems,
    required this.isCheckingOut,
    required this.onCheckout,
  });

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

  @override
  Widget build(BuildContext context) {
    const platformFee = 2000.0;
    final total = totalPrice + platformFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rincian biaya
          _SummaryRow(
            label: 'Subtotal ($totalItems item)',
            value: _formatPrice(totalPrice),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Biaya Platform',
            value: _formatPrice(platformFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE5E7EB)),
          ),
          _SummaryRow(
            label: 'Total Pembayaran',
            value: _formatPrice(total),
            isBold: true,
            valueColor: const Color(0xFF0D9E72),
          ),
          const SizedBox(height: 14),

          // Tombol checkout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isCheckingOut ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9E72),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF0D9E72).withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isCheckingOut
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Checkout • ${_formatPrice(total)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
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
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold
                ? const Color(0xFF111827)
                : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
