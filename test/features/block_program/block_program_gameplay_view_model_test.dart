import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/features/block_program/presentation/gameplay/block_program_gameplay_view_model.dart';
import 'package:debuga_o_mascote/models/block_program_level.dart';

/// `BlockProgramGameplayViewModel` (Mundo 4) — cobre o esmaecimento
/// progressivo (`BlockProgramLevel.prefilledCount`, ver
/// `.claude/memory/decisions.md`, entrada de 2026-09-18): o Programa começa
/// com um prefixo fixo em fases avançadas, `clearProgram` sempre volta pra
/// esse mesmo prefixo (nunca pro vazio), e `removeBlockAt` nunca afeta um
/// índice dentro do prefixo. Construído via `ProviderContainer` puro — sem
/// pump de widget, mesmo padrão de `test/core/progress/progress_notifier_test.dart`
/// (ver `.claude/rules/testing.md`).
void main() {
  // Fase 1: `prefilledCount: 0` — comportamento original, Programa começa
  // vazio.
  final levelWithoutPrefill = world4Levels.first;

  // Fase 5: primeira fase com `prefilledCount > 0` (1 bloco solto fixo,
  // seguido do par `forEachNumber` + bloco-alvo que o jogador ainda precisa
  // montar).
  final levelWithPrefill = world4Levels.firstWhere((l) => l.id == 'world4_level5');

  test('build() com prefilledCount == 0 inicia o Programa vazio (comportamento original)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(blockProgramGameplayViewModelProvider(levelWithoutPrefill.id));

    expect(state.program, isEmpty);
  });

  test('build() com prefilledCount > 0 inicia o Programa já com o prefixo fixo de hintProgram', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(blockProgramGameplayViewModelProvider(levelWithPrefill.id));

    expect(levelWithPrefill.prefilledCount, 1);
    expect(state.program, levelWithPrefill.hintProgram.take(1).toList());
  });

  test('clearProgram() volta para o prefixo fixo, não para a lista vazia', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(blockProgramGameplayViewModelProvider(levelWithPrefill.id).notifier);

    notifier.addBlock(levelWithPrefill.hintProgram[1].type); // forEachNumber
    notifier.addBlock(levelWithPrefill.hintProgram[2].type); // bloco-alvo
    expect(container.read(blockProgramGameplayViewModelProvider(levelWithPrefill.id)).program.length, 3);

    notifier.clearProgram();

    final state = container.read(blockProgramGameplayViewModelProvider(levelWithPrefill.id));
    expect(state.program, levelWithPrefill.hintProgram.take(1).toList());
  });

  test('removeBlockAt() não afeta índices dentro do prefixo fixo', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(blockProgramGameplayViewModelProvider(levelWithPrefill.id).notifier);

    notifier.addBlock(levelWithPrefill.hintProgram[1].type);
    final before = container.read(blockProgramGameplayViewModelProvider(levelWithPrefill.id)).program;
    expect(before.length, 2); // 1 fixo + 1 adicionado

    // Índice 0 está dentro do prefixo fixo (prefilledCount == 1) — ignorado.
    notifier.removeBlockAt(0);
    final afterRemovingPrefilled = container.read(blockProgramGameplayViewModelProvider(levelWithPrefill.id)).program;
    expect(afterRemovingPrefilled, before, reason: 'remoção num índice do prefixo fixo não deve mudar o Programa');

    // Índice 1 (o bloco adicionado pelo jogador) é removível normalmente.
    notifier.removeBlockAt(1);
    final afterRemovingOwn = container.read(blockProgramGameplayViewModelProvider(levelWithPrefill.id)).program;
    expect(afterRemovingOwn.length, 1);
  });
}
