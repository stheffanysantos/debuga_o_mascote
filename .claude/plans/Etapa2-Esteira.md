# Etapa 2 — Motor "Esteira" (Mundo 2, "Esteira de Bugs")

## Como usar este arquivo

Quando for continuar, abra o Claude Code neste projeto e mande algo como:

> Leia `.claude/plans/Etapa2-Esteira.md` e implemente a Etapa 2 descrita nele.

Isso é tudo que precisa dizer — este arquivo tem o contexto e o escopo completos para o Claude pegar do zero, sem precisar da conversa anterior.

## Contexto

Este projeto está migrando de "1 mundo" para "3 mundos = 3 mini-jogos de lógica diferentes" (ver `.claude/plans/Mundos.md` para a arquitetura completa e o porquê da decisão, e `.claude/memory/decisions.md`, entrada "2026-09-05 — 3 mundos = 3 motores de jogo diferentes").

- **Etapa 1 (já implementada e commitada)**: infraestrutura de mundo — `GameWorld`/`WorldGameType`/`worlds` em `lib/models/level.dart`, a tela `lib/screens/world_select_screen.dart` (Seleção de Mundo, entre Splash e Seleção de Fases), e o widget compartilhado `lib/widgets/stage_select_grid_widget.dart`. Mundo 1 (labirinto) está jogável com as 12 fases de sempre. Mundo 2 e Mundo 3 existem como entradas em `worlds` com `comingSoon: true` e `levels: const []` — aparecem na Seleção de Mundo com selo "EM BREVE", não tocáveis.
- **Esta etapa (Etapa 2)**: dar motor de verdade ao Mundo 2 — "Esteira de Bugs". Depois dela, Mundo 2 deixa de ser `comingSoon` e vira jogável, com 12 fases.
- **Etapa 3** (não é este arquivo — ver `.claude/plans/Mundos.md`, seção "Etapa 3"): motor de puzzles de código pro Mundo 3, fica para depois.

### O jogo do Mundo 2

Itens (bugs de 2 cores) chegam numa esteira, um de cada vez, numa fila fixa por fase (ex.: amarelo, amarelo, roxo, amarelo...). O jogador monta um Programa com blocos que classificam o item atual:

- **"Se Amarelo → Caixa A"** — só correto se o próximo item da fila for amarelo.
- **"Se Roxo → Caixa B"** — só correto se o próximo item da fila for roxo.
- **"Repetir 3×"** — aplica-se ao bloco seguinte, processando 3 itens seguidos com ele (mesmo conceito de `Repetir` do Mundo 1).

Ao apertar Play, o programa expandido roda um bloco por item da fila, na ordem. Se o bloco não bate com a cor real do item (ex.: "Se Amarelo" aplicado a um item roxo) → falha (equivalente a "bater na parede" no labirinto). Se o programa processa toda a fila sem erro → vitória. Se o programa acaba antes de processar toda a fila → falha (equivalente a "não chegou ao alvo").

Isso espelha deliberadamente a forma do motor do Mundo 1 (`lib/game/program_executor.dart`) — mesmo formato de `expand`/`applyStep`/`evaluateFinal` — só trocando "grid + colisão de parede" por "fila de itens + classificação errada".

## Escopo desta etapa

### 1. Modelos novos (Dart puro, sem `package:flutter/...` — ver `.claude/rules/architecture.md`)

- `lib/models/belt_item.dart`: `enum BeltItemColor { yellow, purple }`.
- `lib/models/belt_block.dart`: `enum BeltBlockType { ifYellowToBinA, ifPurpleToBinB, repeat }` + classe `BeltBlock` (mesma forma de `lib/models/block.dart`: campo `type`, `operator ==`/`hashCode`).
- `lib/models/conveyor_level.dart`: classe `ConveyorLevel` — mesma forma de `Level` (`lib/models/level.dart`): `id`, `world` (sempre `2`), `number` (1–12), `title`, `itemQueue: List<BeltItemColor>`, `maxBlocks`, `optimalBlocks`, `hintProgram: List<BeltBlock>`. Adicionar `final world2Levels = <ConveyorLevel>[...]` com as 12 fases (dificuldade crescente: filas mais longas, misturas de cor que exigem trocar de bloco no meio da sequência, uso obrigatório de `Repetir` para caber no `maxBlocks`). Cada fase precisa de um `hintProgram` verificado (ver seção Testes).
- Em `lib/models/level.dart`: atualizar a entrada do Mundo 2 em `worlds` — trocar `comingSoon: true`/`levels: const []` por `comingSoon: false`. Como `GameWorld.levels` hoje é `List<Level>` (tipado para o motor do labirinto), você vai precisar generalizar esse campo para aceitar as fases de qualquer motor — a forma mais simples que se encaixa no resto do código (`StageSelectGrid` já trabalha só com `StageTileData`, não com `Level` diretamente) é seguir o padrão de "cada motor sabe construir sua própria lista de `StageTileData` a partir de `Progress`", então `GameWorld` pode ganhar um campo genérico (ex. `List<Object> levels` ou um tipo selado) — decida a forma mais limpa ao chegar nesse ponto; o importante é `WorldSelectScreen`/roteamento não dependerem de `Level` do labirinto especificamente para saber "quantas fases tem esse mundo" e "essa fase específica está concluída" (isso já vem de `Progress.instance` por `id`, que é `String` para qualquer motor).

### 2. Motor (Dart puro): `lib/game/belt_executor.dart`

Mesmo formato de `lib/game/program_executor.dart`:
- `expand(List<BeltBlock> program) → List<ExecutionStep>` (ou tipo equivalente): expande `repeat` em N passos do bloco seguinte, igual à lógica já existente em `ProgramExecutor.expand` (pode literalmente copiar essa função, já que a regra de expansão de `Repetir` é idêntica — considere até extrair um helper genérico compartilhado se dois motores repetirem a mesma lógica, para não duplicar).
- Um "cursor" equivalente a `GameCursor`, mas para a esteira: guarda o índice do próximo item da fila ainda não processado.
- `applyStep`: dado o passo atual (um `BeltBlockType`) e o cursor, verifica se o bloco bate com a cor do item na posição atual da fila; se não bater, retorna um outcome de erro (equivalente a `crashed`); se bater, avança o cursor pra o próximo item.
- `evaluateFinal`: fila totalmente processada → vitória; sobrou item não processado → falha.
- Reaproveite `lib/game/game_result.dart` (`GameOutcome`) se fizer sentido, ou estenda com um novo valor (ex. `misclassified`) — decidir ao implementar, documentando em `.claude/docs/GAME_DESIGN.md` antes.

### 3. Telas

- `lib/screens/conveyor_stage_select_screen.dart`: mesmo papel de `lib/screens/level_select_screen.dart`, mas para `world2Levels` — reaproveita `lib/widgets/stage_select_grid_widget.dart` (`StageSelectGrid`) do mesmo jeito.
- `lib/screens/conveyor_gameplay_screen.dart`: mesmo papel de `lib/screens/gameplay_screen.dart` — cabeçalho (voltar, "FASE N", contador de blocos), uma área central mostrando a esteira com os próximos itens (fila) e 2 caixas nas laterais em vez do tabuleiro 6×6, área "Seu Programa" com os blocos montados, e os botões de comando (agora "Se Amarelo → Caixa A" / "Se Roxo → Caixa B" / "Repetir 3×") + Play. Reaproveitar o máximo de widgets existentes: `CommandButton`, `ProgramBlockChip`, `PrimaryPillButton`, `IconActionButton`, `block_chip_style.dart` (crie um equivalente `belt_block_chip_style.dart` — mesma ideia de `styleForBlock`, mas pra `BeltBlockType`).
- **Vitória/Falha**: como a pontuação do Mundo 2 usa a mesma fórmula do Mundo 1 (`computeScore`, blocos usados vs. `optimalBlocks`, ver `lib/game/scoring.dart`), vale a pena desacoplar `lib/screens/victory_screen.dart`/`lib/screens/failure_screen.dart` do `Level` do labirinto (hoje leem `level.number`/`level.maxBlocks`/`level.hintProgram` diretamente) para um formato genérico — por exemplo, os dois construtores passam a receber `levelNumber`, `maxBlocks`, `blocksUsed`, `optimalBlocks`, e uma `List<Widget> hintChips` já renderizada pelo chamador (em vez de `List<Block>` cru) — permitindo que `GameplayScreen` (Mundo 1) e `ConveyorGameplayScreen` (Mundo 2) montem os mesmos dados a partir de tipos diferentes e cheguem nas mesmas telas de resultado.

### 4. Documentação (mesma disciplina da Etapa 1)

- `.claude/docs/GAME_DESIGN.md`: nova seção "## Mundo 2 — Esteira" com a mecânica descrita acima (regras do programa, condições de vitória/derrota) **antes** de codar o motor — ver a própria instrução do arquivo.
- `.claude/memory/domain-glossary.md`: novos termos ("Esteira", "Caixa", "Item"/"Bug (esteira)"), e atualizar a entrada "Mundo" para tirar o "comingSoon" do Mundo 2.
- `.claude/docs/NAVIGATION_FLOW.md`, `.claude/docs/FOLDER_STRUCTURE.md`, `.claude/memory/design-system.md` (novo `belt_block_chip_style.dart` se vantajoso registrar), `.claude/memory/decisions.md` (nova entrada registrando as escolhas concretas feitas ao implementar, especialmente o formato final de `GameWorld.levels`/generalização de Vitória-Falha).

### 5. Testes

- `test/game/conveyor_level_catalog_test.dart` (nos moldes de `test/game/level_catalog_test.dart`): as 12 fases de `world2Levels` são solucionáveis dentro do `maxBlocks` usando o próprio `hintProgram`, rodando `BeltExecutor` de verdade.
- `test/game/belt_executor_test.dart` (nos moldes de `test/game/program_executor_test.dart`): expansão de `Repetir`, classificação errada gera falha, fila processada até o fim gera vitória, programa curto demais gera falha.
- `test/screens/no_overflow_test.dart`: adicionar `ConveyorStageSelectScreen`/`ConveyorGameplayScreen` (e telas de resultado, se generalizadas) ao mapa de telas testadas.
- Um teste de fluxo real (`test/screens/conveyor_flow_test.dart`, no espírito de `test/screens/gameplay_flow_test.dart`): monta um programa simples, aperta Play, confirma navegação real para Vitória/Falha com dados reais da partida.

## Ordem de execução recomendada

Mesmo fluxo de agentes de `.claude/docs/AGENTS_WORKFLOW.md`, que funcionou bem na Etapa 1:

1. **Game Logic Engineer**: modelos (`BeltItemColor`, `BeltBlockType`, `BeltBlock`, `ConveyorLevel`, `world2Levels` com as 12 fases + `hintProgram` verificado), `belt_executor.dart`, `GAME_DESIGN.md`/`domain-glossary.md`, testes de motor.
2. **UI Engineer**: telas novas, `belt_block_chip_style.dart`, o refactor de Vitória/Falha para formato genérico, `design-system.md`/`NAVIGATION_FLOW.md`, testes de tela.
3. **UX Reviewer**: fricção da esteira (é óbvio o que cada bloco faz sem instrução prévia? o feedback de "classificou errado" é claro?).
4. **Code Reviewer**: `flutter analyze` + `flutter test` (suite inteira) + checklist final antes de considerar pronto — e sempre rodar você mesmo (ou pedir que o Claude rode) esses dois comandos ao final, não só confiar no relato de um agente sem acesso a shell.

## Verificação final

- `flutter analyze` sem issues.
- `flutter test` com a suíte inteira passando (Mundo 1 continua intacto — nenhuma fase/telas antigas devem quebrar).
- Rodar o app e jogar manualmente: Seleção de Mundo → Mundo 2 (agora jogável, sem "EM BREVE") → Seleção de Fases do Mundo 2 → jogar uma fase da esteira → ver Vitória/Falha com dados reais → "Próxima fase" avança dentro do Mundo 2 corretamente.
