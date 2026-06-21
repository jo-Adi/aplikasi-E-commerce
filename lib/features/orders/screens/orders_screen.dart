import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/order_model.dart';
import '../cubit/order_cubit.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    'Semua', 'Menunggu', 'Diproses', 'Selesai', 'Dibatalkan'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<OrderCubit>().loadBuyerOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(
      List<OrderModel> orders, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return orders
            .where((o) => o.status == OrderStatus.pending)
            .toList();
      case 2:
        return orders
            .where((o) =>
                o.status == OrderStatus.processing ||
                o.status == OrderStatus.paid)
            .toList();
      case 3:
        return orders
            .where((o) => o.status == OrderStatus.completed)
            .toList();
      case 4:
        return orders
            .where((o) => o.status == OrderStatus.cancelled)
            .toList();
      default:
        return orders;
    }
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
          'Pesanan Saya',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827)),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF0D9E72),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF0D9E72),
          labelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state.status == OrderLoadStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF0D9E72)),
            );
          }

          if (state.status == OrderLoadStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('😕',
                      style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  const Text('Gagal memuat pesanan.',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: context
                        .read<OrderCubit>()
                        .loadBuyerOrders,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9E72),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: List.generate(_tabs.length, (tabIndex) {
              final filtered =
                  _filterOrders(state.orders, tabIndex);

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('📦',
                          style: TextStyle(fontSize: 44)),
                      SizedBox(height: 12),
                      Text('Belum ada pesanan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          )),
                      SizedBox(height: 6),
                      Text('Pesanan Anda akan muncul di sini',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final order = filtered[i];
                  return OrderCard(
                    order: order,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<OrderCubit>(),
                          child: OrderDetailScreen(order: order),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }
}
