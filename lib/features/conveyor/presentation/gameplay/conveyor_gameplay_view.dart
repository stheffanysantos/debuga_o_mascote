import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/onboarding/onboarding_notifier.dart';
import '../../../../game/belt_executor.dart';
import '../../../../models/belt_block.dart';
import '../../../../models/belt_item.dart';
import '../../../../models/game_track.dart';
import '../../../auth/presentation/register/register_view.dart';
import '../../../tutorial/presentation/tutorial_view.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/belt_block_chip_style.dart';
import '../../../../widgets/command_button_grid_widget.dart';
import '../../../../widgets/command_button_widget.dart';
import '../../../../widgets/gameplay_header_widget.dart';
import '../../../../widgets/primary_pill_button_widget.dart';
import '../../../../widgets/program_block_chip_widget.dart';
import '../../../../widgets/program_chip_grid_widget.dart';
import '../../../../widgets/pulse_tap_widget.dart';
import '../../../../widgets/tutorial_content.dart';
import '../../../result/presentation/failure_view.dart';
import '../../../result/presentation/victory_view.dart';
import '../stage_select/stage_select_view.dart';
import 'conveyor_gameplay_state.dart';
import 'conveyor_gameplay_view_model.dart';

/// Texto real do motivo da falha a partir do `BeltOutcome` da Execução —
/// mesma ideia de `_reasonTextFor(GameOutcome)` em `gameplay_view.dart`
/// (Mundo 1), mas para o motor da Esteira. Ver `.claude/docs/GAME_DESIGN.md`.
String _reasonTextFor(BeltOutcome outcome) {
  switch (outcome) {
    case BeltOutcome.misclassified:
      return 'Um item foi separado na caixa errada.';
    case BeltOutcome.incomplete:
      return 'O programa terminou, mas ainda sobraram itens na esteira.';
    case BeltOutcome.win:
      // Não deveria navegar para a Falha numa vitória — mantido só por
      // exaustividade do switch.
      return '';
  }
}

/// Volta pra Seleção de Fases — a menos que o Mundo que acabou de fechar
/// agora seja o último da Trilha 1 e o jogador ainda não tenha conta, caso
/// em que empurra `RegisterView` primeiro (gate de fim de Trilha, ver
/// `.claude/memory/decisions.md`). Mesmo padrão de `gameplay_view.dart`.
void _returnToLevelSelect(BuildContext context, WidgetRef ref, {required int worldNumber, required bool worldJustCompleted}) {
  final isEndOfTrack1 = worldJustCompleted && worldNumber == tracks.first.worlds.last.number;
  if (isEndOfTrack1 && !ref.read(authServiceProvider).hasAccount) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterView(
        mandatory: true,
        onDone: () => Navigator.of(context).popUntil((route) => route.settings.name == conveyorLevelSelectRouteName),
      ),
    ));
    return;
  }
  Navigator.of(context).popUntil((route) => route.settings.name == conveyorLevelSelectRouteName);
}

/// Chamado pelo botão primário da `VictoryView` — decide entre jogar a
/// próxima fase direto, mostrar a recapitulação de fim de Mundo, ou voltar
/// direto pra Seleção de Fases (com o gate de cadastro embutido em
/// `_returnToLevelSelect`).
void _onVictoryPrimaryAction(BuildContext context, WidgetRef ref, ConveyorVictoryData data) {
  if (data.nextLevel != null) {
    Navigator.of(context).popUntil((route) => route.settings.name == conveyorLevelSelectRouteName);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConveyorGameplayView(levelId: data.nextLevel!.id)));
    return;
  }
  if (data.worldJustCompleted && !ref.read(onboardingNotifierProvider).hasSeenRecap(data.worldNumber)) {
    final recap = recapSlidesFor(data.worldNumber);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TutorialView(
        slides: recap.slides,
        narrationAssets: recap.narrationAssets,
        finalLabel: 'Continuar',
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

/// Gameplay do Mundo 2 (Esteira de Bugs) — mesmo papel de `GameplayView`
/// (Mundo 1), mas sem grid/mascote: o jogador classifica, um de cada vez,
/// os Itens de `level.itemQueue` mandando-os para a Caixa A/B certa. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Mundo 2 — Esteira".
///
/// `ConsumerStatefulWidget` (não `ConsumerWidget`) só para guardar o
/// `ScrollController`/`GlobalKey`s da fila — estado puramente de
/// apresentação (rolar a fila até o item atual), não de jogo: a lógica de
/// Execução continua inteira em `ConveyorGameplayViewModel`. Ver
/// `.claude/rules/architecture.md`.
class ConveyorGameplayView extends ConsumerStatefulWidget {
  final String levelId;

  const ConveyorGameplayView({super.key, required this.levelId});

  @override
  ConsumerState<ConveyorGameplayView> createState() => _ConveyorGameplayViewState();
}

class _ConveyorGameplayViewState extends ConsumerState<ConveyorGameplayView> {
  static const _scrollDuration = Duration(milliseconds: 320);

  /// Uma `GlobalKey` por Item da fila — usada com `Scrollable.ensureVisible`
  /// para rolar a fila horizontal até o item atual, em vez de calcular o
  /// offset manualmente a partir da largura do item/separador (mais
  /// robusto a qualquer ajuste futuro de layout). Testador: "Quando tem uma
  /// fila grande ele não rola sozinho pra a direita" — ver
  /// `.claude/memory/decisions.md`.
  final Map<int, GlobalKey> _itemKeys = {};

  GlobalKey _keyFor(int index) => _itemKeys.putIfAbsent(index, () => GlobalKey());

  void _scrollToItem(int index) {
    final itemContext = _itemKeys[index]?.currentContext;
    if (itemContext == null) return;
    Scrollable.ensureVisible(
      itemContext,
      duration: _scrollDuration,
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  void _handleEffect(BuildContext context, ConveyorGameplayEffect effect) {
    ref.read(conveyorGameplayViewModelProvider(widget.levelId).notifier).clearEffect();
    switch (effect) {
      case NavigateToConveyorVictory(:final data):
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => VictoryView(
            levelNumber: data.levelNumber,
            blocksUsed: data.blocksUsed,
            maxBlocks: data.maxBlocks,
            optimalBlocks: data.optimalBlocks,
            hasNext: data.nextLevel != null,
            onPrimaryAction: () => _onVictoryPrimaryAction(context, ref, data),
          ),
        ));
      case NavigateToConveyorFailure(:final data):
        final level = ref.read(conveyorGameplayViewModelProvider(widget.levelId)).level;
        final hintChips = [
          for (final block in level.hintProgram)
            Builder(builder: (context) {
              final style = styleForBeltBlock(block);
              return ProgramBlockChip(
                label: style.label,
                background: style.background,
                foreground: style.foreground,
                repeatCount: style.repeatCount,
              );
            }),
        ];
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FailureView(
            levelNumber: data.levelNumber,
            attempt: data.attempt,
            reasonText: _reasonTextFor(data.outcome),
            maxBlocks: data.maxBlocks,
            hintChips: hintChips,
            onBackToMenu: () => Navigator.of(context).popUntil((route) => route.settings.name == conveyorLevelSelectRouteName),
          ),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ConveyorGameplayState>(conveyorGameplayViewModelProvider(widget.levelId), (previous, next) {
      final effect = next.pendingEffect;
      if (effect != null) _handleEffect(context, effect);

      // Rola a fila para acompanhar o item atual durante a Execução — só
      // quando o índice realmente muda (evita chamadas redundantes a cada
      // rebuild) e só quando ainda há um item nessa posição (o índice pode
      // avançar além do fim da fila quando a Execução termina).
      final nextIndex = next.cursor.nextItemIndex;
      if (previous?.cursor.nextItemIndex != nextIndex && nextIndex < next.level.itemQueue.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToItem(nextIndex));
      }
    });

    final state = ref.watch(conveyorGameplayViewModelProvider(widget.levelId));
    final notifier = ref.read(conveyorGameplayViewModelProvider(widget.levelId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          // Layout sempre empilhado (celular e tablet) — diferente de
          // `GameplayView` (Mundo 1), que ganha um layout lado a lado em
          // tablet (ver `.claude/plans/Roadmap.md`); replicar isso aqui
          // ficou como item de bônus, não bloqueante para esta etapa.
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 10),
                _buildBelt(state),
                const SizedBox(height: 14),
                _buildProgramArea(state, notifier),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ConveyorGameplayState state) {
    return GameplayHeader(
      levelNumber: state.level.number,
      title: state.level.title,
      trailingChipText: '${state.program.length} / ${state.level.maxBlocks} blocos',
      onBack: () => Navigator.of(context).pop(),
    );
  }

  /// A "esteira": fila horizontal de Itens (o atual em destaque, pulsando —
  /// mesmo motivo visual do alvo pulsante do Mundo 1) sobre um painel com as
  /// duas Caixas de destino abaixo, para o jogador sempre ver pra onde cada
  /// cor deveria ir sem precisar de instrução prévia.
  Widget _buildBelt(ConveyorGameplayState state) {
    final level = state.level;
    return Container(
      key: const Key('conveyorBelt'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.grayButton, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FILA DE ITENS', style: AppText.eyebrow(size: 11)),
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: level.itemQueue.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) => KeyedSubtree(
                key: _keyFor(index),
                child: Center(child: _buildItemDot(state, index)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _buildBinCard(label: 'Caixa A', color: AppColors.yellowNeon, foreground: AppColors.purpleDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildBinCard(label: 'Caixa B', color: AppColors.purple, foreground: AppColors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDot(ConveyorGameplayState state, int index) {
    final level = state.level;
    final isYellow = level.itemQueue[index] == BeltItemColor.yellow;
    final color = isYellow ? AppColors.yellowNeon : AppColors.purple;
    final isCurrent = index == state.cursor.nextItemIndex;
    final isProcessed = index < state.cursor.nextItemIndex;

    final dot = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isCurrent ? Border.all(color: AppColors.white, width: 3) : null,
        boxShadow: isCurrent
            ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 0, spreadRadius: 5)]
            : const [],
      ),
    );

    final content = Opacity(opacity: isProcessed ? 0.3 : 1.0, child: dot);
    return isCurrent ? PulseTap(child: content) : content;
  }

  Widget _buildBinCard({required String label, required Color color, required Color foreground}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      alignment: Alignment.center,
      child: Text(label, style: AppText.style(size: 14, weight: FontWeight.w900, color: foreground)),
    );
  }

  Widget _buildProgramArea(ConveyorGameplayState state, ConveyorGameplayViewModel notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SEU PROGRAMA', style: AppText.eyebrow(size: 11)),
            TextButton(
              onPressed: state.running ? null : notifier.clearProgram,
              child: Text('LIMPAR', style: AppText.eyebrow(size: 11)),
            ),
          ],
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.grayDashedBorder, width: 3),
          ),
          child: state.program.isEmpty
              ? Center(
                  child: Text(
                    'Toque nos blocos abaixo para montar',
                    style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.grayLockIcon),
                  ),
                )
              : ProgramChipGrid(
                  chips: [
                    for (var i = 0; i < state.program.length; i++)
                      _blockChip(state, notifier, i),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        // 5 comandos no Mundo 2 (contra 4 no labirinto) — mesma grade
        // compacta de `CommandButtonGrid` do Mundo 1. "Enquanto" continua
        // diferenciado de "Se" pelo `border` (ver `whileIcon`/
        // `.claude/docs/GAME_DESIGN.md`).
        CommandButtonGrid(
          crossAxisCount: 3,
          maxCellHeight: 100,
          buttons: [
            CommandButton(
              iconBuilder: (size) => conditionIcon(size, foreground: AppColors.purpleDark),
              label: 'Se Amarelo → A',
              background: AppColors.yellowNeon,
              foreground: AppColors.purpleDark,
              shadowColor: AppColors.yellowShadow,
              onTap: () => notifier.addBlock(BeltBlockType.ifYellowToBinA),
            ),
            CommandButton(
              iconBuilder: (size) => conditionIcon(size, foreground: AppColors.white),
              label: 'Se Roxo → B',
              background: AppColors.purple,
              foreground: AppColors.white,
              shadowColor: AppColors.purpleShadow,
              onTap: () => notifier.addBlock(BeltBlockType.ifPurpleToBinB),
            ),
            CommandButton(
              iconBuilder: (size) => whileIcon(size, foreground: AppColors.purpleDark),
              label: 'Enquanto Amarelo → A',
              background: AppColors.yellowNeon,
              foreground: AppColors.purpleDark,
              shadowColor: AppColors.yellowShadow,
              border: Border.all(color: AppColors.purpleDark, width: 3),
              onTap: () => notifier.addBlock(BeltBlockType.whileYellowToBinA),
            ),
            CommandButton(
              iconBuilder: (size) => whileIcon(size, foreground: AppColors.white),
              label: 'Enquanto Roxo → B',
              background: AppColors.purple,
              foreground: AppColors.white,
              shadowColor: AppColors.purpleShadow,
              border: Border.all(color: AppColors.white, width: 3),
              onTap: () => notifier.addBlock(BeltBlockType.whilePurpleToBinB),
            ),
            CommandButton(
              iconBuilder: (size) => AppIcons.repeat(size: size, color: AppColors.purpleDark),
              label: 'Repetir 3×',
              background: AppColors.lilac,
              foreground: AppColors.purpleDark,
              shadowColor: AppColors.lilacShadow,
              onTap: () => notifier.addBlock(BeltBlockType.repeat),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PrimaryPillButton(
          label: state.running ? 'Executando…' : 'PLAY',
          height: 64,
          fontSize: 24,
          enabled: !state.running,
          icon: AppIcons.play(size: 26, color: AppColors.purpleDark),
          onTap: notifier.run,
        ),
      ],
    );
  }

  Widget _blockChip(ConveyorGameplayState state, ConveyorGameplayViewModel notifier, int index) {
    final style = styleForBeltBlock(state.program[index]);
    return ProgramBlockChip(
      label: style.label,
      background: style.background,
      foreground: style.foreground,
      repeatCount: style.repeatCount,
      highlighted: state.currentStepBlockIndex == index,
      onTap: () => notifier.removeBlockAt(index),
      // "Seu Programa" mostra só o ícone (rótulo continua nos
      // `CommandButton`s da paleta acima) — pedido explícito do usuário,
      // ver `.claude/memory/decisions.md`.
      icon: style.icon(programBlockChipIconSize),
      showLabel: false,
      // "Enquanto" precisa continuar diferenciado de "Se" mesmo sem o
      // texto (achado do UX Reviewer) — mesmo contorno do `CommandButton`.
      border: style.border,
    );
  }
}
