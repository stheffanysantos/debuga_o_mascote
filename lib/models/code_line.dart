/// Uma linha de código como texto simples — sem tokens/AST. Coloração de
/// sintaxe (destacar palavras-chave etc.) é decisão de UI, não deste
/// modelo (Dart puro, ver `.claude/rules/architecture.md`). Reaproveitado
/// pelos 3 mundos que mostram código real: Modo Debug
/// (`lib/models/code_puzzle_level.dart`), Preveja a Saída
/// (`lib/models/predict_output_level.dart`) e Complete o Código
/// (`lib/models/complete_code_level.dart`).
class CodeLine {
  final String text;

  const CodeLine(this.text);
}
