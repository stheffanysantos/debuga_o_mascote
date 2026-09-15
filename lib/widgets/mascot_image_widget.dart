import 'package:flutter/material.dart';

/// As 3 expressões do Mascote — ver `.claude/memory/design-system.md`.
enum MascotExpression { neutral, celebrating, confused }

/// Arte real do mascote (`assets/images/mascot.png`, fundo transparente).
/// Substitui o antigo `MascotPlaceholder` — ver `.claude/memory/decisions.md`.
///
/// Só existe uma expressão desenhada por enquanto (a pose neutra/sorrindo).
/// Até termos as variações de "comemorando"/"confuso", `celebrating` usa a
/// mesma arte (a animação de contexto — `Bobbing`, confete — já comunica a
/// vitória) e `confuso` aplica um leve dessaturado sobre a mesma arte,
/// reproduzindo a pista visual do design original (`filter: saturate(.55)`).
class MascotImage extends StatelessWidget {
  final double size;
  final MascotExpression expression;

  const MascotImage({
    super.key,
    this.size = 200,
    this.expression = MascotExpression.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/mascot.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (expression != MascotExpression.confused) {
      return SizedBox(width: size, height: size, child: image);
    }

    return SizedBox(
      width: size,
      height: size,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(_desaturateMatrix),
        child: image,
      ),
    );
  }
}

// Matriz de dessaturação parcial (saturação = 0.55), fórmula padrão do
// filtro SVG/CSS `feColorMatrix type="saturate"` — equivalente exato ao
// `filter: saturate(.55)` do CSS do design original.
const _desaturateMatrix = <double>[
  0.64585, 0.32175, 0.0324, 0, 0,
  0.09585, 0.87175, 0.0324, 0, 0,
  0.09585, 0.32175, 0.5824, 0, 0,
  0, 0, 0, 1, 0,
];
