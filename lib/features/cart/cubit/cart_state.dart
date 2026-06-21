part of 'cart_cubit.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState {
  final CartStatus status;
  final List<CartItem> items;
  final String? errorMessage;
  final bool isCheckingOut;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.isCheckingOut = false,
  });

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    String? errorMessage,
    bool? isCheckingOut,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
    );
  }

  /// Total harga semua item
  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  /// Total jumlah item (untuk badge keranjang)
  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
}
