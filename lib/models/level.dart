import 'block.dart';
import 'block_program_level.dart';
import 'code_puzzle_level.dart';
import 'complete_code_level.dart';
import 'game_level.dart';
import 'predict_output_level.dart';

/// Direção para a qual o Mascote está olhando. A ordem importa: gira em
/// sentido horário (right -> down -> left -> up -> right).
enum FacingDirection { right, down, left, up }

/// Uma célula do Tabuleiro (coordenadas de grade, não pixels).
class GridPosition {
  final int x;
  final int y;

  const GridPosition(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is GridPosition && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// Uma fase: tabuleiro, posição/direção inicial, alvo e limite de blocos.
/// Ver `.claude/memory/domain-glossary.md` e `.claude/rules/naming.md` (id
/// estável e único, nunca reaproveitado). `Level` é o formato de fase do
/// mini-jogo de labirinto — compartilhado pelos Mundos 1 ("Primeiros
/// passos"), 2 ("Resgate de Personagens") e 3 ("Desenho no Tabuleiro"), todos
/// `WorldGameType.maze`, diferenciados só pelo conteúdo de cada fase (ver
/// `GameWorld` mais abaixo). `collectibles`/`collectTarget`/`paintTarget`
/// são opcionais (default vazio/nulo) — o Mundo 1 não usa nenhum dos três,
/// e `world1Levels` continua funcionando exatamente como antes. Ver
/// `.claude/memory/decisions.md`, entradas de 2026-09-18.
class Level implements GameLevel {
  @override
  final String id;
  final int world;

  /// Posição da fase dentro do mundo (1-12) — usada na Seleção de Fases e
  /// no cabeçalho da Gameplay ("FASE N").
  final int number;

  /// Instrução curta mostrada no cabeçalho da Gameplay (ex.: "Vire à
  /// direita").
  final String title;

  final int gridSize;
  final List<GridPosition> walls;
  final GridPosition start;
  final FacingDirection startDirection;
  final GridPosition goal;
  final int maxBlocks;

  /// Quantidade de blocos da melhor solução conhecida — usado para calcular
  /// estrelas/pontos (ver `lib/game/scoring.dart`) e para a Dica da tela de
  /// Tentativa Falha.
  final int optimalBlocks;

  /// Uma solução válida conhecida da fase (não necessariamente a única),
  /// mostrada como Dica quando o jogador falha. Ver
  /// `.claude/docs/GAME_DESIGN.md`.
  final List<Block> hintProgram;

  /// Células com um personagem perdido (Bit/Chip/Loopy/Libug — qual
  /// personagem aparece em cada célula é decisão cosmética da UI, não deste
  /// modelo) — só Mundo 2 ("Resgate de Personagens"), desde que o Mundo 3
  /// trocou de mecânica para "Desenho no Tabuleiro" (ver `paintTarget`
  /// abaixo e `.claude/memory/decisions.md`, entrada de 2026-09-18). Vazio
  /// (default) em fases sem personagem perdido. O bloco
  /// `BlockType.rescueIfCharacterHere` é a única forma de resgatar (andar
  /// por cima não basta mais — ver `.claude/memory/decisions.md`, entrada
  /// de 2026-09-18, "Mundo 2 v4").
  final Set<GridPosition> collectibles;

  /// Quantos personagens o jogador precisa ter resgatado ao chegar no
  /// alvo — só Mundo 2. `null` (default) significa "não importa quantos
  /// foram resgatados", o mesmo comportamento de sempre.
  final int? collectTarget;

  /// O desenho-alvo — só Mundo 3 ("Desenho no Tabuleiro"). O conjunto exato
  /// de células que precisam ficar pintadas ao final da Execução
  /// (`GameCursor.paintedTiles`), nem faltando nem sobrando nenhuma. `null`
  /// (default, Mundos 1/2) significa "esta fase não usa a mecânica de
  /// pintura" — a condição de vitória continua só "terminar no alvo". Ver
  /// `.claude/docs/GAME_DESIGN.md` e `.claude/memory/decisions.md`, entrada
  /// de 2026-09-18.
  final Set<GridPosition>? paintTarget;

  const Level({
    required this.id,
    required this.world,
    required this.number,
    required this.title,
    required this.gridSize,
    required this.walls,
    required this.start,
    required this.startDirection,
    required this.goal,
    required this.maxBlocks,
    required this.optimalBlocks,
    required this.hintProgram,
    this.collectibles = const {},
    this.collectTarget,
    this.paintTarget,
  });

  bool isWall(int x, int y) => walls.any((w) => w.x == x && w.y == y);

  bool isInside(int x, int y) =>
      x >= 0 && x < gridSize && y >= 0 && y < gridSize;

  bool isGoal(int x, int y) => x == goal.x && y == goal.y;

  /// `true` quando `(x, y)` faz parte do desenho-alvo (`paintTarget`) desta
  /// fase — sempre `false` em fases sem `paintTarget` (Mundos 1/2, e as
  /// próprias fases fora do Mundo 3).
  bool isPaintTarget(int x, int y) =>
      paintTarget?.contains(GridPosition(x, y)) ?? false;
}

/// As 12 fases do Mundo 1 ("Primeiros passos"), em ordem de dificuldade
/// crescente. Cada `hintProgram` é uma solução verificada — ver
/// `test/game/level_catalog_test.dart`.
final world1Levels = <Level>[
  Level(
    id: 'world1_level1',
    world: 1,
    number: 1,
    title: 'Ande até o alvo',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(2, 0),
    maxBlocks: 8,
    optimalBlocks: 2,
    hintProgram: const [Block(BlockType.walk), Block(BlockType.walk)],
  ),
  Level(
    id: 'world1_level2',
    world: 1,
    number: 2,
    title: 'Vire e ande',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(0, 3),
    maxBlocks: 8,
    optimalBlocks: 3,
    hintProgram: const [
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
  ),
  Level(
    id: 'world1_level3',
    world: 1,
    number: 3,
    title: 'Dois caminhos',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 3),
    maxBlocks: 8,
    optimalBlocks: 5,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
  ),
  Level(
    id: 'world1_level4',
    world: 1,
    number: 4,
    title: 'Desvie da parede',
    gridSize: 6,
    walls: const [GridPosition(2, 0)],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(2, 1),
    maxBlocks: 8,
    optimalBlocks: 5,
    hintProgram: const [
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
    ],
  ),
  Level(
    id: 'world1_level5',
    world: 1,
    number: 5,
    title: 'Contorne o bloqueio',
    gridSize: 6,
    walls: const [GridPosition(2, 0), GridPosition(2, 1)],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(2, 2),
    maxBlocks: 8,
    optimalBlocks: 6,
    hintProgram: const [
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
    ],
  ),

  /// Fase de demonstração original do design (tabuleiro 6x6, "Fase 6" do
  /// Mundo 1) — `hintProgram` verificado em
  /// `test/game/program_executor_test.dart`.
  Level(
    id: 'world1_level6',
    world: 1,
    number: 6,
    title: 'Vire à direita',
    gridSize: 6,
    walls: const [
      GridPosition(2, 4),
      GridPosition(4, 3),
      GridPosition(1, 3),
      GridPosition(5, 0),
      GridPosition(0, 1),
    ],
    start: const GridPosition(0, 5),
    startDirection: FacingDirection.up,
    goal: const GridPosition(3, 2),
    maxBlocks: 8,
    optimalBlocks: 5,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
  ),
  Level(
    id: 'world1_level7',
    world: 1,
    number: 7,
    title: 'Contorne por baixo',
    gridSize: 6,
    walls: const [GridPosition(3, 0), GridPosition(3, 1), GridPosition(3, 2)],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 3),
    maxBlocks: 8,
    optimalBlocks: 6,
    hintProgram: const [
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
  ),
  Level(
    id: 'world1_level8',
    world: 1,
    number: 8,
    title: 'Passe por cima',
    gridSize: 6,
    walls: const [GridPosition(1, 3), GridPosition(2, 3), GridPosition(3, 3)],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(4, 3),
    maxBlocks: 8,
    optimalBlocks: 6,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
  ),
  Level(
    id: 'world1_level9',
    world: 1,
    number: 9,
    title: 'Fase cheia de curvas',
    gridSize: 6,
    walls: const [
      GridPosition(2, 3),
      GridPosition(4, 2),
      GridPosition(1, 1),
      GridPosition(5, 4),
      GridPosition(0, 1),
    ],
    start: const GridPosition(0, 5),
    startDirection: FacingDirection.up,
    goal: const GridPosition(3, 1),
    maxBlocks: 8,
    optimalBlocks: 7,
    hintProgram: const [
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
  ),
  Level(
    id: 'world1_level10',
    world: 1,
    number: 10,
    title: 'Sem espaço pra errar',
    gridSize: 6,
    walls: const [
      GridPosition(1, 2),
      GridPosition(3, 0),
      GridPosition(0, 3),
      GridPosition(5, 5),
      GridPosition(4, 4),
    ],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(4, 2),
    maxBlocks: 8,
    optimalBlocks: 8,
    hintProgram: const [
      Block(BlockType.walk),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
      Block(BlockType.walk),
    ],
  ),
  Level(
    id: 'world1_level11',
    world: 1,
    number: 11,
    title: 'Bloqueio logo de cara',
    gridSize: 6,
    walls: const [GridPosition(1, 0), GridPosition(3, 2), GridPosition(0, 4)],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 3),
    maxBlocks: 8,
    optimalBlocks: 6,
    hintProgram: const [
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
  ),
  Level(
    id: 'world1_level12',
    world: 1,
    number: 12,
    title: 'Fim do Mundo 1',
    gridSize: 6,
    walls: const [
      GridPosition(4, 4),
      GridPosition(1, 2),
      GridPosition(4, 0),
      GridPosition(5, 3),
    ],
    start: const GridPosition(0, 5),
    startDirection: FacingDirection.up,
    goal: const GridPosition(3, 2),
    maxBlocks: 8,
    optimalBlocks: 6,
    hintProgram: const [
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
  ),
];

/// Fase de demonstração usada por alguns testes mais antigos — mesma
/// instância de `world1Levels[5]` ("Fase 6").
final demoLevel = world1Levels[5];

/// As 12 fases do Mundo 2 ("Resgate de Personagens"): mesmo motor do Mundo 1
/// (`Level`/`ProgramExecutor`), acrescentando **decisão** (`Se`) via
/// personagens perdidos nas células (`collectibles`/`collectTarget`) — o
/// jogador precisa usar o bloco condicional `rescueIfCharacterHere` (em
/// geral combinado com `Repetir 3×`) para resgatar quem está no caminho.
/// Substitui a antiga mecânica de Placa colorida (`Level.signs`/
/// `SignColor`, `turnLeftIfYellow`/`turnRightIfPurple`) — ver
/// `.claude/memory/decisions.md`, entrada de 2026-09-18 ("Mundo 2 v4").
///
/// `Andar` nunca resgata por si só (só `rescueIfCharacterHere` resgata, e só
/// na célula em que ele entra) — por isso todo `collectibles` abaixo cai
/// numa célula visitada por um bloco `rescueIfCharacterHere` no
/// `hintProgram` (nunca na célula `start`, que não é alcançada por nenhum
/// bloco). Progressão: Fase 1 já combina 1 corredor de resgate com
/// `Repetir 3×` **e** uma virada de verdade (pedido explícito do usuário —
/// "um pouco mais difícil" que um primeiro contato isolado, mesmo padrão já
/// usado ao redesenhar os Mundos 1/3); Fases 2-4 isolam o conceito num único
/// corredor de 3 células (via `Repetir 3× + rescueIfCharacterHere`) com
/// personagens espalhados de forma irregular (nem toda célula do corredor
/// tem um); Fases 5-9 encadeiam 2 corredores em sequência, com uma virada
/// entre eles; Fases 10-12 encadeiam 2 corredores **e** um resgate solto
/// (fora de `Repetir`) no mesmo Programa, preenchendo exatamente os 8
/// blocos do `maxBlocks` — as 3 fases mais difíceis do mundo, sem espaço pra
/// errar, com a Fase 12 sendo a mais densa (todas as 3 células do 2º
/// corredor têm personagem). `maxBlocks: 8` constante em todas (convenção
/// do projeto). Dados verificados em `test/game/world2_level_catalog_test.dart`.
/// Ver `.claude/docs/GAME_DESIGN.md` e `.claude/memory/decisions.md`
/// (entrada de 2026-09-18).
final world2Levels = <Level>[
  Level(
    id: 'world2_level1',
    world: 2,
    number: 1,
    title: 'Resgate e vire',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 2),
    maxBlocks: 8,
    optimalBlocks: 5,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.walk),
    ],
    collectibles: {GridPosition(2, 0)},
    collectTarget: 1,
  ),
  Level(
    id: 'world2_level2',
    world: 2,
    number: 2,
    title: 'Resgate no caminho',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(4, 0),
    maxBlocks: 8,
    optimalBlocks: 3,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.walk),
    ],
    collectibles: {GridPosition(1, 0), GridPosition(3, 0)},
    collectTarget: 2,
  ),
  Level(
    id: 'world2_level3',
    world: 2,
    number: 3,
    title: 'Resgate no caminho, de novo',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 5),
    startDirection: FacingDirection.right,
    goal: const GridPosition(4, 5),
    maxBlocks: 8,
    optimalBlocks: 3,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.walk),
    ],
    collectibles: {GridPosition(1, 5), GridPosition(3, 5)},
    collectTarget: 2,
  ),
  Level(
    id: 'world2_level4',
    world: 2,
    number: 4,
    title: 'Desça resgatando',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.down,
    goal: const GridPosition(0, 4),
    maxBlocks: 8,
    optimalBlocks: 3,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.walk),
    ],
    collectibles: {GridPosition(0, 2)},
    collectTarget: 1,
  ),
  Level(
    id: 'world2_level5',
    world: 2,
    number: 5,
    title: 'Dois corredores',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 3),
    maxBlocks: 8,
    optimalBlocks: 5,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
    ],
    collectibles: {
      GridPosition(1, 0),
      GridPosition(3, 0),
      GridPosition(3, 1),
      GridPosition(3, 3),
    },
    collectTarget: 4,
  ),
  Level(
    id: 'world2_level6',
    world: 2,
    number: 6,
    title: 'Vire e resgate de novo',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 5),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 2),
    maxBlocks: 8,
    optimalBlocks: 5,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
    ],
    collectibles: {
      GridPosition(2, 5),
      GridPosition(3, 4),
      GridPosition(3, 2),
    },
    collectTarget: 3,
  ),
  Level(
    id: 'world2_level7',
    world: 2,
    number: 7,
    title: 'Três curvas',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(4, 3),
    maxBlocks: 8,
    optimalBlocks: 7,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
    ],
    collectibles: {
      GridPosition(1, 0),
      GridPosition(2, 0),
      GridPosition(3, 2),
    },
    collectTarget: 3,
  ),
  Level(
    id: 'world2_level8',
    world: 2,
    number: 8,
    title: 'Três curvas, mais rápido',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 5),
    startDirection: FacingDirection.right,
    goal: const GridPosition(4, 2),
    maxBlocks: 8,
    optimalBlocks: 7,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
    ],
    collectibles: {
      GridPosition(1, 5),
      GridPosition(3, 5),
      GridPosition(3, 3),
    },
    collectTarget: 3,
  ),
  Level(
    id: 'world2_level9',
    world: 2,
    number: 9,
    title: 'Corredor comprido',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 4),
    maxBlocks: 8,
    optimalBlocks: 6,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.walk),
    ],
    collectibles: {
      GridPosition(2, 0),
      GridPosition(3, 1),
      GridPosition(3, 3),
    },
    collectTarget: 3,
  ),
  Level(
    id: 'world2_level10',
    world: 2,
    number: 10,
    title: 'Quatro resgates',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(5, 3),
    maxBlocks: 8,
    optimalBlocks: 8,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnLeft),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.walk),
    ],
    collectibles: {
      GridPosition(1, 0),
      GridPosition(3, 0),
      GridPosition(3, 1),
      GridPosition(3, 3),
      GridPosition(4, 3),
    },
    collectTarget: 5,
  ),
  Level(
    id: 'world2_level11',
    world: 2,
    number: 11,
    title: 'Cinco resgates, sem pausa',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 5),
    startDirection: FacingDirection.right,
    goal: const GridPosition(5, 2),
    maxBlocks: 8,
    optimalBlocks: 8,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnRight),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.walk),
    ],
    collectibles: {
      GridPosition(2, 5),
      GridPosition(3, 4),
      GridPosition(3, 2),
      GridPosition(4, 2),
    },
    collectTarget: 4,
  ),
  Level(
    id: 'world2_level12',
    world: 2,
    number: 12,
    title: 'Fim do Mundo 2',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 5),
    startDirection: FacingDirection.right,
    goal: const GridPosition(5, 2),
    maxBlocks: 8,
    optimalBlocks: 8,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.turnRight),
      Block(BlockType.rescueIfCharacterHere),
      Block(BlockType.walk),
    ],
    collectibles: {
      GridPosition(1, 5),
      GridPosition(3, 5),
      GridPosition(3, 4),
      GridPosition(3, 3),
      GridPosition(3, 2),
      GridPosition(4, 2),
    },
    collectTarget: 6,
  ),
];

/// As 12 fases do Mundo 3 ("Desenho no Tabuleiro"): mesmo motor do Mundo
/// 1/2 (`Level`/`ProgramExecutor`), trocando o critério de vitória — em vez
/// de só chegar no alvo, o Mascote pinta cada célula por onde `Andar` passa
/// (`GameCursor.paintedTiles`) e o Programa precisa reproduzir exatamente o
/// desenho-alvo (`Level.paintTarget`) antes de terminar no alvo. Os
/// comandos disponíveis continuam os mesmos 4 do Mundo 1
/// (`walk`/`turnLeft`/`turnRight`/`repeat`) — nenhum bloco novo.
///
/// Como o Mascote só pinta uma única linha contínua (sem "levantar o
/// lápis" nem desenhar 2 traços desconectados), todo `paintTarget` aqui é
/// desenhável como um único traço a partir de `start`, terminando
/// exatamente em `goal` — isso restringe as formas possíveis dentro de
/// `maxBlocks: 8` (formas com "ramos" que precisariam voltar por cima de
/// si mesmas, como uma cruz ou um coração cheio, custam blocos demais para
/// caber no limite; ver `.claude/memory/decisions.md`, entrada de
/// 2026-09-18, para o porquê dessa restrição). Progressão: Fases 1-3
/// desenham um L (reto + 1 virada), a Fase 1 já combinando a virada com
/// `Repetir 3×` (pedido explícito do usuário — "um pouco mais difícil"
/// desde o início, mesmo padrão já usado ao redesenhar o Mundo 2); Fases
/// 4-7 introduzem traços com 2 viradas (zigue-zague, degrau, corredor,
/// gancho); Fases 8-11 combinam 3 viradas ou mais (seta, arco aberto,
/// escada com gancho, arco largo); a Fase 12 ("Fim do Mundo 3") é o
/// zigue-zague grande que usa o máximo de células pintáveis dentro dos 8
/// blocos do `maxBlocks` (3 trechos de 3 células cada, via `Repetir 3×`) —
/// "sem espaço pra errar", mesmo padrão das fases finais dos outros
/// mundos. Nenhuma fase usa parede (`walls`) — o desafio já vem inteiro da
/// forma do desenho, sem precisar de obstáculo. `maxBlocks: 8` constante em
/// todas. Dados verificados em `test/game/world3_level_catalog_test.dart`.
/// Ver `.claude/docs/GAME_DESIGN.md`.
final world3Levels = <Level>[
  Level(
    id: 'world3_level1',
    world: 3,
    number: 1,
    title: 'Pinte o L',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 1),
    maxBlocks: 8,
    optimalBlocks: 4,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(1, 0),
      GridPosition(2, 0),
      GridPosition(3, 0),
      GridPosition(3, 1),
    },
  ),
  Level(
    id: 'world3_level2',
    world: 3,
    number: 2,
    title: 'Pinte o degrau',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(2, 1),
    maxBlocks: 8,
    optimalBlocks: 5,
    hintProgram: const [
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(1, 0),
      GridPosition(1, 1),
      GridPosition(2, 1),
    },
  ),
  Level(
    id: 'world3_level3',
    world: 3,
    number: 3,
    title: 'L bem grande',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 3),
    maxBlocks: 8,
    optimalBlocks: 5,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(1, 0),
      GridPosition(2, 0),
      GridPosition(3, 0),
      GridPosition(3, 1),
      GridPosition(3, 2),
      GridPosition(3, 3),
    },
  ),
  Level(
    id: 'world3_level4',
    world: 3,
    number: 4,
    title: 'Pequeno zigue-zague',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(0, 2),
    maxBlocks: 8,
    optimalBlocks: 6,
    hintProgram: const [
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(1, 0),
      GridPosition(1, 1),
      GridPosition(1, 2),
      GridPosition(0, 2),
    },
  ),
  Level(
    id: 'world3_level5',
    world: 3,
    number: 5,
    title: 'Degrau mais longo',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(2, 2),
    maxBlocks: 8,
    optimalBlocks: 7,
    hintProgram: const [
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(1, 0),
      GridPosition(1, 1),
      GridPosition(2, 1),
      GridPosition(2, 2),
    },
  ),
  Level(
    id: 'world3_level6',
    world: 3,
    number: 6,
    title: 'Corredor estreito',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.down,
    goal: const GridPosition(1, 0),
    maxBlocks: 8,
    optimalBlocks: 7,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(0, 1),
      GridPosition(0, 2),
      GridPosition(0, 3),
      GridPosition(1, 0),
      GridPosition(1, 1),
      GridPosition(1, 2),
      GridPosition(1, 3),
    },
  ),
  Level(
    id: 'world3_level7',
    world: 3,
    number: 7,
    title: 'Gancho comprido',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(5, 1),
    maxBlocks: 8,
    optimalBlocks: 7,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(1, 0),
      GridPosition(2, 0),
      GridPosition(3, 0),
      GridPosition(3, 1),
      GridPosition(4, 1),
      GridPosition(5, 1),
    },
  ),
  Level(
    id: 'world3_level8',
    world: 3,
    number: 8,
    title: 'Pinte a seta',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 2),
    startDirection: FacingDirection.right,
    goal: const GridPosition(3, 3),
    maxBlocks: 8,
    optimalBlocks: 8,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 2),
      GridPosition(1, 2),
      GridPosition(2, 2),
      GridPosition(3, 1),
      GridPosition(3, 2),
      GridPosition(3, 3),
    },
  ),
  Level(
    id: 'world3_level9',
    world: 3,
    number: 9,
    title: 'Arco aberto',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.down,
    goal: const GridPosition(2, 0),
    maxBlocks: 8,
    optimalBlocks: 8,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(0, 1),
      GridPosition(0, 2),
      GridPosition(0, 3),
      GridPosition(1, 3),
      GridPosition(2, 0),
      GridPosition(2, 1),
      GridPosition(2, 2),
      GridPosition(2, 3),
    },
  ),
  Level(
    id: 'world3_level10',
    world: 3,
    number: 10,
    title: 'Escada com gancho',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(2, 3),
    maxBlocks: 8,
    optimalBlocks: 8,
    hintProgram: const [
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.walk),
      Block(BlockType.turnLeft),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(1, 0),
      GridPosition(1, 1),
      GridPosition(1, 2),
      GridPosition(2, 2),
      GridPosition(2, 3),
    },
  ),
  Level(
    id: 'world3_level11',
    world: 3,
    number: 11,
    title: 'Arco largo',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 3),
    startDirection: FacingDirection.up,
    goal: const GridPosition(2, 3),
    maxBlocks: 8,
    optimalBlocks: 8,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.walk),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(0, 1),
      GridPosition(0, 2),
      GridPosition(0, 3),
      GridPosition(1, 0),
      GridPosition(2, 0),
      GridPosition(2, 1),
      GridPosition(2, 2),
      GridPosition(2, 3),
    },
  ),
  Level(
    id: 'world3_level12',
    world: 3,
    number: 12,
    title: 'Fim do Mundo 3',
    gridSize: 6,
    walls: const [],
    start: const GridPosition(0, 0),
    startDirection: FacingDirection.right,
    goal: const GridPosition(0, 3),
    maxBlocks: 8,
    optimalBlocks: 8,
    hintProgram: const [
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
      Block(BlockType.turnRight),
      Block(BlockType.repeat),
      Block(BlockType.walk),
    ],
    paintTarget: {
      GridPosition(0, 0),
      GridPosition(1, 0),
      GridPosition(2, 0),
      GridPosition(3, 0),
      GridPosition(3, 1),
      GridPosition(3, 2),
      GridPosition(3, 3),
      GridPosition(2, 3),
      GridPosition(1, 3),
      GridPosition(0, 3),
    },
  ),
];

/// Motor de jogo usado por um `GameWorld` — cada mundo é um mini-jogo de
/// lógica diferente (ver `.claude/docs/GAME_DESIGN.md` e
/// `.claude/plans/Mundos.md`).
enum WorldGameType {
  /// Mundos 1 ("Primeiros passos"), 2 ("Resgate de Personagens") e 3
  /// ("Desenho no Tabuleiro") — todos compartilham `Level`/
  /// `ProgramExecutor`, diferenciados só pelo conteúdo de cada fase
  /// (`collectibles`/`collectTarget`/`paintTarget` opcionais). Ver
  /// `.claude/memory/decisions.md`.
  maze,

  /// Mundo 4 ("Decisões em Bloco") — programação em blocos visuais (sem
  /// sintaxe de código) sobre uma lista de números, somando/contando
  /// conforme o problema da fase. `BlockProgramLevel`.
  blockProgram,

  /// Mundo 5 ("Preveja a Saída") — lê um trecho de código real e prevê o
  /// resultado por múltipla escolha. `PredictOutputLevel`.
  predictOutput,

  /// Mundo 6 ("Complete o Código") — escolhe qual linha preenche um espaço
  /// em branco num trecho de código real. `CompleteCodeLevel`.
  completeCode,

  /// Mundo 7 ("Modo Debug") — reordena linhas embaralhadas ou acha a linha
  /// com o bug. `CodePuzzleLevel`.
  codePuzzle,
}

/// Um mundo da Seleção de Fases: agrupa `Level`s do mesmo mini-jogo. Ver
/// `.claude/memory/domain-glossary.md` ("Mundo").
class GameWorld {
  final int number;

  /// Título grande mostrado na Seleção de Fases (ex.: "Primeiros passos").
  final String name;

  /// Frase curta descrevendo o mundo, mostrada abaixo do título.
  final String subtitle;

  /// Rótulo de dificuldade mostrado no card do mundo (ex.: "Fácil").
  final String difficultyLabel;

  /// Qual motor de jogo esse mundo usa — decide a tela/lógica de Gameplay.
  final WorldGameType gameType;

  /// `true` enquanto o motor desse mundo ainda não foi construído — o mundo
  /// aparece como "EM BREVE" e não é tocável, independente de progresso.
  final bool comingSoon;

  /// Fases desse mundo, tipadas pela interface mínima `GameLevel`
  /// (`lib/models/game_level.dart`) — cada `WorldGameType` guarda seu
  /// próprio tipo concreto de fase (`Level` para `maze`, `BlockProgramLevel`
  /// para `blockProgram`); quem consome uma fase específica de um mundo
  /// específico já sabe o tipo concreto esperado (ex.:
  /// `LevelSelectScreen`/`BlockProgramStageSelectView`) e faz o cast lá.
  final List<GameLevel> levels;

  const GameWorld({
    required this.number,
    required this.name,
    required this.subtitle,
    required this.difficultyLabel,
    required this.gameType,
    required this.comingSoon,
    required this.levels,
  });
}

/// Os 7 mundos do jogo — todos com fases e motor implementados.
/// Mundo 1 ("Primeiros passos"), Mundo 2 ("Resgate de Personagens") e Mundo
/// 3 ("Desenho no Tabuleiro") — todos `WorldGameType.maze`, compartilhando
/// `Level`/`ProgramExecutor` — formam a Trilha 1 ("Lógica em Apuros"); o
/// Mundo 4 ("Decisões em Bloco", `blockProgram`) — programação em blocos
/// visuais, sem sintaxe de código, ponte entre a Trilha 1 e o código de
/// verdade — forma a Trilha 2 ("Construtores de Lógica") sozinho; Mundo 5
/// ("Preveja a Saída"), Mundo 6 ("Complete o Código") e Mundo 7 ("Modo
/// Debug") formam a Trilha 3 ("Modo Programador"). Ver
/// `.claude/plans/Mundos.md` e `.claude/memory/decisions.md`.
final worlds = <GameWorld>[
  GameWorld(
    number: 1,
    name: 'Primeiros passos',
    subtitle: 'Guie o mascote pelo labirinto',
    difficultyLabel: 'Fácil',
    gameType: WorldGameType.maze,
    comingSoon: false,
    levels: world1Levels,
  ),
  GameWorld(
    number: 2,
    name: 'Resgate de Personagens',
    subtitle: 'Resgate quem está perdido no caminho',
    difficultyLabel: 'Fácil',
    gameType: WorldGameType.maze,
    comingSoon: false,
    levels: world2Levels,
  ),
  GameWorld(
    number: 3,
    name: 'Desenho no Tabuleiro',
    subtitle: 'Pinte o caminho exato até formar o desenho',
    difficultyLabel: 'Médio',
    gameType: WorldGameType.maze,
    comingSoon: false,
    levels: world3Levels,
  ),
  GameWorld(
    number: 4,
    name: 'Decisões em Bloco',
    subtitle: 'Blocos com condição — só soma ou conta quando bate',
    difficultyLabel: 'Médio',
    gameType: WorldGameType.blockProgram,
    comingSoon: false,
    levels: world4Levels,
  ),
  GameWorld(
    number: 5,
    name: 'Preveja a Saída',
    subtitle: 'Leia código real e adivinhe o resultado',
    difficultyLabel: 'Difícil',
    gameType: WorldGameType.predictOutput,
    comingSoon: false,
    levels: world5Levels,
  ),
  GameWorld(
    number: 6,
    name: 'Complete o Código',
    subtitle: 'Escolha a linha certa para completar',
    difficultyLabel: 'Difícil',
    gameType: WorldGameType.completeCode,
    comingSoon: false,
    levels: world6Levels,
  ),
  GameWorld(
    number: 7,
    name: 'Modo Debug',
    subtitle: 'Resolva puzzles de código de verdade',
    difficultyLabel: 'Difícil',
    gameType: WorldGameType.codePuzzle,
    comingSoon: false,
    levels: world7Levels,
  ),
];
