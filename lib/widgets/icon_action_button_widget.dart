import 'package:flutter/material.dart';

import 'hard_shadow_box_widget.dart';

/// Botão quadrado/retangular de ícone com sombra dura — voltar, menu,
/// reiniciar. Reutilizado em todas as telas.
class IconActionButton extends StatelessWidget {
  final Widget icon;
  final Color background;
  final Color shadowColor;
  final double size;
  final double borderRadius;
  final VoidCallback? onTap;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.background,
    required this.shadowColor,
    this.size = 52,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HardShadowBox(
      color: background,
      shadows: [BoxShadow(color: shadowColor, offset: const Offset(0, 8), blurRadius: 0)],
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: SizedBox(width: size, height: size, child: Center(child: icon)),
    );
  }
}
