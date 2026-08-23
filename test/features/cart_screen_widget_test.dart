import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura_fashion_mobile/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:aura_fashion_mobile/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:aura_fashion_mobile/features/cart/domain/entities/cart_item_entity.dart';
import 'package:aura_fashion_mobile/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:aura_fashion_mobile/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:aura_fashion_mobile/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:aura_fashion_mobile/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:aura_fashion_mobile/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:aura_fashion_mobile/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:aura_fashion_mobile/features/cart/presentation/pages/cart_screen.dart';

const _dress = CartItemEntity(
  productId: 'p1',
  name: 'Floral Wrap Dress',
  imageUrl: '',
  unitPrice: 39.99,
  quantity: 1,
  availableStock: 3,
);

Future<CartCubit> _buildCubit() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final localDataSource = CartLocalDataSourceImpl(prefs);
  final repository = CartRepositoryImpl(localDataSource: localDataSource);
  return CartCubit(
    getCartUseCase: GetCartUseCase(repository),
    addToCartUseCase: AddToCartUseCase(repository),
    updateCartItemQuantityUseCase: UpdateCartItemQuantityUseCase(repository),
    removeFromCartUseCase: RemoveFromCartUseCase(repository),
    clearCartUseCase: ClearCartUseCase(repository),
  );
}

void main() {
  testWidgets(
    'cart already populated in the singleton renders immediately, with no loading flash',
    (tester) async {
      final cubit = await _buildCubit();
      // Simulate an item having been added from elsewhere (e.g. the product
      // detail screen) before CartScreen is ever opened.
      await cubit.addItem(_dress);

      await tester.pumpWidget(
        BlocProvider<CartCubit>.value(
          value: cubit,
          child: const MaterialApp(home: CartScreen()),
        ),
      );
      await tester.pump();

      // No pump-and-settle before this assertion: if CartScreen re-triggered
      // a reload on open, the very first frame would show a spinner instead
      // of the already-current item.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Floral Wrap Dress'), findsOneWidget);
    },
  );

  testWidgets('empty cart CTA pops back to the previous screen', (tester) async {
    final cubit = await _buildCubit();
    await cubit.loadCart();

    // The provider must wrap MaterialApp (not `home:`) so that routes pushed
    // via Navigator — a sibling subtree in the Navigator's overlay, not a
    // descendant of `home` — can still resolve CartCubit via context.read.
    await tester.pumpWidget(
      BlocProvider<CartCubit>.value(
        value: cubit,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  child: const Text('Open cart'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open cart'));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Browse Products'), findsOneWidget);

    await tester.tap(find.text('Browse Products'));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsNothing);
    expect(find.text('Open cart'), findsOneWidget);
  });
}
