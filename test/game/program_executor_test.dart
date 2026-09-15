import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/game_result.dart';
import 'package:debuga_o_mascote/game/program_executor.dart';
import 'package:debuga_o_mascote/models/block.dart';
import 'package:debuga_o_mascote/models/level.dart';

void main() {
  group('ProgramExecutor.expand', () {
    test('expande Repetir 3x sobre o bloco seguinte', () {
      final executor = ProgramExecutor(demoLevel);
      final steps = executor.expand(const [Block(BlockType.repeat), Block(BlockType.walk)]);

      expect(steps.length, 3);
      expect(steps.every((s) => s.type == BlockType.walk), isTrue);
      expect(steps.every((s) => s.blockIndex == 1), isTrue);
    });

    test('Repetir sem bloco seguinte não gera passo', () {
      final executor = ProgramExecutor(demoLevel);
      final steps = executor.expand(const [Block(BlockType.walk), Block(BlockType.repeat)]);

      expect(steps.length, 1);
      expect(steps.single.type, BlockType.walk);
    });
  });

  group('ProgramExecutor.applyStep', () {
    test('Andar contra uma parede resulta em crash', () {
      const level = Level(
        id: 'test_wall',
        world: 1,
        number: 1,
        title: 'teste',
        gridSize: 3,
        walls: [GridPosition(1, 0)],
        start: GridPosition(0, 0),
        startDirection: FacingDirection.right,
        goal: GridPosition(2, 0),
        maxBlocks: 8,
        optimalBlocks: 1,
        hintProgram: [],
      );
      final executor = ProgramExecutor(level);
      final cursor = GameCursor.fromStart(level);

      final outcome = executor.applyStep(cursor, BlockType.walk);

      expect(outcome.crashed, isTrue);
      expect(outcome.cursor.x, cursor.x);
      expect(outcome.cursor.y, cursor.y);
    });

    test('Andar para fora do tabuleiro resulta em crash', () {
      const level = Level(
        id: 'test_edge',
        world: 1,
        number: 1,
        title: 'teste',
        gridSize: 2,
        walls: [],
        start: GridPosition(0, 0),
        startDirection: FacingDirection.up,
        goal: GridPosition(1, 1),
        maxBlocks: 8,
        optimalBlocks: 1,
        hintProgram: [],
      );
      final executor = ProgramExecutor(level);
      final cursor = GameCursor.fromStart(level);

      final outcome = executor.applyStep(cursor, BlockType.walk);

      expect(outcome.crashed, isTrue);
    });

    test('Virar não move o mascote, só muda a direção', () {
      final executor = ProgramExecutor(demoLevel);
      final cursor = GameCursor.fromStart(demoLevel);

      final afterLeft = executor.applyStep(cursor, BlockType.turnLeft);
      final afterRight = executor.applyStep(cursor, BlockType.turnRight);

      expect(afterLeft.cursor.x, cursor.x);
      expect(afterLeft.cursor.y, cursor.y);
      expect(afterRight.cursor.direction, FacingDirection.values[(cursor.direction.index + 1) % 4]);
    });
  });

  group('ProgramExecutor.evaluateFinal', () {
    test('vitória quando o cursor termina exatamente no alvo', () {
      const level = Level(
        id: 'test_goal',
        world: 1,
        number: 1,
        title: 'teste',
        gridSize: 2,
        walls: [],
        start: GridPosition(0, 0),
        startDirection: FacingDirection.right,
        goal: GridPosition(1, 0),
        maxBlocks: 8,
        optimalBlocks: 1,
        hintProgram: [],
      );
      final executor = ProgramExecutor(level);

      final result = executor.evaluateFinal(const GameCursor(x: 1, y: 0, direction: FacingDirection.right));

      expect(result, GameOutcome.win);
    });

    test('falha (far) quando o programa termina longe do alvo', () {
      final executor = ProgramExecutor(demoLevel);

      final result = executor.evaluateFinal(GameCursor.fromStart(demoLevel));

      expect(result, GameOutcome.farFromGoal);
    });
  });

  test('demoLevel.hintProgram é solucionável dentro do maxBlocks', () {
    // Também é a Dica real mostrada na tela de Tentativa Falha — ver
    // .claude/docs/GAME_DESIGN.md.
    final executor = ProgramExecutor(demoLevel);
    final program = demoLevel.hintProgram;
    expect(program.length, demoLevel.optimalBlocks);
    expect(program.length, lessThanOrEqualTo(demoLevel.maxBlocks));

    var cursor = GameCursor.fromStart(demoLevel);
    for (final step in executor.expand(program)) {
      final outcome = executor.applyStep(cursor, step.type);
      expect(outcome.crashed, isFalse, reason: 'não deveria colidir na solução conhecida');
      cursor = outcome.cursor;
    }

    expect(executor.evaluateFinal(cursor), GameOutcome.win);
  });
}
