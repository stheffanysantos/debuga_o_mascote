import 'package:flutter/widgets.dart';

/// Paleta do jogo — ver `.claude/memory/design-system.md`.
/// Fonte única de cor: nenhuma tela/widget deve usar `Color(0x...)` direto.
abstract final class AppColors {
  static const background = Color(0xFF393939);
  static const panel = Color(0xFF2B2B2B);
  static const purpleDark = Color(0xFF2A1650);
  static const purple = Color(0xFF6D3DF5);
  static const lilac = Color(0xFFB48CFF);
  static const yellowNeon = Color(0xFFE8FF2A);
  static const white = Color(0xFFFFFFFF);

  // Sombras "duras" (offset, blur 0) dos botões/cards no estilo do design.
  static const purpleShadow = Color(0xFF4322A8);
  static const yellowShadow = Color(0xFFA3B800);
  static const lilacShadow = Color(0xFF7F5AD6);

  // Neutros de apoio usados pontualmente no design original.
  static const grayButton = Color(0xFF4A4A4A);
  static const grayLocked = Color(0xFF4F4F4F);
  static const grayLockedShadow = Color(0xFF333333);
  // Clareado o suficiente para passar de contraste AA (~4.7:1) contra
  // `grayLocked` — ver `.claude/memory/decisions.md` (achado de UX Reviewer
  // sobre o badge "EM BREVE"/cadeado, estande é ambiente bem iluminado).
  static const grayLockIcon = Color(0xFFC4C4C4);
  static const grayStarOff = Color(0xFF555555);
  static const grayCellFree = Color(0xFF444444);
  static const grayDashedBorder = Color(0xFF5A5A5A);
  static const wallStripe = Color(0xFF5B3FA0);

  // Preto puro e sombras suaves derivadas dele (chips, listras de parede) —
  // nomeados aqui em vez de espalhar `Colors.black`/`Color(0x...)` pelas telas.
  static const black = Color(0xFF000000);
  static const overlaySoft = Color(0x59000000);
  static const overlayBadge = Color(0x33000000);
}
