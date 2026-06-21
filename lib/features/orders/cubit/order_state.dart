part of 'order_cubit.dart';

enum OrderLoadStatus { initial, loading, loaded, error }

class OrderState {
  final OrderLoadStatus status;
  final List<OrderModel> orders;
  final OrderModel? selectedOrder;
  final String? errorMessage;
  final bool isProcessing;

  const OrderState({
    this.status = OrderLoadStatus.initial,
    this.orders = const [],
    this.selectedOrder,
    this.errorMessage,
    this.isProcessing = false,
  });

  OrderState copyWith({
    OrderLoadStatus? status,
    List<OrderModel>? orders,
    OrderModel? selectedOrder,
    String? errorMessage,
    bool? isProcessing,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
