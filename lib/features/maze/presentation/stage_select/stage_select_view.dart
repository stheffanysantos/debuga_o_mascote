import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/onboarding/onboarding_notifier.dart';
import '../../../../core/progress/progress_notifier.dart';
import '../../../../models/level.dart';
import '../../../tutorial/presentation/tutorial_view.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/dotted_background_widget.dart';
import '../../../../widgets/icon_action_button_widget.dart';
import '../../../../widgets/stage_select_grid_widget.dart';
import '../../../../widgets/tutorial_content.dart';
import '../gameplay/gameplay_view.dart';

/// Nome de rota usado para voltar direto a esta tela via `popUntil`, sem
/// recriar uma instância nova (ver `VictoryView`/`FailureView`).
const levelSelectRouteName = 'level-select';

/// Seleção de Fases do motor de labirinto (Mundo 1). O Mundo 2 (Esteira) tem
/// sua própria tela equivalente, `ConveyorStageSelectScreen`
/// (`lib/screens/conveyor_stage_select_screen.dart`) — ver
/// `.claude/models/level.dart`. Sem lógica de orquestração própria (só lê
/// `progressNotifierProvider` e monta a grade) — `ConsumerWidget`, sem
/// ViewModel/State dedicados, ver a tabela de convenções do plano de
/// migração (seção 6).
class StageSelectView extends ConsumerWidget {
  final GameWorld world;

  const StageSelectView({super.key, required this.world});

  // `GameWorld.levels` é `List<GameLevel>` (genérico entre motores, ver
  // `lib/models/game_level.dart`) — esta tela é específica do motor de
  // labirinto (Mundo 1), então converte de volta para `List<Level>` aqui.
  List<Level> get _levels => world.levels.cast<Level>();

  List<StageTileData> _stages(WidgetRef ref) {
    final progress = ref.watch(progressNotifierProvider);
    var currentAssigned = false;
    return _levels.map((level) {
      if (progress.isCompleted(level.id)) {
        return StageTileData(number: level.number, status: StageStatus.done, stars: progress.starsFor(level.id));
      }
      if (!currentAssigned) {
        currentAssigned = true;
        return StageTileData(number: level.number, status: StageStatus.current);
      }
      return StageTileData(number: level.number, status: StageStatus.locked);
    }).toList();
  }

  void _openLevelAt(BuildContext context, int index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameplayView(levelId: _levels[index].id)));
  }

  /// Reabre a `TutorialView` deste mundo — botão "?" do cabeçalho. Já
  /// estamos na Seleção de Fases certa, então nunca inclui os slides gerais
  /// de "o que é programar" (só relevantes na 1ª vez, ver `_enterWorld` em
  /// `world_select_screen.dart`) e `onFinish` só marca visto (idem se já
  /// estava) e fecha a tela, sem navegar de novo.
  void _openTutorial(BuildContext context, WidgetRef ref) {
    if (worldTutorials[world.number] == null) return;
    final content = tutorialSlidesFor(world.number);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TutorialView(
        slides: content.slides,
        narrationAssets: content.narrationAssets,
        onFinish: () {
          ref.read(onboardingNotifierProvider.notifier).markSeen(world.number);
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalStars = ref.watch(progressNotifierProvider).totalStars(_levels.map((l) => l.id));
    final maxStars = _levels.length * 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const DottedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconActionButton(
                            background: AppColors.grayButton,
                            shadowColor: Colors.transparent,
                            icon: AppIcons.chevronLeft(size: 22, color: AppColors.white),
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          // Espaço maior (não 10) + cor de fundo diferente
                          // (roxo, não cinza) do botão voltar — achado do UX
                          // Reviewer: os 2 botões ficavam colados e idênticos
                          // em cor, com risco real de toque errado num
                          // estande (ver .claude/memory/decisions.md).
                          const SizedBox(width: 20),
                          IconActionButton(
                            background: AppColors.purple,
                            shadowColor: AppColors.purpleShadow,
                            icon: AppIcons.help(size: 22, color: AppColors.white),
                            onTap: () => _openTutorial(context, ref),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                          decoration: BoxDecoration(color: AppColors.purpleDark, borderRadius: BorderRadius.circular(999)),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppIcons.star(size: 22, color: AppColors.yellowNeon),
                                const SizedBox(width: 8),
                                Text('$totalStars / $maxStars', style: AppText.style(size: 18, weight: FontWeight.w900, color: AppColors.yellowNeon)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text('MUNDO ${world.number}', style: AppText.eyebrow(size: 13)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(world.name, style: AppText.style(size: 34, weight: FontWeight.w900, color: AppColors.white, height: 1.05)),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StageSelectGrid(stages: _stages(ref), onTap: (index) => _openLevelAt(context, index)),
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
