import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/audio/audio_providers.dart';
import '../../../../core/progress/record_level_win_usecase.dart';
import '../../../../game/game_result.dart';
import '../../../../game/program_executor.dart';
import '../../../../game/scoring.dart';
import '../../../../models/block.dart';
import '../../../../models/level.dart';
import 'gameplay_state.dart';

part 'gameplay_view_model.g.dart';

/// ViewModel da Gameplay do Mundo 1 — família por `levelId` (não pelo objeto
/// `Level`, que não tem `==`/`hashCode` de valor). Orquestra a Execução
/// (`ProgramExecutor`) passo a passo, incluindo o timing da animação (mesmo
/// lugar de antes, dentro de `_run()`/`_goToResultScreen` do antigo
/// `GameplayScreen`) — a View só renderiza `state` e reage a
/// `state.pendingEffect` via `ref.listen`.
@riverpod
class GameplayViewModel extends _$GameplayViewModel {
  // `Ref.mounted` não existe nesta versão de riverpod — mesmo padrão de
  // `ProgressNotifier._disposed`.
  bool _disposed = false;

  late final ProgramExecutor _executor;

  /// Do momento em que a fase abre até a vitória — inclui tentativas falhas
  /// (o ViewModel não é recriado entre "Tentar de novo" e a próxima
  /// tentativa, só a View pode ser). Usado só para o Placar do Dia, nunca
  /// mostrado na UI — ver `.claude/docs/GAME_DESIGN.md`.
  final Stopwatch _levelStopwatch = Stopwatch()..start();

  static const _stepDuration = Duration(milliseconds: 460);

  /// Flash mais curto para o bloco condicional de resgate
  /// (`rescueIfCharacterHere`) quando ele anda mas não resgata ninguém — a
  /// casa de destino não tinha personagem (ou já tinha sido resgatada
  /// antes). Sem isso, esse bloco ficava destacado pela mesma duração de um
  /// passo que resgatou de verdade, sem nenhum sinal de "andei e não tinha
  /// ninguém aqui" (mesmo achado do UX Reviewer já aplicado à antiga Placa
  /// e ao Mundo 4). Ver `.claude/memory/decisions.md`, entrada de
  /// 2026-09-18.
  static const _noEffectFlashDuration = Duration(milliseconds: 250);
  static const _startDelay = Duration(milliseconds: 200);

  /// Pausa curta depois do último passo (vitória ou falha) antes de navegar
  /// — só para o jogador ver onde o mascote parou antes da troca de tela.
  static const _resultPause = Duration(milliseconds: 500);

  @override
  GameplayState build(String levelId) {
    ref.onDispose(() => _disposed = true);
    // Os Mundos 1 ("Primeiros passos"), 2 ("Resgate de Personagens") e 3
    // ("Desenho no Tabuleiro") compartilham este motor/`Level` (todos
    // `WorldGameType.maze`) — ver `.claude/memory/decisions.md`, entrada de
    // 2026-09-18.
    final level = [...world1Levels, ...world2Levels, ...world3Levels].firstWhere((l) => l.id == levelId);
    _executor = ProgramExecutor(level);
    return GameplayState(level: level, cursor: GameCursor.fromStart(level));
  }

  void addBlock(BlockType type) {
    if (state.running || state.program.length >= state.level.maxBlocks) return;
    state = state.copyWith(program: [...state.program, Block(type)]);
  }

  void removeBlockAt(int index) {
    if (state.running) return;
    state = state.copyWith(program: [...state.program]..removeAt(index));
  }

  void clearProgram() {
    if (state.running) return;
    state = state.copyWith(program: const [], cursor: GameCursor.fromStart(state.level), currentStepBlockIndex: null);
  }

  /// Chamado pela View depois de consumir `state.pendingEffect`, pra não
  /// repetir a navegação num rebuild seguinte.
  void clearEffect() => state = state.copyWith(pendingEffect: null);

  Future<void> run() async {
    if (state.running || state.program.isEmpty) return;
    final steps = _executor.expand(state.program);

    state = state.copyWith(
      running: true,
      currentStepBlockIndex: null,
      cursor: GameCursor.fromStart(state.level),
      attempts: state.attempts + 1,
      lastRunBlocksUsed: state.program.length,
    );
    ref.read(appSoundsProvider).run();

    await Future.delayed(_startDelay);

    for (final step in steps) {
      if (_disposed) return;
      final cursorBefore = state.cursor;
      final outcome = _executor.applyStep(cursorBefore, step.type);
      final isRescueBlock = step.type == BlockType.rescueIfCharacterHere;
      // Bloco condicional de resgate: sempre move o cursor (mesma regra de
      // colisão de `walk`) — só "resgatou de verdade" se a contagem de
      // personagens mudou; senão a casa de destino não tinha personagem
      // (ou já tinha sido resgatado antes nesta Execução). Nunca é falha
      // (ver `ProgramExecutor.applyStep`).
      final rescueHappened = isRescueBlock && outcome.cursor.collectedCount != cursorBefore.collectedCount;

      if (step.type == BlockType.walk || isRescueBlock) {
        ref.read(appSoundsProvider).walk();
      } else if (step.type == BlockType.turnLeft || step.type == BlockType.turnRight) {
        ref.read(appSoundsProvider).turn();
      }

      if (outcome.crashed) {
        state = state.copyWith(running: false, currentStepBlockIndex: step.blockIndex);
        await _resolveOutcome(GameOutcome.crash);
        return;
      }

      state = state.copyWith(cursor: outcome.cursor, currentStepBlockIndex: step.blockIndex);
      final wasNoOp = isRescueBlock && !rescueHappened;
      await Future.delayed(wasNoOp ? _noEffectFlashDuration : _stepDuration);
    }

    if (_disposed) return;
    final finalOutcome = _executor.evaluateFinal(state.cursor);
    state = state.copyWith(running: false, currentStepBlockIndex: null);
    await _resolveOutcome(finalOutcome);
  }

  /// Monta o efeito de navegação (Vitória ou Falha) assim que a Execução
  /// termina — sem modal/overlay intermediário no tabuleiro, mesmo
  /// comportamento do antigo `_goToResultScreen`.
  Future<void> _resolveOutcome(GameOutcome outcome) async {
    await Future.delayed(_resultPause);
    if (_disposed) return;

    // Captura os valores finais ANTES de resetar o cursor abaixo — só
    // Mundo 2 ("Resgate de Personagens") usa `collectedCount`/
    // `collectTarget`, só Mundo 3 ("Desenho no Tabuleiro") usa a diferença
    // entre `paintedTiles`/`paintTarget` — capturar sempre é inofensivo
    // (fica 0/null nos outros mundos).
    final collectedCount = state.cursor.collectedCount;
    final collectTarget = state.level.collectTarget;
    final paintTarget = state.level.paintTarget;
    final missingPaintCount = paintTarget == null ? 0 : paintTarget.difference(state.cursor.paintedTiles).length;
    final extraPaintCount = paintTarget == null ? 0 : state.cursor.paintedTiles.difference(paintTarget).length;

    // Deixa o tabuleiro pronto para a próxima tentativa (mascote de volta ao
    // início) para quando o jogador voltar via "Tentar de novo".
    state = state.copyWith(cursor: GameCursor.fromStart(state.level));

    if (outcome == GameOutcome.win) {
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

      final levelsInWorld = world.levels.cast<Level>();
      final levelIndex = levelsInWorld.indexWhere((l) => l.id == level.id);
      final nextLevel = (levelIndex >= 0 && levelIndex + 1 < levelsInWorld.length) ? levelsInWorld[levelIndex + 1] : null;

      state = state.copyWith(
        pendingEffect: GameplayEffect.navigateToVictory(
          data: GameplayVictoryData(
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
        pendingEffect: GameplayEffect.navigateToFailure(
          data: GameplayFailureData(
            levelNumber: state.level.number,
            attempt: state.attempts,
            outcome: outcome,
            maxBlocks: state.level.maxBlocks,
            collectedCount: collectedCount,
            collectTarget: collectTarget,
            missingPaintCount: missingPaintCount,
            extraPaintCount: extraPaintCount,
          ),
        ),
      );
    }
  }
}
