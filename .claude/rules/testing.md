# Regra: Testes

## Motor de jogo (`lib/game/`) — unit tests, `flutter_test`
Usa-se `flutter_test` para ambos (unit e widget) para não adicionar uma dependência extra (`package:test`) só para isso — o pacote já vem com o `test()`/`expect()` de que a lógica pura precisa.
Prioridade alta — é a lógica que decide vitória/derrota, sem UI envolvida. Cobrir pelo menos:
- Expansão de `Repetir 3×` em passos.
- Colisão com parede (falha).
- Saída do tabuleiro 6×6 (falha).
- Chegada exata no alvo (vitória).
- Programa que termina sem alcançar o alvo (falha por fim de programa, se essa regra existir — confirmar em `.claude/docs/GAME_DESIGN.md`).
- Cálculo de estrelas a partir de blocos usados vs. ótimo da fase.

## Telas (`lib/screens/`, `lib/widgets/`) — widget tests, `flutter_test`
- Cada tela: pelo menos um teste cobrindo o caminho feliz de renderização.
- Gameplay: teste simulando um Programa simples executando e chegando em vitória/falha (pode usar um `Level` de teste minúsculo, ex.: 2×2).
- Nunca testar detalhe visual frágil (pixel exato, cor exata) — testar presença de widget/estado, não aparência.

## Ao criar uma fase (`Level`) nova
Antes de considerar a fase pronta, validar que ela é solucionável dentro do `maxBlocks` — ver `.claude/reviews/checklist-level.md`. Idealmente com um teste automatizado que roda o motor de jogo contra a solução esperada da fase.
