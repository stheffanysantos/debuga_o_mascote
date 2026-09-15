import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/audio/app_sounds.dart';
import 'package:debuga_o_mascote/data/app_auth.dart';
import 'package:debuga_o_mascote/screens/register_screen.dart';
import 'package:debuga_o_mascote/screens/world_select_screen.dart';
import 'package:debuga_o_mascote/widgets/icon_action_button_widget.dart';
import 'package:debuga_o_mascote/widgets/settings_dialog_widget.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_sound_player.dart';

/// `SettingsDialog` (`lib/widgets/settings_dialog_widget.dart`) — aberto
/// pelo botão de engrenagem da Seleção de Mundo (não mais da Splash, ver
/// `.claude/memory/decisions.md`), ver `.claude/docs/NAVIGATION_FLOW.md`.
void main() {
  setUp(() => AppSounds.instance.player = FakeSoundPlayer());

  tearDown(() {
    AppSounds.instance.resetForTest();
    AppAuth.instance.resetForTest();
  });

  Future<void> pumpWorldSelectAndOpenSettings(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WorldSelectScreen()));
    await tester.pump();
    // Cabeçalho tem 3 `IconActionButton`: voltar (índice 0), Placar do Dia
    // (índice 1) e configurações (índice 2).
    await tester.tap(find.byType(IconActionButton).at(2));
    await tester.pump();
  }

  testWidgets('tocar o botão de configurações na Seleção de Mundo abre o SettingsDialog', (tester) async {
    await pumpWorldSelectAndOpenSettings(tester);

    expect(find.byType(SettingsDialog), findsOneWidget);
    expect(find.text('CONFIGURAÇÕES'), findsOneWidget);
  });

  testWidgets('o toggle de Som reflete e altera AppSounds.instance.muted', (tester) async {
    await pumpWorldSelectAndOpenSettings(tester);

    expect(AppSounds.instance.muted, isFalse);
    // "Ligado" (valor `true` do Switch) = não mutado.
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(AppSounds.instance.muted, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(AppSounds.instance.muted, isFalse);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('sem conta, mostra "Criar conta" — tocar abre a RegisterScreen (voluntária)', (tester) async {
    AppAuth.instance.service = FakeAuthService();
    await pumpWorldSelectAndOpenSettings(tester);

    expect(find.text('Criar conta'), findsOneWidget);

    await tester.tap(find.text('Criar conta'));
    await tester.pump();

    expect(find.byType(RegisterScreen), findsOneWidget);
    final registerScreen = tester.widget<RegisterScreen>(find.byType(RegisterScreen));
    expect(registerScreen.mandatory, isFalse);
  });

  testWidgets('com conta, mostra "Conectado como <nome>" em vez do link de criar conta', (tester) async {
    AppAuth.instance.service = FakeAuthService(hasAccount: true, displayName: 'ana@example.com');
    await pumpWorldSelectAndOpenSettings(tester);

    expect(find.text('Conectado como ana@example.com'), findsOneWidget);
    expect(find.text('Criar conta'), findsNothing);
  });
}
