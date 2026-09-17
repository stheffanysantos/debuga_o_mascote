import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/progress/record_level_win_usecase.dart';
import '../../../../game/code_puzzle_scoring.dart';
import '../../../../models/complete_code_level.dart';
import '../../../../models/level.dart';
import 'complete_code_gameplay_state.dart';

part 'complete_code_gameplay_view_model.g.dart';

/// ViewModel da Gameplay do Mundo 4 ("Complete o Código") — mesma forma de
/// `PredictOutputGameplayViewModel` (Mundo 3): sem passo a passo, cada
/// `confirm()` é um veredito único. Família por `levelId`.
@riverpod
class CompleteCodeGameplayViewModel extends _$CompleteCodeGameplayViewModel {
  final Stopwatch _levelStopwatch = Stopwatch()..start();

  @override
  CompleteCodeGameplayState build(String levelId) {
    final level = world4Levels.firstWhere((l) => l.id == levelId);
    return CompleteCodeGameplayState(level: level);
  }

  void selectOption(int index) => state = state.copyWith(selectedOptionIndex: index);

  void clearEffect() => state = state.copyWith(pendingEffect: null);

  /// Chamado pela View depois que a tela de Resultado de uma derrota fecha
  /// — mesmo cuidado de `PredictOutputGameplayViewModel`.
  void clearSelectionAfterLoss() => state = state.copyWith(selectedOptionIndex: null);

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
      final result = ref.read(recordLevelWinUseCaseProvider).call(
            levelId: level.id,
            world: world,
            score: score,
            blocksUsedOrAttempts: attempts,
            elapsedSeconds: _levelStopwatch.elapsed.inSeconds,
          );
      worldJustCompleted = result.worldJustCompleted;
    }

    final levelsInWorld = world.levels.cast<CompleteCodeLevel>();
    final levelIndex = levelsInWorld.indexWhere((l) => l.id == level.id);
    final nextLevel = (levelIndex >= 0 && levelIndex + 1 < levelsInWorld.length) ? levelsInWorld[levelIndex + 1] : null;

    state = state.copyWith(
      pendingEffect: CompleteCodeGameplayEffect.showResult(
        data: CompleteCodeResultData(
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
