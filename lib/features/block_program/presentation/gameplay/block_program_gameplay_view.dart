import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/onboarding/onboarding_notifier.dart';
import '../../../../game/block_program_executor.dart';
import '../../../../models/block_program_block.dart';
import '../../../../models/block_program_level.dart';
import '../../../../models/game_track.dart';
import '../../../auth/presentation/register/register_view.dart';
import '../../../tutorial/presentation/tutorial_view.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/block_program_chip_style.dart';
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
import 'block_program_gameplay_state.dart';
import 'block_program_gameplay_view_model.dart';

/// Texto real do motivo da falha a partir do `BlockProgramFailureData` da
/// Execução — mesma ideia de `_reasonTextFor(BeltOutcome)` em
/// `conveyor_gameplay_view.dart` (Mundo 2), mas para o motor de
/// "Programação em Blocos". Mostra o Total/Contador real alcançado contra o
/// alvo da fase (`finalValue`/`targetValue`) em vez de um texto genérico —
/// achado do UX Reviewer: sem os números, o jogador só descobria o próprio
/// erro reabrindo a fase.
String _reasonTextFor(BlockProgramFailureData data) {
  switch (data.outcome) {
    case BlockProgramOutcome.wrongResult:
      final goalLabel = data.goal == BlockProgramGoal.total ? 'Total' : 'Contador';
      return 'Seu $goalLabel foi ${data.finalValue}, mas a fase pedia ${data.targetValue}.';
    case BlockProgramOutcome.win:
      // Não deveria navegar para a Falha numa vitória — mantido só por
      // exaustividade do switch.
      return '';
  }
}

/// Volta pra Seleção de Fases — a menos que o Mundo que acabou de fechar
/// agora seja o último da Trilha 1 e o jogador ainda não tenha conta, caso
/// em que empurra `RegisterView` primeiro (gate de fim de Trilha, ver
/// `.claude/memory/decisions.md`). Mesmo padrão de `conveyor_gameplay_view.dart`.
void _returnToLevelSelect(BuildContext context, WidgetRef ref, {required int worldNumber, required bool worldJustCompleted}) {
  final isEndOfTrack1 = worldJustCompleted && worldNumber == tracks.first.worlds.last.number;
  if (isEndOfTrack1 && !ref.read(authServiceProvider).hasAccount) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterView(
        mandatory: true,
        onDone: () => Navigator.of(context).popUntil((route) => route.settings.name == blockProgramLevelSelectRouteName),
      ),
    ));
    return;
  }
  Navigator.of(context).popUntil((route) => route.settings.name == blockProgramLevelSelectRouteName);
}

/// Chamado pelo botão primário da `VictoryView` — decide entre jogar a
/// próxima fase direto, mostrar a recapitulação de fim de Mundo, ou voltar
/// direto pra Seleção de Fases (com o gate de cadastro embutido em
/// `_returnToLevelSelect`).
void _onVictoryPrimaryAction(BuildContext context, WidgetRef ref, BlockProgramVictoryData data) {
  if (data.nextLevel != null) {
    Navigator.of(context).popUntil((route) => route.settings.name == blockProgramLevelSelectRouteName);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlockProgramGameplayView(levelId: data.nextLevel!.id)));
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

/// Gameplay do Mundo 4 ("Decisões em Bloco") — o jogador monta um Programa
/// de `BlockProgramBlock`s que processa a lista de números da fase
/// (`level.numbers`) e produz um Total/Contador comparado ao alvo. O mundo
/// irmão original desta mecânica ("Oficina de Blocos", sem condicionais)
/// saiu do jogo — ver `.claude/memory/decisions.md`, entrada de
/// 2026-09-18 — mas a paleta de comandos continua derivada de
/// `state.level.world` (`availableBlockTypesForWorld`) por segurança. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Programação em Blocos".
///
/// **Esmaecimento progressivo (2026-09-18):** o painel "TRADUTOR DE
/// BLOCOS" separado saiu de cena — cada chip de "Seu Programa" mostra
/// agora a própria linha de código Dart real (`codeLineFor`), não mais um
/// ícone (ver `_blockChip`). Fases com `BlockProgramLevel.prefilledCount >
/// 0` já começam com um prefixo do Programa pronto/travado (ver
/// `BlockProgramGameplayViewModel.build`) — esses chips mostram a mesma
/// linha de código, só com opacidade reduzida e um selo de cadeado,
/// comunicando "isto já está pronto, você não toca aqui" sem parecer
/// quebrado. Ver `.claude/memory/decisions.md`.
///
/// `ConsumerStatefulWidget` (não `ConsumerWidget`) só para guardar o
/// `GlobalKey`s da fila de números — estado puramente de apresentação
/// (rolar a fila até o número atual), não de jogo: a lógica de Execução
/// continua inteira em `BlockProgramGameplayViewModel`. Ver
/// `.claude/rules/architecture.md`.
class BlockProgramGameplayView extends ConsumerStatefulWidget {
  final String levelId;

  const BlockProgramGameplayView({super.key, required this.levelId});

  @override
  ConsumerState<BlockProgramGameplayView> createState() => _BlockProgramGameplayViewState();
}

class _BlockProgramGameplayViewState extends ConsumerState<BlockProgramGameplayView> {
  static const _scrollDuration = Duration(milliseconds: 320);

  /// Uma `GlobalKey` por número da lista — usada com `Scrollable.ensureVisible`
  /// para rolar a fila horizontal até o número atual, mesma técnica de
  /// `ConveyorGameplayView` (ver `.claude/memory/decisions.md`).
  final Map<int, GlobalKey> _numberKeys = {};

  GlobalKey _keyFor(int index) => _numberKeys.putIfAbsent(index, () => GlobalKey());

  void _scrollToNumber(int index) {
    final itemContext = _numberKeys[index]?.currentContext;
    if (itemContext == null) return;
    Scrollable.ensureVisible(
      itemContext,
      duration: _scrollDuration,
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  void _handleEffect(BuildContext context, BlockProgramGameplayEffect effect) {
    ref.read(blockProgramGameplayViewModelProvider(widget.levelId).notifier).clearEffect();
    switch (effect) {
      case NavigateToBlockProgramVictory(:final data):
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
      case NavigateToBlockProgramFailure(:final data):
        final level = ref.read(blockProgramGameplayViewModelProvider(widget.levelId)).level;
        final hintChips = [
          for (final block in level.hintProgram)
            Builder(builder: (context) {
              final style = styleForBlockProgramBlock(block.type);
              return ProgramBlockChip(
                label: style.label,
                background: style.background,
                foreground: style.foreground,
                badgeText: style.badgeText,
                border: style.border,
              );
            }),
        ];
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FailureView(
            levelNumber: data.levelNumber,
            attempt: data.attempt,
            reasonText: _reasonTextFor(data),
            maxBlocks: data.maxBlocks,
            hintChips: hintChips,
            onBackToMenu: () => Navigator.of(context).popUntil((route) => route.settings.name == blockProgramLevelSelectRouteName),
          ),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BlockProgramGameplayState>(blockProgramGameplayViewModelProvider(widget.levelId), (previous, next) {
      final effect = next.pendingEffect;
      if (effect != null) _handleEffect(context, effect);

      // Rola a fila para acompanhar o número atual durante a Execução — só
      // quando o índice realmente muda, e só quando ainda há um número
      // nessa posição (o índice pode avançar além do fim da lista quando a
      // Execução termina).
      final nextIndex = next.cursor.nextNumberIndex;
      if (previous?.cursor.nextNumberIndex != nextIndex && nextIndex < next.level.numbers.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNumber(nextIndex));
      }
    });

    final state = ref.watch(blockProgramGameplayViewModelProvider(widget.levelId));
    final notifier = ref.read(blockProgramGameplayViewModelProvider(widget.levelId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          // Layout sempre empilhado (celular e tablet) — mesmo corte
          // não-bloqueante já feito nos Mundos 2/5/6/7 (ver
          // `.claude/plans/Roadmap.md`).
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 10),
                _buildProblem(state),
                const SizedBox(height: 10),
                _buildNumbers(state),
                const SizedBox(height: 14),
                _buildProgramArea(state, notifier),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BlockProgramGameplayState state) {
    return GameplayHeader(
      levelNumber: state.level.number,
      title: state.level.title,
      trailingChipText: '${state.program.length} / ${state.level.maxBlocks} blocos',
      onBack: () => Navigator.of(context).pop(),
    );
  }

  /// O probleminha em português da fase (ex.: "Some todos os números da
  /// lista.") — sempre visível, o jogador nunca precisa adivinhar o
  /// objetivo. Ver `.claude/docs/GAME_DESIGN.md`.
  Widget _buildProblem(BlockProgramGameplayState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PROBLEMA', style: AppText.eyebrow(size: 11)),
          const SizedBox(height: 6),
          Text(state.level.problem, style: AppText.style(size: 15, weight: FontWeight.w800, color: AppColors.white, height: 1.3)),
        ],
      ),
    );
  }

  /// A lista de números: fila horizontal de "fichas" (o número atual em
  /// destaque, pulsando — mesmo motivo visual do Item atual da Esteira) +
  /// os valores de Total/Contador e Alvo, para o jogador sempre ver o
  /// progresso sem precisar guardar de cabeça.
  Widget _buildNumbers(BlockProgramGameplayState state) {
    final level = state.level;
    final isTotalGoal = level.goal == BlockProgramGoal.total;
    final currentValue = isTotalGoal ? state.cursor.total : state.cursor.count;
    return Container(
      key: const Key('blockProgramNumbers'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LISTA DE NÚMEROS', style: AppText.eyebrow(size: 11)),
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: level.numbers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) => KeyedSubtree(
                key: _keyFor(index),
                child: Center(child: _buildNumberChip(state, index)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _buildValueCard(label: isTotalGoal ? 'TOTAL' : 'CONTADOR', value: '$currentValue')),
              const SizedBox(width: 12),
              Expanded(child: _buildValueCard(label: 'ALVO', value: '${level.targetValue}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberChip(BlockProgramGameplayState state, int index) {
    final level = state.level;
    final isCurrent = index == state.cursor.nextNumberIndex;
    final isProcessed = index < state.cursor.nextNumberIndex;

    final chip = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.lilac,
        shape: BoxShape.circle,
        border: isCurrent ? Border.all(color: AppColors.white, width: 3) : null,
        boxShadow: isCurrent
            ? [BoxShadow(color: AppColors.lilac.withValues(alpha: 0.35), blurRadius: 0, spreadRadius: 5)]
            : const [],
      ),
      alignment: Alignment.center,
      child: Text('${level.numbers[index]}', style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.purpleDark)),
    );

    final content = Opacity(opacity: isProcessed ? 0.3 : 1.0, child: chip);
    return isCurrent ? PulseTap(child: content) : content;
  }

  Widget _buildValueCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: AppColors.purpleDark, borderRadius: BorderRadius.circular(14)),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppText.eyebrow(size: 10)),
          const SizedBox(height: 2),
          Text(value, style: AppText.style(size: 20, weight: FontWeight.w900, color: AppColors.yellowNeon)),
        ],
      ),
    );
  }

  Widget _buildProgramArea(BlockProgramGameplayState state, BlockProgramGameplayViewModel notifier) {
    // 5 comandos no Mundo 4 ("Decisões em Bloco", único mundo deste motor
    // hoje) — derivado de `state.level.world`, ver
    // `availableBlockTypesForWorld`.
    final availableTypes = availableBlockTypesForWorld(state.level.world);
    // Única fonte da regra de pareamento "Para cada número" + bloco-alvo —
    // a mesma função que `BlockProgramExecutor.expand` usa para interpretar
    // o Programa de verdade (achado do Code Reviewer: nunca duplicar essa
    // regra, ver `.claude/memory/decisions.md`). Resolvido uma única vez
    // aqui e repassado para cada chip decidir `numeros[i]` vs.
    // `proximoNumero` (`_blockChip`).
    final entryByBlockIndex = <int, BlockProgramProgramEntry>{
      for (final entry in resolveBlockProgramEntries(state.program)) entry.blockIndex: entry,
    };
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
              // `crossAxisCount: 1` (não o padrão 4) — os chips agora
              // mostram linhas de código real (`_blockChip`), que ficam
              // ilegíveis espremidas em colunas estreitas; uma linha por
              // chip lê como um mini-editor de código de verdade, reforço
              // visual do "esmaecimento progressivo" rumo à Trilha 3.
              : ProgramChipGrid(
                  crossAxisCount: 1,
                  chips: [
                    for (var i = 0; i < state.program.length; i++) _blockChip(state, notifier, i, entryByBlockIndex),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        CommandButtonGrid(
          crossAxisCount: 3,
          maxCellHeight: 100,
          buttons: [for (final type in availableTypes) _commandButtonFor(type, notifier)],
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

  CommandButton _commandButtonFor(BlockProgramBlockType type, BlockProgramGameplayViewModel notifier) {
    final style = styleForBlockProgramBlock(type);
    return CommandButton(
      iconBuilder: style.icon,
      label: style.label,
      background: style.background,
      foreground: style.foreground,
      shadowColor: style.shadowColor,
      border: style.border,
      onTap: () => notifier.addBlock(type),
    );
  }

  /// Chip de "Seu Programa" — mostra a linha de código Dart real
  /// equivalente ao bloco (`codeLineFor`), não mais um ícone + painel
  /// "Tradutor de Blocos" separado (removido nesta mudança, ver
  /// `.claude/memory/decisions.md`, entrada de 2026-09-18). `"Para cada
  /// número"` mostra a própria linha de abertura do laço
  /// (`for (int i = 0; i < numeros.length; i++) {`); o bloco-alvo
  /// imediatamente seguinte (`entryByBlockIndex[index]?.insideForEach`,
  /// resolvido uma única vez em `_buildProgramArea`) mostra a linha do
  /// corpo indentada (`numeros[i]`); um bloco-alvo solto (sem "Para cada
  /// número" antes) mostra a variável descritiva `proximoNumero`. Os dois
  /// chips consecutivos (abertura + corpo) já comunicam o laço sem
  /// precisar de um 3º chip fantasma para o `}` de fechamento.
  ///
  /// Blocos dentro do prefixo fixo da fase
  /// (`index < state.level.prefilledCount`, ver
  /// `BlockProgramLevel.prefilledCount`) mostram a mesma linha de código,
  /// mas com opacidade reduzida (0.75) e um selo de cadeado (canto
  /// superior direito) — "isto já está pronto, você não toca aqui" — e
  /// sem `onTap` (o jogador não consegue removê-los; `removeBlockAt` no
  /// ViewModel já protege isso também, ver `.claude/memory/decisions.md`).
  Widget _blockChip(
    BlockProgramGameplayState state,
    BlockProgramGameplayViewModel notifier,
    int index,
    Map<int, BlockProgramProgramEntry> entryByBlockIndex,
  ) {
    final block = state.program[index];
    final style = styleForBlockProgramBlock(block.type);
    final isPrefilled = index < state.level.prefilledCount;

    final insideLoop = entryByBlockIndex[index]?.insideForEach ?? false;
    final codeLine = codeLineFor(block.type, insideLoop: insideLoop);
    final displayLine = insideLoop ? '  $codeLine' : codeLine;

    final chip = ProgramBlockChip(
      label: displayLine,
      background: style.background,
      foreground: style.foreground,
      highlighted: state.currentStepBlockIndex == index,
      onTap: isPrefilled ? null : () => notifier.removeBlockAt(index),
      border: style.border,
    );

    if (!isPrefilled) return chip;

    return Opacity(
      opacity: 0.75,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          chip,
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: AppColors.purpleDark, shape: BoxShape.circle),
              child: AppIcons.lock(size: 12, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
