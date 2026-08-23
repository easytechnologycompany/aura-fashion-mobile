import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wishlist_item_entity.dart';
import '../cubit/wishlist_cubit.dart';

/// A heart icon that toggles wishlist membership for [item], reflecting the
/// current state via the app-wide [WishlistCubit] singleton. Used both as a
/// small overlay button (product cards) and a larger app-bar action
/// (product detail), so size/background are configurable.
class WishlistButton extends StatelessWidget {
  final WishlistItemEntity item;
  final double size;
  final bool withBackground;

  const WishlistButton({
    super.key,
    required this.item,
    this.size = 20,
    this.withBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      buildWhen: (previous, current) =>
          previous.contains(item.productId) != current.contains(item.productId),
      builder: (context, state) {
        final isWishlisted = state.contains(item.productId);
        final icon = Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          size: size,
          color: isWishlisted
              ? Theme.of(context).colorScheme.error
              : (withBackground ? Colors.black87 : Theme.of(context).colorScheme.onSurface),
        );

        final button = InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: () => context.read<WishlistCubit>().toggle(item),
          child: Padding(
            padding: EdgeInsets.all(withBackground ? 6 : 4),
            child: icon,
          ),
        );

        if (!withBackground) return button;

        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white70,
            shape: BoxShape.circle,
          ),
          child: button,
        );
      },
    );
  }
}
