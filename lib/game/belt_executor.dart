import '../models/belt_block.dart';
import '../models/belt_item.dart';
import '../models/conveyor_level.dart';

/// Cursor da Execução da Esteira: guarda o índice do próximo Item da fila
/// ainda não classificado. Equivalente a `GameCursor` no Mundo 1
/// (labirinto), mas sem posição/direção — só "quanto da fila já foi
/// processado".
class BeltCursor {
  final int nextItemIndex;

  const BeltCursor({required this.nextItemIndex});

  factory BeltCursor.fromStart() => const BeltCursor(nextItemIndex: 0);

  BeltCursor copyWith({int? nextItemIndex}) {
    return BeltCursor(nextItemIndex: nextItemIndex ?? this.nextItemIndex);
  }
}

/// Um Passo já expandido (depois de resolver `Repetir 3×`) do Programa da
/// Esteira, com o índice do bloco original no Programa — usado para
/// destacar o bloco em execução. Espelha `ExecutionStep` do Mundo 1.
class BeltExecutionStep {
  final int blockIndex;
  final BeltBlockType type;

  const BeltExecutionStep({required this.blockIndex, required this.type});
}

/// Resultado de aplicar um único Passo ao cursor da Esteira.
class BeltStepOutcome {
  final BeltCursor cursor;
  final bool misclassified;

  const BeltStepOutcome({required this.cursor, required this.misclassified});
}

/// Resultado final de uma Execução da Esteira. Enum próprio (não reaproveita
/// `GameOutcome` do Mundo 1) — ver `.claude/docs/GAME_DESIGN.md`, seção
/// "Mundo 2 — Esteira", e `.claude/memory/decisions.md` para o porquê.
enum BeltOutcome {
  /// Todos os Itens da fila foram classificados corretamente.
  win,

  /// Um bloco classificou um Item com a cor errada, ou sobrou um passo com
  /// a fila já vazia. Equivalente a `GameOutcome.crash` no Mundo 1.
  misclassified,

  /// O Programa terminou (todos os passos executados) sem classificar toda
  /// a fila. Equivalente a `GameOutcome.farFromGoal` no Mundo 1.
  incomplete,
}

/// Interpretador do Programa da Esteira contra uma `ConveyorLevel`. Dart
/// puro — sem Flutter (ver `.claude/rules/architecture.md`). Mesma forma de
/// `ProgramExecutor` (Mundo 1): quem anima a Execução é a Screen,
/// consumindo `expand`/`applyStep`/`evaluateFinal` passo a passo.
class BeltExecutor {
  final ConveyorLevel level;

  const BeltExecutor(this.level);

  /// Expande o Programa em Passos concretos. Diferente do Mundo 1, essa
  /// expansão é **ciente da fila** (`level.itemQueue`): como a fila é toda
  /// conhecida de antemão (sem aleatoriedade) e o motor não tem branching
  /// real (cada bloco roda exatamente uma vez, na ordem, exceto o que
  /// `repeat` expande), `expand` simula um cursor (`simulatedIndex`)
  /// progredindo pela fila **assumindo que nenhuma classificação erra** —
  /// é só uma simulação otimista para saber quantos Passos cada bloco gera.
  /// A checagem real de acerto/erro continua acontecendo depois, passo a
  /// passo, em `applyStep`, exatamente como antes.
  ///
  /// `Repetir 3×` aplica-se ao bloco imediatamente seguinte (executando-o 3
  /// vezes); um `Repetir` sem um bloco não-`repeat` logo depois (último
  /// bloco, ou seguido de outro `Repetir`) não gera nenhum passo. Mesma
  /// regra de expansão de `ProgramExecutor.expand` (Mundo 1).
  ///
  /// `Enquanto [cor]` é autocontido: gera um Passo (com `blockIndex`
  /// apontando pro próprio bloco `while`, não pro bloco seguinte) para cada
  /// item consecutivo da cor esperada a partir de `simulatedIndex`, parando
  /// no primeiro item de cor diferente ou no fim da fila — inclusive zero
  /// Passos se a condição já começa falsa.
  List<BeltExecutionStep> expand(List<BeltBlock> program) {
    final steps = <BeltExecutionStep>[];
    var simulatedIndex = 0;

    // Gera os Passos de um único bloco (`if`/`while`) já resolvido — usado
    // tanto para blocos soltos quanto para o bloco alvo de um `repeat`
    // (reaproveitado, não duplicado), avançando `simulatedIndex` de acordo.
    void emitStepsFor(int blockIndex, BeltBlockType type) {
      switch (type) {
        case BeltBlockType.ifYellowToBinA:
        case BeltBlockType.ifPurpleToBinB:
          steps.add(BeltExecutionStep(blockIndex: blockIndex, type: type));
          simulatedIndex++;
        case BeltBlockType.whileYellowToBinA:
        case BeltBlockType.whilePurpleToBinB:
          final expectedColor = type == BeltBlockType.whileYellowToBinA ? BeltItemColor.yellow : BeltItemColor.purple;
          while (simulatedIndex < level.itemQueue.length && level.itemQueue[simulatedIndex] == expectedColor) {
            steps.add(BeltExecutionStep(blockIndex: blockIndex, type: type));
            simulatedIndex++;
          }
        case BeltBlockType.repeat:
          // Não deveria ocorrer: `repeat` nunca é passado como bloco alvo
          // (só `program[i]` puro chega aqui como `repeat`, tratado pelo
          // laço principal abaixo, nunca via `emitStepsFor`).
          break;
      }
    }

    for (var i = 0; i < program.length; i++) {
      final block = program[i];
      if (block.type == BeltBlockType.repeat) {
        final hasNext = i + 1 < program.length;
        final next = hasNext ? program[i + 1] : null;
        if (next != null && next.type != BeltBlockType.repeat) {
          for (var k = 0; k < 3; k++) {
            emitStepsFor(i + 1, next.type);
          }
          i++;
        }
      } else {
        emitStepsFor(i, block.type);
      }
    }
    return steps;
  }

  /// Aplica um único Passo ao cursor. `misclassified: true` quando o bloco
  /// não bate com a cor do Item na posição atual da fila, ou quando não há
  /// mais Itens a classificar (passo sobrando com a fila já vazia).
  ///
  /// `whileYellowToBinA`/`whilePurpleToBinB` são tratados exatamente igual
  /// a `ifYellowToBinA`/`ifPurpleToBinB` aqui (mesma cor esperada, mesma
  /// lógica de avançar o cursor) — a garantia de "Enquanto nunca falha" vem
  /// inteiramente de `expand()` só gerar Passos `while` quando a cor já
  /// bate (simulação otimista); não há caso especial aqui, de propósito.
  BeltStepOutcome applyStep(BeltCursor cursor, BeltBlockType type) {
    if (cursor.nextItemIndex >= level.itemQueue.length) {
      return BeltStepOutcome(cursor: cursor, misclassified: true);
    }

    final item = level.itemQueue[cursor.nextItemIndex];
    final expectedColor = switch (type) {
      BeltBlockType.ifYellowToBinA => BeltItemColor.yellow,
      BeltBlockType.ifPurpleToBinB => BeltItemColor.purple,
      BeltBlockType.whileYellowToBinA => BeltItemColor.yellow,
      BeltBlockType.whilePurpleToBinB => BeltItemColor.purple,
      // Não deveria ocorrer pós-`expand` — tratado como classificação
      // errada defensiva (nenhum `repeat` sobrevive à expansão).
      BeltBlockType.repeat => null,
    };

    if (expectedColor == null || item != expectedColor) {
      return BeltStepOutcome(cursor: cursor, misclassified: true);
    }

    return BeltStepOutcome(
      cursor: cursor.copyWith(nextItemIndex: cursor.nextItemIndex + 1),
      misclassified: false,
    );
  }

  /// Resultado quando o Programa termina sem erro de classificação:
  /// vitória se toda a fila foi processada.
  BeltOutcome evaluateFinal(BeltCursor cursor) {
    return cursor.nextItemIndex >= level.itemQueue.length ? BeltOutcome.win : BeltOutcome.incomplete;
  }
}
