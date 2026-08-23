import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

/// Persists the user's theme choice (light/dark/system) across launches.
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences sharedPreferences;

  ThemeCubit(this.sharedPreferences) : super(_readInitial(sharedPreferences));

  static ThemeMode _readInitial(SharedPreferences prefs) {
    final raw = prefs.getString(StorageKeys.themeMode);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await sharedPreferences.setString(StorageKeys.themeMode, mode.name);
  }
}
