import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/audio/app_sounds.dart';
import 'package:debuga_o_mascote/data/app_auth.dart';
import 'package:debuga_o_mascote/models/code_puzzle_level.dart';
import 'package:debuga_o_mascote/models/level.dart';
import 'package:debuga_o_mascote/models/onboarding.dart';
import 'package:debuga_o_mascote/models/progress.dart';
import 'package:debuga_o_mascote/screens/code_puzzle_result_screen.dart';
import 'package:debuga_o_mascote/screens/code_puzzle_stage_select_screen.dart';
import 'package:debuga_o_mascote/screens/register_screen.dart';
import 'package:debuga_o_mascote/screens/tutorial_screen.dart';
import 'package:debuga_o_mascote/screens/world_select_screen.dart';
import 'package:debuga_o_mascote/widgets/primary_pill_button_widget.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_sound_player.dart';

/// Gate de cadastro obrigatório ao terminar a Trilha 1 (hoje = terminar o
/// Mundo 3, o último de `GameTrack.worlds` da Trilha 1) — ver
/// `.claude/memory/decisions.md`. Joga de verdade até a última fase do
/// Mundo 3 (mesmo espírito de `test/screens/tutorial_flow_test.dart`,
/// `winLastWorld1Level`), com as 11 fases anteriores já marcadas como
/// concluídas.
void main() {
  setUp(() => AppSounds.instance.player = FakeSoundPlayer());
  tearDown(() {
    AppSounds.instance.resetForTest();
    AppAuth.instance.resetForTest();
  });

  Future<void> pumpTransition(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Navega de verdade (Seleção de Mundo → Seleção de Fases → Gameplay) e
  /// vence a última fase de `world3Levels` (Fase 12, `findBug`, linha errada
  /// no índice 3 — `buggyLineIndex`). Chamador já marcou
  /// `Onboarding.markSeen(3)` pra pular o tutorial.
  Future<void> winLastWorld3Level(WidgetTester tester) async {
    // Superfície alta o bastante para as 12 fases do Mundo 3 caberem sem
    // rolar — `StageSelectGrid` usa `GridView.builder` (lazy): sem isso, a
    // fase 12 nunca chega a ser construída e `find.text('12')` não acha
    // nada (mesmo cuidado de `tutorial_flow_test.dart`, `winLastWorld1Level`).
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: WorldSelectScreen()));
    await tester.pump();

    final worldNode = find.text('MUNDO 3 / ${worlds[2].name.toUpperCase()}');
    await tester.ensureVisible(worldNode);
    await tester.pump();
    await tester.tap(worldNode);
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(CodePuzzleStageSelectScreen), findsOneWidget);

    final tile = find.text('${world3Levels.last.number}');
    await tester.ensureVisible(tile);
    await tester.pump();
    await tester.tap(tile);
    await tester.pump();
    await pumpTransition(tester);

    await tester.tap(find.byKey(const Key('codePuzzleLine_3')));
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultScreen), findsOneWidget);
  }

  /// A recapitulação de fim de Mundo (`worldRecapSlides`) sempre aparece
  /// antes do gate de cadastro na 1ª vez que a última fase de um Mundo é
  /// vencida — completa o único slide dela ("Você terminou os 3 Mundos!").
  Future<void> completeRecap(WidgetTester tester) async {
    expect(find.byType(TutorialScreen), findsOneWidget);
    await tester.tap(find.byType(PrimaryPillButton)); // revela
    await tester.pump();
    await tester.tap(find.byType(PrimaryPillButton)); // "Concluir"
    await tester.pump();
    await pumpTransition(tester);
  }

  testWidgets('terminar a Trilha 1 sem conta mostra o cadastro obrigatório, com saída pra continuar sem conta', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markSeen(3);
    AppAuth.instance.service = FakeAuthService();
    for (final level in world3Levels.sublist(0, world3Levels.length - 1)) {
      Progress.instance.recordWin(level.id, stars: 3, blocksUsed: 1);
    }

    await winLastWorld3Level(tester);

    await tester.tap(find.text('Ver fases'));
    await tester.pump();
    await pumpTransition(tester);
    await completeRecap(tester);

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Continuar sem conta por enquanto'), findsOneWidget, reason: 'nunca trava o app se o jogador não quiser/puder cadastrar agora');

    await tester.tap(find.text('Continuar sem conta por enquanto'));
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(RegisterScreen), findsNothing);
    expect(find.byType(CodePuzzleStageSelectScreen), findsOneWidget);
  });

  testWidgets('terminar a Trilha 1 já com conta não mostra o cadastro', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markSeen(3);
    AppAuth.instance.service = FakeAuthService(hasAccount: true, displayName: 'jogador@example.com');
    for (final level in world3Levels.sublist(0, world3Levels.length - 1)) {
      Progress.instance.recordWin(level.id, stars: 3, blocksUsed: 1);
    }

    await winLastWorld3Level(tester);

    await tester.tap(find.text('Ver fases'));
    await tester.pump();
    await pumpTransition(tester);
    await completeRecap(tester);

    expect(find.byType(RegisterScreen), findsNothing);
    expect(find.byType(CodePuzzleStageSelectScreen), findsOneWidget);
  });
}
