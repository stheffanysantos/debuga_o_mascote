// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gameplay_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GameplayState {
  Level get level => throw _privateConstructorUsedError;
  List<Block> get program => throw _privateConstructorUsedError;
  GameCursor get cursor => throw _privateConstructorUsedError;
  bool get running => throw _privateConstructorUsedError;
  int? get currentStepBlockIndex => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  int get lastRunBlocksUsed => throw _privateConstructorUsedError;
  GameplayEffect? get pendingEffect => throw _privateConstructorUsedError;

  /// Create a copy of GameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameplayStateCopyWith<GameplayState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameplayStateCopyWith<$Res> {
  factory $GameplayStateCopyWith(
    GameplayState value,
    $Res Function(GameplayState) then,
  ) = _$GameplayStateCopyWithImpl<$Res, GameplayState>;
  @useResult
  $Res call({
    Level level,
    List<Block> program,
    GameCursor cursor,
    bool running,
    int? currentStepBlockIndex,
    int attempts,
    int lastRunBlocksUsed,
    GameplayEffect? pendingEffect,
  });

  $GameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class _$GameplayStateCopyWithImpl<$Res, $Val extends GameplayState>
    implements $GameplayStateCopyWith<$Res> {
  _$GameplayStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameplayState
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
                      as Level,
            program: null == program
                ? _value.program
                : program // ignore: cast_nullable_to_non_nullable
                      as List<Block>,
            cursor: null == cursor
                ? _value.cursor
                : cursor // ignore: cast_nullable_to_non_nullable
                      as GameCursor,
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
                      as GameplayEffect?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameplayEffectCopyWith<$Res>? get pendingEffect {
    if (_value.pendingEffect == null) {
      return null;
    }

    return $GameplayEffectCopyWith<$Res>(_value.pendingEffect!, (value) {
      return _then(_value.copyWith(pendingEffect: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameplayStateImplCopyWith<$Res>
    implements $GameplayStateCopyWith<$Res> {
  factory _$$GameplayStateImplCopyWith(
    _$GameplayStateImpl value,
    $Res Function(_$GameplayStateImpl) then,
  ) = __$$GameplayStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Level level,
    List<Block> program,
    GameCursor cursor,
    bool running,
    int? currentStepBlockIndex,
    int attempts,
    int lastRunBlocksUsed,
    GameplayEffect? pendingEffect,
  });

  @override
  $GameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class __$$GameplayStateImplCopyWithImpl<$Res>
    extends _$GameplayStateCopyWithImpl<$Res, _$GameplayStateImpl>
    implements _$$GameplayStateImplCopyWith<$Res> {
  __$$GameplayStateImplCopyWithImpl(
    _$GameplayStateImpl _value,
    $Res Function(_$GameplayStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameplayState
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
      _$GameplayStateImpl(
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as Level,
        program: null == program
            ? _value._program
            : program // ignore: cast_nullable_to_non_nullable
                  as List<Block>,
        cursor: null == cursor
            ? _value.cursor
            : cursor // ignore: cast_nullable_to_non_nullable
                  as GameCursor,
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
                  as GameplayEffect?,
      ),
    );
  }
}

/// @nodoc

class _$GameplayStateImpl implements _GameplayState {
  const _$GameplayStateImpl({
    required this.level,
    final List<Block> program = const <Block>[],
    required this.cursor,
    this.running = false,
    this.currentStepBlockIndex,
    this.attempts = 0,
    this.lastRunBlocksUsed = 0,
    this.pendingEffect,
  }) : _program = program;

  @override
  final Level level;
  final List<Block> _program;
  @override
  @JsonKey()
  List<Block> get program {
    if (_program is EqualUnmodifiableListView) return _program;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_program);
  }

  @override
  final GameCursor cursor;
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
  final GameplayEffect? pendingEffect;

  @override
  String toString() {
    return 'GameplayState(level: $level, program: $program, cursor: $cursor, running: $running, currentStepBlockIndex: $currentStepBlockIndex, attempts: $attempts, lastRunBlocksUsed: $lastRunBlocksUsed, pendingEffect: $pendingEffect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameplayStateImpl &&
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

  /// Create a copy of GameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameplayStateImplCopyWith<_$GameplayStateImpl> get copyWith =>
      __$$GameplayStateImplCopyWithImpl<_$GameplayStateImpl>(this, _$identity);
}

abstract class _GameplayState implements GameplayState {
  const factory _GameplayState({
    required final Level level,
    final List<Block> program,
    required final GameCursor cursor,
    final bool running,
    final int? currentStepBlockIndex,
    final int attempts,
    final int lastRunBlocksUsed,
    final GameplayEffect? pendingEffect,
  }) = _$GameplayStateImpl;

  @override
  Level get level;
  @override
  List<Block> get program;
  @override
  GameCursor get cursor;
  @override
  bool get running;
  @override
  int? get currentStepBlockIndex;
  @override
  int get attempts;
  @override
  int get lastRunBlocksUsed;
  @override
  GameplayEffect? get pendingEffect;

  /// Create a copy of GameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameplayStateImplCopyWith<_$GameplayStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GameplayEffect {
  Object get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GameplayVictoryData data) navigateToVictory,
    required TResult Function(GameplayFailureData data) navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GameplayVictoryData data)? navigateToVictory,
    TResult? Function(GameplayFailureData data)? navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GameplayVictoryData data)? navigateToVictory,
    TResult Function(GameplayFailureData data)? navigateToFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NavigateToVictory value) navigateToVictory,
    required TResult Function(NavigateToFailure value) navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToVictory value)? navigateToVictory,
    TResult? Function(NavigateToFailure value)? navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToVictory value)? navigateToVictory,
    TResult Function(NavigateToFailure value)? navigateToFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameplayEffectCopyWith<$Res> {
  factory $GameplayEffectCopyWith(
    GameplayEffect value,
    $Res Function(GameplayEffect) then,
  ) = _$GameplayEffectCopyWithImpl<$Res, GameplayEffect>;
}

/// @nodoc
class _$GameplayEffectCopyWithImpl<$Res, $Val extends GameplayEffect>
    implements $GameplayEffectCopyWith<$Res> {
  _$GameplayEffectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameplayEffect
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NavigateToVictoryImplCopyWith<$Res> {
  factory _$$NavigateToVictoryImplCopyWith(
    _$NavigateToVictoryImpl value,
    $Res Function(_$NavigateToVictoryImpl) then,
  ) = __$$NavigateToVictoryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GameplayVictoryData data});
}

/// @nodoc
class __$$NavigateToVictoryImplCopyWithImpl<$Res>
    extends _$GameplayEffectCopyWithImpl<$Res, _$NavigateToVictoryImpl>
    implements _$$NavigateToVictoryImplCopyWith<$Res> {
  __$$NavigateToVictoryImplCopyWithImpl(
    _$NavigateToVictoryImpl _value,
    $Res Function(_$NavigateToVictoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$NavigateToVictoryImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as GameplayVictoryData,
      ),
    );
  }
}

/// @nodoc

class _$NavigateToVictoryImpl implements NavigateToVictory {
  const _$NavigateToVictoryImpl({required this.data});

  @override
  final GameplayVictoryData data;

  @override
  String toString() {
    return 'GameplayEffect.navigateToVictory(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigateToVictoryImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of GameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigateToVictoryImplCopyWith<_$NavigateToVictoryImpl> get copyWith =>
      __$$NavigateToVictoryImplCopyWithImpl<_$NavigateToVictoryImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GameplayVictoryData data) navigateToVictory,
    required TResult Function(GameplayFailureData data) navigateToFailure,
  }) {
    return navigateToVictory(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GameplayVictoryData data)? navigateToVictory,
    TResult? Function(GameplayFailureData data)? navigateToFailure,
  }) {
    return navigateToVictory?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GameplayVictoryData data)? navigateToVictory,
    TResult Function(GameplayFailureData data)? navigateToFailure,
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
    required TResult Function(NavigateToVictory value) navigateToVictory,
    required TResult Function(NavigateToFailure value) navigateToFailure,
  }) {
    return navigateToVictory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToVictory value)? navigateToVictory,
    TResult? Function(NavigateToFailure value)? navigateToFailure,
  }) {
    return navigateToVictory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToVictory value)? navigateToVictory,
    TResult Function(NavigateToFailure value)? navigateToFailure,
    required TResult orElse(),
  }) {
    if (navigateToVictory != null) {
      return navigateToVictory(this);
    }
    return orElse();
  }
}

abstract class NavigateToVictory implements GameplayEffect {
  const factory NavigateToVictory({required final GameplayVictoryData data}) =
      _$NavigateToVictoryImpl;

  @override
  GameplayVictoryData get data;

  /// Create a copy of GameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigateToVictoryImplCopyWith<_$NavigateToVictoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NavigateToFailureImplCopyWith<$Res> {
  factory _$$NavigateToFailureImplCopyWith(
    _$NavigateToFailureImpl value,
    $Res Function(_$NavigateToFailureImpl) then,
  ) = __$$NavigateToFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GameplayFailureData data});
}

/// @nodoc
class __$$NavigateToFailureImplCopyWithImpl<$Res>
    extends _$GameplayEffectCopyWithImpl<$Res, _$NavigateToFailureImpl>
    implements _$$NavigateToFailureImplCopyWith<$Res> {
  __$$NavigateToFailureImplCopyWithImpl(
    _$NavigateToFailureImpl _value,
    $Res Function(_$NavigateToFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$NavigateToFailureImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as GameplayFailureData,
      ),
    );
  }
}

/// @nodoc

class _$NavigateToFailureImpl implements NavigateToFailure {
  const _$NavigateToFailureImpl({required this.data});

  @override
  final GameplayFailureData data;

  @override
  String toString() {
    return 'GameplayEffect.navigateToFailure(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigateToFailureImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of GameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigateToFailureImplCopyWith<_$NavigateToFailureImpl> get copyWith =>
      __$$NavigateToFailureImplCopyWithImpl<_$NavigateToFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GameplayVictoryData data) navigateToVictory,
    required TResult Function(GameplayFailureData data) navigateToFailure,
  }) {
    return navigateToFailure(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GameplayVictoryData data)? navigateToVictory,
    TResult? Function(GameplayFailureData data)? navigateToFailure,
  }) {
    return navigateToFailure?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GameplayVictoryData data)? navigateToVictory,
    TResult Function(GameplayFailureData data)? navigateToFailure,
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
    required TResult Function(NavigateToVictory value) navigateToVictory,
    required TResult Function(NavigateToFailure value) navigateToFailure,
  }) {
    return navigateToFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToVictory value)? navigateToVictory,
    TResult? Function(NavigateToFailure value)? navigateToFailure,
  }) {
    return navigateToFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToVictory value)? navigateToVictory,
    TResult Function(NavigateToFailure value)? navigateToFailure,
    required TResult orElse(),
  }) {
    if (navigateToFailure != null) {
      return navigateToFailure(this);
    }
    return orElse();
  }
}

abstract class NavigateToFailure implements GameplayEffect {
  const factory NavigateToFailure({required final GameplayFailureData data}) =
      _$NavigateToFailureImpl;

  @override
  GameplayFailureData get data;

  /// Create a copy of GameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigateToFailureImplCopyWith<_$NavigateToFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
