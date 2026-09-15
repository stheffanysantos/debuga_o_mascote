import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/models/level.dart';
import 'package:debuga_o_mascote/models/onboarding.dart';
import 'package:debuga_o_mascote/models/progress.dart';
import 'package:debuga_o_mascote/screens/code_puzzle_stage_select_screen.dart';
import 'package:debuga_o_mascote/screens/conveyor_stage_select_screen.dart';
import 'package:debuga_o_mascote/screens/level_select_screen.dart';
import 'package:debuga_o_mascote/screens/world_select_screen.dart';

/// Ver `.claude/plans/Mundos.md` (Etapa 1) e
/// `.claude/docs/NAVIGATION_FLOW.md`. Mesmo estilo de interação real usado
/// em `test/screens/gameplay_flow_test.dart` — sem mock.
///
/// Estes testes cobrem a Seleção de Mundo em si (grade compacta, navegação
/// por `GameWorld`). O fluxo do `TutorialModal` na 1ª vez que um mundo é
/// tocado (ver `Onboarding`, `lib/models/onboarding.dart`) tem seus próprios
/// testes em `test/screens/tutorial_flow_test.dart` — aqui, cada mundo
/// tocado já é marcado como visto de antemão (`Onboarding.instance.markSeen`)
/// para testar só a navegação, sem o modal no meio do caminho.
void main() {
  // O mapa (`_WorldMapPath`) é mais alto que qualquer viewport de celular
  // (3 nós grandes, ver `.claude/memory/decisions.md`) — rola de verdade
  // dentro do `SingleChildScrollView` da tela. `ensureVisible` (chamado antes
  // de cada `tap` abaixo) rola até o nó certo em vez de depender de uma
  // superfície de teste grande o bastante pra caber tudo sem rolagem.
  Future<void> pumpWorldSelect(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: WorldSelectScreen()));
    await tester.pump();
  }

  testWidgets('mostra os 3 mundos com nome', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    await pumpWorldSelect(tester);

    for (final world in worlds) {
      expect(find.text('MUNDO ${world.number} / ${world.name.toUpperCase()}'), findsOneWidget);
    }
  });

  testWidgets('nenhum mundo bloqueado — só o card da Trilha 2 (comingSoon) mostra "EM BREVE"', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    await pumpWorldSelect(tester);

    // Os 3 mundos da Trilha 1 já são jogáveis — o único "EM BREVE" na tela é
    // o badge do card da Trilha 2, que ainda não tem mundos.
    expect(find.text('EM BREVE'), findsOneWidget);
    expect(find.textContaining('TRILHA 2'), findsOneWidget);
  });

  testWidgets('tocar o card do Mundo 2 (já visto) navega direto para a Seleção de Fases da Esteira', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markSeen(worlds[1].number);
    await pumpWorldSelect(tester);

    // Não usar pumpAndSettle: o card jogável usa PulseTap, uma animação em
    // loop infinito, que nunca "assenta" (ver `.claude/rules/testing.md`).
    final node = find.text('MUNDO 2 / ${worlds[1].name.toUpperCase()}');
    await tester.ensureVisible(node);
    await tester.pump();
    await tester.tap(node);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ConveyorStageSelectScreen), findsOneWidget);
    expect(find.text('MUNDO 2'), findsOneWidget);
  });

  testWidgets('tocar o card do Mundo 3 (já visto) navega direto para a Seleção de Fases do Modo Debug', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markSeen(worlds[2].number);
    await pumpWorldSelect(tester);

    final node = find.text('MUNDO 3 / ${worlds[2].name.toUpperCase()}');
    await tester.ensureVisible(node);
    await tester.pump();
    await tester.tap(node);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(CodePuzzleStageSelectScreen), findsOneWidget);
    expect(find.text('MUNDO 3'), findsOneWidget);
  });

  testWidgets('tocar o card do Mundo 1 (já visto) navega direto para a Seleção de Fases', (tester) async {
    Progress.instance.reset();
    Onboarding.instance.reset();
    Onboarding.instance.markSeen(worlds.first.number);
    await pumpWorldSelect(tester);

    // Não usar pumpAndSettle: o card jogável usa PulseTap, uma animação em
    // loop infinito, que nunca "assenta" (ver `.claude/rules/testing.md` e
    // o mesmo padrão em `test/screens/gameplay_flow_test.dart`).
    final node = find.text('MUNDO 1 / ${worlds.first.name.toUpperCase()}');
    await tester.ensureVisible(node);
    await tester.pump();
    await tester.tap(node);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.text('MUNDO 1'), findsOneWidget);
  });
}
