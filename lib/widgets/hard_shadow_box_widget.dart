import 'package:flutter/material.dart';

/// Container com sombra "dura" (estilo do design: offset sólido, sem blur)
/// e cantos arredondados — base de todos os botões/cards do jogo. Ver
/// `.claude/memory/design-system.md`.
class HardShadowBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  const HardShadowBox({
    super.key,
    required this.child,
    required this.color,
    required this.shadows,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.onTap,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: shadows,
        border: border,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
