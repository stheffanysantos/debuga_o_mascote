/// Progresso do jogador numa fase: melhores estrelas e menor contagem de
/// blocos já alcançados nela. Usado por `lib/core/progress/progress_state.dart`
/// (`ProgressState.byLevelId`) — o estado do jogador em si (mutável,
/// exposto via Riverpod) vive lá, não aqui; este arquivo fica só com o
/// tipo de dado, Dart puro (ver `.claude/rules/architecture.md`).
class LevelProgress {
  final int stars;
  final int bestBlocks;

  /// Maior pontuação já obtida nesta fase (`ScoreResult.points`,
  /// `lib/game/scoring.dart`/`code_puzzle_scoring.dart`) — usada para somar
  /// o total de pontos de um Mundo (`ProgressState.totalPoints`), que por
  /// sua vez decide o desbloqueio do próximo Mundo dentro da mesma Trilha
  /// sem exigir 100% das fases. Ver `.claude/memory/decisions.md`.
  final int bestPoints;

  const LevelProgress({required this.stars, required this.bestBlocks, required this.bestPoints});
}
