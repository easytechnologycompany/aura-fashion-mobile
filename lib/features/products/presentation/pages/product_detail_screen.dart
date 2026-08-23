import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/product_detail_cubit.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProductDetailCubit>()..fetchProduct(productId),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView();

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductDetailStatus.initial:
            case ProductDetailStatus.loading:
              return const _LoadingBody();
            case ProductDetailStatus.failure:
              return _ErrorBody(message: state.errorMessage ?? 'Something went wrong');
            case ProductDetailStatus.success:
              return _DetailBody(product: state.product!);
          }
        },
      ),
      bottomNavigationBar: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          if (state.status != ProductDetailStatus.success || state.product == null) {
            return const SizedBox.shrink();
          }
          return _AddToCartBar(
            product: state.product!,
            quantity: _quantity,
            onQuantityChanged: (q) => setState(() => _quantity = q),
          );
        },
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  final ProductEntity product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _AddToCartBar({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;

    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (inStock)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
                  ),
                  Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: quantity < product.stock
                        ? () => onQuantityChanged(quantity + 1)
                        : null,
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: inStock
                  ? () {
                      context.read<CartCubit>().addItem(
                            CartItemEntity(
                              productId: product.id,
                              name: product.name,
                              imageUrl: product.imageUrl,
                              unitPrice: product.effectivePrice,
                              quantity: quantity,
                              availableStock: product.stock,
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${product.name} to cart')),
                      );
                    }
                  : null,
              child: Text(inStock ? 'Add to Cart' : 'Out of Stock'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;

  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final ProductEntity product;

  const _DetailBody({required this.product});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 360,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: product.imageUrl.isNotEmpty
                ? CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover)
                : const ColoredBox(
                    color: Color(0x11000000),
                    child: Icon(Icons.image_not_supported_outlined, size: 64),
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${product.effectivePrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    if (product.isOnSale) ...[
                      const SizedBox(width: 10),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.inStock
                      ? '${product.stock} in stock'
                      : 'Out of stock',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: product.inStock
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 20),
                Text('Description', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  product.description.isNotEmpty
                      ? product.description
                      : 'No description available.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
