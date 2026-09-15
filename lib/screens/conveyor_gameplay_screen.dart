import 'package:flutter/material.dart';

import '../audio/app_sounds.dart';
import '../data/app_auth.dart';
import '../data/progress_sync.dart';
import '../game/belt_executor.dart';
import '../game/leaderboard_scoring.dart';
import '../game/scoring.dart';
import '../models/belt_block.dart';
import '../models/belt_item.dart';
import '../models/conveyor_level.dart';
import '../models/game_track.dart';
import '../models/level.dart';
import '../models/onboarding.dart';
import '../models/progress.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../widgets/belt_block_chip_style.dart';
import '../widgets/command_button_grid_widget.dart';
import '../widgets/command_button_widget.dart';
import '../widgets/gameplay_header_widget.dart';
import '../widgets/primary_pill_button_widget.dart';
import '../widgets/program_block_chip_widget.dart';
import '../widgets/program_chip_grid_widget.dart';
import '../widgets/pulse_tap_widget.dart';
import '../widgets/tutorial_content.dart';
import 'conveyor_stage_select_screen.dart';
import 'failure_screen.dart';
import 'register_screen.dart';
import 'tutorial_screen.dart';
import 'victory_screen.dart';

/// Texto real do motivo da falha a partir do `BeltOutcome` da Execução —
/// mesma ideia de `_reasonTextFor(GameOutcome)` em `gameplay_screen.dart`
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

/// Gameplay do Mundo 2 (Esteira de Bugs) — mesmo papel de `GameplayScreen`
/// (Mundo 1), mas sem grid/mascote: o jogador classifica, um de cada vez,
/// os Itens de `level.itemQueue` mandando-os para a Caixa A/B certa. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Mundo 2 — Esteira".
class ConveyorGameplayScreen extends StatefulWidget {
  final ConveyorLevel level;

  const ConveyorGameplayScreen({super.key, required this.level});

  @override
  State<ConveyorGameplayScreen> createState() => _ConveyorGameplayScreenState();
}

class _ConveyorGameplayScreenState extends State<ConveyorGameplayScreen> {
  ConveyorLevel get _level => widget.level;
  late final BeltExecutor _executor = BeltExecutor(_level);
  final List<BeltBlock> _program = [];

  BeltCursor _cursor = BeltCursor.fromStart();
  bool _running = false;
  int? _currentStepBlockIndex;
  int _attempts = 0;

  /// Blocos do Programa que rodaram na última Execução — mesmo motivo de
  /// `_lastRunBlocksUsed` em `gameplay_screen.dart` (Mundo 1): capturado no
  /// início de `_run()` para não mudar se o jogador tocar num chip do "Seu
  /// Programa" depois de a Execução já ter terminado.
  int _lastRunBlocksUsed = 0;

  /// Mesmo motivo/uso de `_levelStopwatch` em `gameplay_screen.dart`
  /// (Mundo 1) — só para o Placar do Dia, nunca mostrado na UI.
  final Stopwatch _levelStopwatch = Stopwatch()..start();

  // Mesmas durações de `GameplayScreen` (Mundo 1) — mesma cadência de
  // Execução, só trocando "passo no grid" por "item classificado".
  static const _stepDuration = Duration(milliseconds: 460);
  static const _startDelay = Duration(milliseconds: 200);
  static const _resultPause = Duration(milliseconds: 500);

  /// Pausa curta quando um bloco `Enquanto` classifica zero Itens (a
  /// condição já começa falsa) — sem isso a Execução pulava direto pro
  /// próximo bloco sem nenhum sinal visual, podendo parecer que travou
  /// (achado do UX Reviewer). Mais curta que `_stepDuration` porque nada
  /// de fato acontece, só confirma "passei por aqui".
  static const _zeroMatchFlashDuration = Duration(milliseconds: 250);

  void _addBlock(BeltBlockType type) {
    if (_running || _program.length >= _level.maxBlocks) return;
    setState(() => _program.add(BeltBlock(type)));
  }

  void _removeBlockAt(int index) {
    if (_running) return;
    setState(() => _program.removeAt(index));
  }

  void _clearProgram() {
    if (_running) return;
    setState(() {
      _program.clear();
      _cursor = BeltCursor.fromStart();
      _currentStepBlockIndex = null;
    });
  }

  Future<void> _run() async {
    if (_running || _program.isEmpty) return;
    final steps = _executor.expand(_program);

    setState(() {
      _running = true;
      _currentStepBlockIndex = null;
      _cursor = BeltCursor.fromStart();
      _attempts++;
      _lastRunBlocksUsed = _program.length;
    });
    AppSounds.instance.run();

    await Future.delayed(_startDelay);

    // Itera por bloco do Programa (não direto por `steps`) para conseguir
    // detectar blocos `Enquanto` que geraram zero passos (condição já
    // começa falsa) e dar um flash curto neles — ver `_zeroMatchFlashDuration`.
    // `repeat` continua nunca sendo destacado diretamente (mesmo
    // comportamento de sempre: só o bloco alvo que ele repete acende).
    var stepCursor = 0;
    for (var blockIndex = 0; blockIndex < _program.length; blockIndex++) {
      if (!mounted) return;
      if (_program[blockIndex].type == BeltBlockType.repeat) continue;

      var producedAnyStep = false;
      while (stepCursor < steps.length && steps[stepCursor].blockIndex == blockIndex) {
        producedAnyStep = true;
        final step = steps[stepCursor];
        stepCursor++;

        final outcome = _executor.applyStep(_cursor, step.type);
        // Um som por item classificado — reaproveita `turn()` (mesmo
        // espírito de `.walk()`/`.turn()` do Mundo 1: reforço curto por
        // passo, sem criar um método novo em `AppSounds` só para isso).
        AppSounds.instance.turn();

        if (outcome.misclassified) {
          setState(() {
            _running = false;
            _currentStepBlockIndex = step.blockIndex;
          });
          await _goToResultScreen(BeltOutcome.misclassified);
          return;
        }

        setState(() {
          _cursor = outcome.cursor;
          _currentStepBlockIndex = step.blockIndex;
        });

        await Future.delayed(_stepDuration);
      }

      // Só `Enquanto` pode chegar aqui sem ter produzido nenhum passo (`Se`
      // sempre produz exatamente 1, `repeat` já foi pulado acima).
      if (!producedAnyStep) {
        if (!mounted) return;
        setState(() => _currentStepBlockIndex = blockIndex);
        await Future.delayed(_zeroMatchFlashDuration);
      }
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
          onDone: () => Navigator.of(context).popUntil((route) => route.settings.name == conveyorLevelSelectRouteName),
        ),
      ));
      return;
    }
    Navigator.of(context).popUntil((route) => route.settings.name == conveyorLevelSelectRouteName);
  }

  /// Navega direto para a tela de resultado real (Vitória ou Falha) assim
  /// que a Execução termina — mesmo comportamento de `GameplayScreen`
  /// (Mundo 1): sem modal/overlay intermediário na esteira.
  Future<void> _goToResultScreen(BeltOutcome outcome) async {
    await Future.delayed(_resultPause);
    if (!mounted) return;

    // Deixa a esteira pronta para a próxima tentativa (fila do começo) para
    // quando o jogador voltar via "Tentar de novo".
    setState(() => _cursor = BeltCursor.fromStart());

    if (outcome == BeltOutcome.win) {
      final levelsInWorld = worlds.firstWhere((w) => w.number == _level.world).levels.cast<ConveyorLevel>();
      final levelIds = levelsInWorld.map((l) => l.id);
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
              // Volta à mesma instância da Seleção de Fases do Mundo 2 já na
              // pilha (em vez de criar outra) e joga a próxima fase direto
              // na sequência, sem passar pela tela de seleção.
              Navigator.of(context).popUntil((route) => route.settings.name == conveyorLevelSelectRouteName);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConveyorGameplayScreen(level: nextLevel)));
              return;
            }
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
        builder: (_) => FailureScreen(
          levelNumber: _level.number,
          attempt: _attempts,
          reasonText: _reasonTextFor(outcome),
          maxBlocks: _level.maxBlocks,
          hintChips: hintChips,
          onBackToMenu: () => Navigator.of(context).popUntil((route) => route.settings.name == conveyorLevelSelectRouteName),
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
          // Layout sempre empilhado (celular e tablet) — diferente de
          // `GameplayScreen` (Mundo 1), que ganha um layout lado a lado em
          // tablet (ver `.claude/plans/Roadmap.md`); replicar isso aqui
          // ficou como item de bônus, não bloqueante para esta etapa.
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildBelt(),
                const SizedBox(height: 14),
                _buildProgramArea(),
              ],
            ),
          ),
        ),
      ),
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

  /// A "esteira": fila horizontal de Itens (o atual em destaque, pulsando —
  /// mesmo motivo visual do alvo pulsante do Mundo 1) sobre um painel com as
  /// duas Caixas de destino abaixo, para o jogador sempre ver pra onde cada
  /// cor deveria ir sem precisar de instrução prévia.
  Widget _buildBelt() {
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
              itemCount: _level.itemQueue.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) => Center(child: _buildItemDot(index)),
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

  /// Ícone dos 2 comandos condicionais: uma bolinha (eco do Item da
  /// esteira) + seta — reforça visualmente "isto é uma decisão baseada
  /// numa cor", em vez da seta genérica sozinha (achado do UX Reviewer).
  /// `foreground` já contrasta com o fundo colorido do botão (roxo escuro
  /// no botão amarelo, branco no botão roxo).
  Widget _conditionIcon(double size, {required Color foreground}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: size * 0.42, height: size * 0.42, decoration: BoxDecoration(shape: BoxShape.circle, color: foreground)),
        SizedBox(width: size * 0.12),
        AppIcons.arrowRight(size: size * 0.7, color: foreground),
      ],
    );
  }

  /// Mesma ideia de `_conditionIcon` (bolinha ecoando o Item da esteira),
  /// mas com o ícone de `Repetir` em vez da seta — reforça visualmente que
  /// "Enquanto" também repete, só que condicionalmente (não um número fixo
  /// como `Repetir 3×`).
  Widget _whileIcon(double size, {required Color foreground}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: size * 0.42, height: size * 0.42, decoration: BoxDecoration(shape: BoxShape.circle, color: foreground)),
        SizedBox(width: size * 0.12),
        AppIcons.repeat(size: size * 0.7, color: foreground),
      ],
    );
  }

  Widget _buildItemDot(int index) {
    final isYellow = _level.itemQueue[index] == BeltItemColor.yellow;
    final color = isYellow ? AppColors.yellowNeon : AppColors.purple;
    final isCurrent = index == _cursor.nextItemIndex;
    final isProcessed = index < _cursor.nextItemIndex;

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
        // 5 comandos no Mundo 2 (contra 4 no labirinto) — mesma grade
        // compacta de `CommandButtonGrid` do Mundo 1 (achado do usuário: a
        // árvore de `Row`s manual de antes deixava os botões grandes
        // demais, só 1-2 por linha). "Enquanto" continua diferenciado de
        // "Se" pelo `border` (ver `_whileIcon`/`.claude/docs/GAME_DESIGN.md`).
        CommandButtonGrid(
          crossAxisCount: 3,
          maxCellHeight: 100,
          buttons: [
            CommandButton(
              iconBuilder: (size) => _conditionIcon(size, foreground: AppColors.purpleDark),
              label: 'Se Amarelo → A',
              background: AppColors.yellowNeon,
              foreground: AppColors.purpleDark,
              shadowColor: AppColors.yellowShadow,
              onTap: () => _addBlock(BeltBlockType.ifYellowToBinA),
            ),
            CommandButton(
              iconBuilder: (size) => _conditionIcon(size, foreground: AppColors.white),
              label: 'Se Roxo → B',
              background: AppColors.purple,
              foreground: AppColors.white,
              shadowColor: AppColors.purpleShadow,
              onTap: () => _addBlock(BeltBlockType.ifPurpleToBinB),
            ),
            CommandButton(
              iconBuilder: (size) => _whileIcon(size, foreground: AppColors.purpleDark),
              label: 'Enquanto Amarelo → A',
              background: AppColors.yellowNeon,
              foreground: AppColors.purpleDark,
              shadowColor: AppColors.yellowShadow,
              border: Border.all(color: AppColors.purpleDark, width: 3),
              onTap: () => _addBlock(BeltBlockType.whileYellowToBinA),
            ),
            CommandButton(
              iconBuilder: (size) => _whileIcon(size, foreground: AppColors.white),
              label: 'Enquanto Roxo → B',
              background: AppColors.purple,
              foreground: AppColors.white,
              shadowColor: AppColors.purpleShadow,
              border: Border.all(color: AppColors.white, width: 3),
              onTap: () => _addBlock(BeltBlockType.whilePurpleToBinB),
            ),
            CommandButton(
              iconBuilder: (size) => AppIcons.repeat(size: size, color: AppColors.purpleDark),
              label: 'Repetir 3×',
              background: AppColors.lilac,
              foreground: AppColors.purpleDark,
              shadowColor: AppColors.lilacShadow,
              onTap: () => _addBlock(BeltBlockType.repeat),
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

  Widget _blockChip(BeltBlock block, int index) {
    final style = styleForBeltBlock(block);
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
