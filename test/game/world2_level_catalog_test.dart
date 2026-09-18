import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/game_result.dart';
import 'package:debuga_o_mascote/game/program_executor.dart';
import 'package:debuga_o_mascote/models/level.dart';

/// Garante que toda fase de `world2Levels` ("Resgate de Personagens") é
/// solucionável dentro do seu `maxBlocks` usando o próprio `hintProgram` —
/// ver `.claude/reviews/checklist-level.md`. Mesmo padrão de
/// `test/game/level_catalog_test.dart` (Mundo 1).
void main() {
  test('world2Levels tem 12 fases com ids únicos e estáveis', () {
    expect(world2Levels.length, 12);
    expect(world2Levels.map((l) => l.id).toSet().length, 12);
    for (var i = 0; i < world2Levels.length; i++) {
      expect(world2Levels[i].number, i + 1);
      expect(world2Levels[i].world, 2);
      expect(
        world2Levels[i].collectibles,
        isNotEmpty,
        reason:
            'Fase ${world2Levels[i].number} deveria ter ao menos 1 '
            'personagem perdido',
      );
    }
  });

  for (final level in world2Levels) {
    test(
      '${level.id} (Fase ${level.number}): hintProgram resolve dentro do maxBlocks',
      () {
        expect(level.hintProgram.length, level.optimalBlocks);
        expect(level.hintProgram.length, lessThanOrEqualTo(level.maxBlocks));

        final executor = ProgramExecutor(level);
        var cursor = GameCursor.fromStart(level);

        for (final step in executor.expand(level.hintProgram)) {
          final outcome = executor.applyStep(cursor, step.type);
          expect(
            outcome.crashed,
            isFalse,
            reason: 'Fase ${level.number}: hintProgram não deveria colidir',
          );
          cursor = outcome.cursor;
        }

        final target = level.collectTarget;
        if (target != null) {
          expect(
            cursor.collectedCount,
            target,
            reason:
                'Fase ${level.number}: hintProgram deveria coletar '
                'exatamente collectTarget moedas',
          );
        }

        expect(
          executor.evaluateFinal(cursor),
          GameOutcome.win,
          reason: 'Fase ${level.number}: hintProgram deveria vencer',
        );
      },
    );
  }
}
