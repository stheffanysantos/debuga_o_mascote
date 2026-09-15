import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/app_sounds.dart';
import '../game/scoring.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../widgets/bobbing_widget.dart';
import '../widgets/confetti_overlay_widget.dart';
import '../widgets/dotted_background_widget.dart';
import '../widgets/icon_action_button_widget.dart';
import '../widgets/mascot_image_widget.dart';
import '../widgets/primary_pill_button_widget.dart';
import '../widgets/stat_card_widget.dart';

/// Tela 4 — Vitória. Genérica entre motores de jogo (Mundo 1 — labirinto —
/// e Mundo 2 — esteira — chegam nela com dados equivalentes, ver
/// `.claude/memory/decisions.md`, entrada "Mundo 2"): pontos/estrelas são
/// calculados de verdade a partir de `blocksUsed` vs. `optimalBlocks` (ver
/// `lib/game/scoring.dart`). A tela não decide navegação nenhuma — quem a
/// constrói passa `onPrimaryAction`, chamado ao tocar o botão primário.
class VictoryScreen extends StatefulWidget {
  final int levelNumber;
  final int blocksUsed;
  final int maxBlocks;
  final int optimalBlocks;

  /// `true` quando existe uma próxima fase — decide o rótulo do botão
  /// primário ("Próxima fase" vs. "Ver fases"). A navegação em si é sempre
  /// responsabilidade de [onPrimaryAction].
  final bool hasNext;

  /// Chamado ao tocar o botão primário — a tela nunca navega sozinha.
  final VoidCallback onPrimaryAction;

  const VictoryScreen({
    super.key,
    required this.levelNumber,
    required this.blocksUsed,
    required this.maxBlocks,
    required this.optimalBlocks,
    required this.hasNext,
    required this.onPrimaryAction,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> with TickerProviderStateMixin {
  // Só para a rotação do anel atrás do mascote — a animação do confete em
  // si agora vive dentro de `ConfettiOverlay` (autocontida, próprio
  // controller). Mesma duração das duas, então continuam visualmente no
  // mesmo ritmo mesmo sendo controllers diferentes.
  late final AnimationController _ringController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();
  late final AnimationController _starsController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void initState() {
    super.initState();
    AppSounds.instance.victory();
  }

  @override
  void dispose() {
    _ringController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = computeScore(blocksUsed: widget.blocksUsed, optimalBlocks: widget.optimalBlocks);

    // Tamanho derivado só da largura da tela (nunca de "altura restante"),
    // e a tela inteira rola se o conteúdo não couber — a combinação
    // garante que nada aqui pode estourar, em nenhum celular ou tablet.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ringSize = math.min(screenWidth * 0.72, 300.0);
    final innerCircleSize = ringSize * 0.87;
    final mascotSize = ringSize * 0.73;

    return Scaffold(
      backgroundColor: AppColors.purpleDark,
      body: Stack(
        children: [
          const DottedBackground(opacity: 0.08),
          const ConfettiOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('FASE ${widget.levelNumber} CONCLUÍDA', style: AppText.eyebrow(size: 13)),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Mandou bem!', style: AppText.style(size: 48, weight: FontWeight.w900, color: AppColors.yellowNeon, height: 1)),
                    ),
                    const SizedBox(height: 22),
                    _buildStars(score.stars),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: innerCircleSize,
                            height: innerCircleSize,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.background),
                          ),
                          RotationTransition(
                            turns: _ringController,
                            child: Container(
                              width: ringSize,
                              height: ringSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.purple, width: 3),
                              ),
                            ),
                          ),
                          Bobbing(
                            duration: const Duration(milliseconds: 1200),
                            amplitude: 8,
                            child: MascotImage(size: mascotSize, expression: MascotExpression.celebrating),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: StatCard(label: 'PONTOS', value: '${score.points}')),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard(label: 'BLOCOS', value: '${widget.blocksUsed}', suffix: '/ ${widget.maxBlocks}')),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        IconActionButton(
                          size: 72,
                          borderRadius: 22,
                          background: AppColors.purple,
                          shadowColor: AppColors.purpleShadow,
                          icon: AppIcons.refresh(size: 28, color: AppColors.white),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PrimaryPillButton(
                            label: widget.hasNext ? 'Próxima fase' : 'Ver fases',
                            height: 72,
                            fontSize: 24,
                            icon: AppIcons.arrowRight(size: 26, color: AppColors.purpleDark),
                            onTap: widget.onPrimaryAction,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(int litStars) {
    return AnimatedBuilder(
      animation: _starsController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _popStar(size: 64, delay: 0.0, lit: litStars >= 1),
            const SizedBox(width: 6),
            _popStar(size: 84, delay: 0.28, marginBottom: 14, lit: litStars >= 2),
            const SizedBox(width: 6),
            _popStar(size: 64, delay: 0.56, lit: litStars >= 3),
          ],
        );
      },
    );
  }

  Widget _popStar({required double size, required double delay, required bool lit, double marginBottom = 0}) {
    final t = ((_starsController.value - delay).clamp(0.0, 1.0) / (1 - delay)).clamp(0.0, 1.0);
    final scale = Curves.elasticOut.transform(t);
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom),
      child: Transform.scale(
        scale: scale,
        child: AppIcons.star(size: size, color: lit ? AppColors.yellowNeon : AppColors.grayStarOff),
      ),
    );
  }
}
