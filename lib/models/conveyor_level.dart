import 'belt_block.dart';
import 'belt_item.dart';
import 'game_level.dart';

/// Uma fase da Esteira: fila de Itens, limite de blocos e Dica. Mesma forma
/// de `Level` (Mundo 1, `lib/models/level.dart`), mas sem grid — o objetivo
/// aqui é classificar toda a fila corretamente, não chegar num alvo. Ver
/// `.claude/memory/domain-glossary.md` e `.claude/rules/naming.md` (id
/// estável e único, nunca reaproveitado). `ConveyorLevel` é o formato de
/// fase do mini-jogo de esteira (Mundo 2, `WorldGameType.conveyor`).
class ConveyorLevel implements GameLevel {
  @override
  final String id;
  final int world;

  /// Posição da fase dentro do mundo (1-12) — usada na Seleção de Fases e
  /// no cabeçalho da Gameplay ("FASE N").
  final int number;

  /// Instrução curta mostrada no cabeçalho da Gameplay (ex.: "Duas cores").
  final String title;

  /// A fila de Itens da fase, na ordem em que chegam na Esteira. Fixa e
  /// conhecida antes de o jogador montar o Programa (sem aleatoriedade).
  final List<BeltItemColor> itemQueue;

  final int maxBlocks;

  /// Quantidade de blocos da melhor solução conhecida — usado para calcular
  /// estrelas/pontos (ver `lib/game/scoring.dart`) e para a Dica da tela de
  /// Tentativa Falha.
  final int optimalBlocks;

  /// Uma solução válida conhecida da fase (não necessariamente a única),
  /// mostrada como Dica quando o jogador falha. Ver
  /// `.claude/docs/GAME_DESIGN.md`.
  final List<BeltBlock> hintProgram;

  const ConveyorLevel({
    required this.id,
    required this.world,
    required this.number,
    required this.title,
    required this.itemQueue,
    required this.maxBlocks,
    required this.optimalBlocks,
    required this.hintProgram,
  });
}

/// As 12 fases do Mundo 2 ("Esteira de Bugs"), em ordem de dificuldade
/// crescente: filas mais longas, misturas de cor que exigem trocar de bloco
/// no meio, uso obrigatório de `Repetir` para caber no `maxBlocks` nas fases
/// intermediárias, e a partir da Fase 9, sequências de itens da mesma cor
/// com comprimento que não é múltiplo de 3 (ex.: 4, 5 itens seguidos) —
/// onde `Enquanto` (`BeltBlockType.whileYellowToBinA`/`whilePurpleToBinB`)
/// passa a ser a solução mais eficiente (Fase 9) e depois obrigatória para
/// caber no `maxBlocks` (Fases 10-12, onde só `Repetir 3×`+`Se` avulso
/// ultrapassaria os 8 blocos). Cada `hintProgram` é uma solução verificada
/// — ver `test/game/conveyor_level_catalog_test.dart`.
final world2Levels = <ConveyorLevel>[
  ConveyorLevel(
    id: 'world2_level1',
    world: 2,
    number: 1,
    title: 'Separe um item',
    itemQueue: const [BeltItemColor.yellow],
    maxBlocks: 8,
    optimalBlocks: 1,
    hintProgram: const [BeltBlock(BeltBlockType.ifYellowToBinA)],
  ),
  ConveyorLevel(
    id: 'world2_level2',
    world: 2,
    number: 2,
    title: 'Duas cores',
    itemQueue: const [BeltItemColor.yellow, BeltItemColor.purple],
    maxBlocks: 8,
    optimalBlocks: 2,
    hintProgram: const [BeltBlock(BeltBlockType.ifYellowToBinA), BeltBlock(BeltBlockType.ifPurpleToBinB)],
  ),
  ConveyorLevel(
    id: 'world2_level3',
    world: 2,
    number: 3,
    title: 'Troque de caixa',
    itemQueue: const [BeltItemColor.purple, BeltItemColor.yellow, BeltItemColor.purple],
    maxBlocks: 8,
    optimalBlocks: 3,
    hintProgram: const [
      BeltBlock(BeltBlockType.ifPurpleToBinB),
      BeltBlock(BeltBlockType.ifYellowToBinA),
      BeltBlock(BeltBlockType.ifPurpleToBinB),
    ],
  ),
  ConveyorLevel(
    id: 'world2_level4',
    world: 2,
    number: 4,
    title: 'Repita 3 vezes',
    itemQueue: const [BeltItemColor.yellow, BeltItemColor.yellow, BeltItemColor.yellow],
    maxBlocks: 8,
    optimalBlocks: 2,
    hintProgram: const [BeltBlock(BeltBlockType.repeat), BeltBlock(BeltBlockType.ifYellowToBinA)],
  ),
  ConveyorLevel(
    id: 'world2_level5',
    world: 2,
    number: 5,
    title: 'Repetir e continuar',
    itemQueue: const [
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.yellow,
    ],
    maxBlocks: 8,
    optimalBlocks: 3,
    hintProgram: const [
      BeltBlock(BeltBlockType.repeat),
      BeltBlock(BeltBlockType.ifPurpleToBinB),
      BeltBlock(BeltBlockType.ifYellowToBinA),
    ],
  ),
  ConveyorLevel(
    id: 'world2_level6',
    world: 2,
    number: 6,
    title: 'Fila maior',
    itemQueue: const [
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.purple,
    ],
    maxBlocks: 8,
    optimalBlocks: 4,
    hintProgram: const [
      BeltBlock(BeltBlockType.repeat),
      BeltBlock(BeltBlockType.ifYellowToBinA),
      BeltBlock(BeltBlockType.ifPurpleToBinB),
      BeltBlock(BeltBlockType.ifPurpleToBinB),
    ],
  ),
  ConveyorLevel(
    id: 'world2_level7',
    world: 2,
    number: 7,
    title: 'Dois grupos de três',
    itemQueue: const [
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.purple,
    ],
    maxBlocks: 8,
    optimalBlocks: 4,
    hintProgram: const [
      BeltBlock(BeltBlockType.repeat),
      BeltBlock(BeltBlockType.ifYellowToBinA),
      BeltBlock(BeltBlockType.repeat),
      BeltBlock(BeltBlockType.ifPurpleToBinB),
    ],
  ),
  ConveyorLevel(
    id: 'world2_level8',
    world: 2,
    number: 8,
    title: 'Sem padrão fixo',
    itemQueue: const [
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.yellow,
    ],
    maxBlocks: 8,
    optimalBlocks: 7,
    hintProgram: const [
      BeltBlock(BeltBlockType.ifYellowToBinA),
      BeltBlock(BeltBlockType.ifPurpleToBinB),
      BeltBlock(BeltBlockType.ifYellowToBinA),
      BeltBlock(BeltBlockType.ifPurpleToBinB),
      BeltBlock(BeltBlockType.ifYellowToBinA),
      BeltBlock(BeltBlockType.ifPurpleToBinB),
      BeltBlock(BeltBlockType.ifYellowToBinA),
    ],
  ),
  ConveyorLevel(
    id: 'world2_level9',
    world: 2,
    number: 9,
    title: 'Enquanto a cor não mudar',
    // 4 amarelos + 3 roxos — o primeiro grupo (4) não é múltiplo de 3:
    // "Repetir 3×" cobre só 3 deles, sobra 1 item pra um "Se" avulso.
    // "Enquanto" resolve o grupo inteiro (de qualquer tamanho) em 1 bloco só.
    itemQueue: const [
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.purple,
    ],
    maxBlocks: 8,
    optimalBlocks: 2,
    hintProgram: const [
      BeltBlock(BeltBlockType.whileYellowToBinA),
      BeltBlock(BeltBlockType.whilePurpleToBinB),
    ],
  ),
  ConveyorLevel(
    id: 'world2_level10',
    world: 2,
    number: 10,
    title: 'Grupos que não fecham em três',
    // 5 amarelos + 2 roxos + 4 amarelos = 11 itens. Sem "Enquanto", o menor
    // programa possível fica em 9 blocos (acima do maxBlocks: 8) — "Enquanto"
    // é obrigatório aqui, não só mais eficiente.
    itemQueue: const [
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
    ],
    maxBlocks: 8,
    optimalBlocks: 3,
    hintProgram: const [
      BeltBlock(BeltBlockType.whileYellowToBinA),
      BeltBlock(BeltBlockType.whilePurpleToBinB),
      BeltBlock(BeltBlockType.whileYellowToBinA),
    ],
  ),
  ConveyorLevel(
    id: 'world2_level11',
    world: 2,
    number: 11,
    title: 'Quatro grupos irregulares',
    // 4 amarelos + 3 roxos + 5 amarelos + 2 roxos = 14 itens, em 4 grupos.
    // Sem "Enquanto" o menor programa fica em 11 blocos — impossível dentro
    // do maxBlocks: 8.
    itemQueue: const [
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.purple,
    ],
    maxBlocks: 8,
    optimalBlocks: 4,
    hintProgram: const [
      BeltBlock(BeltBlockType.whileYellowToBinA),
      BeltBlock(BeltBlockType.whilePurpleToBinB),
      BeltBlock(BeltBlockType.whileYellowToBinA),
      BeltBlock(BeltBlockType.whilePurpleToBinB),
    ],
  ),
  ConveyorLevel(
    id: 'world2_level12',
    world: 2,
    number: 12,
    title: 'Fim do Mundo 2',
    // 5 amarelos + 4 roxos + 3 amarelos = 12 itens, em 3 grupos. Sem
    // "Enquanto" o menor programa passa bem de 8 blocos — "Enquanto" é a
    // única forma de caber no maxBlocks aqui, fechando o mundo.
    itemQueue: const [
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.purple,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
      BeltItemColor.yellow,
    ],
    maxBlocks: 8,
    optimalBlocks: 3,
    hintProgram: const [
      BeltBlock(BeltBlockType.whileYellowToBinA),
      BeltBlock(BeltBlockType.whilePurpleToBinB),
      BeltBlock(BeltBlockType.whileYellowToBinA),
    ],
  ),
];
