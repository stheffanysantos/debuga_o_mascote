import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/audio/app_sounds.dart';
import 'package:debuga_o_mascote/models/conveyor_level.dart';
import 'package:debuga_o_mascote/models/progress.dart';
import 'package:debuga_o_mascote/screens/conveyor_gameplay_screen.dart';
import 'package:debuga_o_mascote/screens/failure_screen.dart';
import 'package:debuga_o_mascote/screens/victory_screen.dart';
import 'package:debuga_o_mascote/widgets/command_button_widget.dart';

import '../helpers/fake_sound_player.dart';

/// Mesmo espírito de `test/screens/gameplay_flow_test.dart` (Mundo 1), mas
/// para o motor da Esteira (Mundo 2): monta um Programa de verdade, aperta
/// Play, espera a Execução terminar e confirma que a navegação — direto
/// para a tela de resultado real, sem overlay intermediário — e o conteúdo
/// da tela seguinte refletem o resultado real. Ver
/// `.claude/rules/testing.md`.
Future<void> _pumpUntilFound(WidgetTester tester, Finder finder, {int maxSteps = 60}) async {
  for (var i = 0; i < maxSteps; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsOneWidget, reason: 'esperou ${maxSteps * 100}ms e não encontrou');
}

void main() {
  setUp(() => AppSounds.instance.player = FakeSoundPlayer());
  tearDown(() => AppSounds.instance.resetForTest());

  // Fase 1 do Mundo 2 ('world2_level1'): fila com um único item amarelo,
  // solução ótima de 1 bloco.
  final level = world2Levels.first;

  testWidgets('classificar toda a fila corretamente navega direto para a Vitória com os dados reais da partida', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Progress.instance.reset();

    await tester.pumpWidget(MaterialApp(home: ConveyorGameplayScreen(level: level)));
    await tester.pump();

    await tester.tap(find.widgetWithText(CommandButton, 'Se Amarelo → A'));
    await tester.pump();

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    await _pumpUntilFound(tester, find.byType(VictoryScreen));
    await tester.pump(const Duration(milliseconds: 400));

    // A tela de Gameplay continua montada por baixo — escopar a busca à
    // VictoryScreen evita colidir com texto igual que já estava lá.
    Finder onVictory(Finder finder) => find.descendant(of: find.byType(VictoryScreen), matching: finder);

    expect(onVictory(find.text('FASE 1 CONCLUÍDA')), findsOneWidget);
    expect(onVictory(find.text('300')), findsOneWidget, reason: '1 bloco == ótimo da fase -> pontuação máxima');
    expect(onVictory(find.text('1')), findsOneWidget, reason: 'blocos realmente usados no Programa');
  });

  testWidgets('classificar um item na caixa errada navega direto para a Falha com o motivo real', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Progress.instance.reset();

    await tester.pumpWidget(MaterialApp(home: ConveyorGameplayScreen(level: level)));
    await tester.pump();

    // O item da fila é amarelo — "Se Roxo → B" classifica errado.
    await tester.tap(find.widgetWithText(CommandButton, 'Se Roxo → B'));
    await tester.pump();

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    await _pumpUntilFound(tester, find.byType(FailureScreen));
    await tester.pump(const Duration(milliseconds: 400));

    Finder onFailure(Finder finder) => find.descendant(of: find.byType(FailureScreen), matching: finder);

    expect(onFailure(find.text('FASE 1 · TENTATIVA 1')), findsOneWidget);
    expect(onFailure(find.textContaining('separado na caixa errada')), findsOneWidget);
  });

  testWidgets('"Enquanto" classifica um grupo inteiro (tamanho variável) e navega para a Vitória', (tester) async {
    // Fase 9 ('world2_level9'): 4 amarelos + 3 roxos — só resolve dentro do
    // maxBlocks (indiretamente, esta fase já cabe sem "Enquanto" também,
    // mas com menos estrelas) usando 2 blocos "Enquanto" (ótimo real).
    final whileLevel = world2Levels[8];
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Progress.instance.reset();

    await tester.pumpWidget(MaterialApp(home: ConveyorGameplayScreen(level: whileLevel)));
    await tester.pump();

    await tester.tap(find.widgetWithText(CommandButton, 'Enquanto Amarelo → A'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Enquanto Roxo → B'));
    await tester.pump();

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    await _pumpUntilFound(tester, find.byType(VictoryScreen));
    await tester.pump(const Duration(milliseconds: 400));

    Finder onVictory(Finder finder) => find.descendant(of: find.byType(VictoryScreen), matching: finder);

    expect(onVictory(find.text('FASE 9 CONCLUÍDA')), findsOneWidget);
    expect(onVictory(find.text('300')), findsOneWidget, reason: '2 blocos == ótimo da fase -> pontuação máxima');
    expect(onVictory(find.text('2')), findsOneWidget, reason: 'blocos realmente usados no Programa — 2 "Enquanto" classificaram os 7 itens');
  });
}
