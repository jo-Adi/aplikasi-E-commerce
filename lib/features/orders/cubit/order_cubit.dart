import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/order_model.dart';
import '../../../core/models/cart_model.dart';
import '../../../core/repositories/order_repository.dart';
import '../../../core/repositories/user_repository.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final _orderRepo = OrderRepository();
  final _userRepo = UserRepository();
  StreamSubscription<List<OrderModel>>? _ordersSub;

  OrderCubit() : super(const OrderState());

  @override
  Future<void> close() {
    _ordersSub?.cancel();
    return super.close();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Load riwayat pesanan pembeli — realtime stream
  void loadBuyerOrders() {
    final uid = _uid;
    if (uid == null) return;

    emit(state.copyWith(status: OrderLoadStatus.loading));
    _ordersSub?.cancel();
    _ordersSub = _orderRepo.getBuyerOrders(uid).listen(
      (orders) => emit(state.copyWith(
        status: OrderLoadStatus.loaded,
        orders: orders,
      )),
      onError: (_) => emit(state.copyWith(
        status: OrderLoadStatus.error,
        errorMessage: 'Gagal memuat pesanan.',
      )),
    );
  }

  /// Buat pesanan baru dari isi keranjang
  Future<String?> createOrderFromCart({
    required List<CartItem> cartItems,
    required String paymentMethod,
    String? notes,
  }) async {
    final uid = _uid;
    if (uid == null || cartItems.isEmpty) return null;

    emit(state.copyWith(isProcessing: true));

    try {
      // Ambil data user
      final user = await _userRepo.getUser(uid);
      final buyerName = user?.fullName ?? 'Pembeli';

      // Hitung total
      final totalAmount =
          cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
      const platformFee = 2000.0;
      final sellerAmount = totalAmount - platformFee;

      // Ambil storeId & sellerId dari item pertama
      // (asumsi 1 checkout = 1 toko, multi-toko dihandle nanti)
      final storeId = cartItems.first.storeId;

      // Ambil sellerId dari Firestore stores/{storeId}
      final storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .get();
      final sellerId =
          storeDoc.exists ? (storeDoc.data()?['ownerId'] ?? '') : '';

      // Buat list OrderItem dari CartItem
      final orderItems = cartItems.map((item) {
        return OrderItem(
          productId: item.productId,
          productName: item.productName,
          imageUrl: item.imageUrl,
          price: item.price,
          quantity: item.quantity,
          subtotal: item.subtotal,
        );
      }).toList();

      // Buat OrderModel
      final order = OrderModel(
        orderId: '',
        buyerId: uid,
        buyerName: buyerName,
        storeId: storeId,
        sellerId: sellerId,
        items: orderItems,
        totalAmount: totalAmount,
        platformFee: platformFee,
        sellerAmount: sellerAmount,
        status: OrderStatus.pending,
        paymentMethod: paymentMethod,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simpan ke Firestore
      final orderId = await _orderRepo.createOrder(order);
      emit(state.copyWith(isProcessing: false));
      return orderId;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: 'Gagal membuat pesanan.',
      ));
      return null;
    }
  }

  /// Pembeli konfirmasi pesanan diterima
  Future<void> confirmOrder(String orderId) async {
    emit(state.copyWith(isProcessing: true));
    await _orderRepo.updateOrderStatus(orderId, OrderStatus.completed);
    emit(state.copyWith(isProcessing: false));
  }

  /// Batalkan pesanan — hanya bisa saat status pending
  Future<void> cancelOrder(String orderId) async {
    emit(state.copyWith(isProcessing: true));
    await _orderRepo.updateOrderStatus(orderId, OrderStatus.cancelled);
    emit(state.copyWith(isProcessing: false));
  }

  void selectOrder(OrderModel order) =>
      emit(state.copyWith(selectedOrder: order));
}
