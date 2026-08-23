import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../addresses/domain/entities/address_entity.dart';
import '../../../addresses/presentation/cubit/address_cubit.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../orders/presentation/cubit/checkout_cubit.dart';
import '../../../orders/presentation/pages/order_tracking_screen.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // CartCubit is an app-wide singleton kept in sync by every add/update/
    // remove call, so its in-memory state is already current by the time
    // this screen opens (HomeScreen loads it once at startup). Only hit
    // disk here if that hasn't happened yet — reloading unconditionally
    // would flash a loading spinner over already-fresh data on every open,
    // which is what made the cart look like it wasn't updating instantly.
    if (context.read<CartCubit>().state.status == CartStatus.initial) {
      context.read<CartCubit>().loadCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading || state.status == CartStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const _EmptyCartView();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => CartItemTile(item: state.items[index]),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const SizedBox.shrink();
          return SafeArea(
            minimum: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '\$${state.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: FilledButton(
                    onPressed: () => _openCheckout(context),
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openCheckout(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider(
        create: (_) => di.sl<CheckoutCubit>(),
        child: _CheckoutSheet(cartCubit: cartCubit),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Looks like you haven't added anything yet. "
              'Start browsing to find something you love.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }
              },
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Browse Products'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  final CartCubit cartCubit;

  const _CheckoutSheet({required this.cartCubit});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

/// Demo promo codes mapped to a discount fraction of the subtotal.
///
/// aura-fashion-backend has no coupon/discount concept, so this only
/// affects the total previewed in this sheet — the order is still placed,
/// and charged, at full price. Wiring a real discount through checkout
/// would need a backend field to carry the code/amount onto the order.
const _promoCodes = {'WELCOME10': 0.10, 'SAVE20': 0.20};

/// Dummy options — aura-fashion-backend just stores whatever string is sent
/// as `payment_method`; there's no real payment processor integration.
const _paymentMethods = ['Cash on Delivery', 'Credit Card', 'PayPal'];

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _promoController = TextEditingController();
  String? _appliedCode;
  String? _promoError;
  String _paymentMethod = _paymentMethods.first;
  bool _showAddressError = false;

  double get _discountFraction =>
      _appliedCode == null ? 0 : (_promoCodes[_appliedCode] ?? 0);

  void _applyPromoCode() {
    final code = _promoController.text.trim().toUpperCase();
    setState(() {
      if (code.isEmpty) {
        _promoError = null;
        _appliedCode = null;
      } else if (_promoCodes.containsKey(code)) {
        _appliedCode = code;
        _promoError = null;
      } else {
        _appliedCode = null;
        _promoError = 'Invalid promo code';
      }
    });
  }

  void _removePromoCode() {
    setState(() {
      _appliedCode = null;
      _promoError = null;
      _promoController.clear();
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _addNewAddress(BuildContext context) async {
    final addressCubit = context.read<AddressCubit>();
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add address'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label (e.g. Home)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Label is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Full address'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Address is required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      await addressCubit.addAddress(
        AddressEntity(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          label: labelController.text.trim(),
          fullAddress: addressController.text.trim(),
        ),
      );
      if (context.mounted) setState(() => _showAddressError = false);
    }
    labelController.dispose();
    addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.status == CheckoutStatus.success) {
            widget.cartCubit.clear();
            final orderId = state.order!.id;
            // Capture the State objects (not the sheet's BuildContext) since
            // the sheet is popped below and its context becomes invalid
            // before the user gets a chance to tap the snackbar's action.
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            navigator.pop();
            messenger.showSnackBar(
              SnackBar(
                content: Text('Order placed! Total \$${state.order!.total.toStringAsFixed(2)}'),
                action: SnackBarAction(
                  label: 'Track',
                  onPressed: () => navigator.push(
                    MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: orderId)),
                  ),
                ),
              ),
            );
          } else if (state.status == CheckoutStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed to place order')),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == CheckoutStatus.submitting;
          final subtotal = widget.cartCubit.state.total;
          final discount = subtotal * _discountFraction;
          final total = subtotal - discount;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Shipping address', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                BlocBuilder<AddressCubit, AddressState>(
                  builder: (context, addressState) {
                    if (addressState.addresses.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No saved addresses yet',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed:
                                  isSubmitting ? null : () => _addNewAddress(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add address'),
                            ),
                          ),
                        ],
                      );
                    }
                    return RadioGroup<String>(
                      groupValue: addressState.selectedId,
                      onChanged: (value) {
                        if (isSubmitting || value == null) return;
                        context.read<AddressCubit>().selectAddress(value);
                        setState(() => _showAddressError = false);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final address in addressState.addresses)
                            RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              title: Text(address.label),
                              subtitle: Text(address.fullAddress),
                              value: address.id,
                            ),
                          TextButton.icon(
                            onPressed:
                                isSubmitting ? null : () => _addNewAddress(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add new address'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (_showAddressError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Select or add a shipping address',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text('Payment method', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final method in _paymentMethods)
                      ChoiceChip(
                        label: Text(method),
                        selected: _paymentMethod == method,
                        onSelected: isSubmitting
                            ? null
                            : (_) => setState(() => _paymentMethod = method),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Promo code', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_appliedCode != null)
                  Row(
                    children: [
                      Chip(
                        avatar: const Icon(Icons.local_offer_outlined, size: 18),
                        label: Text('$_appliedCode applied'),
                        onDeleted: isSubmitting ? null : _removePromoCode,
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _promoController,
                          enabled: !isSubmitting,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Enter code',
                            border: const OutlineInputBorder(),
                            errorText: _promoError,
                          ),
                          onFieldSubmitted: (_) => _applyPromoCode(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: isSubmitting ? null : _applyPromoCode,
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium),
                    const Spacer(),
                    Text('\$${subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Discount',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green.shade700,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '-\$${discount.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          final selected = context.read<AddressCubit>().selected;
                          if (selected == null) {
                            setState(() => _showAddressError = true);
                            return;
                          }
                          context.read<CheckoutCubit>().placeOrder(
                                cartItems: widget.cartCubit.state.items,
                                shippingAddress: selected.fullAddress,
                                paymentMethod: _paymentMethod,
                              );
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Place Order'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
