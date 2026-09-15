# Checklist — Fase (Level)

- [ ] `id` único e estável (nunca reaproveitado — ver `.claude/rules/naming.md`).
- [ ] Grid 6×6 com paredes definidas de forma consistente (sem parede sobre a célula de início ou de alvo).
- [ ] `start {x,y,dir}` e `goal {x,y}` dentro dos limites do tabuleiro.
- [ ] **Existe pelo menos uma solução dentro de `maxBlocks`** — comprovado por um teste unitário que roda o motor de jogo contra a solução esperada e confirma vitória.
- [ ] `optimalBlocks` reflete o tamanho real da melhor solução conhecida (usado por `computeScore` — ver `.claude/docs/GAME_DESIGN.md`).
- [ ] `hintProgram` é uma solução válida e testada (mesmo se não for a ótima) — é o que aparece como Dica na tela de Tentativa Falha.
- [ ] Fase registrada na lista de fases do mundo correspondente, na posição correta (afeta bloqueio/desbloqueio na tela de Seleção de Fases).
