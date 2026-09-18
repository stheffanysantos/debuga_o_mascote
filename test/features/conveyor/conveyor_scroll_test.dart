import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/features/conveyor/presentation/gameplay/conveyor_gameplay_view.dart';
import 'package:debuga_o_mascote/models/conveyor_level.dart';
import 'package:debuga_o_mascote/widgets/command_button_widget.dart';

import '../../helpers/test_container.dart';

/// Testador: "Quando tem uma fila grande ele não rola sozinho pra a
/// direita. Aí não dá pra ver o que tá acontecendo." Confirma que a fila de
/// Itens (`ListView.separated` horizontal dentro de `Key('conveyorBelt')`)
/// realmente rola sozinha conforme a Execução avança numa fila longa
/// (Fase 12, 12 itens) — sem isso, o item atual sairia da área visível sem
/// nenhum acompanhamento automático. Ver `.claude/memory/decisions.md`.
void main() {
  testWidgets('a fila da esteira rola sozinha para acompanhar o item atual numa fila longa', (tester) async {
    final level = world2Levels.last; // Fase 12 ('world2_level12'): 12 itens.
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapForTest(createTestContainer(), ConveyorGameplayView(levelId: level.id)));
    await tester.pump();

    final scrollableFinder = find.descendant(of: find.byKey(const Key('conveyorBelt')), matching: find.byType(Scrollable));
    expect(scrollableFinder, findsOneWidget);

    double offsetOf() => tester.state<ScrollableState>(scrollableFinder).position.pixels;

    final initialOffset = offsetOf();
    expect(initialOffset, 0);

    // Solução da Fase 12 (`hintProgram`): 3 blocos "Enquanto", classificando
    // os 3 grupos de itens (5 amarelos, 4 roxos, 3 amarelos) sem estourar o
    // `maxBlocks`.
    await tester.tap(find.widgetWithText(CommandButton, 'Enquanto Amarelo → A'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Enquanto Roxo → B'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CommandButton, 'Enquanto Amarelo → A'));
    await tester.pump();

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    // Avança a Execução aos poucos (mesmo padrão de `_pumpUntilFound` nos
    // outros testes de fluxo) sem parar no 1º sinal de scroll — precisa
    // continuar até a Execução inteira terminar (12 itens × ~460ms cada,
    // ver `_stepDuration`), senão sobram `Future.delayed` pendentes quando
    // o teste desmonta a árvore ("A Timer is still pending even after the
    // widget tree was disposed").
    var scrolled = false;
    for (var i = 0; i < 70; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      // Depois que a Execução termina, a tela navega pra Vitória/Falha e a
      // fila (`Key('conveyorBelt')`) some da árvore — só continuamos
      // pumpando (sem consultar `offsetOf()`) pra drenar os `Future.delayed`
      // restantes antes do teste acabar.
      if (scrollableFinder.evaluate().isEmpty) continue;
      if (offsetOf() > 0) scrolled = true;
    }

    expect(scrolled, isTrue, reason: 'a fila deveria ter rolado sozinha ao longo da Execução');
  });
}
