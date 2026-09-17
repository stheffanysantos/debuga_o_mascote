// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complete_code_gameplay_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CompleteCodeGameplayState {
  CompleteCodeLevel get level => throw _privateConstructorUsedError;
  int? get selectedOptionIndex => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  CompleteCodeGameplayEffect? get pendingEffect =>
      throw _privateConstructorUsedError;

  /// Create a copy of CompleteCodeGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompleteCodeGameplayStateCopyWith<CompleteCodeGameplayState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompleteCodeGameplayStateCopyWith<$Res> {
  factory $CompleteCodeGameplayStateCopyWith(
    CompleteCodeGameplayState value,
    $Res Function(CompleteCodeGameplayState) then,
  ) = _$CompleteCodeGameplayStateCopyWithImpl<$Res, CompleteCodeGameplayState>;
  @useResult
  $Res call({
    CompleteCodeLevel level,
    int? selectedOptionIndex,
    int attempts,
    CompleteCodeGameplayEffect? pendingEffect,
  });

  $CompleteCodeGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class _$CompleteCodeGameplayStateCopyWithImpl<
  $Res,
  $Val extends CompleteCodeGameplayState
>
    implements $CompleteCodeGameplayStateCopyWith<$Res> {
  _$CompleteCodeGameplayStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompleteCodeGameplayState
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
                      as CompleteCodeLevel,
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
                      as CompleteCodeGameplayEffect?,
          )
          as $Val,
    );
  }

  /// Create a copy of CompleteCodeGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CompleteCodeGameplayEffectCopyWith<$Res>? get pendingEffect {
    if (_value.pendingEffect == null) {
      return null;
    }

    return $CompleteCodeGameplayEffectCopyWith<$Res>(_value.pendingEffect!, (
      value,
    ) {
      return _then(_value.copyWith(pendingEffect: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CompleteCodeGameplayStateImplCopyWith<$Res>
    implements $CompleteCodeGameplayStateCopyWith<$Res> {
  factory _$$CompleteCodeGameplayStateImplCopyWith(
    _$CompleteCodeGameplayStateImpl value,
    $Res Function(_$CompleteCodeGameplayStateImpl) then,
  ) = __$$CompleteCodeGameplayStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CompleteCodeLevel level,
    int? selectedOptionIndex,
    int attempts,
    CompleteCodeGameplayEffect? pendingEffect,
  });

  @override
  $CompleteCodeGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class __$$CompleteCodeGameplayStateImplCopyWithImpl<$Res>
    extends
        _$CompleteCodeGameplayStateCopyWithImpl<
          $Res,
          _$CompleteCodeGameplayStateImpl
        >
    implements _$$CompleteCodeGameplayStateImplCopyWith<$Res> {
  __$$CompleteCodeGameplayStateImplCopyWithImpl(
    _$CompleteCodeGameplayStateImpl _value,
    $Res Function(_$CompleteCodeGameplayStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompleteCodeGameplayState
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
      _$CompleteCodeGameplayStateImpl(
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as CompleteCodeLevel,
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
                  as CompleteCodeGameplayEffect?,
      ),
    );
  }
}

/// @nodoc

class _$CompleteCodeGameplayStateImpl implements _CompleteCodeGameplayState {
  const _$CompleteCodeGameplayStateImpl({
    required this.level,
    this.selectedOptionIndex,
    this.attempts = 0,
    this.pendingEffect,
  });

  @override
  final CompleteCodeLevel level;
  @override
  final int? selectedOptionIndex;
  @override
  @JsonKey()
  final int attempts;
  @override
  final CompleteCodeGameplayEffect? pendingEffect;

  @override
  String toString() {
    return 'CompleteCodeGameplayState(level: $level, selectedOptionIndex: $selectedOptionIndex, attempts: $attempts, pendingEffect: $pendingEffect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompleteCodeGameplayStateImpl &&
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

  /// Create a copy of CompleteCodeGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompleteCodeGameplayStateImplCopyWith<_$CompleteCodeGameplayStateImpl>
  get copyWith =>
      __$$CompleteCodeGameplayStateImplCopyWithImpl<
        _$CompleteCodeGameplayStateImpl
      >(this, _$identity);
}

abstract class _CompleteCodeGameplayState implements CompleteCodeGameplayState {
  const factory _CompleteCodeGameplayState({
    required final CompleteCodeLevel level,
    final int? selectedOptionIndex,
    final int attempts,
    final CompleteCodeGameplayEffect? pendingEffect,
  }) = _$CompleteCodeGameplayStateImpl;

  @override
  CompleteCodeLevel get level;
  @override
  int? get selectedOptionIndex;
  @override
  int get attempts;
  @override
  CompleteCodeGameplayEffect? get pendingEffect;

  /// Create a copy of CompleteCodeGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompleteCodeGameplayStateImplCopyWith<_$CompleteCodeGameplayStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CompleteCodeGameplayEffect {
  CompleteCodeResultData get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CompleteCodeResultData data) showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CompleteCodeResultData data)? showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CompleteCodeResultData data)? showResult,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShowCompleteCodeResult value) showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShowCompleteCodeResult value)? showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShowCompleteCodeResult value)? showResult,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of CompleteCodeGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompleteCodeGameplayEffectCopyWith<CompleteCodeGameplayEffect>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompleteCodeGameplayEffectCopyWith<$Res> {
  factory $CompleteCodeGameplayEffectCopyWith(
    CompleteCodeGameplayEffect value,
    $Res Function(CompleteCodeGameplayEffect) then,
  ) =
      _$CompleteCodeGameplayEffectCopyWithImpl<
        $Res,
        CompleteCodeGameplayEffect
      >;
  @useResult
  $Res call({CompleteCodeResultData data});
}

/// @nodoc
class _$CompleteCodeGameplayEffectCopyWithImpl<
  $Res,
  $Val extends CompleteCodeGameplayEffect
>
    implements $CompleteCodeGameplayEffectCopyWith<$Res> {
  _$CompleteCodeGameplayEffectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompleteCodeGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as CompleteCodeResultData,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShowCompleteCodeResultImplCopyWith<$Res>
    implements $CompleteCodeGameplayEffectCopyWith<$Res> {
  factory _$$ShowCompleteCodeResultImplCopyWith(
    _$ShowCompleteCodeResultImpl value,
    $Res Function(_$ShowCompleteCodeResultImpl) then,
  ) = __$$ShowCompleteCodeResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CompleteCodeResultData data});
}

/// @nodoc
class __$$ShowCompleteCodeResultImplCopyWithImpl<$Res>
    extends
        _$CompleteCodeGameplayEffectCopyWithImpl<
          $Res,
          _$ShowCompleteCodeResultImpl
        >
    implements _$$ShowCompleteCodeResultImplCopyWith<$Res> {
  __$$ShowCompleteCodeResultImplCopyWithImpl(
    _$ShowCompleteCodeResultImpl _value,
    $Res Function(_$ShowCompleteCodeResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompleteCodeGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$ShowCompleteCodeResultImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as CompleteCodeResultData,
      ),
    );
  }
}

/// @nodoc

class _$ShowCompleteCodeResultImpl implements ShowCompleteCodeResult {
  const _$ShowCompleteCodeResultImpl({required this.data});

  @override
  final CompleteCodeResultData data;

  @override
  String toString() {
    return 'CompleteCodeGameplayEffect.showResult(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShowCompleteCodeResultImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of CompleteCodeGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShowCompleteCodeResultImplCopyWith<_$ShowCompleteCodeResultImpl>
  get copyWith =>
      __$$ShowCompleteCodeResultImplCopyWithImpl<_$ShowCompleteCodeResultImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CompleteCodeResultData data) showResult,
  }) {
    return showResult(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CompleteCodeResultData data)? showResult,
  }) {
    return showResult?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CompleteCodeResultData data)? showResult,
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
    required TResult Function(ShowCompleteCodeResult value) showResult,
  }) {
    return showResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShowCompleteCodeResult value)? showResult,
  }) {
    return showResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShowCompleteCodeResult value)? showResult,
    required TResult orElse(),
  }) {
    if (showResult != null) {
      return showResult(this);
    }
    return orElse();
  }
}

abstract class ShowCompleteCodeResult implements CompleteCodeGameplayEffect {
  const factory ShowCompleteCodeResult({
    required final CompleteCodeResultData data,
  }) = _$ShowCompleteCodeResultImpl;

  @override
  CompleteCodeResultData get data;

  /// Create a copy of CompleteCodeGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShowCompleteCodeResultImplCopyWith<_$ShowCompleteCodeResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
