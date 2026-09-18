/// Pontuação do Placar do Dia — separada do "PONTOS" por fase
/// (`lib/game/scoring.dart`/`code_puzzle_scoring.dart`). Regra completa em
/// `.claude/docs/GAME_DESIGN.md`, seção "Placar do Dia — pontuação de
/// sessão". O tempo gasto nunca aparece na UI — só entra aqui, como um
/// bônus escondido dentro do total de pontos.
///
/// Valores reduzidos em ~10× (2026-09-18) — achado real: jogadores que
/// zeraram o jogo (84 fases, 7 mundos) acumulavam 46.000-47.000+ pontos de
/// sessão, um número grande demais para o placar de um jogo de estande.
/// Mesmo espírito da redução já aplicada antes ao "PONTOS" por fase
/// (`.claude/memory/decisions.md`, "Pontuação por fase reduzida
/// (1000→300)") — só os valores mudam, a fórmula em si continua igual.
const _basePointsByWorld = {1: 30, 2: 40, 3: 50, 4: 60, 5: 70, 6: 80, 7: 90};

const _speedBonusCap = 20;

int computeSessionPoints({required int worldNumber, required int elapsedSeconds}) {
  final base = _basePointsByWorld[worldNumber] ?? 300;
  final speedBonus = (_speedBonusCap - elapsedSeconds).clamp(0, _speedBonusCap);
  return base + speedBonus;
}
