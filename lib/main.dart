import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/addresses/presentation/cubit/address_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/categories/presentation/cubit/category_cubit.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/products/presentation/cubit/product_cubit.dart';
import 'features/wishlist/presentation/cubit/wishlist_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(const AuraFashionApp());
}

class AuraFashionApp extends StatelessWidget {
  const AuraFashionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<ProductCubit>(create: (_) => di.sl<ProductCubit>()),
        BlocProvider<CategoryCubit>(create: (_) => di.sl<CategoryCubit>()),
        BlocProvider<CartCubit>(create: (_) => di.sl<CartCubit>()),
        BlocProvider<WishlistCubit>(create: (_) => di.sl<WishlistCubit>()),
        BlocProvider<AddressCubit>(
          create: (_) => di.sl<AddressCubit>()..loadAddresses(),
        ),
        BlocProvider<ThemeCubit>(create: (_) => di.sl<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Aura Fashion',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const _RootGate(),
          );
        },
      ),
    );
  }
}

/// Routes to the product catalog once authenticated, otherwise to login.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.authenticated:
            return const HomeScreen();
          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const LoginScreen();
        }
      },
    );
  }
}
