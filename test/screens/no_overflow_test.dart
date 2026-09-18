import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/auth/auth_providers.dart';
import 'package:debuga_o_mascote/core/leaderboard/leaderboard_providers.dart';
import 'package:debuga_o_mascote/features/block_program/presentation/gameplay/block_program_gameplay_view.dart';
import 'package:debuga_o_mascote/features/block_program/presentation/stage_select/stage_select_view.dart';
import 'package:debuga_o_mascote/features/code_puzzle/presentation/gameplay/code_puzzle_gameplay_view.dart';
import 'package:debuga_o_mascote/features/code_puzzle/presentation/stage_select/stage_select_view.dart';
import 'package:debuga_o_mascote/features/complete_code/presentation/gameplay/complete_code_gameplay_view.dart';
import 'package:debuga_o_mascote/features/complete_code/presentation/stage_select/stage_select_view.dart';
import 'package:debuga_o_mascote/features/maze/presentation/gameplay/gameplay_view.dart';
import 'package:debuga_o_mascote/features/maze/presentation/stage_select/stage_select_view.dart';
import 'package:debuga_o_mascote/features/predict_output/presentation/gameplay/predict_output_gameplay_view.dart';
import 'package:debuga_o_mascote/features/predict_output/presentation/stage_select/stage_select_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/code_puzzle_result_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/failure_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/victory_view.dart';
import 'package:debuga_o_mascote/models/block_program_level.dart';
import 'package:debuga_o_mascote/models/code_puzzle_level.dart';
import 'package:debuga_o_mascote/models/complete_code_level.dart';
import 'package:debuga_o_mascote/models/level.dart';
import 'package:debuga_o_mascote/models/predict_output_level.dart';
import 'package:debuga_o_mascote/features/leaderboard/presentation/leaderboard_view.dart';
import 'package:debuga_o_mascote/features/auth/presentation/register/register_view.dart';
import 'package:debuga_o_mascote/features/settings/presentation/profile_edit_view.dart';
import 'package:debuga_o_mascote/features/settings/presentation/settings_view.dart';
import 'package:debuga_o_mascote/features/splash/presentation/splash_view.dart';
import 'package:debuga_o_mascote/features/survey/presentation/survey_view.dart';
import 'package:debuga_o_mascote/features/tutorial/presentation/tutorial_view.dart';
import 'package:debuga_o_mascote/features/welcome/presentation/welcome_view.dart';
import 'package:debuga_o_mascote/features/world_select/presentation/world_select_view.dart';
import 'package:debuga_o_mascote/theme/app_colors.dart';
import 'package:debuga_o_mascote/widgets/block_chip_style.dart';
import 'package:debuga_o_mascote/widgets/primary_pill_button_widget.dart';
import 'package:debuga_o_mascote/widgets/program_block_chip_widget.dart';
import 'package:debuga_o_mascote/widgets/tutorial_content.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_leaderboard_repository.dart';
import '../helpers/test_container.dart';

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
    'Splash': const SplashView(),
    'Boas-vindas': const WelcomeView(),
    'Seleção de Mundo': const WorldSelectView(),
    'Seleção de Fases': StageSelectView(world: worlds.first),
    'Gameplay': GameplayView(levelId: demoLevel.id),
    'Vitória': VictoryView(
      levelNumber: demoLevel.number,
      blocksUsed: demoLevel.optimalBlocks,
      maxBlocks: demoLevel.maxBlocks,
      optimalBlocks: demoLevel.optimalBlocks,
      hasNext: true,
      onPrimaryAction: () {},
    ),
    'Tentativa Falha': FailureView(
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
    'Seleção de Fases (Encruzilhada Colorida)': StageSelectView(world: worlds[1]),
    'Gameplay (Encruzilhada Colorida)': GameplayView(levelId: world2Levels.first.id),
    'Seleção de Fases (Caça-Moedas)': StageSelectView(world: worlds[2]),
    'Gameplay (Caça-Moedas)': GameplayView(levelId: world3Levels.first.id),
    'Seleção de Fases (Decisões em Bloco)': BlockProgramStageSelectView(world: worlds[3]),
    'Gameplay (Decisões em Bloco)': BlockProgramGameplayView(levelId: world4Levels.first.id),
    'Seleção de Fases (Preveja a Saída)': PredictOutputStageSelectView(world: worlds[4]),
    'Gameplay (Preveja a Saída)': PredictOutputGameplayView(levelId: world5Levels.first.id),
    'Seleção de Fases (Complete o Código)': CompleteCodeStageSelectView(world: worlds[5]),
    'Gameplay (Complete o Código)': CompleteCodeGameplayView(levelId: world6Levels.first.id),
    'Seleção de Fases (Modo Debug)': CodePuzzleStageSelectView(world: worlds[6]),
    'Gameplay (Modo Debug, reorder)': CodePuzzleGameplayView(levelId: world7Levels.first.id),
    'Gameplay (Modo Debug, findBug)': CodePuzzleGameplayView(levelId: world7Levels.firstWhere((l) => l.type == CodePuzzleType.findBug).id),
    'Resultado (veredito único, vitória)': CodePuzzleResultView(
      won: true,
      levelNumber: world7Levels.first.number,
      attempts: 1,
      stars: 3,
      points: 1000,
      hasNext: true,
      onPrimaryAction: () {},
      onBackToMenu: () {},
    ),
    'Resultado (veredito único, derrota)': CodePuzzleResultView(
      won: false,
      levelNumber: world7Levels.first.number,
      attempts: 1,
      stars: 0,
      points: 0,
      correctOrderChips: [
        for (final line in world7Levels.first.correctOrder)
          ProgramBlockChip(label: line.text, background: AppColors.lilac, foreground: AppColors.purpleDark),
      ],
      hasNext: false,
      onPrimaryAction: () {},
      onBackToMenu: () {},
    ),
    'Placar do Dia': const LeaderboardView(),
    'Pesquisa': const SurveyView(),
    'Cadastro (voluntário)': RegisterView(mandatory: false, onDone: () {}),
    'Cadastro (obrigatório)': RegisterView(mandatory: true, onDone: () {}),
    'Configurações': const SettingsView(),
    'Editar Perfil': const ProfileEditView(),
  };

  for (final sizeEntry in sizes.entries) {
    for (final screenEntry in screens.entries) {
      testWidgets('${screenEntry.key} não estoura em ${sizeEntry.key}', (tester) async {
        final container = createTestContainer(overrides: [
          leaderboardRepositoryProvider.overrideWithValue(FakeLeaderboardRepository()),
          authServiceProvider.overrideWithValue(FakeAuthService()),
        ]);
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrapForTest(container, screenEntry.value));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    }
  }

  // `Splash` acima só pumpa 500ms — tempo insuficiente pra `_stageTimer`
  // (3s) trocar o palco central sequer uma vez, então aquele teste sozinho
  // só cobre o slide inicial (Mascote). Varre os 7 slides de verdade
  // (Mascote + 7 ícones de Mundo — `_stageCount` em `splash_view.dart`; o
  // título não faz mais parte do revezamento, ver `.claude/memory/decisions.md`)
  // em cada tamanho de tela, avançando o relógio falso do teste em vez de
  // esperar tempo real. Mesmo cuidado já aplicado às 12 fases do Mundo 7 e
  // aos slides do Tutorial — sem isso, um estouro só no slide de um ícone
  // específico passaria despercebido.
  for (final sizeEntry in sizes.entries) {
    testWidgets('Splash — todos os slides do palco central não estouram em ${sizeEntry.key}', (tester) async {
      final container = createTestContainer(overrides: [
        leaderboardRepositoryProvider.overrideWithValue(FakeLeaderboardRepository()),
        authServiceProvider.overrideWithValue(FakeAuthService()),
      ]);
      await tester.binding.setSurfaceSize(sizeEntry.value);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapForTest(container, const SplashView()));
      await tester.pump();

      for (var i = 0; i < 7; i++) {
        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(milliseconds: 600)); // transição do fade
        expect(tester.takeException(), isNull, reason: 'slide $i');
      }
    });
  }

  // A varredura genérica de `tutorialSlides` acima usa `TutorialView` pura,
  // sem `finalActionsBuilder` — não cobre o layout real do último slide de
  // `WelcomeView` (3 escolhas de conta lado a lado + link "Jogar sem
  // conta"). Avança de verdade pelos 3 slides pra chegar lá.
  for (final sizeEntry in sizes.entries) {
    testWidgets('Boas-vindas — escolhas de conta do último slide não estouram em ${sizeEntry.key}', (tester) async {
      final container = createTestContainer(overrides: [
        leaderboardRepositoryProvider.overrideWithValue(FakeLeaderboardRepository()),
        authServiceProvider.overrideWithValue(FakeAuthService()),
      ]);
      await tester.binding.setSurfaceSize(sizeEntry.value);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapForTest(container, const WelcomeView()));
      await tester.pump();

      for (var i = 0; i < welcomeSlides.length; i++) {
        await tester.tap(find.byType(PrimaryPillButton)); // revela o slide inteiro
        await tester.pump();
        if (i < welcomeSlides.length - 1) {
          await tester.tap(find.byType(PrimaryPillButton)); // avança
          await tester.pump();
        }
      }

      expect(tester.takeException(), isNull);
    });
  }

  // `Gameplay (Modo Debug, reorder/findBug)` acima só testa 2 das 12 fases
  // de `world7Levels` (a mais curta de cada tipo) — o Code Reviewer achou
  // (rodando um teste temporário) que 4 fases com linhas de código mais
  // longas ("for (int i = 0; i < 3; i++) {", "List<int> numeros = [1, 2, 3];"
  // etc.) estouravam `ProgramBlockChip` em celular, sem nenhum teste
  // cobrindo isso — corrigido em `lib/widgets/program_block_chip_widget.dart`.
  // Varre as 12 fases de verdade para não repetir esse ponto cego. Os
  // Mundos 2/3 ("Encruzilhada Colorida"/"Caça-Moedas", `maze`) e o Mundo 4
  // ("Decisões em Bloco", `blockProgram`) ganham a mesma varredura logo
  // abaixo.
  for (final sizeEntry in sizes.entries) {
    for (final level in world2Levels) {
      testWidgets('Gameplay (Encruzilhada Colorida) ${level.id} não estoura em ${sizeEntry.key}', (tester) async {
        final container = createTestContainer();
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrapForTest(container, GameplayView(levelId: level.id)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    }

    for (final level in world3Levels) {
      testWidgets('Gameplay (Caça-Moedas) ${level.id} não estoura em ${sizeEntry.key}', (tester) async {
        final container = createTestContainer();
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrapForTest(container, GameplayView(levelId: level.id)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    }

    for (final level in world4Levels) {
      testWidgets('Gameplay (Decisões em Bloco) ${level.id} não estoura em ${sizeEntry.key}', (tester) async {
        final container = createTestContainer();
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrapForTest(container, BlockProgramGameplayView(levelId: level.id)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    }

    for (final level in world7Levels) {
      testWidgets('Gameplay (Modo Debug) ${level.id} não estoura em ${sizeEntry.key}', (tester) async {
        final container = createTestContainer();
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrapForTest(container, CodePuzzleGameplayView(levelId: level.id)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    }

    for (final level in world5Levels) {
      testWidgets('Gameplay (Preveja a Saída) ${level.id} não estoura em ${sizeEntry.key}', (tester) async {
        final container = createTestContainer();
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrapForTest(container, PredictOutputGameplayView(levelId: level.id)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    }

    for (final level in world6Levels) {
      testWidgets('Gameplay (Complete o Código) ${level.id} não estoura em ${sizeEntry.key}', (tester) async {
        final container = createTestContainer();
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrapForTest(container, CompleteCodeGameplayView(levelId: level.id)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      });
    }
  }

  // Varre cada slide individual da `TutorialView` (conceito geral +
  // cada Mundo) isolado (`slides: [slide]`) — títulos/corpos variam bastante
  // de tamanho entre eles, e o texto ainda pode estar "digitando" quando o
  // slide troca (ver `_TypewriterText`), então checar só o 1º slide de cada
  // fluxo (como os outros mapas de tela acima fazem) deixaria os demais sem
  // cobertura nenhuma.
  final tutorialSlides = <String, TutorialSlide>{
    for (var i = 0; i < welcomeSlides.length; i++) 'welcome_$i': welcomeSlides[i],
    for (final entry in worldTutorials.entries)
      for (var i = 0; i < entry.value.length; i++) 'world${entry.key}_$i': entry.value[i],
    for (final entry in worldRecapSlides.entries)
      for (var i = 0; i < entry.value.length; i++) 'recap${entry.key}_$i': entry.value[i],
  };

  for (final sizeEntry in sizes.entries) {
    for (final slideEntry in tutorialSlides.entries) {
      testWidgets('TutorialView (${slideEntry.key}) não estoura em ${sizeEntry.key}', (tester) async {
        final container = createTestContainer();
        await tester.binding.setSurfaceSize(sizeEntry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrapForTest(
          container,
          TutorialView(slides: [slideEntry.value], narrationAssets: const [], onFinish: () {}),
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
