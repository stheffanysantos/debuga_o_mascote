import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pequeno triângulo indicando a direção do Mascote na célula do tabuleiro
/// — equivalente ao truque de borda CSS do design original. Sempre desenha
/// apontando para a direita; quem rotaciona é o tile do mascote (mesma
/// rotação aplicada ao sprite).
class DirectionArrow extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const DirectionArrow({
    super.key,
    this.width = 8,
    this.height = 10,
    this.color = AppColors.yellowNeon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _TrianglePainter(color),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => oldDelegate.color != color;
}
