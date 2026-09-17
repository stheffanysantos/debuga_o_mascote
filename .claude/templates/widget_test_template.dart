// Esqueleto de widget test. Ver .claude/rules/testing.md —
// testar presença de widget/estado, nunca detalhe visual frágil (pixel/cor exata).
// createTestContainer()/wrapForTest() (test/helpers/test_container.dart) já
// injetam um FakeSoundPlayer padrão; passe overrides extras quando a tela
// precisar (ex.: leaderboardRepositoryProvider.overrideWithValue(...)).

import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_container.dart';

void main() {
  testWidgets('renderiza o caminho feliz', (tester) async {
    final container = createTestContainer();
    await tester.pumpWidget(wrapForTest(container, const Placeholder())); // substituir pela View real

    expect(find.byType(Placeholder), findsOneWidget);
  });
}
