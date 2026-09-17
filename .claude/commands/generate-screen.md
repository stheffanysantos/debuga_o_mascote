---
description: Cria uma tela nova (View + ViewModel + State opcionais + widgets específicos + teste) do Debuga o Mascote
argument-hint: <nome-da-feature> "<propósito da tela>"
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie a tela **$ARGUMENTS** seguindo `.claude/rules/architecture.md` e `.claude/rules/design.md`.

1. Leia `.claude/docs/NAVIGATION_FLOW.md` para confirmar onde essa tela entra no fluxo do app, e `.claude/rules/naming.md` para a tabela de sufixos.
2. Decida se a tela precisa de ViewModel (ver `.claude/rules/architecture.md`, "Quando dar ViewModel a uma tela"): só quando há orquestração real (chamada de motor de jogo, requisição assíncrona, formulário com erro/envio). Se for uma tela trivial (lista/navegação direta), pule os passos de ViewModel/State.
3. Gere, sob `lib/features/<nome_da_feature>/presentation/` (crie um subdiretório extra, ex. `gameplay/`/`stage_select/`, se a feature tiver mais de um fluxo):
   - `<nome>_view.dart` — `ConsumerWidget` (sem ViewModel) ou `ConsumerStatefulWidget` (com ViewModel, ou com estado puramente de apresentação/animação que não precisa de Riverpod — ver `TutorialView` como referência). Nunca contém regra de jogo/orquestração — só monta a árvore de widgets a partir de `ref.watch(...)` e repassa toques pro ViewModel.
   - Se precisar de ViewModel: `<nome>_state.dart` (`@freezed`, imutável) e `<nome>_view_model.dart` (`@Riverpod` class — `autoDispose` por padrão; só `keepAlive: true` se o estado precisar sobreviver entre telas, como os providers de `lib/core/`). Efeitos de navegação (`Navigator.push`/`pop`) nunca vivem no ViewModel — ele só seta um campo `pendingEffect`/`Effect` `@freezed sealed` na `State`, que a View consome via `ref.listen`.
   - Widgets específicos em `lib/widgets/` se necessário (reutilizando o que já existe em `.claude/memory/design-system.md`).
   - Widget test cobrindo o caminho feliz (`.claude/rules/testing.md`) — use `createTestContainer()`/`wrapForTest()` (`test/helpers/test_container.dart`), não `ProviderScope` cru, pra já vir com o `FakeSoundPlayer` padrão. Se criou um ViewModel com lógica não-trivial, considere também um teste direto via `ProviderContainer` (mais rápido que widget test) — ver `test/core/progress/progress_notifier_test.dart`.
4. Zero hardcode de cor/tipografia/espaçamento — usar `lib/theme/`.
5. Depois de criar/editar qualquer arquivo `@riverpod`/`@freezed`, rode `dart run build_runner build --delete-conflicting-outputs` e comite os arquivos gerados (`*.g.dart`, `*.freezed.dart`) junto (ver `.claude/rules/git-workflow.md`).
6. Ao final, rode `.claude/reviews/checklist-screen.md` e reporte quais itens foram atendidos.
