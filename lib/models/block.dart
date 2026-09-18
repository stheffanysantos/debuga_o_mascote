/// Tipos de comando que o jogador pode adicionar ao Programa. `walk`/
/// `turnLeft`/`turnRight`/`repeat` estão disponíveis nos Mundos 1, 2 e 3
/// (todos `WorldGameType.maze`); `rescueIfCharacterHere` só no Mundo 2
/// ("Resgate de Personagens") — condição embutida no próprio bloco-alvo
/// (mesmo padrão de `BlockProgramBlockType.addToTotalIfEven`), não um
/// modificador aninhado. Ver `.claude/docs/GAME_DESIGN.md` e
/// `lib/widgets/block_chip_style.dart` (`availableBlockTypesForWorld`).
///
/// Substituiu os antigos `turnLeftIfYellow`/`turnRightIfPurple` ("Se
/// Amarelo/Roxo, vire" — mecânica de Placa do antigo "Encruzilhada
/// Colorida") — ver `.claude/memory/decisions.md`, entrada de 2026-09-18
/// ("Mundo 2 v4").
enum BlockType {
  walk,
  turnLeft,
  turnRight,
  repeat,

  /// "Se tiver um personagem aqui, resgate" — só Mundo 2 ("Resgate de
  /// Personagens"). Anda 1 casa na direção atual (mesmas regras de colisão
  /// de `walk` — pode colidir com parede/sair do tabuleiro) e, **na casa de
  /// destino**, resgata o personagem perdido lá (`Level.collectibles`) se
  /// houver um e ele ainda não tiver sido resgatado nesta Execução; senão,
  /// só anda (nunca falha por não ter personagem — mesmo princípio de
  /// `BlockProgramBlockType.addToTotalIfEven`: a ação-base, aqui "andar",
  /// sempre acontece; só o resgate-bônus é condicional). Combinado com
  /// `Repetir 3×`, resolve um corredor inteiro de personagens espalhados de
  /// forma irregular sem o jogador precisar saber exatamente em qual das 3
  /// casas está cada um. Ver `.claude/docs/GAME_DESIGN.md` e
  /// `.claude/memory/decisions.md`, entrada de 2026-09-18.
  rescueIfCharacterHere,
}

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
