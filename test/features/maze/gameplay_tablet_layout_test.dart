import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/features/maze/presentation/gameplay/gameplay_view.dart';
import 'package:debuga_o_mascote/models/level.dart';
import 'package:debuga_o_mascote/widgets/primary_pill_button_widget.dart';

import '../../helpers/test_container.dart';

/// Confirma que o tabuleiro realmente cresce no layout de tablet (lado a
/// lado) em vez de ficar preso ao teto de 340px do layout de celular —
/// `no_overflow_test.dart` só garante que nada estoura, não que o layout
/// lado a lado (`.claude/plans/Roadmap.md`) de fato foi usado.
void main() {
  testWidgets('tabuleiro fica bem maior que o teto de celular (340px) num tablet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapForTest(createTestContainer(), GameplayView(levelId: demoLevel.id)));
    await tester.pump();

    final boardWidth = tester.getSize(find.byKey(const Key('gameplayBoard'))).width;
    expect(boardWidth, greaterThan(400), reason: 'no tablet o tabuleiro deve usar o maxSize maior (640), não o teto de celular (340)');

    // Lado a lado sem scroll: "Seu Programa" e o Play já estão visíveis
    // junto com o tabuleiro, sem precisar rolar.
    expect(find.text('SEU PROGRAMA'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('coluna de comandos continua esticada (não encolhe) mesmo centralizada verticalmente em tablet retrato', (tester) async {
    // Tablet retrato (768x1024): a coluna de comandos fica bem mais alta
    // que o conteúdo, então a centralização vertical (ConstrainedBox +
    // Column(mainAxisAlignment: center)) entra em ação — precisa continuar
    // esticando a largura (crossAxisAlignment: stretch), não encolher para
    // o tamanho mínimo do conteúdo como um `Center` ingênuo faria.
    await tester.binding.setSurfaceSize(const Size(768, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapForTest(createTestContainer(), GameplayView(levelId: demoLevel.id)));
    await tester.pump();

    // Se a centralização vertical tivesse "solto" a largura (ex.: com um
    // `Center` em vez de `Column(mainAxisAlignment: center)`), o botão Play
    // encolheria para caber só o texto/ícone — em vez disso deve continuar
    // esticado pela largura quase toda da coluna de comandos.
    final playButtonWidth = tester.getSize(find.byType(PrimaryPillButton)).width;
    expect(playButtonWidth, greaterThan(200));
  });

  testWidgets('tabuleiro respeita o teto de 340px num celular', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapForTest(createTestContainer(), GameplayView(levelId: demoLevel.id)));
    await tester.pump();

    final boardWidth = tester.getSize(find.byKey(const Key('gameplayBoard'))).width;
    expect(boardWidth, lessThanOrEqualTo(340));
  });
}
