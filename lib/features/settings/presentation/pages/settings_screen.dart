import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../../core/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return RadioGroup<ThemeMode>(
                groupValue: mode,
                onChanged: (value) =>
                    context.read<ThemeCubit>().setThemeMode(value!),
                child: const Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: Text('Light'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Dark'),
                      value: ThemeMode.dark,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Match system'),
                      value: ThemeMode.system,
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();
    final navigator = Navigator.of(context, rootNavigator: true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue shopping.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await authCubit.logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
