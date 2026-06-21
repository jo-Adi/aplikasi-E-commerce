import 'package:binmart/features/checkout/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/cart/cubit/cart_cubit.dart';
import '../../../features/cart/widgets/cart_item_card.dart';
import '../../../features/cart/widgets/cart_summary.dart';
import '../../../features/orders/cubit/order_cubit.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  static const routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().loadCart();
  }

  void _onCheckout(BuildContext context) {
    final cartItems = context.read<CartCubit>().state.items;
    if (cartItems.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider.value(value: context.read<OrderCubit>()),
          ],
          child: CheckoutScreen(cartItems: cartItems, product: null,),
        ),
      ),
    );
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
        title: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Keranjang Belanja',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827))),
              if (state.totalItems > 0)
                Text('${state.totalItems} item',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280))),
            ],
          ),
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox();
              return TextButton(
                onPressed: () => _showClearDialog(context),
                child: const Text('Hapus Semua',
                    style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 12)),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final cubit = context.read<CartCubit>();

          if (state.status == CartStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF0D9E72)),
            );
          }

          if (state.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE1F5EE),
                        shape: BoxShape.circle),
                    child: const Center(
                        child: Text('🛒',
                            style: TextStyle(fontSize: 44))),
                  ),
                  const SizedBox(height: 16),
                  const Text('Keranjang Masih Kosong',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  const Text('Yuk tambahkan produk!',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9E72),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12)),
                    ),
                    child: const Text('Mulai Belanja',
                        style: TextStyle(
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      20, 16, 20, 0),
                  itemCount: state.items.length,
                  itemBuilder: (context, i) {
                    final item = state.items[i];
                    return CartItemCard(
                      item: item,
                      onIncrease: () =>
                          cubit.increaseQty(item),
                      onDecrease: () =>
                          cubit.decreaseQty(item),
                      onRemove: () =>
                          cubit.removeItem(item.productId),
                    );
                  },
                ),
              ),

              // Summary → navigasi ke CheckoutScreen
              CartSummary(
                totalPrice: state.totalPrice,
                totalItems: state.totalItems,
                isCheckingOut: state.isCheckingOut,
                onCheckout: () => _onCheckout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua Item?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800)),
        content: const Text('Semua item akan dihapus.',
            style: TextStyle(
                fontSize: 13, color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartCubit>().clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
