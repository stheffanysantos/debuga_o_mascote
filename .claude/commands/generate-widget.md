---
description: Cria um widget reutilizável novo em lib/widgets/, checando duplicação contra o Design System
argument-hint: <NomeDoWidget> "<propósito e onde será usado>"
allowed-tools: Read, Grep, Glob, Write, Edit
---

Crie o widget **$ARGUMENTS** seguindo `.claude/rules/design.md`.

1. Antes de escrever qualquer código, consulte a tabela de inventário em `.claude/memory/design-system.md` — se algo equivalente já existe, estenda em vez de duplicar.
2. Defina a assinatura pública (props) do widget antes da implementação.
3. Zero hardcode de cor/tipografia/espaçamento — usar tokens de `lib/theme/`.
4. Adicione o widget à tabela de inventário de `.claude/memory/design-system.md` (nome, onde é usado, descrição).
5. Escreva um widget test básico (`.claude/templates/widget_test_template.dart`).
