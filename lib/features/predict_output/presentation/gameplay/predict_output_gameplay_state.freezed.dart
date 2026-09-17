// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'predict_output_gameplay_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PredictOutputGameplayState {
  PredictOutputLevel get level => throw _privateConstructorUsedError;
  int? get selectedOptionIndex => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  PredictOutputGameplayEffect? get pendingEffect =>
      throw _privateConstructorUsedError;

  /// Create a copy of PredictOutputGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PredictOutputGameplayStateCopyWith<PredictOutputGameplayState>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictOutputGameplayStateCopyWith<$Res> {
  factory $PredictOutputGameplayStateCopyWith(
    PredictOutputGameplayState value,
    $Res Function(PredictOutputGameplayState) then,
  ) =
      _$PredictOutputGameplayStateCopyWithImpl<
        $Res,
        PredictOutputGameplayState
      >;
  @useResult
  $Res call({
    PredictOutputLevel level,
    int? selectedOptionIndex,
    int attempts,
    PredictOutputGameplayEffect? pendingEffect,
  });

  $PredictOutputGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class _$PredictOutputGameplayStateCopyWithImpl<
  $Res,
  $Val extends PredictOutputGameplayState
>
    implements $PredictOutputGameplayStateCopyWith<$Res> {
  _$PredictOutputGameplayStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PredictOutputGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? selectedOptionIndex = freezed,
    Object? attempts = null,
    Object? pendingEffect = freezed,
  }) {
    return _then(
      _value.copyWith(
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as PredictOutputLevel,
            selectedOptionIndex: freezed == selectedOptionIndex
                ? _value.selectedOptionIndex
                : selectedOptionIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
            attempts: null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingEffect: freezed == pendingEffect
                ? _value.pendingEffect
                : pendingEffect // ignore: cast_nullable_to_non_nullable
                      as PredictOutputGameplayEffect?,
          )
          as $Val,
    );
  }

  /// Create a copy of PredictOutputGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PredictOutputGameplayEffectCopyWith<$Res>? get pendingEffect {
    if (_value.pendingEffect == null) {
      return null;
    }

    return $PredictOutputGameplayEffectCopyWith<$Res>(_value.pendingEffect!, (
      value,
    ) {
      return _then(_value.copyWith(pendingEffect: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PredictOutputGameplayStateImplCopyWith<$Res>
    implements $PredictOutputGameplayStateCopyWith<$Res> {
  factory _$$PredictOutputGameplayStateImplCopyWith(
    _$PredictOutputGameplayStateImpl value,
    $Res Function(_$PredictOutputGameplayStateImpl) then,
  ) = __$$PredictOutputGameplayStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PredictOutputLevel level,
    int? selectedOptionIndex,
    int attempts,
    PredictOutputGameplayEffect? pendingEffect,
  });

  @override
  $PredictOutputGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class __$$PredictOutputGameplayStateImplCopyWithImpl<$Res>
    extends
        _$PredictOutputGameplayStateCopyWithImpl<
          $Res,
          _$PredictOutputGameplayStateImpl
        >
    implements _$$PredictOutputGameplayStateImplCopyWith<$Res> {
  __$$PredictOutputGameplayStateImplCopyWithImpl(
    _$PredictOutputGameplayStateImpl _value,
    $Res Function(_$PredictOutputGameplayStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PredictOutputGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? selectedOptionIndex = freezed,
    Object? attempts = null,
    Object? pendingEffect = freezed,
  }) {
    return _then(
      _$PredictOutputGameplayStateImpl(
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as PredictOutputLevel,
        selectedOptionIndex: freezed == selectedOptionIndex
            ? _value.selectedOptionIndex
            : selectedOptionIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
        attempts: null == attempts
            ? _value.attempts
            : attempts // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingEffect: freezed == pendingEffect
            ? _value.pendingEffect
            : pendingEffect // ignore: cast_nullable_to_non_nullable
                  as PredictOutputGameplayEffect?,
      ),
    );
  }
}

/// @nodoc

class _$PredictOutputGameplayStateImpl implements _PredictOutputGameplayState {
  const _$PredictOutputGameplayStateImpl({
    required this.level,
    this.selectedOptionIndex,
    this.attempts = 0,
    this.pendingEffect,
  });

  @override
  final PredictOutputLevel level;
  @override
  final int? selectedOptionIndex;
  @override
  @JsonKey()
  final int attempts;
  @override
  final PredictOutputGameplayEffect? pendingEffect;

  @override
  String toString() {
    return 'PredictOutputGameplayState(level: $level, selectedOptionIndex: $selectedOptionIndex, attempts: $attempts, pendingEffect: $pendingEffect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictOutputGameplayStateImpl &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.selectedOptionIndex, selectedOptionIndex) ||
                other.selectedOptionIndex == selectedOptionIndex) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.pendingEffect, pendingEffect) ||
                other.pendingEffect == pendingEffect));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    level,
    selectedOptionIndex,
    attempts,
    pendingEffect,
  );

  /// Create a copy of PredictOutputGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictOutputGameplayStateImplCopyWith<_$PredictOutputGameplayStateImpl>
  get copyWith =>
      __$$PredictOutputGameplayStateImplCopyWithImpl<
        _$PredictOutputGameplayStateImpl
      >(this, _$identity);
}

abstract class _PredictOutputGameplayState
    implements PredictOutputGameplayState {
  const factory _PredictOutputGameplayState({
    required final PredictOutputLevel level,
    final int? selectedOptionIndex,
    final int attempts,
    final PredictOutputGameplayEffect? pendingEffect,
  }) = _$PredictOutputGameplayStateImpl;

  @override
  PredictOutputLevel get level;
  @override
  int? get selectedOptionIndex;
  @override
  int get attempts;
  @override
  PredictOutputGameplayEffect? get pendingEffect;

  /// Create a copy of PredictOutputGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PredictOutputGameplayStateImplCopyWith<_$PredictOutputGameplayStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PredictOutputGameplayEffect {
  PredictOutputResultData get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PredictOutputResultData data) showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PredictOutputResultData data)? showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PredictOutputResultData data)? showResult,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShowPredictOutputResult value) showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShowPredictOutputResult value)? showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShowPredictOutputResult value)? showResult,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of PredictOutputGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PredictOutputGameplayEffectCopyWith<PredictOutputGameplayEffect>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictOutputGameplayEffectCopyWith<$Res> {
  factory $PredictOutputGameplayEffectCopyWith(
    PredictOutputGameplayEffect value,
    $Res Function(PredictOutputGameplayEffect) then,
  ) =
      _$PredictOutputGameplayEffectCopyWithImpl<
        $Res,
        PredictOutputGameplayEffect
      >;
  @useResult
  $Res call({PredictOutputResultData data});
}

/// @nodoc
class _$PredictOutputGameplayEffectCopyWithImpl<
  $Res,
  $Val extends PredictOutputGameplayEffect
>
    implements $PredictOutputGameplayEffectCopyWith<$Res> {
  _$PredictOutputGameplayEffectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PredictOutputGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as PredictOutputResultData,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShowPredictOutputResultImplCopyWith<$Res>
    implements $PredictOutputGameplayEffectCopyWith<$Res> {
  factory _$$ShowPredictOutputResultImplCopyWith(
    _$ShowPredictOutputResultImpl value,
    $Res Function(_$ShowPredictOutputResultImpl) then,
  ) = __$$ShowPredictOutputResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PredictOutputResultData data});
}

/// @nodoc
class __$$ShowPredictOutputResultImplCopyWithImpl<$Res>
    extends
        _$PredictOutputGameplayEffectCopyWithImpl<
          $Res,
          _$ShowPredictOutputResultImpl
        >
    implements _$$ShowPredictOutputResultImplCopyWith<$Res> {
  __$$ShowPredictOutputResultImplCopyWithImpl(
    _$ShowPredictOutputResultImpl _value,
    $Res Function(_$ShowPredictOutputResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PredictOutputGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$ShowPredictOutputResultImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as PredictOutputResultData,
      ),
    );
  }
}

/// @nodoc

class _$ShowPredictOutputResultImpl implements ShowPredictOutputResult {
  const _$ShowPredictOutputResultImpl({required this.data});

  @override
  final PredictOutputResultData data;

  @override
  String toString() {
    return 'PredictOutputGameplayEffect.showResult(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShowPredictOutputResultImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of PredictOutputGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShowPredictOutputResultImplCopyWith<_$ShowPredictOutputResultImpl>
  get copyWith =>
      __$$ShowPredictOutputResultImplCopyWithImpl<
        _$ShowPredictOutputResultImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PredictOutputResultData data) showResult,
  }) {
    return showResult(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PredictOutputResultData data)? showResult,
  }) {
    return showResult?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PredictOutputResultData data)? showResult,
    required TResult orElse(),
  }) {
    if (showResult != null) {
      return showResult(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShowPredictOutputResult value) showResult,
  }) {
    return showResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShowPredictOutputResult value)? showResult,
  }) {
    return showResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShowPredictOutputResult value)? showResult,
    required TResult orElse(),
  }) {
    if (showResult != null) {
      return showResult(this);
    }
    return orElse();
  }
}

abstract class ShowPredictOutputResult implements PredictOutputGameplayEffect {
  const factory ShowPredictOutputResult({
    required final PredictOutputResultData data,
  }) = _$ShowPredictOutputResultImpl;

  @override
  PredictOutputResultData get data;

  /// Create a copy of PredictOutputGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShowPredictOutputResultImplCopyWith<_$ShowPredictOutputResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
