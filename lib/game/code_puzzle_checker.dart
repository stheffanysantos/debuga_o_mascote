import '../models/code_puzzle_level.dart';

/// "Motor" do Mundo 3 ("Modo Debug") — mais simples que `ProgramExecutor`
/// (Mundo 1) e `BeltExecutor` (Mundo 2): não há passo a passo nem cursor,
/// cada fase é um veredito único por tentativa. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Mundo 3 — Modo Debug".

/// Compara a sequência montada pelo jogador com a ordem certa da fase,
/// linha a linha (texto e posição). `true` só se ambas têm o mesmo
/// tamanho e todo texto bate na mesma posição.
bool checkReorder(List<CodeLine> attempt, List<CodeLine> correct) {
  if (attempt.length != correct.length) return false;
  for (var i = 0; i < correct.length; i++) {
    if (attempt[i].text != correct[i].text) return false;
  }
  return true;
}

/// Compara a linha que o jogador tocou com o índice da linha realmente
/// errada da fase.
bool checkFindBug(int tappedLineIndex, int buggyLineIndex) => tappedLineIndex == buggyLineIndex;
