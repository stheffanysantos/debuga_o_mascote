import 'package:flutter/widgets.dart';

import '../models/belt_block.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// Ícone dos 2 comandos condicionais ("Se"): uma bolinha (eco do Item da
/// esteira) + seta — reforça visualmente "isto é uma decisão baseada numa
/// cor", em vez da seta genérica sozinha (achado do UX Reviewer). Extraído
/// de `ConveyorGameplayView` (era `_conditionIcon`, privado) para ser
/// reaproveitado tanto pelo `CommandButton` da paleta quanto pelo ícone do
/// `ProgramBlockChip` em "Seu Programa" (`styleForBeltBlock` abaixo), sem
/// duplicar a construção do ícone. `foreground` já contrasta com o fundo
/// colorido de quem chama (roxo escuro no fundo amarelo, branco no roxo).
Widget conditionIcon(double size, {required Color foreground}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: size * 0.42, height: size * 0.42, decoration: BoxDecoration(shape: BoxShape.circle, color: foreground)),
      SizedBox(width: size * 0.12),
      AppIcons.arrowRight(size: size * 0.7, color: foreground),
    ],
  );
}

/// Mesma ideia de `conditionIcon` (bolinha ecoando o Item da esteira), mas
/// com o ícone de `Repetir` em vez da seta — reforça visualmente que
/// "Enquanto" também repete, só que condicionalmente (não um número fixo
/// como `Repetir 3×`). Extraído de `ConveyorGameplayView` (era
/// `_whileIcon`, privado) pelo mesmo motivo de `conditionIcon`.
Widget whileIcon(double size, {required Color foreground}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: size * 0.42, height: size * 0.42, decoration: BoxDecoration(shape: BoxShape.circle, color: foreground)),
      SizedBox(width: size * 0.12),
      AppIcons.repeat(size: size * 0.7, color: foreground),
    ],
  );
}

/// Rótulo, cores e ícone de um Bloco da Esteira no "Seu Programa" e na
/// Dica — mesma ideia de `BlockChipStyle`/`styleForBlock`
/// (`lib/widgets/block_chip_style.dart`, Mundo 1), única fonte dessa
/// correspondência para `BeltBlockType` (Mundo 2).
class BeltBlockChipStyle {
  final String label;
  final Color background;
  final Color foreground;
  final int? repeatCount;
  final Widget Function(double size) icon;
  final Border? border;

  const BeltBlockChipStyle({
    required this.label,
    required this.background,
    required this.foreground,
    this.repeatCount,
    required this.icon,
    this.border,
  });
}

BeltBlockChipStyle styleForBeltBlock(BeltBlock block) {
  switch (block.type) {
    case BeltBlockType.ifYellowToBinA:
      return BeltBlockChipStyle(
        label: 'Se Amarelo → A',
        background: AppColors.yellowNeon,
        foreground: AppColors.purpleDark,
        icon: (size) => conditionIcon(size, foreground: AppColors.purpleDark),
      );
    case BeltBlockType.ifPurpleToBinB:
      return BeltBlockChipStyle(
        label: 'Se Roxo → B',
        background: AppColors.purple,
        foreground: AppColors.white,
        icon: (size) => conditionIcon(size, foreground: AppColors.white),
      );
    case BeltBlockType.repeat:
      return BeltBlockChipStyle(
        label: 'Repetir',
        background: AppColors.lilac,
        foreground: AppColors.purpleDark,
        repeatCount: 3,
        icon: (size) => AppIcons.repeat(size: size, color: AppColors.purpleDark),
      );
    case BeltBlockType.whileYellowToBinA:
      return BeltBlockChipStyle(
        label: 'Enquanto Amarelo → A',
        background: AppColors.yellowNeon,
        foreground: AppColors.purpleDark,
        icon: (size) => whileIcon(size, foreground: AppColors.purpleDark),
        // Mesmo contorno já usado no `CommandButton` da paleta pra
        // diferenciar "Enquanto" de "Se" (fundo idêntico) — sem isso, o
        // chip de "Seu Programa" perdia esse diferenciador ao esconder o
        // texto (achado do UX Reviewer: regressão de um achado de UX já
        // corrigido antes).
        border: Border.all(color: AppColors.purpleDark, width: 3),
      );
    case BeltBlockType.whilePurpleToBinB:
      return BeltBlockChipStyle(
        label: 'Enquanto Roxo → B',
        background: AppColors.purple,
        foreground: AppColors.white,
        icon: (size) => whileIcon(size, foreground: AppColors.white),
        border: Border.all(color: AppColors.white, width: 3),
      );
  }
}
