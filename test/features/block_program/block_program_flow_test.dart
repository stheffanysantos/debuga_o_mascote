import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/features/block_program/presentation/gameplay/block_program_gameplay_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/failure_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/victory_view.dart';
import 'package:debuga_o_mascote/models/block_program_level.dart';
import 'package:debuga_o_mascote/widgets/command_button_widget.dart';

import '../../helpers/test_container.dart';

/// Mesmo espírito de `test/features/maze/gameplay_flow_test.dart`, mas para
/// o motor de "Programação em Blocos" — hoje só o Mundo 4 ("Decisões em
/// Bloco", `world4Levels`) usa este motor (o mundo irmão original, "Oficina
/// de Blocos", saiu do jogo — ver `.claude/memory/decisions.md`, entrada de
/// 2026-09-18). Monta um Programa de verdade, aperta Play, espera a
/// Execução terminar e confirma que a navegação — direto para a tela de
/// resultado real, sem overlay intermediário — e o conteúdo da tela
/// seguinte refletem o resultado real. Ver `.claude/rules/testing.md`.
Future<void> _pumpUntilFound(WidgetTester tester, Finder finder, {int maxSteps = 60}) async {
  for (var i = 0; i < maxSteps; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsOneWidget, reason: 'esperou ${maxSteps * 100}ms e não encontrou');
}

void main() {
  // Fase 1 do Mundo 4 ('world4_level1'): lista [2, 3], Total só soma os
  // números pares == 2, solução ótima de 2 blocos ("Some os pares" ×2 — um
  // por número, sem "Para cada número" ainda).
  final world4Level = world4Levels.first;

  testWidgets('Mundo 4: somar só os pares corretamente navega direto para a Vitória com os dados reais da partida', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapForTest(createTestContainer(), BlockProgramGameplayView(levelId: world4Level.id)));
    await tester.pump();

    await tester.tap(find.widgetWithText(CommandButton, 'Some os pares'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Some os pares'));
    await tester.pump();

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    await _pumpUntilFound(tester, find.byType(VictoryView));
    await tester.pump(const Duration(milliseconds: 400));

    Finder onVictory(Finder finder) => find.descendant(of: find.byType(VictoryView), matching: finder);

    expect(onVictory(find.text('FASE 1 CONCLUÍDA')), findsOneWidget);
    expect(onVictory(find.text('300')), findsOneWidget, reason: '2 blocos == ótimo da fase -> pontuação máxima');
    expect(onVictory(find.text('2')), findsOneWidget, reason: 'blocos realmente usados no Programa');
  });

  testWidgets('Mundo 4: usar o bloco errado (Contador, não Total) navega direto para a Falha com o motivo real', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapForTest(createTestContainer(), BlockProgramGameplayView(levelId: world4Level.id)));
    await tester.pump();

    // A fase pede o Total == 2; "Conte +1" só incrementa o Contador
    // (ignorado por esta fase, que usa `goal: total`) — Total continua 0.
    await tester.tap(find.widgetWithText(CommandButton, 'Conte +1'));
    await tester.pump();

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    await _pumpUntilFound(tester, find.byType(FailureView));
    await tester.pump(const Duration(milliseconds: 400));

    Finder onFailure(Finder finder) => find.descendant(of: find.byType(FailureView), matching: finder);

    expect(onFailure(find.text('FASE 1 · TENTATIVA 1')), findsOneWidget);
    // Motivo real (achado do UX Reviewer: mostrar o valor alcançado contra
    // o alvo, não um texto genérico) — "Conte +1" não toca o Total, que
    // permanece 0, contra o alvo de 2 desta fase.
    expect(onFailure(find.textContaining('Seu Total foi 0')), findsOneWidget);
    expect(onFailure(find.textContaining('pedia 2')), findsOneWidget);
  });

  testWidgets(
    'Mundo 4 (esmaecimento progressivo): Fase 5 já começa com 1 bloco pronto/travado, jogador só completa o par restante para vencer',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Fase 5 ('world4_level5'): lista [10, 15, 20, 25, 30], Total só soma
      // pares == 60, `prefilledCount: 1` — o `hintProgram` inteiro é
      // [addToTotalIfEven, forEachNumber, addToTotalIfEven] (3 blocos,
      // `optimalBlocks: 3`); o 1º já vem pronto/travado, o jogador só
      // completa o par "Para cada número" + "Some os pares" (2 blocos).
      final level = world4Levels[4];
      expect(level.prefilledCount, 1, reason: 'pré-condição deste teste');

      await tester.pumpWidget(wrapForTest(createTestContainer(), BlockProgramGameplayView(levelId: level.id)));
      await tester.pump();

      // O prefixo fixo já vem montado, mostrando a linha de código real do
      // bloco (sem "Para cada número" antes dele, o bloco-alvo processa o
      // próximo número solto: `proximoNumero`) — o jogador nunca vê o
      // placeholder de "Programa vazio" nesta fase.
      expect(find.textContaining('total += proximoNumero'), findsOneWidget);
      expect(find.text('Toque nos blocos abaixo para montar'), findsNothing);

      // Completa o par restante — dentro do laço, o bloco-alvo passa a usar
      // `numeros[i]`, não mais `proximoNumero`.
      await tester.tap(find.widgetWithText(CommandButton, 'Para cada número'));
      await tester.pump();
      await tester.tap(find.widgetWithText(CommandButton, 'Some os pares'));
      await tester.pump();

      expect(find.textContaining('for (int i = 0; i < numeros.length; i++)'), findsOneWidget);
      expect(find.textContaining('total += numeros[i]'), findsOneWidget);

      await tester.tap(find.text('PLAY'));
      await tester.pump();

      await _pumpUntilFound(tester, find.byType(VictoryView));
      await tester.pump(const Duration(milliseconds: 400));

      Finder onVictory(Finder finder) => find.descendant(of: find.byType(VictoryView), matching: finder);

      expect(onVictory(find.text('FASE 5 CONCLUÍDA')), findsOneWidget);
      expect(
        onVictory(find.text('3')),
        findsOneWidget,
        reason: '3 blocos usados (1 do prefixo + 2 adicionados) == optimalBlocks -> pontuação máxima',
      );
      expect(onVictory(find.text('300')), findsOneWidget);
    },
  );
}
