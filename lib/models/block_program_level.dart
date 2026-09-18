import 'block_program_block.dart';
import 'game_level.dart';

/// O que o Programa precisa produzir para vencer a fase — o motor
/// (`BlockProgramExecutor`) sempre checa exatamente um dos dois, nunca os
/// dois ao mesmo tempo (mesmo espírito de "chegar no Alvo" do Mundo 1: um
/// único critério de vitória por fase).
enum BlockProgramGoal {
  /// Vitória quando o Total acumulado (`addToTotal`/`addToTotalIfEven`)
  /// bate com `BlockProgramLevel.targetValue`.
  total,

  /// Vitória quando o Contador acumulado (`countPlusOne`/
  /// `countPlusOneIfOdd`) bate com `BlockProgramLevel.targetValue`.
  count,
}

/// Uma fase de "Programação em Blocos" (Mundo 4, "Decisões em Bloco",
/// `WorldGameType.blockProgram`): o jogador monta um Programa de
/// `BlockProgramBlock`s que processa `numbers` e produz um Total ou
/// Contador (conforme `goal`), comparado a `targetValue`. Mesma forma geral
/// de `Level` (id/world/number/title/maxBlocks/optimalBlocks/hintProgram),
/// mas sem tabuleiro — o "estado" da fase é a lista de números e o
/// problema em português (`problem`) que a descreve. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Programação em Blocos". O mundo
/// irmão original desta mecânica ("Oficina de Blocos", sem condicionais)
/// saiu do jogo — ver `.claude/memory/decisions.md`, entrada de
/// 2026-09-18.
class BlockProgramLevel implements GameLevel {
  @override
  final String id;
  final int world;

  /// Posição da fase dentro do mundo (1-12) — usada na Seleção de Fases e
  /// no cabeçalho da Gameplay ("FASE N").
  final int number;

  /// Instrução curta mostrada no cabeçalho da Gameplay (ex.: "Some tudo").
  final String title;

  /// O probleminha real em português, mostrado por inteiro na tela (ex.:
  /// "Some todos os números da lista.").
  final String problem;

  /// A lista de números de entrada da fase, na ordem em que o Programa os
  /// processa.
  final List<int> numbers;

  final BlockProgramGoal goal;

  /// Valor que o Total/Contador final (conforme `goal`) precisa bater para
  /// vencer a fase.
  final int targetValue;

  final int maxBlocks;

  /// Quantidade de blocos da melhor solução conhecida — usado para calcular
  /// estrelas/pontos (ver `lib/game/scoring.dart`, `computeScore` — mesma
  /// fórmula de blocos usados vs. ótimo dos Mundos 1/2, não a fórmula por
  /// tentativas dos mundos de veredito único) e para a Dica da tela de
  /// Tentativa Falha.
  final int optimalBlocks;

  /// Uma solução válida conhecida da fase (não necessariamente a única),
  /// mostrada como Dica quando o jogador falha.
  final List<BlockProgramBlock> hintProgram;

  /// Quantos blocos do **início** de `hintProgram` já vêm prontos/fixos na
  /// fase (mostrados como código já escrito, não removíveis) — o jogador só
  /// precisa completar o restante. `0` (default) é o comportamento original:
  /// o jogador monta o Programa inteiro do zero. Esmaecimento progressivo
  /// pedido pelo usuário (referência: EduBlocks — cada bloco já mostra a
  /// linha de código real nele — e a pesquisa sobre transição gradual
  /// blocos→texto): ao longo das 12 fases de `world4Levels`, a proporção de
  /// `prefilledCount`/`hintProgram.length` cresce, terminando a Trilha 2
  /// (Mundo 4 é o último) quase lendo/completando código puro, na porta de
  /// entrada da Trilha 3. Ver `.claude/memory/decisions.md`, entrada de
  /// 2026-09-18.
  ///
  /// **Nunca corta um par "Para cada número" + bloco-alvo** entre o prefixo
  /// fixo e a parte editável — só pode terminar depois de um par completo
  /// (ou depois de um bloco solto), a mesma regra de pareamento de 1 nível
  /// só que `resolveBlockProgramEntries`
  /// (`lib/game/block_program_executor.dart`) já usa para interpretar o
  /// Programa. Quem monta `world4Levels` é responsável por respeitar essa
  /// regra ao escolher o valor — não há validação em runtime.
  final int prefilledCount;

  const BlockProgramLevel({
    required this.id,
    required this.world,
    required this.number,
    required this.title,
    required this.problem,
    required this.numbers,
    required this.goal,
    required this.targetValue,
    required this.maxBlocks,
    required this.optimalBlocks,
    required this.hintProgram,
    this.prefilledCount = 0,
  });
}

/// As 12 fases do Mundo 4 ("Decisões em Bloco"): acrescenta os 2 blocos
/// condicionais (`addToTotalIfEven`/`countPlusOneIfOdd`) aos 3 básicos
/// (`forEachNumber`/`addToTotal`/`countPlusOne`). Fases 1-2 introduzem os
/// condicionais sozinhos (sem `forEachNumber`, um bloco por número, mesmo
/// papel didático de `Andar` sozinho antes de `Repetir` no Mundo 1); a
/// partir da Fase 3, `forEachNumber` combinado com um bloco condicional
/// resolve listas de qualquer tamanho em só 2 blocos, mesmo com a condição
/// filtrando parte dos números. A partir da Fase 5, `prefilledCount` cresce
/// (1, 1, 2, 3, 3, 4, 5, 6 nas Fases 5-12) — os primeiros blocos soltos do
/// `hintProgram` (mesmo tipo do par que vem depois) já chegam prontos, e o
/// jogador só completa com o par `forEachNumber` + bloco-alvo (2 blocos)
/// restante; a Fase 12 chega a `optimalBlocks == maxBlocks` (8), maioria já
/// escrita, só o par final para completar — esmaecimento progressivo rumo à
/// Trilha 3 (código de verdade). Dados consistentes verificados em
/// `test/game/block_program_catalog_test.dart`.
final world4Levels = <BlockProgramLevel>[
  BlockProgramLevel(
    id: 'world4_level1',
    world: 4,
    number: 1,
    title: 'Só os pares',
    problem: 'Some apenas os números pares da lista.',
    numbers: const [2, 3],
    goal: BlockProgramGoal.total,
    targetValue: 2,
    maxBlocks: 8,
    optimalBlocks: 2,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level2',
    world: 4,
    number: 2,
    title: 'Conte os ímpares',
    problem: 'Conte quantos números ímpares tem na lista.',
    numbers: const [1, 2, 3, 4],
    goal: BlockProgramGoal.count,
    targetValue: 2,
    maxBlocks: 8,
    optimalBlocks: 4,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level3',
    world: 4,
    number: 3,
    title: 'Só os pares',
    problem: 'Some apenas os números pares da lista.',
    numbers: const [2, 3, 4, 5, 6],
    goal: BlockProgramGoal.total,
    targetValue: 12,
    maxBlocks: 8,
    optimalBlocks: 2,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level4',
    world: 4,
    number: 4,
    title: 'Conte os ímpares',
    problem: 'Conte quantos números ímpares tem na lista.',
    numbers: const [1, 2, 3, 4, 5, 6, 7],
    goal: BlockProgramGoal.count,
    targetValue: 4,
    maxBlocks: 8,
    optimalBlocks: 2,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
    ],
  ),
  // A partir daqui (Fases 5-12), `prefilledCount` cresce — os primeiros N
  // blocos do `hintProgram` (sempre `addToTotalIfEven`/`countPlusOneIfOdd`
  // soltos, um por número, do mesmo tipo do par que vem depois) já chegam
  // fixos/prontos; o jogador só precisa completar com o par "Para cada
  // número" + bloco-alvo (2 blocos) para os números restantes. Isso não muda
  // `targetValue` em relação à versão anterior (só forEachNumber+alvo, sem
  // prefixo): cada número da lista continua sendo avaliado exatamente uma
  // vez pela mesma regra condicional, só que os primeiros N são avaliados
  // pelos blocos soltos fixos, e o resto pelo par que o jogador adiciona —
  // ver `BlockProgramExecutor.applyStep`/`expand` e
  // `.claude/memory/decisions.md`, entrada de 2026-09-18 ("Mundo 4:
  // esmaecimento progressivo").
  BlockProgramLevel(
    id: 'world4_level5',
    world: 4,
    number: 5,
    title: 'Só os pares',
    problem: 'Some apenas os números pares da lista.',
    numbers: const [10, 15, 20, 25, 30],
    goal: BlockProgramGoal.total,
    targetValue: 60,
    maxBlocks: 8,
    optimalBlocks: 3,
    prefilledCount: 1,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level6',
    world: 4,
    number: 6,
    title: 'Conte os ímpares',
    problem: 'Conte quantos números ímpares tem na lista.',
    numbers: const [3, 4, 5, 6, 7, 8],
    goal: BlockProgramGoal.count,
    targetValue: 3,
    maxBlocks: 8,
    optimalBlocks: 3,
    prefilledCount: 1,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level7',
    world: 4,
    number: 7,
    title: 'Só os pares',
    problem: 'Some apenas os números pares da lista.',
    numbers: const [11, 12, 13, 14, 15, 16, 17],
    goal: BlockProgramGoal.total,
    targetValue: 42,
    maxBlocks: 8,
    optimalBlocks: 4,
    prefilledCount: 2,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level8',
    world: 4,
    number: 8,
    title: 'Conte os ímpares',
    problem: 'Conte quantos números ímpares tem na lista.',
    numbers: const [2, 4, 6, 8, 9, 11, 13, 15],
    goal: BlockProgramGoal.count,
    targetValue: 4,
    maxBlocks: 8,
    optimalBlocks: 5,
    prefilledCount: 3,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level9',
    world: 4,
    number: 9,
    title: 'Só os pares',
    problem: 'Some apenas os números pares da lista.',
    numbers: const [5, 10, 15, 20, 25, 30, 35, 40, 45],
    goal: BlockProgramGoal.total,
    targetValue: 100,
    maxBlocks: 8,
    optimalBlocks: 5,
    prefilledCount: 3,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level10',
    world: 4,
    number: 10,
    title: 'Conte os ímpares',
    problem: 'Conte quantos números ímpares tem na lista.',
    numbers: const [1, 3, 5, 7, 9, 11, 13, 15, 17, 19],
    goal: BlockProgramGoal.count,
    targetValue: 10,
    maxBlocks: 8,
    optimalBlocks: 6,
    prefilledCount: 4,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.countPlusOneIfOdd),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level11',
    world: 4,
    number: 11,
    title: 'Só os pares',
    problem: 'Some apenas os números pares da lista.',
    numbers: const [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22],
    goal: BlockProgramGoal.total,
    targetValue: 132,
    maxBlocks: 8,
    optimalBlocks: 7,
    prefilledCount: 5,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
    ],
  ),
  BlockProgramLevel(
    id: 'world4_level12',
    world: 4,
    number: 12,
    title: 'Fim do Mundo 4',
    problem: 'Some apenas os números pares da lista.',
    numbers: const [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36],
    goal: BlockProgramGoal.total,
    targetValue: 126,
    maxBlocks: 8,
    optimalBlocks: 8,
    prefilledCount: 6,
    hintProgram: const [
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
      BlockProgramBlock(BlockProgramBlockType.forEachNumber),
      BlockProgramBlock(BlockProgramBlockType.addToTotalIfEven),
    ],
  ),
];
