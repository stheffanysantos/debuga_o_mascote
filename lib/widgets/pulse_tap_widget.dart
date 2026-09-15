import 'package:flutter/material.dart';

/// Envolve `child` numa pulsação suave em loop + toque — usado no botão
/// "JOGAR" da Splash, na fase atual da Seleção de Fases e no alvo da
/// Gameplay.
class PulseTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double maxScale;
  final Duration duration;

  const PulseTap({
    super.key,
    required this.child,
    this.onTap,
    this.maxScale = 1.04,
    this.duration = const Duration(milliseconds: 1100),
  });

  @override
  State<PulseTap> createState() => _PulseTapState();
}

class _PulseTapState extends State<PulseTap> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaled = ScaleTransition(
      scale: Tween(begin: 1.0, end: widget.maxScale).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
    if (widget.onTap == null) return scaled;
    return GestureDetector(onTap: widget.onTap, child: scaled);
  }
}
