import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/pages/cart_screen.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../../wishlist/presentation/pages/wishlist_screen.dart';
import '../../domain/home_tab.dart';
import '../widgets/home_tab_bar.dart';
import '../widgets/promo_banner.dart';

/// The post-login landing screen: a SHEIN-style promo banner and top-level
/// browse tabs (New In / Women / Shoes / Accessories / Sale) over a product
/// grid, backed by /categories and /products on aura-fashion-backend.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab _selectedTab = HomeTab.newIn;

  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().fetchCategories();
    context.read<ProductCubit>().fetchProducts();
    context.read<CartCubit>().loadCart();
    context.read<WishlistCubit>().loadWishlist();
  }

  /// "Shoes"/"Accessories" resolve to a real backend category by name;
  /// "New In"/"Women" browse everything; "Sale" also fetches everything and
  /// is narrowed client-side in [_saleFilter] instead of a category filter.
  String? _categoryIdFor(HomeTab tab, List<CategoryEntity> categories) {
    switch (tab) {
      case HomeTab.shoes:
        return categories
            .cast<CategoryEntity?>()
            .firstWhere((c) => c?.name == 'Shoes', orElse: () => null)
            ?.id;
      case HomeTab.accessories:
        return categories
            .cast<CategoryEntity?>()
            .firstWhere((c) => c?.name == 'Accessories', orElse: () => null)
            ?.id;
      case HomeTab.newIn:
      case HomeTab.women:
      case HomeTab.sale:
        return null;
    }
  }

  void _onTabSelected(HomeTab tab) {
    setState(() => _selectedTab = tab);
    final categoryId = _categoryIdFor(tab, context.read<CategoryCubit>().state.categories);
    context.read<ProductCubit>().fetchProducts(categoryId: categoryId);
  }

  Future<void> _refresh() async {
    final categoryCubit = context.read<CategoryCubit>();
    final productCubit = context.read<ProductCubit>();
    await categoryCubit.fetchCategories();
    final categoryId = _categoryIdFor(_selectedTab, categoryCubit.state.categories);
    await productCubit.fetchProducts(categoryId: categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aura Fashion'),
        actions: [
          BlocBuilder<WishlistCubit, WishlistState>(
            builder: (context, state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    ),
                  ),
                  if (state.items.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${state.items.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                  if (state.itemCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${state.itemCount}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const PromoBanner(),
          const SizedBox(height: 12),
          HomeTabBar(selected: _selectedTab, onSelected: _onTabSelected),
          const Divider(height: 1),
          Expanded(
            child: ProductGrid(
              onRefresh: _refresh,
              filter: _selectedTab == HomeTab.sale ? (p) => p.isOnSale : null,
            ),
          ),
        ],
      ),
    );
  }
}
