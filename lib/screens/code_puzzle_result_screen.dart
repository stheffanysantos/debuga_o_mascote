import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/app_sounds.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../widgets/bobbing_widget.dart';
import '../widgets/confetti_overlay_widget.dart';
import '../widgets/dotted_background_widget.dart';
import '../widgets/icon_action_button_widget.dart';
import '../widgets/mascot_image_widget.dart';
import '../widgets/primary_pill_button_widget.dart';
import '../widgets/program_chip_grid_widget.dart';
import '../widgets/star_row_widget.dart';
import '../widgets/stat_card_widget.dart';

/// Tela de Resultado do Mundo 3 ("Modo Debug") — uma tela só, parametrizada
/// por `won`, em vez de duas telas (`VictoryScreen`/`FailureScreen`) como
/// nos outros mundos: um puzzle de veredito único (`lib/game/code_puzzle_checker.dart`)
/// não tem "quase certo" — ver `.claude/docs/GAME_DESIGN.md`, seção "Mundo
/// 3 — Modo Debug". Desacoplada de `CodePuzzleLevel`/`checkReorder`/
/// `checkFindBug` — só recebe dados já prontos, mesmo espírito de
/// `VictoryScreen`/`FailureScreen`.
class CodePuzzleResultScreen extends StatefulWidget {
  final bool won;
  final int levelNumber;
  final int attempts;

  /// Só relevantes quando `won == true` (0 nos outros casos).
  final int stars;
  final int points;

  /// `CodePuzzleLevel.bugExplanation` — mostrada sempre (ganhou ou perdeu)
  /// quando a fase é `findBug`; `null` quando é `reorder`.
  final String? explanationText;

  /// A ordem certa da fase como "Dica" — só quando perdeu um `reorder`
  /// (`null` nos outros 3 casos: ganhou reorder, ganhou findBug, perdeu
  /// findBug — lá quem explica o erro já é `explanationText`).
  final List<Widget>? correctOrderChips;

  /// Só relevante quando `won == true` — decide o rótulo do botão primário
  /// ("Próxima fase" vs. "Ver fases").
  final bool hasNext;

  /// Chamado ao tocar o botão primário quando `won == true`. Quando
  /// `won == false`, o botão primário ("Tentar de novo") só dá `pop()` —
  /// este callback não é usado nesse caso.
  final VoidCallback onPrimaryAction;

  /// Chamado ao tocar "Menu" quando `won == false`.
  final VoidCallback onBackToMenu;

  const CodePuzzleResultScreen({
    super.key,
    required this.won,
    required this.levelNumber,
    required this.attempts,
    required this.stars,
    required this.points,
    this.explanationText,
    this.correctOrderChips,
    required this.hasNext,
    required this.onPrimaryAction,
    required this.onBackToMenu,
  });

  @override
  State<CodePuzzleResultScreen> createState() => _CodePuzzleResultScreenState();
}

class _CodePuzzleResultScreenState extends State<CodePuzzleResultScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.won) {
      AppSounds.instance.victory();
    } else {
      AppSounds.instance.failure();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.won ? _buildWon(context) : _buildLost(context);
  }

  Widget _buildWon(BuildContext context) {
    // Mesmo cálculo de tamanho derivado só da largura da tela de
    // `VictoryScreen` — nunca de "altura restante" — para nunca estourar em
    // nenhum celular/tablet (a tela toda rola se não couber).
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
                    StarRow(lit: widget.stars, size: 48),
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
                          Container(
                            width: ringSize,
                            height: ringSize,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.purple, width: 3)),
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
                        Expanded(child: StatCard(label: 'PONTOS', value: '${widget.points}')),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard(label: 'TENTATIVAS', value: '${widget.attempts}')),
                      ],
                    ),
                    if (widget.explanationText != null) ...[
                      const SizedBox(height: 14),
                      _explanationCard(widget.explanationText!),
                    ],
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

  Widget _buildLost(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final circleSize = math.min(screenWidth * 0.6, 260.0);
    final mascotSize = circleSize * 0.85;

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
                    Text('FASE ${widget.levelNumber} · TENTATIVA ${widget.attempts}', style: AppText.eyebrow(size: 13)),
                    const SizedBox(height: 6),
                    // Título deliberadamente não-punitivo (mesmo princípio
                    // de FailureScreen) — evita "errou"/"falhou".
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Quase lá!', style: AppText.style(size: 48, weight: FontWeight.w900, color: AppColors.white, height: 1)),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: circleSize,
                      height: circleSize,
                      child: Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.panel),
                        alignment: Alignment.center,
                        child: Transform.rotate(
                          angle: -0.1,
                          child: MascotImage(size: mascotSize, expression: MascotExpression.confused),
                        ),
                      ),
                    ),
                    if (widget.explanationText != null) ...[
                      const SizedBox(height: 18),
                      _explanationCard(widget.explanationText!),
                    ],
                    if (widget.correctOrderChips != null) ...[
                      const SizedBox(height: 18),
                      _hintCard(widget.correctOrderChips!),
                    ],
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

  /// Card "COMO FUNCIONA" — a explicação do bug, mostrada sempre (ganhou ou
  /// perdeu) em fases `findBug`.
  Widget _explanationCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMO FUNCIONA', style: AppText.eyebrow(size: 11)),
          const SizedBox(height: 8),
          Text(text, style: AppText.style(size: 15, weight: FontWeight.w800, color: AppColors.white, height: 1.4)),
        ],
      ),
    );
  }

  /// Card "DICA" — a ordem certa de um `reorder`, mostrada só quando o
  /// jogador errou. Mesmo texto/estilo do card de Dica de `FailureScreen`.
  Widget _hintCard(List<Widget> chips) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DICA', style: AppText.eyebrow(size: 11)),
          const SizedBox(height: 8),
          Text('Essa é a ordem certa:', style: AppText.style(size: 15, weight: FontWeight.w800, color: AppColors.white, height: 1.4)),
          const SizedBox(height: 8),
          // 2 colunas — mesmo motivo de `FailureScreen`: este card tem
          // padding próprio somado ao da tela, deixando pouca largura por
          // célula (ver `.claude/memory/decisions.md`).
          ProgramChipGrid(chips: chips, crossAxisCount: 2),
        ],
      ),
    );
  }
}
