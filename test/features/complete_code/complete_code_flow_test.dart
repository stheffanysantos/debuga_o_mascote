import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/features/complete_code/presentation/gameplay/complete_code_gameplay_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/code_puzzle_result_view.dart';
import 'package:debuga_o_mascote/models/complete_code_level.dart';

import '../../helpers/test_container.dart';

/// Mesmo espírito de `test/screens/code_puzzle_flow_test.dart`, mas para o
/// motor de veredito único do Mundo 4 (`CompleteCodeGameplayView` →
/// `CodePuzzleResultView`, sem passo a passo, ver
/// `.claude/rules/testing.md`).
void main() {
  // Fase 1 do Mundo 4 ('world4_level1'): completa "int soma = a + b;" — a
  // resposta certa é a opção de índice 0.
  final level = world4Levels.firstWhere((l) => l.id == 'world4_level1');

  Finder onResult(Finder finder) => find.descendant(of: find.byType(CodePuzzleResultView), matching: finder);

  testWidgets('escolher a linha certa navega para o Resultado com vitória e a explicação', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), CompleteCodeGameplayView(levelId: level.id)));
    await tester.pump();

    await tester.tap(find.byKey(const Key('completeCodeOption_0')));
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultView), findsOneWidget);
    expect(onResult(find.text('FASE 1 CONCLUÍDA')), findsOneWidget);
    expect(onResult(find.text(level.explanation)), findsOneWidget);
  });

  testWidgets('escolher a linha errada navega para o Resultado com derrota e a explicação', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), CompleteCodeGameplayView(levelId: level.id)));
    await tester.pump();

    // Índice 1 ('int soma = a - b;') é uma distratora — errada.
    await tester.tap(find.byKey(const Key('completeCodeOption_1')));
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultView), findsOneWidget);
    expect(onResult(find.text('FASE 1 · TENTATIVA 1')), findsOneWidget);
    expect(onResult(find.text('Quase lá!')), findsOneWidget);
    expect(onResult(find.text(level.explanation)), findsOneWidget);
  });

  testWidgets('Confirmar fica desabilitado até uma opção ser escolhida', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), CompleteCodeGameplayView(levelId: level.id)));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    expect(find.byType(CodePuzzleResultView), findsNothing, reason: 'sem opção escolhida, Confirmar não faz nada');
  });
}
