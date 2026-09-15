/// Tipos de comando que o jogador pode adicionar ao Programa da Esteira
/// (Mundo 2). Ver `.claude/docs/GAME_DESIGN.md`, seção "Mundo 2 — Esteira".
enum BeltBlockType {
  /// "Se Amarelo → Caixa A" — só correto se o item atual da fila for amarelo.
  ifYellowToBinA,

  /// "Se Roxo → Caixa B" — só correto se o item atual da fila for roxo.
  ifPurpleToBinB,

  repeat,

  /// "Enquanto Amarelo → Caixa A" — repetição condicional: classifica, um a
  /// um, todos os itens consecutivos amarelos a partir do item atual,
  /// parando no primeiro item de cor diferente ou no fim da fila. Nunca
  /// falha (se a condição já começa falsa, classifica zero itens).
  /// Autocontido, diferente de `repeat` — não é um modificador do bloco
  /// seguinte. Ver `.claude/docs/GAME_DESIGN.md`, seção "Enquanto —
  /// repetição condicional".
  whileYellowToBinA,

  /// "Enquanto Roxo → Caixa B" — mesma ideia de `whileYellowToBinA`, para
  /// itens roxos e Caixa B.
  whilePurpleToBinB,
}

/// Um bloco do Programa da Esteira montado pelo jogador. `repeat` se aplica
/// ao bloco imediatamente seguinte no Programa (ver `BeltExecutor.expand`)
/// — mesma forma de `lib/models/block.dart` (Mundo 1). `whileYellowToBinA`/
/// `whilePurpleToBinB` são autocontidos (não modificam o bloco seguinte).
class BeltBlock {
  final BeltBlockType type;

  const BeltBlock(this.type);

  @override
  bool operator ==(Object other) => other is BeltBlock && other.type == type;

  @override
  int get hashCode => type.hashCode;
}
