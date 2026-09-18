import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/block_program_executor.dart';
import 'package:debuga_o_mascote/models/block_program_level.dart';

/// Garante que toda fase de `world4Levels` é solucionável dentro do seu
/// `maxBlocks` usando o próprio `hintProgram` — ver
/// `.claude/reviews/checklist-level.md`.
void main() {
  void checkCatalog(String name, List<BlockProgramLevel> levels) {
    test('$name tem 12 fases com ids únicos e estáveis', () {
      expect(levels.length, 12);
      expect(levels.map((l) => l.id).toSet().length, 12);
      for (var i = 0; i < levels.length; i++) {
        expect(levels[i].number, i + 1);
      }
    });

    for (final level in levels) {
      test(
        '${level.id} (Fase ${level.number}): hintProgram resolve dentro do maxBlocks',
        () {
          expect(level.hintProgram.length, level.optimalBlocks);
          expect(level.hintProgram.length, lessThanOrEqualTo(level.maxBlocks));

          final executor = BlockProgramExecutor(level);
          var cursor = BlockProgramCursor.fromStart();

          for (final step in executor.expand(level.hintProgram)) {
            cursor = executor.applyStep(cursor, step.type).cursor;
          }

          expect(
            executor.evaluateFinal(cursor),
            BlockProgramOutcome.win,
            reason: 'Fase ${level.number}: hintProgram deveria vencer',
          );
        },
      );
    }
  }

  checkCatalog('world4Levels', world4Levels);
}
