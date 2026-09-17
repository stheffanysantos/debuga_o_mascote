import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/onboarding/onboarding_notifier.dart';
import 'package:debuga_o_mascote/core/progress/progress_notifier.dart';
import 'package:debuga_o_mascote/features/maze/presentation/stage_select/stage_select_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/victory_view.dart';
import 'package:debuga_o_mascote/models/level.dart';
import 'package:debuga_o_mascote/features/tutorial/presentation/tutorial_view.dart';
import 'package:debuga_o_mascote/features/world_select/presentation/world_select_view.dart';
import 'package:debuga_o_mascote/widgets/command_button_widget.dart';
import 'package:debuga_o_mascote/widgets/icon_action_button_widget.dart';
import 'package:debuga_o_mascote/widgets/primary_pill_button_widget.dart';
import 'package:debuga_o_mascote/widgets/tutorial_content.dart';

import '../helpers/test_container.dart';

/// Fluxo da `TutorialView` (`lib/screens/tutorial_screen.dart`, tela cheia
/// paginada — substituiu o antigo `TutorialModal`, ver
/// `.claude/memory/decisions.md`) — ver `.claude/docs/NAVIGATION_FLOW.md` e
/// `OnboardingNotifier` (`lib/core/onboarding/onboarding_notifier.dart`).
/// Mesmo estilo de interação real usado em `test/screens/gameplay_flow_test.dart`
/// — sem mock, exceto o `soundPlayerProvider` (narração/SFX reais não têm
/// mock de `MethodChannel` configurado em `test/`, ver `test_container.dart`).
///
/// O botão primário ("Próximo"/"Jogar") sempre exige 2 toques por slide: o
/// 1º revela o texto inteiro na hora (o slide chega com 0 caracteres
/// visíveis, efeito de máquina de escrever — ver `_TypewriterText`), o 2º
/// avança de verdade. `_tapPrimary` faz um toque só; os testes chamam duas
/// vezes por slide quando precisam avançar de verdade.
void main() {
  Future<ProviderContainer> pumpWorldSelect(WidgetTester tester, {List<Override> overrides = const []}) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = createTestContainer(overrides: overrides);
    await tester.pumpWidget(wrapForTest(container, const WorldSelectView()));
    await tester.pump();
    return container;
  }

  Future<void> tapWorldNode(WidgetTester tester, GameWorld world) async {
    final node = find.text('MUNDO ${world.number} / ${world.name.toUpperCase()}');
    await tester.ensureVisible(node);
    await tester.pump();
    await tester.tap(node);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tapPrimary(WidgetTester tester) async {
    await tester.tap(find.byType(PrimaryPillButton));
    await tester.pump();
  }

  // Sair da `TutorialView` (pop + push do destino) usa a transição padrão
  // de página do Material 3 (`_FadeForwardsPageTransition`), que não termina
  // dentro de 300ms — não usar `pumpAndSettle` (há `PulseTap` em loop
  // infinito nas telas de destino, ver `.claude/rules/testing.md`), então
  // pumpa em pedaços até a transição terminar de verdade.
  Future<void> pumpTransition(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('tocar um Mundo jogável pela 1ª vez mostra a TutorialView com as regras do mundo', (tester) async {
    await pumpWorldSelect(tester);

    await tapWorldNode(tester, worlds.first);

    expect(find.byType(TutorialView), findsOneWidget);
    expect(find.text(worldTutorials[1]!.first.title!), findsOneWidget);
    expect(find.byType(StageSelectView), findsNothing);
  });

  testWidgets('1º toque no botão primário revela o texto inteiro na hora; só o 2º avança de slide', (tester) async {
    await pumpWorldSelect(tester);
    await tapWorldNode(tester, worlds.first);

    final slides = worldTutorials[1]!;
    // Slide 0 acabou de chegar — texto ainda "digitando" (0 caracteres).
    expect(find.text(slides[0].body), findsNothing);

    await tapPrimary(tester); // revela o slide 0 inteiro
    expect(find.text(slides[0].body), findsOneWidget);
    expect(find.text(slides.first.title!), findsOneWidget); // ainda no mesmo slide

    await tapPrimary(tester); // avança pro slide 1
    expect(find.text(slides.first.title!), findsNothing);

    await tapPrimary(tester); // revela o slide 1 inteiro
    expect(find.text(slides[1].body), findsOneWidget);
  });

  testWidgets('"Pular" sai direto do tutorial sem passar pelos outros slides', (tester) async {
    final container = await pumpWorldSelect(tester);
    await tapWorldNode(tester, worlds.first);

    await tester.tap(find.text('Pular'));
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(TutorialView), findsNothing);
    expect(find.byType(StageSelectView), findsOneWidget);
    expect(container.read(onboardingNotifierProvider).hasSeen(worlds.first.number), isTrue);
  });

  testWidgets('completar todos os slides do Mundo 1 navega para a Seleção de Fases e marca Onboarding', (tester) async {
    final container = await pumpWorldSelect(tester);
    await tapWorldNode(tester, worlds.first);

    final totalSlides = worldTutorials[1]!.length;
    for (var i = 0; i < totalSlides; i++) {
      await tapPrimary(tester); // revela
      await tapPrimary(tester); // avança (ou termina, no último)
    }
    await pumpTransition(tester);

    expect(find.byType(TutorialView), findsNothing);
    expect(find.byType(StageSelectView), findsOneWidget);
    expect(container.read(onboardingNotifierProvider).hasSeen(worlds.first.number), isTrue);
  });

  testWidgets('Mundo já visto (Onboarding) navega direto, sem TutorialView', (tester) async {
    final container = createTestContainer();
    container.read(onboardingNotifierProvider.notifier).markSeen(worlds.first.number);
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(wrapForTest(container, const WorldSelectView()));
    await tester.pump();

    await tapWorldNode(tester, worlds.first);

    expect(find.byType(TutorialView), findsNothing);
    expect(find.byType(StageSelectView), findsOneWidget);
  });

  testWidgets('botão "?" na Seleção de Fases reabre a TutorialView com as regras do mundo, e volta sem navegar de novo', (tester) async {
    final container = createTestContainer();
    container.read(onboardingNotifierProvider.notifier).markSeen(worlds.first.number);

    await tester.pumpWidget(wrapForTest(container, StageSelectView(world: worlds.first)));
    await tester.pump();

    // Cabeçalho tem 2 `IconActionButton`: voltar (índice 0) e "?" (índice 1).
    await tester.tap(find.byType(IconActionButton).at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TutorialView), findsOneWidget);
    expect(find.text(worldTutorials[1]!.first.title!), findsOneWidget);

    final worldSlideCount = worldTutorials[1]!.length;
    for (var i = 0; i < worldSlideCount; i++) {
      await tapPrimary(tester);
      await tapPrimary(tester);
    }
    await pumpTransition(tester);

    expect(find.byType(TutorialView), findsNothing);
    expect(find.byType(StageSelectView), findsOneWidget);
  });

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder, {int maxSteps = 60}) async {
    for (var i = 0; i < maxSteps; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsOneWidget, reason: 'esperou ${maxSteps * 100}ms e não encontrou');
  }

  /// Navega de verdade (Seleção de Mundo → Seleção de Fases → Gameplay,
  /// mesma pilha de rotas nomeadas do app real — precisa existir pra
  /// `popUntil(levelSelectRouteName)` funcionar) e vence a última fase de
  /// `world1Levels` (`Fase 12`, `hintProgram`: Virar →, Repetir 3×, Andar,
  /// Virar ←, Repetir 3×, Andar). Chamador já marcou `markSeen(1)` no
  /// container pra pular o tutorial.
  Future<void> winLastWorld1Level(WidgetTester tester, ProviderContainer container) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.binding.setSurfaceSize(const Size(400, 900));
    await tester.pumpWidget(wrapForTest(container, const WorldSelectView()));
    await tester.pump();
    await tapWorldNode(tester, worlds.first);
    expect(find.byType(StageSelectView), findsOneWidget);

    final tile = find.text('${world1Levels.last.number}');
    await tester.ensureVisible(tile);
    await tester.pump();
    await tester.tap(tile);
    await tester.pump();
    await pumpTransition(tester);

    // Superfície alta o bastante para tabuleiro + comandos + Play ficarem
    // visíveis sem rolar (mesmo cuidado de `gameplay_flow_test.dart`) — só
    // aplicada agora, depois de já ter navegado (a Seleção de Mundo/Fases
    // já foram validadas na altura padrão de 900 usada em todo o arquivo).
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    await tester.pump();

    for (final label in ['Virar →', 'Repetir 3×', 'Andar', 'Virar ←', 'Repetir 3×', 'Andar']) {
      await tester.tap(find.widgetWithText(CommandButton, label));
      await tester.pump();
    }
    await tester.tap(find.text('PLAY'));
    await tester.pump();

    await pumpUntilFound(tester, find.byType(VictoryView));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('terminar a última fase pendente de um Mundo pela 1ª vez mostra a recapitulação antes de voltar', (tester) async {
    final container = createTestContainer();
    container.read(onboardingNotifierProvider.notifier).markSeen(1);
    // Todas as fases do Mundo 1, exceto a última, já concluídas — vencer a
    // última fecha o Mundo agora mesmo.
    final progressNotifier = container.read(progressNotifierProvider.notifier);
    for (final level in world1Levels.sublist(0, world1Levels.length - 1)) {
      progressNotifier.recordWin(level.id, stars: 3, blocksUsed: level.optimalBlocks, points: 300);
    }

    await winLastWorld1Level(tester, container);
    await tester.tap(find.byType(PrimaryPillButton)); // "Próxima fase"/toque único na Vitória
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(TutorialView), findsOneWidget);
    expect(find.text(worldRecapSlides[1]!.first.title!), findsOneWidget);

    await tapPrimary(tester); // revela
    await tapPrimary(tester); // "Continuar" (só 1 slide na recapitulação do Mundo 1)
    await pumpTransition(tester);

    expect(find.byType(TutorialView), findsNothing);
    expect(find.byType(StageSelectView), findsOneWidget);
    expect(container.read(onboardingNotifierProvider).hasSeenRecap(1), isTrue);
  });

  testWidgets('rejogar a última fase de um Mundo já com recapitulação vista não mostra de novo', (tester) async {
    final container = createTestContainer();
    final onboardingNotifier = container.read(onboardingNotifierProvider.notifier);
    onboardingNotifier.markSeen(1);
    final progressNotifier = container.read(progressNotifierProvider.notifier);
    for (final level in world1Levels) {
      progressNotifier.recordWin(level.id, stars: 3, blocksUsed: level.optimalBlocks, points: 300);
    }
    onboardingNotifier.markRecapSeen(1);

    await winLastWorld1Level(tester, container);
    await tester.tap(find.byType(PrimaryPillButton));
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(TutorialView), findsNothing);
    expect(find.byType(StageSelectView), findsOneWidget);
  });
}
