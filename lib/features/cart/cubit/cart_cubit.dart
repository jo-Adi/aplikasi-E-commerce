import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/cart_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/repositories/cart_repository.dart';
import '../../orders/cubit/order_cubit.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepo = CartRepository();
  final OrderCubit orderCubit;

  StreamSubscription<List<CartItem>>? _cartSub;

  CartCubit({
    required this.orderCubit,
  }) : super(const CartState());

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<void> close() {
    _cartSub?.cancel();
    return super.close();
  }

  void loadCart() {
    final uid = _uid;

    if (uid == null) return;

    emit(
      state.copyWith(
        status: CartStatus.loading,
      ),
    );

    _cartSub?.cancel();

    _cartSub = _cartRepo.getCartItems(uid).listen(
      (items) {
        emit(
          state.copyWith(
            status: CartStatus.loaded,
            items: items,
          ),
        );
      },
      onError: (_) {
        emit(
          state.copyWith(
            status: CartStatus.error,
            errorMessage: 'Gagal memuat keranjang.',
          ),
        );
      },
    );
  }

  Future<void> addToCart(
    ProductModel product, {
    int quantity = 1,
  }) async {
    final uid = _uid;

    if (uid == null) return;

    final item = CartItem(
      productId: product.id,
      productName: product.name,
      storeId: product.storeId,
      storeName: product.storeName, 
      price: product.price,
      quantity: quantity,
      imageUrl: product.primaryImage,
      maxStock: product.stock,
    );

    await _cartRepo.addToCart(uid, item);
  }

  Future<void> increaseQty(CartItem item) async {
    final uid = _uid;

    if (uid == null) return;

    if (item.quantity >= item.maxStock) return;

    await _cartRepo.updateQuantity(
      uid,
      item.productId,
      item.quantity + 1,
    );
  }

  Future<void> decreaseQty(CartItem item) async {
    final uid = _uid;

    if (uid == null) return;

    await _cartRepo.updateQuantity(
      uid,
      item.productId,
      item.quantity - 1,
    );
  }

  Future<void> removeItem(String productId) async {
    final uid = _uid;

    if (uid == null) return;

    await _cartRepo.removeFromCart(
      uid,
      productId,
    );
  }

  Future<void> clearCart() async {
    final uid = _uid;

    if (uid == null) return;

    await _cartRepo.clearCart(uid);
  }

  /// Checkout dan membuat order baru
  Future<String?> checkout({
    String paymentMethod = 'Transfer Bank',
  }) async {
    if (state.isEmpty) return null;

    emit(
      state.copyWith(
        isCheckingOut: true,
      ),
    );

    final orderId = await orderCubit.createOrderFromCart(
      cartItems: state.items,
      paymentMethod: paymentMethod,
    );

    if (orderId != null) {
      await clearCart();
    }

    emit(
      state.copyWith(
        isCheckingOut: false,
      ),
    );

    return orderId;
  }
}