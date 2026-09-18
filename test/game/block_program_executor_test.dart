import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/block_program_executor.dart';
import 'package:debuga_o_mascote/models/block_program_block.dart';
import 'package:debuga_o_mascote/models/block_program_level.dart';

BlockProgramOutcome _run(BlockProgramLevel level, List<BlockProgramBlock> program) {
  final executor = BlockProgramExecutor(level);
  var cursor = BlockProgramCursor.fromStart();
  for (final step in executor.expand(program)) {
    cursor = executor.applyStep(cursor, step.type).cursor;
  }
  return executor.evaluateFinal(cursor);
}

void main() {
  group('soma simples', () {
    const level = BlockProgramLevel(
      id: 'test_sum',
      world: 3,
      number: 1,
      title: 'Teste',
      problem: 'Some todos os números da lista.',
      numbers: [1, 2, 3, 4],
      goal: BlockProgramGoal.total,
      targetValue: 10,
      maxBlocks: 8,
      optimalBlocks: 2,
      hintProgram: [BlockProgramBlock(BlockProgramBlockType.forEachNumber), BlockProgramBlock(BlockProgramBlockType.addToTotal)],
    );

    test('"Para cada número" + "Some ao Total" soma a lista inteira', () {
      expect(_run(level, level.hintProgram), BlockProgramOutcome.win);
    });

    test('blocos "Some ao Total" avulsos, um por número, também vencem', () {
      final program = [
        const BlockProgramBlock(BlockProgramBlockType.addToTotal),
        const BlockProgramBlock(BlockProgramBlockType.addToTotal),
        const BlockProgramBlock(BlockProgramBlockType.addToTotal),
        const BlockProgramBlock(BlockProgramBlockType.addToTotal),
      ];
      expect(_run(level, program), BlockProgramOutcome.win);
    });

    test('somar menos números do que a lista tem dá resultado errado', () {
      final program = [
        const BlockProgramBlock(BlockProgramBlockType.addToTotal),
        const BlockProgramBlock(BlockProgramBlockType.addToTotal),
      ];
      expect(_run(level, program), BlockProgramOutcome.wrongResult);
    });
  });

  group('contagem simples', () {
    const level = BlockProgramLevel(
      id: 'test_count',
      world: 3,
      number: 2,
      title: 'Teste',
      problem: 'Conte quantos números tem na lista.',
      numbers: [9, 9, 9, 9, 9],
      goal: BlockProgramGoal.count,
      targetValue: 5,
      maxBlocks: 8,
      optimalBlocks: 2,
      hintProgram: [BlockProgramBlock(BlockProgramBlockType.forEachNumber), BlockProgramBlock(BlockProgramBlockType.countPlusOne)],
    );

    test('"Para cada número" + "Conte +1" conta a lista inteira, ignorando o valor', () {
      expect(_run(level, level.hintProgram), BlockProgramOutcome.win);
    });
  });

  group('condicional par/ímpar', () {
    const evenLevel = BlockProgramLevel(
      id: 'test_even',
      world: 4,
      number: 1,
      title: 'Teste',
      problem: 'Some apenas os números pares da lista.',
      numbers: [1, 2, 3, 4, 5, 6],
      goal: BlockProgramGoal.total,
      targetValue: 12, // 2 + 4 + 6
      maxBlocks: 8,
      optimalBlocks: 2,
      hintProgram: [
        BlockProgramBlock(BlockProgramBlockType.forEachNumber),
        BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      ],
    );

    test('"Some os pares" soma só os números pares', () {
      expect(_run(evenLevel, evenLevel.hintProgram), BlockProgramOutcome.win);
    });

    const oddLevel = BlockProgramLevel(
      id: 'test_odd',
      world: 4,
      number: 2,
      title: 'Teste',
      problem: 'Conte quantos números ímpares tem na lista.',
      numbers: [1, 2, 3, 4, 5, 6, 7],
      goal: BlockProgramGoal.count,
      targetValue: 4, // 1, 3, 5, 7
      maxBlocks: 8,
      optimalBlocks: 2,
      hintProgram: [
        BlockProgramBlock(BlockProgramBlockType.forEachNumber),
        BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      ],
    );

    test('"Conte os ímpares" conta só os números ímpares', () {
      expect(_run(oddLevel, oddLevel.hintProgram), BlockProgramOutcome.win);
    });

    test('condicional não erra: número que não bate com a condição só não conta, não falha', () {
      // Um "Some os pares" avulso aplicado a um número ímpar não
      // deveria travar/errar — só não soma nada e consome o número mesmo
      // assim (mesmo espírito de "Enquanto nunca falha" do Mundo 2).
      const level = BlockProgramLevel(
        id: 'test_odd_number_even_block',
        world: 4,
        number: 3,
        title: 'Teste',
        problem: 'Some apenas os números pares da lista.',
        numbers: [3],
        goal: BlockProgramGoal.total,
        targetValue: 0,
        maxBlocks: 8,
        optimalBlocks: 1,
        hintProgram: [BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven)],
      );
      expect(_run(level, level.hintProgram), BlockProgramOutcome.win);
    });
  });

  group('bloco-alvo usado sem "Para cada número" antes', () {
    // Regra escolhida (documentada em `BlockProgramExecutor.expand`): um
    // bloco-alvo solto no Programa é válido e processa exatamente 1 número
    // (o próximo ainda não consumido) — não existe "erro por bloco" neste
    // motor, mesmo estilo de "Enquanto nunca falha" (Mundo 2), só que levado
    // ao extremo: aqui não há nenhuma checagem de correção por passo, só o
    // resultado final.
    const level = BlockProgramLevel(
      id: 'test_standalone',
      world: 3,
      number: 3,
      title: 'Teste',
      problem: 'Some o número da lista.',
      numbers: [7],
      goal: BlockProgramGoal.total,
      targetValue: 7,
      maxBlocks: 8,
      optimalBlocks: 1,
      hintProgram: [BlockProgramBlock(BlockProgramBlockType.addToTotal)],
    );

    test('um "Some ao Total" avulso processa exatamente 1 número e vence', () {
      expect(_run(level, level.hintProgram), BlockProgramOutcome.win);
    });

    test('um bloco-alvo avulso além do fim da lista não faz nada (sem falha)', () {
      final program = [
        const BlockProgramBlock(BlockProgramBlockType.addToTotal),
        const BlockProgramBlock(BlockProgramBlockType.addToTotal), // sobra, sem número pra processar
      ];
      expect(_run(level, program), BlockProgramOutcome.win);
    });
  });

  group('"Para cada número" sem bloco seguinte válido', () {
    const level = BlockProgramLevel(
      id: 'test_dangling_foreach',
      world: 3,
      number: 4,
      title: 'Teste',
      problem: 'Some o número da lista.',
      numbers: [7],
      goal: BlockProgramGoal.total,
      targetValue: 0,
      maxBlocks: 8,
      optimalBlocks: 1,
      hintProgram: [BlockProgramBlock(BlockProgramBlockType.forEachNumber)],
    );

    test('"Para cada número" como último bloco não gera nenhum passo', () {
      final executor = BlockProgramExecutor(level);
      expect(executor.expand(level.hintProgram), isEmpty);
    });
  });
}
