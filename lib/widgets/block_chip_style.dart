import 'package:flutter/widgets.dart';

import '../models/block.dart';
import '../theme/app_colors.dart';

/// Rótulo e cores de um Bloco no "Seu Programa" e na Dica — única fonte
/// dessa correspondência (usada pela Gameplay e pela tela de Tentativa
/// Falha), para não duplicar a mesma lógica em mais de um lugar.
class BlockChipStyle {
  final String label;
  final Color background;
  final Color foreground;
  final int? repeatCount;

  const BlockChipStyle({required this.label, required this.background, required this.foreground, this.repeatCount});
}

BlockChipStyle styleForBlock(Block block) {
  switch (block.type) {
    case BlockType.walk:
      return const BlockChipStyle(label: 'Andar', background: AppColors.lilac, foreground: AppColors.purpleDark);
    case BlockType.turnLeft:
      return const BlockChipStyle(label: 'Virar ←', background: AppColors.purple, foreground: AppColors.white);
    case BlockType.turnRight:
      return const BlockChipStyle(label: 'Virar →', background: AppColors.purple, foreground: AppColors.white);
    case BlockType.repeat:
      return const BlockChipStyle(label: 'Repetir', background: AppColors.yellowNeon, foreground: AppColors.purpleDark, repeatCount: 3);
  }
}
