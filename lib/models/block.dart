/// Tipos de comando que o jogador pode adicionar ao Programa.
/// Ver `.claude/docs/GAME_DESIGN.md`.
enum BlockType { walk, turnLeft, turnRight, repeat }

/// Um bloco do Programa montado pelo jogador. `repeat` se aplica ao bloco
/// imediatamente seguinte no Programa (ver `ProgramExecutor.expand`).
class Block {
  final BlockType type;

  const Block(this.type);

  @override
  bool operator ==(Object other) => other is Block && other.type == type;

  @override
  int get hashCode => type.hashCode;
}
