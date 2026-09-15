import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'command_button_widget.dart';

/// Grade de `CommandButton`s — extraída de `GameplayScreen` (Mundo 1) para
/// ser reaproveitada por `ConveyorGameplayScreen` (Mundo 2), que tinha uma
/// árvore de `Row`s manual (2+2+1) em vez de grade (achado do usuário:
/// botões grandes demais, só 1-2 por linha). `crossAxisCount` decide quantos
/// cabem por linha (Mundo 1: 4; Mundo 2: 5) — a largura da célula é sempre
/// derivada do espaço real disponível, nunca px fixo, e a altura tem um teto
/// (`maxCellHeight`) para não gerar botões gigantes em telas largas
/// (tablet).
class CommandButtonGrid extends StatelessWidget {
  final List<CommandButton> buttons;
  final int crossAxisCount;
  final double maxCellHeight;

  const CommandButtonGrid({
    super.key,
    required this.buttons,
    required this.crossAxisCount,
    this.maxCellHeight = 72,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final cellWidth = (constraints.maxWidth - gap * (crossAxisCount - 1)) / crossAxisCount;
        final cellHeight = math.min(cellWidth, maxCellHeight);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: cellWidth / cellHeight,
          children: buttons,
        );
      },
    );
  }
}
