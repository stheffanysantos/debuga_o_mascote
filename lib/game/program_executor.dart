import '../models/block.dart';
import '../models/level.dart';
import 'game_result.dart';

/// Posição + direção do Mascote durante a Execução. `collectedCount`/
/// `collectedTiles` só têm efeito em fases com `Level.collectibles` (Mundo
/// 2, "Resgate de Personagens") — em fases sem personagens perdidos ficam
/// sempre em 0/vazio. `paintedTiles` só tem efeito em fases com `Level.paintTarget`
/// (Mundo 3, "Desenho no Tabuleiro") — em fases sem desenho-alvo, ninguém
/// nunca olha para esse campo, mas ele continua crescendo normalmente (é
/// inofensivo, só não é consultado por `evaluateFinal`).
class GameCursor {
  final int x;
  final int y;
  final FacingDirection direction;

  /// Quantos personagens perdidos já foram resgatados nesta Execução.
  final int collectedCount;

  /// Células de personagem já resgatadas — evita contar o mesmo resgate 2×
  /// se o Programa passar pela mesma célula de novo (ex.: via `Repetir`).
  final Set<GridPosition> collectedTiles;

  /// Todas as células por onde o Mascote já passou nesta Execução
  /// (incluindo a célula inicial) — o "desenho" que o Programa pintou até
  /// agora. Cresce a cada `Andar` bem-sucedido (sem colisão); revisitar
  /// uma célula não conta 2× (é um `Set`).
  final Set<GridPosition> paintedTiles;

  const GameCursor({
    required this.x,
    required this.y,
    required this.direction,
    this.collectedCount = 0,
    this.collectedTiles = const {},
    this.paintedTiles = const {},
  });

  factory GameCursor.fromStart(Level level) {
    return GameCursor(
      x: level.start.x,
      y: level.start.y,
      direction: level.startDirection,
      paintedTiles: {GridPosition(level.start.x, level.start.y)},
    );
  }

  GameCursor copyWith({
    int? x,
    int? y,
    FacingDirection? direction,
    int? collectedCount,
    Set<GridPosition>? collectedTiles,
    Set<GridPosition>? paintedTiles,
  }) {
    return GameCursor(
      x: x ?? this.x,
      y: y ?? this.y,
      direction: direction ?? this.direction,
      collectedCount: collectedCount ?? this.collectedCount,
      collectedTiles: collectedTiles ?? this.collectedTiles,
      paintedTiles: paintedTiles ?? this.paintedTiles,
    );
  }
}

/// Um Passo já expandido (depois de resolver `Repetir 3×`), com o índice do
/// bloco original no Programa — usado para destacar o bloco em execução.
class ExecutionStep {
  final int blockIndex;
  final BlockType type;

  const ExecutionStep({required this.blockIndex, required this.type});
}

/// Resultado de aplicar um único Passo ao cursor.
class StepOutcome {
  final GameCursor cursor;
  final bool crashed;

  const StepOutcome({required this.cursor, required this.crashed});
}

/// Um bloco-alvo já resolvido do Programa (depois de decidir se está
/// "dentro de" um `Repetir 3×` ou solto) — `blockIndex` é a posição do
/// bloco-alvo no Programa original (não do `repeat` que o precede, quando
/// houver). Espelha `BlockProgramProgramEntry`
/// (`lib/game/block_program_executor.dart`) — mesmo papel: `expand` usa
/// isso para multiplicar cada entrada `insideRepeat` por 3, e um painel de
/// tradução de código (ex.: o "Tradutor de Blocos" do Mundo 4) pode
/// reaproveitar a mesma regra sem duplicá-la. Ver
/// `.claude/memory/decisions.md`, entrada de 2026-09-18.
class ProgramEntry {
  final int blockIndex;
  final BlockType targetType;
  final bool insideRepeat;

  const ProgramEntry({
    required this.blockIndex,
    required this.targetType,
    required this.insideRepeat,
  });
}

/// Resolve o Programa em `ProgramEntry`s, na ordem — mesma regra de
/// modificador de 1 nível só (sem stacking) já usada por `Repetir`/
/// `Enquanto`/"Para cada número" nos outros mundos. Um `Repetir` sem um
/// bloco não-modificador logo depois (último bloco, ou seguido de outro
/// `Repetir`) não gera nenhuma entrada.
List<ProgramEntry> resolveProgramEntries(List<Block> program) {
  final entries = <ProgramEntry>[];
  for (var i = 0; i < program.length; i++) {
    final block = program[i];
    if (block.type == BlockType.repeat) {
      final hasNext = i + 1 < program.length;
      final next = hasNext ? program[i + 1] : null;
      if (next != null && next.type != BlockType.repeat) {
        entries.add(
          ProgramEntry(
            blockIndex: i + 1,
            targetType: next.type,
            insideRepeat: true,
          ),
        );
        i++;
      }
      continue;
    }
    entries.add(
      ProgramEntry(blockIndex: i, targetType: block.type, insideRepeat: false),
    );
  }
  return entries;
}

/// Interpretador do Programa contra uma Fase. Dart puro — sem Flutter (ver
/// `.claude/rules/architecture.md`). Quem anima a Execução é a Screen,
/// consumindo `expand`/`applyStep`/`evaluateFinal` passo a passo.
class ProgramExecutor {
  final Level level;

  const ProgramExecutor(this.level);

  static const _dx = [1, 0, -1, 0];
  static const _dy = [0, 1, 0, -1];

  /// Expande o Programa em Passos concretos. `Repetir 3×` aplica-se ao
  /// bloco imediatamente seguinte, executando-o 3 vezes — resolvido por
  /// `resolveProgramEntries` (única fonte da regra de pareamento, também
  /// usada por quem precisar traduzir o Programa para outro formato sem
  /// duplicar essa lógica).
  List<ExecutionStep> expand(List<Block> program) {
    final steps = <ExecutionStep>[];
    for (final entry in resolveProgramEntries(program)) {
      final repeatCount = entry.insideRepeat ? 3 : 1;
      for (var k = 0; k < repeatCount; k++) {
        steps.add(
          ExecutionStep(blockIndex: entry.blockIndex, type: entry.targetType),
        );
      }
    }
    return steps;
  }

  /// Aplica um único Passo ao cursor. `crashed: true` quando o passo tenta
  /// mover o mascote para uma parede ou para fora do tabuleiro.
  StepOutcome applyStep(GameCursor cursor, BlockType type) {
    switch (type) {
      case BlockType.turnLeft:
        return StepOutcome(
          cursor: cursor.copyWith(direction: _turnLeft(cursor.direction)),
          crashed: false,
        );
      case BlockType.turnRight:
        return StepOutcome(
          cursor: cursor.copyWith(direction: _turnRight(cursor.direction)),
          crashed: false,
        );
      case BlockType.walk:
        final destination = _forward(cursor);
        if (destination == null) return StepOutcome(cursor: cursor, crashed: true);
        return StepOutcome(
          cursor: cursor.copyWith(
            x: destination.x,
            y: destination.y,
            paintedTiles: {...cursor.paintedTiles, destination},
          ),
          crashed: false,
        );
      case BlockType.rescueIfCharacterHere:
        // A ação-base ("andar") sempre acontece, com as mesmas regras de
        // colisão de `walk` — só o resgate em si (`collectedCount`) é
        // condicional, nunca a movimentação. Mesmo princípio de
        // `BlockProgramBlockType.addToTotalIfEven`
        // (`lib/game/block_program_executor.dart`): a ação-base
        // ("consumir o próximo número") sempre roda; só o bônus condicional
        // é que pode não fazer nada. Ver `.claude/memory/decisions.md`,
        // entrada de 2026-09-18.
        final destination = _forward(cursor);
        if (destination == null) return StepOutcome(cursor: cursor, crashed: true);
        final paintedTiles = {...cursor.paintedTiles, destination};
        if (level.collectibles.contains(destination) &&
            !cursor.collectedTiles.contains(destination)) {
          return StepOutcome(
            cursor: cursor.copyWith(
              x: destination.x,
              y: destination.y,
              collectedCount: cursor.collectedCount + 1,
              collectedTiles: {...cursor.collectedTiles, destination},
              paintedTiles: paintedTiles,
            ),
            crashed: false,
          );
        }
        return StepOutcome(
          cursor: cursor.copyWith(
            x: destination.x,
            y: destination.y,
            paintedTiles: paintedTiles,
          ),
          crashed: false,
        );
      case BlockType.repeat:
        // Não deveria ocorrer pós-`expand` — tratado como no-op defensivo.
        return StepOutcome(cursor: cursor, crashed: false);
    }
  }

  /// Posição 1 casa na frente do cursor, na direção atual — `null` quando
  /// esse movimento colidiria com uma parede ou saísse do tabuleiro (quem
  /// chama trata isso como `crashed: true`). Extraído porque `walk` e
  /// `rescueIfCharacterHere` compartilham exatamente a mesma regra de
  /// movimento/colisão — só o que acontece depois de chegar na casa de
  /// destino é diferente.
  GridPosition? _forward(GameCursor cursor) {
    final dx = _dx[cursor.direction.index];
    final dy = _dy[cursor.direction.index];
    final nx = cursor.x + dx;
    final ny = cursor.y + dy;
    if (!level.isInside(nx, ny) || level.isWall(nx, ny)) return null;
    return GridPosition(nx, ny);
  }

  /// Resultado quando o Programa termina sem colisão (todos os passos
  /// executados): vitória se o cursor parou exatamente no alvo — e, se a
  /// fase tiver `Level.collectTarget`, também bateu a contagem exata de
  /// personagens resgatados (senão, `wrongCollectCount`); e, se a fase tiver
  /// `Level.paintTarget`, também pintou exatamente esse desenho, nem
  /// faltando nem sobrando célula (senão, `wrongPaintPattern`). Nenhum dos
  /// dois é `farFromGoal` — a posição final está certa, o motivo é outro.
  GameOutcome evaluateFinal(GameCursor cursor) {
    if (!level.isGoal(cursor.x, cursor.y)) return GameOutcome.farFromGoal;
    final target = level.collectTarget;
    if (target != null && cursor.collectedCount != target) {
      return GameOutcome.wrongCollectCount;
    }
    final paintTarget = level.paintTarget;
    if (paintTarget != null && !_paintMatches(cursor.paintedTiles, paintTarget)) {
      return GameOutcome.wrongPaintPattern;
    }
    return GameOutcome.win;
  }

  /// `true` quando os dois conjuntos de células têm exatamente os mesmos
  /// elementos — `Set` não sobrescreve `==` para comparar conteúdo (só
  /// identidade), então a comparação precisa ser explícita. `GridPosition`
  /// tem `==`/`hashCode` próprios, então `contains` já funciona por
  /// conteúdo.
  bool _paintMatches(Set<GridPosition> painted, Set<GridPosition> target) {
    return painted.length == target.length && painted.every(target.contains);
  }

  FacingDirection _turnLeft(FacingDirection d) =>
      FacingDirection.values[(d.index + 3) % 4];

  FacingDirection _turnRight(FacingDirection d) =>
      FacingDirection.values[(d.index + 1) % 4];
}
