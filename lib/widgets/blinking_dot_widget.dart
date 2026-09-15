import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pontinho amarelo piscando ao lado do texto "LICODE · FEIRA DE TECNOLOGIA".
class BlinkingDot extends StatefulWidget {
  final double size;

  const BlinkingDot({super.key, this.size = 8});

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.35).animate(_controller),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(color: AppColors.yellowNeon, shape: BoxShape.circle),
      ),
    );
  }
}
