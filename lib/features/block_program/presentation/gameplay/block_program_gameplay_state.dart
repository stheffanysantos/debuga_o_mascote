import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../game/block_program_executor.dart';
import '../../../../models/block_program_block.dart';
import '../../../../models/block_program_level.dart';

part 'block_program_gameplay_state.freezed.dart';

/// Estado da Gameplay dos Mundos 3/4 ("Programação em Blocos") — mesma forma
/// de `ConveyorGameplayState` (Mundo 2), trocando fila/`BeltBlock`/
/// `BeltCursor` por lista de números/`BlockProgramBlock`/
/// `BlockProgramCursor`. Um único par View/ViewModel serve os 2 mundos —
/// `level.world` decide quais blocos a paleta oferece (ver
/// `lib/widgets/block_program_chip_style.dart`).
@freezed
class BlockProgramGameplayState with _$BlockProgramGameplayState {
  const factory BlockProgramGameplayState({
    required BlockProgramLevel level,
    @Default(<BlockProgramBlock>[]) List<BlockProgramBlock> program,
    required BlockProgramCursor cursor,
    @Default(false) bool running,
    int? currentStepBlockIndex,
    @Default(0) int attempts,
    @Default(0) int lastRunBlocksUsed,
    BlockProgramGameplayEffect? pendingEffect,
  }) = _BlockProgramGameplayState;
}

/// Sinal de navegação de uma única vez — a `BlockProgramGameplayView`
/// consome via `ref.listen` e chama `clearEffect()` antes de navegar.
@freezed
sealed class BlockProgramGameplayEffect with _$BlockProgramGameplayEffect {
  const factory BlockProgramGameplayEffect.navigateToVictory({required BlockProgramVictoryData data}) = NavigateToBlockProgramVictory;
  const factory BlockProgramGameplayEffect.navigateToFailure({required BlockProgramFailureData data}) = NavigateToBlockProgramFailure;
}

/// Dados prontos pra montar a `VictoryView` (reaproveitada dos Mundos 1/2 —
/// o contrato de vitória "blocos usados vs. ótimo" é idêntico, ver
/// `.claude/memory/decisions.md`).
class BlockProgramVictoryData {
  final int levelNumber;
  final int blocksUsed;
  final int maxBlocks;
  final int optimalBlocks;
  final int worldNumber;

  /// `null` quando esta era a última fase do Mundo.
  final BlockProgramLevel? nextLevel;

  /// `true` só na 1ª vez que o Mundo fica 100% completo.
  final bool worldJustCompleted;

  const BlockProgramVictoryData({
    required this.levelNumber,
    required this.blocksUsed,
    required this.maxBlocks,
    required this.optimalBlocks,
    required this.worldNumber,
    required this.nextLevel,
    required this.worldJustCompleted,
  });
}

/// Dados prontos pra montar a `FailureView` (reaproveitada dos Mundos 1/2).
/// `finalValue`/`targetValue`/`goal` (achado do UX Reviewer) permitem ao
/// motivo de falha dizer exatamente o que aconteceu (ex.: "Seu Total foi 12,
/// mas a fase pedia 10") em vez de um texto genérico — mesmo capturados
/// **antes** do cursor ser resetado pra próxima tentativa, ver
/// `BlockProgramGameplayViewModel._resolveOutcome`.
class BlockProgramFailureData {
  final int levelNumber;
  final int attempt;
  final BlockProgramOutcome outcome;
  final int maxBlocks;
  final int finalValue;
  final int targetValue;
  final BlockProgramGoal goal;

  const BlockProgramFailureData({
    required this.levelNumber,
    required this.attempt,
    required this.outcome,
    required this.maxBlocks,
    required this.finalValue,
    required this.targetValue,
    required this.goal,
  });
}
