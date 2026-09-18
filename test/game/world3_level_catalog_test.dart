import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/game_result.dart';
import 'package:debuga_o_mascote/game/program_executor.dart';
import 'package:debuga_o_mascote/models/level.dart';

/// Garante que toda fase de `world3Levels` ("Desenho no Tabuleiro") é
/// solucionável dentro do seu `maxBlocks` usando o próprio `hintProgram`,
/// pintando exatamente o desenho-alvo (`paintTarget`) — ver
/// `.claude/reviews/checklist-level.md`. Mesmo padrão de
/// `test/game/level_catalog_test.dart` (Mundo 1)/
/// `world2_level_catalog_test.dart` (Mundo 2).
void main() {
  test('world3Levels tem 12 fases com ids únicos e estáveis', () {
    expect(world3Levels.length, 12);
    expect(world3Levels.map((l) => l.id).toSet().length, 12);
    for (var i = 0; i < world3Levels.length; i++) {
      expect(world3Levels[i].number, i + 1);
      expect(world3Levels[i].world, 3);
      expect(
        world3Levels[i].paintTarget,
        isNotNull,
        reason: 'Fase ${world3Levels[i].number} deveria ter paintTarget',
      );
      // Mundo 3 não usa mais o acumulador de Moedas (isso migrou pro
      // Mundo 2) — nenhuma das 12 fases deveria ter collectTarget.
      expect(
        world3Levels[i].collectTarget,
        isNull,
        reason:
            'Fase ${world3Levels[i].number} não deveria ter collectTarget '
            '(mecânica exclusiva do Mundo 2 desde 2026-09-18)',
      );
    }
  });

  for (final level in world3Levels) {
    test(
      '${level.id} (Fase ${level.number}): hintProgram resolve dentro do maxBlocks e pinta exatamente o desenho-alvo',
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

        final target = level.paintTarget!;
        expect(
          cursor.paintedTiles.length,
          target.length,
          reason:
              'Fase ${level.number}: hintProgram deveria pintar exatamente '
              'o desenho-alvo (nem faltar, nem sobrar célula)',
        );
        expect(
          cursor.paintedTiles.every(target.contains),
          isTrue,
          reason:
              'Fase ${level.number}: toda célula pintada deveria fazer '
              'parte do desenho-alvo',
        );
        expect(
          executor.evaluateFinal(cursor),
          GameOutcome.win,
          reason: 'Fase ${level.number}: hintProgram deveria vencer',
        );
      },
    );
  }
}
