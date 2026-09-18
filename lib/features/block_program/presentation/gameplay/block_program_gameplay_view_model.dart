import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/audio/audio_providers.dart';
import '../../../../core/progress/record_level_win_usecase.dart';
import '../../../../game/block_program_executor.dart';
import '../../../../game/scoring.dart';
import '../../../../models/block_program_block.dart';
import '../../../../models/block_program_level.dart';
import '../../../../models/level.dart';
import 'block_program_gameplay_state.dart';

part 'block_program_gameplay_view_model.g.dart';

/// ViewModel da Gameplay do Mundo 4 ("Decisões em Bloco") — família por
/// `levelId`, orquestra a Execução (`BlockProgramExecutor`) passo a passo,
/// incluindo o timing da animação. A View só renderiza `state` e reage a
/// `state.pendingEffect`. O mundo irmão original desta mecânica ("Oficina
/// de Blocos", sem condicionais) saiu do jogo — ver
/// `.claude/memory/decisions.md`, entrada de 2026-09-18 — então
/// `world4Levels` é hoje a única fonte de fases deste motor.
///
/// Diferente de `BeltExecutor` (Mundo 2), `BlockProgramExecutor` não tem
/// nenhuma falha por Passo (ver `.claude/docs/GAME_DESIGN.md`) — nem
/// "classificou errado", nem "zero Passos produzidos" (um "Para cada
/// número" sem bloco-alvo válido simplesmente não gera nenhum Passo, sem
/// precisar de um flash visual dedicado, diferente do "Enquanto" do Mundo
/// 2). Por isso o loop de execução aqui é mais simples: sempre percorre o
/// Programa por bloco, pulando só os modificadores `forEachNumber` (nunca
/// destacados diretamente — mesmo tratamento que `repeat` já recebe no
/// Mundo 2), e o único veredito é o resultado final
/// (`BlockProgramOutcome`).
@riverpod
class BlockProgramGameplayViewModel extends _$BlockProgramGameplayViewModel {
  // `Ref.mounted` não existe nesta versão de riverpod — mesmo padrão de
  // `ProgressNotifier._disposed`.
  bool _disposed = false;

  late final BlockProgramExecutor _executor;

  final Stopwatch _levelStopwatch = Stopwatch()..start();

  // Mesmas durações de `ConveyorGameplayViewModel` (Mundo 2) — mesma
  // cadência de Execução, só trocando "item classificado" por "número
  // processado".
  static const _stepDuration = Duration(milliseconds: 460);
  static const _startDelay = Duration(milliseconds: 200);
  static const _resultPause = Duration(milliseconds: 500);

  /// Flash mais curto para um Passo que não teve efeito (lista de números já
  /// esgotada — Programa com mais blocos-alvo do que números na fase) — sem
  /// isso, esse bloco ficava destacado pela mesma duração de um Passo que
  /// fez algo de verdade, sem nenhum sinal de que não teve efeito (achado do
  /// UX Reviewer). Mesmo espírito de `_zeroMatchFlashDuration` do Mundo 2
  /// (`ConveyorGameplayViewModel`, bloco `Enquanto` que classifica 0 itens).
  static const _noEffectFlashDuration = Duration(milliseconds: 250);

  @override
  BlockProgramGameplayState build(String levelId) {
    ref.onDispose(() => _disposed = true);
    final level = world4Levels.firstWhere((l) => l.id == levelId);
    _executor = BlockProgramExecutor(level);
    return BlockProgramGameplayState(
      level: level,
      // Esmaecimento progressivo (ver `BlockProgramLevel.prefilledCount`):
      // o Programa não começa mais sempre vazio — os primeiros N blocos do
      // `hintProgram` já vêm prontos/fixos na fase, mostrados como código já
      // escrito. `prefilledCount: 0` (maioria das fases iniciais) preserva o
      // comportamento original (`.take(0)` == lista vazia).
      program: level.hintProgram.take(level.prefilledCount).toList(),
      cursor: BlockProgramCursor.fromStart(),
    );
  }

  void addBlock(BlockProgramBlockType type) {
    if (state.running || state.program.length >= state.level.maxBlocks) return;
    state = state.copyWith(program: [...state.program, BlockProgramBlock(type)]);
  }

  void removeBlockAt(int index) {
    // Defensivo: blocos dentro do prefixo fixo (`prefilledCount`) nunca são
    // removíveis — a UI não deveria nem oferecer essa interação nesses
    // índices, mas o ViewModel protege contra isso mesmo assim (ex.: toque
    // que chegue aqui por engano).
    if (state.running || index < state.level.prefilledCount) return;
    state = state.copyWith(program: [...state.program]..removeAt(index));
  }

  void clearProgram() {
    if (state.running) return;
    // Volta para o prefixo fixo (`prefilledCount`), não para a lista vazia
    // — o jogador nunca consegue apagar blocos já prontos na fase.
    final prefilled = state.level.hintProgram.take(state.level.prefilledCount).toList();
    state = state.copyWith(program: prefilled, cursor: BlockProgramCursor.fromStart(), currentStepBlockIndex: null);
  }

  void clearEffect() => state = state.copyWith(pendingEffect: null);

  Future<void> run() async {
    if (state.running || state.program.isEmpty) return;
    final steps = _executor.expand(state.program);

    state = state.copyWith(
      running: true,
      currentStepBlockIndex: null,
      cursor: BlockProgramCursor.fromStart(),
      attempts: state.attempts + 1,
      lastRunBlocksUsed: state.program.length,
    );
    ref.read(appSoundsProvider).run();

    await Future.delayed(_startDelay);

    // Itera por bloco do Programa (não direto por `steps`) só para pular
    // "Para cada número" (modificador, nunca destacado diretamente — mesmo
    // tratamento que `repeat` recebe no Mundo 2). Todo outro tipo de bloco
    // sempre produz pelo menos 1 Passo (ver `BlockProgramExecutor.expand`),
    // então, diferente do Mundo 2, não existe caso de "zero Passos" a
    // tratar aqui.
    var stepCursor = 0;
    for (var blockIndex = 0; blockIndex < state.program.length; blockIndex++) {
      if (_disposed) return;
      if (state.program[blockIndex].type == BlockProgramBlockType.forEachNumber) continue;

      while (stepCursor < steps.length && steps[stepCursor].blockIndex == blockIndex) {
        final step = steps[stepCursor];
        stepCursor++;

        final hadNumberLeft = state.cursor.nextNumberIndex < state.level.numbers.length;
        final outcome = _executor.applyStep(state.cursor, step.type);
        // Um som por número processado — reaproveita `turn()` (mesmo
        // espírito de `.walk()`/`.turn()` dos outros mundos).
        ref.read(appSoundsProvider).turn();

        state = state.copyWith(cursor: outcome.cursor, currentStepBlockIndex: step.blockIndex);
        await Future.delayed(hadNumberLeft ? _stepDuration : _noEffectFlashDuration);
      }
    }

    if (_disposed) return;
    final finalOutcome = _executor.evaluateFinal(state.cursor);
    state = state.copyWith(running: false, currentStepBlockIndex: null);
    await _resolveOutcome(finalOutcome);
  }

  /// Monta o efeito de navegação (Vitória ou Falha) assim que a Execução
  /// termina — sem modal/overlay intermediário.
  Future<void> _resolveOutcome(BlockProgramOutcome outcome) async {
    await Future.delayed(_resultPause);
    if (_disposed) return;

    // Captura o valor final ANTES de resetar o cursor abaixo — é o que
    // permite a tela de Falha dizer exatamente o Total/Contador que o
    // jogador alcançou (achado do UX Reviewer), não só "não bateu".
    final level = state.level;
    final finalValue = level.goal == BlockProgramGoal.total ? state.cursor.total : state.cursor.count;

    // Deixa a fase pronta para a próxima tentativa (lista do começo) para
    // quando o jogador voltar via "Tentar de novo".
    state = state.copyWith(cursor: BlockProgramCursor.fromStart());

    if (outcome == BlockProgramOutcome.win) {
      final world = worlds.firstWhere((w) => w.number == level.world);
      final score = computeScore(blocksUsed: state.lastRunBlocksUsed, optimalBlocks: level.optimalBlocks);

      final result = ref.read(recordLevelWinUseCaseProvider).call(
            levelId: level.id,
            world: world,
            score: score,
            blocksUsedOrAttempts: state.lastRunBlocksUsed,
            elapsedSeconds: _levelStopwatch.elapsed.inSeconds,
          );

      final levelsInWorld = world.levels.cast<BlockProgramLevel>();
      final levelIndex = levelsInWorld.indexWhere((l) => l.id == level.id);
      final nextLevel = (levelIndex >= 0 && levelIndex + 1 < levelsInWorld.length) ? levelsInWorld[levelIndex + 1] : null;

      state = state.copyWith(
        pendingEffect: BlockProgramGameplayEffect.navigateToVictory(
          data: BlockProgramVictoryData(
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
        pendingEffect: BlockProgramGameplayEffect.navigateToFailure(
          data: BlockProgramFailureData(
            levelNumber: level.number,
            attempt: state.attempts,
            outcome: outcome,
            maxBlocks: level.maxBlocks,
            finalValue: finalValue,
            targetValue: level.targetValue,
            goal: level.goal,
          ),
        ),
      );
    }
  }
}
