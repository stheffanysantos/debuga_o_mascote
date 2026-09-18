import 'package:flutter/material.dart';

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

  /// Sombra dura (offset, blur 0) do `CommandButton` deste bloco na paleta
  /// de comandos — mesma cor "escurecida" do `background`, ver
  /// `.claude/memory/design-system.md`.
  final Color shadowColor;
  final int? repeatCount;
  final String? badgeText;
  final Widget Function(double size) icon;

  /// Contorno opcional — usado pelo bloco condicional de resgate
  /// (`rescueIfCharacterHere`), que reaproveita a mesma cor de fundo de
  /// `walk` (`lilac`) por ser a escolha menos ambígua da paleta (evita
  /// colidir com `repeat`/`yellowNeon`, o bloco mais usado ao lado dele no
  /// mesmo Programa). Sem contorno, os dois ficavam diferenciados só pelo
  /// `badgeText` no chip de "Seu Programa" — achado do UX Reviewer, mesma
  /// lição já aplicada a "Se"/"Enquanto" da antiga Esteira e aos blocos
  /// condicionais do Mundo 4.
  final Border? border;

  const BlockChipStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.shadowColor,
    this.repeatCount,
    this.badgeText,
    required this.icon,
    this.border,
  });
}

/// Blocos disponíveis por Mundo — todos `WorldGameType.maze`. Mundo 1
/// ("Primeiros passos") e Mundo 3 ("Desenho no Tabuleiro") só os 4 básicos;
/// Mundo 2 ("Resgate de Personagens") acrescenta o bloco condicional de
/// resgate. Ver `.claude/docs/GAME_DESIGN.md`.
List<BlockType> availableBlockTypesForWorld(int worldNumber) {
  const basic = [
    BlockType.walk,
    BlockType.turnLeft,
    BlockType.turnRight,
    BlockType.repeat,
  ];
  if (worldNumber == 2) {
    return [...basic, BlockType.rescueIfCharacterHere];
  }
  return basic;
}

BlockChipStyle styleForBlock(Block block) {
  switch (block.type) {
    case BlockType.walk:
      return BlockChipStyle(
        label: 'Andar',
        background: AppColors.lilac,
        foreground: AppColors.purpleDark,
        shadowColor: AppColors.lilacShadow,
        icon: (size) => AppIcons.walk(size: size, color: AppColors.purpleDark),
      );
    case BlockType.turnLeft:
      return BlockChipStyle(
        label: 'Virar ←',
        background: AppColors.purple,
        foreground: AppColors.white,
        shadowColor: AppColors.purpleShadow,
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
        shadowColor: AppColors.purpleShadow,
        badgeText: '→',
        icon: (size) => AppIcons.turnRight(size: size, color: AppColors.white),
      );
    case BlockType.repeat:
      return BlockChipStyle(
        label: 'Repetir',
        background: AppColors.yellowNeon,
        foreground: AppColors.purpleDark,
        shadowColor: AppColors.yellowShadow,
        repeatCount: 3,
        icon: (size) =>
            AppIcons.repeat(size: size, color: AppColors.purpleDark),
      );
    case BlockType.rescueIfCharacterHere:
      // Fundo `lilac` (mesma cor de `walk`) — a escolha menos ambígua da
      // paleta: evita colidir com `repeat`/`yellowNeon` (o bloco mais usado
      // ao lado deste no mesmo Programa, via "Repetir 3× + Se resgate") e
      // evita virar o 3º bloco em `purple` (já dividido entre `turnLeft`/
      // `turnRight`). Contorno + badge diferenciam de `walk` — mesma
      // técnica já usada pelos antigos condicionais de Placa e pelos
      // condicionais do Mundo 4. Sem SVG dedicado para "resgatar"/"coração"
      // em `AppIcons` — reaproveita `Icons.favorite` do Material, mesma
      // exceção documentada já usada no Mundo 4 (`Icons.functions`/
      // `Icons.exposure_plus_1`).
      return BlockChipStyle(
        label: 'Se tiver, resgate',
        background: AppColors.lilac,
        foreground: AppColors.purpleDark,
        shadowColor: AppColors.lilacShadow,
        badgeText: 'RESGATE',
        border: Border.all(color: AppColors.purpleDark, width: 3),
        icon: (size) =>
            Icon(Icons.favorite, size: size, color: AppColors.purpleDark),
      );
  }
}
