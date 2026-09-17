# Regra: Arquitetura

Riverpod + MVVM + Clean Architecture pragmática — ver `.claude/memory/decisions.md` (entrada de 2026-09-16) para o porquê da migração a partir do `setState` original.

## Camadas

```
lib/
  models/     # Level, Block, LevelProgress, GameTrack — entidades de domínio, dado puro (sem Flutter, sem Riverpod)
  game/       # motor de execução por mundo: interpreta o Programa passo a passo, checa colisão/vitória (sem Flutter, sem Riverpod)
  core/       # infraestrutura transversal, exposta via provider (era: singletons em data/+audio/)
    progress/   ProgressNotifier, ProgressRepository, RecordLevelWinUseCase
    onboarding/ OnboardingNotifier
    auth/       AuthService (interface) + FirebaseAuthService + authServiceProvider
    leaderboard/ LeaderboardRepository (interface) + implementações + leaderboardRepositoryProvider
    audio/      SoundPlayer (interface) + implementação + soundPlayerProvider/mutedProvider/appSoundsProvider
    device_identity.dart
  theme/      # paleta, tipografia, tokens (fonte única de cor/estilo — ver .claude/rules/design.md)
  widgets/    # componentes de Design System reutilizados por 2+ features (ConsumerWidget quando lê provider, senão StatelessWidget)
  features/
    <mundo|tela>/
      presentation/
        <sub-fluxo>/
          <nome>_view.dart        # ConsumerWidget/ConsumerStatefulWidget — só renderiza + repassa toques
          <nome>_view_model.dart  # @riverpod class, só quando há orquestração real (ver "Quando dar ViewModel" abaixo)
          <nome>_state.dart       # @freezed, imutável
  main.dart   # runApp envolto em ProviderScope/UncontrolledProviderScope
```

Hoje `lib/features/` tem uma pasta por mundo de jogo (`maze`, `conveyor`, `predict_output`, `complete_code`, `code_puzzle`, cada uma com `presentation/{gameplay,stage_select}/`) mais uma por tela transversal (`world_select`, `tutorial`, `leaderboard`, `auth/register`, `survey`, `splash`) e `result/presentation/` (telas de resultado genéricas — `VictoryView`/`FailureView`/`CodePuzzleResultView` — reaproveitadas por vários mundos).

## Regra de dependência

- `models/` e `game/` **não importam Flutter nem Riverpod** — são Dart puro, testáveis com `test` sem precisar de `flutter_test`/`ProviderContainer`. Nenhum dos dois lê `ref`/provider algum.
- `features/*/presentation/` pode depender de `models/`, `game/`, `core/`, `theme/`, `widgets/` e de outras `features/*/presentation/` (ex.: `maze` navega para `result`), nunca o contrário.
- `game/` não conhece `features/`/`widgets/` — expõe o resultado de cada Passo via retorno de função (`ExecutionStep`, `StepOutcome` etc.), quem decide como animar isso é o ViewModel.
- Nenhuma regra de jogo (condição de vitória/derrota, expansão de `Repetir`) vive dentro de um `Widget` ou `ViewModel` — sempre em `game/`. O ViewModel só orquestra (quando chamar o motor, quando navegar, quando persistir).
- `core/` é chamado por `features/`, nunca o contrário — e nunca por `models/`/`game/`.

## View / ViewModel / State

- **View**: `ConsumerWidget` (sem estado local próprio) ou `ConsumerStatefulWidget` (quando há estado puramente de apresentação/animação — timers, `AnimationController`, `TextEditingController` — que não precisa sobreviver fora da tela nem ser lido de fora). Só monta a árvore de widgets a partir de `ref.watch(xViewModelProvider)` e repassa toques para `ref.read(xViewModelProvider.notifier)`.
- **ViewModel**: `@Riverpod` class (`autoDispose` por padrão — só `keepAlive: true` para estado que precisa sobreviver entre telas, ver `core/`). Dono de toda orquestração: chamar o motor de jogo, decidir quando navegar (via um campo `pendingEffect`/`Effect` `@freezed sealed` na própria `State`, consumido pela View com `ref.listen`), persistir progresso.
- **State**: `@freezed`, imutável, sem lógica de negócio além de getters derivados triviais.
- **Efeito de navegação**: sem router (`go_router`/`auto_route` seria desproporcional para 16+ telas) — a View escuta `pendingEffect` via `ref.listen` e decide o `Navigator.push`/`pop` real; o ViewModel só decide *que* efeito disparar, nunca manipula `BuildContext`/`Navigator` diretamente.

### Quando dar ViewModel a uma tela

Nem toda tela ganha `_view_model.dart`/`_state.dart` — só quando há orquestração real (chamada de motor de jogo, requisição assíncrona, formulário com estado de erro/envio). Telas triviais (`WorldSelectView`, `SplashView`, `StageSelectView` de cada mundo, `SurveyView`) ficam só como `ConsumerWidget`/`ConsumerStatefulWidget` lendo `ref.watch(...)` direto no `build()` — forçar um ViewModel ali seria cerimônia sem ganho (ver `.claude/memory/decisions.md`).

## Firebase / repositórios

Toda integração externa (Firestore, Firebase Auth, `audioplayers`) vive atrás de uma interface em `core/<área>/` (`AuthService`, `LeaderboardRepository`, `SoundPlayer`, `ProgressRepository`), resolvida por um `@Riverpod(keepAlive: true)` provider — nunca chamada direto de dentro de `features/`. Isso é o que permite trocar a implementação (local ↔ Firebase) ou injetar um fake em teste (`ProviderScope(overrides: [...])`/`ProviderContainer(overrides: [...])`) sem tocar em nenhuma View/ViewModel.

## Quando isso pode mudar

Se um mundo/fluxo futuro precisar de navegação não-linear de verdade (deep links, back-stack complexo), reavaliar introduzir `go_router` — hoje `Navigator` imperativo + `pendingEffect` é suficiente para o tamanho do app.
