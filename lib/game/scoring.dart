/// Resultado da pontuação de uma Execução vitoriosa.
class ScoreResult {
  final int stars;
  final int points;

  const ScoreResult({required this.stars, required this.points});
}

/// Calcula estrelas (1–3) e pontos a partir de quantos blocos o jogador
/// usou em relação ao ótimo da fase — ver `.claude/docs/GAME_DESIGN.md`.
/// Só chamado após uma vitória (`GameOutcome.win`).
///
/// - 3 estrelas: usou o ótimo (ou até 1 bloco a mais).
/// - 2 estrelas: usou até 3 blocos a mais que o ótimo.
/// - 1 estrela: qualquer solução válida além disso.
/// - Pontos: 300 no ótimo, -50 por bloco extra, piso de 50.
ScoreResult computeScore({required int blocksUsed, required int optimalBlocks}) {
  final diff = blocksUsed - optimalBlocks;
  final extra = diff < 0 ? 0 : diff;

  final int stars;
  if (extra <= 1) {
    stars = 3;
  } else if (extra <= 3) {
    stars = 2;
  } else {
    stars = 1;
  }

  final points = (300 - extra * 50).clamp(50, 300);

  return ScoreResult(stars: stars, points: points);
}
