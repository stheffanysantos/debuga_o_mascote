import 'package:flutter/widgets.dart';

import '../models/belt_block.dart';
import '../theme/app_colors.dart';

/// Rótulo e cores de um Bloco da Esteira no "Seu Programa" e na Dica — mesma
/// ideia de `BlockChipStyle`/`styleForBlock` (`lib/widgets/block_chip_style.dart`,
/// Mundo 1), única fonte dessa correspondência para `BeltBlockType` (Mundo 2).
class BeltBlockChipStyle {
  final String label;
  final Color background;
  final Color foreground;
  final int? repeatCount;

  const BeltBlockChipStyle({required this.label, required this.background, required this.foreground, this.repeatCount});
}

BeltBlockChipStyle styleForBeltBlock(BeltBlock block) {
  switch (block.type) {
    case BeltBlockType.ifYellowToBinA:
      return const BeltBlockChipStyle(label: 'Se Amarelo → A', background: AppColors.yellowNeon, foreground: AppColors.purpleDark);
    case BeltBlockType.ifPurpleToBinB:
      return const BeltBlockChipStyle(label: 'Se Roxo → B', background: AppColors.purple, foreground: AppColors.white);
    case BeltBlockType.repeat:
      return const BeltBlockChipStyle(label: 'Repetir', background: AppColors.lilac, foreground: AppColors.purpleDark, repeatCount: 3);
    case BeltBlockType.whileYellowToBinA:
      return const BeltBlockChipStyle(label: 'Enquanto Amarelo → A', background: AppColors.yellowNeon, foreground: AppColors.purpleDark);
    case BeltBlockType.whilePurpleToBinB:
      return const BeltBlockChipStyle(label: 'Enquanto Roxo → B', background: AppColors.purple, foreground: AppColors.white);
  }
}
