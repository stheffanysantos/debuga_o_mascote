import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/data/app_auth.dart';
import 'package:debuga_o_mascote/data/leaderboard.dart';
import 'package:debuga_o_mascote/models/leaderboard_entry.dart';
import 'package:debuga_o_mascote/models/progress.dart';
import 'package:debuga_o_mascote/screens/leaderboard_screen.dart';
import 'package:debuga_o_mascote/screens/register_screen.dart';
import 'package:debuga_o_mascote/screens/survey_screen.dart';
import 'package:debuga_o_mascote/screens/world_select_screen.dart';
import 'package:debuga_o_mascote/widgets/icon_action_button_widget.dart';
import 'package:debuga_o_mascote/widgets/primary_pill_button_widget.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_leaderboard_repository.dart';

/// Fluxo do Placar do Dia (`LeaderboardScreen`) e da Pesquisa opcional
/// (`SurveyScreen`, idade/já programou — o nome vem da conta logada, não é
/// mais digitado) — ver `.claude/memory/decisions.md`.
void main() {
  late FakeLeaderboardRepository fakeRepository;
  late FakeAuthService fakeAuth;

  setUp(() {
    fakeRepository = FakeLeaderboardRepository();
    Leaderboard.instance.repository = fakeRepository;
    fakeAuth = FakeAuthService();
    AppAuth.instance.service = fakeAuth;
    Progress.instance.reset();
  });

  tearDown(() {
    Leaderboard.instance.resetForTest();
    AppAuth.instance.resetForTest();
  });

  testWidgets('ícone de troféu na Seleção de Mundo abre o Placar do Dia', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WorldSelectScreen()));
    await tester.pump();

    // Cabeçalho: voltar (0), Placar (1), configurações (2).
    await tester.tap(find.byType(IconActionButton).at(1));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LeaderboardScreen), findsOneWidget);
  });

  testWidgets('Placar sem pontuação de sessão não mostra o convite pra pesquisa', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LeaderboardScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Aparecer no Placar'), findsNothing);
    expect(find.text('Entrar e aparecer no Placar'), findsNothing);
    expect(find.textContaining('Ninguém no Placar ainda hoje'), findsOneWidget);
  });

  testWidgets('Placar com pontuação de sessão e conta já logada leva direto pra Pesquisa', (tester) async {
    fakeAuth = FakeAuthService(hasAccount: true, displayName: 'Ana');
    AppAuth.instance.service = fakeAuth;
    Progress.instance.addSessionPoints(450);

    await tester.pumpWidget(const MaterialApp(home: LeaderboardScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('450 pontos'), findsOneWidget);

    await tester.tap(find.text('Aparecer no Placar'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SurveyScreen), findsOneWidget);
  });

  testWidgets('Placar com pontuação de sessão sem conta pede login antes da Pesquisa', (tester) async {
    Progress.instance.addSessionPoints(450);

    await tester.pumpWidget(const MaterialApp(home: LeaderboardScreen()));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Entrar e aparecer no Placar'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.byType(SurveyScreen), findsNothing);

    // Login com Google (1 toque, fake) — depois disso deve cair na Pesquisa.
    final googleButton = find.text('Continuar com Google');
    await tester.ensureVisible(googleButton);
    await tester.pump();
    await tester.tap(googleButton);
    await tester.pump();
    await tester.pump();

    expect(find.byType(RegisterScreen), findsNothing);
    expect(find.byType(SurveyScreen), findsOneWidget);
  });

  testWidgets('botão "Ver meu Placar" só habilita com idade e resposta preenchidos', (tester) async {
    fakeAuth = FakeAuthService(hasAccount: true, displayName: 'Ana');
    AppAuth.instance.service = fakeAuth;
    Progress.instance.addSessionPoints(450);
    await tester.pumpWidget(const MaterialApp(home: SurveyScreen()));
    await tester.pump();

    PrimaryPillButton primaryButton() => tester.widget<PrimaryPillButton>(find.byType(PrimaryPillButton));
    expect(primaryButton().enabled, isFalse);

    await tester.enterText(find.byType(TextField), '10');
    await tester.pump();
    expect(primaryButton().enabled, isFalse, reason: 'ainda falta responder Sim/Não');

    await tester.tap(find.text('Sim'));
    await tester.pump();
    expect(primaryButton().enabled, isTrue);
  });

  testWidgets('enviar a pesquisa registra a entrada no Placar (nome da conta) e navega mostrando o ranking', (tester) async {
    fakeAuth = FakeAuthService(hasAccount: true, displayName: 'Ana');
    AppAuth.instance.service = fakeAuth;
    Progress.instance.addSessionPoints(450);
    await tester.pumpWidget(const MaterialApp(home: SurveyScreen()));
    await tester.pump();

    expect(find.textContaining('Ana'), findsOneWidget, reason: 'mostra pra que nome da conta vai enviar');

    await tester.enterText(find.byType(TextField), '10');
    await tester.tap(find.text('Sim'));
    await tester.pump();

    await tester.tap(find.byType(PrimaryPillButton));
    await tester.pump();
    // `pushReplacement` usa a mesma transição de página que não termina
    // dentro de um único pump curto (mesmo cuidado de
    // `test/screens/tutorial_flow_test.dart`, `pumpTransition`).
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(fakeRepository.entries, hasLength(1));
    final entry = fakeRepository.entries.first;
    expect(entry.name, 'Ana');
    expect(entry.age, 10);
    expect(entry.hasProgrammedBefore, isTrue);
    expect(entry.score, 450);
    expect(Progress.instance.hasSubmittedToLeaderboard, isTrue);

    expect(find.byType(LeaderboardScreen), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('450'), findsOneWidget);
  });

  testWidgets('ranking mostra as entradas de hoje ordenadas da maior pontuação pra menor', (tester) async {
    final now = DateTime.now();
    fakeRepository.entries.addAll([
      LeaderboardEntry(name: 'Beto', age: 12, hasProgrammedBefore: false, score: 300, submittedAt: now),
      LeaderboardEntry(name: 'Ana', age: 10, hasProgrammedBefore: true, score: 900, submittedAt: now),
    ]);

    await tester.pumpWidget(const MaterialApp(home: LeaderboardScreen()));
    await tester.pump();
    await tester.pump();

    final anaCenter = tester.getCenter(find.text('Ana'));
    final betoCenter = tester.getCenter(find.text('Beto'));
    expect(anaCenter.dy, lessThan(betoCenter.dy), reason: 'Ana (900 pontos) deve vir antes de Beto (300 pontos)');
  });
}
