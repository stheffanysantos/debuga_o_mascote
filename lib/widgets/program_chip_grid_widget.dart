import 'package:flutter/material.dart';

/// Grade organizada de `ProgramBlockChip`s para a área "Seu Programa" —
/// cada chip recebe a mesma largura (derivada do espaço real, dividida em
/// `crossAxisCount` colunas), alinhando os blocos em colunas visuais em vez
/// de um `Wrap` "solto" (achado do usuário: os chips ficavam grandes e
/// desorganizados). Usa `Wrap` por baixo (não `GridView`) de propósito —
/// cada chip mantém sua própria altura (rótulos longos do Mundo 2, ex.
/// "Enquanto Amarelo → A", quebram em 2+ linhas sem estourar a célula,
/// diferente de uma grade de altura fixa).
class ProgramChipGrid extends StatelessWidget {
  final List<Widget> chips;
  final int crossAxisCount;

  const ProgramChipGrid({super.key, required this.chips, this.crossAxisCount = 4});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final chipWidth = (constraints.maxWidth - gap * (crossAxisCount - 1)) / crossAxisCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final chip in chips) SizedBox(width: chipWidth, child: chip)],
        );
      },
    );
  }
}
