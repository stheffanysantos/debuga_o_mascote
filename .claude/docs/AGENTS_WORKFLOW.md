# Como os Agentes Colaboram

Os 4 subagentes de `.claude/agents/` são especialistas por preocupação. Para tarefas pequenas e sem ambiguidade, não é necessário passar pelo fluxo completo — delegue só ao agente relevante.

```
Game Logic Engineer
   │ define/valida regra de jogo (.claude/docs/GAME_DESIGN.md) antes de qualquer UI
   ▼
UI Engineer
   │ telas, widgets, tema, Design System
   ▼
UX Reviewer
   │ revisão de fluxo/legibilidade/fricção antes do "pronto"
   ▼
Code Reviewer
   │ checklist final (.claude/reviews/code-review-checklist.md), flutter analyze/test
```

## Quando delegar para qual agente

| Situação | Agente |
|---|---|
| Nova regra de jogo, novo comando, condição de vitória/derrota, cálculo de estrelas, criar/validar uma fase | Game Logic Engineer |
| Tela nova, componente de Design System, hardcode de cor/tipografia | UI Engineer |
| Fluxo confuso, onboarding implícito ruim, feedback insuficiente, botão pequeno demais para toque | UX Reviewer |
| Revisão final antes de considerar algo pronto | Code Reviewer |

Para uma feature de porte considerável (ex.: um mundo novo com comando novo), passar pelo fluxo completo acima; para um ajuste pontual (cor de um botão, texto de uma tela), delegar direto ao agente relevante.
