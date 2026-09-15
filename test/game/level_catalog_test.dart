import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/game_result.dart';
import 'package:debuga_o_mascote/game/program_executor.dart';
import 'package:debuga_o_mascote/models/level.dart';

/// Garante que toda fase do catálogo é solucionável dentro do seu
/// `maxBlocks` usando o próprio `hintProgram` — ver
/// `.claude/reviews/checklist-level.md`.
void main() {
  test('world1Levels tem 12 fases com ids únicos e estáveis', () {
    expect(world1Levels.length, 12);
    expect(world1Levels.map((l) => l.id).toSet().length, 12);
    for (var i = 0; i < world1Levels.length; i++) {
      expect(world1Levels[i].number, i + 1);
    }
  });

  for (final level in world1Levels) {
    test('${level.id} (Fase ${level.number}): hintProgram resolve dentro do maxBlocks', () {
      expect(level.hintProgram.length, level.optimalBlocks);
      expect(level.hintProgram.length, lessThanOrEqualTo(level.maxBlocks));

      final executor = ProgramExecutor(level);
      var cursor = GameCursor.fromStart(level);

      for (final step in executor.expand(level.hintProgram)) {
        final outcome = executor.applyStep(cursor, step.type);
        expect(outcome.crashed, isFalse, reason: 'Fase ${level.number}: hintProgram não deveria colidir');
        cursor = outcome.cursor;
      }

      expect(executor.evaluateFinal(cursor), GameOutcome.win, reason: 'Fase ${level.number}: hintProgram deveria vencer');
    });
  }
}
