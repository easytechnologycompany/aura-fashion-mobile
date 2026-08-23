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

const _dress = CartItemEntity(
  productId: 'p1',
  name: 'Floral Wrap Dress',
  imageUrl: 'https://example.com/dress.jpg',
  unitPrice: 39.99,
  quantity: 1,
  availableStock: 3,
);

CartCubit _buildCubit(SharedPreferences prefs) {
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('adding an item puts it in the cart with the requested quantity', () async {
    final cubit = _buildCubit(await SharedPreferences.getInstance());

    await cubit.addItem(_dress);

    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.items.single.quantity, 1);
    expect(cubit.state.itemCount, 1);
    expect(cubit.state.total, closeTo(39.99, 0.001));
  });

  test('adding the same product twice merges quantities', () async {
    final cubit = _buildCubit(await SharedPreferences.getInstance());

    await cubit.addItem(_dress);
    await cubit.addItem(_dress.copyWith(quantity: 1));

    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.items.single.quantity, 2);
  });

  test('merged quantity is capped at available stock', () async {
    final cubit = _buildCubit(await SharedPreferences.getInstance());

    await cubit.addItem(_dress.copyWith(quantity: 2));
    await cubit.addItem(_dress.copyWith(quantity: 5));

    expect(cubit.state.items.single.quantity, _dress.availableStock);
  });

  test('updating quantity to zero removes the item', () async {
    final cubit = _buildCubit(await SharedPreferences.getInstance());

    await cubit.addItem(_dress);
    await cubit.updateQuantity(_dress.productId, 0);

    expect(cubit.state.items, isEmpty);
  });

  test('removeItem removes only the targeted product', () async {
    final cubit = _buildCubit(await SharedPreferences.getInstance());
    const shoe = CartItemEntity(
      productId: 'p2',
      name: 'Platform Sneakers',
      imageUrl: '',
      unitPrice: 44.99,
      quantity: 1,
      availableStock: 10,
    );

    await cubit.addItem(_dress);
    await cubit.addItem(shoe);
    await cubit.removeItem(_dress.productId);

    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.items.single.productId, 'p2');
  });

  test('cart persists across cubit instances via SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    await _buildCubit(prefs).addItem(_dress);

    final reloaded = _buildCubit(prefs);
    await reloaded.loadCart();

    expect(reloaded.state.items, hasLength(1));
    expect(reloaded.state.items.single.productId, _dress.productId);
  });

  test('clear empties the cart and persisted storage', () async {
    final prefs = await SharedPreferences.getInstance();
    final cubit = _buildCubit(prefs);

    await cubit.addItem(_dress);
    await cubit.clear();

    expect(cubit.state.items, isEmpty);

    final reloaded = _buildCubit(prefs);
    await reloaded.loadCart();
    expect(reloaded.state.items, isEmpty);
  });
}
