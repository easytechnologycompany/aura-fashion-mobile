import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura_fashion_mobile/features/wishlist/data/datasources/wishlist_local_data_source.dart';
import 'package:aura_fashion_mobile/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:aura_fashion_mobile/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:aura_fashion_mobile/features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import 'package:aura_fashion_mobile/features/wishlist/domain/usecases/get_wishlist_usecase.dart';
import 'package:aura_fashion_mobile/features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import 'package:aura_fashion_mobile/features/wishlist/presentation/cubit/wishlist_cubit.dart';

const _dress = WishlistItemEntity(
  productId: 'p1',
  name: 'Floral Wrap Dress',
  imageUrl: 'https://example.com/dress.jpg',
  unitPrice: 39.99,
);

WishlistCubit _buildCubit(SharedPreferences prefs) {
  final localDataSource = WishlistLocalDataSourceImpl(prefs);
  final repository = WishlistRepositoryImpl(localDataSource: localDataSource);
  return WishlistCubit(
    getWishlistUseCase: GetWishlistUseCase(repository),
    addToWishlistUseCase: AddToWishlistUseCase(repository),
    removeFromWishlistUseCase: RemoveFromWishlistUseCase(repository),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('adding an item puts it in the wishlist', () async {
    final cubit = _buildCubit(await SharedPreferences.getInstance());

    await cubit.addItem(_dress);

    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.contains('p1'), isTrue);
  });

  test('adding the same product twice is a no-op', () async {
    final cubit = _buildCubit(await SharedPreferences.getInstance());

    await cubit.addItem(_dress);
    await cubit.addItem(_dress);

    expect(cubit.state.items, hasLength(1));
  });

  test('toggle adds when absent and removes when present', () async {
    final cubit = _buildCubit(await SharedPreferences.getInstance());

    await cubit.toggle(_dress);
    expect(cubit.state.contains('p1'), isTrue);

    await cubit.toggle(_dress);
    expect(cubit.state.contains('p1'), isFalse);
  });

  test('removeItem removes only the targeted product', () async {
    final cubit = _buildCubit(await SharedPreferences.getInstance());
    const shoe = WishlistItemEntity(
      productId: 'p2',
      name: 'Platform Sneakers',
      imageUrl: '',
      unitPrice: 59.99,
      salePrice: 44.99,
    );

    await cubit.addItem(_dress);
    await cubit.addItem(shoe);
    await cubit.removeItem('p1');

    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.items.single.productId, 'p2');
    expect(cubit.state.items.single.isOnSale, isTrue);
  });

  test('wishlist persists across cubit instances via SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    await _buildCubit(prefs).addItem(_dress);

    final reloaded = _buildCubit(prefs);
    await reloaded.loadWishlist();

    expect(reloaded.state.items, hasLength(1));
    expect(reloaded.state.items.single.productId, _dress.productId);
  });
}
