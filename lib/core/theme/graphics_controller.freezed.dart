// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'graphics_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GraphicsState {
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  bool get highFidelityCanvas => throw _privateConstructorUsedError;
  bool get snapToGrid => throw _privateConstructorUsedError;
  bool get showLabels => throw _privateConstructorUsedError;
  Color get backgroundColor => throw _privateConstructorUsedError;
  bool get showGrid => throw _privateConstructorUsedError;
  Color get gridColor => throw _privateConstructorUsedError;

  /// Create a copy of GraphicsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GraphicsStateCopyWith<GraphicsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GraphicsStateCopyWith<$Res> {
  factory $GraphicsStateCopyWith(
          GraphicsState value, $Res Function(GraphicsState) then) =
      _$GraphicsStateCopyWithImpl<$Res, GraphicsState>;
  @useResult
  $Res call(
      {ThemeMode themeMode,
      bool highFidelityCanvas,
      bool snapToGrid,
      bool showLabels,
      Color backgroundColor,
      bool showGrid,
      Color gridColor});
}

/// @nodoc
class _$GraphicsStateCopyWithImpl<$Res, $Val extends GraphicsState>
    implements $GraphicsStateCopyWith<$Res> {
  _$GraphicsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GraphicsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? highFidelityCanvas = null,
    Object? snapToGrid = null,
    Object? showLabels = null,
    Object? backgroundColor = null,
    Object? showGrid = null,
    Object? gridColor = null,
  }) {
    return _then(_value.copyWith(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      highFidelityCanvas: null == highFidelityCanvas
          ? _value.highFidelityCanvas
          : highFidelityCanvas // ignore: cast_nullable_to_non_nullable
              as bool,
      snapToGrid: null == snapToGrid
          ? _value.snapToGrid
          : snapToGrid // ignore: cast_nullable_to_non_nullable
              as bool,
      showLabels: null == showLabels
          ? _value.showLabels
          : showLabels // ignore: cast_nullable_to_non_nullable
              as bool,
      backgroundColor: null == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color,
      showGrid: null == showGrid
          ? _value.showGrid
          : showGrid // ignore: cast_nullable_to_non_nullable
              as bool,
      gridColor: null == gridColor
          ? _value.gridColor
          : gridColor // ignore: cast_nullable_to_non_nullable
              as Color,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GraphicsStateImplCopyWith<$Res>
    implements $GraphicsStateCopyWith<$Res> {
  factory _$$GraphicsStateImplCopyWith(
          _$GraphicsStateImpl value, $Res Function(_$GraphicsStateImpl) then) =
      __$$GraphicsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ThemeMode themeMode,
      bool highFidelityCanvas,
      bool snapToGrid,
      bool showLabels,
      Color backgroundColor,
      bool showGrid,
      Color gridColor});
}

/// @nodoc
class __$$GraphicsStateImplCopyWithImpl<$Res>
    extends _$GraphicsStateCopyWithImpl<$Res, _$GraphicsStateImpl>
    implements _$$GraphicsStateImplCopyWith<$Res> {
  __$$GraphicsStateImplCopyWithImpl(
      _$GraphicsStateImpl _value, $Res Function(_$GraphicsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GraphicsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? highFidelityCanvas = null,
    Object? snapToGrid = null,
    Object? showLabels = null,
    Object? backgroundColor = null,
    Object? showGrid = null,
    Object? gridColor = null,
  }) {
    return _then(_$GraphicsStateImpl(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      highFidelityCanvas: null == highFidelityCanvas
          ? _value.highFidelityCanvas
          : highFidelityCanvas // ignore: cast_nullable_to_non_nullable
              as bool,
      snapToGrid: null == snapToGrid
          ? _value.snapToGrid
          : snapToGrid // ignore: cast_nullable_to_non_nullable
              as bool,
      showLabels: null == showLabels
          ? _value.showLabels
          : showLabels // ignore: cast_nullable_to_non_nullable
              as bool,
      backgroundColor: null == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color,
      showGrid: null == showGrid
          ? _value.showGrid
          : showGrid // ignore: cast_nullable_to_non_nullable
              as bool,
      gridColor: null == gridColor
          ? _value.gridColor
          : gridColor // ignore: cast_nullable_to_non_nullable
              as Color,
    ));
  }
}

/// @nodoc

class _$GraphicsStateImpl implements _GraphicsState {
  const _$GraphicsStateImpl(
      {this.themeMode = ThemeMode.system,
      this.highFidelityCanvas = true,
      this.snapToGrid = true,
      this.showLabels = true,
      this.backgroundColor = const Color(0xFFF5F5F5),
      this.showGrid = true,
      this.gridColor = const Color(0xFFE0E0E0)});

  @override
  @JsonKey()
  final ThemeMode themeMode;
  @override
  @JsonKey()
  final bool highFidelityCanvas;
  @override
  @JsonKey()
  final bool snapToGrid;
  @override
  @JsonKey()
  final bool showLabels;
  @override
  @JsonKey()
  final Color backgroundColor;
  @override
  @JsonKey()
  final bool showGrid;
  @override
  @JsonKey()
  final Color gridColor;

  @override
  String toString() {
    return 'GraphicsState(themeMode: $themeMode, highFidelityCanvas: $highFidelityCanvas, snapToGrid: $snapToGrid, showLabels: $showLabels, backgroundColor: $backgroundColor, showGrid: $showGrid, gridColor: $gridColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GraphicsStateImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.highFidelityCanvas, highFidelityCanvas) ||
                other.highFidelityCanvas == highFidelityCanvas) &&
            (identical(other.snapToGrid, snapToGrid) ||
                other.snapToGrid == snapToGrid) &&
            (identical(other.showLabels, showLabels) ||
                other.showLabels == showLabels) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.showGrid, showGrid) ||
                other.showGrid == showGrid) &&
            (identical(other.gridColor, gridColor) ||
                other.gridColor == gridColor));
  }

  @override
  int get hashCode => Object.hash(runtimeType, themeMode, highFidelityCanvas,
      snapToGrid, showLabels, backgroundColor, showGrid, gridColor);

  /// Create a copy of GraphicsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GraphicsStateImplCopyWith<_$GraphicsStateImpl> get copyWith =>
      __$$GraphicsStateImplCopyWithImpl<_$GraphicsStateImpl>(this, _$identity);
}

abstract class _GraphicsState implements GraphicsState {
  const factory _GraphicsState(
      {final ThemeMode themeMode,
      final bool highFidelityCanvas,
      final bool snapToGrid,
      final bool showLabels,
      final Color backgroundColor,
      final bool showGrid,
      final Color gridColor}) = _$GraphicsStateImpl;

  @override
  ThemeMode get themeMode;
  @override
  bool get highFidelityCanvas;
  @override
  bool get snapToGrid;
  @override
  bool get showLabels;
  @override
  Color get backgroundColor;
  @override
  bool get showGrid;
  @override
  Color get gridColor;

  /// Create a copy of GraphicsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GraphicsStateImplCopyWith<_$GraphicsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
