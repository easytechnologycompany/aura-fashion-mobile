import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../theme/theme_cubit.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_cached_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_product_by_id_usecase.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/presentation/cubit/product_cubit.dart';

import '../../features/categories/data/datasources/category_remote_data_source.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/get_categories_usecase.dart';
import '../../features/categories/presentation/cubit/category_cubit.dart';

import '../../features/products/presentation/cubit/product_detail_cubit.dart';

import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart_usecase.dart';
import '../../features/cart/domain/usecases/clear_cart_usecase.dart';
import '../../features/cart/domain/usecases/get_cart_usecase.dart';
import '../../features/cart/domain/usecases/remove_from_cart_usecase.dart';
import '../../features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';

import '../../features/orders/data/datasources/order_remote_data_source.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/create_order_usecase.dart';
import '../../features/orders/domain/usecases/get_order_usecase.dart';
import '../../features/orders/domain/usecases/list_orders_usecase.dart';
import '../../features/orders/presentation/cubit/checkout_cubit.dart';
import '../../features/orders/presentation/cubit/order_list_cubit.dart';
import '../../features/orders/presentation/cubit/order_tracking_cubit.dart';

import '../../features/addresses/data/datasources/address_local_data_source.dart';
import '../../features/addresses/data/repositories/address_repository_impl.dart';
import '../../features/addresses/domain/repositories/address_repository.dart';
import '../../features/addresses/domain/usecases/add_address_usecase.dart';
import '../../features/addresses/domain/usecases/get_addresses_usecase.dart';
import '../../features/addresses/domain/usecases/remove_address_usecase.dart';
import '../../features/addresses/presentation/cubit/address_cubit.dart';

import '../../features/wishlist/data/datasources/wishlist_local_data_source.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../../features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import '../../features/wishlist/domain/usecases/get_wishlist_usecase.dart';
import '../../features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import '../../features/wishlist/presentation/cubit/wishlist_cubit.dart';

final sl = GetIt.instance;

/// Registers every dependency used across the app. Call once from `main()`
/// before `runApp`.
Future<void> initDependencies() async {
  // ----- External -----
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ----- Core -----
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));
  sl.registerLazySingleton(() => ThemeCubit(sl()));

  // ----- Auth feature -----
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCachedUserUseCase: sl(),
    ),
  );

  // ----- Products feature -----
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByIdUseCase(sl()));
  sl.registerFactory(() => ProductCubit(getProductsUseCase: sl()));

  // ----- Categories feature -----
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerFactory(() => CategoryCubit(getCategoriesUseCase: sl()));

  // ----- Product detail (uses the products feature's repository) -----
  sl.registerFactory(() => ProductDetailCubit(getProductByIdUseCase: sl()));

  // ----- Cart feature -----
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartItemQuantityUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));
  // Lazy singleton (not factory): the cart is app-wide state shared across
  // every screen, so all callers must see the same Cubit instance.
  sl.registerLazySingleton(
    () => CartCubit(
      getCartUseCase: sl(),
      addToCartUseCase: sl(),
      updateCartItemQuantityUseCase: sl(),
      removeFromCartUseCase: sl(),
      clearCartUseCase: sl(),
    ),
  );

  // ----- Orders feature (checkout) -----
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderUseCase(sl()));
  sl.registerLazySingleton(() => ListOrdersUseCase(sl()));
  sl.registerFactory(() => CheckoutCubit(createOrderUseCase: sl()));
  sl.registerFactory(() => OrderListCubit(listOrdersUseCase: sl()));
  sl.registerFactory(() => OrderTrackingCubit(getOrderUseCase: sl()));

  // ----- Wishlist feature -----
  sl.registerLazySingleton<WishlistLocalDataSource>(
    () => WishlistLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetWishlistUseCase(sl()));
  sl.registerLazySingleton(() => AddToWishlistUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromWishlistUseCase(sl()));
  // Lazy singleton (not factory): wishlist state, like the cart, is shared
  // across every screen (heart icons on cards, detail page, wishlist tab).
  sl.registerLazySingleton(
    () => WishlistCubit(
      getWishlistUseCase: sl(),
      addToWishlistUseCase: sl(),
      removeFromWishlistUseCase: sl(),
    ),
  );

  // ----- Addresses feature -----
  sl.registerLazySingleton<AddressLocalDataSource>(
    () => AddressLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetAddressesUseCase(sl()));
  sl.registerLazySingleton(() => AddAddressUseCase(sl()));
  sl.registerLazySingleton(() => RemoveAddressUseCase(sl()));
  // Lazy singleton: the selected/saved address list is shared between the
  // checkout sheet and any future address-management screen.
  sl.registerLazySingleton(
    () => AddressCubit(
      getAddressesUseCase: sl(),
      addAddressUseCase: sl(),
      removeAddressUseCase: sl(),
    ),
  );
}
