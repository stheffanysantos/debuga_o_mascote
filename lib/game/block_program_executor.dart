import '../models/block_program_block.dart';
import '../models/block_program_level.dart';

/// Cursor da Execução de "Programação em Blocos": guarda quanto da lista de
/// números já foi processado e o Total/Contador acumulados até agora.
/// Equivalente a `GameCursor` (Mundo 1, posição/direção) e `BeltCursor`
/// (Mundo 2, próximo item da fila), mas acumulando um resultado numérico em
/// vez de posição/classificação.
class BlockProgramCursor {
  final int nextNumberIndex;
  final int total;
  final int count;

  const BlockProgramCursor({required this.nextNumberIndex, required this.total, required this.count});

  factory BlockProgramCursor.fromStart() => const BlockProgramCursor(nextNumberIndex: 0, total: 0, count: 0);

  BlockProgramCursor copyWith({int? nextNumberIndex, int? total, int? count}) {
    return BlockProgramCursor(
      nextNumberIndex: nextNumberIndex ?? this.nextNumberIndex,
      total: total ?? this.total,
      count: count ?? this.count,
    );
  }
}

/// Um Passo já expandido (depois de resolver `Para cada número`) do
/// Programa, com o índice do bloco original no Programa — usado para
/// destacar o bloco em execução. Espelha `ExecutionStep`/`BeltExecutionStep`.
class BlockProgramExecutionStep {
  final int blockIndex;
  final BlockProgramBlockType type;

  const BlockProgramExecutionStep({required this.blockIndex, required this.type});
}

/// Resultado de aplicar um único Passo ao cursor.
class BlockProgramStepOutcome {
  final BlockProgramCursor cursor;

  const BlockProgramStepOutcome({required this.cursor});
}

/// Um bloco-alvo já resolvido do Programa (depois de decidir se está "dentro
/// de" um "Para cada número" ou solto) — `blockIndex` é a posição do
/// bloco-alvo no Programa original (não do `forEachNumber` que o precede,
/// quando houver). Usado tanto por `BlockProgramExecutor.expand` (que
/// multiplica cada entrada `insideForEach` por `level.numbers.length`)
/// quanto pelo painel "Tradutor de Blocos" (`codeLinesFor`,
/// `lib/widgets/block_program_chip_style.dart`) — uma única fonte da regra
/// de pareamento "`forEachNumber` só se aplica ao próximo bloco
/// não-modificador", pra nunca divergir entre os dois (achado do Code
/// Reviewer: eram 2 cópias independentes da mesma regra).
class BlockProgramProgramEntry {
  final int blockIndex;
  final BlockProgramBlockType targetType;
  final bool insideForEach;

  const BlockProgramProgramEntry({required this.blockIndex, required this.targetType, required this.insideForEach});
}

/// Resolve o Programa em `BlockProgramProgramEntry`s, na ordem — mesma regra
/// de modificador de 1 nível só (sem stacking) já usada por `Repetir`/
/// `Enquanto` nos outros mundos. Um "Para cada número" sem um bloco
/// não-modificador logo depois (último bloco, ou seguido de outro "Para
/// cada número") não gera nenhuma entrada.
List<BlockProgramProgramEntry> resolveBlockProgramEntries(List<BlockProgramBlock> program) {
  final entries = <BlockProgramProgramEntry>[];
  for (var i = 0; i < program.length; i++) {
    final block = program[i];
    if (block.type == BlockProgramBlockType.forEachNumber) {
      final hasNext = i + 1 < program.length;
      final next = hasNext ? program[i + 1] : null;
      if (next != null && next.type != BlockProgramBlockType.forEachNumber) {
        entries.add(BlockProgramProgramEntry(blockIndex: i + 1, targetType: next.type, insideForEach: true));
        i++;
      }
      continue;
    }
    entries.add(BlockProgramProgramEntry(blockIndex: i, targetType: block.type, insideForEach: false));
  }
  return entries;
}

/// Resultado final de uma Execução de "Programação em Blocos". Enum próprio
/// (não reaproveita `GameOutcome`/`BeltOutcome`) — não há tabuleiro/parede
/// nem fila a esvaziar, só um resultado numérico certo ou errado. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Programação em Blocos".
enum BlockProgramOutcome {
  /// O Total/Contador final (conforme `BlockProgramLevel.goal`) bate com
  /// `targetValue`.
  win,

  /// O Programa terminou, mas o resultado não bate com `targetValue`.
  wrongResult,
}

/// Interpretador do Programa de "Programação em Blocos" (Mundos 3 e 4)
/// contra uma `BlockProgramLevel`. Dart puro — sem Flutter (ver
/// `.claude/rules/architecture.md`). Mesma forma de `ProgramExecutor`/
/// `BeltExecutor`: quem anima a Execução é a View, consumindo
/// `expand`/`applyStep`/`evaluateFinal` passo a passo.
class BlockProgramExecutor {
  final BlockProgramLevel level;

  const BlockProgramExecutor(this.level);

  /// Expande o Programa em Passos concretos. `Para cada número` aplica-se
  /// ao bloco imediatamente seguinte, executando-o uma vez **por número da
  /// lista da fase** (`level.numbers.length` vezes — contagem fixa,
  /// conhecida de antemão a partir do tamanho da lista, não do conteúdo
  /// dela) — mesmo algoritmo de `ProgramExecutor.expand`/
  /// `BeltExecutor.expand` ao tratar `Repetir` (modificador de 1 nível só,
  /// olha só o bloco seguinte; sem stacking de 2 modificadores). Um "Para
  /// cada número" sem um bloco não-modificador logo depois (último bloco,
  /// ou seguido de outro "Para cada número") não gera nenhum passo — mesma
  /// regra de `Repetir` sem bloco seguinte válido.
  ///
  /// Um bloco-alvo usado **sem** "Para cada número" antes (solto no
  /// Programa) é perfeitamente válido: gera exatamente 1 Passo, processando
  /// só o próximo número ainda não consumido — não há "erro" possível por
  /// bloco isolado neste motor (diferente de `Se`/`Enquanto` da Esteira,
  /// aqui não existe conceito de "bater com a cor errada"); o único
  /// resultado que pode dar errado é o Total/Contador final não bater com
  /// `targetValue`, checado só em `evaluateFinal`.
  List<BlockProgramExecutionStep> expand(List<BlockProgramBlock> program) {
    final steps = <BlockProgramExecutionStep>[];
    for (final entry in resolveBlockProgramEntries(program)) {
      final repeatCount = entry.insideForEach ? level.numbers.length : 1;
      for (var k = 0; k < repeatCount; k++) {
        steps.add(BlockProgramExecutionStep(blockIndex: entry.blockIndex, type: entry.targetType));
      }
    }
    return steps;
  }

  /// Aplica um único Passo ao cursor: consome o próximo número ainda não
  /// processado (`cursor.nextNumberIndex`) e atualiza Total/Contador
  /// conforme o tipo do bloco. Sem falha por passo — se não houver mais
  /// números a processar (Programa gerou mais Passos do que itens na
  /// lista), o Passo simplesmente não faz nada (cursor inalterado), nunca
  /// classificado como erro: o único veredito deste motor é o resultado
  /// final (`evaluateFinal`).
  BlockProgramStepOutcome applyStep(BlockProgramCursor cursor, BlockProgramBlockType type) {
    if (cursor.nextNumberIndex >= level.numbers.length) {
      return BlockProgramStepOutcome(cursor: cursor);
    }

    final number = level.numbers[cursor.nextNumberIndex];
    var total = cursor.total;
    var count = cursor.count;

    switch (type) {
      case BlockProgramBlockType.addToTotal:
        total += number;
      case BlockProgramBlockType.countPlusOne:
        count += 1;
      case BlockProgramBlockType.addToTotalIfEven:
        if (number % 2 == 0) total += number;
      case BlockProgramBlockType.countPlusOneIfOdd:
        if (number % 2 != 0) count += 1;
      case BlockProgramBlockType.forEachNumber:
        // Não deveria ocorrer: `forEachNumber` nunca sobrevive à expansão
        // como bloco-alvo (só o laço principal de `expand` o trata, nunca
        // chega aqui).
        break;
    }

    return BlockProgramStepOutcome(cursor: cursor.copyWith(nextNumberIndex: cursor.nextNumberIndex + 1, total: total, count: count));
  }

  /// Resultado final: vitória se o Total/Contador (conforme `level.goal`)
  /// bate exatamente com `level.targetValue`.
  BlockProgramOutcome evaluateFinal(BlockProgramCursor cursor) {
    final result = level.goal == BlockProgramGoal.total ? cursor.total : cursor.count;
    return result == level.targetValue ? BlockProgramOutcome.win : BlockProgramOutcome.wrongResult;
  }
}
