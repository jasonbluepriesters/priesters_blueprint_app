// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blueprint_elements_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$blueprintElementsHash() => r'309c8409fcd2ae5bfbf9d7f9524f160491cdc741';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$BlueprintElements
    extends BuildlessAutoDisposeNotifier<List<dynamic>> {
  late final String blueprintId;

  List<dynamic> build(
    String blueprintId,
  );
}

/// See also [BlueprintElements].
@ProviderFor(BlueprintElements)
const blueprintElementsProvider = BlueprintElementsFamily();

/// See also [BlueprintElements].
class BlueprintElementsFamily extends Family<List<dynamic>> {
  /// See also [BlueprintElements].
  const BlueprintElementsFamily();

  /// See also [BlueprintElements].
  BlueprintElementsProvider call(
    String blueprintId,
  ) {
    return BlueprintElementsProvider(
      blueprintId,
    );
  }

  @override
  BlueprintElementsProvider getProviderOverride(
    covariant BlueprintElementsProvider provider,
  ) {
    return call(
      provider.blueprintId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'blueprintElementsProvider';
}

/// See also [BlueprintElements].
class BlueprintElementsProvider
    extends AutoDisposeNotifierProviderImpl<BlueprintElements, List<dynamic>> {
  /// See also [BlueprintElements].
  BlueprintElementsProvider(
    String blueprintId,
  ) : this._internal(
          () => BlueprintElements()..blueprintId = blueprintId,
          from: blueprintElementsProvider,
          name: r'blueprintElementsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$blueprintElementsHash,
          dependencies: BlueprintElementsFamily._dependencies,
          allTransitiveDependencies:
              BlueprintElementsFamily._allTransitiveDependencies,
          blueprintId: blueprintId,
        );

  BlueprintElementsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.blueprintId,
  }) : super.internal();

  final String blueprintId;

  @override
  List<dynamic> runNotifierBuild(
    covariant BlueprintElements notifier,
  ) {
    return notifier.build(
      blueprintId,
    );
  }

  @override
  Override overrideWith(BlueprintElements Function() create) {
    return ProviderOverride(
      origin: this,
      override: BlueprintElementsProvider._internal(
        () => create()..blueprintId = blueprintId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        blueprintId: blueprintId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<BlueprintElements, List<dynamic>>
      createElement() {
    return _BlueprintElementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BlueprintElementsProvider &&
        other.blueprintId == blueprintId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, blueprintId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BlueprintElementsRef on AutoDisposeNotifierProviderRef<List<dynamic>> {
  /// The parameter `blueprintId` of this provider.
  String get blueprintId;
}

class _BlueprintElementsProviderElement
    extends AutoDisposeNotifierProviderElement<BlueprintElements, List<dynamic>>
    with BlueprintElementsRef {
  _BlueprintElementsProviderElement(super.provider);

  @override
  String get blueprintId => (origin as BlueprintElementsProvider).blueprintId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
