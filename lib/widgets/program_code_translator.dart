import '../game/program_executor.dart';
import '../models/block.dart';

/// Traduz o Programa do motor de labirinto (Mundos 1 "Primeiros passos", 2
/// "Resgate de Personagens" e 3 "Desenho no Tabuleiro" — todos `Level`/
/// `ProgramExecutor`, `WorldGameType.maze`) para linhas de pseudo-código
/// Dart-like, mostradas no painel "Tradutor de Blocos" da Gameplay
/// (`GameplayView`). Mesma ideia de `codeLinesFor`/`codeLineFor`
/// (`lib/widgets/block_program_chip_style.dart`, Mundo 4), mas para este
/// motor — tradução deliberadamente pedagógica, não um transpilador de
/// verdade (não precisa compilar).
///
/// Reaproveita `resolveProgramEntries` (`lib/game/program_executor.dart`) —
/// a mesma função que `ProgramExecutor.expand` usa pra gerar Passos — para
/// nunca duplicar a regra de pareamento de `Repetir 3×` ("aplica-se só ao
/// bloco imediatamente seguinte, sem stacking"). Ver
/// `.claude/memory/decisions.md`, entrada de 2026-09-18.
List<String> programCodeLinesFor(List<Block> program) {
  final lines = <String>[];
  for (final entry in resolveProgramEntries(program)) {
    if (entry.insideRepeat) {
      lines.add('repetir (3) {');
      lines.add('  ${programCodeLineFor(entry.targetType)}');
      lines.add('}');
    } else {
      lines.add(programCodeLineFor(entry.targetType));
    }
  }
  return lines;
}

/// Uma linha de pseudo-código equivalente a um único bloco-alvo (não
/// `repeat`, que só existe como o bloco `repetir (3) { ... }` que
/// `programCodeLinesFor` monta ao redor de outra linha).
String programCodeLineFor(BlockType type) {
  switch (type) {
    case BlockType.walk:
      return 'andar();';
    case BlockType.turnLeft:
      return 'virarEsquerda();';
    case BlockType.turnRight:
      return 'virarDireita();';
    case BlockType.rescueIfCharacterHere:
      return 'seTiverPersonagem() { resgatar(); }';
    case BlockType.repeat:
      // Não deveria ocorrer isolado — `programCodeLinesFor` sempre consome
      // `repeat` junto do bloco seguinte antes de chamar esta função para
      // ele. Mantido só por exaustividade do switch.
      return 'repetir (3) {';
  }
}
