import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../pages/product_detail_screen.dart';
import 'product_card.dart';

/// Same-category products, excluding the one currently being viewed.
/// aura-fashion-backend has no dedicated "similar products" endpoint, so
/// this reuses the existing category-filtered product list and filters out
/// [currentProductId] client-side.
class RecommendedProductsSection extends StatefulWidget {
  final String categoryId;
  final String currentProductId;

  const RecommendedProductsSection({
    super.key,
    required this.categoryId,
    required this.currentProductId,
  });

  @override
  State<RecommendedProductsSection> createState() => _RecommendedProductsSectionState();
}

class _RecommendedProductsSectionState extends State<RecommendedProductsSection> {
  late final Future<List<ProductEntity>> _future = _load();

  Future<List<ProductEntity>> _load() async {
    final result = await di.sl<GetProductsUseCase>()(
      GetProductsParams(categoryId: widget.categoryId, limit: 10),
    );
    return result.fold(
      (_) => const [],
      (page) => page.products.where((p) => p.id != widget.currentProductId).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductEntity>>(
      future: _future,
      builder: (context, snapshot) {
        final products = snapshot.data ?? const [];
        if (snapshot.connectionState != ConnectionState.waiting && products.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You Might Also Like', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return SizedBox(
                          width: 160,
                          child: ProductCard(
                            product: product,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(productId: product.id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
