import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/complete_code_level.dart';

part 'complete_code_gameplay_state.freezed.dart';

/// Estado da Gameplay do Mundo 6 ("Complete o Código") — mesma forma de
/// `PredictOutputGameplayState` (Mundo 5): veredito único por tentativa,
/// sem passo a passo.
@freezed
class CompleteCodeGameplayState with _$CompleteCodeGameplayState {
  const factory CompleteCodeGameplayState({
    required CompleteCodeLevel level,
    int? selectedOptionIndex,
    @Default(0) int attempts,
    CompleteCodeGameplayEffect? pendingEffect,
  }) = _CompleteCodeGameplayState;
}

/// Sinal de navegação de uma única vez — a `CompleteCodeGameplayView`
/// consome via `ref.listen` e chama `clearEffect()` antes de navegar.
@freezed
sealed class CompleteCodeGameplayEffect with _$CompleteCodeGameplayEffect {
  const factory CompleteCodeGameplayEffect.showResult({required CompleteCodeResultData data}) = ShowCompleteCodeResult;
}

/// Dados prontos pra montar a `CodePuzzleResultView` (reaproveitada — o
/// contrato de "veredito único" é o mesmo dos Mundos 3/5).
class CompleteCodeResultData {
  final bool won;
  final int levelNumber;
  final int attempts;

  /// Só relevantes quando `won == true` (0 nos outros casos).
  final int stars;
  final int points;

  /// `CompleteCodeLevel.explanation` — mostrada sempre (ganhou ou perdeu).
  final String explanationText;

  final int worldNumber;

  /// `null` quando esta era a última fase do Mundo.
  final CompleteCodeLevel? nextLevel;

  /// `true` só na 1ª vez que o Mundo fica 100% completo.
  final bool worldJustCompleted;

  const CompleteCodeResultData({
    required this.won,
    required this.levelNumber,
    required this.attempts,
    required this.stars,
    required this.points,
    required this.explanationText,
    required this.worldNumber,
    required this.nextLevel,
    required this.worldJustCompleted,
  });
}
