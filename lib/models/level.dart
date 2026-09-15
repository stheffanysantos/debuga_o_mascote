import 'block.dart';
import 'code_puzzle_level.dart';
import 'conveyor_level.dart';
import 'game_level.dart';

/// Direção para a qual o Mascote está olhando. A ordem importa: gira em
/// sentido horário (right -> down -> left -> up -> right).
enum FacingDirection { right, down, left, up }

/// Uma célula do Tabuleiro (coordenadas de grade, não pixels).
class GridPosition {
  final int x;
  final int y;

  const GridPosition(this.x, this.y);

  @override
  bool operator ==(Object other) => other is GridPosition && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// Uma fase: tabuleiro, posição/direção inicial, alvo e limite de blocos.
/// Ver `.claude/memory/domain-glossary.md` e `.claude/rules/naming.md` (id
/// estável e único, nunca reaproveitado). `Level` é o formato de fase do
/// mini-jogo de labirinto (Mundo 1, `WorldGameType.maze`) — ver `GameWorld`
/// mais abaixo para o agrupamento dos 3 mundos do jogo.
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
  });

  bool isWall(int x, int y) => walls.any((w) => w.x == x && w.y == y);

  bool isInside(int x, int y) => x >= 0 && x < gridSize && y >= 0 && y < gridSize;

  bool isGoal(int x, int y) => x == goal.x && y == goal.y;
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
    hintProgram: const [Block(BlockType.turnRight), Block(BlockType.repeat), Block(BlockType.walk)],
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
    walls: const [GridPosition(2, 3), GridPosition(4, 2), GridPosition(1, 1), GridPosition(5, 4), GridPosition(0, 1)],
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
    walls: const [GridPosition(1, 2), GridPosition(3, 0), GridPosition(0, 3), GridPosition(5, 5), GridPosition(4, 4)],
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
    walls: const [GridPosition(4, 4), GridPosition(1, 2), GridPosition(4, 0), GridPosition(5, 3)],
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

/// Motor de jogo usado por um `GameWorld` — cada mundo é um mini-jogo de
/// lógica diferente (ver `.claude/docs/GAME_DESIGN.md` e
/// `.claude/plans/Mundos.md`). Só `maze` (Mundo 1) tem motor
/// implementado hoje; `conveyor`/`codePuzzle` chegam nas Etapas 2/3.
enum WorldGameType { maze, conveyor, codePuzzle }

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
  /// próprio tipo concreto de fase (`Level` para `maze`, `ConveyorLevel`
  /// para `conveyor`); quem consome uma fase específica de um mundo
  /// específico já sabe o tipo concreto esperado (ex.:
  /// `LevelSelectScreen`/`ConveyorStageSelectScreen`) e faz o cast lá.
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

/// Os 3 mundos do jogo — todos com fases e motor implementados (Mundo 1
/// labirinto, Mundo 2 esteira, Mundo 3 puzzles de código, ver
/// `.claude/plans/Mundos.md`, Etapas 1-3).
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
    name: 'Esteira de Bugs',
    subtitle: 'Separe os itens com condicionais',
    difficultyLabel: 'Médio',
    gameType: WorldGameType.conveyor,
    comingSoon: false,
    levels: world2Levels,
  ),
  GameWorld(
    number: 3,
    name: 'Modo Debug',
    subtitle: 'Resolva puzzles de código de verdade',
    difficultyLabel: 'Difícil',
    gameType: WorldGameType.codePuzzle,
    comingSoon: false,
    levels: world3Levels,
  ),
];
