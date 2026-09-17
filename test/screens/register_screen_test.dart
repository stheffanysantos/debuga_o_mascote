import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/auth/auth_providers.dart';
import 'package:debuga_o_mascote/features/auth/presentation/register/register_view.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/test_container.dart';

/// `RegisterView` — cadastro/login (nome/email/senha) + Google, via
/// `authServiceProvider` (fake injetado, sem tocar o Firebase Auth real).
/// Ver `.claude/memory/decisions.md`.
void main() {
  late FakeAuthService fakeAuth;

  setUp(() => fakeAuth = FakeAuthService());

  Future<void> pumpRegister(WidgetTester tester, {bool mandatory = false, VoidCallback? onDone}) async {
    final container = createTestContainer(overrides: [authServiceProvider.overrideWithValue(fakeAuth)]);
    await tester.pumpWidget(wrapForTest(container, RegisterView(mandatory: mandatory, onDone: onDone ?? () {})));
    await tester.pump();
  }

  testWidgets('modo cadastro mostra campo de nome; alternar pra login esconde', (tester) async {
    await pumpRegister(tester);

    expect(find.text('Seu nome'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);

    final toggleLink = find.text('Já tem conta? Entrar');
    await tester.ensureVisible(toggleLink);
    await tester.pump();
    await tester.tap(toggleLink);
    await tester.pump();

    expect(find.text('Seu nome'), findsNothing);
    expect(find.text('Entrar'), findsWidgets);
  });

  testWidgets('botão "Criar conta" só chama o cadastro depois de nome/email/senha preenchidos', (tester) async {
    await pumpRegister(tester);

    // Campos vazios — `PrimaryPillButton` desabilitado, o toque não chama
    // `AuthService`/muda estado nenhum.
    await tester.tap(find.text('Criar conta'));
    await tester.pump();
    expect(fakeAuth.hasAccount, isFalse);

    await tester.enterText(find.widgetWithText(TextField, 'Como podemos te chamar?'), 'Ana');
    await tester.enterText(find.widgetWithText(TextField, 'seu@email.com'), 'ana@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Pelo menos 6 caracteres'), 'senha123');
    await tester.pump();

    await tester.tap(find.text('Criar conta'));
    await tester.pump();
    await tester.pump();

    expect(fakeAuth.hasAccount, isTrue);
  });

  testWidgets('cadastro com sucesso chama onDone', (tester) async {
    var done = false;
    await pumpRegister(tester, onDone: () => done = true);

    await tester.enterText(find.widgetWithText(TextField, 'Como podemos te chamar?'), 'Ana');
    await tester.enterText(find.widgetWithText(TextField, 'seu@email.com'), 'ana@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Pelo menos 6 caracteres'), 'senha123');
    await tester.pump();
    await tester.tap(find.text('Criar conta'));
    await tester.pump();
    await tester.pump();

    expect(done, isTrue);
  });

  testWidgets('erro do AuthService aparece inline e não chama onDone', (tester) async {
    fakeAuth.errorToReturn = 'E-mail inválido.';
    var done = false;
    await pumpRegister(tester, onDone: () => done = true);

    await tester.enterText(find.widgetWithText(TextField, 'Como podemos te chamar?'), 'Ana');
    await tester.enterText(find.widgetWithText(TextField, 'seu@email.com'), 'ana@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Pelo menos 6 caracteres'), 'senha123');
    await tester.pump();
    await tester.tap(find.text('Criar conta'));
    await tester.pump();
    await tester.pump();

    expect(find.text('E-mail inválido.'), findsOneWidget);
    expect(done, isFalse);
  });

  testWidgets('"Continuar com Google" chama signInWithGoogle e onDone', (tester) async {
    var done = false;
    await pumpRegister(tester, onDone: () => done = true);

    final googleButton = find.text('Continuar com Google');
    await tester.ensureVisible(googleButton);
    await tester.pump();
    await tester.tap(googleButton);
    await tester.pump();
    await tester.pump();

    expect(fakeAuth.hasAccount, isTrue);
    expect(done, isTrue);
  });

  testWidgets('modo mandatory não tem botão de fechar e mostra saída "Continuar sem conta"', (tester) async {
    await pumpRegister(tester, mandatory: true);

    expect(find.text('Continuar sem conta por enquanto'), findsOneWidget);
  });

  testWidgets('modo voluntário (não mandatory) não mostra a saída "Continuar sem conta"', (tester) async {
    await pumpRegister(tester, mandatory: false);

    expect(find.text('Continuar sem conta por enquanto'), findsNothing);
  });
}
