import '../models/block.dart';
import '../models/level.dart';
import 'game_result.dart';

/// Posição + direção do Mascote durante a Execução.
class GameCursor {
  final int x;
  final int y;
  final FacingDirection direction;

  const GameCursor({required this.x, required this.y, required this.direction});

  factory GameCursor.fromStart(Level level) {
    return GameCursor(x: level.start.x, y: level.start.y, direction: level.startDirection);
  }

  GameCursor copyWith({int? x, int? y, FacingDirection? direction}) {
    return GameCursor(x: x ?? this.x, y: y ?? this.y, direction: direction ?? this.direction);
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

/// Interpretador do Programa contra uma Fase. Dart puro — sem Flutter (ver
/// `.claude/rules/architecture.md`). Quem anima a Execução é a Screen,
/// consumindo `expand`/`applyStep`/`evaluateFinal` passo a passo.
class ProgramExecutor {
  final Level level;

  const ProgramExecutor(this.level);

  static const _dx = [1, 0, -1, 0];
  static const _dy = [0, 1, 0, -1];

  /// Expande o Programa em Passos concretos. `Repetir 3×` aplica-se ao
  /// bloco imediatamente seguinte (executando-o 3 vezes); um `Repetir` sem
  /// um bloco não-`repeat` logo depois (último bloco, ou seguido de outro
  /// `Repetir`) não gera nenhum passo.
  List<ExecutionStep> expand(List<Block> program) {
    final steps = <ExecutionStep>[];
    for (var i = 0; i < program.length; i++) {
      final block = program[i];
      if (block.type == BlockType.repeat) {
        final hasNext = i + 1 < program.length;
        final next = hasNext ? program[i + 1] : null;
        if (next != null && next.type != BlockType.repeat) {
          for (var k = 0; k < 3; k++) {
            steps.add(ExecutionStep(blockIndex: i + 1, type: next.type));
          }
          i++;
        }
      } else {
        steps.add(ExecutionStep(blockIndex: i, type: block.type));
      }
    }
    return steps;
  }

  /// Aplica um único Passo ao cursor. `crashed: true` quando o passo tenta
  /// mover o mascote para uma parede ou para fora do tabuleiro.
  StepOutcome applyStep(GameCursor cursor, BlockType type) {
    switch (type) {
      case BlockType.turnLeft:
        return StepOutcome(cursor: cursor.copyWith(direction: _turnLeft(cursor.direction)), crashed: false);
      case BlockType.turnRight:
        return StepOutcome(cursor: cursor.copyWith(direction: _turnRight(cursor.direction)), crashed: false);
      case BlockType.walk:
        final dx = _dx[cursor.direction.index];
        final dy = _dy[cursor.direction.index];
        final nx = cursor.x + dx;
        final ny = cursor.y + dy;
        if (!level.isInside(nx, ny) || level.isWall(nx, ny)) {
          return StepOutcome(cursor: cursor, crashed: true);
        }
        return StepOutcome(cursor: cursor.copyWith(x: nx, y: ny), crashed: false);
      case BlockType.repeat:
        // Não deveria ocorrer pós-`expand` — tratado como no-op defensivo.
        return StepOutcome(cursor: cursor, crashed: false);
    }
  }

  /// Resultado quando o Programa termina sem colisão (todos os passos
  /// executados): vitória se o cursor parou exatamente no alvo.
  GameOutcome evaluateFinal(GameCursor cursor) {
    return level.isGoal(cursor.x, cursor.y) ? GameOutcome.win : GameOutcome.farFromGoal;
  }

  FacingDirection _turnLeft(FacingDirection d) => FacingDirection.values[(d.index + 3) % 4];

  FacingDirection _turnRight(FacingDirection d) => FacingDirection.values[(d.index + 1) % 4];
}
