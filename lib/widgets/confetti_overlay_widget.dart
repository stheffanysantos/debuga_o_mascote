import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Camada de confete caindo em loop — extraída de `VictoryScreen` (era
/// `_ConfettiPainter` inline) para ser reaproveitada por
/// `CodePuzzleResultScreen` (Mundo 3) sem duplicar a animação. Autocontido:
/// gerencia seu próprio `AnimationController`/`dispose` — quem usa só
/// coloca `const ConfettiOverlay()` dentro de um `Stack`, sem precisar de
/// `TickerProviderStateMixin` externo. Ver `.claude/memory/design-system.md`.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_controller.value)),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double t;

  _ConfettiPainter(this.t);

  static const _pieces = [
    (left: 0.08, phase: 0.0, speed: 1.0, color: AppColors.yellowNeon, isCircle: false),
    (left: 0.22, phase: 0.12, speed: 1.25, color: AppColors.lilac, isCircle: true),
    (left: 0.38, phase: 0.28, speed: 0.9, color: AppColors.white, isCircle: false),
    (left: 0.56, phase: 0.06, speed: 1.1, color: AppColors.yellowNeon, isCircle: false),
    (left: 0.72, phase: 0.34, speed: 0.95, color: AppColors.purple, isCircle: true),
    (left: 0.88, phase: 0.2, speed: 1.15, color: AppColors.lilac, isCircle: false),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in _pieces) {
      final progress = (t * piece.speed + piece.phase) % 1.0;
      final dy = -40 + progress * (size.height + 80);
      final dx = piece.left * size.width;
      final paint = Paint()..color = piece.color;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(progress * 6.28 * 1.5);
      if (piece.isCircle) {
        canvas.drawCircle(Offset.zero, 5, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -8, 10, 16), const Radius.circular(3)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
