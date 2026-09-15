import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_auth.dart';
import '../data/progress_sync.dart';
import '../game/code_puzzle_checker.dart';
import '../game/code_puzzle_scoring.dart';
import '../game/leaderboard_scoring.dart';
import '../models/code_puzzle_level.dart';
import '../models/game_track.dart';
import '../models/level.dart';
import '../models/onboarding.dart';
import '../models/progress.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/gameplay_header_widget.dart';
import '../widgets/primary_pill_button_widget.dart';
import '../widgets/program_block_chip_widget.dart';
import '../widgets/tutorial_content.dart';
import 'code_puzzle_result_screen.dart';
import 'code_puzzle_stage_select_screen.dart';
import 'register_screen.dart';
import 'tutorial_screen.dart';

/// Palavras-chave destacadas na sintaxe simples de `findBug` — sem parser
/// real, um regex de palavras inteiras já basta (ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Mundo 3 — Modo Debug").
final _keywordPattern = RegExp(r'\b(if|else|for|while|return|int|bool|List|void)\b');

/// Gameplay do Mundo 3 ("Modo Debug") — alterna o conteúdo central pelo
/// `CodePuzzleType` da fase: `reorder` (montar a sequência certa tocando
/// linhas embaralhadas, mesmo padrão de tap-para-montar dos outros mundos)
/// ou `findBug` (tocar a linha com o erro). Sem execução passo a passo —
/// cada "Confirmar" é um veredito único, ver
/// `lib/game/code_puzzle_checker.dart`.
class CodePuzzleGameplayScreen extends StatefulWidget {
  final CodePuzzleLevel level;

  const CodePuzzleGameplayScreen({super.key, required this.level});

  @override
  State<CodePuzzleGameplayScreen> createState() => _CodePuzzleGameplayScreenState();
}

class _CodePuzzleGameplayScreenState extends State<CodePuzzleGameplayScreen> {
  CodePuzzleLevel get _level => widget.level;

  /// Tentativas já confirmadas nesta fase — começa em 0; o cabeçalho mostra
  /// sempre `_attempts + 1` ("Tentativa 1", nunca "Tentativa 0"), a que
  /// está prestes a rodar.
  int _attempts = 0;

  /// `correctOrder` embaralhado uma única vez por fase, com seed fixa a
  /// partir do `id` (não re-embaralha a cada rebuild) — estado só desta
  /// tela; o modelo (`CodePuzzleLevel`) nunca guarda uma ordem embaralhada
  /// fixa, ver `lib/models/code_puzzle_level.dart`. Vazio em fases
  /// `findBug`.
  late final List<CodeLine> _shuffledLines = List<CodeLine>.of(_level.correctOrder)..shuffle(Random(_level.id.hashCode));

  /// Índices (em `_shuffledLines`) já tocados para montar a sequência, na
  /// ordem em que o jogador tocou — só usado em fases `reorder`. Tocar um
  /// chip do "banco" adiciona seu índice aqui; tocar um chip já adicionado
  /// remove — mesmo padrão de `GameplayScreen._addBlock`/`_removeBlockAt`.
  final List<int> _sequenceIndices = [];

  /// Linha tocada como "essa é a errada" — só usado em fases `findBug`.
  int? _selectedLineIndex;

  /// Mesmo motivo/uso de `_levelStopwatch` em `gameplay_screen.dart`
  /// (Mundo 1) — só para o Placar do Dia, nunca mostrado na UI.
  final Stopwatch _levelStopwatch = Stopwatch()..start();

  bool get _canConfirm {
    switch (_level.type) {
      case CodePuzzleType.reorder:
        return _sequenceIndices.length == _level.correctOrder.length;
      case CodePuzzleType.findBug:
        return _selectedLineIndex != null;
    }
  }

  void _addToSequence(int shuffledIndex) {
    if (_sequenceIndices.contains(shuffledIndex)) return;
    setState(() => _sequenceIndices.add(shuffledIndex));
  }

  void _removeFromSequence(int shuffledIndex) {
    setState(() => _sequenceIndices.remove(shuffledIndex));
  }

  void _selectLine(int index) => setState(() => _selectedLineIndex = index);

  bool _checkWon() {
    switch (_level.type) {
      case CodePuzzleType.reorder:
        final attempt = [for (final i in _sequenceIndices) _shuffledLines[i]];
        return checkReorder(attempt, _level.correctOrder);
      case CodePuzzleType.findBug:
        return checkFindBug(_selectedLineIndex!, _level.buggyLineIndex);
    }
  }

  void _confirm() {
    if (!_canConfirm) return;

    final won = _checkWon();
    setState(() => _attempts++);
    _goToResultScreen(won);
  }

  /// Volta pra Seleção de Fases — a menos que o Mundo que acabou de fechar
  /// agora seja o último da Trilha 1 e o jogador ainda não tenha conta, caso
  /// em que empurra `RegisterScreen` primeiro (gate de fim de Trilha, ver
  /// `.claude/memory/decisions.md`). Hoje é o único dos 3 Gameplay screens
  /// onde esse gate realmente entra em jogo (Mundo 3 é o último da Trilha
  /// 1). Sempre tem uma saída (link "Continuar sem conta por enquanto"
  /// dentro da própria tela) — nunca trava o app se o Firebase estiver
  /// indisponível.
  void _returnToLevelSelect(BuildContext context, bool worldJustCompleted) {
    final isEndOfTrack1 = worldJustCompleted && _level.world == tracks.first.worlds.last.number;
    if (isEndOfTrack1 && !AppAuth.instance.hasAccount) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RegisterScreen(
          mandatory: true,
          onDone: () => Navigator.of(context).popUntil((route) => route.settings.name == codePuzzleStageSelectRouteName),
        ),
      ));
      return;
    }
    Navigator.of(context).popUntil((route) => route.settings.name == codePuzzleStageSelectRouteName);
  }

  Future<void> _goToResultScreen(bool won) async {
    final isReorder = _level.type == CodePuzzleType.reorder;

    var stars = 0;
    var points = 0;
    var worldJustCompleted = false;
    if (won) {
      final levelIdsInWorld = worlds.firstWhere((w) => w.number == _level.world).levels.map((l) => l.id);
      final wasWorldCompleteBefore = Progress.instance.isWorldCompleted(levelIdsInWorld);
      final isFirstWin = !Progress.instance.isCompleted(_level.id);

      final score = computeCodePuzzleScore(attempts: _attempts);
      stars = score.stars;
      points = score.points;
      // `blocksUsed` aqui guarda Tentativas, não blocos — o Mundo 3 não tem
      // conceito de "blocos" (motor de veredito único). Reaproveita a API
      // existente de `Progress.recordWin` em vez de criar um parâmetro novo
      // só para este mundo — ver `.claude/memory/decisions.md`, entrada
      // "Motor do Mundo 3".
      Progress.instance.recordWin(_level.id, stars: stars, blocksUsed: _attempts);
      if (isFirstWin) {
        Progress.instance.addSessionPoints(
          computeSessionPoints(worldNumber: _level.world, elapsedSeconds: _levelStopwatch.elapsed.inSeconds),
        );
      }
      worldJustCompleted = !wasWorldCompleteBefore && Progress.instance.isWorldCompleted(levelIdsInWorld);
      ProgressSync.instance.syncNow();
    }

    // Em findBug a explicação é mostrada sempre (ganhou ou perdeu); em
    // reorder não existe (o "porquê" é a própria ordem certa, mostrada só
    // na Dica quando o jogador erra).
    final explanationText = isReorder ? null : _level.bugExplanation;
    final correctOrderChips = (!won && isReorder)
        ? [
            for (final line in _level.correctOrder)
              ProgramBlockChip(label: line.text, background: AppColors.lilac, foreground: AppColors.purpleDark),
          ]
        : null;

    // `List<CodePuzzleLevel>` — `CodePuzzleStageSelectScreen` só é aberta
    // com um Mundo 3 (ver `WorldSelectScreen._openWorld`), então este
    // `CodePuzzleGameplayScreen` só recebe fases de um mundo `codePuzzle`.
    final levelsInWorld = worlds.firstWhere((w) => w.number == _level.world).levels.cast<CodePuzzleLevel>();
    final levelIndex = levelsInWorld.indexWhere((l) => l.id == _level.id);
    final nextLevel = (levelIndex >= 0 && levelIndex + 1 < levelsInWorld.length) ? levelsInWorld[levelIndex + 1] : null;

    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CodePuzzleResultScreen(
        won: won,
        levelNumber: _level.number,
        attempts: _attempts,
        stars: stars,
        points: points,
        explanationText: explanationText,
        correctOrderChips: correctOrderChips,
        hasNext: nextLevel != null,
        onPrimaryAction: () {
          if (nextLevel != null) {
            // Volta à mesma instância da Seleção de Fases do Mundo 3 já na
            // pilha (em vez de criar outra) e joga a próxima fase direto na
            // sequência, sem passar pela tela de seleção.
            Navigator.of(context).popUntil((route) => route.settings.name == codePuzzleStageSelectRouteName);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => CodePuzzleGameplayScreen(level: nextLevel)));
            return;
          }
          if (worldJustCompleted && !Onboarding.instance.hasSeenRecap(_level.world)) {
            final recap = recapSlidesFor(_level.world);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TutorialScreen(
                slides: recap.slides,
                narrationAssets: recap.narrationAssets,
                finalLabel: 'Concluir',
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
        onBackToMenu: () => Navigator.of(context).popUntil((route) => route.settings.name == codePuzzleStageSelectRouteName),
      ),
    ));

    // "Tentar de novo" (derrota) só faz `pop()` — volta pra esta mesma
    // instância. Sem isso, a linha/sequência da tentativa errada continuava
    // montada, e `_canConfirm` já voltava `true` de cara: o jogador podia
    // apertar Confirmar de novo sem perceber que precisava mudar a resposta
    // (achado do UX Reviewer). Não limpa em caso de vitória — a tela nem
    // volta pra cá nesse caso (navega pra próxima fase/Seleção de Fases).
    if (!won && mounted) {
      setState(() {
        _selectedLineIndex = null;
        _sequenceIndices.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          // Layout sempre empilhado (celular e tablet) — mesmo bônus não
          // aplicado do Mundo 2 (ver `.claude/plans/Roadmap.md`): não
          // bloqueante, a tela não estoura em tablet, só não aproveita a
          // largura extra com um layout lado a lado.
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildContent(),
                const SizedBox(height: 14),
                PrimaryPillButton(
                  label: 'Confirmar',
                  height: 64,
                  fontSize: 24,
                  enabled: _canConfirm,
                  onTap: _confirm,
                ),
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
      trailingChipText: 'Tentativa ${_attempts + 1}',
      onBack: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildContent() {
    switch (_level.type) {
      case CodePuzzleType.reorder:
        return _buildReorderContent();
      case CodePuzzleType.findBug:
        return _buildFindBugContent();
    }
  }

  Widget _buildReorderContent() {
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
          child: _sequenceIndices.isEmpty
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
                    for (final i in _sequenceIndices)
                      ProgramBlockChip(
                        label: _shuffledLines[i].text,
                        background: AppColors.purple,
                        foreground: AppColors.white,
                        onTap: () => _removeFromSequence(i),
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
            for (var i = 0; i < _shuffledLines.length; i++)
              if (!_sequenceIndices.contains(i))
                ProgramBlockChip(
                  label: _shuffledLines[i].text,
                  background: AppColors.lilac,
                  foreground: AppColors.purpleDark,
                  onTap: () => _addToSequence(i),
                ),
          ],
        ),
      ],
    );
  }

  Widget _buildFindBugContent() {
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
          for (var i = 0; i < _level.codeWithBug.length; i++) _buildFindBugLine(i, _level.codeWithBug[i]),
        ],
      ),
    );
  }

  Widget _buildFindBugLine(int index, CodeLine line) {
    final selected = _selectedLineIndex == index;
    return GestureDetector(
      // `key` só para os testes de tela conseguirem tocar uma linha
      // específica — o texto em si é um `RichText`/`TextSpan` (destaque de
      // sintaxe), que `find.text` não localiza.
      key: Key('codePuzzleLine_$index'),
      onTap: () => _selectLine(index),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? AppColors.purple.withValues(alpha: 0.35) : Colors.transparent,
          border: selected ? Border.all(color: AppColors.yellowNeon, width: 2) : null,
        ),
        child: RichText(text: TextSpan(children: _highlightLine(line.text))),
      ),
    );
  }

  /// Destaque de sintaxe simples: só 2 cores fixas de `AppColors` — sem
  /// pacote novo, sem parser real, um regex de palavras-chave já basta (ver
  /// `.claude/docs/GAME_DESIGN.md`).
  List<TextSpan> _highlightLine(String text) {
    final spans = <TextSpan>[];
    var lastEnd = 0;
    for (final match in _keywordPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: AppText.style(size: 15, weight: FontWeight.w800, color: AppColors.white),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: AppText.style(size: 15, weight: FontWeight.w900, color: AppColors.lilac),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: AppText.style(size: 15, weight: FontWeight.w800, color: AppColors.white),
      ));
    }
    return spans;
  }
}
