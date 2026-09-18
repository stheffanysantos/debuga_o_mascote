import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/progress/record_level_win_usecase.dart';
import '../../../../game/code_puzzle_scoring.dart';
import '../../../../models/level.dart';
import '../../../../models/predict_output_level.dart';
import 'predict_output_gameplay_state.dart';

part 'predict_output_gameplay_view_model.g.dart';

/// ViewModel da Gameplay do Mundo 3 ("Preveja a Saída") — sem passo a passo
/// (diferente de `GameplayViewModel`/`ConveyorGameplayViewModel`): cada
/// `confirm()` é um veredito único, calculado na hora a partir da opção
/// escolhida. Família por `levelId`.
@riverpod
class PredictOutputGameplayViewModel extends _$PredictOutputGameplayViewModel {
  /// Mesmo motivo/uso de `_levelStopwatch` em `GameplayViewModel` (Mundo 1)
  /// — só para o Placar do Dia, nunca mostrado na UI.
  final Stopwatch _levelStopwatch = Stopwatch()..start();

  @override
  PredictOutputGameplayState build(String levelId) {
    final level = world3Levels.firstWhere((l) => l.id == levelId);
    return PredictOutputGameplayState(level: level);
  }

  void selectOption(int index) => state = state.copyWith(selectedOptionIndex: index);

  void clearEffect() => state = state.copyWith(pendingEffect: null);

  /// Chamado pela View depois que a tela de Resultado de uma derrota fecha
  /// — sem isso, o jogador podia apertar Confirmar de novo sem perceber que
  /// precisava mudar a resposta (achado do UX Reviewer).
  void clearSelectionAfterLoss() => state = state.copyWith(selectedOptionIndex: null);

  /// Chamado pela View quando o jogador toca o ícone de "jogar de novo" na
  /// tela de Vitória (`CodePuzzleResultView._buildWon`) — esse atalho faz
  /// só um `pop()` de volta para esta mesma instância/provider (não recria
  /// a fase do zero, ver `.claude/memory/decisions.md`, "Bug real
  /// corrigido: `attempts` não resetava..."), então sem este reset
  /// explícito `attempts` continuaria acumulando indefinidamente entre
  /// replays rápidos, mesmo o jogador acertando de primeira em cada um.
  /// Reseta para exatamente o estado que `build()` produziria.
  void resetForReplay() => state = PredictOutputGameplayState(level: state.level);

  void confirm() {
    final selected = state.selectedOptionIndex;
    if (selected == null) return;

    final level = state.level;
    final won = selected == level.correctOptionIndex;
    final attempts = state.attempts + 1;
    state = state.copyWith(attempts: attempts);

    var stars = 0;
    var points = 0;
    var worldJustCompleted = false;
    final world = worlds.firstWhere((w) => w.number == level.world);
    if (won) {
      final score = computeCodePuzzleScore(attempts: attempts);
      stars = score.stars;
      points = score.points;
      // `blocksUsedOrAttempts` aqui guarda Tentativas, não blocos — mesmo
      // reaproveitamento já usado nos Mundos 4/5 (ver
      // `.claude/memory/decisions.md`).
      final result = ref.read(recordLevelWinUseCaseProvider).call(
            levelId: level.id,
            world: world,
            score: score,
            blocksUsedOrAttempts: attempts,
            elapsedSeconds: _levelStopwatch.elapsed.inSeconds,
          );
      worldJustCompleted = result.worldJustCompleted;
    }

    final levelsInWorld = world.levels.cast<PredictOutputLevel>();
    final levelIndex = levelsInWorld.indexWhere((l) => l.id == level.id);
    final nextLevel = (levelIndex >= 0 && levelIndex + 1 < levelsInWorld.length) ? levelsInWorld[levelIndex + 1] : null;

    state = state.copyWith(
      pendingEffect: PredictOutputGameplayEffect.showResult(
        data: PredictOutputResultData(
          won: won,
          levelNumber: level.number,
          attempts: attempts,
          stars: stars,
          points: points,
          explanationText: level.explanation,
          worldNumber: level.world,
          nextLevel: nextLevel,
          worldJustCompleted: worldJustCompleted,
        ),
      ),
    );
  }
}
