import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/predict_output_level.dart';

part 'predict_output_gameplay_state.freezed.dart';

/// Estado da Gameplay do Mundo 3 ("Preveja a Saída") — veredito único por
/// tentativa (sem passo a passo/animação, diferente de Mundo 1/2): o
/// jogador escolhe uma opção e confirma.
@freezed
class PredictOutputGameplayState with _$PredictOutputGameplayState {
  const factory PredictOutputGameplayState({
    required PredictOutputLevel level,
    int? selectedOptionIndex,
    @Default(0) int attempts,
    PredictOutputGameplayEffect? pendingEffect,
  }) = _PredictOutputGameplayState;
}

/// Sinal de navegação de uma única vez — a `PredictOutputGameplayView`
/// consome via `ref.listen` e chama `clearEffect()` antes de navegar.
@freezed
sealed class PredictOutputGameplayEffect with _$PredictOutputGameplayEffect {
  const factory PredictOutputGameplayEffect.showResult({required PredictOutputResultData data}) = ShowPredictOutputResult;
}

/// Dados prontos pra montar a `CodePuzzleResultView` (reaproveitada — o
/// contrato de "veredito único" é o mesmo dos Mundos 4/5).
class PredictOutputResultData {
  final bool won;
  final int levelNumber;
  final int attempts;

  /// Só relevantes quando `won == true` (0 nos outros casos).
  final int stars;
  final int points;

  /// `PredictOutputLevel.explanation` — mostrada sempre (ganhou ou perdeu).
  final String explanationText;

  final int worldNumber;

  /// `null` quando esta era a última fase do Mundo.
  final PredictOutputLevel? nextLevel;

  /// `true` só na 1ª vez que o Mundo fica 100% completo.
  final bool worldJustCompleted;

  const PredictOutputResultData({
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
