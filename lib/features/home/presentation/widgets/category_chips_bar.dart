import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/presentation/cubit/category_cubit.dart';

class CategoryChipsBar extends StatelessWidget {
  const CategoryChipsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state.status == CategoryStatus.loading ||
            state.status == CategoryStatus.initial) {
          return const SizedBox(
            height: 48,
            child: Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state.status == CategoryStatus.failure || state.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: state.categories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = state.selectedCategoryId == null;
                return ChoiceChip(
                  label: const Text('All'),
                  selected: isSelected,
                  onSelected: (_) => context.read<CategoryCubit>().selectCategory(null),
                );
              }
              final category = state.categories[index - 1];
              final isSelected = state.selectedCategoryId == category.id;
              return ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (_) =>
                    context.read<CategoryCubit>().selectCategory(category.id),
              );
            },
          ),
        );
      },
    );
  }
}
