import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/order_entity.dart';
import '../cubit/order_list_cubit.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderListCubit>()..fetchOrders(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: BlocBuilder<OrderListCubit, OrderListState>(
        builder: (context, state) {
          switch (state.status) {
            case OrderListStatus.initial:
            case OrderListStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case OrderListStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.errorMessage ?? 'Failed to load orders'),
                ),
              );
            case OrderListStatus.success:
              if (state.orders.isEmpty) {
                return const Center(child: Text('No orders yet'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _OrderTile(order: state.orders[index]),
              );
          }
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderEntity order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Order #${order.id.substring(0, order.id.length.clamp(0, 8))}'),
        subtitle: Text(_statusLabel(order.status)),
        trailing: Text('\$${order.total.toStringAsFixed(2)}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id)),
        ),
      ),
    );
  }

  String _statusLabel(String status) =>
      status.isEmpty ? status : '${status[0].toUpperCase()}${status.substring(1)}';
}
