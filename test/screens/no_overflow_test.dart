import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/audio/app_sounds.dart';
import 'package:debuga_o_mascote/data/app_auth.dart';
import 'package:debuga_o_mascote/data/leaderboard.dart';
import 'package:debuga_o_mascote/models/code_puzzle_level.dart';
import 'package:debuga_o_mascote/models/conveyor_level.dart';
import 'package:debuga_o_mascote/models/level.dart';
import 'package:debuga_o_mascote/screens/code_puzzle_gameplay_screen.dart';
import 'package:debuga_o_mascote/screens/code_puzzle_result_screen.dart';
import 'package:debuga_o_mascote/screens/code_puzzle_stage_select_screen.dart';
import 'package:debuga_o_mascote/screens/conveyor_gameplay_screen.dart';
import 'package:debuga_o_mascote/screens/conveyor_stage_select_screen.dart';
import 'package:debuga_o_mascote/screens/failure_screen.dart';
import 'package:debuga_o_mascote/screens/gameplay_screen.dart';
import 'package:debuga_o_mascote/screens/leaderboard_screen.dart';
import 'package:debuga_o_mascote/screens/level_select_screen.dart';
import 'package:debuga_o_mascote/screens/register_screen.dart';
import 'package:debuga_o_mascote/screens/splash_screen.dart';
import 'package:debuga_o_mascote/screens/survey_screen.dart';
import 'package:debuga_o_mascote/screens/tutorial_screen.dart';
import 'package:debuga_o_mascote/screens/victory_screen.dart';
import 'package:debuga_o_mascote/screens/world_select_screen.dart';
import 'package:debuga_o_mascote/theme/app_colors.dart';
import 'package:debuga_o_mascote/widgets/block_chip_style.dart';
import 'package:debuga_o_mascote/widgets/program_block_chip_widget.dart';
import 'package:debuga_o_mascote/widgets/tutorial_content.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_leaderboard_repository.dart';
import '../helpers/fake_sound_player.dart';

/// Garante que nenhuma tela estoura (RenderFlex overflow) no menor
/// aparelho comum (iPhone SE, 320x568 lógicos) nem num tablet grande —
/// os dois extremos de tamanho que o jogo precisa suportar (celular e
/// tablet, ver `.claude/docs/GAME_DESIGN.md`).
void main() {
  const sizes = {
    'celular pequeno (320x568)': Size(320, 568),
    'celular grande (430x932)': Size(430, 932),
    'tablet (1024x768)': Size(1024, 768),
  };

  final screens = {
    'Splash': const SplashScreen(),
    'Seleção de Mundo': const WorldSelectScreen(),
    'Seleção de Fases': LevelSelectScreen(world: worlds.first),
    'Gameplay': GameplayScreen(level: demoLevel),
    'Vitória': VictoryScreen(
      levelNumber: demoLevel.number,
      blocksUsed: demoLevel.optimalBlocks,
      maxBlocks: demoLevel.maxBlocks,
      optimalBlocks: demoLevel.optimalBlocks,
      hasNext: true,
      onPrimaryAction: () {},
    ),
    'Tentativa Falha': FailureScreen(
      levelNumber: demoLevel.number,
      attempt: 2,
      reasonText: 'O mascote bateu na parede (ou saiu do tabuleiro) antes de chegar no alvo.',
      maxBlocks: demoLevel.maxBlocks,
      hintChips: [
        for (final block in demoLevel.hintProgram)
          Builder(builder: (context) {
            final style = styleForBlock(block);
            return ProgramBlockChip(label: style.label, background: style.background, foreground: style.foreground, repeatCount: style.repeatCount);
          }),
      ],
      onBackToMenu: () {},
    ),
    'Seleção de Fases (Esteira)': ConveyorStageSelectScreen(world: worlds[1]),
    'Gameplay (Esteira)': ConveyorGameplayScreen(level: world2Levels.first),
    'Seleção de Fases (Modo Debug)': CodePuzzleStageSelectScreen(world: worlds[2]),
    'Gameplay (Modo Debug, reorder)': CodePuzzleGameplayScreen(level: world3Levels.first),
    'Gameplay (Modo Debug, findBug)': CodePuzzleGameplayScreen(level: world3Levels.firstWhere((l) => l.type == CodePuzzleType.findBug)),
    'Resultado (Modo Debug, vitória)': CodePuzzleResultScreen(
      won: true,
      levelNumber: world3Levels.first.number,
      attempts: 1,
      stars: 3,
      points: 1000,
      hasNext: true,
      onPrimaryAction: () {},
      onBackToMenu: () {},
    ),
    'Resultado (Modo Debug, derrota)': CodePuzzleResultScreen(
      won: false,
      levelNumber: world3Levels.first.number,
      attempts: 1,
      stars: 0,
      points: 0,
      correctOrderChips: [
        for (final line in world3Levels.first.correctOrder)
          ProgramBlockChip(label: line.text, background: AppColors.lilac, foreground: AppColors.purpleDark),
      ],
      hasNext: false,
      onPrimaryAction: () {},
      onBackToMenu: () {},
    ),
    'Placar do Dia': const LeaderboardScreen(),
    'Pesquisa': const SurveyScreen(),
    'Cadastro (voluntário)': RegisterScreen(mandatory: false, onDone: () {}),
    'Cadastro (obrigatório)': RegisterScreen(mandatory: true, onDone: () {}),
  };

  for (final sizeEntry in sizes.entries) {
    for (final screenEntry in screens.entries) {
      testWidgets('${screenEntry.key} não estoura em ${sizeEntry.key}', (tester) async {
        AppSounds.instance.player = FakeSoundPlayer();
        addTearDown(() => AppSounds.instance.resetForTest());
        Leaderboard.instance.repository = FakeLeaderboardRepository();
        addTearDown(() => Leaderboard.instance.resetForTest());
        AppAuth.instance.service = FakeAuthService();
        addTearDown(() => AppAuth.instance.resetForTest());
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(MaterialApp(home: screenEntry.value));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    }
  }

  // `Gameplay (Modo Debug, reorder/findBug)` acima só testa 2 das 12 fases
  // de `world3Levels` (a mais curta de cada tipo) — o Code Reviewer achou
  // (rodando um teste temporário) que 4 fases com linhas de código mais
  // longas ("for (int i = 0; i < 3; i++) {", "List<int> numeros = [1, 2, 3];"
  // etc.) estouravam `ProgramBlockChip` em celular, sem nenhum teste
  // cobrindo isso — corrigido em `lib/widgets/program_block_chip_widget.dart`.
  // Varre as 12 fases de verdade para não repetir esse ponto cego.
  for (final sizeEntry in sizes.entries) {
    for (final level in world3Levels) {
      testWidgets('Gameplay (Modo Debug) ${level.id} não estoura em ${sizeEntry.key}', (tester) async {
        AppSounds.instance.player = FakeSoundPlayer();
        addTearDown(() => AppSounds.instance.resetForTest());
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(MaterialApp(home: CodePuzzleGameplayScreen(level: level)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    }
  }

  // Varre cada slide individual da `TutorialScreen` (conceito geral +
  // cada Mundo) isolado (`slides: [slide]`) — títulos/corpos variam bastante
  // de tamanho entre eles, e o texto ainda pode estar "digitando" quando o
  // slide troca (ver `_TypewriterText`), então checar só o 1º slide de cada
  // fluxo (como os outros mapas de tela acima fazem) deixaria os demais sem
  // cobertura nenhuma.
  final tutorialSlides = <String, TutorialSlide>{
    for (var i = 0; i < programmingConceptSlides.length; i++) 'intro_$i': programmingConceptSlides[i],
    for (final entry in worldTutorials.entries)
      for (var i = 0; i < entry.value.length; i++) 'world${entry.key}_$i': entry.value[i],
    for (final entry in worldRecapSlides.entries)
      for (var i = 0; i < entry.value.length; i++) 'recap${entry.key}_$i': entry.value[i],
  };

  for (final sizeEntry in sizes.entries) {
    for (final slideEntry in tutorialSlides.entries) {
      testWidgets('TutorialScreen (${slideEntry.key}) não estoura em ${sizeEntry.key}', (tester) async {
        AppSounds.instance.player = FakeSoundPlayer();
        addTearDown(() => AppSounds.instance.resetForTest());
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(MaterialApp(
          home: TutorialScreen(slides: [slideEntry.value], narrationAssets: const [], onFinish: () {}),
        ));
        await tester.pump();
        // Texto completo revelado na hora (sem esperar a máquina de
        // escrever) — é o pior caso de largura/altura pra estourar.
        await tester.pump(const Duration(seconds: 5));

        expect(tester.takeException(), isNull);
      });
    }
  }
}
