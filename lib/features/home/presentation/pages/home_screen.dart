import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../widgets/category_chips_bar.dart';

/// The post-login landing screen: category filter chips over a product grid,
/// both backed by /categories and /products on aura-fashion-backend.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().fetchCategories();
    context.read<ProductCubit>().fetchProducts();
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<CategoryCubit>().fetchCategories(),
      context.read<ProductCubit>().fetchProducts(
            categoryId: context.read<CategoryCubit>().state.selectedCategoryId,
          ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aura Fashion')),
      body: BlocListener<CategoryCubit, CategoryState>(
        listenWhen: (previous, current) =>
            previous.selectedCategoryId != current.selectedCategoryId,
        listener: (context, state) {
          context
              .read<ProductCubit>()
              .fetchProducts(categoryId: state.selectedCategoryId);
        },
        child: Column(
          children: [
            const SizedBox(height: 8),
            const CategoryChipsBar(),
            const SizedBox(height: 8),
            Expanded(child: ProductGrid(onRefresh: _refresh)),
          ],
        ),
      ),
    );
  }
}
