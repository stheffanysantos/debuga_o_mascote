import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/features/maze/presentation/gameplay/gameplay_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/failure_view.dart';
import 'package:debuga_o_mascote/features/result/presentation/victory_view.dart';
import 'package:debuga_o_mascote/models/level.dart';
import 'package:debuga_o_mascote/widgets/command_button_widget.dart';

import '../../helpers/test_container.dart';

/// Simula o jogador jogando de verdade (não um mock): monta um Programa,
/// aperta Play, espera a Execução terminar e confirma que a navegação —
/// direto para a tela de resultado real, sem modal/overlay intermediário
/// no tabuleiro — e o conteúdo da tela seguinte refletem o resultado real.
/// Ver `.claude/rules/testing.md` ("Gameplay: teste simulando um Programa
/// simples executando e chegando em vitória/falha").
Future<void> _pumpUntilFound(WidgetTester tester, Finder finder, {int maxSteps = 60}) async {
  for (var i = 0; i < maxSteps; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsOneWidget, reason: 'esperou ${maxSteps * 100}ms e não encontrou');
}

void main() {
  testWidgets('vencer de verdade navega direto para a Vitória com os dados reais da partida', (tester) async {
    // Tela alta o bastante para tudo (tabuleiro + painel "TRADUTOR DE
    // BLOCOS" + comandos + Play) ficar visível sem precisar rolar — a tela
    // real rola (ver GameplayView), mas aqui simplifica o teste a
    // interagir sem `ensureVisible` a cada toque.
    await tester.binding.setSurfaceSize(const Size(400, 1700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = createTestContainer();
    await tester.pumpWidget(wrapForTest(container, GameplayView(levelId: demoLevel.id)));
    await tester.pump();

    // Mesma solução verificada em test/game/program_executor_test.dart:
    // repetir+andar (sobe 3), virar à direita, repetir+andar (chega no alvo).
    await tester.tap(find.widgetWithText(CommandButton, 'Repetir 3×'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Andar'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Virar →'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Repetir 3×'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Andar'));
    await tester.pump();

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    // Sem overlay/botão para tocar — só espera a navegação automática.
    await _pumpUntilFound(tester, find.byType(VictoryView));
    await tester.pump(const Duration(milliseconds: 400));

    // A tela de Gameplay continua montada por baixo (Navigator mantém a
    // rota anterior) — escopar a busca à VictoryView evita colidir com
    // texto igual que já estava lá (ex.: o contador "5 / 8 blocos").
    Finder onVictory(Finder finder) => find.descendant(of: find.byType(VictoryView), matching: finder);

    expect(onVictory(find.text('FASE 6 CONCLUÍDA')), findsOneWidget);
    expect(onVictory(find.text('300')), findsOneWidget, reason: '5 blocos == ótimo da fase -> pontuação máxima');
    expect(onVictory(find.text('5')), findsOneWidget, reason: 'blocos realmente usados no Programa');
  });

  testWidgets('bater na parede navega direto para a Falha com o motivo real', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = createTestContainer();
    await tester.pumpWidget(wrapForTest(container, GameplayView(levelId: demoLevel.id)));
    await tester.pump();

    // Vira 180° e anda: sai do tabuleiro na primeira casa (crash garantido).
    await tester.tap(find.widgetWithText(CommandButton, 'Virar →'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Virar →'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Andar'));
    await tester.pump();

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    await _pumpUntilFound(tester, find.byType(FailureView));
    await tester.pump(const Duration(milliseconds: 400));

    // Escopar à FailureView — a Gameplay continua montada por baixo.
    Finder onFailure(Finder finder) => find.descendant(of: find.byType(FailureView), matching: finder);

    expect(onFailure(find.text('FASE 6 · TENTATIVA 1')), findsOneWidget);
    expect(onFailure(find.textContaining('bateu na parede')), findsOneWidget);
  });
}
