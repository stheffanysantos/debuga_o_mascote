---
description: Roda o checklist de UI/UX numa tela existente do Debuga o Mascote
argument-hint: <nome-da-tela ou caminho do arquivo>
allowed-tools: Read, Grep, Glob
---

Revise **$ARGUMENTS** contra:

1. `.claude/rules/design.md` (hardcode de cor/tipografia/espaçamento, uso de `yellowNeon` na ação primária).
2. `.claude/memory/design-system.md` (componentes duplicados que já existem no inventário).
3. `.claude/reviews/checklist-screen.md`.
4. Aspectos de fluxo/legibilidade descritos em `.claude/agents/ux-reviewer.md` (onboarding implícito, feedback imediato, botões grandes o suficiente para toque em estande).

Reporte achados como lista objetiva (arquivo, linha quando aplicável, regra violada e correção sugerida) — não aprove com ressalvas vagas.
