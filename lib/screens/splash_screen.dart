import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../widgets/blinking_dot_widget.dart';
import '../widgets/bobbing_widget.dart';
import '../widgets/dotted_background_widget.dart';
import '../widgets/mascot_image_widget.dart';
import '../widgets/primary_pill_button_widget.dart';
import 'world_select_screen.dart';

/// Tela 1 — Splash/Menu. Ver `.claude/docs/NAVIGATION_FLOW.md`.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const DottedBackground(),
          Builder(
            builder: (context) {
              final glowSize = (MediaQuery.sizeOf(context).width * 0.72).clamp(200.0, 320.0);
              return Positioned(
                top: -glowSize * 0.28,
                right: -glowSize * 0.28,
                child: Container(
                  width: glowSize,
                  height: glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.purple.withValues(alpha: 0.35),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BlinkingDot(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'LICODE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.eyebrow(size: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text('</> JOGO DE LÓGICA', style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.yellowNeon, letterSpacing: 1.3)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: AppText.style(size: 52, weight: FontWeight.w900, color: AppColors.white, height: 0.95, letterSpacing: -1),
                        children: [
                          const TextSpan(text: 'DEBUGA\nO\n'),
                          TextSpan(text: 'MASCOTE', style: AppText.style(size: 52, weight: FontWeight.w900, color: AppColors.lilac, height: 0.95, letterSpacing: -1)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final available = math.max(constraints.maxWidth, 0.0) < math.max(constraints.maxHeight, 0.0)
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                        // Só limita o teto (telas enormes) — nunca o piso:
                        // exigir um mínimo aqui faria o círculo pedir mais
                        // espaço do que o Expanded realmente tem, estourando
                        // em telas baixas.
                        final circleSize = available.clamp(0.0, 340.0) * 0.82;
                        final mascotSize = circleSize * 0.86;
                        return Center(
                          // A caixa precisa ter o tamanho do círculo (o
                          // maior elemento) — do contrário o Stack se
                          // dimensiona pelo mascote e corta o círculo nas
                          // bordas em vez de mostrá-lo redondo.
                          child: SizedBox(
                            width: circleSize,
                            height: circleSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: circleSize,
                                  height: circleSize,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.purpleDark),
                                ),
                                Bobbing(child: MascotImage(size: mascotSize)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  PrimaryPillButton(
                    label: 'JOGAR',
                    height: 76,
                    fontSize: 30,
                    pulsing: true,
                    icon: AppIcons.play(size: 30, color: AppColors.purpleDark),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const WorldSelectScreen(),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
