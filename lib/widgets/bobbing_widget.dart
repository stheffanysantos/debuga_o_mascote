import 'package:flutter/material.dart';

/// Faz o filho "flutuar" (translação vertical em loop) — usado no Mascote
/// da Splash e da Vitória, com durações diferentes.
class Bobbing extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double amplitude;

  const Bobbing({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 3000),
    this.amplitude = 10,
  });

  @override
  State<Bobbing> createState() => _BobbingState();
}

class _BobbingState extends State<Bobbing> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy = -widget.amplitude * Curves.easeInOut.transform(_controller.value);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}
