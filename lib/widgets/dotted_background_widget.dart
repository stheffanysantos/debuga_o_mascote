import 'package:flutter/material.dart';

/// Textura de fundo pontilhada usada atrás do conteúdo em quase todas as
/// telas — reproduz o `background-image: radial-gradient(...)` do design.
class DottedBackground extends StatelessWidget {
  final double opacity;
  final double spacing;

  const DottedBackground({super.key, this.opacity = 0.07, this.spacing = 28});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _DotGridPainter(opacity: opacity, spacing: spacing)),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final double opacity;
  final double spacing;

  _DotGridPainter({required this.opacity, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.spacing != spacing;
}
