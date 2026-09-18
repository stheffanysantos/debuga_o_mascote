import 'package:flutter/widgets.dart';

import '../models/block.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// Rótulo, cores e ícone de um Bloco no "Seu Programa" e na Dica — única
/// fonte dessa correspondência (usada pela Gameplay e pela tela de
/// Tentativa Falha), para não duplicar a mesma lógica em mais de um lugar.
/// `icon` recebe o tamanho já calculado por quem chama — mesmo padrão de
/// `CommandButton.iconBuilder` — para caber tanto no botão de comando
/// (ícone grande) quanto no chip de "Seu Programa" (ícone menor, ver
/// `programBlockChipIconSize`).
class BlockChipStyle {
  final String label;
  final Color background;
  final Color foreground;
  final int? repeatCount;
  final String? badgeText;
  final Widget Function(double size) icon;

  const BlockChipStyle({
    required this.label,
    required this.background,
    required this.foreground,
    this.repeatCount,
    this.badgeText,
    required this.icon,
  });
}

BlockChipStyle styleForBlock(Block block) {
  switch (block.type) {
    case BlockType.walk:
      return BlockChipStyle(
        label: 'Andar',
        background: AppColors.lilac,
        foreground: AppColors.purpleDark,
        icon: (size) => AppIcons.walk(size: size, color: AppColors.purpleDark),
      );
    case BlockType.turnLeft:
      return BlockChipStyle(
        label: 'Virar ←',
        background: AppColors.purple,
        foreground: AppColors.white,
        // Ícones de `turnLeft`/`turnRight` são o mesmo traço espelhado —
        // sem o rótulo ao lado (Mundo 1, "Seu Programa"), os dois ficam
        // ambíguos em miniatura (achado do UX Reviewer). Badge com a seta
        // do lado reforça a direção, mesmo padrão visual já usado pelo
        // badge "3×" de `Repetir`.
        badgeText: '←',
        icon: (size) => AppIcons.turnLeft(size: size, color: AppColors.white),
      );
    case BlockType.turnRight:
      return BlockChipStyle(
        label: 'Virar →',
        background: AppColors.purple,
        foreground: AppColors.white,
        badgeText: '→',
        icon: (size) => AppIcons.turnRight(size: size, color: AppColors.white),
      );
    case BlockType.repeat:
      return BlockChipStyle(
        label: 'Repetir',
        background: AppColors.yellowNeon,
        foreground: AppColors.purpleDark,
        repeatCount: 3,
        icon: (size) => AppIcons.repeat(size: size, color: AppColors.purpleDark),
      );
  }
}
