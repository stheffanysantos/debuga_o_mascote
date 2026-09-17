import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/character_avatar.dart';
import '../../models/game_track.dart';
import '../../models/progress.dart';

part 'progress_state.freezed.dart';

/// Progresso do jogador — estado imutável exposto por `ProgressNotifier`
/// (`progress_notifier.dart`). Sincronizado com o Firestore
/// (`players/{uid}`, anônimo ou cadastrado) por `FirestoreProgressRepository`
/// — ver `.claude/memory/decisions.md`.
@freezed
class ProgressState with _$ProgressState {
  const factory ProgressState({
    @Default({}) Map<String, LevelProgress> byLevelId,

    /// Pontuação acumulada nesta sessão para o Placar do Dia — separada do
    /// "PONTOS" por fase (`LevelProgress` não guarda isso).
    @Default(0) int sessionScore,

    /// `true` depois que o jogador já enviou a pontuação desta sessão pro
    /// Placar (`SurveyScreen`).
    @Default(false) bool hasSubmittedToLeaderboard,

    /// Idade/"já programou antes?" respondidas na Pesquisa — guardadas aqui
    /// (não só usadas na hora) pra `LeaderboardSyncService` poder reenviar a
    /// entrada do Placar sozinho a cada vitória nova, sem pedir de novo.
    int? surveyAge,
    bool? surveyHasProgrammedBefore,

    /// `true` depois que o jogador completa 100% das fases dos 5 Mundos
    /// (`isGameCompleted`) — usado pra tirá-lo do Placar Geral e colocá-lo na
    /// lista separada de quem zerou o jogo (`LeaderboardEntry.gameCompleted`,
    /// ver `.claude/memory/decisions.md`).
    @Default(false) bool gameCompleted,

    /// Quando `gameCompleted` virou `true` pela 1ª vez — guardado (não
    /// recalculado a cada sincronização) pra lista de quem zerou poder
    /// ordenar por quem terminou primeiro.
    DateTime? gameCompletedAt,

    /// Nome de exibição escolhido pelo jogador em `ProfileEditView` — `null`
    /// enquanto ele não editou nada, caso em que o Placar Geral/UI usam o
    /// nome da conta (`AuthService.displayName`) como antes.
    String? username,

    /// Id de `CharacterAvatar` (`lib/models/character_avatar.dart`) escolhido
    /// em `ProfileEditView` — `null` enquanto ele não editou nada. Ver
    /// `displayAvatarId` abaixo.
    String? avatarId,
  }) = _ProgressState;

  const ProgressState._();

  /// `avatarId` sempre resolvido pra um id válido — nunca `null`, mesmo antes
  /// do jogador escolher um avatar (cai no personagem padrão do jogo, ver
  /// `lib/models/character_avatar.dart`).
  String get displayAvatarId => avatarId ?? defaultAvatarId;

  LevelProgress? forLevel(String levelId) => byLevelId[levelId];

  bool isCompleted(String levelId) => byLevelId.containsKey(levelId);

  int starsFor(String levelId) => byLevelId[levelId]?.stars ?? 0;

  int totalStars(Iterable<String> levelIds) => levelIds.fold(0, (sum, id) => sum + starsFor(id));

  /// Soma dos melhores pontos (`LevelProgress.bestPoints`) já obtidos em
  /// `levelIds` — usado para desbloquear o próximo Mundo dentro da mesma
  /// Trilha sem exigir 100% das fases (ver
  /// `WorldSelectView._isWorldUnlocked`/`.claude/memory/decisions.md`).
  int totalPoints(Iterable<String> levelIds) => levelIds.fold(0, (sum, id) => sum + (byLevelId[id]?.bestPoints ?? 0));

  /// `true` quando toda fase de `levelIds` já foi concluída — usado tanto
  /// para destravar o próximo Mundo quanto para decidir se acabou de
  /// completar o Mundo atual pela primeira vez (recapitulação de fim de
  /// mundo, ver `.claude/memory/decisions.md`).
  bool isWorldCompleted(Iterable<String> levelIds) => levelIds.every(isCompleted);

  /// Trilha inteira completa — todos os seus Mundos com 100% das fases
  /// concluídas. Usado para saber quando exigir cadastro (ver
  /// `.claude/memory/decisions.md`). Migrado de `lib/models/game_track.dart`
  /// (`isTrackCompleted`), que ficava acoplado a `Progress.instance` — um
  /// arquivo de modelo (Dart puro) não pode depender de estado do Riverpod.
  bool isTrackCompleted(GameTrack track) =>
      track.worlds.every((w) => isWorldCompleted(w.levels.map((l) => l.id)));

  /// `true` quando **todas** as Trilhas (`tracks`, `lib/models/game_track.dart`)
  /// estão 100% completas — "zerar o jogo". Usado por
  /// `RecordLevelWinUseCase` pra saber quando marcar `gameCompleted` e tirar
  /// o jogador do Placar Geral (ver `.claude/memory/decisions.md`).
  bool isGameCompleted() => tracks.every(isTrackCompleted);

  /// Mescla este estado com `other` (o progresso salvo de uma conta,
  /// buscado do Firestore em `ProgressNotifier._hydrate`) — nunca descarta
  /// progresso de nenhum dos dois lados. Precisa existir porque um jogador
  /// pode jogar sem conta num aparelho (progresso local, UID anônimo) e
  /// depois logar numa conta que já tem progresso salvo de **outro**
  /// aparelho — sem isso, `_hydrate` simplesmente substituía `state` pelo
  /// que veio do Firestore, perdendo tudo que foi jogado localmente antes
  /// do login (achado real do usuário, ver `.claude/memory/decisions.md`).
  ///
  /// Por fase: fica com o melhor resultado (mais estrelas, menos blocos,
  /// mais pontos) — mesmo critério que `ProgressNotifier.recordWin` já usa
  /// quando a mesma fase é vencida duas vezes na mesma conta. Pontuação de
  /// sessão: fica com a maior das duas (nunca soma, pra não inflar a
  /// pontuação artificialmente só por ter trocado de conta no meio do
  /// caminho). `hasSubmittedToLeaderboard`: vira `true` se qualquer um dos
  /// dois já tiver enviado (evita reabrir o convite pro Placar à toa).
  /// `surveyAge`/`surveyHasProgrammedBefore`: fica com o deste lado se
  /// preenchido, senão o de `other` (não há "melhor" resposta, só presença).
  /// `gameCompleted`: `true` se qualquer um dos dois já tiver zerado;
  /// `gameCompletedAt` fica com a data mais antiga não nula (quem zerou
  /// primeiro, entre os dois lados). `username`/`avatarId`: mesmo critério de
  /// "fica com o deste lado se preenchido, senão o de `other`" — não há
  /// "melhor" nome/avatar, só presença de uma escolha já feita.
  ProgressState mergedWith(ProgressState other) {
    final mergedByLevelId = <String, LevelProgress>{...byLevelId};
    for (final entry in other.byLevelId.entries) {
      final current = mergedByLevelId[entry.key];
      mergedByLevelId[entry.key] = current == null
          ? entry.value
          : LevelProgress(
              stars: current.stars > entry.value.stars ? current.stars : entry.value.stars,
              bestBlocks: current.bestBlocks < entry.value.bestBlocks ? current.bestBlocks : entry.value.bestBlocks,
              bestPoints: current.bestPoints > entry.value.bestPoints ? current.bestPoints : entry.value.bestPoints,
            );
    }
    DateTime? mergedCompletedAt;
    if (gameCompletedAt == null) {
      mergedCompletedAt = other.gameCompletedAt;
    } else if (other.gameCompletedAt == null) {
      mergedCompletedAt = gameCompletedAt;
    } else {
      mergedCompletedAt = gameCompletedAt!.isBefore(other.gameCompletedAt!) ? gameCompletedAt : other.gameCompletedAt;
    }
    return ProgressState(
      byLevelId: mergedByLevelId,
      sessionScore: sessionScore > other.sessionScore ? sessionScore : other.sessionScore,
      hasSubmittedToLeaderboard: hasSubmittedToLeaderboard || other.hasSubmittedToLeaderboard,
      surveyAge: surveyAge ?? other.surveyAge,
      surveyHasProgrammedBefore: surveyHasProgrammedBefore ?? other.surveyHasProgrammedBefore,
      gameCompleted: gameCompleted || other.gameCompleted,
      gameCompletedAt: mergedCompletedAt,
      username: username ?? other.username,
      avatarId: avatarId ?? other.avatarId,
    );
  }
}
