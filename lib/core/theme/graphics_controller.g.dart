// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graphics_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'ba76a00430192645e02a3bd8be0b8b38fb66fcab';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$graphicsControllerHash() =>
    r'91627a6ed7a9e14dde12f00b5840fcd438163907';

/// See also [GraphicsController].
@ProviderFor(GraphicsController)
final graphicsControllerProvider =
    AutoDisposeNotifierProvider<GraphicsController, GraphicsState>.internal(
  GraphicsController.new,
  name: r'graphicsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$graphicsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GraphicsController = AutoDisposeNotifier<GraphicsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
