import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/game_result.dart';
import 'package:debuga_o_mascote/game/program_executor.dart';
import 'package:debuga_o_mascote/models/block.dart';
import 'package:debuga_o_mascote/models/level.dart';

void main() {
  group('ProgramExecutor.expand', () {
    test('expande Repetir 3x sobre o bloco seguinte', () {
      final executor = ProgramExecutor(demoLevel);
      final steps = executor.expand(const [
        Block(BlockType.repeat),
        Block(BlockType.walk),
      ]);

      expect(steps.length, 3);
      expect(steps.every((s) => s.type == BlockType.walk), isTrue);
      expect(steps.every((s) => s.blockIndex == 1), isTrue);
    });

    test('Repetir sem bloco seguinte não gera passo', () {
      final executor = ProgramExecutor(demoLevel);
      final steps = executor.expand(const [
        Block(BlockType.walk),
        Block(BlockType.repeat),
      ]);

      expect(steps.length, 1);
      expect(steps.single.type, BlockType.walk);
    });
  });

  group('resolveProgramEntries', () {
    test('marca a entrada como insideRepeat quando precedida de Repetir', () {
      final entries = resolveProgramEntries(const [
        Block(BlockType.repeat),
        Block(BlockType.walk),
        Block(BlockType.turnLeft),
      ]);

      expect(entries.length, 2);
      expect(entries[0].blockIndex, 1);
      expect(entries[0].targetType, BlockType.walk);
      expect(entries[0].insideRepeat, isTrue);
      expect(entries[1].blockIndex, 2);
      expect(entries[1].targetType, BlockType.turnLeft);
      expect(entries[1].insideRepeat, isFalse);
    });

    test('Repetir sem bloco seguinte válido não gera entrada', () {
      final entries = resolveProgramEntries(const [
        Block(BlockType.walk),
        Block(BlockType.repeat),
      ]);

      expect(entries.length, 1);
      expect(entries.single.blockIndex, 0);
      expect(entries.single.insideRepeat, isFalse);
    });

    test('expand() usa resolveProgramEntries — mesma expansão de sempre', () {
      final executor = ProgramExecutor(demoLevel);
      final program = const [
        Block(BlockType.repeat),
        Block(BlockType.walk),
        Block(BlockType.turnRight),
      ];

      final entries = resolveProgramEntries(program);
      final steps = executor.expand(program);

      final expectedStepCount = entries.fold<int>(
        0,
        (sum, e) => sum + (e.insideRepeat ? 3 : 1),
      );
      expect(steps.length, expectedStepCount);
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
      expect(
        afterRight.cursor.direction,
        FacingDirection.values[(cursor.direction.index + 1) % 4],
      );
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

      final result = executor.evaluateFinal(
        const GameCursor(x: 1, y: 0, direction: FacingDirection.right),
      );

      expect(result, GameOutcome.win);
    });

    test('falha (far) quando o programa termina longe do alvo', () {
      final executor = ProgramExecutor(demoLevel);

      final result = executor.evaluateFinal(GameCursor.fromStart(demoLevel));

      expect(result, GameOutcome.farFromGoal);
    });
  });

  group('ProgramExecutor.applyStep — Resgate de Personagens (Mundo 2)', () {
    test(
      'rescueIfCharacterHere anda e resgata quando a célula de destino tem personagem',
      () {
        final level = Level(
          id: 'test_rescue',
          world: 2,
          number: 1,
          title: 'teste',
          gridSize: 3,
          walls: [],
          start: GridPosition(0, 0),
          startDirection: FacingDirection.right,
          goal: GridPosition(2, 0),
          maxBlocks: 8,
          optimalBlocks: 2,
          hintProgram: [],
          collectibles: {GridPosition(1, 0)},
          collectTarget: 1,
        );
        final executor = ProgramExecutor(level);
        final cursor = GameCursor.fromStart(level);

        final outcome = executor.applyStep(
          cursor,
          BlockType.rescueIfCharacterHere,
        );

        expect(outcome.crashed, isFalse);
        expect(outcome.cursor.x, 1);
        expect(outcome.cursor.y, 0);
        expect(outcome.cursor.collectedCount, 1);
        expect(
          outcome.cursor.collectedTiles,
          contains(const GridPosition(1, 0)),
        );
      },
    );

    test(
      'rescueIfCharacterHere só anda (nunca falha) quando não há personagem no destino',
      () {
        final executor = ProgramExecutor(demoLevel);
        final cursor = GameCursor.fromStart(demoLevel);

        final outcome = executor.applyStep(
          cursor,
          BlockType.rescueIfCharacterHere,
        );

        expect(outcome.crashed, isFalse);
        expect(outcome.cursor.collectedCount, 0);
        expect(outcome.cursor.collectedTiles, isEmpty);
      },
    );

    test('rescueIfCharacterHere colide com parede igual a walk', () {
      final level = Level(
        id: 'test_rescue_wall',
        world: 2,
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

      final outcome = executor.applyStep(
        cursor,
        BlockType.rescueIfCharacterHere,
      );

      expect(outcome.crashed, isTrue);
      expect(outcome.cursor.x, cursor.x);
      expect(outcome.cursor.y, cursor.y);
    });

    test('Andar NÃO resgata mais automaticamente (só rescueIfCharacterHere resgata)', () {
      final level = Level(
        id: 'test_walk_no_autocollect',
        world: 2,
        number: 1,
        title: 'teste',
        gridSize: 3,
        walls: [],
        start: GridPosition(0, 0),
        startDirection: FacingDirection.right,
        goal: GridPosition(2, 0),
        maxBlocks: 8,
        optimalBlocks: 2,
        hintProgram: [],
        collectibles: {GridPosition(1, 0)},
        collectTarget: 1,
      );
      final executor = ProgramExecutor(level);
      final cursor = GameCursor.fromStart(level);

      final outcome = executor.applyStep(cursor, BlockType.walk);

      expect(outcome.crashed, isFalse);
      expect(outcome.cursor.collectedCount, 0);
      expect(outcome.cursor.collectedTiles, isEmpty);
    });

    test(
      'visitar a mesma célula de personagem 2 vezes via rescueIfCharacterHere só conta 1 vez',
      () {
        final level = Level(
          id: 'test_rescue_twice',
          world: 2,
          number: 1,
          title: 'teste',
          gridSize: 3,
          walls: [],
          start: GridPosition(0, 0),
          startDirection: FacingDirection.right,
          goal: GridPosition(1, 0),
          maxBlocks: 8,
          optimalBlocks: 3,
          hintProgram: [],
          collectibles: {GridPosition(1, 0)},
          collectTarget: 1,
        );
        final executor = ProgramExecutor(level);
        var cursor = GameCursor.fromStart(level);

        cursor = executor
            .applyStep(cursor, BlockType.rescueIfCharacterHere)
            .cursor; // (0,0)->(1,0), resgata
        cursor = executor.applyStep(cursor, BlockType.turnLeft).cursor;
        cursor = executor.applyStep(cursor, BlockType.turnLeft).cursor;
        cursor = executor
            .applyStep(cursor, BlockType.rescueIfCharacterHere)
            .cursor; // (1,0)->(0,0)
        cursor = executor.applyStep(cursor, BlockType.turnLeft).cursor;
        cursor = executor.applyStep(cursor, BlockType.turnLeft).cursor;
        cursor = executor
            .applyStep(cursor, BlockType.rescueIfCharacterHere)
            .cursor; // (0,0)->(1,0) de novo

        expect(cursor.collectedCount, 1);
      },
    );

    test(
      'evaluateFinal: vitória quando chega no alvo com a contagem exata de personagens resgatados',
      () {
        const level = Level(
          id: 'test_coin_win',
          world: 2,
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
          collectibles: {},
          collectTarget: 1,
        );
        final executor = ProgramExecutor(level);

        final result = executor.evaluateFinal(
          const GameCursor(
            x: 1,
            y: 0,
            direction: FacingDirection.right,
            collectedCount: 1,
          ),
        );

        expect(result, GameOutcome.win);
      },
    );

    test(
      'evaluateFinal: wrongCollectCount quando chega no alvo com contagem errada de personagens resgatados',
      () {
        const level = Level(
          id: 'test_coin_wrong',
          world: 2,
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
          collectibles: {},
          collectTarget: 2,
        );
        final executor = ProgramExecutor(level);

        final result = executor.evaluateFinal(
          const GameCursor(
            x: 1,
            y: 0,
            direction: FacingDirection.right,
            collectedCount: 1,
          ),
        );

        expect(result, GameOutcome.wrongCollectCount);
      },
    );

    test(
      'evaluateFinal: farFromGoal continua tendo prioridade sobre a contagem de personagens resgatados',
      () {
        const level = Level(
          id: 'test_coin_far',
          world: 2,
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
          collectibles: {},
          collectTarget: 1,
        );
        final executor = ProgramExecutor(level);

        final result = executor.evaluateFinal(GameCursor.fromStart(level));

        expect(result, GameOutcome.farFromGoal);
      },
    );
  });

  group('GameCursor.fromStart / paintedTiles', () {
    test('fromStart já conta a célula inicial como pintada', () {
      final cursor = GameCursor.fromStart(demoLevel);

      expect(cursor.paintedTiles, {
        GridPosition(demoLevel.start.x, demoLevel.start.y),
      });
    });
  });

  group('ProgramExecutor — Desenho no Tabuleiro (Mundo 3)', () {
    test('Andar bem-sucedido adiciona a célula de destino a paintedTiles', () {
      final level = Level(
        id: 'test_paint_grow',
        world: 3,
        number: 1,
        title: 'teste',
        gridSize: 3,
        walls: [],
        start: GridPosition(0, 0),
        startDirection: FacingDirection.right,
        goal: GridPosition(2, 0),
        maxBlocks: 8,
        optimalBlocks: 2,
        hintProgram: [],
        paintTarget: {
          GridPosition(0, 0),
          GridPosition(1, 0),
          GridPosition(2, 0),
        },
      );
      final executor = ProgramExecutor(level);
      var cursor = GameCursor.fromStart(level);

      cursor = executor.applyStep(cursor, BlockType.walk).cursor;
      expect(cursor.paintedTiles, {
        const GridPosition(0, 0),
        const GridPosition(1, 0),
      });

      cursor = executor.applyStep(cursor, BlockType.walk).cursor;
      expect(cursor.paintedTiles, {
        const GridPosition(0, 0),
        const GridPosition(1, 0),
        const GridPosition(2, 0),
      });
    });

    test('revisitar a mesma célula (via Repetir) não duplica em paintedTiles', () {
      final level = Level(
        id: 'test_paint_revisit',
        world: 3,
        number: 1,
        title: 'teste',
        gridSize: 3,
        walls: [],
        start: GridPosition(0, 0),
        startDirection: FacingDirection.right,
        goal: GridPosition(0, 0),
        maxBlocks: 8,
        optimalBlocks: 5,
        hintProgram: [],
        paintTarget: {GridPosition(0, 0), GridPosition(1, 0)},
      );
      final executor = ProgramExecutor(level);
      var cursor = GameCursor.fromStart(level);

      // Anda até (1,0), dá meia-volta e volta para (0,0) — revisita as
      // mesmas 2 células várias vezes.
      cursor = executor.applyStep(cursor, BlockType.walk).cursor; // (1,0)
      cursor = executor.applyStep(cursor, BlockType.turnRight).cursor;
      cursor = executor.applyStep(cursor, BlockType.turnRight).cursor;
      cursor = executor.applyStep(cursor, BlockType.walk).cursor; // (0,0)

      expect(cursor.paintedTiles.length, 2);
      expect(cursor.paintedTiles, {
        const GridPosition(0, 0),
        const GridPosition(1, 0),
      });
    });

    test(
      'evaluateFinal: vitória quando o desenho pintado bate exatamente com paintTarget',
      () {
        final level = Level(
          id: 'test_paint_win',
          world: 3,
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
          paintTarget: {GridPosition(0, 0), GridPosition(1, 0)},
        );
        final executor = ProgramExecutor(level);

        final result = executor.evaluateFinal(
          GameCursor(
            x: 1,
            y: 0,
            direction: FacingDirection.right,
            paintedTiles: {GridPosition(0, 0), GridPosition(1, 0)},
          ),
        );

        expect(result, GameOutcome.win);
      },
    );

    test(
      'evaluateFinal: wrongPaintPattern quando falta pintar uma célula do desenho-alvo',
      () {
        final level = Level(
          id: 'test_paint_missing',
          world: 3,
          number: 1,
          title: 'teste',
          gridSize: 3,
          walls: [],
          start: GridPosition(0, 0),
          startDirection: FacingDirection.right,
          goal: GridPosition(2, 0),
          maxBlocks: 8,
          optimalBlocks: 1,
          hintProgram: [],
          paintTarget: {
            GridPosition(0, 0),
            GridPosition(1, 0),
            GridPosition(2, 0),
          },
        );
        final executor = ProgramExecutor(level);

        // Chegou no alvo (2,0), mas "pulou" (1,0) — cursor forjado direto,
        // sem passar por lá (simula um Programa que teria feito isso por
        // outro caminho, se o tabuleiro permitisse).
        final result = executor.evaluateFinal(
          GameCursor(
            x: 2,
            y: 0,
            direction: FacingDirection.right,
            paintedTiles: {GridPosition(0, 0), GridPosition(2, 0)},
          ),
        );

        expect(result, GameOutcome.wrongPaintPattern);
      },
    );

    test(
      'evaluateFinal: wrongPaintPattern quando pinta uma célula fora do desenho-alvo',
      () {
        final level = Level(
          id: 'test_paint_extra',
          world: 3,
          number: 1,
          title: 'teste',
          gridSize: 3,
          walls: [],
          start: GridPosition(0, 0),
          startDirection: FacingDirection.right,
          goal: GridPosition(1, 0),
          maxBlocks: 8,
          optimalBlocks: 1,
          hintProgram: [],
          paintTarget: {GridPosition(0, 0), GridPosition(1, 0)},
        );
        final executor = ProgramExecutor(level);

        final result = executor.evaluateFinal(
          GameCursor(
            x: 1,
            y: 0,
            direction: FacingDirection.right,
            paintedTiles: {
              GridPosition(0, 0),
              GridPosition(1, 0),
              GridPosition(2, 0),
            },
          ),
        );

        expect(result, GameOutcome.wrongPaintPattern);
      },
    );

    test(
      'evaluateFinal: farFromGoal continua tendo prioridade sobre o desenho pintado',
      () {
        final level = Level(
          id: 'test_paint_far',
          world: 3,
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
          paintTarget: {GridPosition(0, 0)},
        );
        final executor = ProgramExecutor(level);

        final result = executor.evaluateFinal(GameCursor.fromStart(level));

        expect(result, GameOutcome.farFromGoal);
      },
    );
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
      expect(
        outcome.crashed,
        isFalse,
        reason: 'não deveria colidir na solução conhecida',
      );
      cursor = outcome.cursor;
    }

    expect(executor.evaluateFinal(cursor), GameOutcome.win);
  });
}
