// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conveyor_gameplay_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConveyorGameplayState {
  ConveyorLevel get level => throw _privateConstructorUsedError;
  List<BeltBlock> get program => throw _privateConstructorUsedError;
  BeltCursor get cursor => throw _privateConstructorUsedError;
  bool get running => throw _privateConstructorUsedError;
  int? get currentStepBlockIndex => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  int get lastRunBlocksUsed => throw _privateConstructorUsedError;
  ConveyorGameplayEffect? get pendingEffect =>
      throw _privateConstructorUsedError;

  /// Create a copy of ConveyorGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConveyorGameplayStateCopyWith<ConveyorGameplayState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConveyorGameplayStateCopyWith<$Res> {
  factory $ConveyorGameplayStateCopyWith(
    ConveyorGameplayState value,
    $Res Function(ConveyorGameplayState) then,
  ) = _$ConveyorGameplayStateCopyWithImpl<$Res, ConveyorGameplayState>;
  @useResult
  $Res call({
    ConveyorLevel level,
    List<BeltBlock> program,
    BeltCursor cursor,
    bool running,
    int? currentStepBlockIndex,
    int attempts,
    int lastRunBlocksUsed,
    ConveyorGameplayEffect? pendingEffect,
  });

  $ConveyorGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class _$ConveyorGameplayStateCopyWithImpl<
  $Res,
  $Val extends ConveyorGameplayState
>
    implements $ConveyorGameplayStateCopyWith<$Res> {
  _$ConveyorGameplayStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConveyorGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? program = null,
    Object? cursor = null,
    Object? running = null,
    Object? currentStepBlockIndex = freezed,
    Object? attempts = null,
    Object? lastRunBlocksUsed = null,
    Object? pendingEffect = freezed,
  }) {
    return _then(
      _value.copyWith(
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as ConveyorLevel,
            program: null == program
                ? _value.program
                : program // ignore: cast_nullable_to_non_nullable
                      as List<BeltBlock>,
            cursor: null == cursor
                ? _value.cursor
                : cursor // ignore: cast_nullable_to_non_nullable
                      as BeltCursor,
            running: null == running
                ? _value.running
                : running // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentStepBlockIndex: freezed == currentStepBlockIndex
                ? _value.currentStepBlockIndex
                : currentStepBlockIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
            attempts: null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                      as int,
            lastRunBlocksUsed: null == lastRunBlocksUsed
                ? _value.lastRunBlocksUsed
                : lastRunBlocksUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingEffect: freezed == pendingEffect
                ? _value.pendingEffect
                : pendingEffect // ignore: cast_nullable_to_non_nullable
                      as ConveyorGameplayEffect?,
          )
          as $Val,
    );
  }

  /// Create a copy of ConveyorGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConveyorGameplayEffectCopyWith<$Res>? get pendingEffect {
    if (_value.pendingEffect == null) {
      return null;
    }

    return $ConveyorGameplayEffectCopyWith<$Res>(_value.pendingEffect!, (
      value,
    ) {
      return _then(_value.copyWith(pendingEffect: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConveyorGameplayStateImplCopyWith<$Res>
    implements $ConveyorGameplayStateCopyWith<$Res> {
  factory _$$ConveyorGameplayStateImplCopyWith(
    _$ConveyorGameplayStateImpl value,
    $Res Function(_$ConveyorGameplayStateImpl) then,
  ) = __$$ConveyorGameplayStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ConveyorLevel level,
    List<BeltBlock> program,
    BeltCursor cursor,
    bool running,
    int? currentStepBlockIndex,
    int attempts,
    int lastRunBlocksUsed,
    ConveyorGameplayEffect? pendingEffect,
  });

  @override
  $ConveyorGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class __$$ConveyorGameplayStateImplCopyWithImpl<$Res>
    extends
        _$ConveyorGameplayStateCopyWithImpl<$Res, _$ConveyorGameplayStateImpl>
    implements _$$ConveyorGameplayStateImplCopyWith<$Res> {
  __$$ConveyorGameplayStateImplCopyWithImpl(
    _$ConveyorGameplayStateImpl _value,
    $Res Function(_$ConveyorGameplayStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConveyorGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? program = null,
    Object? cursor = null,
    Object? running = null,
    Object? currentStepBlockIndex = freezed,
    Object? attempts = null,
    Object? lastRunBlocksUsed = null,
    Object? pendingEffect = freezed,
  }) {
    return _then(
      _$ConveyorGameplayStateImpl(
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as ConveyorLevel,
        program: null == program
            ? _value._program
            : program // ignore: cast_nullable_to_non_nullable
                  as List<BeltBlock>,
        cursor: null == cursor
            ? _value.cursor
            : cursor // ignore: cast_nullable_to_non_nullable
                  as BeltCursor,
        running: null == running
            ? _value.running
            : running // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentStepBlockIndex: freezed == currentStepBlockIndex
            ? _value.currentStepBlockIndex
            : currentStepBlockIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
        attempts: null == attempts
            ? _value.attempts
            : attempts // ignore: cast_nullable_to_non_nullable
                  as int,
        lastRunBlocksUsed: null == lastRunBlocksUsed
            ? _value.lastRunBlocksUsed
            : lastRunBlocksUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingEffect: freezed == pendingEffect
            ? _value.pendingEffect
            : pendingEffect // ignore: cast_nullable_to_non_nullable
                  as ConveyorGameplayEffect?,
      ),
    );
  }
}

/// @nodoc

class _$ConveyorGameplayStateImpl implements _ConveyorGameplayState {
  const _$ConveyorGameplayStateImpl({
    required this.level,
    final List<BeltBlock> program = const <BeltBlock>[],
    required this.cursor,
    this.running = false,
    this.currentStepBlockIndex,
    this.attempts = 0,
    this.lastRunBlocksUsed = 0,
    this.pendingEffect,
  }) : _program = program;

  @override
  final ConveyorLevel level;
  final List<BeltBlock> _program;
  @override
  @JsonKey()
  List<BeltBlock> get program {
    if (_program is EqualUnmodifiableListView) return _program;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_program);
  }

  @override
  final BeltCursor cursor;
  @override
  @JsonKey()
  final bool running;
  @override
  final int? currentStepBlockIndex;
  @override
  @JsonKey()
  final int attempts;
  @override
  @JsonKey()
  final int lastRunBlocksUsed;
  @override
  final ConveyorGameplayEffect? pendingEffect;

  @override
  String toString() {
    return 'ConveyorGameplayState(level: $level, program: $program, cursor: $cursor, running: $running, currentStepBlockIndex: $currentStepBlockIndex, attempts: $attempts, lastRunBlocksUsed: $lastRunBlocksUsed, pendingEffect: $pendingEffect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConveyorGameplayStateImpl &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality().equals(other._program, _program) &&
            (identical(other.cursor, cursor) || other.cursor == cursor) &&
            (identical(other.running, running) || other.running == running) &&
            (identical(other.currentStepBlockIndex, currentStepBlockIndex) ||
                other.currentStepBlockIndex == currentStepBlockIndex) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.lastRunBlocksUsed, lastRunBlocksUsed) ||
                other.lastRunBlocksUsed == lastRunBlocksUsed) &&
            (identical(other.pendingEffect, pendingEffect) ||
                other.pendingEffect == pendingEffect));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    level,
    const DeepCollectionEquality().hash(_program),
    cursor,
    running,
    currentStepBlockIndex,
    attempts,
    lastRunBlocksUsed,
    pendingEffect,
  );

  /// Create a copy of ConveyorGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConveyorGameplayStateImplCopyWith<_$ConveyorGameplayStateImpl>
  get copyWith =>
      __$$ConveyorGameplayStateImplCopyWithImpl<_$ConveyorGameplayStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ConveyorGameplayState implements ConveyorGameplayState {
  const factory _ConveyorGameplayState({
    required final ConveyorLevel level,
    final List<BeltBlock> program,
    required final BeltCursor cursor,
    final bool running,
    final int? currentStepBlockIndex,
    final int attempts,
    final int lastRunBlocksUsed,
    final ConveyorGameplayEffect? pendingEffect,
  }) = _$ConveyorGameplayStateImpl;

  @override
  ConveyorLevel get level;
  @override
  List<BeltBlock> get program;
  @override
  BeltCursor get cursor;
  @override
  bool get running;
  @override
  int? get currentStepBlockIndex;
  @override
  int get attempts;
  @override
  int get lastRunBlocksUsed;
  @override
  ConveyorGameplayEffect? get pendingEffect;

  /// Create a copy of ConveyorGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConveyorGameplayStateImplCopyWith<_$ConveyorGameplayStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ConveyorGameplayEffect {
  Object get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ConveyorVictoryData data) navigateToVictory,
    required TResult Function(ConveyorFailureData data) navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ConveyorVictoryData data)? navigateToVictory,
    TResult? Function(ConveyorFailureData data)? navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ConveyorVictoryData data)? navigateToVictory,
    TResult Function(ConveyorFailureData data)? navigateToFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NavigateToConveyorVictory value)
    navigateToVictory,
    required TResult Function(NavigateToConveyorFailure value)
    navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToConveyorVictory value)? navigateToVictory,
    TResult? Function(NavigateToConveyorFailure value)? navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToConveyorVictory value)? navigateToVictory,
    TResult Function(NavigateToConveyorFailure value)? navigateToFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConveyorGameplayEffectCopyWith<$Res> {
  factory $ConveyorGameplayEffectCopyWith(
    ConveyorGameplayEffect value,
    $Res Function(ConveyorGameplayEffect) then,
  ) = _$ConveyorGameplayEffectCopyWithImpl<$Res, ConveyorGameplayEffect>;
}

/// @nodoc
class _$ConveyorGameplayEffectCopyWithImpl<
  $Res,
  $Val extends ConveyorGameplayEffect
>
    implements $ConveyorGameplayEffectCopyWith<$Res> {
  _$ConveyorGameplayEffectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConveyorGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NavigateToConveyorVictoryImplCopyWith<$Res> {
  factory _$$NavigateToConveyorVictoryImplCopyWith(
    _$NavigateToConveyorVictoryImpl value,
    $Res Function(_$NavigateToConveyorVictoryImpl) then,
  ) = __$$NavigateToConveyorVictoryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ConveyorVictoryData data});
}

/// @nodoc
class __$$NavigateToConveyorVictoryImplCopyWithImpl<$Res>
    extends
        _$ConveyorGameplayEffectCopyWithImpl<
          $Res,
          _$NavigateToConveyorVictoryImpl
        >
    implements _$$NavigateToConveyorVictoryImplCopyWith<$Res> {
  __$$NavigateToConveyorVictoryImplCopyWithImpl(
    _$NavigateToConveyorVictoryImpl _value,
    $Res Function(_$NavigateToConveyorVictoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConveyorGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$NavigateToConveyorVictoryImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as ConveyorVictoryData,
      ),
    );
  }
}

/// @nodoc

class _$NavigateToConveyorVictoryImpl implements NavigateToConveyorVictory {
  const _$NavigateToConveyorVictoryImpl({required this.data});

  @override
  final ConveyorVictoryData data;

  @override
  String toString() {
    return 'ConveyorGameplayEffect.navigateToVictory(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigateToConveyorVictoryImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of ConveyorGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigateToConveyorVictoryImplCopyWith<_$NavigateToConveyorVictoryImpl>
  get copyWith =>
      __$$NavigateToConveyorVictoryImplCopyWithImpl<
        _$NavigateToConveyorVictoryImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ConveyorVictoryData data) navigateToVictory,
    required TResult Function(ConveyorFailureData data) navigateToFailure,
  }) {
    return navigateToVictory(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ConveyorVictoryData data)? navigateToVictory,
    TResult? Function(ConveyorFailureData data)? navigateToFailure,
  }) {
    return navigateToVictory?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ConveyorVictoryData data)? navigateToVictory,
    TResult Function(ConveyorFailureData data)? navigateToFailure,
    required TResult orElse(),
  }) {
    if (navigateToVictory != null) {
      return navigateToVictory(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NavigateToConveyorVictory value)
    navigateToVictory,
    required TResult Function(NavigateToConveyorFailure value)
    navigateToFailure,
  }) {
    return navigateToVictory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToConveyorVictory value)? navigateToVictory,
    TResult? Function(NavigateToConveyorFailure value)? navigateToFailure,
  }) {
    return navigateToVictory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToConveyorVictory value)? navigateToVictory,
    TResult Function(NavigateToConveyorFailure value)? navigateToFailure,
    required TResult orElse(),
  }) {
    if (navigateToVictory != null) {
      return navigateToVictory(this);
    }
    return orElse();
  }
}

abstract class NavigateToConveyorVictory implements ConveyorGameplayEffect {
  const factory NavigateToConveyorVictory({
    required final ConveyorVictoryData data,
  }) = _$NavigateToConveyorVictoryImpl;

  @override
  ConveyorVictoryData get data;

  /// Create a copy of ConveyorGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigateToConveyorVictoryImplCopyWith<_$NavigateToConveyorVictoryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NavigateToConveyorFailureImplCopyWith<$Res> {
  factory _$$NavigateToConveyorFailureImplCopyWith(
    _$NavigateToConveyorFailureImpl value,
    $Res Function(_$NavigateToConveyorFailureImpl) then,
  ) = __$$NavigateToConveyorFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ConveyorFailureData data});
}

/// @nodoc
class __$$NavigateToConveyorFailureImplCopyWithImpl<$Res>
    extends
        _$ConveyorGameplayEffectCopyWithImpl<
          $Res,
          _$NavigateToConveyorFailureImpl
        >
    implements _$$NavigateToConveyorFailureImplCopyWith<$Res> {
  __$$NavigateToConveyorFailureImplCopyWithImpl(
    _$NavigateToConveyorFailureImpl _value,
    $Res Function(_$NavigateToConveyorFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConveyorGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$NavigateToConveyorFailureImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as ConveyorFailureData,
      ),
    );
  }
}

/// @nodoc

class _$NavigateToConveyorFailureImpl implements NavigateToConveyorFailure {
  const _$NavigateToConveyorFailureImpl({required this.data});

  @override
  final ConveyorFailureData data;

  @override
  String toString() {
    return 'ConveyorGameplayEffect.navigateToFailure(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigateToConveyorFailureImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of ConveyorGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigateToConveyorFailureImplCopyWith<_$NavigateToConveyorFailureImpl>
  get copyWith =>
      __$$NavigateToConveyorFailureImplCopyWithImpl<
        _$NavigateToConveyorFailureImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ConveyorVictoryData data) navigateToVictory,
    required TResult Function(ConveyorFailureData data) navigateToFailure,
  }) {
    return navigateToFailure(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ConveyorVictoryData data)? navigateToVictory,
    TResult? Function(ConveyorFailureData data)? navigateToFailure,
  }) {
    return navigateToFailure?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ConveyorVictoryData data)? navigateToVictory,
    TResult Function(ConveyorFailureData data)? navigateToFailure,
    required TResult orElse(),
  }) {
    if (navigateToFailure != null) {
      return navigateToFailure(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NavigateToConveyorVictory value)
    navigateToVictory,
    required TResult Function(NavigateToConveyorFailure value)
    navigateToFailure,
  }) {
    return navigateToFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToConveyorVictory value)? navigateToVictory,
    TResult? Function(NavigateToConveyorFailure value)? navigateToFailure,
  }) {
    return navigateToFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToConveyorVictory value)? navigateToVictory,
    TResult Function(NavigateToConveyorFailure value)? navigateToFailure,
    required TResult orElse(),
  }) {
    if (navigateToFailure != null) {
      return navigateToFailure(this);
    }
    return orElse();
  }
}

abstract class NavigateToConveyorFailure implements ConveyorGameplayEffect {
  const factory NavigateToConveyorFailure({
    required final ConveyorFailureData data,
  }) = _$NavigateToConveyorFailureImpl;

  @override
  ConveyorFailureData get data;

  /// Create a copy of ConveyorGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigateToConveyorFailureImplCopyWith<_$NavigateToConveyorFailureImpl>
  get copyWith => throw _privateConstructorUsedError;
}
