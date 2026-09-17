import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../game/belt_executor.dart';
import '../../../../models/belt_block.dart';
import '../../../../models/conveyor_level.dart';

part 'conveyor_gameplay_state.freezed.dart';

/// Estado da Gameplay do Mundo 2 (Esteira) — mesma forma de `GameplayState`
/// (Mundo 1, `lib/features/maze/presentation/gameplay/gameplay_state.dart`),
/// trocando grid/`Block`/`GameCursor` por fila/`BeltBlock`/`BeltCursor`.
@freezed
class ConveyorGameplayState with _$ConveyorGameplayState {
  const factory ConveyorGameplayState({
    required ConveyorLevel level,
    @Default(<BeltBlock>[]) List<BeltBlock> program,
    required BeltCursor cursor,
    @Default(false) bool running,
    int? currentStepBlockIndex,
    @Default(0) int attempts,
    @Default(0) int lastRunBlocksUsed,
    ConveyorGameplayEffect? pendingEffect,
  }) = _ConveyorGameplayState;
}

/// Sinal de navegação de uma única vez — a `ConveyorGameplayView` consome
/// via `ref.listen` e chama `clearEffect()` antes de navegar.
@freezed
sealed class ConveyorGameplayEffect with _$ConveyorGameplayEffect {
  const factory ConveyorGameplayEffect.navigateToVictory({required ConveyorVictoryData data}) = NavigateToConveyorVictory;
  const factory ConveyorGameplayEffect.navigateToFailure({required ConveyorFailureData data}) = NavigateToConveyorFailure;
}

/// Dados prontos pra montar a `VictoryView` (reaproveitada do Mundo 1 — o
/// contrato de vitória "blocos usados vs. ótimo" é idêntico entre os dois
/// motores, ver `.claude/memory/decisions.md`).
class ConveyorVictoryData {
  final int levelNumber;
  final int blocksUsed;
  final int maxBlocks;
  final int optimalBlocks;
  final int worldNumber;

  /// `null` quando esta era a última fase do Mundo.
  final ConveyorLevel? nextLevel;

  /// `true` só na 1ª vez que o Mundo fica 100% completo.
  final bool worldJustCompleted;

  const ConveyorVictoryData({
    required this.levelNumber,
    required this.blocksUsed,
    required this.maxBlocks,
    required this.optimalBlocks,
    required this.worldNumber,
    required this.nextLevel,
    required this.worldJustCompleted,
  });
}

/// Dados prontos pra montar a `FailureView` (reaproveitada do Mundo 1).
class ConveyorFailureData {
  final int levelNumber;
  final int attempt;
  final BeltOutcome outcome;
  final int maxBlocks;

  const ConveyorFailureData({
    required this.levelNumber,
    required this.attempt,
    required this.outcome,
    required this.maxBlocks,
  });
}
