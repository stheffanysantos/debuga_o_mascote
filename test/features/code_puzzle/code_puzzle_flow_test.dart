import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/features/code_puzzle/presentation/gameplay/code_puzzle_gameplay_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/code_puzzle_result_view.dart';
import 'package:debuga_o_mascote/models/code_puzzle_level.dart';

import '../../helpers/test_container.dart';

/// Mesmo espírito de `test/features/maze/gameplay_flow_test.dart`/
/// `test/features/conveyor/conveyor_flow_test.dart`, mas para o motor de
/// veredito único do Mundo 5 (`CodePuzzleGameplayView` →
/// `CodePuzzleResultView`, sem passo a passo, ver
/// `.claude/rules/testing.md`).
void main() {
  // Fase 1 do Mundo 5 ('world5_level1', reorder): duas linhas,
  // `int x = 5;` seguida de `print(x);`.
  final reorderLevel = world5Levels.firstWhere((l) => l.id == 'world5_level1');

  // Fase 7 do Mundo 5 ('world5_level7', findBug): a linha errada é o
  // índice 1 (`return a - b;`, deveria somar).
  final findBugLevel = world5Levels.firstWhere((l) => l.id == 'world5_level7');

  Finder onResult(Finder finder) => find.descendant(of: find.byType(CodePuzzleResultView), matching: finder);

  testWidgets('montar a sequência certa num puzzle reorder navega para o Resultado com vitória', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), CodePuzzleGameplayView(levelId: reorderLevel.id)));
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

    expect(find.byType(CodePuzzleResultView), findsOneWidget);
    expect(onResult(find.text('FASE 1 CONCLUÍDA')), findsOneWidget);
    expect(onResult(find.text('Mandou bem!')), findsOneWidget);
  });

  testWidgets(
    'Fase 2 (linhas intercambiáveis) aceita a ordem alternativa das declarações independentes '
    '(regressão: "int a"/"int b" podiam vir em qualquer ordem entre si, mas só uma era aceita)',
    (tester) async {
      final level2 = world5Levels.firstWhere((l) => l.id == 'world5_level2');
      await tester.pumpWidget(wrapForTest(createTestContainer(), CodePuzzleGameplayView(levelId: level2.id)));
      await tester.pump();

      // Ordem trocada das duas declarações independentes — ambas vêm
      // antes do print, mas na ordem inversa da declarada em
      // `correctOrder`.
      await tester.tap(find.text('int b = 3;'));
      await tester.pump();
      await tester.tap(find.text('int a = 2;'));
      await tester.pump();
      await tester.tap(find.text('print(a + b);'));
      await tester.pump();

      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CodePuzzleResultView), findsOneWidget);
      expect(onResult(find.text('Mandou bem!')), findsOneWidget);
    },
  );

  testWidgets('montar a sequência errada num puzzle reorder navega para o Resultado com derrota e a Dica certa', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), CodePuzzleGameplayView(levelId: reorderLevel.id)));
    await tester.pump();

    // Ordem invertida — errada.
    await tester.tap(find.text('print(x);'));
    await tester.pump();
    await tester.tap(find.text('int x = 5;'));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultView), findsOneWidget);
    expect(onResult(find.text('FASE 1 · TENTATIVA 1')), findsOneWidget);
    expect(onResult(find.text('Quase lá!')), findsOneWidget);
    expect(onResult(find.text('DICA')), findsOneWidget, reason: 'reorder perdido mostra a ordem certa como Dica');
  });

  testWidgets('tocar a linha certa num puzzle findBug navega para o Resultado com vitória e a explicação', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), CodePuzzleGameplayView(levelId: findBugLevel.id)));
    await tester.pump();

    await tester.tap(find.byKey(const Key('codePuzzleLine_1')));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultView), findsOneWidget);
    expect(onResult(find.text('FASE 7 CONCLUÍDA')), findsOneWidget);
    expect(onResult(find.text(findBugLevel.bugExplanation)), findsOneWidget);
  });

  testWidgets(
    'replay rápido a partir do ícone de "jogar de novo" na Vitória reseta as tentativas '
    '(regressão: attempts não podia continuar acumulando entre sessões distintas)',
    (tester) async {
      // Superfície alta o bastante para os cartões da tela de Resultado
      // (com explicação) caberem sem precisar rolar — mesmo cuidado de
      // `gameplay_flow_test.dart`/`conveyor_flow_test.dart` (sem isso, o
      // ícone de "jogar de novo" fica fora da viewport padrão de teste e
      // o toque nele não registra).
      await tester.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapForTest(createTestContainer(), CodePuzzleGameplayView(levelId: findBugLevel.id)));
      await tester.pump();

      // 1ª tentativa: errada (índice 0).
      await tester.tap(find.byKey(const Key('codePuzzleLine_0')));
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(onResult(find.text('Quase lá!')), findsOneWidget);

      // Pumps extras pra deixar a transição de `pop()` terminar de
      // verdade antes do próximo toque (senão o toque seguinte erra o
      // hit-test, achado ao escrever este teste).
      await tester.tap(find.text('Tentar de novo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Tentativa 2'), findsOneWidget);

      // 2ª tentativa: certa (índice 1) — vence com attempts == 2.
      await tester.tap(find.byKey(const Key('codePuzzleLine_1')));
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(onResult(find.text('Mandou bem!')), findsOneWidget);
      expect(onResult(find.text('2')), findsOneWidget, reason: 'TENTATIVAS deve mostrar 2');
      expect(onResult(find.text('200')), findsOneWidget, reason: 'PONTOS penalizados pela tentativa extra');

      await tester.tap(find.byKey(const Key('codePuzzleResultReplayButton')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Tentativa 1'), findsOneWidget, reason: 'nova sessão — attempts deve ter voltado a 0');

      await tester.tap(find.byKey(const Key('codePuzzleLine_1')));
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(onResult(find.text('Mandou bem!')), findsOneWidget);
      expect(onResult(find.text('1')), findsOneWidget, reason: 'TENTATIVAS deve mostrar 1 de novo');
      expect(onResult(find.text('300')), findsOneWidget, reason: 'PONTOS deve voltar ao máximo, não continuar caindo');
    },
  );

  testWidgets('tocar a linha errada num puzzle findBug navega para o Resultado com derrota e a explicação', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), CodePuzzleGameplayView(levelId: findBugLevel.id)));
    await tester.pump();

    // A linha certa é o índice 1 — toca o índice 0 (errado) de propósito.
    await tester.tap(find.byKey(const Key('codePuzzleLine_0')));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultView), findsOneWidget);
    expect(onResult(find.text('FASE 7 · TENTATIVA 1')), findsOneWidget);
    expect(onResult(find.text('Quase lá!')), findsOneWidget);
    expect(onResult(find.text(findBugLevel.bugExplanation)), findsOneWidget);
  });
}
