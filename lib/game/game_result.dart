/// Resultado de uma Execução. Ver `.claude/docs/GAME_DESIGN.md`.
enum GameOutcome {
  /// O mascote parou exatamente na célula do alvo.
  win,

  /// O mascote bateu numa parede ou tentou sair do tabuleiro.
  crash,

  /// O programa terminou (todos os passos executados) sem o mascote
  /// estar no alvo.
  farFromGoal,
}

class GameResult {
  final GameOutcome outcome;

  const GameResult(this.outcome);
}
