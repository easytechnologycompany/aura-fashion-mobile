import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_entity.dart';
import '../cubit/product_cubit.dart';
import '../pages/product_detail_screen.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final Future<void> Function() onRefresh;

  /// Optional client-side filter applied on top of the fetched list, e.g.
  /// restricting the grid to on-sale items without a separate API call.
  final bool Function(ProductEntity product)? filter;

  const ProductGrid({super.key, required this.onRefresh, this.filter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        switch (state.status) {
          case ProductStatus.initial:
          case ProductStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ProductStatus.failure:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Something went wrong',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: onRefresh, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          case ProductStatus.success:
            final products = filter == null
                ? state.products
                : state.products.where(filter!).toList();
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    const Text('No products in this category yet'),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productId: product.id),
                      ),
                    ),
                  );
                },
              ),
            );
        }
      },
    );
  }
}
