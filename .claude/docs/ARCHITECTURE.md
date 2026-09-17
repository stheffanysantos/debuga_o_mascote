# Arquitetura — Debuga o Mascote

Ver a decisão de fundo em `.claude/memory/decisions.md` (migração para Riverpod + MVVM + Clean Architecture pragmática, entrada de 2026-09-16 — supera a decisão original de `setState`) e a regra normativa em `.claude/rules/architecture.md` — este documento é a versão descritiva/narrativa.

## Camadas

```
lib/
  models/     Level, Block, LevelProgress, GameTrack — entidades de domínio, Dart puro
  game/       motores de execução por mundo (interpretador do Programa) — Dart puro
  core/       infraestrutura transversal via provider (progress/onboarding/auth/leaderboard/audio)
  widgets/    componentes de Design System reutilizados por 2+ features
  theme/      paleta, tipografia, tokens
  features/   um diretório por mundo/tela, cada um com presentation/{view,view_model,state}
```

## Fluxo de dados (gameplay, usando o Mundo 1 — labirinto — como exemplo)

1. `StageSelectView` (`lib/features/maze/presentation/stage_select/`) lê `world.levels`, deriva o status de cada fase de `progressNotifierProvider` e navega para `GameplayView(levelId: level.id)`.
2. `GameplayViewModel` (`@riverpod` family por `levelId`) monta o `Level`/`GameplayState` inicial (`program: []`, cursor no início) — a View só lê esse estado via `ref.watch`.
3. Cada toque num comando chama um método do ViewModel (`addBlock`, `removeBlockAt`), que devolve uma cópia nova do `GameplayState` (`copyWith`).
4. Ao tocar Play, `GameplayViewModel.run()` expande o Programa via `ProgramExecutor` (`lib/game/`), avança passo a passo (`await Future.delayed(...)` entre passos, checando um flag `_disposed` em vez de `Ref.mounted`, que não existe nesta versão do riverpod) e muta `state.cursor`/`state.currentStepBlockIndex` a cada passo — a View reflete isso automaticamente via `ref.watch`.
5. Ao terminar, o ViewModel chama `RecordLevelWinUseCase` (se venceu) e seta `state.pendingEffect` (`GameplayEffect.navigateToVictory`/`navigateToFailure`) — nunca manipula `Navigator` diretamente.
6. `GameplayView` escuta `pendingEffect` via `ref.listen` e faz o `Navigator.push` real para `VictoryView`/`FailureView` (`lib/features/result/presentation/`), passando os dados já prontos.

## Por que essa divisão
- O motor de jogo (`lib/game/`) e as entidades de domínio (`lib/models/`) não sabem nada sobre Flutter nem Riverpod — podem ser testados com `package:test`/`flutter_test` puro, rápido, sem precisar montar widgets nem `ProviderContainer`.
- O ViewModel concentra toda orquestração (quando chamar o motor, quando navegar, quando persistir) — a View só renderiza `state` e repassa toques.
- Efeitos de navegação vivem no `state` (`pendingEffect`), não em callbacks imperativos espalhados — um único ponto (`ref.listen` na View) decide como cada efeito vira uma navegação real.

## O que evitar
- Regra de vitória/derrota implementada dentro de um `onTap` de widget ou dentro do ViewModel sem passar pelo motor de jogo.
- Widget que importa `lib/game/` e reimplementa parte da lógica em vez de usar o resultado do motor.
- ViewModel chamando `Navigator`/lendo `BuildContext` diretamente — sempre via `pendingEffect` consumido pela View.
- ViewModel para uma tela sem orquestração real (ver `.claude/rules/architecture.md`, "Quando dar ViewModel a uma tela").
