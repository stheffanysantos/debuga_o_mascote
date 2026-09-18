import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/auth/auth_providers.dart';
import 'package:debuga_o_mascote/core/leaderboard/leaderboard_providers.dart';
import 'package:debuga_o_mascote/core/progress/progress_notifier.dart';
import 'package:debuga_o_mascote/models/leaderboard_entry.dart';
import 'package:debuga_o_mascote/features/leaderboard/presentation/leaderboard_view.dart';
import 'package:debuga_o_mascote/features/auth/presentation/register/register_view.dart';
import 'package:debuga_o_mascote/features/survey/presentation/survey_view.dart';
import 'package:debuga_o_mascote/features/world_select/presentation/world_select_view.dart';
import 'package:debuga_o_mascote/widgets/icon_action_button_widget.dart';
import 'package:debuga_o_mascote/widgets/primary_pill_button_widget.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_leaderboard_repository.dart';
import '../helpers/test_container.dart';

/// Fluxo do Placar do Dia (`LeaderboardView`) e da Pesquisa opcional
/// (`SurveyView`, idade/já programou — o nome vem da conta logada, não é
/// mais digitado) — ver `.claude/memory/decisions.md`.
void main() {
  late FakeLeaderboardRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeLeaderboardRepository();
  });

  ProviderContainer buildContainer({FakeAuthService? auth}) => createTestContainer(overrides: [
        leaderboardRepositoryProvider.overrideWithValue(fakeRepository),
        authServiceProvider.overrideWithValue(auth ?? FakeAuthService()),
      ]);

  testWidgets('ícone de troféu na Seleção de Mundo abre o Placar do Dia', (tester) async {
    final container = buildContainer();
    await tester.pumpWidget(wrapForTest(container, const WorldSelectView()));
    await tester.pump();

    // Cabeçalho: voltar (0), Placar (1), configurações (2).
    await tester.tap(find.byType(IconActionButton).at(1));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LeaderboardView), findsOneWidget);
  });

  testWidgets('Placar sem pontuação de sessão não mostra o convite pra pesquisa', (tester) async {
    final container = buildContainer();
    await tester.pumpWidget(wrapForTest(container, const LeaderboardView()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Aparecer no Placar'), findsNothing);
    expect(find.text('Entrar e aparecer no Placar'), findsNothing);
    expect(find.textContaining('Ninguém no Placar ainda'), findsOneWidget);
  });

  testWidgets('Placar com pontuação de sessão e conta já logada leva direto pra Pesquisa', (tester) async {
    final container = buildContainer(auth: FakeAuthService(hasAccount: true, displayName: 'Ana'));
    container.read(progressNotifierProvider.notifier).addSessionPoints(450);

    await tester.pumpWidget(wrapForTest(container, const LeaderboardView()));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('450 pontos'), findsOneWidget);

    await tester.tap(find.text('Aparecer no Placar'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SurveyView), findsOneWidget);
  });

  testWidgets('Placar com pontuação de sessão sem conta pede login antes da Pesquisa', (tester) async {
    final container = buildContainer();
    container.read(progressNotifierProvider.notifier).addSessionPoints(450);

    await tester.pumpWidget(wrapForTest(container, const LeaderboardView()));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Entrar e aparecer no Placar'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(RegisterView), findsOneWidget);
    expect(find.byType(SurveyView), findsNothing);

    // Login com Google (1 toque, fake) — depois disso deve cair na Pesquisa.
    final googleButton = find.text('Continuar com Google');
    await tester.ensureVisible(googleButton);
    await tester.pump();
    await tester.tap(googleButton);
    await tester.pump();
    await tester.pump();

    expect(find.byType(RegisterView), findsNothing);
    expect(find.byType(SurveyView), findsOneWidget);
  });

  testWidgets('botão "Ver meu Placar" só habilita com idade e resposta preenchidos', (tester) async {
    final container = buildContainer(auth: FakeAuthService(hasAccount: true, displayName: 'Ana'));
    container.read(progressNotifierProvider.notifier).addSessionPoints(450);
    await tester.pumpWidget(wrapForTest(container, const SurveyView()));
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

  testWidgets('idade absurda (acima de 120) não habilita o botão', (tester) async {
    final container = buildContainer(auth: FakeAuthService(hasAccount: true, displayName: 'Ana'));
    container.read(progressNotifierProvider.notifier).addSessionPoints(450);
    await tester.pumpWidget(wrapForTest(container, const SurveyView()));
    await tester.pump();

    PrimaryPillButton primaryButton() => tester.widget<PrimaryPillButton>(find.byType(PrimaryPillButton));

    await tester.enterText(find.byType(TextField), '999');
    await tester.tap(find.text('Sim'));
    await tester.pump();
    expect(primaryButton().enabled, isFalse, reason: 'campo limita a 3 dígitos, mas 999 ainda passa do teto de idade');

    await tester.enterText(find.byType(TextField), '30');
    await tester.pump();
    expect(primaryButton().enabled, isTrue);
  });

  testWidgets('enviar a pesquisa registra a entrada no Placar (nome da conta) e navega mostrando o ranking', (tester) async {
    final container = buildContainer(auth: FakeAuthService(hasAccount: true, displayName: 'Ana'));
    container.read(progressNotifierProvider.notifier).addSessionPoints(450);
    await tester.pumpWidget(wrapForTest(container, const SurveyView()));
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
    expect(container.read(progressNotifierProvider).hasSubmittedToLeaderboard, isTrue);

    expect(find.byType(LeaderboardView), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('450'), findsOneWidget);
  });

  testWidgets('depois de enviar a pesquisa, o Placar recém-aberto já mostra a entrada (sem precisar sair e voltar)', (tester) async {
    // Fluxo real (não pula direto pra `SurveyView` isolada, como o teste
    // acima) — a `LeaderboardView` original continua montada por baixo na
    // pilha do `Navigator` quando `SurveyView` é empurrada, exatamente como
    // acontece de verdade no app (achado real do usuário: "por que no
    // placar não está aparecendo meu nome?" — `leaderboardViewModelProvider`
    // não é `.family`, e sem `ref.invalidate` antes do `pushReplacement`, a
    // tela nova reusava o resultado cacheado de ANTES do envio, ver
    // `.claude/memory/decisions.md`).
    final container = buildContainer(auth: FakeAuthService(hasAccount: true, displayName: 'Ana'));
    container.read(progressNotifierProvider.notifier).addSessionPoints(450);

    await tester.pumpWidget(wrapForTest(container, const LeaderboardView()));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Ninguém no Placar ainda'), findsOneWidget);

    await tester.tap(find.text('Aparecer no Placar'));
    await tester.pump();
    await tester.pump();

    await tester.enterText(find.byType(TextField), '10');
    await tester.tap(find.text('Sim'));
    await tester.pump();
    // A `LeaderboardView` anterior continua montada por baixo (offstage) —
    // "Aparecer no Placar" dela também é um `PrimaryPillButton`, então
    // precisa achar pelo texto específico do botão da `SurveyView`.
    await tester.tap(find.text('Ver meu Placar'));
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(LeaderboardView), findsWidgets);
    expect(find.text('Ana'), findsOneWidget, reason: 'placar recém-aberto precisa refletir o envio na hora, não a busca antiga cacheada');
  });

  testWidgets('ranking mostra as entradas ordenadas da maior pontuação pra menor', (tester) async {
    final now = DateTime.now();
    fakeRepository.entries.addAll([
      LeaderboardEntry(name: 'Beto', age: 12, hasProgrammedBefore: false, score: 300, updatedAt: now),
      LeaderboardEntry(name: 'Ana', age: 10, hasProgrammedBefore: true, score: 900, updatedAt: now),
    ]);

    final container = buildContainer();
    await tester.pumpWidget(wrapForTest(container, const LeaderboardView()));
    await tester.pump();
    await tester.pump();

    final anaCenter = tester.getCenter(find.text('Ana'));
    final betoCenter = tester.getCenter(find.text('Beto'));
    expect(anaCenter.dy, lessThan(betoCenter.dy), reason: 'Ana (900 pontos) deve vir antes de Beto (300 pontos)');
  });
}
