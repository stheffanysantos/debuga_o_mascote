import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Sombras "duras" (offset sólido, sem blur) usadas nos botões/cards do
/// design — equivalente a `box-shadow: 0 Npx 0 #cor` do CSS original.
abstract final class AppShadows {
  static List<BoxShadow> hard(Color color, {double dy = 8}) {
    return [BoxShadow(color: color, offset: Offset(0, dy), blurRadius: 0)];
  }

  /// Sombra dura + sombra suave por baixo, para os botões de ação primária
  /// (ex.: "JOGAR", "PLAY") que também têm profundidade de queda no design.
  static List<BoxShadow> hardWithDepth(Color color, {double dy = 10, double depthDy = 18}) {
    return [
      BoxShadow(color: color, offset: Offset(0, dy), blurRadius: 0),
      BoxShadow(color: AppColors.overlaySoft, offset: Offset(0, depthDy), blurRadius: 30),
    ];
  }
}
