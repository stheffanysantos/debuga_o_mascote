import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Chip de um Bloco — usado na área "Seu Programa" (removível ao tocar) e
/// no card de Dica da tela de Tentativa Falha (não removível, pode ficar
/// destacado em amarelo para indicar a correção sugerida).
class ProgramBlockChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final int? repeatCount;
  final bool highlighted;
  final VoidCallback? onTap;

  const ProgramBlockChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.repeatCount,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Teto de largura + `label` dentro de `Flexible` (quebra linha em vez
    // de estourar) — sem isso, rótulos curtos (Mundo 1/2: "Andar") sempre
    // couberam, mas o Mundo 5 reaproveita este chip para uma linha de
    // código inteira ("for (int i = 0; i < 3; i++) {"), que sem limite
    // algum estourava o `Wrap` pai (achado do Code Reviewer). Não usa
    // `TextOverflow.ellipsis`/`FittedBox` de propósito — truncar ou
    // encolher a ponto de ficar ilegível apagaria justamente o texto que o
    // jogador precisa ler para reordenar o código corretamente.
    final maxChipWidth = MediaQuery.sizeOf(context).width - 80;
    final chip = Container(
      constraints: BoxConstraints(minHeight: 44, maxWidth: maxChipWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: AppColors.overlaySoft, offset: Offset(0, 4), blurRadius: 0)],
        border: highlighted ? Border.all(color: AppColors.yellowNeon, width: 3) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (repeatCount != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.overlayBadge,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$repeatCount×', style: AppText.style(size: 12, weight: FontWeight.w900, color: foreground)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(label, style: AppText.style(size: 14, weight: FontWeight.w900, color: foreground))),
        ],
      ),
    );

    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}
