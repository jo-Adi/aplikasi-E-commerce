part of 'seller_cubit.dart';

enum SellerLoadStatus { initial, loading, loaded, error }

class SellerState {
  final SellerLoadStatus status;
  final StoreModel? store;
  final List<ProductModel> products;
  final List<OrderModel> orders;
  final String? errorMessage;
  final bool isProcessing;

  // Statistik dashboard
  int get totalProducts => products.length;
  int get activeProducts => products.where((p) => p.isActive).toList().length;
  int get totalOrders => orders.length;
  int get pendingOrders =>
      orders.where((o) => o.status == OrderStatus.pending).length;
  double get totalRevenue => orders
      .where((o) => o.status == OrderStatus.completed)
      .fold(0.0, (sum, o) => sum + o.sellerAmount);

  const SellerState({
    this.status = SellerLoadStatus.initial,
    this.store,
    this.products = const [],
    this.orders = const [],
    this.errorMessage,
    this.isProcessing = false,
  });

  SellerState copyWith({
    SellerLoadStatus? status,
    StoreModel? store,
    List<ProductModel>? products,
    List<OrderModel>? orders,
    String? errorMessage,
    bool? isProcessing,
  }) {
    return SellerState(
      status: status ?? this.status,
      store: store ?? this.store,
      products: products ?? this.products,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
