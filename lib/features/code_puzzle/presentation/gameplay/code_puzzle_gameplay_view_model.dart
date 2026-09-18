import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/progress/record_level_win_usecase.dart';
import '../../../../game/code_puzzle_checker.dart';
import '../../../../game/code_puzzle_scoring.dart';
import '../../../../models/code_line.dart';
import '../../../../models/code_puzzle_level.dart';
import '../../../../models/level.dart';
import 'code_puzzle_gameplay_state.dart';

part 'code_puzzle_gameplay_view_model.g.dart';

/// ViewModel da Gameplay do Mundo 7 ("Modo Debug") — mesma forma de
/// `PredictOutputGameplayViewModel`/`CompleteCodeGameplayViewModel`: sem
/// passo a passo, cada `confirm()` é um veredito único. Família por
/// `levelId`.
@riverpod
class CodePuzzleGameplayViewModel extends _$CodePuzzleGameplayViewModel {
  final Stopwatch _levelStopwatch = Stopwatch()..start();

  /// `correctOrder` embaralhado uma única vez por fase, com seed fixa a
  /// partir do `id` (não re-embaralha a cada rebuild) — o modelo
  /// (`CodePuzzleLevel`) nunca guarda uma ordem embaralhada fixa. Vazio em
  /// fases `findBug`.
  late final List<CodeLine> shuffledLines;

  @override
  CodePuzzleGameplayState build(String levelId) {
    final level = world7Levels.firstWhere((l) => l.id == levelId);
    shuffledLines = List<CodeLine>.of(level.correctOrder)..shuffle(Random(level.id.hashCode));
    return CodePuzzleGameplayState(level: level);
  }

  bool get canConfirm {
    switch (state.level.type) {
      case CodePuzzleType.reorder:
        return state.sequenceIndices.length == state.level.correctOrder.length;
      case CodePuzzleType.findBug:
        return state.selectedLineIndex != null;
    }
  }

  void addToSequence(int shuffledIndex) {
    if (state.sequenceIndices.contains(shuffledIndex)) return;
    state = state.copyWith(sequenceIndices: [...state.sequenceIndices, shuffledIndex]);
  }

  void removeFromSequence(int shuffledIndex) {
    state = state.copyWith(sequenceIndices: [...state.sequenceIndices]..remove(shuffledIndex));
  }

  void selectLine(int index) => state = state.copyWith(selectedLineIndex: index);

  void clearEffect() => state = state.copyWith(pendingEffect: null);

  /// Chamado pela View depois que a tela de Resultado de uma derrota fecha
  /// — sem isso, o jogador podia apertar Confirmar de novo sem perceber que
  /// precisava mudar a resposta (achado do UX Reviewer).
  void clearSelectionAfterLoss() => state = state.copyWith(selectedLineIndex: null, sequenceIndices: const []);

  /// Chamado pela View quando o jogador toca o ícone de "jogar de novo" na
  /// tela de Vitória (`CodePuzzleResultView._buildWon`) — esse atalho faz
  /// só um `pop()` de volta para esta mesma instância/provider (não recria
  /// a fase do zero, ver `.claude/memory/decisions.md`, "Bug real
  /// corrigido: `attempts` não resetava..."), então sem este reset
  /// explícito `attempts` continuaria acumulando indefinidamente entre
  /// replays rápidos, mesmo o jogador acertando de primeira em cada um.
  /// Reseta para exatamente o estado que `build()` produziria —
  /// `shuffledLines` continua o mesmo (seed fixa por `levelId`, não
  /// depende do estado).
  void resetForReplay() => state = CodePuzzleGameplayState(level: state.level);

  bool _checkWon() {
    switch (state.level.type) {
      case CodePuzzleType.reorder:
        final attempt = [for (final i in state.sequenceIndices) shuffledLines[i]];
        return checkReorder(attempt, state.level.correctOrder, groupOf: state.level.groupOf);
      case CodePuzzleType.findBug:
        return checkFindBug(state.selectedLineIndex!, state.level.buggyLineIndex);
    }
  }

  void confirm() {
    if (!canConfirm) return;

    final level = state.level;
    final isReorder = level.type == CodePuzzleType.reorder;
    final won = _checkWon();
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
      // `blocksUsedOrAttempts` aqui guarda Tentativas, não blocos — o Mundo
      // 5 não tem conceito de "blocos" (motor de veredito único). Ver
      // `.claude/memory/decisions.md`.
      final result = ref.read(recordLevelWinUseCaseProvider).call(
            levelId: level.id,
            world: world,
            score: score,
            blocksUsedOrAttempts: attempts,
            elapsedSeconds: _levelStopwatch.elapsed.inSeconds,
          );
      worldJustCompleted = result.worldJustCompleted;
    }

    // Em findBug a explicação é mostrada sempre (ganhou ou perdeu); em
    // reorder não existe (o "porquê" é a própria ordem certa, mostrada só
    // na Dica quando o jogador erra).
    final explanationText = isReorder ? null : level.bugExplanation;
    final correctOrder = (!won && isReorder) ? level.correctOrder : null;

    final levelsInWorld = world.levels.cast<CodePuzzleLevel>();
    final levelIndex = levelsInWorld.indexWhere((l) => l.id == level.id);
    final nextLevel = (levelIndex >= 0 && levelIndex + 1 < levelsInWorld.length) ? levelsInWorld[levelIndex + 1] : null;

    state = state.copyWith(
      pendingEffect: CodePuzzleGameplayEffect.showResult(
        data: CodePuzzleGameplayResultData(
          won: won,
          levelNumber: level.number,
          attempts: attempts,
          stars: stars,
          points: points,
          explanationText: explanationText,
          correctOrder: correctOrder,
          worldNumber: level.world,
          nextLevel: nextLevel,
          worldJustCompleted: worldJustCompleted,
        ),
      ),
    );
  }
}
