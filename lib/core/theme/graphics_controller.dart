import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'graphics_controller.freezed.dart';
part 'graphics_controller.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError('This is overridden in main.dart');
}

@freezed
class GraphicsState with _$GraphicsState {
  const factory GraphicsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(true) bool highFidelityCanvas,
    @Default(true) bool snapToGrid,
    @Default(true) bool showLabels,
    @Default(Color(0xFFF5F5F5)) Color backgroundColor,
    @Default(true) bool showGrid,
    @Default(Color(0xFFE0E0E0)) Color gridColor,
  }) = _GraphicsState;
}

@riverpod
class GraphicsController extends _$GraphicsController {
  late SharedPreferences _prefs;

  @override
  GraphicsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);

    return GraphicsState(
      themeMode: _loadThemeMode(),
      highFidelityCanvas: _prefs.getBool('highFidelityCanvas') ?? true,
      snapToGrid: _prefs.getBool('snapToGrid') ?? true,
      showLabels: _prefs.getBool('showLabels') ?? true,
      showGrid: _prefs.getBool('showGrid') ?? true,
    );
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setString('themeMode', mode.name);
    state = state.copyWith(themeMode: mode);
  }

  void toggleGrid(bool visible) {
    _prefs.setBool('showGrid', visible);
    state = state.copyWith(showGrid: visible);
  }

  void toggleHighFidelity(bool isHighFidelity) {
    _prefs.setBool('highFidelityCanvas', isHighFidelity);
    state = state.copyWith(highFidelityCanvas: isHighFidelity);
  }

  ThemeMode _loadThemeMode() {
    final savedMode = _prefs.getString('themeMode');
    return ThemeMode.values.firstWhere(
          (element) => element.name == savedMode,
      orElse: () => ThemeMode.system,
    );
  }
}