import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/main.dart';

void main() {
  testWidgets('Splash mostra o botão JOGAR', (WidgetTester tester) async {
    await tester.pumpWidget(const DebugaOMascoteApp());
    await tester.pump();

    expect(find.text('JOGAR'), findsOneWidget);
    expect(find.textContaining('DEBUGA', findRichText: true), findsOneWidget);
  });
}
