import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/audio/app_sounds.dart';
import 'package:debuga_o_mascote/models/code_puzzle_level.dart';
import 'package:debuga_o_mascote/models/progress.dart';
import 'package:debuga_o_mascote/screens/code_puzzle_gameplay_screen.dart';
import 'package:debuga_o_mascote/screens/code_puzzle_result_screen.dart';

import '../helpers/fake_sound_player.dart';

/// Mesmo espírito de `test/screens/gameplay_flow_test.dart`/
/// `conveyor_flow_test.dart`, mas para o motor de veredito único do Mundo 3
/// (`CodePuzzleGameplayScreen` → `CodePuzzleResultScreen`, sem passo a
/// passo, ver `.claude/rules/testing.md`).
void main() {
  setUp(() => AppSounds.instance.player = FakeSoundPlayer());
  tearDown(() => AppSounds.instance.resetForTest());

  // Fase 1 do Mundo 3 ('world3_level1', reorder): duas linhas,
  // `int x = 5;` seguida de `print(x);`.
  final reorderLevel = world3Levels.firstWhere((l) => l.id == 'world3_level1');

  // Fase 7 do Mundo 3 ('world3_level7', findBug): a linha errada é o
  // índice 1 (`return a - b;`, deveria somar).
  final findBugLevel = world3Levels.firstWhere((l) => l.id == 'world3_level7');

  Finder onResult(Finder finder) => find.descendant(of: find.byType(CodePuzzleResultScreen), matching: finder);

  testWidgets('montar a sequência certa num puzzle reorder navega para o Resultado com vitória', (tester) async {
    Progress.instance.reset();
    await tester.pumpWidget(MaterialApp(home: CodePuzzleGameplayScreen(level: reorderLevel)));
    await tester.pump();

    // Toca as linhas pelo texto (não pela posição embaralhada, que é
    // aleatória por seed) na ordem certa de `correctOrder`.
    await tester.tap(find.text('int x = 5;'));
    await tester.pump();
    await tester.tap(find.text('print(x);'));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultScreen), findsOneWidget);
    expect(onResult(find.text('FASE 1 CONCLUÍDA')), findsOneWidget);
    expect(onResult(find.text('Mandou bem!')), findsOneWidget);
  });

  testWidgets('montar a sequência errada num puzzle reorder navega para o Resultado com derrota e a Dica certa', (tester) async {
    Progress.instance.reset();
    await tester.pumpWidget(MaterialApp(home: CodePuzzleGameplayScreen(level: reorderLevel)));
    await tester.pump();

    // Ordem invertida — errada.
    await tester.tap(find.text('print(x);'));
    await tester.pump();
    await tester.tap(find.text('int x = 5;'));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultScreen), findsOneWidget);
    expect(onResult(find.text('FASE 1 · TENTATIVA 1')), findsOneWidget);
    expect(onResult(find.text('Quase lá!')), findsOneWidget);
    expect(onResult(find.text('DICA')), findsOneWidget, reason: 'reorder perdido mostra a ordem certa como Dica');
  });

  testWidgets('tocar a linha certa num puzzle findBug navega para o Resultado com vitória e a explicação', (tester) async {
    Progress.instance.reset();
    await tester.pumpWidget(MaterialApp(home: CodePuzzleGameplayScreen(level: findBugLevel)));
    await tester.pump();

    await tester.tap(find.byKey(const Key('codePuzzleLine_1')));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultScreen), findsOneWidget);
    expect(onResult(find.text('FASE 7 CONCLUÍDA')), findsOneWidget);
    expect(onResult(find.text(findBugLevel.bugExplanation)), findsOneWidget);
  });

  testWidgets('tocar a linha errada num puzzle findBug navega para o Resultado com derrota e a explicação', (tester) async {
    Progress.instance.reset();
    await tester.pumpWidget(MaterialApp(home: CodePuzzleGameplayScreen(level: findBugLevel)));
    await tester.pump();

    // A linha certa é o índice 1 — toca o índice 0 (errado) de propósito.
    await tester.tap(find.byKey(const Key('codePuzzleLine_0')));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultScreen), findsOneWidget);
    expect(onResult(find.text('FASE 7 · TENTATIVA 1')), findsOneWidget);
    expect(onResult(find.text('Quase lá!')), findsOneWidget);
    expect(onResult(find.text(findBugLevel.bugExplanation)), findsOneWidget);
  });
}
