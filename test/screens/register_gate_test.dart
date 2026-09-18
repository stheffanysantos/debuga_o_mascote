import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/auth/auth_providers.dart';
import 'package:debuga_o_mascote/core/onboarding/onboarding_notifier.dart';
import 'package:debuga_o_mascote/core/progress/progress_notifier.dart';
import 'package:debuga_o_mascote/features/maze/presentation/stage_select/stage_select_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/victory_view.dart';
import 'package:debuga_o_mascote/models/level.dart';
import 'package:debuga_o_mascote/features/auth/presentation/register/register_view.dart';
import 'package:debuga_o_mascote/features/tutorial/presentation/tutorial_view.dart';
import 'package:debuga_o_mascote/features/world_select/presentation/world_select_view.dart';
import 'package:debuga_o_mascote/widgets/command_button_widget.dart';
import 'package:debuga_o_mascote/widgets/primary_pill_button_widget.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/test_container.dart';

/// Gate de cadastro obrigatório ao terminar a Trilha 1 (hoje = terminar o
/// Mundo 2 "Resgate de Personagens", o último de `GameTrack.worlds` da
/// Trilha 1 — os Mundos 3/4 moram na Trilha 2 e os Mundos 5/6/7 na Trilha
/// 3, ver `.claude/memory/decisions.md`). Joga de verdade até a última fase
/// do Mundo 2 (mesmo espírito de `test/screens/tutorial_flow_test.dart`,
/// `winLastWorld1Level`), com as 11 fases anteriores já marcadas como
/// concluídas.
void main() {
  Future<void> pumpTransition(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder, {int maxSteps = 60}) async {
    for (var i = 0; i < maxSteps; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsOneWidget, reason: 'esperou ${maxSteps * 100}ms e não encontrou');
  }

  /// Navega de verdade (Seleção de Mundo → Seleção de Fases → Gameplay) e
  /// vence a última fase de `world2Levels` (Fase 12, "Fim do Mundo 2") —
  /// mesma sequência do `hintProgram` verificado da fase (8 blocos,
  /// preenchendo exatamente o `maxBlocks`). Chamador já marcou `markSeen(2)`
  /// no container pra pular o tutorial.
  Future<void> winLastWorld2Level(WidgetTester tester, ProviderContainer container) async {
    // Superfície alta o bastante para as 12 fases do Mundo 2 caberem sem
    // rolar — `StageSelectGrid` usa `GridView.builder` (lazy): sem isso, a
    // fase 12 nunca chega a ser construída e `find.text('12')` não acha
    // nada (mesmo cuidado de `tutorial_flow_test.dart`, `winLastWorld1Level`).
    // Também alta o bastante para a Gameplay (tabuleiro + painel
    // "Resgatados"/"TRADUTOR DE BLOCOS" + 5 comandos + Play) caber sem
    // rolar, já que os toques abaixo não usam `ensureVisible`.
    await tester.binding.setSurfaceSize(const Size(400, 1700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapForTest(container, const WorldSelectView()));
    await tester.pump();

    final worldNode = find.text('MUNDO 2 / ${worlds[1].name.toUpperCase()}');
    await tester.ensureVisible(worldNode);
    await tester.pump();
    await tester.tap(worldNode);
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(StageSelectView), findsOneWidget);

    final tile = find.text('${world2Levels.last.number}');
    await tester.ensureVisible(tile);
    await tester.pump();
    await tester.tap(tile);
    await tester.pump();
    await pumpTransition(tester);

    // `hintProgram` de `world2_level12`: Repetir 3×, Se tiver resgate,
    // Virar ←, Repetir 3×, Se tiver resgate, Virar →, Se tiver resgate,
    // Andar (8 blocos == maxBlocks).
    for (final label in [
      'Repetir 3×',
      'Se tiver, resgate',
      'Virar ←',
      'Repetir 3×',
      'Se tiver, resgate',
      'Virar →',
      'Se tiver, resgate',
      'Andar',
    ]) {
      await tester.tap(find.widgetWithText(CommandButton, label));
      await tester.pump();
    }

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    await pumpUntilFound(tester, find.byType(VictoryView), maxSteps: 90);
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// A recapitulação de fim de Mundo (`worldRecapSlides`) sempre aparece
  /// antes do gate de cadastro na 1ª vez que a última fase de um Mundo é
  /// vencida — completa o único slide dela ("Trilha 1 completa!").
  Future<void> completeRecap(WidgetTester tester) async {
    expect(find.byType(TutorialView), findsOneWidget);
    await tester.tap(find.byType(PrimaryPillButton)); // revela
    await tester.pump();
    await tester.tap(find.byType(PrimaryPillButton)); // "Continuar"
    await tester.pump();
    await pumpTransition(tester);
  }

  testWidgets('terminar a Trilha 1 sem conta mostra o cadastro obrigatório, com saída pra continuar sem conta', (tester) async {
    final container = createTestContainer(overrides: [authServiceProvider.overrideWithValue(FakeAuthService())]);
    container.read(onboardingNotifierProvider.notifier).markSeen(2);
    final progressNotifier = container.read(progressNotifierProvider.notifier);
    for (final level in world2Levels.sublist(0, world2Levels.length - 1)) {
      progressNotifier.recordWin(level.id, stars: 3, blocksUsed: 1, points: 300);
    }

    await winLastWorld2Level(tester, container);

    await tester.tap(find.text('Ver fases'));
    await tester.pump();
    await pumpTransition(tester);
    await completeRecap(tester);

    expect(find.byType(RegisterView), findsOneWidget);
    expect(find.text('Continuar sem conta por enquanto'), findsOneWidget, reason: 'nunca trava o app se o jogador não quiser/puder cadastrar agora');

    await tester.tap(find.text('Continuar sem conta por enquanto'));
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(RegisterView), findsNothing);
    expect(find.byType(StageSelectView), findsOneWidget);
  });

  testWidgets('terminar a Trilha 1 já com conta não mostra o cadastro', (tester) async {
    final container = createTestContainer(
      overrides: [authServiceProvider.overrideWithValue(FakeAuthService(hasAccount: true, displayName: 'jogador@example.com'))],
    );
    container.read(onboardingNotifierProvider.notifier).markSeen(2);
    final progressNotifier = container.read(progressNotifierProvider.notifier);
    for (final level in world2Levels.sublist(0, world2Levels.length - 1)) {
      progressNotifier.recordWin(level.id, stars: 3, blocksUsed: 1, points: 300);
    }

    await winLastWorld2Level(tester, container);

    await tester.tap(find.text('Ver fases'));
    await tester.pump();
    await pumpTransition(tester);
    await completeRecap(tester);

    expect(find.byType(RegisterView), findsNothing);
    expect(find.byType(StageSelectView), findsOneWidget);
  });
}
