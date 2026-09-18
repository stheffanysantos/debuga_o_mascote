# Game Design — Debuga o Mascote

Fonte de verdade das regras do jogo. Qualquer mudança de regra é escrita aqui **antes** de implementada no motor de jogo (`lib/game/`) — ver `.claude/agents/game-logic-engineer.md`.

O jogo tem 5 mundos, cada um um mini-jogo de lógica de programação diferente, com seu próprio motor (`GameWorld`/`WorldGameType`, `lib/models/level.dart`), agrupados em 2 Trilhas (`GameTrack`, `lib/models/game_track.dart`): a Trilha 1 ("Fundamentos") tem os Mundos 1-3; a Trilha 2 ("Avançado") tem os Mundos 4-5. Este documento descreve as regras do **Mundo 1 — Labirinto**, do **Mundo 2 — Esteira**, do **Mundo 3 — Preveja a Saída**, do **Mundo 4 — Complete o Código** e do **Mundo 5 — Modo Debug**.

## Mundo 1 — Labirinto

## Tabuleiro
- Grade fixa **6×6**.
- Cada célula é: livre, parede, início do Mascote, ou alvo (`</>`).
- Paredes são renderizadas em roxo listrado; o alvo pulsa em amarelo neon.

## Comandos disponíveis
| Comando | Efeito |
|---|---|
| **Andar** | Move o Mascote 1 casa na direção para a qual ele está olhando. |
| **Virar Esquerda** | Gira o Mascote 90° à esquerda, sem mover de casa. |
| **Virar Direita** | Gira o Mascote 90° à direita, sem mover de casa. |
| **Repetir 3×** | Aplica-se ao próximo bloco do programa, executando-o 3 vezes seguidas. |

## Regras do programa
- Máximo de **8 blocos** por programa (`Repetir 3×` conta como 1 bloco do total, mesmo controlando 3 repetições do bloco seguinte).
- O programa é montado tocando os botões de comando; tocar um bloco já adicionado o remove.

## Execução
- Ao tocar Play, o programa é expandido em passos (`Repetir` vira N passos do bloco alvo) e executado um passo por vez, com animação do Mascote.
- Durante a execução, o bloco atualmente em execução fica destacado na área "Seu programa".

## Condições de fim de execução
| Condição | Resultado |
|---|---|
| Mascote termina um passo exatamente na célula do alvo | **Vitória** |
| Mascote tenta mover para uma célula de parede | **Falha** — motivo: "bateu na parede" |
| Mascote tenta mover para fora do tabuleiro 6×6 | **Falha** — motivo: "saiu do tabuleiro" |
| Programa termina (todos os passos executados) sem o Mascote estar no alvo | **Falha** — motivo: "não chegou ao alvo" |

## Pontuação e estrelas
Implementado em `lib/game/scoring.dart` (`computeScore`), chamado só após uma vitória, a partir de `Level.optimalBlocks` (blocos da melhor solução conhecida) e dos blocos realmente usados pelo jogador:

| Blocos usados vs. ótimo | Estrelas |
|---|---|
| Até 1 a mais que o ótimo | 3 |
| Até 3 a mais que o ótimo | 2 |
| Mais que isso | 1 |

Pontos: 300 no ótimo, -50 por bloco extra, com piso de 50. Tela de Vitória (`VictoryScreen`) recebe `level`/`blocksUsed` reais da partida jogada em `GameplayScreen` — nada de números fixos de exemplo.

## Dica (tela de Tentativa Falha)
- `Level.hintProgram` guarda uma solução válida conhecida da fase (não necessariamente a ótima) — `FailureScreen` renderiza essa sequência de verdade como Dica, a partir do `Level` realmente jogado.
- O motivo da falha mostrado (`GameOutcome.crash` vs. `GameOutcome.farFromGoal`) também é o resultado real da Execução, não um texto de exemplo.

## Mundo 2 — Esteira

Mini-jogo de lógica diferente do Mundo 1: sem grid, sem Mascote andando. Itens (bugs de 2 cores) chegam numa **Esteira**, um de cada vez, numa fila fixa por fase (`ConveyorLevel.itemQueue`). O jogador monta um Programa com blocos que classificam o item atual, mandando-o para uma **Caixa**.

### Itens e cores
- Cada **Item** da fila tem uma cor: amarelo ou roxo (`BeltItemColor`, `lib/models/belt_item.dart`).
- A fila (`itemQueue`) é fixa por fase e conhecida antes de o jogador montar o Programa (não há aleatoriedade).

### Comandos disponíveis
| Comando | Efeito |
|---|---|
| **Se Amarelo → Caixa A** | Classifica o item atual da fila como amarelo, mandando-o para a Caixa A. Só correto se o item realmente for amarelo. |
| **Se Roxo → Caixa B** | Classifica o item atual da fila como roxo, mandando-o para a Caixa B. Só correto se o item realmente for roxo. |
| **Repetir 3×** | Aplica-se ao próximo bloco do programa, executando-o 3 vezes seguidas (mesmo conceito de `Repetir` do Mundo 1) — processa 3 itens seguidos da fila com o bloco seguinte. |
| **Enquanto Amarelo → Caixa A** | Classifica, um a um, todos os itens **consecutivos** a partir do item atual que forem amarelos, mandando cada um para a Caixa A — para assim que encontrar um item de cor diferente (ou a fila acabar). Introduzido nas fases mais difíceis (a partir da Fase 9) — ver "Enquanto" abaixo. |
| **Enquanto Roxo → Caixa B** | Mesma ideia de "Enquanto Amarelo", para itens roxos e Caixa B. |

### "Enquanto" — repetição condicional (diferente de "Repetir")
- **"Repetir 3×"** é uma repetição **fixa**: sempre 3 vezes, não importa o conteúdo da fila (é um modificador aplicado ao bloco seguinte, igual ao Mundo 1).
- **"Enquanto [cor] → Caixa"** é uma repetição **condicional**: testa a cor do item atual antes de cada repetição, como um `while` de verdade — continua enquanto a condição for verdadeira, sem contagem fixa. Diferente de "Se", **não é possível "errar" um bloco "Enquanto"**: se o item atual já não for da cor esperada quando o bloco roda, ele simplesmente classifica **zero** itens (a condição já começa falsa) e o Programa segue pro próximo bloco — sem falha, sem penalidade (mesmo princípio de "falha nunca é punitiva" do `CLAUDE.md`, levado para dentro da regra do motor). É um bloco **autocontido** (não é um modificador como `Repetir` — não se aplica "ao bloco seguinte", ele mesmo é a instrução completa).
- Conta como **1 bloco** do total de `maxBlocks`, não importa quantos itens ele acabe classificando em tempo de execução.
- Combinar `Repetir` sobre um bloco `Enquanto` é permitido (não é bloqueado na UI) mas raramente útil: a segunda/terceira aplicação do `Repetir` testa a condição de novo a partir de onde a aplicação anterior parou — geralmente já falsa (o "Enquanto" anterior já consumiu tudo que dava pra consumir), então normalmente não classifica nada a mais. Não é um erro, só não ajuda a resolver a fase.

### Regras do programa
- Máximo de blocos por programa definido por `ConveyorLevel.maxBlocks` (mesma ideia de `Level.maxBlocks` do Mundo 1 — `Repetir 3×`/`Enquanto` contam como 1 bloco do total cada).
- O programa é montado tocando os botões de comando, na ordem em que os itens chegam na Esteira.

### Execução
- Ao tocar Play, o programa é expandido em passos e executado um passo por vez: cada passo tenta classificar o próximo item ainda não processado da fila.
  - `Repetir` vira N passos do bloco alvo (mesma expansão do Mundo 1) — não depende do conteúdo da fila.
  - `Enquanto [cor]` vira 0 ou mais passos — **depende do conteúdo real da fila** (`ConveyorLevel.itemQueue`) na posição em que o bloco é alcançado: a expansão "olha pra frente" na fila a partir de onde a Execução chegaria naquele ponto (assumindo os blocos anteriores classificaram certo) e gera um passo pra cada item consecutivo da cor esperada, parando no primeiro item de cor diferente ou no fim da fila.
- Um passo classifica errado quando o bloco não bate com a cor real do item na posição atual da fila (ex.: "Se Amarelo → Caixa A" aplicado a um item roxo), ou quando não há mais itens a classificar (passo sobrando depois que a fila já acabou). Isso vale para `Se`/`Repetir` — passos gerados por `Enquanto` nunca classificam errado (ver acima).

### Condições de fim de execução
| Condição | Resultado |
|---|---|
| Todos os itens da fila foram classificados corretamente | **Vitória** |
| Um bloco classifica um item com a cor errada (ou sobra passo com a fila já vazia) | **Falha** — motivo: "classificou um item errado" |
| Programa termina (todos os passos executados) sem processar toda a fila | **Falha** — motivo: "sobraram itens na esteira" |

### Resultado da Execução (motor)
`lib/game/belt_executor.dart` (`BeltExecutor`) espelha deliberadamente a forma de `ProgramExecutor` (Mundo 1) — `expand`/`applyStep`/`evaluateFinal` — mas com um enum de resultado próprio, `BeltOutcome` (`win`/`misclassified`/`incomplete`), em vez de reaproveitar `GameOutcome` do Mundo 1. Decisão: `GameOutcome` já tem um switch exaustivo consumido pelas telas do Mundo 1 (`FailureScreen`); estender esse enum compartilhado misturaria dois motores diferentes num mesmo tipo e arriscaria acoplar Mundo 1/Mundo 2 sem necessidade. `BeltOutcome.misclassified` é o equivalente semântico de `GameOutcome.crash` (bateu numa regra do motor no meio da Execução) e `BeltOutcome.incomplete` é o equivalente de `GameOutcome.farFromGoal` (Execução terminou sem cumprir o objetivo). Ver `.claude/memory/decisions.md`.

### Pontuação e estrelas
Mesma fórmula do Mundo 1 — `lib/game/scoring.dart` (`computeScore`), reaproveitada sem alteração: `ConveyorLevel.optimalBlocks` (blocos da melhor solução conhecida) comparado aos blocos realmente usados pelo jogador na vitória. Ver tabela de estrelas/pontos na seção "Pontuação e estrelas" do Mundo 1 acima — a regra é idêntica, só troca a fonte do `Level` para `ConveyorLevel`.

### Dica (tela de Tentativa Falha)
- `ConveyorLevel.hintProgram` guarda uma solução válida conhecida da fase (não necessariamente a ótima) — mesmo papel de `Level.hintProgram` no Mundo 1.

## Mundo 3 — Preveja a Saída

Ponte entre o Mundo 2 (Esteira, sem código de verdade) e a Trilha 2 (código de verdade manipulável): sem grid, sem Mascote, sem fila de itens, sem execução passo a passo. Cada fase (`PredictOutputLevel`, `lib/models/predict_output_level.dart`) mostra um trecho de código real, curto e já na ordem certa (nunca embaralhado/editável) — o jogador só **lê** o código e prevê o resultado por múltipla escolha. Mesma família de "veredito único" dos Mundos 4/5 (sem "quase certo").

### Estrutura da fase
- `code`: o trecho de código, na ordem certa, mostrado só para leitura (com destaque de sintaxe simples, `highlightCodeLine`).
- `question`: a pergunta sobre o resultado (ex.: "O que aparece na tela?").
- `options`/`correctOptionIndex`: 2-3 respostas possíveis, uma certa.
- `explanation`: mostrada sempre (ganhou ou perdeu), explicando por que aquele é o resultado.

### Condição de vitória/derrota
Binária: `selectedOptionIndex == correctOptionIndex` — Vitória; qualquer outra opção — Falha (tentativa não conta como certa, jogador pode tentar de novo).

### Pontuação e estrelas
Reaproveita `computeCodePuzzleScore` (mesma fórmula do Mundo 5, ver abaixo) — a métrica de "tentativas até acertar" já é genérica o bastante, sem precisar de um cálculo próprio.

## Mundo 4 — Complete o Código

Continuação do Mundo 3 dentro da Trilha 2 (mais difícil — já manipula código de verdade, não só lê): sem grid, sem Mascote, sem fila de itens. Cada fase (`CompleteCodeLevel`, `lib/models/complete_code_level.dart`) mostra um trecho de código real com **1 linha em branco** (`blankLineIndex`) — o jogador escolhe, por múltipla escolha, qual das `options` (linhas de código candidatas) completa certo. Um degrau mais perto de `reorder`/`findBug` (Mundo 5) do que o Mundo 3, mas ainda por múltipla escolha (não por reordenar/tocar a linha errada).

### Estrutura da fase
- `question`: pergunta de contexto mostrada junto do código, deixando explícito o que ele deve fazer/exibir (mesmo papel de `PredictOutputLevel.question` no Mundo 3) — sem ela, `title` sozinho (curto, tipo "Complete a soma") não bastava pro jogador saber o que estava sendo pedido (achado real de testador: "Mundo 4 não dá contexto do que quer que eu faça"). Sempre precisa deixar claro o comportamento/resultado esperado (ex.: "para que o print mostre 7"), de forma que só uma das `options` a satisfaça — sem isso, uma fase pode ficar ambígua o bastante pra mais de uma opção parecer "certa" (achado real: Fase 12 não dizia qual saída era esperada).
- `code`: o trecho de código completo e correto (a UI não revela `code[blankLineIndex]` antes do jogador responder — mostra um espaço em branco tracejado no lugar, e a prévia da opção escolhida assim que ela é tocada).
- `options`/`correctOptionIndex`: 2-3 linhas de código candidatas para o espaço em branco.
- `explanation`: mostrada sempre (ganhou ou perdeu).

### Condição de vitória/derrota
Binária: `selectedOptionIndex == correctOptionIndex` — Vitória; qualquer outra opção — Falha.

### Pontuação e estrelas
Reaproveita `computeCodePuzzleScore` (mesma fórmula do Mundo 5, ver abaixo).

### Sessão de tentativas (`attempts`) — reset entre visitas distintas
`attempts` (usado por `computeCodePuzzleScore`) deve refletir quantas vezes o jogador tentou **dentro de uma sessão contínua** naquela fase: perder e tocar "Tentar de novo" aumenta `attempts` de propósito (a pontuação cai, isso é intencional). Mas reabrir a fase do zero — inclusive pelo atalho de "jogar de novo" na própria tela de Vitória (`CodePuzzleResultView._buildWon`, que só dá `pop()` de volta pra mesma instância de Gameplay em vez de recriar a fase) — precisa resetar `attempts` a 0, senão a pontuação continua caindo indefinidamente mesmo acertando de primeira em cada sessão nova (achado real de testador). Ver `.claude/memory/decisions.md`, entrada de 2026-09-18, e o mesmo princípio vale para os Mundos 3 e 5 (mesma família de "veredito único").

## Mundo 5 — Modo Debug

Mini-jogo de lógica diferente dos Mundos 1 e 2: sem grid, sem Mascote, sem fila de itens, sem execução passo a passo. Inspirado no app real Mimo de ensino de código — cada fase (`CodePuzzleLevel`, `lib/models/code_puzzle_level.dart`) é um puzzle de **veredito único**: o jogador confirma uma resposta e ela está certa ou errada, sem meio-termo ("quase certo" não existe aqui, diferente de "usou blocos a mais" nos outros mundos).

### Tipos de puzzle
Cada fase é de exatamente um dos 2 tipos (`CodePuzzleType`):

| Tipo | Mecânica |
|---|---|
| **Reordenar** (`reorder`) | O jogador vê um código real (Dart/pseudocódigo simples) com as linhas embaralhadas, mostradas como chips tocáveis — tocar para adicionar à sequência montada, tocar de novo para remover (mesma mecânica de "tocar para montar" dos outros mundos). Ao confirmar, a sequência montada é comparada com `CodePuzzleLevel.correctOrder`, **por grupo** (`CodePuzzleLevel.groupOf`) — ver abaixo. |
| **Achar o bug** (`findBug`) | O jogador vê o código inteiro (`CodePuzzleLevel.codeWithBug`), já na ordem certa, com destaque de sintaxe simples. Toca na linha que acha que tem o erro e confirma — comparado com `CodePuzzleLevel.buggyLineIndex`. |

### Linhas intercambiáveis (`groupOf`) em `reorder`
Algumas fases têm linhas **independentes entre si** (ex.: duas declarações que não dependem uma da outra, ambas só precisando vir antes de uma 3ª linha que as usa) — comparar posição a posição rejeitava uma ordem alternativa igualmente válida (achado real de testador na Fase 2: "int a = 2;"/"int b = 3;" podem vir em qualquer ordem entre si, desde que ambas venham antes de "print(a + b);"). `CodePuzzleLevel.groupOf` (paralelo a `correctOrder`, mesmo índice) resolve isso: linhas com o **mesmo** grupo podem aparecer em qualquer ordem relativa entre si; a ordem **entre** grupos diferentes continua obrigatória. Sem `groupOf` informado na fábrica `CodePuzzleLevel.reorder`, cada linha vira seu próprio grupo sequencial (`0, 1, 2, ...`) — ordem exata, comportamento de sempre, preservado por padrão. `checkReorder` valida isso comparando, grupo a grupo (na ordem em que aparecem em `correct`), se o trecho correspondente de `attempt` tem o mesmo multiconjunto de textos daquele grupo — não mais posição a posição. `correctOrder` continua sendo a única ordem usada para montar a Dica ("essa é a ordem certa") — mostra uma ordem válida, não precisa listar todas.

### Condição de vitória/derrota
Binária, sem gradação — decidida em `lib/game/code_puzzle_checker.dart`:

| Condição | Resultado |
|---|---|
| `checkReorder`: sequência montada bate, grupo a grupo, com `correctOrder`/`groupOf` (mesmo tamanho, mesmo texto por grupo, mesma ordem entre grupos) | **Vitória** |
| `checkReorder`: qualquer linha fora do grupo/posição esperada, faltando ou sobrando | **Falha** — tentativa não conta como certa; jogador pode tentar de novo |
| `checkFindBug`: linha tocada é `buggyLineIndex` | **Vitória** |
| `checkFindBug`: linha tocada é qualquer outra | **Falha** — tentativa não conta como certa; jogador pode tentar de novo |

Em `findBug`, `CodePuzzleLevel.bugExplanation` é mostrada sempre (não só na falha) — equivalente a uma "Dica" permanente, já que o objetivo é entender o erro, não só acertar por tentativa.

### Pontuação e estrelas
Implementado em `lib/game/code_puzzle_scoring.dart` (`computeCodePuzzleScore`), diferente da fórmula de `computeScore` (Mundos 1/2, blocos usados vs. ótimo) — aqui não há "blocos", então a métrica é **quantas tentativas até acertar**:

| Tentativa em que acertou | Estrelas |
|---|---|
| 1ª | 3 |
| 2ª | 2 |
| 3ª em diante | 1 |

Pontos: 300 na 1ª tentativa, -100 por tentativa extra, com piso de 50.

## Placar do Dia — pontuação de sessão

Separado do "PONTOS" por fase (`computeScore`/`computeCodePuzzleScore` acima, mostrado na Vitória/Resultado) — o Placar do Dia soma uma pontuação própria (`Progress.sessionScore`) toda vez que o jogador conclui uma fase **pela primeira vez** (replay de fase já concluída não soma de novo, evita farm). Pedido explícito do usuário: mundos mais difíceis valem mais, e resolver mais rápido rende mais pontos — **mas isso nunca aparece na UI como "tempo"/cronômetro**, só como um número de pontos, pra não parecer punição de quem joga mais devagar.

Implementado em `lib/game/leaderboard_scoring.dart` (`computeSessionPoints`):

```
basePorMundo = { 1: 300, 2: 450, 3: 600, 4: 750, 5: 900 }
bônusPorRapidez = max(0, 200 - segundosGastosNaFase)   // nunca negativo, teto de 200
pontosDaFase = basePorMundo[mundo] + bônusPorRapidez
```

"Segundos gastos na fase" é medido por um `Stopwatch` em cada tela de Gameplay, do momento em que a fase abre até a vitória — **inclui tentativas falhas** (a Gameplay não é recriada entre "Tentar de novo" e a tentativa seguinte, então o cronômetro continua correndo). Constantes acima são um ponto de partida, ajustáveis depois de testar no estande — não são uma promessa de balanceamento final.
