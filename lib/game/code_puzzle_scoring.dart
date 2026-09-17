import 'scoring.dart';

/// Estrelas/pontos do Mundo 5 ("Modo Debug"), calculados por número de
/// **tentativas** até acertar — diferente da fórmula de `computeScore`
/// (Mundos 1/2, `lib/game/scoring.dart`, blocos usados vs. ótimo da fase).
/// Reaproveita `ScoreResult` (mesmo formato de saída, `stars`/`points`) em
/// vez de criar um tipo novo, já que o consumidor (tela de Resultado) só
/// precisa de estrelas/pontos, não importa a origem do cálculo. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Mundo 5 — Modo Debug".
///
/// - 3 estrelas: acertou na 1ª tentativa.
/// - 2 estrelas: acertou na 2ª tentativa.
/// - 1 estrela: acertou na 3ª tentativa em diante.
/// - Pontos: 300 na 1ª tentativa, -100 por tentativa extra, piso de 50.
ScoreResult computeCodePuzzleScore({required int attempts}) {
  final extra = attempts <= 1 ? 0 : attempts - 1;

  final int stars;
  if (attempts <= 1) {
    stars = 3;
  } else if (attempts == 2) {
    stars = 2;
  } else {
    stars = 1;
  }

  final points = (maxLevelPoints - extra * 100).clamp(50, maxLevelPoints);

  return ScoreResult(stars: stars, points: points);
}
