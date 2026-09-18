// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProgressState {
  Map<String, LevelProgress> get byLevelId =>
      throw _privateConstructorUsedError;

  /// Pontuação acumulada nesta sessão para o Placar do Dia — separada do
  /// "PONTOS" por fase (`LevelProgress` não guarda isso).
  int get sessionScore => throw _privateConstructorUsedError;

  /// `true` depois que o jogador já enviou a pontuação desta sessão pro
  /// Placar (`SurveyScreen`).
  bool get hasSubmittedToLeaderboard => throw _privateConstructorUsedError;

  /// Idade/"já programou antes?" respondidas na Pesquisa — guardadas aqui
  /// (não só usadas na hora) pra `LeaderboardSyncService` poder reenviar a
  /// entrada do Placar sozinho a cada vitória nova, sem pedir de novo.
  int? get surveyAge => throw _privateConstructorUsedError;
  bool? get surveyHasProgrammedBefore => throw _privateConstructorUsedError;

  /// `true` depois que o jogador completa 100% das fases dos 7 Mundos
  /// (`isGameCompleted`) — usado pra tirá-lo do Placar Geral e colocá-lo na
  /// lista separada de quem zerou o jogo (`LeaderboardEntry.gameCompleted`,
  /// ver `.claude/memory/decisions.md`).
  bool get gameCompleted => throw _privateConstructorUsedError;

  /// Quando `gameCompleted` virou `true` pela 1ª vez — guardado (não
  /// recalculado a cada sincronização) pra lista de quem zerou poder
  /// ordenar por quem terminou primeiro.
  DateTime? get gameCompletedAt => throw _privateConstructorUsedError;

  /// Nome de exibição escolhido pelo jogador em `ProfileEditView` — `null`
  /// enquanto ele não editou nada, caso em que o Placar Geral/UI usam o
  /// nome da conta (`AuthService.displayName`) como antes.
  String? get username => throw _privateConstructorUsedError;

  /// Id de `CharacterAvatar` (`lib/models/character_avatar.dart`) escolhido
  /// em `ProfileEditView` — `null` enquanto ele não editou nada. Ver
  /// `displayAvatarId` abaixo.
  String? get avatarId => throw _privateConstructorUsedError;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressStateCopyWith<ProgressState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressStateCopyWith<$Res> {
  factory $ProgressStateCopyWith(
    ProgressState value,
    $Res Function(ProgressState) then,
  ) = _$ProgressStateCopyWithImpl<$Res, ProgressState>;
  @useResult
  $Res call({
    Map<String, LevelProgress> byLevelId,
    int sessionScore,
    bool hasSubmittedToLeaderboard,
    int? surveyAge,
    bool? surveyHasProgrammedBefore,
    bool gameCompleted,
    DateTime? gameCompletedAt,
    String? username,
    String? avatarId,
  });
}

/// @nodoc
class _$ProgressStateCopyWithImpl<$Res, $Val extends ProgressState>
    implements $ProgressStateCopyWith<$Res> {
  _$ProgressStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byLevelId = null,
    Object? sessionScore = null,
    Object? hasSubmittedToLeaderboard = null,
    Object? surveyAge = freezed,
    Object? surveyHasProgrammedBefore = freezed,
    Object? gameCompleted = null,
    Object? gameCompletedAt = freezed,
    Object? username = freezed,
    Object? avatarId = freezed,
  }) {
    return _then(
      _value.copyWith(
            byLevelId: null == byLevelId
                ? _value.byLevelId
                : byLevelId // ignore: cast_nullable_to_non_nullable
                      as Map<String, LevelProgress>,
            sessionScore: null == sessionScore
                ? _value.sessionScore
                : sessionScore // ignore: cast_nullable_to_non_nullable
                      as int,
            hasSubmittedToLeaderboard: null == hasSubmittedToLeaderboard
                ? _value.hasSubmittedToLeaderboard
                : hasSubmittedToLeaderboard // ignore: cast_nullable_to_non_nullable
                      as bool,
            surveyAge: freezed == surveyAge
                ? _value.surveyAge
                : surveyAge // ignore: cast_nullable_to_non_nullable
                      as int?,
            surveyHasProgrammedBefore: freezed == surveyHasProgrammedBefore
                ? _value.surveyHasProgrammedBefore
                : surveyHasProgrammedBefore // ignore: cast_nullable_to_non_nullable
                      as bool?,
            gameCompleted: null == gameCompleted
                ? _value.gameCompleted
                : gameCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            gameCompletedAt: freezed == gameCompletedAt
                ? _value.gameCompletedAt
                : gameCompletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarId: freezed == avatarId
                ? _value.avatarId
                : avatarId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgressStateImplCopyWith<$Res>
    implements $ProgressStateCopyWith<$Res> {
  factory _$$ProgressStateImplCopyWith(
    _$ProgressStateImpl value,
    $Res Function(_$ProgressStateImpl) then,
  ) = __$$ProgressStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, LevelProgress> byLevelId,
    int sessionScore,
    bool hasSubmittedToLeaderboard,
    int? surveyAge,
    bool? surveyHasProgrammedBefore,
    bool gameCompleted,
    DateTime? gameCompletedAt,
    String? username,
    String? avatarId,
  });
}

/// @nodoc
class __$$ProgressStateImplCopyWithImpl<$Res>
    extends _$ProgressStateCopyWithImpl<$Res, _$ProgressStateImpl>
    implements _$$ProgressStateImplCopyWith<$Res> {
  __$$ProgressStateImplCopyWithImpl(
    _$ProgressStateImpl _value,
    $Res Function(_$ProgressStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byLevelId = null,
    Object? sessionScore = null,
    Object? hasSubmittedToLeaderboard = null,
    Object? surveyAge = freezed,
    Object? surveyHasProgrammedBefore = freezed,
    Object? gameCompleted = null,
    Object? gameCompletedAt = freezed,
    Object? username = freezed,
    Object? avatarId = freezed,
  }) {
    return _then(
      _$ProgressStateImpl(
        byLevelId: null == byLevelId
            ? _value._byLevelId
            : byLevelId // ignore: cast_nullable_to_non_nullable
                  as Map<String, LevelProgress>,
        sessionScore: null == sessionScore
            ? _value.sessionScore
            : sessionScore // ignore: cast_nullable_to_non_nullable
                  as int,
        hasSubmittedToLeaderboard: null == hasSubmittedToLeaderboard
            ? _value.hasSubmittedToLeaderboard
            : hasSubmittedToLeaderboard // ignore: cast_nullable_to_non_nullable
                  as bool,
        surveyAge: freezed == surveyAge
            ? _value.surveyAge
            : surveyAge // ignore: cast_nullable_to_non_nullable
                  as int?,
        surveyHasProgrammedBefore: freezed == surveyHasProgrammedBefore
            ? _value.surveyHasProgrammedBefore
            : surveyHasProgrammedBefore // ignore: cast_nullable_to_non_nullable
                  as bool?,
        gameCompleted: null == gameCompleted
            ? _value.gameCompleted
            : gameCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        gameCompletedAt: freezed == gameCompletedAt
            ? _value.gameCompletedAt
            : gameCompletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarId: freezed == avatarId
            ? _value.avatarId
            : avatarId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ProgressStateImpl extends _ProgressState {
  const _$ProgressStateImpl({
    final Map<String, LevelProgress> byLevelId = const {},
    this.sessionScore = 0,
    this.hasSubmittedToLeaderboard = false,
    this.surveyAge,
    this.surveyHasProgrammedBefore,
    this.gameCompleted = false,
    this.gameCompletedAt,
    this.username,
    this.avatarId,
  }) : _byLevelId = byLevelId,
       super._();

  final Map<String, LevelProgress> _byLevelId;
  @override
  @JsonKey()
  Map<String, LevelProgress> get byLevelId {
    if (_byLevelId is EqualUnmodifiableMapView) return _byLevelId;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byLevelId);
  }

  /// Pontuação acumulada nesta sessão para o Placar do Dia — separada do
  /// "PONTOS" por fase (`LevelProgress` não guarda isso).
  @override
  @JsonKey()
  final int sessionScore;

  /// `true` depois que o jogador já enviou a pontuação desta sessão pro
  /// Placar (`SurveyScreen`).
  @override
  @JsonKey()
  final bool hasSubmittedToLeaderboard;

  /// Idade/"já programou antes?" respondidas na Pesquisa — guardadas aqui
  /// (não só usadas na hora) pra `LeaderboardSyncService` poder reenviar a
  /// entrada do Placar sozinho a cada vitória nova, sem pedir de novo.
  @override
  final int? surveyAge;
  @override
  final bool? surveyHasProgrammedBefore;

  /// `true` depois que o jogador completa 100% das fases dos 7 Mundos
  /// (`isGameCompleted`) — usado pra tirá-lo do Placar Geral e colocá-lo na
  /// lista separada de quem zerou o jogo (`LeaderboardEntry.gameCompleted`,
  /// ver `.claude/memory/decisions.md`).
  @override
  @JsonKey()
  final bool gameCompleted;

  /// Quando `gameCompleted` virou `true` pela 1ª vez — guardado (não
  /// recalculado a cada sincronização) pra lista de quem zerou poder
  /// ordenar por quem terminou primeiro.
  @override
  final DateTime? gameCompletedAt;

  /// Nome de exibição escolhido pelo jogador em `ProfileEditView` — `null`
  /// enquanto ele não editou nada, caso em que o Placar Geral/UI usam o
  /// nome da conta (`AuthService.displayName`) como antes.
  @override
  final String? username;

  /// Id de `CharacterAvatar` (`lib/models/character_avatar.dart`) escolhido
  /// em `ProfileEditView` — `null` enquanto ele não editou nada. Ver
  /// `displayAvatarId` abaixo.
  @override
  final String? avatarId;

  @override
  String toString() {
    return 'ProgressState(byLevelId: $byLevelId, sessionScore: $sessionScore, hasSubmittedToLeaderboard: $hasSubmittedToLeaderboard, surveyAge: $surveyAge, surveyHasProgrammedBefore: $surveyHasProgrammedBefore, gameCompleted: $gameCompleted, gameCompletedAt: $gameCompletedAt, username: $username, avatarId: $avatarId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressStateImpl &&
            const DeepCollectionEquality().equals(
              other._byLevelId,
              _byLevelId,
            ) &&
            (identical(other.sessionScore, sessionScore) ||
                other.sessionScore == sessionScore) &&
            (identical(
                  other.hasSubmittedToLeaderboard,
                  hasSubmittedToLeaderboard,
                ) ||
                other.hasSubmittedToLeaderboard == hasSubmittedToLeaderboard) &&
            (identical(other.surveyAge, surveyAge) ||
                other.surveyAge == surveyAge) &&
            (identical(
                  other.surveyHasProgrammedBefore,
                  surveyHasProgrammedBefore,
                ) ||
                other.surveyHasProgrammedBefore == surveyHasProgrammedBefore) &&
            (identical(other.gameCompleted, gameCompleted) ||
                other.gameCompleted == gameCompleted) &&
            (identical(other.gameCompletedAt, gameCompletedAt) ||
                other.gameCompletedAt == gameCompletedAt) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatarId, avatarId) ||
                other.avatarId == avatarId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_byLevelId),
    sessionScore,
    hasSubmittedToLeaderboard,
    surveyAge,
    surveyHasProgrammedBefore,
    gameCompleted,
    gameCompletedAt,
    username,
    avatarId,
  );

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressStateImplCopyWith<_$ProgressStateImpl> get copyWith =>
      __$$ProgressStateImplCopyWithImpl<_$ProgressStateImpl>(this, _$identity);
}

abstract class _ProgressState extends ProgressState {
  const factory _ProgressState({
    final Map<String, LevelProgress> byLevelId,
    final int sessionScore,
    final bool hasSubmittedToLeaderboard,
    final int? surveyAge,
    final bool? surveyHasProgrammedBefore,
    final bool gameCompleted,
    final DateTime? gameCompletedAt,
    final String? username,
    final String? avatarId,
  }) = _$ProgressStateImpl;
  const _ProgressState._() : super._();

  @override
  Map<String, LevelProgress> get byLevelId;

  /// Pontuação acumulada nesta sessão para o Placar do Dia — separada do
  /// "PONTOS" por fase (`LevelProgress` não guarda isso).
  @override
  int get sessionScore;

  /// `true` depois que o jogador já enviou a pontuação desta sessão pro
  /// Placar (`SurveyScreen`).
  @override
  bool get hasSubmittedToLeaderboard;

  /// Idade/"já programou antes?" respondidas na Pesquisa — guardadas aqui
  /// (não só usadas na hora) pra `LeaderboardSyncService` poder reenviar a
  /// entrada do Placar sozinho a cada vitória nova, sem pedir de novo.
  @override
  int? get surveyAge;
  @override
  bool? get surveyHasProgrammedBefore;

  /// `true` depois que o jogador completa 100% das fases dos 7 Mundos
  /// (`isGameCompleted`) — usado pra tirá-lo do Placar Geral e colocá-lo na
  /// lista separada de quem zerou o jogo (`LeaderboardEntry.gameCompleted`,
  /// ver `.claude/memory/decisions.md`).
  @override
  bool get gameCompleted;

  /// Quando `gameCompleted` virou `true` pela 1ª vez — guardado (não
  /// recalculado a cada sincronização) pra lista de quem zerou poder
  /// ordenar por quem terminou primeiro.
  @override
  DateTime? get gameCompletedAt;

  /// Nome de exibição escolhido pelo jogador em `ProfileEditView` — `null`
  /// enquanto ele não editou nada, caso em que o Placar Geral/UI usam o
  /// nome da conta (`AuthService.displayName`) como antes.
  @override
  String? get username;

  /// Id de `CharacterAvatar` (`lib/models/character_avatar.dart`) escolhido
  /// em `ProfileEditView` — `null` enquanto ele não editou nada. Ver
  /// `displayAvatarId` abaixo.
  @override
  String? get avatarId;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressStateImplCopyWith<_$ProgressStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
