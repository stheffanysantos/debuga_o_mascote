import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografia — Nunito (pesos 800/900 para títulos/números de destaque).
/// Fonte única de `TextStyle`: nenhuma tela/widget deve montar `TextStyle`
/// com `fontSize`/`fontWeight` literais fora daqui (ver `.claude/rules/design.md`).
abstract final class AppText {
  static TextStyle style({
    required double size,
    required FontWeight weight,
    Color color = AppColors.white,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Rótulo pequeno em maiúsculas com letter-spacing largo (ex.: "MUNDO 1",
  /// "FASE 6", "SEU PROGRAMA") — reutilizado em todas as telas.
  static TextStyle eyebrow({double size = 12, Color color = AppColors.lilac}) {
    return style(size: size, weight: FontWeight.w900, color: color, letterSpacing: size * 0.14);
  }
}
