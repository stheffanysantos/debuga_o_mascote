import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// Fileira de 3 estrelas (Seleção de Fases, Vitória) — `lit` estrelas
/// acesas em amarelo, o restante apagado.
class StarRow extends StatelessWidget {
  final int lit;
  final double size;
  final double gap;

  const StarRow({super.key, required this.lit, this.size = 20, this.gap = 2});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) SizedBox(width: gap),
          AppIcons.star(size: size, color: i < lit ? AppColors.yellowNeon : AppColors.grayStarOff),
        ],
      ],
    );
  }
}
