import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/onboarding/onboarding_notifier.dart';
import '../../../../game/game_result.dart';
import '../../../../models/block.dart';
import '../../../../models/game_track.dart';
import '../../../../models/level.dart';
import '../../../auth/presentation/register/register_view.dart';
import '../../../tutorial/presentation/tutorial_view.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/block_chip_style.dart';
import '../../../../widgets/command_button_grid_widget.dart';
import '../../../../widgets/command_button_widget.dart';
import '../../../../widgets/direction_arrow_widget.dart';
import '../../../../widgets/gameplay_header_widget.dart';
import '../../../../widgets/mascot_image_widget.dart';
import '../../../../widgets/primary_pill_button_widget.dart';
import '../../../../widgets/program_block_chip_widget.dart';
import '../../../../widgets/program_chip_grid_widget.dart';
import '../../../../widgets/pulse_tap_widget.dart';
import '../../../../widgets/tutorial_content.dart';
import '../../../result/presentation/failure_view.dart';
import '../../../result/presentation/victory_view.dart';
import '../stage_select/stage_select_view.dart';
import 'gameplay_state.dart';
import 'gameplay_view_model.dart';

/// Texto real do motivo da falha a partir do `GameOutcome` da Execução —
/// só quem conhece o motor do Mundo 1 sabe interpretar um `GameOutcome`
/// (`FailureView` é genérica entre motores). Ver `.claude/docs/GAME_DESIGN.md`.
String _reasonTextFor(GameOutcome outcome) {
  switch (outcome) {
    case GameOutcome.crash:
      return 'O mascote bateu na parede (ou saiu do tabuleiro) antes de chegar no alvo.';
    case GameOutcome.farFromGoal:
      return 'O programa terminou, mas o mascote não chegou no alvo.';
    case GameOutcome.win:
      // Não deveria navegar para a Falha numa vitória — mantido só por
      // exaustividade do switch.
      return '';
  }
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

/// Gameplay do Mundo 1 (labirinto) — View da vertical de referência da
/// migração pra Riverpod/MVVM (ver
/// `C:\Users\XProcess\.claude\plans\encapsulated-whistling-peach.md`). Só
/// renderiza `GameplayState` e repassa toques pro `GameplayViewModel`
/// (`gameplayViewModelProvider(levelId)`) — nenhuma lógica de jogo ou
/// orquestração mora aqui.
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
            reasonText: _reasonTextFor(data.outcome),
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
          _buildBoard(state, maxSize: 340),
          const SizedBox(height: 14),
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
              Expanded(flex: 5, child: _buildBoard(state, maxSize: 640)),
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
                          children: [_buildProgramArea(context, ref, state)],
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
                      return _BoardCell(isWall: level.isWall(x, y), isGoal: level.isGoal(x, y));
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
        CommandButtonGrid(
          crossAxisCount: 4,
          maxCellHeight: 100,
          buttons: [
            CommandButton(
              iconBuilder: (size) => AppIcons.walk(size: size, color: AppColors.purpleDark),
              label: 'Andar',
              background: AppColors.lilac,
              foreground: AppColors.purpleDark,
              shadowColor: AppColors.lilacShadow,
              onTap: () => notifier.addBlock(BlockType.walk),
            ),
            CommandButton(
              iconBuilder: (size) => AppIcons.turnLeft(size: size, color: AppColors.white),
              label: 'Virar ←',
              background: AppColors.purple,
              foreground: AppColors.white,
              shadowColor: AppColors.purpleShadow,
              onTap: () => notifier.addBlock(BlockType.turnLeft),
            ),
            CommandButton(
              iconBuilder: (size) => AppIcons.turnRight(size: size, color: AppColors.white),
              label: 'Virar →',
              background: AppColors.purple,
              foreground: AppColors.white,
              shadowColor: AppColors.purpleShadow,
              onTap: () => notifier.addBlock(BlockType.turnRight),
            ),
            CommandButton(
              iconBuilder: (size) => AppIcons.repeat(size: size, color: AppColors.purpleDark),
              label: 'Repetir 3×',
              background: AppColors.yellowNeon,
              foreground: AppColors.purpleDark,
              shadowColor: AppColors.yellowShadow,
              onTap: () => notifier.addBlock(BlockType.repeat),
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

  Widget _blockChip(GameplayState state, GameplayViewModel notifier, int index) {
    final style = styleForBlock(state.program[index]);
    return ProgramBlockChip(
      label: style.label,
      background: style.background,
      foreground: style.foreground,
      repeatCount: style.repeatCount,
      badgeText: style.badgeText,
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

  const _BoardCell({required this.isWall, required this.isGoal});

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
    return Container(decoration: BoxDecoration(color: AppColors.grayCellFree, borderRadius: BorderRadius.circular(8)));
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
