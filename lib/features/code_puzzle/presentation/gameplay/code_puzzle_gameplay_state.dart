import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/code_line.dart';
import '../../../../models/code_puzzle_level.dart';

part 'code_puzzle_gameplay_state.freezed.dart';

/// Estado da Gameplay do Mundo 7 ("Modo Debug") — veredito único por
/// tentativa (sem passo a passo), alternando entre `reorder`/`findBug`
/// conforme `level.type`.
@freezed
class CodePuzzleGameplayState with _$CodePuzzleGameplayState {
  const factory CodePuzzleGameplayState({
    required CodePuzzleLevel level,

    /// Índices (em `CodePuzzleGameplayViewModel.shuffledLines`) já tocados
    /// para montar a sequência, na ordem em que o jogador tocou — só usado
    /// em fases `reorder`.
    @Default(<int>[]) List<int> sequenceIndices,

    /// Linha tocada como "essa é a errada" — só usado em fases `findBug`.
    int? selectedLineIndex,
    @Default(0) int attempts,
    CodePuzzleGameplayEffect? pendingEffect,
  }) = _CodePuzzleGameplayState;
}

/// Sinal de navegação de uma única vez — a `CodePuzzleGameplayView` consome
/// via `ref.listen` e chama `clearEffect()` antes de navegar.
@freezed
sealed class CodePuzzleGameplayEffect with _$CodePuzzleGameplayEffect {
  const factory CodePuzzleGameplayEffect.showResult({required CodePuzzleGameplayResultData data}) = ShowCodePuzzleGameplayResult;
}

/// Dados prontos pra montar a `CodePuzzleResultView`. `correctOrder` (não
/// os `Widget`s já montados) — quem constrói os chips é a View, o
/// ViewModel não monta `Widget`.
class CodePuzzleGameplayResultData {
  final bool won;
  final int levelNumber;
  final int attempts;

  /// Só relevantes quando `won == true` (0 nos outros casos).
  final int stars;
  final int points;

  /// `CodePuzzleLevel.bugExplanation` — mostrada sempre (ganhou ou perdeu)
  /// quando a fase é `findBug`; `null` quando é `reorder`.
  final String? explanationText;

  /// A ordem certa da fase como "Dica" — só quando perdeu um `reorder`.
  final List<CodeLine>? correctOrder;

  final int worldNumber;

  /// `null` quando esta era a última fase do Mundo.
  final CodePuzzleLevel? nextLevel;

  /// `true` só na 1ª vez que o Mundo fica 100% completo.
  final bool worldJustCompleted;

  const CodePuzzleGameplayResultData({
    required this.won,
    required this.levelNumber,
    required this.attempts,
    required this.stars,
    required this.points,
    this.explanationText,
    this.correctOrder,
    required this.worldNumber,
    required this.nextLevel,
    required this.worldJustCompleted,
  });
}
