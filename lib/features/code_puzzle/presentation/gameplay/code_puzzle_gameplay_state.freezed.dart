// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'code_puzzle_gameplay_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CodePuzzleGameplayState {
  CodePuzzleLevel get level => throw _privateConstructorUsedError;

  /// Índices (em `CodePuzzleGameplayViewModel.shuffledLines`) já tocados
  /// para montar a sequência, na ordem em que o jogador tocou — só usado
  /// em fases `reorder`.
  List<int> get sequenceIndices => throw _privateConstructorUsedError;

  /// Linha tocada como "essa é a errada" — só usado em fases `findBug`.
  int? get selectedLineIndex => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  CodePuzzleGameplayEffect? get pendingEffect =>
      throw _privateConstructorUsedError;

  /// Create a copy of CodePuzzleGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CodePuzzleGameplayStateCopyWith<CodePuzzleGameplayState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CodePuzzleGameplayStateCopyWith<$Res> {
  factory $CodePuzzleGameplayStateCopyWith(
    CodePuzzleGameplayState value,
    $Res Function(CodePuzzleGameplayState) then,
  ) = _$CodePuzzleGameplayStateCopyWithImpl<$Res, CodePuzzleGameplayState>;
  @useResult
  $Res call({
    CodePuzzleLevel level,
    List<int> sequenceIndices,
    int? selectedLineIndex,
    int attempts,
    CodePuzzleGameplayEffect? pendingEffect,
  });

  $CodePuzzleGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class _$CodePuzzleGameplayStateCopyWithImpl<
  $Res,
  $Val extends CodePuzzleGameplayState
>
    implements $CodePuzzleGameplayStateCopyWith<$Res> {
  _$CodePuzzleGameplayStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CodePuzzleGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? sequenceIndices = null,
    Object? selectedLineIndex = freezed,
    Object? attempts = null,
    Object? pendingEffect = freezed,
  }) {
    return _then(
      _value.copyWith(
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as CodePuzzleLevel,
            sequenceIndices: null == sequenceIndices
                ? _value.sequenceIndices
                : sequenceIndices // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            selectedLineIndex: freezed == selectedLineIndex
                ? _value.selectedLineIndex
                : selectedLineIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
            attempts: null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingEffect: freezed == pendingEffect
                ? _value.pendingEffect
                : pendingEffect // ignore: cast_nullable_to_non_nullable
                      as CodePuzzleGameplayEffect?,
          )
          as $Val,
    );
  }

  /// Create a copy of CodePuzzleGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CodePuzzleGameplayEffectCopyWith<$Res>? get pendingEffect {
    if (_value.pendingEffect == null) {
      return null;
    }

    return $CodePuzzleGameplayEffectCopyWith<$Res>(_value.pendingEffect!, (
      value,
    ) {
      return _then(_value.copyWith(pendingEffect: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CodePuzzleGameplayStateImplCopyWith<$Res>
    implements $CodePuzzleGameplayStateCopyWith<$Res> {
  factory _$$CodePuzzleGameplayStateImplCopyWith(
    _$CodePuzzleGameplayStateImpl value,
    $Res Function(_$CodePuzzleGameplayStateImpl) then,
  ) = __$$CodePuzzleGameplayStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CodePuzzleLevel level,
    List<int> sequenceIndices,
    int? selectedLineIndex,
    int attempts,
    CodePuzzleGameplayEffect? pendingEffect,
  });

  @override
  $CodePuzzleGameplayEffectCopyWith<$Res>? get pendingEffect;
}

/// @nodoc
class __$$CodePuzzleGameplayStateImplCopyWithImpl<$Res>
    extends
        _$CodePuzzleGameplayStateCopyWithImpl<
          $Res,
          _$CodePuzzleGameplayStateImpl
        >
    implements _$$CodePuzzleGameplayStateImplCopyWith<$Res> {
  __$$CodePuzzleGameplayStateImplCopyWithImpl(
    _$CodePuzzleGameplayStateImpl _value,
    $Res Function(_$CodePuzzleGameplayStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CodePuzzleGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? sequenceIndices = null,
    Object? selectedLineIndex = freezed,
    Object? attempts = null,
    Object? pendingEffect = freezed,
  }) {
    return _then(
      _$CodePuzzleGameplayStateImpl(
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as CodePuzzleLevel,
        sequenceIndices: null == sequenceIndices
            ? _value._sequenceIndices
            : sequenceIndices // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        selectedLineIndex: freezed == selectedLineIndex
            ? _value.selectedLineIndex
            : selectedLineIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
        attempts: null == attempts
            ? _value.attempts
            : attempts // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingEffect: freezed == pendingEffect
            ? _value.pendingEffect
            : pendingEffect // ignore: cast_nullable_to_non_nullable
                  as CodePuzzleGameplayEffect?,
      ),
    );
  }
}

/// @nodoc

class _$CodePuzzleGameplayStateImpl implements _CodePuzzleGameplayState {
  const _$CodePuzzleGameplayStateImpl({
    required this.level,
    final List<int> sequenceIndices = const <int>[],
    this.selectedLineIndex,
    this.attempts = 0,
    this.pendingEffect,
  }) : _sequenceIndices = sequenceIndices;

  @override
  final CodePuzzleLevel level;

  /// Índices (em `CodePuzzleGameplayViewModel.shuffledLines`) já tocados
  /// para montar a sequência, na ordem em que o jogador tocou — só usado
  /// em fases `reorder`.
  final List<int> _sequenceIndices;

  /// Índices (em `CodePuzzleGameplayViewModel.shuffledLines`) já tocados
  /// para montar a sequência, na ordem em que o jogador tocou — só usado
  /// em fases `reorder`.
  @override
  @JsonKey()
  List<int> get sequenceIndices {
    if (_sequenceIndices is EqualUnmodifiableListView) return _sequenceIndices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sequenceIndices);
  }

  /// Linha tocada como "essa é a errada" — só usado em fases `findBug`.
  @override
  final int? selectedLineIndex;
  @override
  @JsonKey()
  final int attempts;
  @override
  final CodePuzzleGameplayEffect? pendingEffect;

  @override
  String toString() {
    return 'CodePuzzleGameplayState(level: $level, sequenceIndices: $sequenceIndices, selectedLineIndex: $selectedLineIndex, attempts: $attempts, pendingEffect: $pendingEffect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CodePuzzleGameplayStateImpl &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality().equals(
              other._sequenceIndices,
              _sequenceIndices,
            ) &&
            (identical(other.selectedLineIndex, selectedLineIndex) ||
                other.selectedLineIndex == selectedLineIndex) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.pendingEffect, pendingEffect) ||
                other.pendingEffect == pendingEffect));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    level,
    const DeepCollectionEquality().hash(_sequenceIndices),
    selectedLineIndex,
    attempts,
    pendingEffect,
  );

  /// Create a copy of CodePuzzleGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CodePuzzleGameplayStateImplCopyWith<_$CodePuzzleGameplayStateImpl>
  get copyWith =>
      __$$CodePuzzleGameplayStateImplCopyWithImpl<
        _$CodePuzzleGameplayStateImpl
      >(this, _$identity);
}

abstract class _CodePuzzleGameplayState implements CodePuzzleGameplayState {
  const factory _CodePuzzleGameplayState({
    required final CodePuzzleLevel level,
    final List<int> sequenceIndices,
    final int? selectedLineIndex,
    final int attempts,
    final CodePuzzleGameplayEffect? pendingEffect,
  }) = _$CodePuzzleGameplayStateImpl;

  @override
  CodePuzzleLevel get level;

  /// Índices (em `CodePuzzleGameplayViewModel.shuffledLines`) já tocados
  /// para montar a sequência, na ordem em que o jogador tocou — só usado
  /// em fases `reorder`.
  @override
  List<int> get sequenceIndices;

  /// Linha tocada como "essa é a errada" — só usado em fases `findBug`.
  @override
  int? get selectedLineIndex;
  @override
  int get attempts;
  @override
  CodePuzzleGameplayEffect? get pendingEffect;

  /// Create a copy of CodePuzzleGameplayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CodePuzzleGameplayStateImplCopyWith<_$CodePuzzleGameplayStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CodePuzzleGameplayEffect {
  CodePuzzleGameplayResultData get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CodePuzzleGameplayResultData data) showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CodePuzzleGameplayResultData data)? showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CodePuzzleGameplayResultData data)? showResult,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShowCodePuzzleGameplayResult value) showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShowCodePuzzleGameplayResult value)? showResult,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShowCodePuzzleGameplayResult value)? showResult,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of CodePuzzleGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CodePuzzleGameplayEffectCopyWith<CodePuzzleGameplayEffect> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CodePuzzleGameplayEffectCopyWith<$Res> {
  factory $CodePuzzleGameplayEffectCopyWith(
    CodePuzzleGameplayEffect value,
    $Res Function(CodePuzzleGameplayEffect) then,
  ) = _$CodePuzzleGameplayEffectCopyWithImpl<$Res, CodePuzzleGameplayEffect>;
  @useResult
  $Res call({CodePuzzleGameplayResultData data});
}

/// @nodoc
class _$CodePuzzleGameplayEffectCopyWithImpl<
  $Res,
  $Val extends CodePuzzleGameplayEffect
>
    implements $CodePuzzleGameplayEffectCopyWith<$Res> {
  _$CodePuzzleGameplayEffectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CodePuzzleGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as CodePuzzleGameplayResultData,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShowCodePuzzleGameplayResultImplCopyWith<$Res>
    implements $CodePuzzleGameplayEffectCopyWith<$Res> {
  factory _$$ShowCodePuzzleGameplayResultImplCopyWith(
    _$ShowCodePuzzleGameplayResultImpl value,
    $Res Function(_$ShowCodePuzzleGameplayResultImpl) then,
  ) = __$$ShowCodePuzzleGameplayResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CodePuzzleGameplayResultData data});
}

/// @nodoc
class __$$ShowCodePuzzleGameplayResultImplCopyWithImpl<$Res>
    extends
        _$CodePuzzleGameplayEffectCopyWithImpl<
          $Res,
          _$ShowCodePuzzleGameplayResultImpl
        >
    implements _$$ShowCodePuzzleGameplayResultImplCopyWith<$Res> {
  __$$ShowCodePuzzleGameplayResultImplCopyWithImpl(
    _$ShowCodePuzzleGameplayResultImpl _value,
    $Res Function(_$ShowCodePuzzleGameplayResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CodePuzzleGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$ShowCodePuzzleGameplayResultImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as CodePuzzleGameplayResultData,
      ),
    );
  }
}

/// @nodoc

class _$ShowCodePuzzleGameplayResultImpl
    implements ShowCodePuzzleGameplayResult {
  const _$ShowCodePuzzleGameplayResultImpl({required this.data});

  @override
  final CodePuzzleGameplayResultData data;

  @override
  String toString() {
    return 'CodePuzzleGameplayEffect.showResult(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShowCodePuzzleGameplayResultImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of CodePuzzleGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShowCodePuzzleGameplayResultImplCopyWith<
    _$ShowCodePuzzleGameplayResultImpl
  >
  get copyWith =>
      __$$ShowCodePuzzleGameplayResultImplCopyWithImpl<
        _$ShowCodePuzzleGameplayResultImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CodePuzzleGameplayResultData data) showResult,
  }) {
    return showResult(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CodePuzzleGameplayResultData data)? showResult,
  }) {
    return showResult?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CodePuzzleGameplayResultData data)? showResult,
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
    required TResult Function(ShowCodePuzzleGameplayResult value) showResult,
  }) {
    return showResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShowCodePuzzleGameplayResult value)? showResult,
  }) {
    return showResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShowCodePuzzleGameplayResult value)? showResult,
    required TResult orElse(),
  }) {
    if (showResult != null) {
      return showResult(this);
    }
    return orElse();
  }
}

abstract class ShowCodePuzzleGameplayResult
    implements CodePuzzleGameplayEffect {
  const factory ShowCodePuzzleGameplayResult({
    required final CodePuzzleGameplayResultData data,
  }) = _$ShowCodePuzzleGameplayResultImpl;

  @override
  CodePuzzleGameplayResultData get data;

  /// Create a copy of CodePuzzleGameplayEffect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShowCodePuzzleGameplayResultImplCopyWith<
    _$ShowCodePuzzleGameplayResultImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
