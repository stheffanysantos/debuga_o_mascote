// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnboardingState {
  Set<int> get seenWorldNumbers => throw _privateConstructorUsedError;
  Set<int> get seenRecapWorldNumbers => throw _privateConstructorUsedError;

  /// `true` depois que o jogador já viu o intro de boas-vindas (3 slides +
  /// escolha de conta) pelo menos uma vez, ao tocar "JOGAR" na Splash.
  bool get seenWelcome => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
    OnboardingState value,
    $Res Function(OnboardingState) then,
  ) = _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
  @useResult
  $Res call({
    Set<int> seenWorldNumbers,
    Set<int> seenRecapWorldNumbers,
    bool seenWelcome,
  });
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seenWorldNumbers = null,
    Object? seenRecapWorldNumbers = null,
    Object? seenWelcome = null,
  }) {
    return _then(
      _value.copyWith(
            seenWorldNumbers: null == seenWorldNumbers
                ? _value.seenWorldNumbers
                : seenWorldNumbers // ignore: cast_nullable_to_non_nullable
                      as Set<int>,
            seenRecapWorldNumbers: null == seenRecapWorldNumbers
                ? _value.seenRecapWorldNumbers
                : seenRecapWorldNumbers // ignore: cast_nullable_to_non_nullable
                      as Set<int>,
            seenWelcome: null == seenWelcome
                ? _value.seenWelcome
                : seenWelcome // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnboardingStateImplCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$$OnboardingStateImplCopyWith(
    _$OnboardingStateImpl value,
    $Res Function(_$OnboardingStateImpl) then,
  ) = __$$OnboardingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Set<int> seenWorldNumbers,
    Set<int> seenRecapWorldNumbers,
    bool seenWelcome,
  });
}

/// @nodoc
class __$$OnboardingStateImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingStateImpl>
    implements _$$OnboardingStateImplCopyWith<$Res> {
  __$$OnboardingStateImplCopyWithImpl(
    _$OnboardingStateImpl _value,
    $Res Function(_$OnboardingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seenWorldNumbers = null,
    Object? seenRecapWorldNumbers = null,
    Object? seenWelcome = null,
  }) {
    return _then(
      _$OnboardingStateImpl(
        seenWorldNumbers: null == seenWorldNumbers
            ? _value._seenWorldNumbers
            : seenWorldNumbers // ignore: cast_nullable_to_non_nullable
                  as Set<int>,
        seenRecapWorldNumbers: null == seenRecapWorldNumbers
            ? _value._seenRecapWorldNumbers
            : seenRecapWorldNumbers // ignore: cast_nullable_to_non_nullable
                  as Set<int>,
        seenWelcome: null == seenWelcome
            ? _value.seenWelcome
            : seenWelcome // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$OnboardingStateImpl extends _OnboardingState {
  const _$OnboardingStateImpl({
    final Set<int> seenWorldNumbers = const {},
    final Set<int> seenRecapWorldNumbers = const {},
    this.seenWelcome = false,
  }) : _seenWorldNumbers = seenWorldNumbers,
       _seenRecapWorldNumbers = seenRecapWorldNumbers,
       super._();

  final Set<int> _seenWorldNumbers;
  @override
  @JsonKey()
  Set<int> get seenWorldNumbers {
    if (_seenWorldNumbers is EqualUnmodifiableSetView) return _seenWorldNumbers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_seenWorldNumbers);
  }

  final Set<int> _seenRecapWorldNumbers;
  @override
  @JsonKey()
  Set<int> get seenRecapWorldNumbers {
    if (_seenRecapWorldNumbers is EqualUnmodifiableSetView)
      return _seenRecapWorldNumbers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_seenRecapWorldNumbers);
  }

  /// `true` depois que o jogador já viu o intro de boas-vindas (3 slides +
  /// escolha de conta) pelo menos uma vez, ao tocar "JOGAR" na Splash.
  @override
  @JsonKey()
  final bool seenWelcome;

  @override
  String toString() {
    return 'OnboardingState(seenWorldNumbers: $seenWorldNumbers, seenRecapWorldNumbers: $seenRecapWorldNumbers, seenWelcome: $seenWelcome)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStateImpl &&
            const DeepCollectionEquality().equals(
              other._seenWorldNumbers,
              _seenWorldNumbers,
            ) &&
            const DeepCollectionEquality().equals(
              other._seenRecapWorldNumbers,
              _seenRecapWorldNumbers,
            ) &&
            (identical(other.seenWelcome, seenWelcome) ||
                other.seenWelcome == seenWelcome));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_seenWorldNumbers),
    const DeepCollectionEquality().hash(_seenRecapWorldNumbers),
    seenWelcome,
  );

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      __$$OnboardingStateImplCopyWithImpl<_$OnboardingStateImpl>(
        this,
        _$identity,
      );
}

abstract class _OnboardingState extends OnboardingState {
  const factory _OnboardingState({
    final Set<int> seenWorldNumbers,
    final Set<int> seenRecapWorldNumbers,
    final bool seenWelcome,
  }) = _$OnboardingStateImpl;
  const _OnboardingState._() : super._();

  @override
  Set<int> get seenWorldNumbers;
  @override
  Set<int> get seenRecapWorldNumbers;

  /// `true` depois que o jogador já viu o intro de boas-vindas (3 slides +
  /// escolha de conta) pelo menos uma vez, ao tocar "JOGAR" na Splash.
  @override
  bool get seenWelcome;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
