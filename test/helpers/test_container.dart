import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/audio/audio_providers.dart';

import 'fake_sound_player.dart';

/// Cria um `ProviderContainer` de teste, já com `soundPlayerProvider`
/// trocado por um `FakeSoundPlayer` (quase todo teste de tela precisa disso
/// — nenhum mock de `MethodChannel` configurado em `test/`, ver
/// `.claude/memory/decisions.md`). Passe overrides extras (`FakeAuthService`,
/// `FakeLeaderboardRepository`, etc.) quando o teste precisar.
///
/// Diferente do `.instance.xxx = Fake...()` + `resetForTest()` de antes da
/// migração pra Riverpod, cada teste ganha um container novo — nada vaza
/// entre `testWidgets`, sem precisar de `tearDown` nenhum.
ProviderContainer createTestContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(
    overrides: [soundPlayerProvider.overrideWithValue(FakeSoundPlayer()), ...overrides],
  );
  addTearDown(container.dispose);
  return container;
}

/// Envolve `child` num `MaterialApp` + `UncontrolledProviderScope` usando o
/// `container` de teste — mesmo padrão usado em `main.dart` (container
/// explícito, não implícito), pra o teste poder ler/mutar providers antes e
/// depois do `pumpWidget` via `container.read(...)`.
Widget wrapForTest(ProviderContainer container, Widget child) {
  return UncontrolledProviderScope(container: container, child: MaterialApp(home: child));
}
