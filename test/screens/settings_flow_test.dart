import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/audio/audio_providers.dart';
import 'package:debuga_o_mascote/core/auth/auth_providers.dart';
import 'package:debuga_o_mascote/core/progress/progress_notifier.dart';
import 'package:debuga_o_mascote/features/auth/presentation/register/register_view.dart';
import 'package:debuga_o_mascote/features/settings/presentation/profile_edit_view.dart';
import 'package:debuga_o_mascote/features/settings/presentation/settings_view.dart';
import 'package:debuga_o_mascote/features/world_select/presentation/world_select_view.dart';
import 'package:debuga_o_mascote/widgets/icon_action_button_widget.dart';
import 'package:debuga_o_mascote/widgets/labeled_text_field_widget.dart';
import 'package:debuga_o_mascote/widgets/primary_pill_button_widget.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/test_container.dart';

/// `SettingsView` (`lib/features/settings/presentation/settings_view.dart`)
/// — tela cheia (substituiu o antigo `SettingsDialog`, um `Dialog` modal, ver
/// `.claude/memory/decisions.md`), aberta pelo botão de engrenagem da
/// Seleção de Mundo. Ver `.claude/docs/NAVIGATION_FLOW.md`.
///
/// Navegação real via `Navigator.push`/`pop` (não mais `showDialog`) usa a
/// transição padrão de página do Material 3, que não termina num único
/// `pump()` (mesmo cuidado de `test/screens/tutorial_flow_test.dart`,
/// `pumpTransition`) — sem pumpar em pedaços, a página de destino ainda
/// aparece com a geometria transitória da animação (fora da tela), e um
/// toque nela erra o alvo.
void main() {
  Future<void> pumpTransition(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<ProviderContainer> pumpWorldSelectAndOpenSettings(WidgetTester tester, {List<Override> overrides = const []}) async {
    final container = createTestContainer(overrides: overrides);
    await tester.pumpWidget(wrapForTest(container, const WorldSelectView()));
    await tester.pump();
    // Cabeçalho tem 3 `IconActionButton`: voltar (índice 0), Placar Geral
    // (índice 1) e configurações (índice 2).
    await tester.tap(find.byType(IconActionButton).at(2));
    await tester.pump();
    await pumpTransition(tester);
    return container;
  }

  testWidgets('tocar o botão de configurações na Seleção de Mundo abre a SettingsView', (tester) async {
    await pumpWorldSelectAndOpenSettings(tester);

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.text('CONFIGURAÇÕES'), findsOneWidget);
  });

  testWidgets('o toggle de Som reflete e altera mutedProvider', (tester) async {
    final container = await pumpWorldSelectAndOpenSettings(tester);

    expect(container.read(mutedProvider), isFalse);
    // "Ligado" (valor `true` do Switch) = não mutado.
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(container.read(mutedProvider), isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(container.read(mutedProvider), isFalse);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('sem conta, mostra "Criar conta" — tocar abre a RegisterView (voluntária)', (tester) async {
    await pumpWorldSelectAndOpenSettings(tester, overrides: [authServiceProvider.overrideWithValue(FakeAuthService())]);

    expect(find.text('Criar conta'), findsOneWidget);

    await tester.tap(find.text('Criar conta'));
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(RegisterView), findsOneWidget);
    final registerScreen = tester.widget<RegisterView>(find.byType(RegisterView));
    expect(registerScreen.mandatory, isFalse);
  });

  testWidgets('sem conta, não mostra o lápis de editar avatar (nome/foto só editáveis com conta)', (tester) async {
    await pumpWorldSelectAndOpenSettings(tester, overrides: [authServiceProvider.overrideWithValue(FakeAuthService())]);

    expect(find.byIcon(Icons.edit), findsNothing);
    expect(find.text('Sair da conta'), findsNothing);
  });

  testWidgets('com conta, mostra "Conectado como <nome>", o lápis de editar avatar e "Sair da conta"', (tester) async {
    await pumpWorldSelectAndOpenSettings(
      tester,
      overrides: [authServiceProvider.overrideWithValue(FakeAuthService(hasAccount: true, displayName: 'ana@example.com'))],
    );

    expect(find.text('Conectado como ana@example.com'), findsOneWidget);
    expect(find.text('Criar conta'), findsNothing);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);
  });

  testWidgets('"Sair da conta" sai da conta e zera o progresso local', (tester) async {
    final container = await pumpWorldSelectAndOpenSettings(
      tester,
      overrides: [authServiceProvider.overrideWithValue(FakeAuthService(hasAccount: true, displayName: 'ana@example.com'))],
    );
    container.read(progressNotifierProvider.notifier).addSessionPoints(300);
    expect(container.read(progressNotifierProvider).sessionScore, 300);

    await tester.tap(find.text('Sair da conta'));
    await tester.pump();

    expect(find.text('Conectado como ana@example.com'), findsNothing);
    expect(find.text('Criar conta'), findsOneWidget, reason: 'volta a mostrar o link de criar conta, agora sem conta');
    expect(find.byIcon(Icons.edit), findsNothing, reason: 'sem conta, o lápis de editar avatar some de novo');
    expect(container.read(progressNotifierProvider).sessionScore, 0, reason: 'progresso local reseta — "próximo jogador" no estande');
  });

  testWidgets('com conta, tocar o lápis do avatar abre a ProfileEditView', (tester) async {
    await pumpWorldSelectAndOpenSettings(tester, overrides: [authServiceProvider.overrideWithValue(FakeAuthService(hasAccount: true))]);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(ProfileEditView), findsOneWidget);
  });

  testWidgets('editar nome de usuário e escolher um personagem salva no Progress e reflete na SettingsView', (tester) async {
    final container = await pumpWorldSelectAndOpenSettings(tester, overrides: [authServiceProvider.overrideWithValue(FakeAuthService(hasAccount: true))]);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();
    await pumpTransition(tester);

    await tester.enterText(find.byType(TextField), 'Capitã Debug');
    await tester.tap(find.text('Libug'));
    await tester.pump();

    await tester.tap(find.byType(PrimaryPillButton));
    await tester.pump();
    await pumpTransition(tester);

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.byType(ProfileEditView), findsNothing);
    expect(find.text('Capitã Debug'), findsOneWidget);
    expect(container.read(progressNotifierProvider).username, 'Capitã Debug');
    expect(container.read(progressNotifierProvider).avatarId, 'libug');
  });

  testWidgets('ProfileEditView pré-preenche com o nome/avatar já salvos', (tester) async {
    final container = createTestContainer();
    container.read(progressNotifierProvider.notifier)
      ..setUsername('Já Salvo')
      ..setAvatarId('libug');
    await tester.pumpWidget(wrapForTest(container, const ProfileEditView()));
    await tester.pump();

    expect(find.text('Já Salvo'), findsOneWidget);
    final labeled = tester.widget<LabeledTextField>(find.byType(LabeledTextField));
    expect(labeled.controller.text, 'Já Salvo');
  });
}
