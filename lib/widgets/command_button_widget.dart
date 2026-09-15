import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import 'hard_shadow_box_widget.dart';

/// Botão de comando da Gameplay (Andar / Virar ← / Virar → / Repetir 3×) —
/// ícone + rótulo, com tamanho sempre derivado do espaço real disponível
/// (nunca px fixo), para caber em qualquer tamanho de tela e escalar bem
/// em tablets. `iconBuilder` recebe o tamanho de ícone já calculado.
class CommandButton extends StatelessWidget {
  final Widget Function(double size) iconBuilder;
  final String label;
  final Color background;
  final Color foreground;
  final Color shadowColor;
  final VoidCallback onTap;

  /// Contorno opcional — usado quando 2 comandos têm a mesma cor de fundo
  /// mas significados bem diferentes (ex. Mundo 2: "Se Amarelo" vs.
  /// "Enquanto Amarelo", empilhados na mesma coluna), para diferenciá-los
  /// além do ícone pequeno (achado do UX Reviewer: ícone sozinho não bastava
  /// num toque rápido de estande).
  final Border? border;

  const CommandButton({
    super.key,
    required this.iconBuilder,
    required this.label,
    required this.background,
    required this.foreground,
    required this.shadowColor,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return HardShadowBox(
      color: background,
      shadows: [BoxShadow(color: shadowColor, offset: const Offset(0, 6), blurRadius: 0)],
      borderRadius: BorderRadius.circular(18),
      border: border,
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final box = math.min(constraints.maxWidth, constraints.maxHeight);
          final iconSize = (box * 0.36).clamp(16.0, 30.0);
          final fontSize = (box * 0.17).clamp(10.0, 14.0);
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconBuilder(iconSize),
                  SizedBox(height: box * 0.045),
                  // `FittedBox` em vez de um `Text` cru: rótulos mais longos
                  // (ex. "Se Amarelo → A" do Mundo 2, bem mais longo que
                  // "Andar"/"Virar ←" do Mundo 1) encolhem para caber em vez
                  // de quebrar linha e estourar a altura fixa da célula.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: AppText.style(size: fontSize, weight: FontWeight.w900, color: foreground),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
