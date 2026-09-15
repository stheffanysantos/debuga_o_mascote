---
description: Cria uma tela nova (Screen + widgets específicos + teste) do Debuga o Mascote
argument-hint: <nome-da-tela> "<propósito da tela>"
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie a tela **$ARGUMENTS** seguindo `.claude/rules/architecture.md` e `.claude/rules/design.md`.

1. Leia `.claude/docs/NAVIGATION_FLOW.md` para confirmar onde essa tela entra no fluxo das 5 telas, e `.claude/templates/screen_template.dart`.
2. Gere:
   - `lib/screens/<nome_da_tela>_screen.dart` (`StatefulWidget`, sem regra de jogo dentro — delega a `lib/game/`).
   - Widgets específicos em `lib/widgets/` se necessário (reutilizando o que já existe em `.claude/memory/design-system.md`).
   - Widget test cobrindo o caminho feliz (`.claude/rules/testing.md`, `.claude/templates/widget_test_template.dart`).
3. Zero hardcode de cor/tipografia/espaçamento — usar `lib/theme/`.
4. Ao final, rode `.claude/reviews/checklist-screen.md` e reporte quais itens foram atendidos.
