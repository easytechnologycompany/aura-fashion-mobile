import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../cubit/order_tracking_cubit.dart';
import '../widgets/order_status_timeline.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderTrackingCubit>()..fetchOrder(orderId),
      child: const _OrderTrackingView(),
    );
  }
}

class _OrderTrackingView extends StatelessWidget {
  const _OrderTrackingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
        builder: (context, state) {
          switch (state.status) {
            case OrderTrackingStatus.initial:
            case OrderTrackingStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case OrderTrackingStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.errorMessage ?? 'Failed to load order'),
                ),
              );
            case OrderTrackingStatus.success:
              final order = state.order!;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Order #${order.id.substring(0, order.id.length.clamp(0, 8))}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  OrderStatusTimeline(
                    status: order.status,
                    createdAt: order.createdAt,
                    updatedAt: order.updatedAt,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 32),
                  Text('Shipping address', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(
                    order.shippingAddress.isNotEmpty
                        ? order.shippingAddress
                        : 'No address on file',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Text('Items', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} × ${item.quantity}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 32),
                  _SummaryRow(label: 'Subtotal', value: order.subtotal),
                  _SummaryRow(label: 'Shipping', value: order.shippingFee),
                  const SizedBox(height: 4),
                  _SummaryRow(label: 'Total', value: order.total, emphasize: true),
                ],
              );
          }
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasize;

  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text('\$${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
