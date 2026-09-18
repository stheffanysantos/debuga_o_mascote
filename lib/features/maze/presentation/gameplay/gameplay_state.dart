import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../game/game_result.dart';
import '../../../../game/program_executor.dart';
import '../../../../models/block.dart';
import '../../../../models/level.dart';

part 'gameplay_state.freezed.dart';

/// Estado da Gameplay do Mundo 1 (labirinto) — vertical de referência da
/// migração pra Riverpod/MVVM (ver
/// `C:\Users\XProcess\.claude\plans\encapsulated-whistling-peach.md`, seção
/// 3). `cursor`/cada campo espelham os antigos campos privados de
/// `_GameplayScreenState`.
@freezed
class GameplayState with _$GameplayState {
  const factory GameplayState({
    required Level level,
    @Default(<Block>[]) List<Block> program,
    required GameCursor cursor,
    @Default(false) bool running,
    int? currentStepBlockIndex,
    @Default(0) int attempts,
    @Default(0) int lastRunBlocksUsed,
    GameplayEffect? pendingEffect,
  }) = _GameplayState;
}

/// Sinal de navegação de uma única vez — a `GameplayView` consome via
/// `ref.listen` e chama `clearEffect()` antes de navegar, pra não repetir a
/// navegação num rebuild seguinte.
@freezed
sealed class GameplayEffect with _$GameplayEffect {
  const factory GameplayEffect.navigateToVictory({required GameplayVictoryData data}) = NavigateToVictory;
  const factory GameplayEffect.navigateToFailure({required GameplayFailureData data}) = NavigateToFailure;
}

/// Dados prontos pra montar a `VictoryView` — quem monta a tela (a View) não
/// recalcula nada, só lê estes campos.
class GameplayVictoryData {
  final int levelNumber;
  final int blocksUsed;
  final int maxBlocks;
  final int optimalBlocks;
  final int worldNumber;

  /// `null` quando esta era a última fase do Mundo.
  final Level? nextLevel;

  /// `true` só na 1ª vez que o Mundo fica 100% completo (não num replay da
  /// última fase já concluída) — decide se a recapitulação de fim de Mundo
  /// aparece antes de voltar pra Seleção de Fases.
  final bool worldJustCompleted;

  const GameplayVictoryData({
    required this.levelNumber,
    required this.blocksUsed,
    required this.maxBlocks,
    required this.optimalBlocks,
    required this.worldNumber,
    required this.nextLevel,
    required this.worldJustCompleted,
  });
}

/// Dados prontos pra montar a `FailureView`. `collectedCount`/
/// `collectTarget` só têm valor real em `GameOutcome.wrongCollectCount`
/// (Mundo 2, "Resgate de Personagens"); `missingPaintCount`/
/// `extraPaintCount` só em `GameOutcome.wrongPaintPattern` (Mundo 3,
/// "Desenho no Tabuleiro") — nos outros mundos/motivos ficam em `0`/`null`
/// e não são usados pelo texto do motivo (ver `_reasonTextFor`).
class GameplayFailureData {
  final int levelNumber;
  final int attempt;
  final GameOutcome outcome;
  final int maxBlocks;
  final int collectedCount;
  final int? collectTarget;

  /// Quantas células do desenho-alvo (`Level.paintTarget`) ainda faltavam
  /// ser pintadas quando o mascote chegou no alvo.
  final int missingPaintCount;

  /// Quantas células pintadas ficaram fora do desenho-alvo.
  final int extraPaintCount;

  const GameplayFailureData({
    required this.levelNumber,
    required this.attempt,
    required this.outcome,
    required this.maxBlocks,
    this.collectedCount = 0,
    this.collectTarget,
    this.missingPaintCount = 0,
    this.extraPaintCount = 0,
  });
}
