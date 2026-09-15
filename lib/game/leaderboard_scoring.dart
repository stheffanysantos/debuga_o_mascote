/// Pontuação do Placar do Dia — separada do "PONTOS" por fase
/// (`lib/game/scoring.dart`/`code_puzzle_scoring.dart`). Regra completa em
/// `.claude/docs/GAME_DESIGN.md`, seção "Placar do Dia — pontuação de
/// sessão". O tempo gasto nunca aparece na UI — só entra aqui, como um
/// bônus escondido dentro do total de pontos.
const _basePointsByWorld = {1: 300, 2: 500, 3: 800};

const _speedBonusCap = 200;

int computeSessionPoints({required int worldNumber, required int elapsedSeconds}) {
  final base = _basePointsByWorld[worldNumber] ?? 300;
  final speedBonus = (_speedBonusCap - elapsedSeconds).clamp(0, _speedBonusCap);
  return base + speedBonus;
}
