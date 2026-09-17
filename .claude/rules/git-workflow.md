# Regra: Git / Commits

Projeto pequeno, sem hooks automáticos (ver `.claude/memory/decisions.md`) — a disciplina aqui é convenção, não bloqueio de ferramenta.

## Commits
- Mensagem no imperativo, curta, em português: `Adiciona tela de seleção de fases`, `Corrige colisão com parede diagonal`.
- Um commit por unidade lógica (uma tela, um comando, uma fase nova) — evitar commits que misturam refactor com feature nova.

## Antes de commitar
- Rodar `flutter analyze` e `flutter test` — sem hook bloqueando, então isso é responsabilidade de quem commita (ou do agente **Code Reviewer**, ver `.claude/agents/code-reviewer.md`).
- Se alguma classe `@riverpod`/`@freezed` mudou (qualquer `_view_model.dart`, `_state.dart`, `_notifier.dart`), rodar `dart run build_runner build --delete-conflicting-outputs` **antes** de rodar `flutter analyze`/`flutter test` e comitar os arquivos gerados (`*.g.dart`, `*.freezed.dart`) junto — eles ficam versionados no repositório (decisão pragmática pra time pequeno sem CI: `git pull` já compila sem precisar lembrar de rodar codegen, ver `.claude/memory/decisions.md`).
- Conferir `.claude/reviews/code-review-checklist.md` para mudanças de tela/widget.
