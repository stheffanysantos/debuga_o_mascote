# Game Design — Debuga o Mascote

Fonte de verdade das regras do jogo. Qualquer mudança de regra é escrita aqui **antes** de implementada no motor de jogo (`lib/game/`) — ver `.claude/agents/game-logic-engineer.md`.

O jogo tem 7 mundos, cada um um mini-jogo de lógica de programação diferente, com seu próprio motor (`GameWorld`/`WorldGameType`, `lib/models/level.dart`), agrupados em 3 Trilhas (`GameTrack`, `lib/models/game_track.dart`): a Trilha 1 ("Lógica em Apuros") tem os Mundos 1-2-3; a Trilha 2 ("Construtores de Lógica") tem o Mundo 4; a Trilha 3 ("Modo Programador") tem os Mundos 5-7. Este documento descreve as regras do **Mundo 1 — Labirinto**, do **Mundo 2 — Resgate de Personagens**, do **Mundo 3 — Desenho no Tabuleiro**, do **Mundo 4 — Decisões em Bloco** ("Programação em Blocos" + "Tradutor de Blocos"), do **Mundo 5 — Preveja a Saída**, do **Mundo 6 — Complete o Código** e do **Mundo 7 — Modo Debug**.

Mundos 1, 2 e 3 compartilham o mesmo motor (`Level`/`ProgramExecutor`,
`WorldGameType.maze`) — o que muda entre eles é só o conteúdo de cada
fase (`collectibles`/`collectTarget` no Mundo 2, `paintTarget` no
Mundo 3), nunca a mecânica de Execução em si. Ver
`.claude/memory/decisions.md`, entradas de 2026-09-18, para o porquê
dessa decisão (em vez de um motor novo por mundo), para a troca de
mecânica do Mundo 3 (era "Caça-Moedas", virou "Desenho no Tabuleiro") e
para a 4ª iteração do Mundo 2 (era "Encruzilhada Colorida"/Placa, virou
"Resgate de Personagens").

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

## Mundo 2 — Resgate de Personagens

Mesmo motor do Mundo 1 (`Level`/`ProgramExecutor`, `WorldGameType.maze`), acrescentando **decisão** (`Se`) sem adicionar mecânica nova de tabuleiro: além do tabuleiro/Alvo/paredes de sempre, algumas células têm um **personagem perdido** (`Level.collectibles: Set<GridPosition>`, mesmo acumulador de sempre — `Level.collectTarget: int?`). O jogador precisa usar o bloco condicional de resgate (`rescueIfCharacterHere`), normalmente combinado com `Repetir 3×`, para resgatar quem está pelo caminho.

Esta é a 4ª iteração do Mundo 2 nesta sessão (Esteira → Encruzilhada Colorida com Placa → Encruzilhada+Moeda → **Resgate de Personagens**, 2026-09-18) — a Placa colorida (`Level.signs`/`SignColor`, blocos `turnLeftIfYellow`/`turnRightIfPurple`) **saiu de cena por completo**: como a fase é fixa e conhecida de antemão, o condicional de Placa nunca "decidia" nada de verdade (dava sempre no mesmo resultado de um `Virar` comum naquele ponto) — achado real do usuário ao testar. Ver `.claude/memory/decisions.md`, entrada de 2026-09-18 ("Mundo 2 v4"), inclusive o racional de por que a alternativa "decisão por parede" foi discutida e rejeitada antes de se chegar nesta mecânica.

### Estrutura da fase (personagem perdido)
- `Level.collectibles: Set<GridPosition>` — células com um personagem perdido (Bit/Chip/Loopy/Libug — qual personagem aparece em cada célula é decisão cosmética da UI, não deste modelo).
- `Level.collectTarget: int?` — quantos personagens o jogador precisa ter resgatado **ao chegar no Alvo** para vencer. `null` (Mundo 1, e a maioria das fases do Mundo 3) significa "não importa".

### Comando disponível: "Se tiver um personagem aqui, resgate" (`rescueIfCharacterHere`)
Condição embutida no próprio bloco-alvo (mesmo padrão de `addToTotalIfEven`/`countPlusOneIfOdd`, Mundo 4 — não é um modificador aninhado). Diferente da antiga Placa, este bloco **sempre move** o Mascote 1 casa na direção atual (mesmas regras de colisão de `Andar` — pode bater na parede/sair do tabuleiro) e, **na casa de destino**, resgata o personagem que estiver lá, se ainda não tiver sido resgatado nesta Execução:

| Comando | Efeito |
|---|---|
| **Se tiver um personagem aqui, resgate** (`rescueIfCharacterHere`) | Anda 1 casa na direção atual (igual a `Andar`); se a casa de destino tiver um personagem ainda não resgatado, resgata (incrementa a contagem); senão, só anda — nunca falha por não haver personagem. |

`Andar` (`walk`) **não resgata mais automaticamente** — desde esta iteração, resgatar é sempre uma escolha explícita do jogador (usar `rescueIfCharacterHere` em vez de `Andar` naquele passo), não um efeito colateral de qualquer movimento.

### Por que o bloco sempre move (e não só "verifica parado")
A ação-base ("andar") sempre acontece; só a ação-bônus (resgatar) é condicional — mesmo princípio de `addToTotalIfEven`/`countPlusOneIfOdd` (Mundo 4, `lib/game/block_program_executor.dart`): lá, consumir o próximo número da lista sempre acontece, só somar ao Total é condicional. Isso é o que permite `Repetir 3× + Se tiver um personagem aqui, resgate` (2 blocos) resolver um corredor inteiro de personagens espalhados de forma **irregular** ao longo de 3 casas, sem o jogador precisar saber exatamente em qual delas está cada um — sem o bloco mover, `Repetir` (que só multiplica 1 bloco seguinte, sem repetir uma sequência de vários) nunca conseguiria, por si só, processar 3 casas diferentes.

### "Se" nunca falha
Igual ao princípio já usado em "Enquanto" (histórico, Esteira), em `addToTotalIfEven`/`countPlusOneIfOdd` (Mundo 4) e na antiga Placa: não haver personagem na casa de destino não é uma falha de Execução — o Passo simplesmente não resgata (o Mascote anda normalmente) e o Programa segue pro próximo bloco. Isso não impede o jogador de "errar a fase" — só significa que o erro aparece no final (contagem de personagens errada ao chegar no Alvo, ou o Mascote nem chega lá), nunca como uma interrupção abrupta no meio do Passo condicional em si.

### Condição de vitória — chegar no Alvo não basta
Quando a fase tem `collectTarget`, terminar um Passo exatamente na célula do Alvo **não garante** vitória por si só: `collectedCount` também precisa bater exatamente com esse valor.

| Condição | Resultado |
|---|---|
| Mascote termina no Alvo **e** `collectedCount == collectTarget` | **Vitória** (`GameOutcome.win`) |
| Mascote termina no Alvo, mas `collectedCount != collectTarget` | **Falha** — motivo: "chegou no alvo, mas resgatou a quantidade errada de personagens" (`GameOutcome.wrongCollectCount`) |

`wrongCollectCount` é distinto de `farFromGoal` de propósito — a posição final está certa, o motivo do erro é outro (contagem de resgates), e a tela de Tentativa Falha precisa de um texto diferente para isso.

### Regras do programa / Execução
Mesmas do Mundo 1 (`maxBlocks: 8`, `Repetir`/o condicional de resgate contam 1 bloco cada, `expand`/`evaluateFinal` idênticos). `applyStep` ganhou o case `rescueIfCharacterHere` (move como `Andar` — mesma checagem de colisão/borda, extraída num helper interno compartilhado `_forward` — e, na casa de destino, resgata condicionalmente); `Andar` (`walk`) voltou a só mover o cursor, sem nenhum efeito colateral de coleta.

### Condições de fim de execução
Mesma tabela do Mundo 1, com o motivo extra `GameOutcome.wrongCollectCount` (ver acima) quando a fase tem `collectTarget` e o Mascote chega no Alvo com a contagem de resgates errada. Usar `rescueIfCharacterHere` numa casa sem personagem não falha por si só (ver acima); o Programa segue e falha do jeito de sempre ("bateu na parede"/"saiu do tabuleiro"/"não chegou ao alvo"/"resgatou a quantidade errada de personagens").

### Pontuação e estrelas
Mesma fórmula do Mundo 1 (`computeScore`, blocos usados vs. `optimalBlocks`), sem alteração — só chamada depois de uma vitória de verdade (`GameOutcome.win`, não `wrongCollectCount`).

### As 12 fases (`world2Levels`)
Progressão de dificuldade (dados verificados em `test/game/world2_level_catalog_test.dart`, rodando o `ProgramExecutor` de verdade contra cada `hintProgram`) — nenhuma fase usa parede (`walls`), o desafio vem todo da posição irregular dos personagens dentro de cada corredor:

| Fases | O que introduzem |
|---|---|
| 1 | 1 corredor de resgate (`Repetir 3× + rescueIfCharacterHere`) **e** uma virada de verdade depois dele — pedido explícito do usuário para a Fase 1 ficar "um pouco mais difícil" que um primeiro contato isolado, já que o Mundo 2 é continuação direta do Mundo 1 (o jogador já deveria dominar Andar/Virar/Repetir). |
| 2-4 | Isolam o conceito: 1 único corredor de 3 casas (`Repetir 3× + rescueIfCharacterHere`) com 1-2 personagens espalhados de forma irregular (nem toda casa do corredor tem um), seguido de um `Andar` até o Alvo. |
| 5-9 | Encadeiam 2 corredores em sequência, com uma virada entre eles — cada corredor com personagens espalhados de forma diferente. |
| 10-12 | Encadeiam 2 corredores **e** um resgate solto (fora de `Repetir`) no mesmo Programa, preenchendo exatamente os 8 blocos do `maxBlocks` — as 3 fases mais difíceis do mundo, sem espaço pra errar; a Fase 12 ("Fim do Mundo 2") é a mais densa (todas as 3 casas do 2º corredor têm personagem). |

## Mundo 3 — Desenho no Tabuleiro

Mesmo motor do Mundo 1/2 (`Level`/`ProgramExecutor`), trocando o **critério de vitória** — sem adicionar bloco novo: os comandos disponíveis continuam exatamente os 4 do Mundo 1 (`Andar`/`Virar Esquerda`/`Virar Direita`/`Repetir 3×`, sem os condicionais do Mundo 2, sem acumulador do Mundo 2). Estilo Tartaruga/LOGO — o Mascote pinta cada célula por onde `Andar` passa, e o objetivo é reproduzir um desenho exato, não só chegar num alvo qualquer. Substituiu a mecânica anterior deste mundo ("Caça-Moedas", que migrou por completo para o Mundo 2) — ver `.claude/memory/decisions.md`, entrada de 2026-09-18.

### Estrutura da fase
- `Level.paintTarget: Set<GridPosition>?` — o conjunto exato de células que precisam ficar pintadas ao final da Execução. `null` (Mundos 1/2) significa "esta fase não usa a mecânica de pintura".

### Pintura
- `GameCursor.paintedTiles: Set<GridPosition>` — todas as células por onde o Mascote já passou nesta Execução. Começa com a própria célula inicial (`GameCursor.fromStart` já a inclui) e cresce a cada `Andar` bem-sucedido (sem colisão), adicionando a célula de destino. Revisitar uma célula (ex.: via `Repetir` ou dando meia-volta) não conta 2× — é um `Set`.
- Não há como "errar" um passo de pintura isoladamente — pintar é automático e nunca é uma falha por si só; o que pode dar errado é o **resultado final** (ver abaixo).

### Condição de vitória — chegar no Alvo não basta
Terminar um Passo exatamente na célula do Alvo **não garante** vitória quando a fase tem `paintTarget`: `GameCursor.paintedTiles` também precisa ser **exatamente igual** a `Level.paintTarget` — nem faltando, nem sobrando nenhuma célula.

| Condição | Resultado |
|---|---|
| Mascote termina no Alvo **e** `paintedTiles == paintTarget` (mesmo conjunto exato) | **Vitória** (`GameOutcome.win`) |
| Mascote termina no Alvo, mas `paintedTiles` difere de `paintTarget` (faltou pintar alguma célula do desenho, ou pintou alguma fora dele) | **Falha** — motivo: "o desenho não ficou igual ao pedido" (`GameOutcome.wrongPaintPattern`) |
| Mascote bate na parede / sai do tabuleiro | **Falha** — motivo: "bateu na parede"/"saiu do tabuleiro" (`GameOutcome.crash`, igual ao Mundo 1) |
| Programa termina longe do Alvo | **Falha** — motivo: "não chegou ao alvo" (`GameOutcome.farFromGoal`, igual ao Mundo 1) |

`wrongPaintPattern` é distinto de `farFromGoal` de propósito — a posição final está certa, o motivo do erro é outro (o desenho não bateu), e a tela de Tentativa Falha precisa de um texto diferente para isso (ver `.claude/memory/decisions.md`, entrada de 2026-09-18 — atualizar o switch exaustivo de `GameOutcome`→texto em `lib/features/maze/presentation/gameplay/gameplay_view.dart` fica para quem tocar a UI a seguir).

### Restrição de forma: só um traço contínuo
Como o Mascote nunca "levanta o lápis" (não existe um comando para pintar sem se mover, nem para desenhar 2 trechos desconectados), todo `paintTarget` precisa ser alcançável como um único traço contínuo a partir de `Level.start`, terminando exatamente em `Level.goal`. Isso restringe as formas possíveis dentro de `maxBlocks: 8`: desenhos com "ramos" que exigiriam o Mascote voltar por cima de si mesmo para alcançar uma parte separada (ex.: uma cruz com 4 pontas, ou um coração preenchido) custam blocos demais para caber no limite — o custo de ir e voltar por um trecho já pintado (sem pintar nada novo) soma ao total de blocos sem ajudar a completar o desenho. As 12 fases abaixo foram desenhadas dentro dessa restrição.

### `resolveProgramEntries` — extraído para não duplicar a regra de `Repetir`
A regra de pareamento "`Repetir 3×` se aplica só ao bloco imediatamente seguinte" (usada por `ProgramExecutor.expand`) foi extraída para uma função pura reaproveitável, `resolveProgramEntries(List<Block> program) → List<ProgramEntry>` (`lib/game/program_executor.dart`) — mesmo padrão já usado por `resolveBlockProgramEntries`/`BlockProgramProgramEntry` no Mundo 4. Isso existe para que um futuro painel de tradução de código para o Mundo 1 (ex.: um "Tradutor de Blocos" equivalente ao do Mundo 4) não precise reimplementar essa regra por conta própria — ver `.claude/memory/decisions.md`, entrada de 2026-09-18.

### Pontuação e estrelas
Mesma fórmula do Mundo 1/2 (`computeScore`, blocos usados vs. `optimalBlocks`), sem alteração — só chamada depois de uma vitória de verdade (`GameOutcome.win`, não `wrongPaintPattern`).

### As 12 fases (`world3Levels`)
Progressão de dificuldade (dados verificados em `test/game/world3_level_catalog_test.dart`, rodando o `ProgramExecutor` de verdade contra cada `hintProgram`) — nenhuma fase usa parede (`walls`), já que o próprio desenho-alvo é o desafio:

| Fases | Forma / o que introduzem |
|---|---|
| 1-3 | Um "L" (reto + 1 virada) — a Fase 1 já combina a virada com `Repetir 3×` (pedido explícito do usuário, "um pouco mais difícil" desde o início, mesmo padrão do Mundo 2), a Fase 3 estende os dois lados do L com `Repetir 3×`. |
| 4-7 | Traços com 2 viradas: zigue-zague pequeno, degrau mais longo (viradas alternadas), corredor estreito (2 colunas cheias), gancho comprido. |
| 8-11 | Traços com 3 viradas ou mais, usando o `maxBlocks: 8` inteiro: uma seta (haste + barra na ponta), 2 variações de arco aberto (3 lados de um retângulo) e uma escada com gancho. |
| 12 | "Fim do Mundo 3" — o zigue-zague que usa o máximo de células pintáveis dentro dos 8 blocos do `maxBlocks` (3 trechos de 3 células cada, via `Repetir 3×`, com 2 viradas) — "sem espaço pra errar", mesmo padrão das fases finais dos outros mundos. |

### Pontuação e estrelas
Mesma fórmula do Mundo 1/2 (`computeScore`, blocos usados vs. `optimalBlocks`), sem alteração — só chamada depois de uma vitória de verdade (`GameOutcome.win`, não `wrongCollectCount`).

## Mundo 4 — Decisões em Bloco (Programação em Blocos + Tradutor de Blocos)

Único mundo restante de "Programação em Blocos" (`WorldGameType.blockProgram`) — o mundo irmão original ("Oficina de Blocos", sem condicionais) saiu do jogo, ver `.claude/memory/decisions.md`, entrada de 2026-09-18. Forma a Trilha 2 ("Construtores de Lógica") sozinho, como ponte entre a Trilha 1 (sequência/decisão, sem código) e a Trilha 3 (código de verdade): o jogador monta um Programa de blocos visuais (sem sintaxe de código) que processa uma lista de números e produz um resultado, comparado ao alvo da fase. Sem grid, sem Mascote, sem fila de Itens — a fila aqui é uma lista de números, mostrada como fileira de "fichas".

### Estrutura da fase (`BlockProgramLevel`, `lib/models/block_program_level.dart`)
- `numbers`: a lista de números de entrada, na ordem em que o Programa os processa.
- `problem`: o probleminha em português (ex.: "Some todos os números da lista.").
- `goal`: qual métrica final decide a vitória — `total` (Total acumulado) ou `count` (Contador acumulado). O motor sempre checa exatamente uma das duas, nunca as duas ao mesmo tempo.
- `targetValue`: o valor que `goal` precisa bater para vencer.

### Comandos disponíveis (`BlockProgramBlockType`, `lib/models/block_program_block.dart`)

| Bloco | Mecânica |
|---|---|
| **Para cada número** (`forEachNumber`) | Modificador (1 nível só, igual `Repetir` do Mundo 1 — sem stacking de 2 modificadores) que aplica o bloco imediatamente seguinte uma vez **por número da lista da fase** (contagem fixa = `numbers.length`, conhecida de antemão a partir do tamanho da lista). |
| **Some ao Total** (`addToTotal`) | Total += número atual. |
| **Conte +1** (`countPlusOne`) | Contador += 1 (ignora o valor do número, só conta quantas vezes rodou). |
| **Some os pares** (`addToTotalIfEven`) | Condição embutida no próprio bloco-alvo (não um modificador aninhado): soma o número atual ao Total só quando ele for par; quando ímpar, não faz nada — **não é uma falha**. |
| **Conte os ímpares** (`countPlusOneIfOdd`) | Soma 1 ao Contador só quando o número atual for ímpar; quando par, não faz nada — não é uma falha. |

### Execução (`BlockProgramExecutor`, `lib/game/block_program_executor.dart`)
Motor Dart puro, mesma forma de `ProgramExecutor` — `expand`/`applyStep`/`evaluateFinal`, um cursor (`BlockProgramCursor`) guardando quanto da lista já foi processado e o Total/Contador acumulados.

- `expand`: `Para cada número` aplica-se ao bloco imediatamente seguinte, gerando `numbers.length` Passos dele — mesmo algoritmo de `Repetir` no Mundo 1 (modificador de 1 nível, olha só o bloco seguinte; sem stacking). Um "Para cada número" sem bloco não-modificador logo depois (último bloco, ou seguido de outro "Para cada número") não gera nenhum Passo.
- `applyStep`: cada Passo consome exatamente o próximo número ainda não processado e atualiza Total/Contador conforme o tipo do bloco. **Não existe falha por Passo neste motor** — nem um bloco-alvo usado sem "Para cada número" antes (solto no Programa, processa 1 número, perfeitamente válido), nem um Passo sobrando com a lista já esgotada (simplesmente não faz nada). O único veredito do motor é o resultado final.
- `evaluateFinal`: Vitória (`BlockProgramOutcome.win`) quando o Total/Contador final bate exatamente com `targetValue`; senão, `BlockProgramOutcome.wrongResult`.

### Condições de fim de execução
Só 2 possíveis (sem "crash" — não há grid/parede aqui):

| Condição | Resultado |
|---|---|
| Total/Contador final == `targetValue` | **Vitória** |
| Total/Contador final != `targetValue` (Programa terminou de qualquer forma) | **Falha** — jogador pode ajustar o Programa e tentar de novo |

### Pontuação e estrelas
Reaproveita `computeScore` (`lib/game/scoring.dart`, mesma fórmula dos Mundos 1/2/3 — blocos usados vs. `optimalBlocks`), **não** a fórmula por tentativas dos Mundos 5/6/7: aqui o conceito é "montar um Programa" (mesma família dos Mundos 1/2/3), não "escolher 1 resposta".

### Tradutor de Blocos — `codeLinesFor`/`codeLineFor` (`lib/widgets/block_program_chip_style.dart`)
"Porta de entrada" pra sintaxe de código real que a Trilha 3 vai cobrar: cada bloco do Programa vira uma linha de código Dart equivalente, montada por `codeLinesFor(List<BlockProgramBlock> program) → List<String>`. Tradução deliberadamente pedagógica, **não** um transpilador de verdade — não precisa compilar.

- `Para cada número` abre um laço `for (int i = 0; i < numeros.length; i++) {`, com a linha do bloco que ele modifica indentada dentro, fechado por `}` — mesma regra de `expand` (aplica-se só ao bloco imediatamente seguinte).
- Dentro do laço, o número atual é `numeros[i]`; um bloco-alvo usado **sem** `Para cada número` antes (solto no Programa) usa a variável descritiva `proximoNumero` em vez de um índice de laço que não existe.
- `Some ao Total` → `total += <número>;`; `Conte +1` → `contador++;`; `Some os pares` → `if (<número> % 2 == 0) total += <número>;`; `Conte os ímpares` → `if (<número> % 2 != 0) contador++;`.

**Reformulação (2026-09-18):** o painel "TRADUTOR DE BLOCOS" separado (`_buildCodeTranslator`) sai de cena — `codeLinesFor`/`codeLineFor` continuam existindo e sendo a única fonte da tradução bloco→código, só que passam a ser consumidas **por chip** (cada bloco de "Seu Programa" mostra a própria linha de código nele, não um ícone + painel à parte que crescia e empurrava os controles pra baixo em Programas grandes). Isso é trabalho de UI (próxima fase) — aqui só a intenção fica registrada para explicar o "porquê" dos dados abaixo; a paleta de comandos (`CommandButton`, onde o jogador ainda está aprendendo o que cada bloco faz) mantém o rótulo em português.

### Esmaecimento progressivo — `prefilledCount` (`BlockProgramLevel`)

Pesquisa real que embasou esta decisão: **EduBlocks** (cada bloco de uma paleta visual já mostra a linha de código real nele, sem painel de tradução separado) e a literatura sobre transição gradual blocos→texto (recomenda **esmaecer progressivamente**, aumentando a proporção de texto/código puro ao longo de uma progressão, em vez de uma troca abrupta de paradigma). Mundo 4 é o último mundo da Trilha 2, logo antes da Trilha 3 (código de verdade manipulável) — por isso a Trilha 2 deve terminar "com cara de Trilha 3".

- `BlockProgramLevel.prefilledCount` (`int`, default `0`): quantos blocos do **início** de `hintProgram` já vêm prontos/fixos na fase — mostrados como código já escrito, não removíveis; o jogador só completa o restante. `0` preserva o comportamento original (Programa monta do zero).
- **Regra de pareamento**: o corte entre o prefixo fixo e a parte editável nunca pode cair no meio de um par `Para cada número` + bloco-alvo — só depois de um par completo, ou depois de um bloco solto (mesma regra de 1-nível-só que `resolveBlockProgramEntries` já usa para interpretar o Programa).
- `BlockProgramGameplayViewModel`: `build()` inicia `state.program` com `level.hintProgram.take(level.prefilledCount)` (em vez de vazio); `clearProgram()` volta pra esse mesmo prefixo, nunca pro vazio; `removeBlockAt(index)` ignora `index < level.prefilledCount` (defensivo — a UI, na próxima fase, nem deveria oferecer essa interação nesses índices).
- **Progressão das 12 fases de `world4Levels`**: Fases 1-4 com `prefilledCount: 0` (monta tudo do zero — inclusive a introdução de `forEachNumber` na Fase 3, que precisa ser construída, não só completada). A partir da Fase 5, cada `hintProgram` passa a ser `[bloco-alvo solto × K, forEachNumber, bloco-alvo]` — os `K` blocos soltos fixos processam os primeiros `K` números da lista com a mesma regra condicional do par que vem depois (matematicamente equivalente a processar a lista inteira só com o par, já que cada número é avaliado exatamente uma vez pela mesma condição, não importa se por um bloco solto ou por uma repetição de `forEachNumber` — por isso `targetValue`/`numbers` não mudam em relação à versão anterior sem prefixo). `prefilledCount` cresce ao longo das Fases 5-12: `1, 1, 2, 3, 3, 4, 5, 6` — sempre deixando o par final (`forEachNumber` + bloco-alvo, 2 blocos) por completar. A Fase 12 chega a `optimalBlocks == maxBlocks == 8` (sem espaço de sobra, mesmo padrão "sem espaço pra errar" de fases finais de outros mundos), com a maior parte do Programa já escrita — a mais próxima de "só completar código" que a Trilha 2 chega.

## Mundo 5 — Preveja a Saída

Ponte entre a Trilha 2 (Programação em Blocos, sem sintaxe de código) e o resto da Trilha 3 (código de verdade manipulável): sem grid, sem Mascote, sem fila de itens, sem execução passo a passo. Cada fase (`PredictOutputLevel`, `lib/models/predict_output_level.dart`) mostra um trecho de código real, curto e já na ordem certa (nunca embaralhado/editável) — o jogador só **lê** o código e prevê o resultado por múltipla escolha. Mesma família de "veredito único" dos Mundos 6/7 (sem "quase certo").

### Estrutura da fase
- `code`: o trecho de código, na ordem certa, mostrado só para leitura (com destaque de sintaxe simples, `highlightCodeLine`).
- `question`: a pergunta sobre o resultado (ex.: "O que aparece na tela?").
- `options`/`correctOptionIndex`: 2-3 respostas possíveis, uma certa.
- `explanation`: mostrada sempre (ganhou ou perdeu), explicando por que aquele é o resultado.

### Condição de vitória/derrota
Binária: `selectedOptionIndex == correctOptionIndex` — Vitória; qualquer outra opção — Falha (tentativa não conta como certa, jogador pode tentar de novo).

### Pontuação e estrelas
Reaproveita `computeCodePuzzleScore` (mesma fórmula do Mundo 7, ver abaixo) — a métrica de "tentativas até acertar" já é genérica o bastante, sem precisar de um cálculo próprio.

## Mundo 6 — Complete o Código

Continuação do Mundo 5 dentro da Trilha 3 (mais difícil — já manipula código de verdade, não só lê): sem grid, sem Mascote, sem fila de itens. Cada fase (`CompleteCodeLevel`, `lib/models/complete_code_level.dart`) mostra um trecho de código real com **1 linha em branco** (`blankLineIndex`) — o jogador escolhe, por múltipla escolha, qual das `options` (linhas de código candidatas) completa certo. Um degrau mais perto de `reorder`/`findBug` (Mundo 7) do que o Mundo 5, mas ainda por múltipla escolha (não por reordenar/tocar a linha errada).

### Estrutura da fase
- `question`: pergunta de contexto mostrada junto do código, deixando explícito o que ele deve fazer/exibir (mesmo papel de `PredictOutputLevel.question` no Mundo 5) — sem ela, `title` sozinho (curto, tipo "Complete a soma") não bastava pro jogador saber o que estava sendo pedido (achado real de testador: "Mundo 6 não dá contexto do que quer que eu faça"). Sempre precisa deixar claro o comportamento/resultado esperado (ex.: "para que o print mostre 7"), de forma que só uma das `options` a satisfaça — sem isso, uma fase pode ficar ambígua o bastante pra mais de uma opção parecer "certa" (achado real: Fase 12 não dizia qual saída era esperada).
- `code`: o trecho de código completo e correto (a UI não revela `code[blankLineIndex]` antes do jogador responder — mostra um espaço em branco tracejado no lugar, e a prévia da opção escolhida assim que ela é tocada).
- `options`/`correctOptionIndex`: 2-3 linhas de código candidatas para o espaço em branco.
- `explanation`: mostrada sempre (ganhou ou perdeu).

### Condição de vitória/derrota
Binária: `selectedOptionIndex == correctOptionIndex` — Vitória; qualquer outra opção — Falha.

### Pontuação e estrelas
Reaproveita `computeCodePuzzleScore` (mesma fórmula do Mundo 7, ver abaixo).

### Sessão de tentativas (`attempts`) — reset entre visitas distintas
`attempts` (usado por `computeCodePuzzleScore`) deve refletir quantas vezes o jogador tentou **dentro de uma sessão contínua** naquela fase: perder e tocar "Tentar de novo" aumenta `attempts` de propósito (a pontuação cai, isso é intencional). Mas reabrir a fase do zero — inclusive pelo atalho de "jogar de novo" na própria tela de Vitória (`CodePuzzleResultView._buildWon`, que só dá `pop()` de volta pra mesma instância de Gameplay em vez de recriar a fase) — precisa resetar `attempts` a 0, senão a pontuação continua caindo indefinidamente mesmo acertando de primeira em cada sessão nova (achado real de testador). Ver `.claude/memory/decisions.md`, entrada de 2026-09-18, e o mesmo princípio vale para os Mundos 5 e 7 (mesma família de "veredito único").

## Mundo 7 — Modo Debug

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
Implementado em `lib/game/code_puzzle_scoring.dart` (`computeCodePuzzleScore`), diferente da fórmula de `computeScore` (Mundos 1/2/3/4, blocos usados vs. ótimo) — aqui não há "blocos", então a métrica é **quantas tentativas até acertar**:

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
basePorMundo = { 1: 300, 2: 400, 3: 500, 4: 600, 5: 700, 6: 800, 7: 900 }
bônusPorRapidez = max(0, 200 - segundosGastosNaFase)   // nunca negativo, teto de 200
pontosDaFase = basePorMundo[mundo] + bônusPorRapidez
```

"Segundos gastos na fase" é medido por um `Stopwatch` em cada tela de Gameplay, do momento em que a fase abre até a vitória — **inclui tentativas falhas** (a Gameplay não é recriada entre "Tentar de novo" e a tentativa seguinte, então o cronômetro continua correndo). Constantes acima são um ponto de partida, ajustáveis depois de testar no estande — não são uma promessa de balanceamento final.
