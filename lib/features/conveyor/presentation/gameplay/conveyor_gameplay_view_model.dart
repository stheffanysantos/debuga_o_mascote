import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/audio/audio_providers.dart';
import '../../../../core/progress/record_level_win_usecase.dart';
import '../../../../game/belt_executor.dart';
import '../../../../game/scoring.dart';
import '../../../../models/belt_block.dart';
import '../../../../models/conveyor_level.dart';
import '../../../../models/level.dart';
import 'conveyor_gameplay_state.dart';

part 'conveyor_gameplay_view_model.g.dart';

/// ViewModel da Gameplay do Mundo 2 (Esteira) — mesma forma de
/// `GameplayViewModel` (Mundo 1): família por `levelId`, orquestra a
/// Execução (`BeltExecutor`) passo a passo, incluindo o timing da animação.
/// A View só renderiza `state` e reage a `state.pendingEffect`.
@riverpod
class ConveyorGameplayViewModel extends _$ConveyorGameplayViewModel {
  // `Ref.mounted` não existe nesta versão de riverpod — mesmo padrão de
  // `ProgressNotifier._disposed`.
  bool _disposed = false;

  late final BeltExecutor _executor;

  final Stopwatch _levelStopwatch = Stopwatch()..start();

  // Mesmas durações de `GameplayViewModel` (Mundo 1) — mesma cadência de
  // Execução, só trocando "passo no grid" por "item classificado".
  static const _stepDuration = Duration(milliseconds: 460);
  static const _startDelay = Duration(milliseconds: 200);
  static const _resultPause = Duration(milliseconds: 500);

  /// Pausa curta quando um bloco `Enquanto` classifica zero Itens (a
  /// condição já começa falsa) — sem isso a Execução pulava direto pro
  /// próximo bloco sem nenhum sinal visual (achado do UX Reviewer). Mais
  /// curta que `_stepDuration` porque nada de fato acontece.
  static const _zeroMatchFlashDuration = Duration(milliseconds: 250);

  @override
  ConveyorGameplayState build(String levelId) {
    ref.onDispose(() => _disposed = true);
    final level = world2Levels.firstWhere((l) => l.id == levelId);
    _executor = BeltExecutor(level);
    return ConveyorGameplayState(level: level, cursor: BeltCursor.fromStart());
  }

  void addBlock(BeltBlockType type) {
    if (state.running || state.program.length >= state.level.maxBlocks) return;
    state = state.copyWith(program: [...state.program, BeltBlock(type)]);
  }

  void removeBlockAt(int index) {
    if (state.running) return;
    state = state.copyWith(program: [...state.program]..removeAt(index));
  }

  void clearProgram() {
    if (state.running) return;
    state = state.copyWith(program: const [], cursor: BeltCursor.fromStart(), currentStepBlockIndex: null);
  }

  void clearEffect() => state = state.copyWith(pendingEffect: null);

  Future<void> run() async {
    if (state.running || state.program.isEmpty) return;
    final steps = _executor.expand(state.program);

    state = state.copyWith(
      running: true,
      currentStepBlockIndex: null,
      cursor: BeltCursor.fromStart(),
      attempts: state.attempts + 1,
      lastRunBlocksUsed: state.program.length,
    );
    ref.read(appSoundsProvider).run();

    await Future.delayed(_startDelay);

    // Itera por bloco do Programa (não direto por `steps`) para conseguir
    // detectar blocos `Enquanto` que geraram zero passos (condição já
    // começa falsa) e dar um flash curto neles. `repeat` continua nunca
    // sendo destacado diretamente (só o bloco alvo que ele repete acende).
    var stepCursor = 0;
    for (var blockIndex = 0; blockIndex < state.program.length; blockIndex++) {
      if (_disposed) return;
      if (state.program[blockIndex].type == BeltBlockType.repeat) continue;

      var producedAnyStep = false;
      while (stepCursor < steps.length && steps[stepCursor].blockIndex == blockIndex) {
        producedAnyStep = true;
        final step = steps[stepCursor];
        stepCursor++;

        final outcome = _executor.applyStep(state.cursor, step.type);
        // Um som por item classificado — reaproveita `turn()` (mesmo
        // espírito de `.walk()`/`.turn()` do Mundo 1).
        ref.read(appSoundsProvider).turn();

        if (outcome.misclassified) {
          state = state.copyWith(running: false, currentStepBlockIndex: step.blockIndex);
          await _resolveOutcome(BeltOutcome.misclassified);
          return;
        }

        state = state.copyWith(cursor: outcome.cursor, currentStepBlockIndex: step.blockIndex);
        await Future.delayed(_stepDuration);
      }

      // Só `Enquanto` pode chegar aqui sem ter produzido nenhum passo (`Se`
      // sempre produz exatamente 1, `repeat` já foi pulado acima).
      if (!producedAnyStep) {
        if (_disposed) return;
        state = state.copyWith(currentStepBlockIndex: blockIndex);
        await Future.delayed(_zeroMatchFlashDuration);
      }
    }

    if (_disposed) return;
    final finalOutcome = _executor.evaluateFinal(state.cursor);
    state = state.copyWith(running: false, currentStepBlockIndex: null);
    await _resolveOutcome(finalOutcome);
  }

  /// Monta o efeito de navegação (Vitória ou Falha) assim que a Execução
  /// termina — sem modal/overlay intermediário na esteira.
  Future<void> _resolveOutcome(BeltOutcome outcome) async {
    await Future.delayed(_resultPause);
    if (_disposed) return;

    // Deixa a esteira pronta para a próxima tentativa (fila do começo) para
    // quando o jogador voltar via "Tentar de novo".
    state = state.copyWith(cursor: BeltCursor.fromStart());

    if (outcome == BeltOutcome.win) {
      final level = state.level;
      final world = worlds.firstWhere((w) => w.number == level.world);
      final score = computeScore(blocksUsed: state.lastRunBlocksUsed, optimalBlocks: level.optimalBlocks);

      final result = ref.read(recordLevelWinUseCaseProvider).call(
            levelId: level.id,
            world: world,
            score: score,
            blocksUsedOrAttempts: state.lastRunBlocksUsed,
            elapsedSeconds: _levelStopwatch.elapsed.inSeconds,
          );

      final levelsInWorld = world.levels.cast<ConveyorLevel>();
      final levelIndex = levelsInWorld.indexWhere((l) => l.id == level.id);
      final nextLevel = (levelIndex >= 0 && levelIndex + 1 < levelsInWorld.length) ? levelsInWorld[levelIndex + 1] : null;

      state = state.copyWith(
        pendingEffect: ConveyorGameplayEffect.navigateToVictory(
          data: ConveyorVictoryData(
            levelNumber: level.number,
            blocksUsed: state.lastRunBlocksUsed,
            maxBlocks: level.maxBlocks,
            optimalBlocks: level.optimalBlocks,
            worldNumber: level.world,
            nextLevel: nextLevel,
            worldJustCompleted: result.worldJustCompleted,
          ),
        ),
      );
    } else {
      state = state.copyWith(
        pendingEffect: ConveyorGameplayEffect.navigateToFailure(
          data: ConveyorFailureData(
            levelNumber: state.level.number,
            attempt: state.attempts,
            outcome: outcome,
            maxBlocks: state.level.maxBlocks,
          ),
        ),
      );
    }
  }
}
