import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/belt_executor.dart';
import 'package:debuga_o_mascote/models/belt_block.dart';
import 'package:debuga_o_mascote/models/belt_item.dart';
import 'package:debuga_o_mascote/models/conveyor_level.dart';

void main() {
  const level = ConveyorLevel(
    id: 'test_belt',
    world: 2,
    number: 1,
    title: 'teste',
    itemQueue: [BeltItemColor.yellow, BeltItemColor.yellow, BeltItemColor.yellow, BeltItemColor.purple],
    maxBlocks: 8,
    optimalBlocks: 3,
    hintProgram: [],
  );

  group('BeltExecutor.expand', () {
    test('expande Repetir 3x sobre o bloco seguinte', () {
      final executor = BeltExecutor(level);
      final steps = executor.expand(const [BeltBlock(BeltBlockType.repeat), BeltBlock(BeltBlockType.ifYellowToBinA)]);

      expect(steps.length, 3);
      expect(steps.every((s) => s.type == BeltBlockType.ifYellowToBinA), isTrue);
      expect(steps.every((s) => s.blockIndex == 1), isTrue);
    });

    test('Repetir sem bloco seguinte não gera passo', () {
      final executor = BeltExecutor(level);
      final steps = executor.expand(const [BeltBlock(BeltBlockType.ifYellowToBinA), BeltBlock(BeltBlockType.repeat)]);

      expect(steps.length, 1);
      expect(steps.single.type, BeltBlockType.ifYellowToBinA);
    });

    test('Enquanto classifica todos os itens consecutivos de N tamanho (não múltiplo de 3) e para na troca de cor', () {
      // fila: 5 amarelos, depois 1 roxo.
      const queueLevel = ConveyorLevel(
        id: 'test_while_run',
        world: 2,
        number: 1,
        title: 'teste',
        itemQueue: [
          BeltItemColor.yellow,
          BeltItemColor.yellow,
          BeltItemColor.yellow,
          BeltItemColor.yellow,
          BeltItemColor.yellow,
          BeltItemColor.purple,
        ],
        maxBlocks: 8,
        optimalBlocks: 2,
        hintProgram: [],
      );
      final executor = BeltExecutor(queueLevel);
      final steps = executor.expand(const [BeltBlock(BeltBlockType.whileYellowToBinA), BeltBlock(BeltBlockType.ifPurpleToBinB)]);

      // 5 passos de whileYellowToBinA (blockIndex 0, o próprio bloco while) +
      // 1 passo de ifPurpleToBinB (blockIndex 1).
      expect(steps.length, 6);
      expect(steps.sublist(0, 5).every((s) => s.type == BeltBlockType.whileYellowToBinA), isTrue);
      expect(steps.sublist(0, 5).every((s) => s.blockIndex == 0), isTrue);
      expect(steps[5].type, BeltBlockType.ifPurpleToBinB);
      expect(steps[5].blockIndex, 1);
    });

    test('Enquanto para no fim da fila mesmo sem trocar de cor', () {
      const queueLevel = ConveyorLevel(
        id: 'test_while_end',
        world: 2,
        number: 1,
        title: 'teste',
        itemQueue: [BeltItemColor.yellow, BeltItemColor.yellow, BeltItemColor.yellow, BeltItemColor.yellow],
        maxBlocks: 8,
        optimalBlocks: 1,
        hintProgram: [],
      );
      final executor = BeltExecutor(queueLevel);
      final steps = executor.expand(const [BeltBlock(BeltBlockType.whileYellowToBinA)]);

      expect(steps.length, 4);
      expect(steps.every((s) => s.type == BeltBlockType.whileYellowToBinA), isTrue);
    });

    test('Enquanto com condição já falsa classifica zero itens, sem erro, e segue pro próximo bloco', () {
      const queueLevel = ConveyorLevel(
        id: 'test_while_zero',
        world: 2,
        number: 1,
        title: 'teste',
        itemQueue: [BeltItemColor.purple, BeltItemColor.purple],
        maxBlocks: 8,
        optimalBlocks: 1,
        hintProgram: [],
      );
      final executor = BeltExecutor(queueLevel);
      final steps = executor.expand(const [BeltBlock(BeltBlockType.whileYellowToBinA), BeltBlock(BeltBlockType.whilePurpleToBinB)]);

      // Nenhum passo do whileYellowToBinA (condição já começa falsa: item
      // atual é roxo) — só os 2 passos do whilePurpleToBinB seguinte.
      expect(steps.length, 2);
      expect(steps.every((s) => s.type == BeltBlockType.whilePurpleToBinB), isTrue);
      expect(steps.every((s) => s.blockIndex == 1), isTrue);
    });

    test('Enquanto combinado com Se e Repetir no mesmo Programa', () {
      // fila: 1 roxo, 3 amarelos, 4 roxos, 1 amarelo (9 itens).
      const queueLevel = ConveyorLevel(
        id: 'test_while_combo',
        world: 2,
        number: 1,
        title: 'teste',
        itemQueue: [
          BeltItemColor.purple,
          BeltItemColor.yellow,
          BeltItemColor.yellow,
          BeltItemColor.yellow,
          BeltItemColor.purple,
          BeltItemColor.purple,
          BeltItemColor.purple,
          BeltItemColor.purple,
          BeltItemColor.yellow,
        ],
        maxBlocks: 8,
        optimalBlocks: 4,
        hintProgram: [],
      );
      final executor = BeltExecutor(queueLevel);
      const program = [
        BeltBlock(BeltBlockType.ifPurpleToBinB), // 1 roxo avulso
        BeltBlock(BeltBlockType.repeat), // Repetir aplicado ao próximo (fixo, 3x)
        BeltBlock(BeltBlockType.ifYellowToBinA), // 3 amarelos via Repetir
        BeltBlock(BeltBlockType.whilePurpleToBinB), // 4 roxos consecutivos
        BeltBlock(BeltBlockType.ifYellowToBinA), // 1 amarelo final avulso
      ];
      final steps = executor.expand(program);

      expect(steps.length, 9);
      var cursor = BeltCursor.fromStart();
      for (final step in steps) {
        final outcome = executor.applyStep(cursor, step.type);
        expect(outcome.misclassified, isFalse);
        cursor = outcome.cursor;
      }
      expect(executor.evaluateFinal(cursor), BeltOutcome.win);
    });

    test('Repetir aplicado sobre Enquanto: segunda aplicação geralmente classifica zero itens a mais (sem erro)', () {
      // fila: 4 amarelos.
      const queueLevel = ConveyorLevel(
        id: 'test_repeat_over_while',
        world: 2,
        number: 1,
        title: 'teste',
        itemQueue: [BeltItemColor.yellow, BeltItemColor.yellow, BeltItemColor.yellow, BeltItemColor.yellow],
        maxBlocks: 8,
        optimalBlocks: 2,
        hintProgram: [],
      );
      final executor = BeltExecutor(queueLevel);
      final steps = executor.expand(const [BeltBlock(BeltBlockType.repeat), BeltBlock(BeltBlockType.whileYellowToBinA)]);

      // 1ª aplicação consome os 4 amarelos; 2ª e 3ª aplicações não têm mais
      // itens amarelos consecutivos a classificar (fila já esgotada).
      expect(steps.length, 4);
      expect(steps.every((s) => s.type == BeltBlockType.whileYellowToBinA), isTrue);
      expect(steps.every((s) => s.blockIndex == 1), isTrue);
    });
  });

  group('BeltExecutor.applyStep', () {
    test('classificar a cor errada resulta em misclassified', () {
      final executor = BeltExecutor(level);
      final cursor = BeltCursor.fromStart();

      final outcome = executor.applyStep(cursor, BeltBlockType.ifPurpleToBinB);

      expect(outcome.misclassified, isTrue);
      expect(outcome.cursor.nextItemIndex, cursor.nextItemIndex);
    });

    test('whileYellowToBinA/whilePurpleToBinB são tratados como a mesma cor de ifYellowToBinA/ifPurpleToBinB', () {
      final executor = BeltExecutor(level);
      final cursor = BeltCursor.fromStart();

      final whileOutcome = executor.applyStep(cursor, BeltBlockType.whileYellowToBinA);
      expect(whileOutcome.misclassified, isFalse);
      expect(whileOutcome.cursor.nextItemIndex, 1);

      final wrongColorOutcome = executor.applyStep(cursor, BeltBlockType.whilePurpleToBinB);
      expect(wrongColorOutcome.misclassified, isTrue);
    });

    test('classificar a cor certa avança o cursor', () {
      final executor = BeltExecutor(level);
      final cursor = BeltCursor.fromStart();

      final outcome = executor.applyStep(cursor, BeltBlockType.ifYellowToBinA);

      expect(outcome.misclassified, isFalse);
      expect(outcome.cursor.nextItemIndex, 1);
    });

    test('passo sobrando com a fila já vazia resulta em misclassified', () {
      const emptyLevel = ConveyorLevel(
        id: 'test_empty',
        world: 2,
        number: 1,
        title: 'teste',
        itemQueue: [BeltItemColor.yellow],
        maxBlocks: 8,
        optimalBlocks: 1,
        hintProgram: [],
      );
      final executor = BeltExecutor(emptyLevel);
      final cursor = const BeltCursor(nextItemIndex: 1);

      final outcome = executor.applyStep(cursor, BeltBlockType.ifYellowToBinA);

      expect(outcome.misclassified, isTrue);
    });
  });

  group('BeltExecutor.evaluateFinal', () {
    test('vitória quando toda a fila foi processada', () {
      const shortLevel = ConveyorLevel(
        id: 'test_short',
        world: 2,
        number: 1,
        title: 'teste',
        itemQueue: [BeltItemColor.yellow],
        maxBlocks: 8,
        optimalBlocks: 1,
        hintProgram: [],
      );
      final executor = BeltExecutor(shortLevel);

      final result = executor.evaluateFinal(const BeltCursor(nextItemIndex: 1));

      expect(result, BeltOutcome.win);
    });

    test('falha (incomplete) quando sobram itens na fila', () {
      final executor = BeltExecutor(level);

      final result = executor.evaluateFinal(BeltCursor.fromStart());

      expect(result, BeltOutcome.incomplete);
    });
  });

  test('programa curto demais (acaba antes do fim da fila) gera falha', () {
    // Só 1 bloco pra uma fila de 4 itens — processa o primeiro e para.
    final executor = BeltExecutor(level);
    var cursor = BeltCursor.fromStart();

    for (final step in executor.expand(const [BeltBlock(BeltBlockType.ifYellowToBinA)])) {
      final outcome = executor.applyStep(cursor, step.type);
      expect(outcome.misclassified, isFalse);
      cursor = outcome.cursor;
    }

    expect(executor.evaluateFinal(cursor), BeltOutcome.incomplete);
  });

  test('fila totalmente processada sem erro gera vitória', () {
    final executor = BeltExecutor(level);
    var cursor = BeltCursor.fromStart();
    const program = [
      BeltBlock(BeltBlockType.repeat),
      BeltBlock(BeltBlockType.ifYellowToBinA),
      BeltBlock(BeltBlockType.ifPurpleToBinB),
    ];

    for (final step in executor.expand(program)) {
      final outcome = executor.applyStep(cursor, step.type);
      expect(outcome.misclassified, isFalse);
      cursor = outcome.cursor;
    }

    expect(executor.evaluateFinal(cursor), BeltOutcome.win);
  });
}
