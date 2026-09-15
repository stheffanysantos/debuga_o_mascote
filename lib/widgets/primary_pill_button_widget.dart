import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import 'pulse_tap_widget.dart';

/// Botão de ação primária (amarelo neon) — "JOGAR", "PLAY", "Próxima fase",
/// "Tentar de novo". Sempre `yellowNeon` (ver `.claude/rules/design.md`).
/// `pulsing: true` reproduz a animação de destaque do design (menu, alvo).
class PrimaryPillButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final double height;
  final double fontSize;
  final bool pulsing;
  final bool enabled;
  final VoidCallback? onTap;

  const PrimaryPillButton({
    super.key,
    required this.label,
    this.icon,
    this.height = 64,
    this.fontSize = 22,
    this.pulsing = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.yellowNeon,
          borderRadius: BorderRadius.circular(height / 2.7),
          boxShadow: AppShadows.hardWithDepth(AppColors.yellowShadow),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(height / 2.7),
          child: InkWell(
            borderRadius: BorderRadius.circular(height / 2.7),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 10)],
                    Text(label, style: AppText.style(size: fontSize, weight: FontWeight.w900, color: AppColors.purpleDark)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!pulsing) return content;
    return PulseTap(child: content);
  }
}
