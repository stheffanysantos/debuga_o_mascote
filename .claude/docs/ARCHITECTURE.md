# Arquitetura — Debuga o Mascote

Ver a decisão de fundo em `.claude/memory/decisions.md` (`setState` em vez de GetX/Riverpod) e a regra normativa em `.claude/rules/architecture.md` — este documento é a versão descritiva/narrativa.

## Camadas

```
lib/
  models/     Level, Block, Program, Progress — Dart puro
  game/       motor de execução (interpretador do Program) — Dart puro
  screens/    as 5 telas (StatefulWidget)
  widgets/    componentes reutilizados por 2+ telas
  theme/      paleta, tipografia, tokens
```

## Fluxo de dados (gameplay)

1. `LevelSelectScreen` escolhe um `Level` (dado estático, ver `.claude/reviews/checklist-level.md`) e navega para `GameplayScreen`.
2. `GameplayScreen` mantém o `Program` em construção no seu `State` (lista de `Block`).
3. Ao tocar Play, `GameplayScreen` entrega o `Program` e o `Level` para o motor de jogo (`lib/game/`), que expande `Repetir` em passos e chama `onStep(passo)` a cada movimento.
4. `GameplayScreen` anima cada passo recebido via `onStep` e, ao final, recebe o `GameResult` (vitória/falha + motivo + estrelas).
5. Dependendo do `GameResult`, `GameplayScreen` navega para `VictoryScreen` ou `FailureScreen`, passando o resultado.

## Por que essa divisão
- O motor de jogo não sabe nada sobre Flutter — pode ser testado com `package:test` puro, rápido, sem precisar montar widgets.
- As Screens não têm regra de jogo dentro — apenas orquestram estado de UI e delegam a decisão de vitória/derrota ao motor.

## O que evitar
- Regra de vitória/derrota implementada dentro de um `onPressed` de widget.
- Widget que importa `lib/game/` e reimplementa parte da lógica em vez de usar o resultado do motor.
