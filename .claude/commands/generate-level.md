---
description: Cria uma fase (Level) nova, validando que é solucionável dentro do maxBlocks
argument-hint: <world> <levelId> "<descrição/objetivo da fase>"
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie a fase **$ARGUMENTS** seguindo `.claude/docs/GAME_DESIGN.md`.

1. Leia `.claude/templates/level_template.dart` e `.claude/memory/domain-glossary.md` (campos de `Level`: grid 6×6, `start {x,y,dir}`, `goal {x,y}`, `maxBlocks`, `starThresholds`).
2. Defina o tabuleiro (paredes) e a posição/direção inicial e o alvo, garantindo que existe pelo menos uma solução dentro de `maxBlocks`.
3. Escreva um teste unitário (`.claude/templates/unit_test_template.dart`) que roda o motor de jogo (`lib/game/`) contra a solução esperada e confirma vitória — isso é a prova de que a fase é solucionável.
4. Rode `.claude/reviews/checklist-level.md` antes de considerar a fase pronta.
5. Registre o `id` da fase (estável, nunca reaproveitado — ver `.claude/rules/naming.md`) no local onde as fases do mundo são listadas.
