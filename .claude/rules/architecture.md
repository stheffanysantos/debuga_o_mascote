# Regra: Arquitetura

Arquitetura deliberadamente simples — ver `.claude/memory/decisions.md` para o porquê de não usar GetX/Clean Architecture em 3 camadas.

## Camadas

```
lib/
  models/     # Level, Block, Program, Progress — classes de dados puras (sem Flutter)
  game/       # motor de execução: interpreta o Program passo a passo, checa colisão/vitória (sem Flutter)
  screens/    # as 5 telas (StatefulWidget), montam o layout e chamam o motor de jogo
  widgets/    # componentes reutilizados por 2+ telas (prefixo não obrigatório, mas nome descritivo)
  theme/      # paleta, tipografia, tokens (fonte única de cor/estilo — ver .claude/rules/design.md)
  audio/      # sons/haptics (AppSounds) — infraestrutura chamada por screens/widgets, nunca por models/game
  data/       # LeaderboardRepository etc. — infraestrutura chamada por screens/widgets, nunca por models/game
```

## Regra de dependência

- `models/` e `game/` **não importam Flutter** (`package:flutter/...`) — são Dart puro, testáveis com `test` sem precisar de `flutter_test`.
- `screens/` e `widgets/` podem depender de `models/`, `game/`, `theme/`, `audio/` e `data/`, nunca o contrário.
- `game/` não conhece `screens/`/`widgets/` — comunica resultado de cada Passo via callback (ex.: `onStep(GameState state)`), quem decide como animar isso é a tela.
- Nenhuma regra de jogo (condição de vitória/derrota, expansão de `Repetir`) vive dentro de um `Widget` — sempre em `game/`.

## Quando isso pode mudar

Se o projeto crescer além do escopo do estande (mais mundos, comandos novos, mais telas) a ponto de `setState` ficar difícil de seguir, reavaliar a decisão em `.claude/memory/decisions.md` antes de migrar para um pacote de state management.
