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

  testWidgets('mostra a pergunta de contexto da fase na Gameplay', (tester) async {
    await tester.pumpWidget(wrapForTest(createTestContainer(), CompleteCodeGameplayView(levelId: level.id)));
    await tester.pump();

    expect(find.text(level.question), findsOneWidget);
  });

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

      await tester.pumpWidget(wrapForTest(createTestContainer(), CompleteCodeGameplayView(levelId: level.id)));
      await tester.pump();

      // 1ª tentativa: errada.
      await tester.tap(find.byKey(const Key('completeCodeOption_1')));
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(onResult(find.text('Quase lá!')), findsOneWidget);

      // "Tentar de novo" (derrota) volta pra mesma instância — attempts
      // deve continuar (comportamento correto, não é o bug). Pumps extras
      // pra deixar a transição de `pop()` terminar de verdade antes do
      // próximo toque (senão o toque seguinte erra o hit-test, achado ao
      // escrever este teste).
      await tester.tap(find.text('Tentar de novo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Tentativa 2'), findsOneWidget);

      // 2ª tentativa: certa — vence com attempts == 2 (pontuação já
      // penalizada pela tentativa errada anterior).
      await tester.tap(find.byKey(const Key('completeCodeOption_0')));
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(onResult(find.text('Mandou bem!')), findsOneWidget);
      expect(onResult(find.text('2')), findsOneWidget, reason: 'TENTATIVAS deve mostrar 2');
      expect(onResult(find.text('200')), findsOneWidget, reason: 'PONTOS penalizados pela tentativa extra');

      // Toca o ícone de "jogar de novo" (replay rápido, sem passar pela
      // Seleção de Fases) — deve resetar a sessão.
      await tester.tap(find.byKey(const Key('codePuzzleResultReplayButton')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Tentativa 1'), findsOneWidget, reason: 'nova sessão — attempts deve ter voltado a 0');

      // Acertando de primeira nesta nova sessão, a pontuação deve ser a
      // pontuação máxima de novo — não continuar caindo.
      await tester.tap(find.byKey(const Key('completeCodeOption_0')));
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
    await tester.pumpWidget(wrapForTest(createTestContainer(), CompleteCodeGameplayView(levelId: level.id)));
    await tester.pump();

    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    expect(find.byType(CodePuzzleResultView), findsNothing, reason: 'sem opção escolhida, Confirmar não faz nada');
  });
}
