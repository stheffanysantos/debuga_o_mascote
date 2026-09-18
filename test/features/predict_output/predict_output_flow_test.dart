import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/features/predict_output/presentation/gameplay/predict_output_gameplay_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/code_puzzle_result_view.dart';
import 'package:debuga_o_mascote/models/predict_output_level.dart';

import '../../helpers/test_container.dart';

/// Mesmo espírito de `test/screens/code_puzzle_flow_test.dart`, mas para o
/// motor de veredito único do Mundo 3 (`PredictOutputGameplayView` →
/// `CodePuzzleResultView`, sem passo a passo, ver
/// `.claude/rules/testing.md`).
void main() {
  // Fase 1 do Mundo 3 ('world3_level1'): "int x = 4; print(x + 1);" — a
  // resposta certa é a opção de índice 0 ("5").
  final level = world3Levels.firstWhere((l) => l.id == 'world3_level1');

  Finder onResult(Finder finder) => find.descendant(of: find.byType(CodePuzzleResultView), matching: finder);

  testWidgets('escolher a resposta certa navega para o Resultado com vitória e a explicação', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), PredictOutputGameplayView(levelId: level.id)));
    await tester.pump();

    await tester.tap(find.byKey(const Key('predictOption_0')));
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultView), findsOneWidget);
    expect(onResult(find.text('FASE 1 CONCLUÍDA')), findsOneWidget);
    expect(onResult(find.text(level.explanation)), findsOneWidget);
  });

  testWidgets('escolher a resposta errada navega para o Resultado com derrota e a explicação', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), PredictOutputGameplayView(levelId: level.id)));
    await tester.pump();

    // Índice 1 ('4') é uma das distratoras — errada.
    await tester.tap(find.byKey(const Key('predictOption_1')));
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CodePuzzleResultView), findsOneWidget);
    expect(onResult(find.text('FASE 1 · TENTATIVA 1')), findsOneWidget);
    expect(onResult(find.text('Quase lá!')), findsOneWidget);
    expect(onResult(find.text(level.explanation)), findsOneWidget);
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

      await tester.pumpWidget(wrapForTest(createTestContainer(), PredictOutputGameplayView(levelId: level.id)));
      await tester.pump();

      // 1ª tentativa: errada.
      await tester.tap(find.byKey(const Key('predictOption_1')));
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

      // 2ª tentativa: certa — vence com attempts == 2.
      await tester.tap(find.byKey(const Key('predictOption_0')));
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

      await tester.tap(find.byKey(const Key('predictOption_0')));
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(onResult(find.text('Mandou bem!')), findsOneWidget);
      expect(onResult(find.text('1')), findsOneWidget, reason: 'TENTATIVAS deve mostrar 1 de novo');
      expect(onResult(find.text('300')), findsOneWidget, reason: 'PONTOS deve voltar ao máximo, não continuar caindo');
    },
  );

  testWidgets('Confirmar fica desabilitado até uma opção ser escolhida', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), PredictOutputGameplayView(levelId: level.id)));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    expect(find.byType(CodePuzzleResultView), findsNothing, reason: 'sem opção escolhida, Confirmar não faz nada');
  });
}
