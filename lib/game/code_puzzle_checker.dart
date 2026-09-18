import '../models/code_line.dart';

/// "Motor" do Mundo 7 ("Modo Debug") — mais simples que `ProgramExecutor`
/// (Mundo 1) e `BeltExecutor` (Mundo 2): não há passo a passo nem cursor,
/// cada fase é um veredito único por tentativa. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Mundo 7 — Modo Debug".

/// Compara a sequência montada pelo jogador com a ordem certa da fase —
/// por **grupo**, não posição a posição. `groupOf` (mesmo índice de
/// `correct`, opcional) marca linhas intercambiáveis entre si: linhas com
/// o mesmo grupo podem aparecer em qualquer ordem relativa dentro do seu
/// próprio intervalo, mas a ordem **entre** grupos diferentes continua
/// obrigatória. Sem `groupOf` (ou com um grupo por linha, o padrão de
/// `CodePuzzleLevel.reorder`), o comportamento é idêntico ao antigo
/// "ordem exata" — generalização sem quebrar fases já corretas. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Mundo 7 — Modo Debug", e
/// `.claude/memory/decisions.md`.
///
/// `true` só se `attempt`/`correct` têm o mesmo tamanho e, para cada grupo
/// (na ordem em que aparecem em `correct`), o trecho correspondente de
/// `attempt` contém exatamente o mesmo multiconjunto de textos daquele
/// grupo em `correct`.
bool checkReorder(List<CodeLine> attempt, List<CodeLine> correct, {List<int>? groupOf}) {
  if (attempt.length != correct.length) return false;

  final groups = groupOf ?? List<int>.generate(correct.length, (i) => i);
  if (groups.length != correct.length) return false;

  var start = 0;
  while (start < correct.length) {
    var end = start;
    while (end + 1 < correct.length && groups[end + 1] == groups[start]) {
      end++;
    }

    final correctGroupTexts = [for (var i = start; i <= end; i++) correct[i].text]..sort();
    final attemptGroupTexts = [for (var i = start; i <= end; i++) attempt[i].text]..sort();
    if (!_sameTexts(correctGroupTexts, attemptGroupTexts)) return false;

    start = end + 1;
  }
  return true;
}

bool _sameTexts(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Compara a linha que o jogador tocou com o índice da linha realmente
/// errada da fase.
bool checkFindBug(int tappedLineIndex, int buggyLineIndex) => tappedLineIndex == buggyLineIndex;
