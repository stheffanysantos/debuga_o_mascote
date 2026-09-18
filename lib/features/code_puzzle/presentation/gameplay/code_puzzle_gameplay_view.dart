import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/onboarding/onboarding_notifier.dart';
import '../../../../models/code_line.dart';
import '../../../../models/code_puzzle_level.dart';
import '../../../../models/game_track.dart';
import '../../../auth/presentation/register/register_view.dart';
import '../../../tutorial/presentation/tutorial_view.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/code_syntax_highlight.dart';
import '../../../../widgets/gameplay_header_widget.dart';
import '../../../../widgets/primary_pill_button_widget.dart';
import '../../../../widgets/program_block_chip_widget.dart';
import '../../../../widgets/selectable_line_tile_widget.dart';
import '../../../../widgets/tutorial_content.dart';
import '../../../result/presentation/code_puzzle_result_view.dart';
import '../stage_select/stage_select_view.dart';
import 'code_puzzle_gameplay_state.dart';
import 'code_puzzle_gameplay_view_model.dart';

/// Volta pra Seleção de Fases — a menos que o Mundo que acabou de fechar
/// agora seja o último da Trilha 1 e o jogador ainda não tenha conta, caso
/// em que empurra `RegisterView` primeiro (gate de fim de Trilha, ver
/// `.claude/memory/decisions.md`). Hoje é o único dos 5 Gameplay onde esse
/// gate realmente entra em jogo (Mundo 5 é o último da Trilha 1). Sempre tem
/// uma saída ("Continuar sem conta por enquanto") — nunca trava o app se o
/// Firebase estiver indisponível.
void _returnToLevelSelect(BuildContext context, WidgetRef ref, {required int worldNumber, required bool worldJustCompleted}) {
  final isEndOfTrack1 = worldJustCompleted && worldNumber == tracks.first.worlds.last.number;
  if (isEndOfTrack1 && !ref.read(authServiceProvider).hasAccount) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterView(
        mandatory: true,
        onDone: () => Navigator.of(context).popUntil((route) => route.settings.name == codePuzzleStageSelectRouteName),
      ),
    ));
    return;
  }
  Navigator.of(context).popUntil((route) => route.settings.name == codePuzzleStageSelectRouteName);
}

void _onResultPrimaryAction(BuildContext context, WidgetRef ref, CodePuzzleGameplayResultData data) {
  if (data.nextLevel != null) {
    // Volta à mesma instância da Seleção de Fases do Mundo 5 já na pilha
    // (em vez de criar outra) e joga a próxima fase direto na sequência.
    Navigator.of(context).popUntil((route) => route.settings.name == codePuzzleStageSelectRouteName);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CodePuzzleGameplayView(levelId: data.nextLevel!.id)));
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

/// Gameplay do Mundo 5 ("Modo Debug") — alterna o conteúdo central pelo
/// `CodePuzzleType` da fase: `reorder` (montar a sequência certa tocando
/// linhas embaralhadas, mesmo padrão de tap-para-montar dos outros mundos)
/// ou `findBug` (tocar a linha com o erro). Sem execução passo a passo —
/// cada "Confirmar" é um veredito único, ver
/// `lib/game/code_puzzle_checker.dart`.
class CodePuzzleGameplayView extends ConsumerWidget {
  final String levelId;

  const CodePuzzleGameplayView({super.key, required this.levelId});

  Future<void> _handleEffect(BuildContext context, WidgetRef ref, CodePuzzleGameplayEffect effect) async {
    final notifier = ref.read(codePuzzleGameplayViewModelProvider(levelId).notifier);
    notifier.clearEffect();
    switch (effect) {
      case ShowCodePuzzleGameplayResult(:final data):
        final correctOrderChips = data.correctOrder == null
            ? null
            : [
                for (final line in data.correctOrder!)
                  ProgramBlockChip(label: line.text, background: AppColors.lilac, foreground: AppColors.purpleDark),
              ];
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CodePuzzleResultView(
            won: data.won,
            levelNumber: data.levelNumber,
            attempts: data.attempts,
            stars: data.stars,
            points: data.points,
            explanationText: data.explanationText,
            correctOrderChips: correctOrderChips,
            hasNext: data.nextLevel != null,
            onPrimaryAction: () => _onResultPrimaryAction(context, ref, data),
            onBackToMenu: () => Navigator.of(context).popUntil((route) => route.settings.name == codePuzzleStageSelectRouteName),
            onReplaySameLevel: notifier.resetForReplay,
          ),
        ));
        // "Tentar de novo" (derrota) só faz `pop()` — volta pra esta mesma
        // instância. Sem isso, a linha/sequência da tentativa errada
        // continuava montada (achado do UX Reviewer). Não limpa em caso de
        // vitória — a tela nem volta pra cá nesse caso.
        if (!data.won) notifier.clearSelectionAfterLoss();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<CodePuzzleGameplayState>(codePuzzleGameplayViewModelProvider(levelId), (previous, next) {
      final effect = next.pendingEffect;
      if (effect != null) _handleEffect(context, ref, effect);
    });

    final state = ref.watch(codePuzzleGameplayViewModelProvider(levelId));
    final notifier = ref.read(codePuzzleGameplayViewModelProvider(levelId).notifier);
    final level = state.level;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          // Layout sempre empilhado (celular e tablet) — mesmo bônus não
          // aplicado do Mundo 2 (ver `.claude/plans/Roadmap.md`).
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
                _buildContent(state, notifier),
                const SizedBox(height: 14),
                PrimaryPillButton(
                  label: 'Confirmar',
                  height: 64,
                  fontSize: 24,
                  enabled: notifier.canConfirm,
                  onTap: notifier.confirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(CodePuzzleGameplayState state, CodePuzzleGameplayViewModel notifier) {
    switch (state.level.type) {
      case CodePuzzleType.reorder:
        return _buildReorderContent(state, notifier);
      case CodePuzzleType.findBug:
        return _buildFindBugContent(state, notifier);
    }
  }

  Widget _buildReorderContent(CodePuzzleGameplayState state, CodePuzzleGameplayViewModel notifier) {
    final shuffledLines = notifier.shuffledLines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('SUA SEQUÊNCIA', style: AppText.eyebrow(size: 11)),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.grayDashedBorder, width: 3),
          ),
          child: state.sequenceIndices.isEmpty
              ? Center(
                  child: Text(
                    'Toque nas linhas abaixo para montar',
                    style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.grayLockIcon),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final i in state.sequenceIndices)
                      ProgramBlockChip(
                        label: shuffledLines[i].text,
                        background: AppColors.purple,
                        foreground: AppColors.white,
                        onTap: () => notifier.removeFromSequence(i),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        Text('LINHAS DISPONÍVEIS', style: AppText.eyebrow(size: 11)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < shuffledLines.length; i++)
              if (!state.sequenceIndices.contains(i))
                ProgramBlockChip(
                  label: shuffledLines[i].text,
                  background: AppColors.lilac,
                  foreground: AppColors.purpleDark,
                  onTap: () => notifier.addToSequence(i),
                ),
          ],
        ),
      ],
    );
  }

  Widget _buildFindBugContent(CodePuzzleGameplayState state, CodePuzzleGameplayViewModel notifier) {
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
          Text('TOQUE NA LINHA COM O ERRO', style: AppText.eyebrow(size: 11)),
          const SizedBox(height: 10),
          for (var i = 0; i < level.codeWithBug.length; i++) _buildFindBugLine(state, notifier, i, level.codeWithBug[i]),
        ],
      ),
    );
  }

  Widget _buildFindBugLine(CodePuzzleGameplayState state, CodePuzzleGameplayViewModel notifier, int index, CodeLine line) {
    return SelectableLineTile(
      // `key` só para os testes de tela conseguirem tocar uma linha
      // específica — o texto em si é um `RichText`/`TextSpan` (destaque de
      // sintaxe), que `find.text` não localiza.
      key: Key('codePuzzleLine_$index'),
      selected: state.selectedLineIndex == index,
      onTap: () => notifier.selectLine(index),
      child: RichText(text: TextSpan(children: highlightCodeLine(line.text))),
    );
  }
}
