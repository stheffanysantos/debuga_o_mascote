import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/onboarding/onboarding_notifier.dart';
import '../../../../models/code_line.dart';
import '../../../../models/game_track.dart';
import '../../../auth/presentation/register/register_view.dart';
import '../../../tutorial/presentation/tutorial_view.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/code_syntax_highlight.dart';
import '../../../../widgets/gameplay_header_widget.dart';
import '../../../../widgets/primary_pill_button_widget.dart';
import '../../../../widgets/selectable_line_tile_widget.dart';
import '../../../../widgets/tutorial_content.dart';
import '../../../result/presentation/code_puzzle_result_view.dart';
import '../stage_select/stage_select_view.dart';
import 'complete_code_gameplay_state.dart';
import 'complete_code_gameplay_view_model.dart';

/// Mesmo padrão dos outros mundos — ver `.claude/memory/decisions.md`.
void _returnToLevelSelect(BuildContext context, WidgetRef ref, {required int worldNumber, required bool worldJustCompleted}) {
  final isEndOfTrack1 = worldJustCompleted && worldNumber == tracks.first.worlds.last.number;
  if (isEndOfTrack1 && !ref.read(authServiceProvider).hasAccount) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterView(
        mandatory: true,
        onDone: () => Navigator.of(context).popUntil((route) => route.settings.name == completeCodeStageSelectRouteName),
      ),
    ));
    return;
  }
  Navigator.of(context).popUntil((route) => route.settings.name == completeCodeStageSelectRouteName);
}

void _onResultPrimaryAction(BuildContext context, WidgetRef ref, CompleteCodeResultData data) {
  if (data.nextLevel != null) {
    Navigator.of(context).popUntil((route) => route.settings.name == completeCodeStageSelectRouteName);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CompleteCodeGameplayView(levelId: data.nextLevel!.id)));
    return;
  }
  if (data.worldJustCompleted && !ref.read(onboardingNotifierProvider).hasSeenRecap(data.worldNumber)) {
    final recap = recapSlidesFor(data.worldNumber);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TutorialView(
        slides: recap.slides,
        narrationAssets: recap.narrationAssets,
        finalLabel: 'Concluir',
        onFinish: () {
          ref.read(onboardingNotifierProvider.notifier).markRecapSeen(data.worldNumber);
          _returnToLevelSelect(context, ref, worldNumber: data.worldNumber, worldJustCompleted: data.worldJustCompleted);
        },
      ),
    ));
    return;
  }
  _returnToLevelSelect(context, ref, worldNumber: data.worldNumber, worldJustCompleted: data.worldJustCompleted);
}

/// Gameplay do Mundo 4 ("Complete o Código") — mostra um trecho de código
/// real com uma linha em branco (`CompleteCodeLevel.blankLineIndex`) e o
/// jogador escolhe, por múltipla escolha, qual linha completa certo. A
/// linha escolhida "aparece" na prévia do código assim que tocada (antes de
/// confirmar), reforçando visualmente o que vai ser testado. Sem execução
/// passo a passo — cada "Confirmar" é um veredito único, mesma família de
/// `PredictOutputGameplayView` (Mundo 3) e `CodePuzzleGameplayView`
/// (Mundo 5). Ver `.claude/docs/GAME_DESIGN.md`.
class CompleteCodeGameplayView extends ConsumerWidget {
  final String levelId;

  const CompleteCodeGameplayView({super.key, required this.levelId});

  Future<void> _handleEffect(BuildContext context, WidgetRef ref, CompleteCodeGameplayEffect effect) async {
    final notifier = ref.read(completeCodeGameplayViewModelProvider(levelId).notifier);
    notifier.clearEffect();
    switch (effect) {
      case ShowCompleteCodeResult(:final data):
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CodePuzzleResultView(
            won: data.won,
            levelNumber: data.levelNumber,
            attempts: data.attempts,
            stars: data.stars,
            points: data.points,
            explanationText: data.explanationText,
            hasNext: data.nextLevel != null,
            onPrimaryAction: () => _onResultPrimaryAction(context, ref, data),
            onBackToMenu: () => Navigator.of(context).popUntil((route) => route.settings.name == completeCodeStageSelectRouteName),
            onReplaySameLevel: notifier.resetForReplay,
          ),
        ));
        if (!data.won) notifier.clearSelectionAfterLoss();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<CompleteCodeGameplayState>(completeCodeGameplayViewModelProvider(levelId), (previous, next) {
      final effect = next.pendingEffect;
      if (effect != null) _handleEffect(context, ref, effect);
    });

    final state = ref.watch(completeCodeGameplayViewModelProvider(levelId));
    final notifier = ref.read(completeCodeGameplayViewModelProvider(levelId).notifier);
    final level = state.level;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GameplayHeader(
                  levelNumber: level.number,
                  title: level.title,
                  trailingChipText: 'Tentativa ${state.attempts + 1}',
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 14),
                _buildCodeCard(state),
                const SizedBox(height: 14),
                Text(level.question, style: AppText.style(size: 17, weight: FontWeight.w900, color: AppColors.white)),
                const SizedBox(height: 10),
                Text('ESCOLHA A LINHA CERTA', style: AppText.eyebrow(size: 11)),
                const SizedBox(height: 8),
                for (var i = 0; i < level.options.length; i++) _buildOption(state, notifier, i),
                const SizedBox(height: 8),
                PrimaryPillButton(
                  label: 'Confirmar',
                  height: 64,
                  fontSize: 24,
                  enabled: state.selectedOptionIndex != null,
                  onTap: notifier.confirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeCard(CompleteCodeGameplayState state) {
    final level = state.level;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.grayButton, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('COMPLETE O CÓDIGO', style: AppText.eyebrow(size: 11)),
          const SizedBox(height: 10),
          for (var i = 0; i < level.code.length; i++) _buildCodeLine(state, i),
        ],
      ),
    );
  }

  /// A linha do espaço em branco nunca mostra `CodeLine.text` original antes
  /// de confirmar — mostra um placeholder tracejado, ou (assim que o
  /// jogador tocar uma opção) uma prévia com o texto da opção escolhida, em
  /// destaque roxo, pra deixar claro que ainda não foi confirmado.
  Widget _buildCodeLine(CompleteCodeGameplayState state, int index) {
    final level = state.level;
    if (index != level.blankLineIndex) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: RichText(text: TextSpan(children: highlightCodeLine(level.code[index].text))),
      );
    }

    if (state.selectedOptionIndex == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grayDashedBorder, width: 2),
        ),
        child: Text('?', style: AppText.style(size: 15, weight: FontWeight.w900, color: AppColors.grayLockIcon)),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.purple.withValues(alpha: 0.35),
      ),
      child: RichText(text: TextSpan(children: highlightCodeLine(level.options[state.selectedOptionIndex!].text))),
    );
  }

  Widget _buildOption(CompleteCodeGameplayState state, CompleteCodeGameplayViewModel notifier, int index) {
    final CodeLine option = state.level.options[index];
    return SelectableLineTile(
      key: Key('completeCodeOption_$index'),
      selected: state.selectedOptionIndex == index,
      onTap: () => notifier.selectOption(index),
      child: RichText(text: TextSpan(children: highlightCodeLine(option.text))),
    );
  }
}
