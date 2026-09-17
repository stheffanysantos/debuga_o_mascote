import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/onboarding/onboarding_notifier.dart';
import '../../../../models/game_track.dart';
import '../../../../models/predict_output_level.dart';
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
import 'predict_output_gameplay_state.dart';
import 'predict_output_gameplay_view_model.dart';

/// Volta pra Seleção de Fases — a menos que o Mundo que acabou de fechar
/// agora seja o último da Trilha 1 e o jogador ainda não tenha conta, caso
/// em que empurra `RegisterView` primeiro (gate de fim de Trilha, ver
/// `.claude/memory/decisions.md`). Mesmo padrão dos outros mundos.
void _returnToLevelSelect(BuildContext context, WidgetRef ref, {required int worldNumber, required bool worldJustCompleted}) {
  final isEndOfTrack1 = worldJustCompleted && worldNumber == tracks.first.worlds.last.number;
  if (isEndOfTrack1 && !ref.read(authServiceProvider).hasAccount) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterView(
        mandatory: true,
        onDone: () => Navigator.of(context).popUntil((route) => route.settings.name == predictOutputStageSelectRouteName),
      ),
    ));
    return;
  }
  Navigator.of(context).popUntil((route) => route.settings.name == predictOutputStageSelectRouteName);
}

/// Chamado pelo botão primário da `CodePuzzleResultView` numa vitória —
/// decide entre jogar a próxima fase direto, mostrar a recapitulação de fim
/// de Mundo, ou voltar direto pra Seleção de Fases.
void _onResultPrimaryAction(BuildContext context, WidgetRef ref, PredictOutputResultData data) {
  if (data.nextLevel != null) {
    Navigator.of(context).popUntil((route) => route.settings.name == predictOutputStageSelectRouteName);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PredictOutputGameplayView(levelId: data.nextLevel!.id)));
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

/// Gameplay do Mundo 3 ("Preveja a Saída") — mostra um trecho de código real
/// (só leitura, já na ordem certa) e uma pergunta de múltipla escolha sobre
/// o resultado. Sem execução passo a passo, sem embaralhar/editar nada —
/// cada "Confirmar" é um veredito único, mesma família de
/// `CodePuzzleGameplayView` (Mundo 5) e `CompleteCodeGameplayView` (Mundo 4).
/// Ver `.claude/docs/GAME_DESIGN.md`.
class PredictOutputGameplayView extends ConsumerWidget {
  final String levelId;

  const PredictOutputGameplayView({super.key, required this.levelId});

  Future<void> _handleEffect(BuildContext context, WidgetRef ref, PredictOutputGameplayEffect effect) async {
    final notifier = ref.read(predictOutputGameplayViewModelProvider(levelId).notifier);
    notifier.clearEffect();
    switch (effect) {
      case ShowPredictOutputResult(:final data):
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
            onBackToMenu: () => Navigator.of(context).popUntil((route) => route.settings.name == predictOutputStageSelectRouteName),
          ),
        ));
        // "Tentar de novo" (derrota) só faz `pop()` — mesmo cuidado dos
        // Mundos 4/5 (achado do UX Reviewer): sem limpar a seleção, o
        // jogador podia apertar Confirmar de novo sem perceber que
        // precisava mudar a resposta.
        if (!data.won) notifier.clearSelectionAfterLoss();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PredictOutputGameplayState>(predictOutputGameplayViewModelProvider(levelId), (previous, next) {
      final effect = next.pendingEffect;
      if (effect != null) _handleEffect(context, ref, effect);
    });

    final state = ref.watch(predictOutputGameplayViewModelProvider(levelId));
    final notifier = ref.read(predictOutputGameplayViewModelProvider(levelId).notifier);
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
                _buildCodeCard(level),
                const SizedBox(height: 14),
                Text(level.question, style: AppText.style(size: 17, weight: FontWeight.w900, color: AppColors.white)),
                const SizedBox(height: 10),
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

  Widget _buildCodeCard(PredictOutputLevel level) {
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
          Text('LEIA O CÓDIGO', style: AppText.eyebrow(size: 11)),
          const SizedBox(height: 10),
          for (final line in level.code)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: RichText(text: TextSpan(children: highlightCodeLine(line.text))),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(PredictOutputGameplayState state, PredictOutputGameplayViewModel notifier, int index) {
    return SelectableLineTile(
      key: Key('predictOption_$index'),
      selected: state.selectedOptionIndex == index,
      onTap: () => notifier.selectOption(index),
      label: '${String.fromCharCode(97 + index)})',
      child: Text(
        state.level.options[index],
        style: AppText.style(size: 16, weight: FontWeight.w800, color: AppColors.white),
      ),
    );
  }
}
