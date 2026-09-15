import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/app_sounds.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../widgets/dotted_background_widget.dart';
import '../widgets/icon_action_button_widget.dart';
import '../widgets/mascot_image_widget.dart';
import '../widgets/primary_pill_button_widget.dart';
import '../widgets/program_chip_grid_widget.dart';

/// Tela 5 — Tentativa Falha. Genérica entre motores de jogo (mesma ideia de
/// `VictoryScreen` — ver `.claude/memory/decisions.md`, entrada "Mundo 2"):
/// motivo da falha (`reasonText`) e Dica (`hintChips`) já vêm prontos de
/// quem constrói a tela, a partir do resultado real da Execução (`GameOutcome`
/// do Mundo 1 ou `BeltOutcome` do Mundo 2) — ver `.claude/docs/GAME_DESIGN.md`.
class FailureScreen extends StatefulWidget {
  final int levelNumber;
  final int attempt;

  /// Texto já pronto explicando o motivo da falha — quem chama decide a
  /// partir do outcome do motor certo (`GameOutcome`/`BeltOutcome`).
  final String reasonText;

  final int maxBlocks;

  /// Chips da Dica (`hintProgram`), já construídos por quem chama (ex.:
  /// `ProgramBlockChip` a partir de `styleForBlock`/`styleForBeltBlock`) —
  /// esta tela só os organiza num `Wrap`.
  final List<Widget> hintChips;

  /// Chamado ao tocar o botão "Menu" — a tela nunca navega sozinha.
  final VoidCallback onBackToMenu;

  const FailureScreen({
    super.key,
    required this.levelNumber,
    required this.attempt,
    required this.reasonText,
    required this.maxBlocks,
    required this.hintChips,
    required this.onBackToMenu,
  });

  @override
  State<FailureScreen> createState() => _FailureScreenState();
}

class _FailureScreenState extends State<FailureScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    AppSounds.instance.failure();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tamanho derivado só da largura da tela (nunca de "altura restante"),
    // e a tela inteira rola se o conteúdo não couber — a combinação
    // garante que nada aqui pode estourar, em nenhum celular ou tablet.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final circleSize = math.min(screenWidth * 0.6, 260.0);
    final mascotSize = circleSize * 0.85;
    final bubbleSize = circleSize * 0.29;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const DottedBackground(opacity: 0.06),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('FASE ${widget.levelNumber} · TENTATIVA ${widget.attempt}', style: AppText.eyebrow(size: 13)),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Ops, um bug!', style: AppText.style(size: 48, weight: FontWeight.w900, color: AppColors.white, height: 1)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.reasonText,
                      textAlign: TextAlign.center,
                      style: AppText.style(size: 17, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: circleSize,
                      height: circleSize + bubbleSize * 0.35,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.panel),
                              alignment: Alignment.center,
                              child: Transform.rotate(
                                angle: -0.1,
                                child: MascotImage(size: mascotSize, expression: MascotExpression.confused),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: circleSize * 0.02,
                            child: AnimatedBuilder(
                              animation: _shakeController,
                              builder: (context, child) {
                                final angle = (_shakeController.value - 0.5) * 0.14;
                                return Transform.rotate(angle: angle, child: child);
                              },
                              child: Container(
                                width: bubbleSize,
                                height: bubbleSize,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.yellowNeon,
                                  borderRadius: BorderRadius.circular(bubbleSize * 0.32),
                                  boxShadow: [BoxShadow(color: AppColors.yellowShadow, offset: Offset(0, bubbleSize * 0.08), blurRadius: 0)],
                                ),
                                child: Text('?', style: AppText.style(size: bubbleSize * 0.53, weight: FontWeight.w900, color: AppColors.purpleDark)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DICA', style: AppText.eyebrow(size: 11)),
                          const SizedBox(height: 8),
                          Text(
                            'Essa sequência resolve a fase dentro do limite de ${widget.maxBlocks} blocos:',
                            style: AppText.style(size: 15, weight: FontWeight.w800, color: AppColors.white, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          // 2 colunas (não o padrão 4 de "Seu Programa") —
                          // este card já tem padding próprio (16px) somado
                          // ao da tela, deixando menos largura disponível;
                          // com 4 colunas a célula ficava estreita demais e
                          // o chip estourava (achado ao rodar
                          // `no_overflow_test.dart`).
                          ProgramChipGrid(chips: widget.hintChips, crossAxisCount: 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        IconActionButton(
                          size: 72,
                          borderRadius: 22,
                          background: AppColors.grayButton,
                          shadowColor: Colors.transparent,
                          icon: AppIcons.home(size: 26, color: AppColors.white),
                          onTap: widget.onBackToMenu,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PrimaryPillButton(
                            label: 'Tentar de novo',
                            height: 72,
                            fontSize: 24,
                            icon: AppIcons.refresh(size: 26, color: AppColors.purpleDark),
                            onTap: () => Navigator.of(context).pop(),
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
}
