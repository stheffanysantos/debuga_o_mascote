import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/belt_executor.dart';
import 'package:debuga_o_mascote/models/conveyor_level.dart';

/// Garante que toda fase de `world2Levels` é solucionável dentro do seu
/// `maxBlocks` usando o próprio `hintProgram` — ver
/// `.claude/reviews/checklist-level.md`.
void main() {
  test('world2Levels tem 12 fases com ids únicos e estáveis', () {
    expect(world2Levels.length, 12);
    expect(world2Levels.map((l) => l.id).toSet().length, 12);
    for (var i = 0; i < world2Levels.length; i++) {
      expect(world2Levels[i].number, i + 1);
    }
  });

  for (final level in world2Levels) {
    test('${level.id} (Fase ${level.number}): hintProgram resolve dentro do maxBlocks', () {
      expect(level.hintProgram.length, level.optimalBlocks);
      expect(level.hintProgram.length, lessThanOrEqualTo(level.maxBlocks));

      final executor = BeltExecutor(level);
      var cursor = BeltCursor.fromStart();

      for (final step in executor.expand(level.hintProgram)) {
        final outcome = executor.applyStep(cursor, step.type);
        expect(outcome.misclassified, isFalse, reason: 'Fase ${level.number}: hintProgram não deveria classificar errado');
        cursor = outcome.cursor;
      }

      expect(executor.evaluateFinal(cursor), BeltOutcome.win, reason: 'Fase ${level.number}: hintProgram deveria vencer');
    });
  }
}
