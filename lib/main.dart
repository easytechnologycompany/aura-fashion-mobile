import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/products/presentation/cubit/product_cubit.dart';
import 'features/products/presentation/pages/product_list_page.dart';

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
      ],
      child: MaterialApp(
        title: 'Aura Fashion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _RootGate(),
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
            return const ProductListPage();
          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const LoginScreen();
        }
      },
    );
  }
}
