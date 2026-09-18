/// Resultado de uma Execução. Ver `.claude/docs/GAME_DESIGN.md`.
enum GameOutcome {
  /// O mascote parou exatamente na célula do alvo (e, se a fase tiver
  /// `Level.collectTarget`, resgatou exatamente essa quantidade de
  /// personagens).
  win,

  /// O mascote bateu numa parede ou tentou sair do tabuleiro.
  crash,

  /// O programa terminou (todos os passos executados) sem o mascote
  /// estar no alvo.
  farFromGoal,

  /// Só Mundo 2 ("Resgate de Personagens"): o mascote parou exatamente na
  /// célula do alvo, mas resgatou uma quantidade de personagens diferente
  /// de `Level.collectTarget`. Distinto de `farFromGoal` porque a posição
  /// final está certa — o motivo da falha é outro (contagem errada), e a
  /// tela de Tentativa Falha precisa de um texto diferente para isso.
  wrongCollectCount,

  /// Só Mundo 3 ("Desenho no Tabuleiro"): o mascote parou exatamente na
  /// célula do alvo, mas o conjunto de células pintadas
  /// (`GameCursor.paintedTiles`) não é exatamente igual ao desenho-alvo
  /// (`Level.paintTarget`) — faltou pintar alguma célula do desenho, ou
  /// pintou alguma célula fora dele. Distinto de `farFromGoal` pelo mesmo
  /// motivo de `wrongCollectCount`: a posição final está certa, o motivo
  /// da falha é outro. Ver `.claude/docs/GAME_DESIGN.md` e
  /// `.claude/memory/decisions.md`, entrada de 2026-09-18.
  wrongPaintPattern,
}

class GameResult {
  final GameOutcome outcome;

  const GameResult(this.outcome);
}
