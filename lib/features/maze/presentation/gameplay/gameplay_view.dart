import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/onboarding/onboarding_notifier.dart';
import '../../../../game/game_result.dart';
import '../../../../models/block.dart';
import '../../../../models/character_avatar.dart';
import '../../../../models/game_track.dart';
import '../../../../models/level.dart';
import '../../../auth/presentation/register/register_view.dart';
import '../../../tutorial/presentation/tutorial_view.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/block_chip_style.dart';
import '../../../../widgets/character_avatar_widget.dart';
import '../../../../widgets/command_button_grid_widget.dart';
import '../../../../widgets/command_button_widget.dart';
import '../../../../widgets/code_syntax_highlight.dart';
import '../../../../widgets/direction_arrow_widget.dart';
import '../../../../widgets/gameplay_header_widget.dart';
import '../../../../widgets/mascot_image_widget.dart';
import '../../../../widgets/primary_pill_button_widget.dart';
import '../../../../widgets/program_block_chip_widget.dart';
import '../../../../widgets/program_chip_grid_widget.dart';
import '../../../../widgets/program_code_translator.dart';
import '../../../../widgets/pulse_tap_widget.dart';
import '../../../../widgets/tutorial_content.dart';
import '../../../result/presentation/failure_view.dart';
import '../../../result/presentation/victory_view.dart';
import '../stage_select/stage_select_view.dart';
import 'gameplay_state.dart';
import 'gameplay_view_model.dart';

/// Texto real do motivo da falha a partir do `GameplayFailureData` da
/// Execução — só quem conhece o motor de labirinto (Mundos 1/2/3) sabe
/// interpretar um `GameOutcome` (`FailureView` é genérica entre motores).
/// Ver `.claude/docs/GAME_DESIGN.md`.
String _reasonTextFor(GameplayFailureData data) {
  switch (data.outcome) {
    case GameOutcome.crash:
      return 'O mascote bateu na parede (ou saiu do tabuleiro) antes de chegar no alvo.';
    case GameOutcome.farFromGoal:
      return 'O programa terminou, mas o mascote não chegou no alvo.';
    case GameOutcome.wrongCollectCount:
      // Só Mundo 2 ("Resgate de Personagens") — a posição final estava
      // certa, mas a quantidade de personagens resgatados não bateu
      // (achado do UX Reviewer: mostrar os números reais, não um texto
      // genérico — mesmo padrão já usado em
      // `block_program_gameplay_view.dart`).
      return 'O mascote chegou no alvo, mas resgatou ${data.collectedCount} personagem(ns) — a fase pedia ${data.collectTarget}.';
    case GameOutcome.wrongPaintPattern:
      {
        // Só Mundo 3 ("Desenho no Tabuleiro") — a posição final estava
        // certa, mas o desenho pintado não bateu exatamente com o pedido.
        // Mostra a diferença real (quantas células faltaram/sobraram),
        // mesmo critério de "números reais, não texto genérico" já usado
        // em `wrongCollectCount`/`block_program_gameplay_view.dart`.
        final missing = data.missingPaintCount;
        final extra = data.extraPaintCount;
        if (missing > 0 && extra > 0) {
          return 'O mascote chegou no alvo, mas faltou pintar $missing célula(s) do desenho e pintou $extra fora dele.';
        }
        if (missing > 0) {
          return 'O mascote chegou no alvo, mas faltou pintar $missing célula(s) do desenho.';
        }
        if (extra > 0) {
          return 'O mascote chegou no alvo, mas pintou $extra célula(s) fora do desenho.';
        }
        return 'O mascote chegou no alvo, mas o desenho não ficou igual ao pedido.';
      }
    case GameOutcome.win:
      // Não deveria navegar para a Falha numa vitória — mantido só por
      // exaustividade do switch.
      return '';
  }
}

/// Personagens elegíveis para aparecer perdidos no tabuleiro do Mundo 2
/// ("Resgate de Personagens") — todos exceto Lili (o próprio Mascote
/// controlado pelo jogador; resgatar a si mesma não faria sentido).
final _rescuableAvatars = characterAvatars.where((a) => a.id != defaultAvatarId).toList();

/// Escolhe um personagem determinístico para cada célula com um personagem
/// perdido (`Level.collectibles`) — cicla por `_rescuableAvatars` na ordem
/// (y, depois x) das posições, para o mesmo conjunto de células sempre
/// resultar na mesma escolha visual (a ordem de iteração de `Set` não é
/// garantida, por isso a ordenação explícita). Decisão puramente cosmética
/// de UI — o modelo (`Level.collectibles`) não sabe nem precisa saber qual
/// personagem é qual. Ver `.claude/memory/decisions.md`, entrada de
/// 2026-09-18.
Map<GridPosition, String> _avatarIdsForCollectibles(Set<GridPosition> collectibles) {
  final sorted = collectibles.toList()
    ..sort((a, b) => a.y != b.y ? a.y.compareTo(b.y) : a.x.compareTo(b.x));
  return {
    for (var i = 0; i < sorted.length; i++) sorted[i]: _rescuableAvatars[i % _rescuableAvatars.length].id,
  };
}

/// Volta pra Seleção de Fases — a menos que o Mundo que acabou de fechar
/// agora seja o último da Trilha 1 e o jogador ainda não tenha conta, caso
/// em que empurra `RegisterView` primeiro (gate de fim de Trilha, ver
/// `.claude/memory/decisions.md`). Sempre tem uma saída (link "Continuar
/// sem conta por enquanto" dentro da própria tela) — nunca trava o app se
/// o Firebase estiver indisponível.
void _returnToLevelSelect(BuildContext context, WidgetRef ref, {required int worldNumber, required bool worldJustCompleted}) {
  final isEndOfTrack1 = worldJustCompleted && worldNumber == tracks.first.worlds.last.number;
  if (isEndOfTrack1 && !ref.read(authServiceProvider).hasAccount) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterView(
        mandatory: true,
        onDone: () => Navigator.of(context).popUntil((route) => route.settings.name == levelSelectRouteName),
      ),
    ));
    return;
  }
  Navigator.of(context).popUntil((route) => route.settings.name == levelSelectRouteName);
}

/// Chamado pelo botão primário da `VictoryView` — decide entre jogar a
/// próxima fase direto, mostrar a recapitulação de fim de Mundo (só na 1ª
/// vez que o Mundo fica 100% completo), ou voltar direto pra Seleção de
/// Fases (com o gate de cadastro embutido em `_returnToLevelSelect`).
void _onVictoryPrimaryAction(BuildContext context, WidgetRef ref, GameplayVictoryData data) {
  if (data.nextLevel != null) {
    // Volta à mesma instância da Seleção de Fases já na pilha (em vez de
    // criar outra) e joga a próxima fase direto na sequência, sem passar
    // pela tela de seleção.
    Navigator.of(context).popUntil((route) => route.settings.name == levelSelectRouteName);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameplayView(levelId: data.nextLevel!.id)));
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

/// Gameplay do motor de labirinto — reaproveitada pelos Mundos 1 ("Primeiros
/// passos"), 2 ("Resgate de Personagens") e 3 ("Desenho no Tabuleiro"), todos
/// `WorldGameType.maze` (`Level`/`ProgramExecutor`), diferenciados só pelo
/// conteúdo de cada fase — ver `.claude/memory/decisions.md`, entradas de
/// 2026-09-18. Só renderiza `GameplayState` e repassa toques pro
/// `GameplayViewModel` (`gameplayViewModelProvider(levelId)`) — nenhuma
/// lógica de jogo ou orquestração mora aqui.
class GameplayView extends ConsumerWidget {
  final String levelId;

  const GameplayView({super.key, required this.levelId});

  static const _boardPadding = 8.0;
  static const _cellGap = 4.0;
  static const _moveAnimationDuration = Duration(milliseconds: 380);

  /// Acima desta largura (tablet, principalmente paisagem — ver
  /// `.claude/plans/Roadmap.md`), o tabuleiro e a área de comandos ficam
  /// lado a lado em vez de empilhados; abaixo, o layout de celular
  /// (empilhado, com scroll) continua igual.
  static const _tabletBreakpoint = 700.0;

  void _handleEffect(BuildContext context, WidgetRef ref, GameplayEffect effect) {
    ref.read(gameplayViewModelProvider(levelId).notifier).clearEffect();
    switch (effect) {
      case NavigateToVictory(:final data):
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
      case NavigateToFailure(:final data):
        final level = ref.read(gameplayViewModelProvider(levelId)).level;
        final hintChips = [
          for (final block in level.hintProgram)
            Builder(builder: (context) {
              final style = styleForBlock(block);
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
            reasonText: _reasonTextFor(data),
            maxBlocks: data.maxBlocks,
            hintChips: hintChips,
            onBackToMenu: () => Navigator.of(context).popUntil((route) => route.settings.name == levelSelectRouteName),
          ),
        ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<GameplayState>(gameplayViewModelProvider(levelId), (previous, next) {
      final effect = next.pendingEffect;
      if (effect != null) _handleEffect(context, ref, effect);
    });

    final state = ref.watch(gameplayViewModelProvider(levelId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth >= _tabletBreakpoint ? _buildTabletLayout(context, ref, state) : _buildPhoneLayout(context, ref, state);
            },
          ),
        ),
      ),
    );
  }

  /// Celular: tudo empilhado (tabuleiro em cima, comandos embaixo), com
  /// scroll — evita estourar em celulares baixos em vez de forçar caber.
  Widget _buildPhoneLayout(BuildContext context, WidgetRef ref, GameplayState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context, state),
          const SizedBox(height: 10),
          _buildRescuePanel(state),
          _buildBoard(state, maxSize: 340),
          const SizedBox(height: 14),
          _buildCodeTranslator(state),
          _buildProgramArea(context, ref, state),
        ],
      ),
    );
  }

  /// Tablet: tabuleiro (maior) à esquerda, "Seu Programa" + comandos + Play
  /// à direita — aproveita a largura extra sem precisar de scroll (ver
  /// `.claude/plans/Roadmap.md`).
  Widget _buildTabletLayout(BuildContext context, WidgetRef ref, GameplayState state) {
    return Column(
      children: [
        _buildHeader(context, state),
        const SizedBox(height: 14),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildRescuePanel(state),
                    Expanded(child: _buildBoard(state, maxSize: 640)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      // Centraliza verticalmente quando sobra altura (comum
                      // em tablet retrato, onde a coluna fica bem mais alta
                      // que o conteúdo) — sem isso tudo ficava colado no
                      // topo, com um vão vazio embaixo do Play (achado do
                      // UX Reviewer). `Column` (não `Center`) preserva a
                      // largura travada que `SingleChildScrollView` já dá
                      // ao filho — `Center` a soltaria e quebraria o
                      // `crossAxisAlignment: stretch` de `_buildProgramArea`.
                      // Ainda rola normalmente se não couber (tablet baixo).
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCodeTranslator(state),
                            _buildProgramArea(context, ref, state),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Painel "Resgatados: X / Y" — só Mundo 2 ("Resgate de Personagens",
  /// `level.collectTarget != null`). Mesmo espírito visual dos cards
  /// "TOTAL"/"ALVO" do Mundo 4 ("Decisões em Bloco") — o jogador sempre vê o
  /// progresso sem precisar guardar de cabeça quantos personagens já
  /// resgatou.
  Widget _buildRescuePanel(GameplayState state) {
    final target = state.level.collectTarget;
    if (target == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: AppColors.purpleDark, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 18, color: AppColors.yellowNeon),
            const SizedBox(width: 8),
            // `Flexible`+`FittedBox` em vez de `Text` cru — em celulares
            // estreitos (320px), "Resgatados: X / Y" em Nunito 900 não cabia
            // nos ~226px restantes do Row (achado real, `RenderFlex
            // overflowed by 50 pixels`), mesma técnica já usada em
            // `gameplay_header_widget.dart`/`CommandButton` para encolher em
            // vez de estourar.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Resgatados: ${state.cursor.collectedCount} / $target',
                  maxLines: 1,
                  style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.yellowNeon),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameplayState state) {
    return GameplayHeader(
      levelNumber: state.level.number,
      title: state.level.title,
      trailingChipText: '${state.program.length} / ${state.level.maxBlocks} blocos',
      onBack: () => Navigator.of(context).pop(),
    );
  }

  /// `maxSize` limita o lado do tabuleiro (celular: cabe na largura da
  /// tela; tablet: cabe na largura *e* na altura disponíveis dentro do
  /// `Expanded` do layout lado a lado — por isso considera as duas, não só
  /// a largura como antes).
  Widget _buildBoard(GameplayState state, {required double maxSize}) {
    final level = state.level;
    final avatarIds = _avatarIdsForCollectibles(level.collectibles);
    return Center(
      child: LayoutBuilder(
        builder: (context, outerConstraints) {
          final boardSize = math.min(math.min(outerConstraints.maxWidth, outerConstraints.maxHeight), maxSize);
          final innerSize = boardSize - _boardPadding * 2;
          final cellSize = (innerSize - _cellGap * (level.gridSize - 1)) / level.gridSize;

          return SizedBox(
            key: const Key('gameplayBoard'),
            width: boardSize,
            height: boardSize,
            child: Container(
              padding: const EdgeInsets.all(_boardPadding),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.grayButton, width: 3),
              ),
              child: Stack(
                children: [
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: level.gridSize * level.gridSize,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: level.gridSize,
                      mainAxisSpacing: _cellGap,
                      crossAxisSpacing: _cellGap,
                    ),
                    itemBuilder: (context, index) {
                      final x = index % level.gridSize;
                      final y = index ~/ level.gridSize;
                      final position = GridPosition(x, y);
                      return _BoardCell(
                        isWall: level.isWall(x, y),
                        isGoal: level.isGoal(x, y),
                        hasCollectible: level.collectibles.contains(position),
                        collected: state.cursor.collectedTiles.contains(position),
                        avatarId: avatarIds[position],
                        isPaintTarget: level.isPaintTarget(x, y),
                        isPainted: state.cursor.paintedTiles.contains(position),
                      );
                    },
                  ),
                  AnimatedPositioned(
                    duration: _moveAnimationDuration,
                    curve: Curves.easeInOut,
                    left: state.cursor.x * (cellSize + _cellGap),
                    top: state.cursor.y * (cellSize + _cellGap),
                    width: cellSize,
                    height: cellSize,
                    child: _MascotTile(direction: state.cursor.direction),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Painel "TRADUTOR DE BLOCOS" — mostra o Programa montado como
  /// pseudo-código Dart-like (`programCodeLinesFor`), atualizando ao vivo a
  /// cada bloco adicionado/removido. Aparece nos 3 mundos deste motor
  /// (Mundos 1, 2 e 3) — a mesma "porta de entrada" visual para código que
  /// o Mundo 4 já tem (`codeLinesFor`/`block_program_chip_style.dart`), sem
  /// duplicar a regra de pareamento de `Repetir` (`resolveProgramEntries`,
  /// ver `.claude/docs/GAME_DESIGN.md`). Altura limitada com scroll próprio
  /// — Programas grandes (até 8 blocos, alguns virando 3 linhas com
  /// `Repetir`) não empurram o resto do layout pra baixo.
  Widget _buildCodeTranslator(GameplayState state) {
    final lines = programCodeLinesFor(state.program);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        key: const Key('mazeCodeTranslator'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.purpleDark, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TRADUTOR DE BLOCOS', style: AppText.eyebrow(size: 11)),
            const SizedBox(height: 8),
            if (lines.isEmpty)
              Text(
                '// monte um Programa para ver o código aqui',
                style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.grayLockIcon),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final line in lines)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: RichText(text: TextSpan(children: highlightCodeLine(line))),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramArea(BuildContext context, WidgetRef ref, GameplayState state) {
    final notifier = ref.read(gameplayViewModelProvider(levelId).notifier);
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
        _buildCommandGrid(state, notifier),
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

  /// Paleta de comandos derivada de `availableBlockTypesForWorld` — Mundos 1
  /// ("Primeiros passos") e 3 ("Desenho no Tabuleiro") continuam com os
  /// mesmos 4 comandos básicos; Mundo 2 ("Resgate de Personagens") ganha o
  /// bloco condicional de resgate (`rescueIfCharacterHere`), 5 no total. 3
  /// colunas quando há mais de 4 comandos para caberem 2 linhas sem
  /// espremer — mesmo critério já usado por outros motores com 5-6
  /// comandos.
  Widget _buildCommandGrid(GameplayState state, GameplayViewModel notifier) {
    final availableTypes = availableBlockTypesForWorld(state.level.world);
    return CommandButtonGrid(
      crossAxisCount: availableTypes.length > 4 ? 3 : 4,
      maxCellHeight: 100,
      buttons: [
        for (final type in availableTypes) _commandButtonFor(type, notifier),
      ],
    );
  }

  CommandButton _commandButtonFor(BlockType type, GameplayViewModel notifier) {
    final style = styleForBlock(Block(type));
    return CommandButton(
      iconBuilder: style.icon,
      // "Repetir" precisa continuar aparecendo como "Repetir 3×" no botão
      // (diferente do chip de "Seu Programa", que mostra o "3×" num badge
      // separado) — mesmo texto que os testes de fluxo já procuram.
      label: style.repeatCount != null ? '${style.label} ${style.repeatCount}×' : style.label,
      background: style.background,
      foreground: style.foreground,
      shadowColor: style.shadowColor,
      border: style.border,
      onTap: () => notifier.addBlock(type),
    );
  }

  Widget _blockChip(GameplayState state, GameplayViewModel notifier, int index) {
    final style = styleForBlock(state.program[index]);
    return ProgramBlockChip(
      label: style.label,
      background: style.background,
      foreground: style.foreground,
      repeatCount: style.repeatCount,
      badgeText: style.badgeText,
      border: style.border,
      highlighted: state.currentStepBlockIndex == index,
      onTap: () => notifier.removeBlockAt(index),
      // "Seu Programa" mostra só o ícone (rótulo continua nos
      // `CommandButton`s da paleta abaixo) — pedido explícito do usuário,
      // ver `.claude/memory/decisions.md`.
      icon: style.icon(programBlockChipIconSize),
      showLabel: false,
    );
  }
}

class _BoardCell extends StatelessWidget {
  final bool isWall;
  final bool isGoal;

  /// `true` quando esta célula tem um personagem perdido — só Mundo 2
  /// ("Resgate de Personagens"), ver `Level.collectibles`.
  final bool hasCollectible;

  /// `true` quando o mascote já resgatou o personagem desta célula nesta
  /// Execução (via `rescueIfCharacterHere`) — dispara a animação de "poof"
  /// (fade + encolher) em vez de o personagem simplesmente desaparecer.
  final bool collected;

  /// Qual personagem desenhar nesta célula (`CharacterAvatar.id`) — só
  /// relevante quando `hasCollectible` é `true`.
  final String? avatarId;

  /// `true` quando esta célula faz parte do desenho-alvo — só Mundo 3
  /// ("Desenho no Tabuleiro"), ver `Level.paintTarget`.
  final bool isPaintTarget;

  /// `true` quando o mascote já pintou esta célula nesta Execução
  /// (`GameCursor.paintedTiles`).
  final bool isPainted;

  const _BoardCell({
    required this.isWall,
    required this.isGoal,
    this.hasCollectible = false,
    this.collected = false,
    this.avatarId,
    this.isPaintTarget = false,
    this.isPainted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isWall) {
      return CustomPaint(painter: _WallPainter());
    }
    if (isGoal) {
      return Container(
        decoration: BoxDecoration(color: AppColors.grayCellFree, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: PulseTap(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.yellowNeon,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.yellowNeon.withValues(alpha: 0.25), blurRadius: 0, spreadRadius: 5)],
              ),
              alignment: Alignment.center,
              child: FittedBox(
                child: Text('</>', style: AppText.style(size: 12, weight: FontWeight.w900, color: AppColors.purpleDark)),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(color: AppColors.grayCellFree, borderRadius: BorderRadius.circular(8)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isPaintTarget) Positioned.fill(child: _PaintMarker(painted: isPainted)),
          if (hasCollectible) _CharacterMarker(avatarId: avatarId ?? defaultAvatarId, rescued: collected),
        ],
      ),
    );
  }
}

/// Indicador visual do desenho-alvo (Mundo 3, "Desenho no Tabuleiro") —
/// preenchimento sutil enquanto a célula ainda não foi pintada
/// (`painted: false`), que fica mais forte/sólido quando o mascote já
/// passou por aqui nesta Execução (`painted: true`). Cor `lilac` — não
/// compete com o Alvo (`yellowNeon` pulsante) nem com o contorno do
/// Mascote (também `lilac`, mas sem preencher a célula).
class _PaintMarker extends StatelessWidget {
  final bool painted;

  const _PaintMarker({required this.painted});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: AppColors.lilac.withValues(alpha: painted ? 0.7 : 0.18),
        borderRadius: BorderRadius.circular(8),
        border: painted ? null : Border.all(color: AppColors.lilac.withValues(alpha: 0.6), width: 2),
      ),
    );
  }
}

/// Indicador visual de um personagem perdido (Mundo 2, "Resgate de
/// Personagens") — desaparece com um "poof" (encolher + esmaecer, ~260ms)
/// quando `rescueIfCharacterHere` resgata de verdade, em vez de só sumir de
/// repente. `avatarId` cicla entre os personagens do jogo (exceto Lili, o
/// próprio Mascote) — ver `_avatarIdsForCollectibles`.
class _CharacterMarker extends StatelessWidget {
  final String avatarId;
  final bool rescued;

  const _CharacterMarker({required this.avatarId, required this.rescued});

  static const _poofDuration = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: rescued ? 0 : 1,
      duration: _poofDuration,
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: rescued ? 0 : 1,
        duration: _poofDuration,
        child: FractionallySizedBox(
          widthFactor: 0.72,
          heightFactor: 0.72,
          child: LayoutBuilder(
            builder: (context, constraints) => CharacterAvatarCircle(
              avatarId: avatarId,
              size: constraints.biggest.shortestSide,
              ringColor: AppColors.purpleDark,
              ringWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _WallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8));
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRRect(rrect, Paint()..color = AppColors.wallStripe);

    final stripePaint = Paint()
      ..color = AppColors.black.withValues(alpha: 0.18)
      ..strokeWidth = 6;
    final diagonal = size.width + size.height;
    for (var offset = -diagonal; offset < diagonal; offset += 12) {
      canvas.drawLine(Offset(offset, 0), Offset(offset + size.height, size.height), stripePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WallPainter oldDelegate) => false;
}

class _MascotTile extends StatelessWidget {
  final FacingDirection direction;

  const _MascotTile({required this.direction});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transformAlignment: Alignment.center,
      transform: Matrix4.rotationZ(direction.index * 1.5708),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lilac, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(2),
            child: FittedBox(fit: BoxFit.contain, child: MascotImage(size: 200)),
          ),
          const Positioned(right: 2, top: 2, child: DirectionArrow(width: 7, height: 10)),
        ],
      ),
    );
  }
}
