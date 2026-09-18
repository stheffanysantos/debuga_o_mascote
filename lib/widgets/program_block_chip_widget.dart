import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Tamanho de ícone recomendado para quem monta um `icon` para este chip
/// (ex.: `BlockChipStyle.icon(programBlockChipIconSize)`) — mantém os
/// ícones dos Mundos 1/2 sempre no mesmo tamanho dentro de "Seu Programa",
/// independente do tipo de bloco.
const double programBlockChipIconSize = 22.0;

/// Chip de um Bloco — usado na área "Seu Programa" (removível ao tocar) e
/// no card de Dica da tela de Tentativa Falha (não removível, pode ficar
/// destacado em amarelo para indicar a correção sugerida). Também
/// reaproveitado pelo Mundo 5 para mostrar uma linha de código de verdade
/// como `label`.
///
/// `showLabel: false` (Mundos 1/2, "Seu Programa" — ver
/// `.claude/memory/decisions.md`) esconde o texto e mostra só `icon` no
/// lugar, mantendo o badge de `repeatCount` — pensado para os rótulos
/// ficarem só nos `CommandButton`s da paleta abaixo, e os chips do
/// Programa montado ficarem compactos/padronizados. Continua exigindo
/// `label` mesmo com `showLabel: false`: usado como rótulo semântico
/// (`Semantics`) para não perder acessibilidade, e como texto do card de
/// Dica/Mundo 5 quando `showLabel` fica no padrão `true`.
class ProgramBlockChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final int? repeatCount;
  final String? badgeText;
  final bool highlighted;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool showLabel;
  final Border? border;

  const ProgramBlockChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.repeatCount,
    this.badgeText,
    this.highlighted = false,
    this.onTap,
    this.icon,
    this.showLabel = true,
    this.border,
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
    // Sem rótulo (só ícone), o chip não precisa esticar para caber texto —
    // um piso de largura garante uma área de toque quadrada e consistente
    // entre tipos de bloco diferentes (achado de acessibilidade: um chip
    // "estreito" só com ícone reduziria a área de toque abaixo do
    // confortável para um estande de toque).
    final chip = Container(
      constraints: BoxConstraints(minHeight: 44, minWidth: showLabel ? 0 : 44, maxWidth: maxChipWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: AppColors.overlaySoft, offset: Offset(0, 4), blurRadius: 0)],
        // `highlighted` (flash amarelo da Execução) tem prioridade sobre um
        // `border` estático (ex.: diferenciar "Enquanto" de "Se" no Mundo 2,
        // ver `BeltBlockChipStyle.border`/achado do UX Reviewer) — os dois
        // nunca precisam aparecer juntos.
        border: highlighted ? Border.all(color: AppColors.yellowNeon, width: 3) : border,
      ),
      child: Builder(builder: (context) {
        final row = Row(
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
            ] else if (badgeText != null) ...[
              // Mesmo papel do badge de `repeatCount` ("3×" ao lado do
              // ícone de Repetir já lia bem sem o texto do bloco) — usado
              // para diferenciar ícones espelhados que sozinhos ficam
              // ambíguos em miniatura (ex. "Virar ←"/"Virar →", achado do
              // UX Reviewer).
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.overlayBadge,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badgeText!, style: AppText.style(size: 12, weight: FontWeight.w900, color: foreground)),
              ),
              const SizedBox(width: 8),
            ],
            if (showLabel)
              Flexible(child: Text(label, style: AppText.style(size: 14, weight: FontWeight.w900, color: foreground)))
            else if (icon != null)
              icon!
            else
              // Fallback defensivo — nenhum call site hoje pede `showLabel:
              // false` sem `icon`, mas sem isso o chip ficaria vazio.
              Flexible(child: Text(label, style: AppText.style(size: 14, weight: FontWeight.w900, color: foreground))),
          ],
        );
        if (showLabel) return row;
        // `showLabel: false` (badge de repetição + ícone, sem texto) não tem
        // o mesmo motivo pra evitar encolher que o texto de código do Mundo
        // 5 tem (ver comentário acima) — badge+ícone sempre cabem juntos
        // num `FittedBox`, então deixamos o conjunto encolher como um todo
        // em vez de estourar quando a célula da grade (`ProgramChipGrid`)
        // for mais estreita que badge+ícone somados (achado real: Mundo 1,
        // bloco "Repetir" com badge "3×" + ícone, `RenderFlex overflowed`).
        return FittedBox(fit: BoxFit.scaleDown, child: row);
      }),
    );

    // `showLabel: false` esconde o texto visualmente, mas o rótulo
    // continua disponível para leitores de tela via `Semantics` — nunca
    // perder o nome do comando por completo.
    final semanticChip = showLabel ? chip : Semantics(label: label, child: chip);

    if (onTap == null) return semanticChip;
    return GestureDetector(onTap: onTap, child: semanticChip);
  }
}
