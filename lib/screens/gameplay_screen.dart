import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/app_sounds.dart';
import '../data/app_auth.dart';
import '../data/progress_sync.dart';
import '../game/game_result.dart';
import '../game/leaderboard_scoring.dart';
import '../game/program_executor.dart';
import '../game/scoring.dart';
import '../models/block.dart';
import '../models/game_track.dart';
import '../models/level.dart';
import '../models/onboarding.dart';
import '../models/progress.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../widgets/block_chip_style.dart';
import '../widgets/command_button_grid_widget.dart';
import '../widgets/command_button_widget.dart';
import '../widgets/direction_arrow_widget.dart';
import '../widgets/gameplay_header_widget.dart';
import '../widgets/mascot_image_widget.dart';
import '../widgets/primary_pill_button_widget.dart';
import '../widgets/program_block_chip_widget.dart';
import '../widgets/program_chip_grid_widget.dart';
import '../widgets/pulse_tap_widget.dart';
import '../widgets/tutorial_content.dart';
import 'failure_screen.dart';
import 'level_select_screen.dart';
import 'register_screen.dart';
import 'tutorial_screen.dart';
import 'victory_screen.dart';

/// Texto real do motivo da falha a partir do `GameOutcome` da Execução —
/// movido para cá (de dentro de `FailureScreen`, agora genérica entre
/// motores) porque só quem conhece o motor do Mundo 1 sabe interpretar um
/// `GameOutcome`. Ver `.claude/docs/GAME_DESIGN.md`.
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

/// Tela 3 — Gameplay. A única tela interativa: o jogador monta o Programa
/// e a Execução roda contra `level` via `ProgramExecutor` (`lib/game/`).
class GameplayScreen extends StatefulWidget {
  final Level level;

  const GameplayScreen({super.key, required this.level});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  Level get _level => widget.level;
  late final ProgramExecutor _executor = ProgramExecutor(_level);
  final List<Block> _program = [];

  late GameCursor _cursor = GameCursor.fromStart(_level);
  bool _running = false;
  int? _currentStepBlockIndex;
  int _attempts = 0;

  /// Do momento em que a fase abre até a vitória — inclui tentativas
  /// falhas (a tela não é recriada entre "Tentar de novo" e a próxima
  /// tentativa). Usado só para o Placar do Dia (`Progress.sessionScore`),
  /// nunca mostrado na UI — ver `.claude/docs/GAME_DESIGN.md`.
  final Stopwatch _levelStopwatch = Stopwatch()..start();

  /// Blocos do Programa que rodaram na última Execução — capturado no
  /// início de `_run()` para não mudar se o jogador tocar num chip do
  /// "Seu Programa" depois de a Execução já ter terminado.
  int _lastRunBlocksUsed = 0;

  static const _boardPadding = 8.0;
  static const _cellGap = 4.0;
  static const _stepDuration = Duration(milliseconds: 460);
  static const _startDelay = Duration(milliseconds: 200);
  static const _moveAnimationDuration = Duration(milliseconds: 380);

  /// Acima desta largura (tablet, principalmente paisagem — ver
  /// `.claude/plans/Roadmap.md`), o tabuleiro e a área de comandos ficam
  /// lado a lado em vez de empilhados; abaixo, o layout de celular
  /// (empilhado, com scroll) continua igual.
  static const _tabletBreakpoint = 700.0;

  /// Pausa curta depois do último passo (vitória ou falha) antes de navegar
  /// — só para o jogador ver onde o mascote parou antes da troca de tela.
  static const _resultPause = Duration(milliseconds: 500);

  void _addBlock(BlockType type) {
    if (_running || _program.length >= _level.maxBlocks) return;
    setState(() => _program.add(Block(type)));
  }

  void _removeBlockAt(int index) {
    if (_running) return;
    setState(() => _program.removeAt(index));
  }

  void _clearProgram() {
    if (_running) return;
    setState(() {
      _program.clear();
      _cursor = GameCursor.fromStart(_level);
      _currentStepBlockIndex = null;
    });
  }

  Future<void> _run() async {
    if (_running || _program.isEmpty) return;
    final steps = _executor.expand(_program);

    setState(() {
      _running = true;
      _currentStepBlockIndex = null;
      _cursor = GameCursor.fromStart(_level);
      _attempts++;
      _lastRunBlocksUsed = _program.length;
    });
    AppSounds.instance.run();

    await Future.delayed(_startDelay);

    for (final step in steps) {
      if (!mounted) return;
      final outcome = _executor.applyStep(_cursor, step.type);
      if (step.type == BlockType.walk) {
        AppSounds.instance.walk();
      } else if (step.type == BlockType.turnLeft || step.type == BlockType.turnRight) {
        AppSounds.instance.turn();
      }

      if (outcome.crashed) {
        setState(() {
          _running = false;
          _currentStepBlockIndex = step.blockIndex;
        });
        await _goToResultScreen(GameOutcome.crash);
        return;
      }

      setState(() {
        _cursor = outcome.cursor;
        _currentStepBlockIndex = step.blockIndex;
      });

      await Future.delayed(_stepDuration);
    }

    if (!mounted) return;
    final finalOutcome = _executor.evaluateFinal(_cursor);
    setState(() {
      _running = false;
      _currentStepBlockIndex = null;
    });
    await _goToResultScreen(finalOutcome);
  }

  /// Volta pra Seleção de Fases — a menos que o Mundo que acabou de fechar
  /// agora seja o último da Trilha 1 e o jogador ainda não tenha conta, caso
  /// em que empurra `RegisterScreen` primeiro (gate de fim de Trilha, ver
  /// `.claude/memory/decisions.md`). Sempre tem uma saída (link "Continuar
  /// sem conta por enquanto" dentro da própria tela) — nunca trava o app se
  /// o Firebase estiver indisponível.
  void _returnToLevelSelect(BuildContext context, bool worldJustCompleted) {
    final isEndOfTrack1 = worldJustCompleted && _level.world == tracks.first.worlds.last.number;
    if (isEndOfTrack1 && !AppAuth.instance.hasAccount) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RegisterScreen(
          mandatory: true,
          onDone: () => Navigator.of(context).popUntil((route) => route.settings.name == levelSelectRouteName),
        ),
      ));
      return;
    }
    Navigator.of(context).popUntil((route) => route.settings.name == levelSelectRouteName);
  }

  /// Navega direto para a tela de resultado real (Vitória ou Falha) assim
  /// que a Execução termina — sem modal/overlay intermediário no tabuleiro.
  Future<void> _goToResultScreen(GameOutcome outcome) async {
    await Future.delayed(_resultPause);
    if (!mounted) return;

    // Deixa o tabuleiro pronto para a próxima tentativa (mascote de volta
    // ao início) para quando o jogador voltar via "Tentar de novo".
    setState(() => _cursor = GameCursor.fromStart(_level));

    if (outcome == GameOutcome.win) {
      // `List<Level>` — `LevelSelectScreen` só é aberta com um Mundo 1 (ver
      // `WorldSelectScreen._openWorld`), então este `GameplayScreen` só
      // recebe `Level`s de um mundo `maze`; o `.cast` desfaz o
      // `List<GameLevel>` genérico de `GameWorld.levels`.
      final levelsInWorld = worlds.firstWhere((w) => w.number == _level.world).levels.cast<Level>();
      final levelIds = levelsInWorld.map((l) => l.id);
      // Calculado antes de `recordWin` marcar esta fase como concluída —
      // só assim dá pra saber se o Mundo acabou de ficar 100% completo
      // agora (e não já estava antes, num replay).
      final wasWorldCompleteBefore = Progress.instance.isWorldCompleted(levelIds);
      final isFirstWin = !Progress.instance.isCompleted(_level.id);

      final score = computeScore(blocksUsed: _lastRunBlocksUsed, optimalBlocks: _level.optimalBlocks);
      Progress.instance.recordWin(_level.id, stars: score.stars, blocksUsed: _lastRunBlocksUsed);
      if (isFirstWin) {
        Progress.instance.addSessionPoints(
          computeSessionPoints(worldNumber: _level.world, elapsedSeconds: _levelStopwatch.elapsed.inSeconds),
        );
      }
      ProgressSync.instance.syncNow();
      final worldJustCompleted = !wasWorldCompleteBefore && Progress.instance.isWorldCompleted(levelIds);

      final levelIndex = levelsInWorld.indexWhere((l) => l.id == _level.id);
      final nextLevel = (levelIndex >= 0 && levelIndex + 1 < levelsInWorld.length) ? levelsInWorld[levelIndex + 1] : null;

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VictoryScreen(
          levelNumber: _level.number,
          blocksUsed: _lastRunBlocksUsed,
          maxBlocks: _level.maxBlocks,
          optimalBlocks: _level.optimalBlocks,
          hasNext: nextLevel != null,
          onPrimaryAction: () {
            if (nextLevel != null) {
              // Volta à mesma instância da Seleção de Fases já na pilha (em
              // vez de criar outra) e joga a próxima fase direto na
              // sequência, sem passar pela tela de seleção.
              Navigator.of(context).popUntil((route) => route.settings.name == levelSelectRouteName);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameplayScreen(level: nextLevel)));
              return;
            }
            // Última fase do Mundo — se ele acabou de ficar 100% completo
            // agora (não já antes), mostra a recapitulação antes de voltar
            // (ver `.claude/memory/decisions.md`).
            if (worldJustCompleted && !Onboarding.instance.hasSeenRecap(_level.world)) {
              final recap = recapSlidesFor(_level.world);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TutorialScreen(
                  slides: recap.slides,
                  narrationAssets: recap.narrationAssets,
                  finalLabel: 'Continuar',
                  onFinish: () {
                    Onboarding.instance.markRecapSeen(_level.world);
                    _returnToLevelSelect(context, worldJustCompleted);
                  },
                ),
              ));
              return;
            }
            _returnToLevelSelect(context, worldJustCompleted);
          },
        ),
      ));
    } else {
      final hintChips = [
        for (final block in _level.hintProgram)
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
        builder: (_) => FailureScreen(
          levelNumber: _level.number,
          attempt: _attempts,
          reasonText: _reasonTextFor(outcome),
          maxBlocks: _level.maxBlocks,
          hintChips: hintChips,
          onBackToMenu: () => Navigator.of(context).popUntil((route) => route.settings.name == levelSelectRouteName),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth >= _tabletBreakpoint ? _buildTabletLayout() : _buildPhoneLayout();
            },
          ),
        ),
      ),
    );
  }

  /// Celular: tudo empilhado (tabuleiro em cima, comandos embaixo), com
  /// scroll — evita estourar em celulares baixos em vez de forçar caber.
  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildBoard(maxSize: 340),
          const SizedBox(height: 14),
          _buildProgramArea(),
        ],
      ),
    );
  }

  /// Tablet: tabuleiro (maior) à esquerda, "Seu Programa" + comandos + Play
  /// à direita — aproveita a largura extra sem precisar de scroll (ver
  /// `.claude/plans/Roadmap.md`).
  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 14),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: _buildBoard(maxSize: 640)),
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
                          children: [_buildProgramArea()],
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

  Widget _buildHeader() {
    return GameplayHeader(
      levelNumber: _level.number,
      title: _level.title,
      trailingChipText: '${_program.length} / ${_level.maxBlocks} blocos',
      onBack: () => Navigator.of(context).pop(),
    );
  }

  /// `maxSize` limita o lado do tabuleiro (celular: cabe na largura da
  /// tela; tablet: cabe na largura *e* na altura disponíveis dentro do
  /// `Expanded` do layout lado a lado — por isso considera as duas, não só
  /// a largura como antes).
  Widget _buildBoard({required double maxSize}) {
    return Center(
      child: LayoutBuilder(
        builder: (context, outerConstraints) {
          final boardSize = math.min(math.min(outerConstraints.maxWidth, outerConstraints.maxHeight), maxSize);
          final innerSize = boardSize - _boardPadding * 2;
          final cellSize = (innerSize - _cellGap * (_level.gridSize - 1)) / _level.gridSize;

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
                    itemCount: _level.gridSize * _level.gridSize,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _level.gridSize,
                      mainAxisSpacing: _cellGap,
                      crossAxisSpacing: _cellGap,
                    ),
                    itemBuilder: (context, index) {
                      final x = index % _level.gridSize;
                      final y = index ~/ _level.gridSize;
                      return _BoardCell(isWall: _level.isWall(x, y), isGoal: _level.isGoal(x, y));
                    },
                  ),
                  AnimatedPositioned(
                    duration: _moveAnimationDuration,
                    curve: Curves.easeInOut,
                    left: _cursor.x * (cellSize + _cellGap),
                    top: _cursor.y * (cellSize + _cellGap),
                    width: cellSize,
                    height: cellSize,
                    child: _MascotTile(direction: _cursor.direction),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgramArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SEU PROGRAMA', style: AppText.eyebrow(size: 11)),
            TextButton(
              onPressed: _running ? null : _clearProgram,
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
          child: _program.isEmpty
              ? Center(
                  child: Text(
                    'Toque nos blocos abaixo para montar',
                    style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.grayLockIcon),
                  ),
                )
              : ProgramChipGrid(
                  chips: [
                    for (var i = 0; i < _program.length; i++)
                      _blockChip(_program[i], i),
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
              onTap: () => _addBlock(BlockType.walk),
            ),
            CommandButton(
              iconBuilder: (size) => AppIcons.turnLeft(size: size, color: AppColors.white),
              label: 'Virar ←',
              background: AppColors.purple,
              foreground: AppColors.white,
              shadowColor: AppColors.purpleShadow,
              onTap: () => _addBlock(BlockType.turnLeft),
            ),
            CommandButton(
              iconBuilder: (size) => AppIcons.turnRight(size: size, color: AppColors.white),
              label: 'Virar →',
              background: AppColors.purple,
              foreground: AppColors.white,
              shadowColor: AppColors.purpleShadow,
              onTap: () => _addBlock(BlockType.turnRight),
            ),
            CommandButton(
              iconBuilder: (size) => AppIcons.repeat(size: size, color: AppColors.purpleDark),
              label: 'Repetir 3×',
              background: AppColors.yellowNeon,
              foreground: AppColors.purpleDark,
              shadowColor: AppColors.yellowShadow,
              onTap: () => _addBlock(BlockType.repeat),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PrimaryPillButton(
          label: _running ? 'Executando…' : 'PLAY',
          height: 64,
          fontSize: 24,
          enabled: !_running,
          icon: AppIcons.play(size: 26, color: AppColors.purpleDark),
          onTap: _run,
        ),
      ],
    );
  }

  Widget _blockChip(Block block, int index) {
    final style = styleForBlock(block);
    return ProgramBlockChip(
      label: style.label,
      background: style.background,
      foreground: style.foreground,
      repeatCount: style.repeatCount,
      highlighted: _currentStepBlockIndex == index,
      onTap: () => _removeBlockAt(index),
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
