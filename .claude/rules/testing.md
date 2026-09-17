# Regra: Testes

## Motor de jogo (`lib/game/`) — unit tests, `flutter_test`
Usa-se `flutter_test` para tudo (unit e widget) para não adicionar uma dependência extra (`package:test`) só para isso — o pacote já vem com o `test()`/`expect()` de que a lógica pura precisa.
Prioridade alta — é a lógica que decide vitória/derrota, sem UI envolvida. Cobrir pelo menos:
- Expansão de `Repetir 3×` em passos.
- Colisão com parede (falha).
- Saída do tabuleiro 6×6 (falha).
- Chegada exata no alvo (vitória).
- Programa que termina sem alcançar o alvo (falha por fim de programa, se essa regra existir — confirmar em `.claude/docs/GAME_DESIGN.md`).
- Cálculo de estrelas a partir de blocos usados (ou tentativas) vs. ótimo da fase.

## ViewModels (`lib/features/*/presentation/**/*_view_model.dart`) — unit tests via `ProviderContainer`
Lógica de orquestração pesada (loop de execução passo a passo, cálculo de efeito de navegação, gate de cadastro) é testável direto contra o ViewModel, sem montar nenhum widget — mais rápido e mais focado que um widget test:
```dart
final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(_FakeProgressRepository())]);
addTearDown(container.dispose);
final notifier = container.read(progressNotifierProvider.notifier);
notifier.recordWin('fase1', stars: 3, blocksUsed: 2);
expect(container.read(progressNotifierProvider).starsFor('fase1'), 3);
```
Ver `test/core/progress/progress_notifier_test.dart` como referência. Prefira esse padrão a um widget test sempre que a asserção for sobre *estado*, não sobre *renderização*.

## Views (`lib/features/*/presentation/**/*_view.dart`, `lib/widgets/`) — widget tests, `flutter_test`
- Cada View: pelo menos um teste cobrindo o caminho feliz de renderização.
- Gameplay: teste simulando um Programa simples executando e chegando em vitória/falha (pode usar um `Level` de teste minúsculo, ex.: 2×2).
- Nunca testar detalhe visual frágil (pixel exato, cor exata) — testar presença de widget/estado, não aparência.
- Container de teste: use `createTestContainer({overrides})`/`wrapForTest(container, child)` (`test/helpers/test_container.dart`) — já injeta um `FakeSoundPlayer` por padrão; passe overrides extras (`leaderboardRepositoryProvider.overrideWithValue(...)`, `authServiceProvider.overrideWithValue(...)`) quando a tela precisar. Cada teste ganha um `ProviderContainer` novo — nada vaza entre `testWidgets`, sem precisar de `tearDown` manual (diferente do padrão antigo de singleton `.instance.x = Fake...()`/`resetForTest()`).
- Para seedar estado antes de montar a tela (ex.: progresso/onboarding já preenchidos), leia/mute o notifier direto no container antes de `pumpWidget`: `container.read(progressNotifierProvider.notifier).recordWin(...)`.

## Ao criar uma fase (`Level`) nova
Antes de considerar a fase pronta, validar que ela é solucionável dentro do `maxBlocks` — ver `.claude/reviews/checklist-level.md`. Idealmente com um teste automatizado que roda o motor de jogo contra a solução esperada da fase.
