// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block_program_gameplay_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BlockProgramGameplayState {
  BlockProgramLevel get level => throw _privateConstructorUsedError;
  List<BlockProgramBlock> get program => throw _privateConstructorUsedError;
  BlockProgramCursor get cursor => throw _privateConstructorUsedError;
  bool get running => throw _privateConstructorUsedError;
  int? get currentStepBlockIndex => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  int get lastRunBlocksUsed => throw _privateConstructorUsedError;
  BlockProgramGameplayEffect? get pendingEffect =>
      throw _privateConstructorUsedError;

  /// Create a copy of BlockProgramGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockProgramGameplayStateCopyWith<BlockProgramGameplayState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockProgramGameplayStateCopyWith<$Res> {
  factory $BlockProgramGameplayStateCopyWith(
    BlockProgramGameplayState value,
    $Res Function(BlockProgramGameplayState) then,
  ) = _$BlockProgramGameplayStateCopyWithImpl<$Res, BlockProgramGameplayState>;
  @useResult
  $Res call({
    BlockProgramLevel level,
    List<BlockProgramBlock> program,
    BlockProgramCursor cursor,
    bool running,
    int? currentStepBlockIndex,
    int attempts,
    int lastRunBlocksUsed,
    BlockProgramGameplayEffect? pendingEffect,
  });

  $BlockProgramGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class _$BlockProgramGameplayStateCopyWithImpl<
  $Res,
  $Val extends BlockProgramGameplayState
>
    implements $BlockProgramGameplayStateCopyWith<$Res> {
  _$BlockProgramGameplayStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockProgramGameplayState
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
                      as BlockProgramLevel,
            program: null == program
                ? _value.program
                : program // ignore: cast_nullable_to_non_nullable
                      as List<BlockProgramBlock>,
            cursor: null == cursor
                ? _value.cursor
                : cursor // ignore: cast_nullable_to_non_nullable
                      as BlockProgramCursor,
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
                      as BlockProgramGameplayEffect?,
          )
          as $Val,
    );
  }

  /// Create a copy of BlockProgramGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlockProgramGameplayEffectCopyWith<$Res>? get pendingEffect {
    if (_value.pendingEffect == null) {
      return null;
    }

    return $BlockProgramGameplayEffectCopyWith<$Res>(_value.pendingEffect!, (
      value,
    ) {
      return _then(_value.copyWith(pendingEffect: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BlockProgramGameplayStateImplCopyWith<$Res>
    implements $BlockProgramGameplayStateCopyWith<$Res> {
  factory _$$BlockProgramGameplayStateImplCopyWith(
    _$BlockProgramGameplayStateImpl value,
    $Res Function(_$BlockProgramGameplayStateImpl) then,
  ) = __$$BlockProgramGameplayStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BlockProgramLevel level,
    List<BlockProgramBlock> program,
    BlockProgramCursor cursor,
    bool running,
    int? currentStepBlockIndex,
    int attempts,
    int lastRunBlocksUsed,
    BlockProgramGameplayEffect? pendingEffect,
  });

  @override
  $BlockProgramGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class __$$BlockProgramGameplayStateImplCopyWithImpl<$Res>
    extends
        _$BlockProgramGameplayStateCopyWithImpl<
          $Res,
          _$BlockProgramGameplayStateImpl
        >
    implements _$$BlockProgramGameplayStateImplCopyWith<$Res> {
  __$$BlockProgramGameplayStateImplCopyWithImpl(
    _$BlockProgramGameplayStateImpl _value,
    $Res Function(_$BlockProgramGameplayStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlockProgramGameplayState
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
      _$BlockProgramGameplayStateImpl(
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as BlockProgramLevel,
        program: null == program
            ? _value._program
            : program // ignore: cast_nullable_to_non_nullable
                  as List<BlockProgramBlock>,
        cursor: null == cursor
            ? _value.cursor
            : cursor // ignore: cast_nullable_to_non_nullable
                  as BlockProgramCursor,
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
                  as BlockProgramGameplayEffect?,
      ),
    );
  }
}

/// @nodoc

class _$BlockProgramGameplayStateImpl implements _BlockProgramGameplayState {
  const _$BlockProgramGameplayStateImpl({
    required this.level,
    final List<BlockProgramBlock> program = const <BlockProgramBlock>[],
    required this.cursor,
    this.running = false,
    this.currentStepBlockIndex,
    this.attempts = 0,
    this.lastRunBlocksUsed = 0,
    this.pendingEffect,
  }) : _program = program;

  @override
  final BlockProgramLevel level;
  final List<BlockProgramBlock> _program;
  @override
  @JsonKey()
  List<BlockProgramBlock> get program {
    if (_program is EqualUnmodifiableListView) return _program;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_program);
  }

  @override
  final BlockProgramCursor cursor;
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
  final BlockProgramGameplayEffect? pendingEffect;

  @override
  String toString() {
    return 'BlockProgramGameplayState(level: $level, program: $program, cursor: $cursor, running: $running, currentStepBlockIndex: $currentStepBlockIndex, attempts: $attempts, lastRunBlocksUsed: $lastRunBlocksUsed, pendingEffect: $pendingEffect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockProgramGameplayStateImpl &&
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

  /// Create a copy of BlockProgramGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockProgramGameplayStateImplCopyWith<_$BlockProgramGameplayStateImpl>
  get copyWith =>
      __$$BlockProgramGameplayStateImplCopyWithImpl<
        _$BlockProgramGameplayStateImpl
      >(this, _$identity);
}

abstract class _BlockProgramGameplayState implements BlockProgramGameplayState {
  const factory _BlockProgramGameplayState({
    required final BlockProgramLevel level,
    final List<BlockProgramBlock> program,
    required final BlockProgramCursor cursor,
    final bool running,
    final int? currentStepBlockIndex,
    final int attempts,
    final int lastRunBlocksUsed,
    final BlockProgramGameplayEffect? pendingEffect,
  }) = _$BlockProgramGameplayStateImpl;

  @override
  BlockProgramLevel get level;
  @override
  List<BlockProgramBlock> get program;
  @override
  BlockProgramCursor get cursor;
  @override
  bool get running;
  @override
  int? get currentStepBlockIndex;
  @override
  int get attempts;
  @override
  int get lastRunBlocksUsed;
  @override
  BlockProgramGameplayEffect? get pendingEffect;

  /// Create a copy of BlockProgramGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockProgramGameplayStateImplCopyWith<_$BlockProgramGameplayStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BlockProgramGameplayEffect {
  Object get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BlockProgramVictoryData data) navigateToVictory,
    required TResult Function(BlockProgramFailureData data) navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BlockProgramVictoryData data)? navigateToVictory,
    TResult? Function(BlockProgramFailureData data)? navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BlockProgramVictoryData data)? navigateToVictory,
    TResult Function(BlockProgramFailureData data)? navigateToFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NavigateToBlockProgramVictory value)
    navigateToVictory,
    required TResult Function(NavigateToBlockProgramFailure value)
    navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToBlockProgramVictory value)? navigateToVictory,
    TResult? Function(NavigateToBlockProgramFailure value)? navigateToFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToBlockProgramVictory value)? navigateToVictory,
    TResult Function(NavigateToBlockProgramFailure value)? navigateToFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockProgramGameplayEffectCopyWith<$Res> {
  factory $BlockProgramGameplayEffectCopyWith(
    BlockProgramGameplayEffect value,
    $Res Function(BlockProgramGameplayEffect) then,
  ) =
      _$BlockProgramGameplayEffectCopyWithImpl<
        $Res,
        BlockProgramGameplayEffect
      >;
}

/// @nodoc
class _$BlockProgramGameplayEffectCopyWithImpl<
  $Res,
  $Val extends BlockProgramGameplayEffect
>
    implements $BlockProgramGameplayEffectCopyWith<$Res> {
  _$BlockProgramGameplayEffectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockProgramGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NavigateToBlockProgramVictoryImplCopyWith<$Res> {
  factory _$$NavigateToBlockProgramVictoryImplCopyWith(
    _$NavigateToBlockProgramVictoryImpl value,
    $Res Function(_$NavigateToBlockProgramVictoryImpl) then,
  ) = __$$NavigateToBlockProgramVictoryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BlockProgramVictoryData data});
}

/// @nodoc
class __$$NavigateToBlockProgramVictoryImplCopyWithImpl<$Res>
    extends
        _$BlockProgramGameplayEffectCopyWithImpl<
          $Res,
          _$NavigateToBlockProgramVictoryImpl
        >
    implements _$$NavigateToBlockProgramVictoryImplCopyWith<$Res> {
  __$$NavigateToBlockProgramVictoryImplCopyWithImpl(
    _$NavigateToBlockProgramVictoryImpl _value,
    $Res Function(_$NavigateToBlockProgramVictoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlockProgramGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$NavigateToBlockProgramVictoryImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as BlockProgramVictoryData,
      ),
    );
  }
}

/// @nodoc

class _$NavigateToBlockProgramVictoryImpl
    implements NavigateToBlockProgramVictory {
  const _$NavigateToBlockProgramVictoryImpl({required this.data});

  @override
  final BlockProgramVictoryData data;

  @override
  String toString() {
    return 'BlockProgramGameplayEffect.navigateToVictory(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigateToBlockProgramVictoryImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of BlockProgramGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigateToBlockProgramVictoryImplCopyWith<
    _$NavigateToBlockProgramVictoryImpl
  >
  get copyWith =>
      __$$NavigateToBlockProgramVictoryImplCopyWithImpl<
        _$NavigateToBlockProgramVictoryImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BlockProgramVictoryData data) navigateToVictory,
    required TResult Function(BlockProgramFailureData data) navigateToFailure,
  }) {
    return navigateToVictory(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BlockProgramVictoryData data)? navigateToVictory,
    TResult? Function(BlockProgramFailureData data)? navigateToFailure,
  }) {
    return navigateToVictory?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BlockProgramVictoryData data)? navigateToVictory,
    TResult Function(BlockProgramFailureData data)? navigateToFailure,
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
    required TResult Function(NavigateToBlockProgramVictory value)
    navigateToVictory,
    required TResult Function(NavigateToBlockProgramFailure value)
    navigateToFailure,
  }) {
    return navigateToVictory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToBlockProgramVictory value)? navigateToVictory,
    TResult? Function(NavigateToBlockProgramFailure value)? navigateToFailure,
  }) {
    return navigateToVictory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToBlockProgramVictory value)? navigateToVictory,
    TResult Function(NavigateToBlockProgramFailure value)? navigateToFailure,
    required TResult orElse(),
  }) {
    if (navigateToVictory != null) {
      return navigateToVictory(this);
    }
    return orElse();
  }
}

abstract class NavigateToBlockProgramVictory
    implements BlockProgramGameplayEffect {
  const factory NavigateToBlockProgramVictory({
    required final BlockProgramVictoryData data,
  }) = _$NavigateToBlockProgramVictoryImpl;

  @override
  BlockProgramVictoryData get data;

  /// Create a copy of BlockProgramGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigateToBlockProgramVictoryImplCopyWith<
    _$NavigateToBlockProgramVictoryImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NavigateToBlockProgramFailureImplCopyWith<$Res> {
  factory _$$NavigateToBlockProgramFailureImplCopyWith(
    _$NavigateToBlockProgramFailureImpl value,
    $Res Function(_$NavigateToBlockProgramFailureImpl) then,
  ) = __$$NavigateToBlockProgramFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BlockProgramFailureData data});
}

/// @nodoc
class __$$NavigateToBlockProgramFailureImplCopyWithImpl<$Res>
    extends
        _$BlockProgramGameplayEffectCopyWithImpl<
          $Res,
          _$NavigateToBlockProgramFailureImpl
        >
    implements _$$NavigateToBlockProgramFailureImplCopyWith<$Res> {
  __$$NavigateToBlockProgramFailureImplCopyWithImpl(
    _$NavigateToBlockProgramFailureImpl _value,
    $Res Function(_$NavigateToBlockProgramFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlockProgramGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$NavigateToBlockProgramFailureImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as BlockProgramFailureData,
      ),
    );
  }
}

/// @nodoc

class _$NavigateToBlockProgramFailureImpl
    implements NavigateToBlockProgramFailure {
  const _$NavigateToBlockProgramFailureImpl({required this.data});

  @override
  final BlockProgramFailureData data;

  @override
  String toString() {
    return 'BlockProgramGameplayEffect.navigateToFailure(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigateToBlockProgramFailureImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of BlockProgramGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigateToBlockProgramFailureImplCopyWith<
    _$NavigateToBlockProgramFailureImpl
  >
  get copyWith =>
      __$$NavigateToBlockProgramFailureImplCopyWithImpl<
        _$NavigateToBlockProgramFailureImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BlockProgramVictoryData data) navigateToVictory,
    required TResult Function(BlockProgramFailureData data) navigateToFailure,
  }) {
    return navigateToFailure(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BlockProgramVictoryData data)? navigateToVictory,
    TResult? Function(BlockProgramFailureData data)? navigateToFailure,
  }) {
    return navigateToFailure?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BlockProgramVictoryData data)? navigateToVictory,
    TResult Function(BlockProgramFailureData data)? navigateToFailure,
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
    required TResult Function(NavigateToBlockProgramVictory value)
    navigateToVictory,
    required TResult Function(NavigateToBlockProgramFailure value)
    navigateToFailure,
  }) {
    return navigateToFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToBlockProgramVictory value)? navigateToVictory,
    TResult? Function(NavigateToBlockProgramFailure value)? navigateToFailure,
  }) {
    return navigateToFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToBlockProgramVictory value)? navigateToVictory,
    TResult Function(NavigateToBlockProgramFailure value)? navigateToFailure,
    required TResult orElse(),
  }) {
    if (navigateToFailure != null) {
      return navigateToFailure(this);
    }
    return orElse();
  }
}

abstract class NavigateToBlockProgramFailure
    implements BlockProgramGameplayEffect {
  const factory NavigateToBlockProgramFailure({
    required final BlockProgramFailureData data,
  }) = _$NavigateToBlockProgramFailureImpl;

  @override
  BlockProgramFailureData get data;

  /// Create a copy of BlockProgramGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigateToBlockProgramFailureImplCopyWith<
    _$NavigateToBlockProgramFailureImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
