import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Destaque de sintaxe simples: só 2 cores fixas de `AppColors` — sem
/// pacote novo, sem parser real, um regex de palavras-chave já basta (ver
/// `.claude/docs/GAME_DESIGN.md`). Extraído de `CodePuzzleGameplayScreen`
/// (Mundo 5) para ser reaproveitado por qualquer tela que mostre uma
/// `CodeLine` — hoje também Mundo 3 ("Preveja a Saída") e Mundo 4
/// ("Complete o Código").
final _keywordPattern = RegExp(r'\b(if|else|for|while|return|int|bool|List|void)\b');

List<TextSpan> highlightCodeLine(String text) {
  final spans = <TextSpan>[];
  var lastEnd = 0;
  for (final match in _keywordPattern.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: AppText.style(size: 15, weight: FontWeight.w800, color: AppColors.white),
      ));
    }
    spans.add(TextSpan(
      text: match.group(0),
      style: AppText.style(size: 15, weight: FontWeight.w900, color: AppColors.lilac),
    ));
    lastEnd = match.end;
  }
  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: AppText.style(size: 15, weight: FontWeight.w800, color: AppColors.white),
    ));
  }
  return spans;
}
