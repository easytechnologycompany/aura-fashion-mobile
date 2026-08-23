import 'package:flutter/material.dart';

/// The happy-path progression an order moves through. `cancelled` and
/// `refunded` are terminal states outside this path, rendered as a
/// distinct final step instead of being slotted into it.
const _happyPathSteps = ['pending', 'paid', 'shipped', 'delivered'];

const _stepLabels = {
  'pending': 'Order Placed',
  'paid': 'Payment Confirmed',
  'shipped': 'Shipped',
  'delivered': 'Delivered',
};

const _stepIcons = {
  'pending': Icons.receipt_long_outlined,
  'paid': Icons.payments_outlined,
  'shipped': Icons.local_shipping_outlined,
  'delivered': Icons.home_outlined,
};

/// Renders the order status as a vertical timeline.
///
/// aura-fashion-backend only stores `status` plus `created_at`/`updated_at`
/// (no per-transition timestamps), so completed steps are inferred from the
/// current status's rank in the happy path rather than individual event
/// times — only the first step shows [createdAt] and the current step shows
/// [updatedAt] as "last updated".
class OrderStatusTimeline extends StatelessWidget {
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderStatusTimeline({
    super.key,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get _isTerminalException => status == 'cancelled' || status == 'refunded';

  @override
  Widget build(BuildContext context) {
    final currentIndex = _happyPathSteps.indexOf(status);
    final activeIndex = _isTerminalException ? _happyPathSteps.length : currentIndex;

    final steps = [..._happyPathSteps, if (_isTerminalException) status];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineTile(
            label: _isTerminalException && i == steps.length - 1
                ? (status == 'cancelled' ? 'Cancelled' : 'Refunded')
                : _stepLabels[steps[i]] ?? steps[i],
            icon: _isTerminalException && i == steps.length - 1
                ? Icons.cancel_outlined
                : _stepIcons[steps[i]] ?? Icons.circle_outlined,
            isFirst: i == 0,
            isLast: i == steps.length - 1,
            state: _isTerminalException && i == steps.length - 1
                ? _TileState.exception
                : i < activeIndex
                    ? _TileState.done
                    : i == activeIndex
                        ? _TileState.current
                        : _TileState.upcoming,
            timestamp: i == 0
                ? createdAt
                : (i == activeIndex || (_isTerminalException && i == steps.length - 1))
                    ? updatedAt
                    : null,
          ),
      ],
    );
  }
}

enum _TileState { done, current, upcoming, exception }

class _TimelineTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isFirst;
  final bool isLast;
  final _TileState state;
  final DateTime? timestamp;

  const _TimelineTile({
    required this.label,
    required this.icon,
    required this.isFirst,
    required this.isLast,
    required this.state,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color dotColor = switch (state) {
      _TileState.done => scheme.primary,
      _TileState.current => scheme.primary,
      _TileState.upcoming => scheme.outlineVariant,
      _TileState.exception => scheme.error,
    };
    final bool filled = state == _TileState.done ||
        state == _TileState.current ||
        state == _TileState.exception;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? dotColor : Colors.transparent,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: filled ? scheme.onPrimary : dotColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: state == _TileState.done ? scheme.primary : scheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 28, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: state == _TileState.upcoming
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: state == _TileState.upcoming
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(timestamp!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${_twoDigits(local.month)}-${_twoDigits(local.day)} '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
