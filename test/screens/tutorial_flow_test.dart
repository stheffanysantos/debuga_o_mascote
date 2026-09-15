import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/audio/app_sounds.dart';
import 'package:debuga_o_mascote/models/level.dart';
import 'package:debuga_o_mascote/models/onboarding.dart';
import 'package:debuga_o_mascote/models/progress.dart';
import 'package:debuga_o_mascote/screens/level_select_screen.dart';
import 'package:debuga_o_mascote/screens/tutorial_screen.dart';
import 'package:debuga_o_mascote/screens/victory_screen.dart';
import 'package:debuga_o_mascote/screens/world_select_screen.dart';
import 'package:debuga_o_mascote/widgets/command_button_widget.dart';
import 'package:debuga_o_mascote/widgets/icon_action_button_widget.dart';
import 'package:debuga_o_mascote/widgets/primary_pill_button_widget.dart';
import 'package:debuga_o_mascote/widgets/tutorial_content.dart';

import '../helpers/fake_sound_player.dart';

/// Fluxo da `TutorialScreen` (`lib/screens/tutorial_screen.dart`, tela cheia
/// paginada — substituiu o antigo `TutorialModal`, ver
/// `.claude/memory/decisions.md`) — ver `.claude/docs/NAVIGATION_FLOW.md` e
/// `Onboarding` (`lib/models/onboarding.dart`). Mesmo estilo de interação
/// real usado em `test/screens/gameplay_flow_test.dart` — sem mock, exceto
/// `AppSounds.player` (narração/SFX reais não têm mock de `MethodChannel`
/// configurado em `test/`).
///
/// O botão primário ("Próximo"/"Jogar") sempre exige 2 toques por slide: o
/// 1º revela o texto inteiro na hora (o slide chega com 0 caracteres
/// visíveis, efeito de máquina de escrever — ver `_TypewriterText`), o 2º
/// avança de verdade. `_tapPrimary` faz um toque só; os testes chamam duas
/// vezes por slide quando precisam avançar de verdade.
void main() {
  setUp(() => AppSounds.instance.player = FakeSoundPlayer());

  tearDown(() => AppSounds.instance.resetForTest());

  Future<void> pumpWorldSelect(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: WorldSelectScreen()));
    await tester.pump();
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

  // Sair da `TutorialScreen` (pop + push do destino) usa a transição padrão
  // de página do Material 3 (`_FadeForwardsPageTransition`), que não termina
  // dentro de 300ms — não usar `pumpAndSettle` (há `PulseTap` em loop
  // infinito nas telas de destino, ver `.claude/rules/testing.md`), então
  // pumpa em pedaços até a transição terminar de verdade.
  Future<void> pumpTransition(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('tocar um Mundo jogável pela 1ª vez mostra a TutorialScreen com o conceito geral de programação primeiro', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    await pumpWorldSelect(tester);

    await tapWorldNode(tester, worlds.first);

    expect(find.byType(TutorialScreen), findsOneWidget);
    expect(find.text(programmingConceptSlides.first.title!), findsOneWidget);
    expect(find.byType(LevelSelectScreen), findsNothing);
  });

  testWidgets('1º toque no botão primário revela o texto inteiro na hora; só o 2º avança de slide', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    await pumpWorldSelect(tester);
    await tapWorldNode(tester, worlds.first);

    // Slide 0 acabou de chegar — texto ainda "digitando" (0 caracteres).
    expect(find.text(programmingConceptSlides[0].body), findsNothing);

    await tapPrimary(tester); // revela o slide 0 inteiro
    expect(find.text(programmingConceptSlides[0].body), findsOneWidget);
    expect(find.text(programmingConceptSlides.first.title!), findsOneWidget); // ainda no mesmo slide

    await tapPrimary(tester); // avança pro slide 1
    expect(find.text(programmingConceptSlides.first.title!), findsNothing);

    await tapPrimary(tester); // revela o slide 1 inteiro
    expect(find.text(programmingConceptSlides[1].body), findsOneWidget);
  });

  testWidgets('"Pular" sai direto do tutorial sem passar pelos outros slides', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    await pumpWorldSelect(tester);
    await tapWorldNode(tester, worlds.first);

    await tester.tap(find.text('Pular'));
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(TutorialScreen), findsNothing);
    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(Onboarding.instance.hasSeen(worlds.first.number), isTrue);
    expect(Onboarding.instance.hasSeenIntro, isTrue);
  });

  testWidgets('completar todos os slides (intro + Mundo 1) navega para a Seleção de Fases e marca Onboarding', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    await pumpWorldSelect(tester);
    await tapWorldNode(tester, worlds.first);

    final totalSlides = programmingConceptSlides.length + worldTutorials[1]!.length;
    for (var i = 0; i < totalSlides; i++) {
      await tapPrimary(tester); // revela
      await tapPrimary(tester); // avança (ou termina, no último)
    }
    await pumpTransition(tester);

    expect(find.byType(TutorialScreen), findsNothing);
    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(Onboarding.instance.hasSeenIntro, isTrue);
    expect(Onboarding.instance.hasSeen(worlds.first.number), isTrue);
  });

  testWidgets('Mundo tocado depois que a intro já foi vista não mostra o conceito geral de novo, só as regras do mundo', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markIntroSeen();
    await pumpWorldSelect(tester);

    await tapWorldNode(tester, worlds[1]);

    expect(find.byType(TutorialScreen), findsOneWidget);
    expect(find.text(worldTutorials[2]!.first.title!), findsOneWidget);
    expect(find.text(programmingConceptSlides.first.title!), findsNothing);
  });

  testWidgets('Mundo já visto (Onboarding) navega direto, sem TutorialScreen', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markIntroSeen();
    Onboarding.instance.markSeen(worlds.first.number);
    await pumpWorldSelect(tester);

    await tapWorldNode(tester, worlds.first);

    expect(find.byType(TutorialScreen), findsNothing);
    expect(find.byType(LevelSelectScreen), findsOneWidget);
  });

  testWidgets('botão "?" na Seleção de Fases reabre a TutorialScreen só com as regras do mundo (sem o conceito geral), e volta sem navegar de novo', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markIntroSeen();
    Onboarding.instance.markSeen(worlds.first.number);

    await tester.pumpWidget(MaterialApp(home: LevelSelectScreen(world: worlds.first)));
    await tester.pump();

    // Cabeçalho tem 2 `IconActionButton`: voltar (índice 0) e "?" (índice 1).
    await tester.tap(find.byType(IconActionButton).at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TutorialScreen), findsOneWidget);
    expect(find.text(worldTutorials[1]!.first.title!), findsOneWidget);
    expect(find.text(programmingConceptSlides.first.title!), findsNothing);

    final worldSlideCount = worldTutorials[1]!.length;
    for (var i = 0; i < worldSlideCount; i++) {
      await tapPrimary(tester);
      await tapPrimary(tester);
    }
    await pumpTransition(tester);

    expect(find.byType(TutorialScreen), findsNothing);
    expect(find.byType(LevelSelectScreen), findsOneWidget);
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
  /// Virar ←, Repetir 3×, Andar). Chamador já marcou `Onboarding.markSeen(1)`
  /// pra pular o tutorial.
  Future<void> winLastWorld1Level(WidgetTester tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpWorldSelect(tester);
    await tapWorldNode(tester, worlds.first);
    expect(find.byType(LevelSelectScreen), findsOneWidget);

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

    await pumpUntilFound(tester, find.byType(VictoryScreen));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('terminar a última fase pendente de um Mundo pela 1ª vez mostra a recapitulação antes de voltar', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markSeen(1);
    // Todas as fases do Mundo 1, exceto a última, já concluídas — vencer a
    // última fecha o Mundo agora mesmo.
    for (final level in world1Levels.sublist(0, world1Levels.length - 1)) {
      Progress.instance.recordWin(level.id, stars: 3, blocksUsed: level.optimalBlocks);
    }

    await winLastWorld1Level(tester);
    await tester.tap(find.byType(PrimaryPillButton)); // "Próxima fase"/toque único na Vitória
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(TutorialScreen), findsOneWidget);
    expect(find.text(worldRecapSlides[1]!.first.title!), findsOneWidget);

    await tapPrimary(tester); // revela
    await tapPrimary(tester); // "Continuar" (só 1 slide na recapitulação do Mundo 1)
    await pumpTransition(tester);

    expect(find.byType(TutorialScreen), findsNothing);
    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(Onboarding.instance.hasSeenRecap(1), isTrue);
  });

  testWidgets('rejogar a última fase de um Mundo já com recapitulação vista não mostra de novo', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markSeen(1);
    for (final level in world1Levels) {
      Progress.instance.recordWin(level.id, stars: 3, blocksUsed: level.optimalBlocks);
    }
    Onboarding.instance.markRecapSeen(1);

    await winLastWorld1Level(tester);
    await tester.tap(find.byType(PrimaryPillButton));
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(TutorialScreen), findsNothing);
    expect(find.byType(LevelSelectScreen), findsOneWidget);
  });
}
