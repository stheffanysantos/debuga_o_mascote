import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Uma linha/opção tocável com destaque de seleção — extraído de
/// `CodePuzzleGameplayScreen` (Mundo 7, "toque na linha com o erro") para
/// ser reaproveitado por qualquer tela de veredito único que peça "toque
/// para escolher uma opção": hoje também Mundo 5 ("Preveja a Saída", opções
/// de resposta em texto) e Mundo 6 ("Complete o Código", linhas de código
/// candidatas). O conteúdo (`child`) fica a cargo de quem chama — pode ser
/// um `Text` simples ou um `RichText` com destaque de sintaxe
/// (`highlightCodeLine`, `lib/widgets/code_syntax_highlight.dart`).
///
/// Fundo sempre visível (`grayButton`, mesmo sem seleção) — achado do
/// usuário: sem nenhum fundo, as opções pareciam texto solto, sem affordance
/// de toque, num mundo de múltipla escolha. `label` (opcional, ex.: `'a)'`)
/// prefixa o conteúdo para reforçar "isto é uma lista de alternativas" —
/// usado hoje só pelo Mundo 5 (Preveja a Saída), onde as opções são texto
/// livre e não código; Mundo 6/7 continuam sem letra (as opções ali já são
/// visualmente linhas de código, uma letra ao lado confundiria mais que
/// ajudaria).
class SelectableLineTile extends StatelessWidget {
  final Widget child;
  final bool selected;
  final VoidCallback onTap;
  final String? label;

  const SelectableLineTile({super.key, required this.child, required this.selected, required this.onTap, this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? AppColors.purple.withValues(alpha: 0.35) : AppColors.grayButton,
          border: Border.all(color: selected ? AppColors.yellowNeon : Colors.transparent, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (label != null) ...[
              Text(label!, style: AppText.style(size: 16, weight: FontWeight.w900, color: selected ? AppColors.yellowNeon : AppColors.lilac)),
              const SizedBox(width: 10),
            ],
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
