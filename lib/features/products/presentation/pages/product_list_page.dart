import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_entity.dart';
import '../cubit/product_cubit.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aura Fashion')),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductStatus.initial:
            case ProductStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ProductStatus.failure:
              return Center(child: Text(state.errorMessage ?? 'Something went wrong'));
            case ProductStatus.success:
              if (state.products.isEmpty) {
                return const Center(child: Text('No products yet'));
              }
              return RefreshIndicator(
                onRefresh: () => context.read<ProductCubit>().fetchProducts(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) =>
                      _ProductCard(product: state.products[index]),
                ),
              );
          }
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: product.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorWidget: (_, _, _) => const Icon(Icons.broken_image),
                  )
                : const Icon(Icons.image_not_supported, size: 48),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${product.effectivePrice.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (product.isOnSale) ...[
                      const SizedBox(width: 6),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
