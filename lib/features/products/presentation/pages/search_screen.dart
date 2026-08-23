import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../cubit/product_cubit.dart';
import '../widgets/product_grid.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProductCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _queryController = TextEditingController();
  Timer? _debounce;
  RangeValues _priceRange = const RangeValues(0, 200);
  bool _priceFilterActive = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _runSearch);
  }

  void _runSearch() {
    final query = _queryController.text.trim();
    context.read<ProductCubit>().fetchProducts(
          search: query.isEmpty ? null : query,
          minPrice: _priceFilterActive ? _priceRange.start : null,
          maxPrice: _priceFilterActive ? _priceRange.end : null,
        );
  }

  Future<void> _pickPriceRange() async {
    final result = await showModalBottomSheet<_PriceFilterResult>(
      context: context,
      builder: (sheetContext) => _PriceFilterSheet(initial: _priceRange),
    );
    // Sheet dismissed (e.g. swiped away) without Apply/Clear — leave as-is.
    if (result == null) return;

    setState(() {
      _priceFilterActive = result.range != null;
      if (result.range != null) _priceRange = result.range!;
    });
    _runSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search products…',
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
          onSubmitted: (_) => _runSearch(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color: _priceFilterActive ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: 'Price filter',
            onPressed: _pickPriceRange,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_priceFilterActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                    '\$${_priceRange.start.round()} – \$${_priceRange.end.round()}',
                  ),
                  onDeleted: () {
                    setState(() => _priceFilterActive = false);
                    _runSearch();
                  },
                ),
              ),
            ),
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state.status == ProductStatus.initial) {
                  return const Center(
                    child: Text('Search for products by name'),
                  );
                }
                return ProductGrid(
                  onRefresh: () async => _runSearch(),
                  emptyMessage: 'No products match your search',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// `range == null` means "clear the filter", distinct from the sheet being
/// dismissed without a choice (which yields a null [_PriceFilterResult]).
class _PriceFilterResult {
  final RangeValues? range;
  const _PriceFilterResult(this.range);
}

class _PriceFilterSheet extends StatefulWidget {
  final RangeValues initial;

  const _PriceFilterSheet({required this.initial});

  @override
  State<_PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<_PriceFilterSheet> {
  late RangeValues _range = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Range', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '\$${_range.start.round()} – \$${_range.end.round()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          RangeSlider(
            values: _range,
            min: 0,
            max: 200,
            divisions: 40,
            labels: RangeLabels(
              '\$${_range.start.round()}',
              '\$${_range.end.round()}',
            ),
            onChanged: (values) => setState(() => _range = values),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(const _PriceFilterResult(null)),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_PriceFilterResult(_range)),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
