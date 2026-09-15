# Decisões — Debuga o Mascote

Log curto de decisões arquiteturais (ADR). Toda decisão que contradiga ou substitua algo em `CLAUDE.md`/`.claude/rules/` é registrada aqui **antes** de ser implementada, com o porquê.

---

## 2026-09-04 — `setState` em vez de GetX/Riverpod

**Decisão:** o app usa `StatefulWidget`/`setState` puro (sem pacote de state management), com a lógica de jogo isolada em `lib/game/` (motor de execução, sem Flutter/UI).

**Por quê:** o projeto de referência da empresa (`xp_servico`) usa GetX + Clean Architecture em 3 camadas, mas isso serve um app grande, offline-first, com equipe e ciclo de vida longo. O Debuga o Mascote é um mini-jogo standalone de estande, com 5 telas e uma única fonte de estado por tela — a complexidade de GetX/Clean Architecture não se paga aqui.

**Como aplicar:** ver `.claude/rules/architecture.md`. Se o projeto crescer (mais mundos, comandos, telas) a ponto de `setState` ficar difícil de seguir, reavaliar aqui antes de migrar.

---

## 2026-09-04 — Sem hooks automáticos (Python) no `.claude/`

**Decisão:** ao contrário do `xp_servico` (que tem `.claude/hooks/scripts/*.py` bloqueando `Write`/`Edit`/`Bash` por regex), este projeto não usa hooks. `.claude/settings.json` fica vazio.

**Por quê:** hooks de guarda (arquitetura, design tokens, GetX) fazem sentido quando há muitas mãos mexendo em código por muito tempo e um padrão rígido a proteger. Aqui o escopo é pequeno, o prazo é curto (feira) e as regras cabem em `.claude/rules/` como guia lido pelos agentes, sem precisar de bloqueio automático.

**Como aplicar:** se o projeto ganhar vida além da feira (mais desenvolvedores, mais mundos), reavaliar se vale a pena adicionar 1-2 hooks leves (ex.: lembrete pós-escrita).

---

## 2026-09-04 — Persistência de progresso: a definir

**Decisão:** ainda não decidido. Candidato natural é `shared_preferences` (progresso local simples: estrelas por fase, melhor contagem de blocos) já que não há login nem sincronização com backend.

**Por quê:** o escopo passado pelo usuário não especifica isso; não inventar uma decisão de dados sem confirmação.

**Como aplicar:** antes de implementar `Progress` (ver `.claude/memory/domain-glossary.md`), confirmar com o usuário e atualizar esta entrada com a decisão final.

---

## 2026-09-04 — Implementação inicial das 5 telas a partir do design do Claude Design

**Decisão:** as 5 telas foram implementadas replicando fielmente o projeto `Debuga o Mascote.dc.html` (importado via `claude_design` MCP). Duas dependências foram adicionadas ao `pubspec.yaml`: `google_fonts` (Nunito, como no design) e `flutter_svg` (ícones traduzidos 1:1 dos `<path>` SVG originais, para fidelidade visual).

**Por quê:** `google_fonts`/`flutter_svg` são bibliotecas puramente de apresentação (sem estado, sem rede além do carregamento inicial da fonte), não mudam a decisão de arquitetura (`setState`) nem justificam GetX/Riverpod.

**Mascote placeholder (resolvido em 2026-09-04):** a arte real do mascote (foto de referência do design) não pôde ser baixada automaticamente do MCP nesta sessão (o arquivo é muito grande/repetitivo e a transcrição do base64 foi bloqueada por uma proteção do harness contra blobs binários enormes). A implementação inicial usou `lib/widgets/mascot_placeholder_widget.dart`, um mascote desenhado via `CustomPainter`. O usuário depois forneceu a arte real (`personagem_licode_fundo_branco.png`, fundo transparente) manualmente — o placeholder foi removido e substituído por `lib/widgets/mascot_image_widget.dart` (`MascotImage`), que carrega `assets/images/mascot.png` via `Image.asset`.

**Como aplicar:** só existe **uma** expressão desenhada por enquanto (pose neutra/sorrindo, olhos fechados). `MascotExpression.celebrating` reaproveita a mesma arte (a animação de contexto já comunica a vitória); `MascotExpression.confused` aplica um filtro de dessaturação parcial sobre a mesma arte (equivalente ao `filter: saturate(.55)` do design original), em vez de uma ilustração própria. Quando expressões dedicadas de "comemorando"/"confuso" existirem, adicionar os assets (`mascot_celebrating.png`, `mascot_confused.png`) e trocar a lógica condicional de `MascotImage` para usar cada arquivo.

---

## 2026-09-04 — Vitória/Falha passam a usar dados reais da partida

**Decisão:** `VictoryScreen`/`FailureScreen` deixaram de mostrar conteúdo estático de exemplo (pontos/blocos fixos, motivo de falha sempre "bateu na parede", dica fabricada) e passaram a receber e exibir o resultado real da Execução rodada em `GameplayScreen`: `blocksUsed`, `GameOutcome` (`crash`/`farFromGoal`), número da tentativa, e uma dica real (`Level.hintProgram`). Pontuação/estrelas viraram uma regra de jogo de verdade em `lib/game/scoring.dart` (`computeScore`), com `Level.optimalBlocks` novo no modelo.

**Por quê:** o pedido inicial era só fidelidade visual ao mock do Claude Design (que tinha essas telas estáticas, sem conexão com a Execução real). O usuário depois pediu explicitamente para usar as telas reais de acerto/erro — mostrar o que realmente aconteceu na partida, não um exemplo fixo.

**Como aplicar:** ao adicionar fases novas (`/generate-level`), sempre preencher `optimalBlocks` e `hintProgram` com uma solução verificada (ver `.claude/reviews/checklist-level.md`) — sem isso a tela de Vitória calcula estrelas erradas e a Dica fica vazia.

---

## 2026-09-04 — Sem modal de resultado no tabuleiro; navegação direta para Vitória/Falha

**Decisão:** removido o overlay ("Chegou! ⭐⭐⭐" / "Ops, um bug!" com botões "Reiniciar"/"Ver vitória") que aparecia sobre o tabuleiro ao final da Execução. Agora `GameplayScreen._run()` navega automaticamente para `VictoryScreen` ou `FailureScreen` assim que o resultado é conhecido, com só uma pausa curta (`_resultPause`, 500ms) para o jogador ver a posição final do mascote.

**Por quê:** pedido explícito do usuário — o modal intermediário era um passo extra sem necessidade, já que as duas telas de resultado (reais, ver decisão anterior) já cumprem esse papel.

**Como aplicar:** o antigo botão "Reiniciar" do overlay não tem mais equivalente direto — para tentar de novo, o fluxo é sempre sair da Gameplay (Vitória → "Próxima fase"/Falha → "Tentar de novo") e voltar; `_program` continua preenchido ao voltar, então o jogador pode ajustar ou só apertar Play de novo.

---

## 2026-09-04 — As 12 fases do Mundo 1 viraram jogáveis; progresso só na sessão

**Decisão:** `world1Levels` (`lib/models/level.dart`) agora tem as 12 fases do Mundo 1 (cada uma com `hintProgram` verificado em `test/game/level_catalog_test.dart`). `GameplayScreen` recebe o `Level` a jogar por parâmetro (não mais fixo em `demoLevel`). `LevelSelectScreen` deriva o status de cada fase (concluída/atual/bloqueada) de `Progress.instance` (`lib/models/progress.dart`) — uma progressão sequencial simples: a primeira fase não concluída é a "atual", as depois dela ficam bloqueadas. Fases concluídas também ficam tocáveis (permite rejogar). Vencer uma fase chama `Progress.instance.recordWin(...)` e a tela de Vitória, quando existe próxima fase, joga ela direto (sem passar pela Seleção de Fases).

**Por quê:** pedido explícito do usuário — só a Fase 6 (demoLevel) funcionava; as outras 11 eram só decoração estática. Sobre persistência: o usuário decidiu explicitamente que progresso só durar a sessão atual (reinicia ao reabrir o app) é suficiente por agora — a decisão de persistência entre sessões (ver entrada acima) continua em aberto.

**Como aplicar:** `Progress` é um singleton em memória (`Progress.instance`) — nenhuma dependência nova, nenhum `shared_preferences`. Ao decidir persistência de verdade no futuro, `Progress` é o lugar natural para trocar o armazenamento interno (o `Map` em memória) por leitura/escrita em disco, sem mudar a API usada pelas telas.

---

## 2026-09-09 — Etapa 3 (UI): Mundo 3 ligado, `CodePuzzleResultScreen` própria, `GameplayHeader` generalizado

**Decisão:** com o motor/modelos do Mundo 3 já prontos (`CodePuzzleLevel`, `checkReorder`/`checkFindBug`, `computeCodePuzzleScore`), esta etapa liga o Mundo 3 de ponta a ponta na UI:

- `worlds[2]` (`lib/models/level.dart`) passa a `comingSoon: false, levels: world3Levels` — os 3 mundos agora são jogáveis.
- `WorldSelectScreen._openWorld` roteia `WorldGameType.codePuzzle` para `CodePuzzleStageSelectScreen` (nova, mesmo papel de `LevelSelectScreen`/`ConveyorStageSelectScreen`, rota nomeada `codePuzzleStageSelectRouteName`).
- `CodePuzzleGameplayScreen` (nova) alterna o conteúdo central pelo `CodePuzzleType`: `reorder` reaproveita `ProgramBlockChip` num padrão "banco de linhas embaralhadas → toca pra montar/desmontar a sequência" (mesmo espírito de `GameplayScreen._addBlock`/`_removeBlockAt`); `findBug` usa `RichText`/`TextSpan` com um regex simples de palavras-chave (`if`/`else`/`for`/`while`/`return`/`int`/`bool`/`List`/`void`) coloridas em `AppColors.lilac`, resto em `AppColors.white` — sem parser real, sem pacote novo. O embaralhamento de `reorder` usa uma seed fixa por fase (`Random(level.id.hashCode)`), calculada uma vez (`late final`) para não reembaralhar a cada rebuild.
- **`GameplayHeader` generalizado**: o campo `blocksUsed`/`maxBlocks` (específico de "blocos", que o Mundo 3 não tem) virou `trailingChipText: String?` — texto livre mostrado no mesmo chip visual; `null` esconde o chip. `GameplayScreen`/`ConveyorGameplayScreen` passam `'${blocos} / ${max} blocos'` (comportamento idêntico a antes); `CodePuzzleGameplayScreen` passa `'Tentativa ${_attempts + 1}'` (a tentativa que está prestes a rodar, sempre exibida a partir de 1).
- **`CodePuzzleResultScreen` (nova) em vez de reaproveitar `VictoryScreen`/`FailureScreen`**: o resultado do Mundo 3 é binário por tentativas (sem "blocos usados vs. ótimo", sem "quase certo") — não cabe no contrato das outras duas telas. É uma tela só, parametrizada por `won: bool` (em vez de duas telas espelhadas), com o mesmo vocabulário visual reaproveitado (`MascotImage` celebrating/confused, `DottedBackground`, `ConfettiOverlay`, `StarRow`, `StatCard` "PONTOS"/"TENTATIVAS", `PrimaryPillButton`, `IconActionButton`, `MuteButton`). Título de derrota deliberadamente não-punitivo: "Quase lá!" (não "Ops, um bug!" da `FailureScreen` — nesse mundo "bug" já é o tema do puzzle `findBug`, reaproveitar a mesma palavra para "você errou" confundiria). Quando a fase é `findBug`, um card "COMO FUNCIONA" com `bugExplanation` aparece **sempre** (ganhou ou perdeu, conforme `.claude/docs/GAME_DESIGN.md`); quando é `reorder` e o jogador perdeu, um card "DICA" mostra a ordem certa via `correctOrderChips` (montado por `CodePuzzleGameplayScreen`, a tela de resultado não conhece `CodePuzzleLevel`).
- **`ConfettiOverlay` extraído** (`lib/widgets/confetti_overlay_widget.dart`) de `_ConfettiPainter`/`AnimationController` inline de `VictoryScreen`, para `CodePuzzleResultScreen` reaproveitar sem duplicar a animação. Autocontido (gerencia seu próprio `AnimationController`/`dispose`). `VictoryScreen` manteve um controller próprio (renomeado `_ringController`) só para a rotação do anel atrás do mascote — mesma duração (3200ms) do confete, então os dois continuam visualmente sincronizados mesmo sendo instâncias diferentes. `CodePuzzleResultScreen` não replicou a rotação do anel (simplificação deliberada — o anel ali é estático, sem `TickerProviderStateMixin` extra só para isso).
- Layout do Mundo 3 sempre empilhado (celular e tablet) — mesmo corte não-bloqueante já feito no Mundo 2 (ver `.claude/plans/Roadmap.md`).

**Por quê:** seguir a arquitetura combinada em `.claude/plans/Etapa3-ModoDebug.md`; as escolhas concretas de "uma tela vs. duas" e do reaproveitamento de `Progress.recordWin(blocksUsed: attempts)` (Mundo 3 usa tentativas, não blocos) foram deixadas em aberto pelo plano para a UI decidir na hora de implementar — registradas aqui.

**Como aplicar:** se o Mundo 3 ganhar um 3º tipo de puzzle no futuro, `CodePuzzleGameplayScreen._buildContent()`/`_checkWon()` são os dois pontos de extensão (switch exaustivo por `CodePuzzleType`); `CodePuzzleResultScreen` provavelmente não precisa mudar, já que seu contrato (`won`/`explanationText`/`correctOrderChips`) é bem genérico. Se o destaque de sintaxe precisar de mais nuance (comentários, strings), trocar `_keywordPattern`/`_highlightLine` por um parser de verdade — hoje é deliberadamente um regex simples.

---

## 2026-09-09 — Tutorial vira modal ilustrado, Seleção de Mundo vira grade compacta, Configurações vira dialog

**Decisão:** três mudanças de UI pedidas explicitamente pelo usuário depois de testar o app:

1. **Tutorial** (`TutorialModal`, `lib/widgets/tutorial_modal_widget.dart`) é um modal ilustrado — `MascotImage` (expressão neutra) + título + lista de bullets curtos (ícone de check) + botão "Aprendi" (`PrimaryPillButton`) — não um vídeo. Sem arquivo de vídeo, sem pacote de player. Mostrado via `showDialog(..., barrierDismissible: false, ...)`: o jogador precisa tocar "Aprendi", não pode fechar tocando fora (senão o tutorial "escaparia" sem o jogador confirmar que leu). Controlado por `Onboarding` (`lib/models/onboarding.dart`, singleton em memória — mesmo padrão de `Progress` — `hasSeen(worldNumber)`/`markSeen(worldNumber)`, dura só a sessão). `WorldSelectScreen` mostra o modal na 1ª vez que um Mundo jogável é tocado (antes de navegar para a Seleção de Fases); `onDone` marca `Onboarding`, fecha o modal e só então navega. Cada Seleção de Fases (`LevelSelectScreen`/`ConveyorStageSelectScreen`/`CodePuzzleStageSelectScreen`) ganhou um botão "?" (`AppIcons.help`) no cabeçalho — agrupado ao lado do botão voltar (mesmo `Row` interno, `mainAxisSize: MainAxisSize.min`), sem mexer no chip de estrelas que continua `Flexible` à direita — que reabre o mesmo `TutorialModal` a qualquer momento (`onDone` aqui só fecha, não navega de novo, já está na tela certa). Conteúdo textual de cada Mundo (título + 3 bullets, já revisado contra as regras reais de cada motor) fica em `lib/widgets/tutorial_content.dart` (`WorldTutorial`, `worldTutorials`).

2. **Seleção de Mundo** (`WorldSelectScreen`) trocou a lista vertical de cards horizontais grandes (número + nome + subtítulo + pill de dificuldade + estrelas + status) por uma grade (`GridView.builder`, 2 colunas no celular / 3 em telas ≥480px — os 3 mundos cabem numa única linha em tablet) de cards quadrados compactos (`_WorldTile`, privado a `world_select_screen.dart` — só usado nesta tela, não sobe para `lib/widgets/`). Cada card mostra só o número do mundo (quadrado colorido, tamanho sempre derivado do espaço real da célula — mesma técnica de `_StageTile` em `stage_select_grid_widget.dart`) e o nome abaixo em texto pequeno. Removidos do card: subtítulo, pill de dificuldade e contagem de estrelas — pedido explícito de "menos informação"; essa informação não foi realocada para outro lugar (não era obrigatório, e simplificar era o próprio pedido). Estados visuais preservados: jogável = amarelo + `PulseTap`; bloqueado por progresso = cinza + cadeado; `comingSoon` = cinza + badge "EM BREVE" pequeno (sem mundo `comingSoon` hoje, mas o caminho de código continua correto). Toda a lógica existente (`_isWorldUnlocked`, `_handleTap` com `SnackBar`, `_openWorld` por `WorldGameType`) foi preservada — só o `onTap` de um card jogável passou a checar `Onboarding` antes de navegar (item 1 acima).

3. **Configurações** (`SettingsDialog`, `lib/widgets/settings_dialog_widget.dart`) é um `Dialog` modal (`showDialog`), não uma tela cheia nova — `StatefulWidget` com `setState` próprio (mesmo motivo de `MuteButton` já ser `StatefulWidget`: `AppSounds.instance.muted` é um campo simples, não um `ValueNotifier`). Conteúdo: título "CONFIGURAÇÕES" (`AppText.eyebrow`), botão de fechar (`IconActionButton` com `Icons.close` do Material — não valia a pena criar um ícone SVG próprio só para um X, `AppIcons` não tem um) e uma linha "Som" + `Switch` (cores do tema via `activeColor`/`activeTrackColor`/`inactiveThumbColor`/`inactiveTrackColor`, nunca cor literal) ligado a `AppSounds.instance.muted` (invertido: `Switch` "ligado" = não mutado). Aberto pelo novo botão de engrenagem (`AppIcons.settings`, já existia como ícone) no canto superior direito da Splash, no lugar exato onde `MuteButton` estava antes — `MuteButton` continua em uso em Gameplay/Vitória/Falha/`CodePuzzleResultScreen`, só saiu da Splash (o volume continua acessível ali dentro do `SettingsDialog`).

**Por quê:** pedido explícito do usuário depois de testar o app fisicamente — vídeo de tutorial adicionaria peso ao app (arquivo de vídeo + pacote de player) sem necessidade num app de estande com sessões curtas; a lista vertical de mundos com informação demais (subtítulo, pill, estrelas) competia visualmente com o que importa no primeiro toque (qual mundo jogar); uma tela cheia de Configurações para um único toggle era desproporcional.

**Como aplicar:** ao adicionar um Mundo 4 (se algum dia), lembrar de adicionar a entrada correspondente em `worldTutorials` (`tutorial_content.dart`) — se faltar, `_enterWorld`/`_openTutorial` não quebram (fallback marca visto e segue direto), mas o jogador perde a explicação da mecânica nova. Se o `SettingsDialog` ganhar mais opções no futuro (ex.: idioma, dificuldade), o padrão de `Row(label + controle)` dentro do `Column` já comporta itens novos sem redesenho.

---

## 2026-09-05 — 3 mundos = 3 motores de jogo diferentes (não 3 níveis de dificuldade do mesmo labirinto)

**Decisão:** o plano original para "3 mundos" era dificuldade crescente no mesmo motor de labirinto (mais paredes, tabuleiros maiores). O usuário corrigiu explicitamente: cada mundo deve ser um **mini-jogo de lógica diferente** — Mundo 1 continua o labirinto atual (grid, Andar/Virar/Repetir); Mundo 2 será uma esteira com condicional (blocos "Se [cor] → Caixa", introduzindo `if`); Mundo 3 será puzzles de código estilo Mimo (reordenar linhas embaralhadas / achar a linha com bug), sem grid nem mascote andando. Arquitetura completa das 3 etapas em `.claude/plans/Mundos.md`.

**Por quê:** pedido explícito do usuário — ele queria jogos de lógica variados no mesmo app, não só labirintos progressivamente maiores/mais difíceis.

**Como aplicar (Etapa 1, implementada agora):** `lib/models/level.dart` ganhou `WorldGameType` (`maze`/`conveyor`/`codePuzzle`) e `GameWorld` (`number`, `name`, `subtitle`, `difficultyLabel`, `gameType`, `comingSoon`, `levels`), e a lista `worlds` com os 3 mundos. Mundo 2 ("Esteira de Bugs") e Mundo 3 ("Modo Debug") nascem com `comingSoon: true` e `levels: const []` — sem fases e sem motor ainda, aguardando as Etapas 2/3 do plano (que trazem `ConveyorLevel`/`belt_executor.dart` e `CodePuzzleLevel`/`code_puzzle_checker.dart`, respectivamente). `GameplayScreen._goToResultScreen` passou a resolver a próxima fase via `worlds.firstWhere((w) => w.number == level.world).levels` em vez de `world1Levels` fixo, para já funcionar corretamente quando Mundo 2/3 ganharem fases.

**Ajustes de UX Reviewer aplicados na mesma Etapa 1:** (1) `AppColors.grayLockIcon` clareado de `0xFF8A8A8A` para `0xFFC4C4C4` — o par cadeado/"EM BREVE" sobre `grayLocked` estava com contraste ~2.4:1, abaixo do mínimo AA (~4.5:1) exigido por `.claude/rules/design.md` ("alto contraste sempre — estande iluminado"); token compartilhado, então o ajuste também melhora as fases bloqueadas da Seleção de Fases. (2) Em `WorldSelectScreen`, cards de mundo não jogável (`comingSoon` ou bloqueado por progresso) agora sempre têm `onTap` (nunca `null`) — mostram um `SnackBar` explicando o motivo ("Em breve!"/"Complete o Mundo N primeiro") em vez de não reagir ao toque, que antes não dava feedback nenhum (`HardShadowBox` só tem `InkWell`/ripple quando `onTap != null`). Um novo campo `tappable` em `_WorldCard` decide separadamente o destaque visual "JOGAR"/pulso (`PulseTap`), independente do card ter ou não um `onTap`.

---

## 2026-09-09 — "Enquanto" (Mundo 2): `BeltExecutor.expand` deixa de ser puramente estrutural e vira "ciente da fila"

**Decisão:** adicionados dois blocos novos ao Mundo 2 ("Esteira de Bugs"): `BeltBlockType.whileYellowToBinA`/`whilePurpleToBinB` ("Enquanto Amarelo/Roxo → Caixa"), regra completa em `.claude/docs/GAME_DESIGN.md` ("Enquanto — repetição condicional") e `.claude/memory/domain-glossary.md`. Diferente de `repeat` (modificador fixo de 3× sobre o bloco seguinte), `Enquanto` é autocontido e sua expansão depende do conteúdo real de `ConveyorLevel.itemQueue` na posição em que o bloco é alcançado. Isso mudou a arquitetura de `BeltExecutor.expand()`: antes era uma função puramente estrutural (só olhava a forma do `Programa`, nunca a fila); agora simula um cursor otimista (`simulatedIndex`) progredindo pela fila **assumindo que nenhuma classificação anterior errou** — só para saber quantos Passos cada bloco `while` gera. A checagem real de acerto/erro continua 100% em `applyStep`, passo a passo, como antes (`expand` nunca decide vitória/derrota, só quantidade e ordem de passos). `applyStep` trata `while*` exatamente igual a `if*` (mesma cor esperada) — a garantia de "Enquanto nunca falha" vem inteiramente de `expand` só gerar passos `while` quando a cor já bate, não de um caso especial dentro de `applyStep`.

**Por quê:** pedido explícito do usuário — as fases mais difíceis do Mundo 2 (9-12) usavam só `Se`/`Repetir 3×` fixo e ficaram fáceis demais/repetitivas. Isso é justificável dentro de `expand()` continuar Dart puro e sem branching real (ver `.claude/rules/architecture.md`) porque a fila é toda conhecida de antemão, sem aleatoriedade — a simulação otimista é determinística e barata (mesmo custo de uma passada linear pela fila).

**Fases redesenhadas (só 9-12, 1-8 inalteradas):** Fase 9 ("Enquanto a cor não mudar", 4 amarelos + 3 roxos = 7 itens, `optimalBlocks: 2`) introduz `Enquanto` como a opção **mais eficiente** (uma solução sem `Enquanto` ainda cabe no `maxBlocks: 8` com 5 blocos, mas rende só 2 estrelas). Fases 10-12 tornam `Enquanto` **obrigatório** — a menor solução possível sem ele ultrapassa `maxBlocks: 8` (Fase 10: 11 itens/3 grupos, sem `Enquanto` precisaria de 9 blocos; Fase 11: 14 itens/4 grupos, precisaria de 11; Fase 12: 12 itens/3 grupos — 5 amarelos + 4 roxos + 3 amarelos —, precisaria de bem mais que 8), sempre porque os grupos de mesma cor têm tamanho não-múltiplo de 3 (4, 5 itens seguidos), onde `Repetir 3×` sempre sobra resto. `optimalBlocks`/`hintProgram` de cada uma foram recalculados e verificados em `test/game/conveyor_level_catalog_test.dart` (que já cobre `world2Levels` genericamente, sem precisar de teste dedicado por fase).

**Efeito colateral necessário (não é redesign de UI):** `lib/widgets/belt_block_chip_style.dart` (`styleForBeltBlock`) tinha um `switch` exaustivo sobre `BeltBlockType` — precisou ganhar os 2 casos novos (`Enquanto Amarelo → A`/`Enquanto Roxo → B`, mesmas cores de `if`) só para o projeto continuar compilando (`flutter analyze` reprova switch não-exaustivo); não foi adicionado nenhum botão novo na tela (`ConveyorGameplayScreen`) — isso fica para a etapa de UI.

**Como aplicar:** ao adicionar um comando novo ao Mundo 2 que também dependa do conteúdo da fila (não só da forma do Programa), seguir o mesmo padrão: resolver em `expand()` via simulação otimista de cursor, nunca decidir acerto/erro ali — `applyStep` continua a única fonte de verdade de classificação certa/errada.

---

## 2026-09-09 — Etapa 2 (UI): `GameLevel`, `VictoryScreen`/`FailureScreen` genéricas, telas/visual do Mundo 2

**Decisão:** completando a Etapa 2 (`.claude/plans/Etapa2-Esteira.md`; modelos/motor do Mundo 2 já implementados antes desta entrada — ver seção "Mundo 2 — Esteira" em `.claude/docs/GAME_DESIGN.md`), a parte de UI trouxe:

1. **`GameWorld.levels` generalizado**: nova interface mínima `GameLevel` (`lib/models/game_level.dart`, só `String get id`), implementada por `Level` (Mundo 1) e `ConveyorLevel` (Mundo 2). `GameWorld.levels` passou de `List<Level>` para `List<GameLevel>` — Dart aceita atribuir `List<Level>`/`List<ConveyorLevel>` a esse campo sem cast (generics covariantes). Cada tela de Seleção de Fases específica de um motor (`LevelSelectScreen`, `ConveyorStageSelectScreen`) converte de volta para o tipo concreto com `.cast<Level>()`/`.cast<ConveyorLevel>()` — a alternativa (um tipo selado `GameLevel` com subtipos e pattern matching) pareceu mais cerimônia do que o problema pede para só 2 motores.
2. **`VictoryScreen`/`FailureScreen` desacopladas do `Level` do labirinto**: os construtores passaram a receber dados primitivos prontos (`levelNumber`, `blocksUsed`, `maxBlocks`, `optimalBlocks`, `hasNext` na Vitória; `levelNumber`, `attempt`, `reasonText`, `maxBlocks`, `hintChips: List<Widget>` na Falha) e um callback de navegação (`onPrimaryAction`/`onBackToMenu`) — as duas telas não conhecem `Level`/`ConveyorLevel`/`GameOutcome`/`BeltOutcome` nem decidem `Navigator` sozinhas. Quem monta cada tela (`GameplayScreen` ou `ConveyorGameplayScreen`) já sabe interpretar o outcome do motor certo — o switch que converte `GameOutcome`→texto migrou de dentro de `FailureScreen` para uma função privada em `gameplay_screen.dart` (`_reasonTextFor`), e o equivalente para `BeltOutcome` vive em `conveyor_gameplay_screen.dart`. Motivo: nenhum outro desenho (ex. um enum de resultado unificado entre motores) evitava acoplar as duas telas de resultado a um motor específico sem introduzir um tipo "genérico" artificial pior que passar os campos já resolvidos.
3. **Mundo 2 jogável**: `worlds[1]` (Esteira de Bugs) virou `comingSoon: false`/`levels: world2Levels`; `WorldSelectScreen._openWorld` agora despacha por `WorldGameType` (`maze` → `LevelSelectScreen`, `conveyor` → `ConveyorStageSelectScreen` nova, `codePuzzle` → `throw UnimplementedError` defensivo, nunca deveria ser alcançado enquanto Mundo 3 for `comingSoon`).
4. **Visual da esteira (`ConveyorGameplayScreen`)**: painel único ("PRÓXIMO ITEM") com (a) fila horizontal rolável de círculos coloridos (amarelo/roxo, sem glifo/ícone de "bug" — a cor já é a única informação que importa para a mecânica), item atual com borda branca + leve glow + `PulseTap` (mesma linguagem visual do alvo pulsante do Mundo 1, para reforçar "isto é o que importa agora" sem texto), itens já processados com opacidade reduzida; (b) duas "Caixas" (pills "Caixa A" amarela / "Caixa B" roxa) abaixo, sempre visíveis, para o mapeamento cor→caixa nunca depender de memória. Comandos: em vez da grade de 4 colunas do Mundo 1 (rótulos curtos: "Andar", "Virar ←"), o Mundo 2 tem só 3 comandos com rótulos mais longos ("Se Amarelo → A" etc.) — layout viraram 2 botões lado a lado (condicionais) + 1 botão de largura cheia (Repetir), dando mais espaço por rótulo. Reforço geral (não específico do Mundo 2): `CommandButton` passou a envolver o rótulo em `FittedBox(fit: scaleDown)` — encolhe em vez de quebrar linha/estourar quando o texto não cabe na célula, útil tanto para os rótulos mais longos do Mundo 2 quanto como proteção geral do widget.
5. **Som/haptics do Mundo 2**: reaproveita `AppSounds.instance` sem métodos novos — `run()` ao apertar Play, `turn()` a cada item classificado (não há distinção "andar vs. virar" na esteira, então um som só por passo já basta), `victory()`/`failure()` nas telas de resultado (inalterados).
6. **Layout de tablet da `ConveyorGameplayScreen`**: só o layout empilhado (celular) foi implementado nesta etapa — o layout lado a lado que `GameplayScreen` (Mundo 1) tem para telas ≥700px não foi replicado aqui por tempo; registrado como pendente em `.claude/plans/Roadmap.md` (não é bloqueante: a tela não estoura em tablet, só não aproveita a largura extra).

**Como aplicar:** ao trazer o Mundo 3 (`codePuzzle`), o mesmo padrão se repete — um `CodePuzzleLevel implements GameLevel`, uma tela de Seleção de Fases própria, uma Gameplay própria, e `VictoryScreen`/`FailureScreen` reaproveitadas do jeito que já estão (não deveriam precisar de nenhum campo novo, já que os dois construtores são deliberadamente genéricos).

---

## 2026-09-08 — Sons e haptics: nova camada `lib/audio/`, pacote `audioplayers`, SFX sintetizado

**Decisão:** primeiro item do `Roadmap.md` ("Sons e haptics") implementado. Nova camada `lib/audio/` (Dart com Flutter — infraestrutura chamada por `screens/`/`widgets/`, nunca por `models/`/`game/`, ver `.claude/rules/architecture.md`):
- `sound_player.dart` — interface `SoundPlayer` (só para permitir um fake nos testes, sem mockar `MethodChannel`).
- `audioplayers_sound_player.dart` — implementação real com o pacote `audioplayers` (`^6.1.0`, adicionado ao `pubspec.yaml`).
- `app_sounds.dart` — singleton `AppSounds.instance` (mesmo padrão de `Progress.instance`): `muted` (estado de sessão, mesma decisão em aberto de persistência — ver entrada acima), `walk()`/`turn()`/`run()` (efeitos da Execução e do Play) e `victory()`/`failure()` (som **+** `HapticFeedback` via `package:flutter/services.dart`, sem pacote novo para vibração). Toda chamada ao player/haptic é engolida em `try/catch` — áudio nunca pode derrubar uma sessão no estande.

**Gatilhos** (confirmados com o usuário antes de implementar): som de Andar/Virar sincronizado com cada passo real da Execução em `GameplayScreen._run()` (não ao montar o Programa); Play dispara `run()`; `VictoryScreen`/`FailureScreen` disparam `victory()`/`failure()` no `initState`. Um botão de mute (`MuteButton`, `lib/widgets/`) foi adicionado às 4 telas que tocam som — Splash, Gameplay, Vitória e Falha (achado do UX Reviewer: Vitória/Falha tocam som sozinhas no `initState` sem controle visível antes desse ajuste) — pensado para várias telas do estande tocando som ao mesmo tempo. Em Vitória/Falha ele fica sobreposto (`Align(topRight)` fora da `Column` rolável) para não deslocar o conteúdo centralizado.

**Ajustes de UX Reviewer aplicados na mesma mudança:** `HapticFeedback` de `failure()` trocado de `heavyImpact` para `lightImpact` — o impacto físico mais forte não pode ficar reservado para o erro (contradiz "falha nunca é punitiva"); `MuteButton` subiu de `size: 40`/`44` para `48` em todas as telas (consistência de área de toque com os outros `IconActionButton`); padding horizontal do contador de blocos na Gameplay reduzido de 14 para 10 para abrir espaço sem precisar encolher o botão de mute.

**SFX placeholder sintetizado:** sem asset de som real disponível (mesma situação que a arte do mascote teve antes da arte real chegar, ver entrada acima) — em vez de baixar de terceiros (risco de licença), os 5 `.wav` em `assets/audio/` foram gerados por síntese (seno + envelope) pelo script `tool/generate_sfx.py`, comitado para permitir regerar/ajustar o tom depois. Substituível por SFX de verdade sem mudar `lib/audio/` (só trocar os arquivos).

**Por quê:** pedido explícito do usuário, na ordem som → layout de tablet → Mundo 2 → Mundo 3. Decisões de produto (som sincronizado à Execução, vitória/falha com som+vibração, botão de mute) confirmadas via pergunta direta antes de implementar.

**Como aplicar:** `AppSounds.player` é `@visibleForTesting` — testes de tela que exercitam Gameplay/Vitória/Falha (`gameplay_flow_test.dart`, `no_overflow_test.dart`) trocam por um `FakeSoundPlayer` (`test/helpers/fake_sound_player.dart`) em `setUp`/`tearDown`, para não depender de `MethodChannel` real do `audioplayers` (sem mock configurado em `test/`). `_player` só é construído de verdade (tocando plugin) na primeira chamada real, nunca na construção do singleton — importante para não exigir um binding do Flutter só para acessar `AppSounds.instance`.

---

## 2026-09-09 — Motor do Mundo 2 ("Esteira de Bugs"): modelos, `BeltExecutor` e `BeltOutcome` próprio

**Decisão:** implementada a parte de Game Logic da Etapa 2 (`.claude/plans/Etapa2-Esteira.md`) — só modelos + motor + docs + testes de motor, sem telas (UI fica pra próxima etapa). Modelos novos: `lib/models/belt_item.dart` (`BeltItemColor { yellow, purple }`), `lib/models/belt_block.dart` (`BeltBlockType { ifYellowToBinA, ifPurpleToBinB, repeat }` + classe `BeltBlock`, mesma forma de `Block`/`BlockType` do Mundo 1), `lib/models/conveyor_level.dart` (`ConveyorLevel` — mesma forma de `Level`, com `itemQueue: List<BeltItemColor>` no lugar do grid, e `world2Levels` com as 12 fases). Motor novo: `lib/game/belt_executor.dart` (`BeltExecutor`), espelhando `ProgramExecutor` — `expand` (mesma regra de expansão de `Repetir 3×`, copiada literalmente), `BeltCursor` (equivalente a `GameCursor`, mas só com `nextItemIndex`), `applyStep`/`evaluateFinal`.

**Outcome do motor da Esteira — enum próprio, não reaproveita `GameOutcome`:** criado `BeltOutcome { win, misclassified, incomplete }` dentro de `lib/game/belt_executor.dart`, em vez de adicionar um valor novo a `GameOutcome` (`lib/game/game_result.dart`, hoje `win`/`crash`/`farFromGoal`). Motivo: `GameOutcome` já é consumido por um switch exaustivo em `lib/screens/failure_screen.dart` (Mundo 1) — estender esse enum compartilhado obrigaria mexer em tela que não é escopo desta etapa (UI fica para o UI Engineer) e acoplaria os dois motores num tipo só sem necessidade real (os dois nunca colidem no mesmo fluxo). `BeltOutcome.misclassified` é o equivalente semântico de `GameOutcome.crash` (bloco não bate com a cor real do item, ou sobra passo com a fila já vazia); `BeltOutcome.incomplete` é o equivalente de `GameOutcome.farFromGoal` (Programa termina sem esvaziar a fila). Documentado em `.claude/docs/GAME_DESIGN.md`, seção "Mundo 2 — Esteira".

**Termos em português finais (glossário):** "Esteira" (mecânica/motor), "Item" (elemento da fila, evitando confundir com "bug" no sentido de defeito de software mesmo o mundo se chamando "Esteira de Bugs"), "Caixa A"/"Caixa B" (destino da classificação — não "Bin", mantendo tudo em português como o resto do glossário).

**`world2Levels` — as 12 fases:** `maxBlocks: 8` constante em todas (como no Mundo 1), com `itemQueue` crescendo de 1 a 12 itens. Progressão verificada à mão e por teste (`test/game/conveyor_level_catalog_test.dart`, roda `BeltExecutor` de verdade contra cada `hintProgram`): fases 1–3 sem `repeat` (fila curta, cores variando); fase 4 introduz `repeat` (primeira fila com uma sequência de 3 itens da mesma cor); fases 5–7 misturam sequências de 3 com itens avulsos; fase 8 é uma fila alternada sem nenhuma sequência de 3 repetível (força usar quase todo o `maxBlocks` em blocos avulsos, `optimalBlocks: 7`); fases 9–11 voltam a ter sequências de 3 compressíveis, mas com filas mais longas (8–10 itens); fase 12 (final) exige `repeat` 4 vezes (`optimalBlocks: 8 == maxBlocks`, igual à fase 10 do Mundo 1 — "sem espaço pra errar").

**Como aplicar:** `worlds`/`GameWorld` em `lib/models/level.dart` **não foram tocados** nesta etapa (Mundo 2 continua `comingSoon: true`/`levels: const []`) — combinado explicitamente no escopo desta rodada, fica para a próxima etapa (junto das telas), quando `GameWorld.levels` também precisa generalizar de `List<Level>` para aceitar `ConveyorLevel` (ver `.claude/plans/Etapa2-Esteira.md`, item 1 do escopo original). Próxima etapa (UI Engineer): telas de Seleção de Fases/Gameplay do Mundo 2, `belt_block_chip_style.dart`, e aí sim ligar `world2Levels` em `worlds`.

---

## 2026-09-09 — Layout de tablet: `GameplayScreen` lado a lado acima de 700px

**Decisão:** segundo item do `Roadmap.md` ("Layout de tablet") implementado, só na `GameplayScreen` (é a única tela com conteúdo suficiente pra se beneficiar — as outras já cabem bem numa coluna centralizada em qualquer largura). `build()` usa `LayoutBuilder` para escolher entre `_buildPhoneLayout()` (o que já existia: tudo empilhado numa `Column` dentro de `SingleChildScrollView`, sem mudança) e `_buildTabletLayout()` (novo: `Column` com o header no topo e, embaixo, um `Row` — tabuleiro à esquerda (`Expanded(flex: 5)`), "Seu Programa" + comandos + Play à direita (`Expanded(flex: 4)`, dentro de um `SingleChildScrollView` como rede de segurança para tablets de altura curta)). Breakpoint: `_tabletBreakpoint = 700.0` (largura) — testado com folga entre os tamanhos já cobertos por `no_overflow_test.dart` (celular até 430px, tablet 1024px).

`_buildBoard` deixou de ter um `maxWidth: 340` fixo — agora recebe `maxSize` (340 no celular, 640 no tablet) e calcula o lado do tabuleiro como `min(largura disponível, altura disponível, maxSize)`, porque no layout de tablet o tabuleiro fica dentro de um `Expanded` com altura finita (diferente do celular, onde a altura é `infinity` dentro do `SingleChildScrollView` e só a largura importa).

**Por quê:** pedido explícito do usuário, no lugar 2 da ordem som → layout de tablet → Mundo 2 → Mundo 3 — hoje o tabuleiro fica preso a 340px e sobra bastante espaço vazio num tablet, além de forçar scroll numa tela que já tem altura de sobra.

**Como aplicar:** novo teste `test/screens/gameplay_tablet_layout_test.dart` (com a `Key('gameplayBoard')` adicionada ao `SizedBox` do tabuleiro) confirma que o tabuleiro realmente cresce além de 340px em 1024×768 e continua ≤340px em 390×844 — sem esse teste, um erro na condição do breakpoint (ex.: sempre cair no layout de celular) passaria despercebido pelos testes de overflow existentes, que só checam ausência de exceção, não qual layout foi de fato usado.

**Ajuste de UX Reviewer aplicado na mesma mudança:** em tablet **retrato** (ex.: 768×1024), a coluna de comandos à direita ficava colada no topo com um vão vazio grande embaixo do Play, porque a altura sobra bastante (achado real, não bloqueante). Corrigido centralizando o conteúdo verticalmente quando sobra espaço: `Expanded(flex: 4, child: LayoutBuilder(...))` com `SingleChildScrollView > ConstrainedBox(minHeight: <altura disponível>) > Column(mainAxisAlignment: center, crossAxisAlignment: stretch, children: [_buildProgramArea()])`. Importante: usar `Column(mainAxisAlignment: center)` em vez de um `Center` direto — `Center` soltaria a largura travada que o `SingleChildScrollView` dá ao filho e quebraria o `crossAxisAlignment: stretch` de dentro de `_buildProgramArea()` (os botões/"Seu Programa" encolheriam para o tamanho do conteúdo em vez de esticar). Teste `test/screens/gameplay_tablet_layout_test.dart` ganhou um caso a mais confirmando que o `PrimaryPillButton` (Play) continua esticado (não encolhido) em tablet retrato.

---

## 2026-09-09 — Mundo 2 (Esteira de Bugs): ajustes finais de UX Reviewer + Code Reviewer

**Decisão:** fechando a Etapa 2 (`.claude/plans/Etapa2-Esteira.md`), 3 ajustes pós-revisão sobre o que a entrada "Etapa 2 (UI)" já registrou:

1. **Rótulo "PRÓXIMO ITEM" → "FILA DE ITENS"** (`conveyor_gameplay_screen.dart`) — achado do UX Reviewer: o painel mostra a fila inteira (só o item atual tem destaque de borda+pulso), então "PRÓXIMO ITEM" sugeria que só um item importava, quando o jogador precisa olhar a fila toda pra prever as próximas classificações.
2. **Ícone dos 2 comandos condicionais** ("Se Amarelo → A"/"Se Roxo → B") trocado da seta genérica (`AppIcons.arrowRight` sozinha) para uma bolinha (cor do `foreground`, ecoando visualmente o Item da esteira) + seta — achado do UX Reviewer: o salto conceitual "sequência" (Mundo 1) → "decisão baseada em cor" (Mundo 2, primeiro uso de `if` no jogo) ficava abrupto sem nenhum reforço visual além do texto do rótulo. Novo helper privado `_conditionIcon(size, {foreground})` em `conveyor_gameplay_screen.dart`.
3. **`GameplayHeader` extraído** (`lib/widgets/gameplay_header_widget.dart`) — achado do Code Reviewer: `_buildHeader()` em `GameplayScreen` (Mundo 1) e `ConveyorGameplayScreen` (Mundo 2) eram byte-a-byte idênticos (voltar, "FASE N"+título, contador de blocos, `MuteButton`). Widget novo recebe `levelNumber`/`title`/`blocksUsed`/`maxBlocks`/`onBack`; as duas telas passaram a só montar esses parâmetros.

**Por quê:** achados reais de revisão nesta mesma etapa, pequenos o bastante pra corrigir na hora em vez de virar item de Roadmap.

**Como aplicar:** `flutter analyze` limpo e as 89 specs da suíte inteira passando depois dos 3 ajustes (`test/screens/conveyor_flow_test.dart`/`no_overflow_test.dart` cobrem o resultado). Se um Mundo 3 futuro também tiver Gameplay com o mesmo cabeçalho, reaproveitar `GameplayHeader` direto, sem duplicar de novo.

---

## 2026-09-09 — Motor do Mundo 3 ("Modo Debug"): `CodePuzzleLevel` com fábricas nomeadas, `ScoreResult` reaproveitado, `Progress.blocksUsed` reaproveitado como "tentativas"

**Decisão:** implementada a parte de Game Logic da Etapa 3 (`.claude/plans/Etapa3-ModoDebug.md`) — modelos, motor/checker e pontuação, sem UI (telas ficam para a próxima etapa). Três escolhas concretas:

1. **Forma de `CodePuzzleLevel` para os 2 tipos** (`lib/models/code_puzzle_level.dart`): construtor privado `CodePuzzleLevel._` com todos os campos (inclusive os "do outro tipo", preenchidos com sentinela — `correctOrder`/`codeWithBug` vazios, `buggyLineIndex: -1`, `bugExplanation: ''`), mais 2 fábricas nomeadas públicas, `CodePuzzleLevel.reorder(...)` e `CodePuzzleLevel.findBug(...)`, cada uma só pedindo os campos do seu tipo e validando com `assert` (`correctOrder` não vazio; `buggyLineIndex` dentro dos limites de `codeWithBug`; `bugExplanation` não vazia). Preferido a campos nulináveis "soltos" porque o nome da fábrica já documenta a intenção no call site (`CodePuzzleLevel.findBug(...)` é autoexplicativo em `world3Levels`, um campo `type: CodePuzzleType.findBug` ao lado de vários campos nulináveis exigiria ler os `required`/comentários para saber quais preencher).
2. **Pontuação: `ScoreResult` reaproveitado, função nova** — `lib/game/code_puzzle_scoring.dart` (`computeCodePuzzleScore({required int attempts})`) devolve o mesmo `ScoreResult` (`stars`/`points`) de `lib/game/scoring.dart`, só que calculado por tentativas (3/2/1 estrelas na 1ª/2ª/3ª+ tentativa; pontos 1000 na 1ª, -300 por tentativa extra, piso 100) em vez de blocos vs. ótimo — fórmula documentada em `.claude/docs/GAME_DESIGN.md`, seção "Mundo 3 — Modo Debug", **antes** desta implementação. Não criei um tipo de resultado novo porque o único consumidor (tela de Resultado) só precisa de `stars`/`points`, independente da fórmula de origem — um `CodePuzzleScoreResult` duplicado seria puro ruído.
3. **`Progress.recordWin`: reaproveitado sem generalizar** — decidido **não** renomear `LevelProgress.bestBlocks`/o parâmetro `blocksUsed` de `Progress.recordWin` para algo mais neutro. Quando a próxima etapa (UI) ligar `CodePuzzleGameplayScreen`/telas de resultado, o ponto de chamada deve passar `Progress.instance.recordWin(level.id, stars: score.stars, blocksUsed: attempts)`, com um comentário ali explicando que `blocksUsed` guarda o número de Tentativas para fases do Mundo 3 (não blocos). Motivo: só um motor (de três) precisaria do nome novo, `Progress`/`LevelProgress` já são consumidos por `LevelSelectScreen`/`ConveyorStageSelectScreen`/`VictoryScreen`/`WorldSelectScreen` hoje, e trocar o nome público força revisar todos esses pontos por um ganho só cosmético — mesmo raciocínio de `BeltOutcome` não estender `GameOutcome` (ver entrada "Motor do Mundo 2" acima: reaproveitar um campo com nome “errado” documentado é preferível a acoplar/generalizar uma API compartilhada por pouco benefício).

**Por quê:** pedido explícito da tarefa (Game Logic Engineer, Etapa 3) para decidir e documentar essas 3 escolhas em vez de deixá-las em aberto para a próxima etapa.

**Como aplicar:** `lib/models/code_puzzle_level.dart` (`CodePuzzleType`, `CodeLine`, `CodePuzzleLevel`, `world3Levels` com 12 fases — 6 `reorder` seguidas de uma mistura de `reorder`/`findBug` cada vez mais sutil), `lib/game/code_puzzle_checker.dart` (`checkReorder`/`checkFindBug`), `lib/game/code_puzzle_scoring.dart` (`computeCodePuzzleScore`). Testes: `test/game/code_puzzle_checker_test.dart` (checker + scoring) e `test/game/code_puzzle_catalog_test.dart` (consistência das 12 fases, nos moldes de `level_catalog_test.dart`/`conveyor_level_catalog_test.dart`). `worlds`/`comingSoon` em `lib/models/level.dart` **não foram tocados** nesta etapa — a próxima etapa (UI) liga `world3Levels` lá, mesmo padrão da Etapa 2.

---

## 2026-09-09 — Etapa 3 (UI): Mundo 3 ligado, `GameplayHeader`/`ConfettiOverlay` generalizados, correção de overflow

**Decisão:** UI Engineer implementou a etapa de telas do Mundo 3 sobre o motor já pronto: `worlds`/`GameWorld` em `lib/models/level.dart` ligados (`comingSoon: false, levels: world3Levels`); `lib/screens/code_puzzle_stage_select_screen.dart` (mesmo padrão de `ConveyorStageSelectScreen`); `lib/screens/code_puzzle_gameplay_screen.dart` (alterna `reorder`/`findBug`; `reorder` reaproveita `ProgramBlockChip` num padrão "banco embaralhado → toca pra montar", embaralhamento com seed fixa `Random(level.id.hashCode)`; `findBug` usa `RichText`/regex de palavras-chave em `AppColors.lilac` para destaque simples de sintaxe); `lib/screens/code_puzzle_result_screen.dart` (**uma tela só**, `won: bool`, em vez de duas como os outros mundos — resultado é binário por tentativas, sem "quase certo"; título de derrota não-punitivo "Quase lá!", evitando repetir "bug" já usado no tema do mundo). `ConfettiOverlay` (`lib/widgets/confetti_overlay_widget.dart`) extraído de `_ConfettiPainter`/`AnimationController` que viviam inline em `victory_screen.dart`, reaproveitado por `CodePuzzleResultScreen` quando `won == true`. `GameplayHeader` generalizado: `blocksUsed`/`maxBlocks` (int) viraram `trailingChipText: String?` (texto livre; `null` esconde o chip) — Mundo 1/2 formatam `'$blocksUsed / $maxBlocks blocos'`, Mundo 3 passa `'Tentativa N'`.

**Correção de overflow (achado ao rodar `flutter test` depois da etapa, não pelo UI Engineer que não tem Bash):** o `trailingChipText` unificado (uma única `Text` tamanho 14) ficou mais largo que o chip antigo de dois tamanhos (`16`/`12`), estourando o cabeçalho em 320px em 4 telas (Mundo 1, Mundo 2, Mundo 3 `reorder`/`findBug` — de 0.75px a 15px, dependendo do texto). Corrigido em `gameplay_header_widget.dart` com `Container(constraints: BoxConstraints(maxWidth: 120)) > FittedBox(fit: scaleDown) > Text(maxLines: 1)` — garante que qualquer `trailingChipText`, de qualquer mundo atual ou futuro, nunca estoura o cabeçalho, encolhendo em vez de quebrar layout.

**Por quê:** pedido explícito do usuário, último item da ordem som → layout de tablet → Mundo 2 → Mundo 3.

**Como aplicar:** `flutter analyze` limpo e as 133 specs da suíte inteira passando (`test/screens/no_overflow_test.dart` cobre as 4 telas novas + as 2 telas de Resultado em vitória/derrota; `test/screens/code_puzzle_flow_test.dart` cobre vitória/derrota real dos dois tipos de puzzle; `test/screens/world_select_screen_test.dart` atualizado — Mundo 3 agora navega em vez de "EM BREVE"). Layout de tablet lado a lado (como `GameplayScreen`/Mundo 1 tem) não foi replicado em `CodePuzzleGameplayScreen` nesta etapa — registrado como pendência não bloqueante em `.claude/plans/Roadmap.md`, mesmo padrão já usado pro Mundo 2.

---

## 2026-09-09 — Mundo 3: 2 achados reais de revisão corrigidos (overflow em `ProgramBlockChip`, estado não resetado ao repetir)

**Decisão:** fechando a Etapa 3, 2 bugs reais encontrados pelo Code Reviewer e pelo UX Reviewer:

1. **Overflow em `ProgramBlockChip` reaproveitado para linhas de código** (`lib/widgets/program_block_chip_widget.dart`) — achado do Code Reviewer, com um teste temporário cobrindo as 12 fases de `world3Levels` (não só a primeira, que `no_overflow_test.dart` testava até então): 4 fases (`world3_level3`, `5`, `8`, `11` — linhas como `for (int i = 0; i < 3; i++) {`) estouravam o chip em celular, porque o `Row(mainAxisSize: min)` interno não tinha nenhum teto de largura (o widget foi desenhado só pra rótulos curtos de Bloco, "Andar"/"Repetir"). Corrigido com `Container(constraints: BoxConstraints(minHeight: 44, maxWidth: MediaQuery.sizeOf(context).width - 80))` + `Flexible(child: Text(label))` (sem `maxLines`/`ellipsis` — texto quebra em várias linhas em vez de truncar, porque truncar apagaria justamente o código que o jogador precisa ler pra reordenar certo). `no_overflow_test.dart` ganhou uma varredura das 12 fases de `world3Levels` (não só a primeira) pra não repetir esse ponto cego — o teste "verde" de antes dava falsa confiança.
2. **Estado não resetado ao "Tentar de novo" numa derrota** (`lib/screens/code_puzzle_gameplay_screen.dart`) — achado do UX Reviewer: como `CodePuzzleResultScreen` só faz `pop()` no botão de derrota (reexibe a mesma instância de `CodePuzzleGameplayScreen`), `_selectedLineIndex`/`_sequenceIndices` da tentativa errada continuavam preenchidos — `_canConfirm` já voltava `true`, deixando o jogador apertar "Confirmar" de novo sem perceber que precisava mudar a resposta. Corrigido: `_goToResultScreen` agora dá `await` no `Navigator.push` e, se `!won`, limpa os dois campos com `setState` assim que a tela de Resultado é fechada.

**Por quê:** achados reais das revisões desta mesma etapa — pequenos e localizados o bastante pra corrigir na hora.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com **169 specs** passando (133 de antes + 36 novas da varredura das 12 fases do Mundo 3 em 3 tamanhos de tela). Se um mundo futuro também reaproveitar `ProgramBlockChip` para texto de tamanho variável, o teto de largura/`Flexible` já cobre isso — não precisa de ajuste novo.

---

## 2026-09-09 — "Enquanto" (Mundo 2): botões novos em `ConveyorGameplayScreen`

**Decisão:** fechando a feature "Enquanto" (motor já implementado numa etapa anterior desta mesma sessão — ver entrada acima, "`BeltExecutor.expand` deixa de ser puramente estrutural"), adicionei os 2 botões novos na tela de Gameplay do Mundo 2 (`lib/screens/conveyor_gameplay_screen.dart`): "Enquanto Amarelo → A"/"Enquanto Roxo → B", numa segunda `Row` de 2 colunas (mesmo padrão dos botões "Se"), entre a linha de "Se" e o botão "Repetir 3×" — agrupando visualmente os 2 pares de condicionais (fixo `Se` / condicional `Enquanto`) antes do modificador de repetição. Ícone novo, `_whileIcon` (bolinha da cor do Item + ícone de `Repetir`, em vez de bolinha + seta do `_conditionIcon` de "Se") — reforça visualmente "isto também repete, mas condicionalmente", diferenciando de "Se" (decisão única) sem inventar um ícone novo em `AppIcons` (reaproveita `AppIcons.repeat`, já existente).

**Por quê:** pedido explícito do usuário — as fases mais difíceis da Esteira estavam fáceis demais, faltava um comando de repetição condicional.

**Como aplicar:** `test/screens/conveyor_flow_test.dart` ganhou um teste de fluxo real tocando os 2 botões novos (Fase 9, `world2Levels[8]`, 4 amarelos + 3 roxos → 2 blocos "Enquanto", vitória com pontuação máxima) — os testes de motor já cobriam `expand`/`applyStep` a fundo, mas nenhum teste exercitava os botões de verdade antes deste. `flutter analyze` limpo, **176 specs** passando (169 de antes + `no_overflow_test.dart` já cobria `ConveyorGameplayScreen` de forma geral, sem precisar de caso novo, + 1 teste de fluxo novo).

---

## 2026-09-09 — "Enquanto": 2 achados reais de UX corrigidos (diferenciação visual, feedback de zero itens)

**Decisão:** 2 bugs de UX reais encontrados pelo UX Reviewer, corrigidos na hora:

1. **"Se" e "Enquanto" visualmente idênticos além do ícone pequeno** — `CommandButton` (`lib/widgets/command_button_widget.dart`) ganhou um campo opcional `border: Border?` (repassado pro `HardShadowBox` que já suportava isso). Os 2 botões "Enquanto" em `conveyor_gameplay_screen.dart` passaram a ter um contorno de 3px na cor do `foreground` (mesma cor já usada no ícone/texto do próprio botão — nenhuma cor nova) — diferencia visualmente de "Se" (sem contorno) mesmo empilhados na mesma coluna de cor, sem precisar inventar um token novo.
2. **Bloco "Enquanto" com zero itens classificados não dava nenhum sinal visual** — `ConveyorGameplayScreen._run()` foi reestruturado: em vez de iterar direto sobre os `BeltExecutionStep`s gerados por `expand()`, agora itera por bloco do Programa (`_program`) e consome os passos correspondentes a cada um; quando um bloco `Enquanto` não gera nenhum passo (condição já começa falsa), o chip dele ainda recebe um flash curto (`_zeroMatchFlashDuration`, 250ms — mais curto que `_stepDuration` porque nada de fato acontece) antes de seguir pro próximo bloco. `Repetir` continua nunca destacado diretamente (mesmo comportamento de sempre — só o bloco alvo que ele repete acende), e blocos `Se` sempre produzem exatamente 1 passo (nunca entram nesse caminho).

**Por quê:** achados reais da revisão desta mesma etapa — pequenos e localizados, corrigidos na hora em vez de virar item de Roadmap.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com as 176 specs continuando a passar (a reestruturação do loop de `_run()` preserva o comportamento exato dos passos reais — só adiciona o caminho novo para "zero passos"). Não foi adicionado teste de widget dedicado pro timing do flash (~250ms) — é feedback visual transitório, mesmo critério de "não testar detalhe visual frágil" de `.claude/rules/testing.md`; a cobertura existente (testes de motor pro caso "zero itens" + teste de fluxo feliz) já garante que a lógica em si está correta.

---

## 2026-09-09 — Botões de comando compactados: `CommandButtonGrid` extraído, reaproveitado por Mundo 1 e 2

**Decisão:** pedido explícito do usuário depois de testar o app — os botões de comando estavam grandes demais, "um por coluna" (a árvore de `Row`s manual do Mundo 2 — 2+2+1 — deixava só 1-2 comandos visíveis por linha; o Mundo 1 já usava uma grade de 4 colunas, mas com células de até 90px, grandes demais). Extraído `lib/widgets/command_button_grid_widget.dart` (`CommandButtonGrid`) do código de grade que já existia inline em `GameplayScreen` (Mundo 1) — mesmo padrão de largura de célula sempre derivada do espaço real (`LayoutBuilder`), altura com teto (`maxCellHeight`, agora 68 nos dois mundos, antes 90 só no Mundo 1). `GameplayScreen` (4 comandos → `crossAxisCount: 4`, já era assim, só ficou mais compacto) e `ConveyorGameplayScreen` (5 comandos → `crossAxisCount: 5`, antes 3 `Row`s manuais) passaram a usar o widget compartilhado.

**Por quê:** pedido explícito — "exiba os comandos lado a lado... 4 ou 5 por linha".

**Como aplicar:** `flutter analyze` limpo; `flutter test` com as 176 specs passando, incluindo `no_overflow_test.dart` (confirma que 5 colunas em 320px não estoura — `CommandButton` já tinha `FittedBox` nos rótulos, absorve a densidade extra) e `conveyor_flow_test.dart` (toca os botões pelo texto, continua funcionando com o novo layout). Se um mundo futuro precisar de outra quantidade de colunas, reaproveitar `CommandButtonGrid` direto (`crossAxisCount` já é parâmetro).

---

## 2026-09-09 — Ajuste do ajuste: botões de comando maiores de novo, chips de "Seu Programa" organizados em grid

**Decisão:** o usuário testou o app e achou os botões de comando pequenos demais depois do `CommandButtonGrid` (entrada acima) — pediu pra deixá-los maiores, "para que o usuário possa entender o que eles querem dizer" (legibilidade > densidade). Ajustado: `GameplayScreen` (Mundo 1) `maxCellHeight: 68 → 100`; `ConveyorGameplayScreen` (Mundo 2) `crossAxisCount: 5 → 3` (com `maxCellHeight: 100`) — em telas de celular, a largura da célula é limitada pela contagem de colunas, não pelo teto de altura, então reduzir de 5 pra 3 colunas é o que realmente deixa os botões maiores (o teto de altura sozinho quase não muda nada em telas estreitas, só limita o tamanho em tablets largos).

Também esclarecido que o pedido original incluía a área "SEU PROGRAMA" (chips do Programa já montado, acima dos botões) — extraído `lib/widgets/program_chip_grid_widget.dart` (`ProgramChipGrid`), que organiza os `ProgramBlockChip`s em colunas de largura fixa (`crossAxisCount`, padrão 4), usando `Wrap` por baixo (não `GridView`) para cada chip poder crescer em altura livremente se o rótulo for longo (Mundo 2: "Enquanto Amarelo → A" quebra em 2+ linhas sem estourar a célula — mesmo `Flexible`/sem `ellipsis` já usado em `ProgramBlockChip`, ver entrada "Mundo 3: 2 achados reais de UX corrigidos"). Aplicado em `GameplayScreen`/`ConveyorGameplayScreen`, trocando o `Wrap` de largura livre que tinha antes.

**Por quê:** pedido explícito do usuário, corrigindo o excesso da mudança anterior.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com as 176 specs continuando a passar. Se o número de colunas de `ProgramChipGrid`/`CommandButtonGrid` precisar mudar nesta ou em telas futuras, são ambos parâmetros (`crossAxisCount`), não precisa duplicar o widget.

---

## 2026-09-09 — `TutorialModal`: botão "Aprendi" ficava fora da tela em celular pequeno (achado real, não só de teste)

**Decisão:** ao escrever `test/screens/tutorial_flow_test.dart` pra cobrir o fluxo do `TutorialModal` (`.claude/memory/decisions.md`, entrada "Tutorial vira modal ilustrado..."), um `tester.tap(find.text('Aprendi'))` falhava de forma determinística (mesmo offset exato em execuções repetidas) com o toque caindo na barreira do modal em vez do botão. Investigado com um teste ad-hoc medindo `tester.getRect()` do botão em 4 tamanhos de tela — confirmado: em **320×568** (menor celular suportado, testado em `no_overflow_test.dart`), o botão "Aprendi" das 3 fases ficava a mais de 150px **fora** da tela (`buttonRect.bottom` ≈ 743-843 contra `screenHeight: 568`). Não era só um problema de teste — era um bug real: o `SingleChildScrollView` original continha mascote+título+tips **e** o botão juntos, então em telas baixas o conteúdo inteiro precisava rolar bastante pra alcançar "Aprendi" — e como `barrierDismissible: false` (decisão deliberada, o jogador precisa confirmar que leu), um jogador que não percebesse que dava pra rolar ficaria travado sem nenhuma pista visual de que havia mais conteúdo abaixo.

**Correção em `lib/widgets/tutorial_modal_widget.dart`:** separado o `Column` em duas partes — um `Flexible(child: SingleChildScrollView(...))` só com mascote/título/tips, e o botão "Aprendi" **fora** dele, sempre fixo na parte de baixo do card do modal (mesmo padrão de "cabeçalho/corpo rolável/rodapé fixo" de diálogos padrão). Revalidado com o mesmo teste ad-hoc: botão 100% visível sem rolagem nos 4 tamanhos (320×568, 390×844, 400×900, 1024×768) para as 3 fases.

**Por quê:** achado real ao escrever o teste de fluxo desta mesma feature — não era hipotético, o script de medição confirmou o overflow de verdade antes da correção.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com **182 specs** passando. Ao escrever conteúdo novo de tutorial (Mundo 4 futuro, ou mais tips num mundo existente), o botão "Aprendi" nunca sai de vista — só o texto acima dele rola, então não precisa reconferir esse limite manualmente de novo.

---

## 2026-09-09 — Botão "?" de tutorial diferenciado do botão voltar (achado real de UX)

**Decisão:** achado do UX Reviewer sobre a entrega de Configurações/Mundos/Tutorial (entrada acima): nas 3 telas de Seleção de Fases (`level_select_screen.dart`, `conveyor_stage_select_screen.dart`, `code_puzzle_stage_select_screen.dart`), o botão "?" (`AppIcons.help`) ficava colado ao botão voltar — mesmo tamanho, mesma cor de fundo (`AppColors.grayButton`), só 10px de distância, no canto mais tocado do estande. Risco real de toque errado (voltar em vez de tutorial, ou vice-versa), mesmo o erro sendo leve (o "?" só abre um modal informativo, não perde progresso). Corrigido nas 3 telas: espaço dobrado (`SizedBox(width: 20)`, não 10) **e** cor de fundo diferente (`AppColors.purple`/`purpleShadow`, não `grayButton`) — voltar continua cinza, "?" agora é roxo, diferenciável à distância sem precisar ler o ícone.

**Por quê:** achado real da revisão desta mesma etapa — dois botões de ação bem diferentes (navegação vs. ajuda) não deveriam ser visualmente idênticos.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com as 182 specs continuando a passar. Se uma tela nova ganhar um par "voltar + outra ação" no cabeçalho, repetir esse padrão (espaço maior + cor distinta) em vez de dois `IconActionButton` cinza colados.

---

## 2026-09-09 — `MuteButton` removido de todo lugar (Gameplay, Vitória, Falha, Resultado) — som só via `SettingsDialog`

**Decisão:** pedido explícito do usuário — agora que existe um `SettingsDialog` central (Splash) com o toggle de som, o `MuteButton` espalhado em `GameplayHeader` (Mundo 1/2/3), `VictoryScreen`, `FailureScreen` e `CodePuzzleResultScreen` (vitória e derrota) virou redundante. Removido de todos esses lugares — junto com o `Align(topRight)`/`SafeArea` que existia só pra posicioná-lo em `VictoryScreen`/`FailureScreen`/`CodePuzzleResultScreen` (removido também, não só o botão). Como isso deixou `lib/widgets/mute_button_widget.dart` sem nenhum uso em lugar nenhum do app, o arquivo foi **excluído** (não só desconectado) — sem código morto, ver `CLAUDE.md`/"Avoid backwards-compatibility hacks... se tiver certeza que algo não é usado, pode excluir completamente".

**Por quê:** pedido explícito do usuário, depois da entrega de Configurações/Tutorial (entrada acima) já ter centralizado o controle de som.

**Como aplicar:** som agora só é ajustável pelo botão de engrenagem → `SettingsDialog` (ver entrada abaixo para onde esse botão mora hoje). Se algum mundo/tela futura precisar de um controle de som local de novo, reavaliar — não recriar `MuteButton` "por precaução"; se voltar a ser necessário, um widget novo pode reaproveitar a mesma lógica de `AppSounds.instance.muted`/`toggleMute()` que já existe. `flutter analyze` limpo; `flutter test` com as 182 specs continuando a passar (nenhum teste dependia do `MuteButton` aparecer nessas telas).

---

## 2026-09-09 — Configurações sai da Splash, mora só na Seleção de Mundo; chips de Dica (Falha/Resultado do Modo Debug) compactados

**Decisão:** 2 ajustes pedidos pelo usuário depois de testar:

1. **Botão de Configurações movido da Splash pra Seleção de Mundo** — `lib/screens/splash_screen.dart` perdeu o botão de engrenagem (e o `showDialog`/import de `SettingsDialog` junto); `lib/screens/world_select_screen.dart` ganhou um cabeçalho novo (`Row(spaceBetween)`: botão voltar à esquerda, botão de engrenagem à direita, mesmo `AppIcons.settings`/`showDialog(... SettingsDialog())` de antes). `test/screens/settings_dialog_test.dart` atualizado pra abrir a partir de `WorldSelectScreen` (2º `IconActionButton` do cabeçalho, índice 1 — o 1º é voltar) em vez de `SplashScreen`.
2. **Chips do card "DICA" (`FailureScreen`, `CodePuzzleResultScreen`) compactados** — já usavam `ProgramChipGrid` (não mais `Wrap` livre, ver entrada "Botões de comando compactados"), mas com o `crossAxisCount` padrão (4) — que já tinha sido calibrado pro contexto de "Seu Programa" (padding mais folgado). O card "DICA" tem padding próprio (`Container(padding: 16)`) somado ao da tela, deixando menos largura disponível — com 4 colunas a célula ficava só ~30px de conteúdo (descontando o padding interno de `ProgramBlockChip`), e o chip estourava (`RenderFlex overflowed by 15 pixels`, achado rodando `no_overflow_test.dart` depois de aplicar o pedido do usuário de "diminuir"). Corrigido com `crossAxisCount: 2` nos dois lugares — cabe confortavelmente mesmo com os rótulos mais longos do Mundo 2 ("Enquanto Amarelo → A").

**Por quê:** pedidos explícitos do usuário.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com as 182 specs passando. Se um card/área nova reaproveitar `ProgramChipGrid` dentro de um container com padding próprio (não a área "Seu Programa" direto), considerar `crossAxisCount: 2` (ou calcular a largura disponível de verdade) em vez de assumir o padrão 4 — o padrão 4 só é seguro em containers com padding leve.

---

## 2026-09-09 — Ícones ilustrados dos 3 mundos (gerados por IA); card da Seleção de Mundo vira lista de retângulos (imagem + "MUNDO N / NOME")

**Decisão:** o usuário pediu prompts para gerar (via ChatGPT) uma imagem ilustrada por mundo, no mesmo estilo visual do jogo (flat 2D, paleta de `AppColors`). As 3 imagens geradas foram entregues e integradas seguindo o mesmo processo da arte real do mascote (ver entrada "Mascote placeholder" acima): copiadas para `assets/images/world1_icon.png` (labirinto — Mundo 1 "Primeiros passos"), `assets/images/world2_icon.png` (esteira com os 2 bugs — Mundo 2 "Esteira de Bugs") e `assets/images/world3_icon.png` (janela de código + lupa — Mundo 3 "Modo Debug"), listadas em `pubspec.yaml` (`flutter.assets`). A correspondência arquivo→mundo foi decidida pelo **conteúdo** de cada imagem (o mapeamento não dependia da ordem em que o usuário colou os caminhos, que não batia com a ordem numérica dos mundos), não pela ordem em que os arquivos foram colados na mensagem.

Junto disso, `WorldSelectScreen` trocou a grade compacta de cards quadrados (2-3 colunas, só número + nome) por uma **lista em coluna única** (`ListView.separated`) de cards retangulares: imagem do mundo à esquerda (84×84, cantos arredondados, `BoxFit.cover`), texto único "MUNDO N / NOME" à direita (2 linhas no máximo), e um selo à direita (seta amarela = jogável, cadeado = bloqueado por progresso, "EM BREVE" = `comingSoon`). Cor de fundo do card é sempre `AppColors.panel` (não muda por estado) — o que comunica bloqueio agora é a imagem em escala de cinza (`ColorFiltered` com matriz de saturação 0, `Opacity(0.6)`) + o texto acinzentado (`grayLockIcon`), não mais o quadrado inteiro virando cinza como na grade antiga.

**Por quê:** pedido explícito do usuário, depois de já ter pedido a grade compacta antes (entrada "Tutorial vira modal ilustrado, Seleção de Mundo vira grade compacta..." acima) — ele reavaliou e preferiu voltar a cards em coluna, agora com a arte ilustrada nova em vez de só um número.

**Como aplicar:** `_worldIconAsset(int)` (privado em `world_select_screen.dart`) resolve o caminho `assets/images/world{N}_icon.png` a partir de `GameWorld.number` — ao trocar/adicionar arte de mundo, só substituir o arquivo, sem mudar código. `_WorldTile` continua privado a essa tela (usado só ali, não sobe pra `lib/widgets/` — ver `.claude/rules/design.md`). `flutter analyze` limpo; `flutter test` com 182 specs passando (`test/screens/world_select_screen_test.dart` e `test/screens/tutorial_flow_test.dart` atualizados pra tocar/checar o texto combinado `"MUNDO N / NOME"` em vez de só `world.name`).

---

## 2026-09-09 — Seleção de Mundo vira mapa em zigue-zague, nós ligados por trilha pontilhada

**Decisão:** pedido explícito do usuário — trocar a lista em coluna de cards retangulares (entrada acima) por um "mapa", no estilo comum de apps de fases (Duolingo/Candy Crush): os 3 `GameWorld` viram nós circulares posicionados em zigue-zague (`_WorldMapPath`, `lib/screens/world_select_screen.dart` — `LayoutBuilder` + `Stack`, posição horizontal de cada nó alternando `0.28`/`0.72`/`0.28` da largura disponível, `_nodeSpacing: 190` de altura por nó), conectados por uma linha pontilhada desenhada com `CustomPainter` (`_DashedPathPainter`, segmentos retos entre os centros dos nós consecutivos, cor `AppColors.grayDashedBorder` — token que já existia mas não tinha uso ainda). Cada nó (`_WorldMapNode`) é um círculo (84px, anel colorido — amarelo se jogável, cinza se bloqueado) com a imagem ilustrada do mundo (mesmos assets `world{N}_icon.png` da entrada acima, `ClipOval` em vez de `ClipRRect`) + rótulo "MUNDO N / NOME" abaixo numa pílula. Bloqueio por progresso mostra um badge de cadeado sobreposto no canto do círculo (em vez do ícone ao lado do texto que o card retangular tinha); `comingSoon` mantém o mesmo badge "EM BREVE" pequeno abaixo do rótulo. O conteúdo é centralizado com `ConstrainedBox(maxWidth: 480)` dentro de um `SingleChildScrollView` (a trilha tem altura fixa de `worlds.length * 190px`, que pode passar da altura da tela em celulares baixos — por isso a rolagem, mesmo padrão já usado em outras telas longas do app).

**Por quê:** pedido explícito do usuário, depois de já ter pedido a grade compacta e depois a lista de cards (entradas acima) — reavaliou de novo e preferiu a metáfora visual de "mapa de fases" no lugar de uma lista/grade simples.

**Como aplicar:** `_WorldMapPath._xFractions` é uma lista cíclica (`index % length`) — um Mundo 4 futuro continua o zigue-zague automaticamente sem precisar editar a lógica de posicionamento. Se o número de mundos crescer muito (mais que uns 5-6), reavaliar `_nodeSpacing`/o zigue-zague simples por algo que aproveite melhor a largura em tablet (hoje o mapa fica bem espremido ao centro mesmo em telas largas, por causa do `maxWidth: 480` — decisão deliberada para não esticar demais o zigue-zague). `flutter analyze` limpo; `flutter test` com as 182 specs continuando a passar sem nenhuma mudança nos arquivos de teste (o texto tocado/checado, `"MUNDO N / NOME"`, não mudou — só o layout ao redor dele).

---

## 2026-09-09 — Círculos do mapa bem maiores ("maximalista"), depois ajustados um pouco menor

**Decisão:** pedido explícito do usuário depois de ver o mapa em zigue-zague (entrada acima) — os círculos dos nós ficaram grandes o suficiente para dominar visualmente o mapa: `_WorldMapNode.circleSize` de `84` para `168` (2x), com anel/sombra/badge de cadeado escalados junto, e `_nodeSpacing` (altura reservada por nó em `_WorldMapPath`) de `190` para `300` para os círculos maiores não se sobreporem/ficarem espremidos. A trilha pontilhada também ficou mais grossa para acompanhar a escala nova.

**Ajuste seguinte (mesmo dia):** o usuário achou o resultado grande demais ("acho que um pouquinho menor") — recalibrado para um meio-termo: `circleSize: 168 → 132`, `_nodeSpacing: 300 → 250`, `nodeWidth: 210 → 180`, borda do anel `7 → 6`, sombra `offset 10 → 8`, badge de cadeado (`padding 8→6`, ícone `22→18`) — ainda bem maior que o card original (84px), mas sem dominar tanto a tela quanto a primeira tentativa.

**Efeito colateral (achado ao rodar os testes depois do primeiro ajuste, continua válido):** com nós grandes o bastante, a altura total do mapa passou a exceder a superfície de teste padrão usada em `test/screens/world_select_screen_test.dart` (`400×900`) — o nó do Mundo 3 (o último, mais embaixo) ficava parcialmente fora da viewport e o `tester.tap()` nele passou a falhar (`hit test` fora dos limites do `RenderView`). Corrigido chamando `tester.ensureVisible(...)` antes de cada `tap()` nesse arquivo (rola de verdade dentro do `SingleChildScrollView` da tela até o nó certo) — mais robusto que só aumentar a superfície de teste, porque o mapa já era pensado pra rolar em celulares baixos de qualquer forma (ver entrada acima, "Seleção de Mundo vira lista..."/"...vira mapa...").

**Por quê:** pedidos explícitos do usuário — primeiro "bem maior"/"maximalista", depois "um pouquinho menor" ajustando o resultado.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com as 182 specs continuando a passar nos dois ajustes. Se o tamanho dos círculos mudar de novo no futuro, reavaliar `_nodeSpacing`/`nodeWidth` (`_WorldMapPath`) proporcionalmente — `nodeWidth` (180) sempre precisa de folga sobre `circleSize` (132) pra caber o badge de cadeado sem cortar.

---

## 2026-09-09 — `TutorialModal` vira `TutorialScreen`: tela cheia paginada, conceito de programação, máquina de escrever, narração sintetizada

**Decisão:** pedido explícito do usuário, com 3 partes:

1. **Modal → tela cheia paginada.** `lib/widgets/tutorial_modal_widget.dart` (`TutorialModal`, um `Dialog` com tudo junto + botão único "Aprendi") foi **excluído** — substituído por `lib/screens/tutorial_screen.dart` (`TutorialScreen`), empurrada via `Navigator.push` como qualquer tela. Mostra um `TutorialSlide` por vez (`title: String?`, `body: String`); o texto do corpo é revelado letra a letra (`_TypewriterText`, `Timer.periodic` de 22ms/caractere) — 1º toque no botão primário ("Próximo") revela o slide inteiro na hora se ainda estiver "digitando"; só o 2º toque avança de verdade (ou termina, no último slide, onde o botão vira "Jogar"). Um botão "Pular" no topo sai do tutorial a qualquer momento sem passar pelos slides restantes. Continua não navegando/gravando `Onboarding` sozinha — quem empurra a tela decide o que `onFinish` faz, mesmo contrato de `onDone` que `TutorialModal` já tinha.

2. **Conceito de programação antes das regras do Mundo.** Novo `programmingConceptSlides` (`tutorial_content.dart`, 5 slides: "o que é programar", "Bloco", "Programa", "a ordem importa", "errar não é o fim") — mostrado **uma única vez**, antes dos slides do 1º Mundo que o jogador tocar (não repete a cada Mundo, nem ao reabrir pelo "?"). `Onboarding` (`lib/models/onboarding.dart`) ganhou `hasSeenIntro`/`markIntroSeen` (mesmo padrão de `hasSeen`/`markSeen` por mundo, sessão apenas). `tutorialSlidesFor(worldNumber, {includeIntro})` (`tutorial_content.dart`) monta a lista combinada certa: `WorldSelectScreen._enterWorld` passa `includeIntro: !Onboarding.instance.hasSeenIntro`; o botão "?" de cada Seleção de Fases sempre passa `includeIntro: false` (o jogador já viu o conceito geral se chegou até ali).

3. **Narração em áudio sintetizada.** `AppSounds` ganhou `playNarration(String assetPath)` (wrapper fino sobre `_play`, mesmo tratamento de mute/erro dos outros sons). Cada slide tem um arquivo de narração opcional (`assets/audio/tutorial/{chave}.wav`) tocado ao entrar no slide (`initState`/depois de cada avanço). Sem gravação real disponível (mesma situação do mascote/SFX antes das artes reais — ver entradas acima), os arquivos foram **sintetizados** com o motor de voz do Windows (`System.Speech`, voz "Microsoft Maria Desktop", pt-BR — confirmada instalada neste ambiente) via `tool/generate_tutorial_narration.ps1`, com o cabeçalho do `.wav` resultante reescrito para uma taxa de amostragem ~22% mais alta que a gravação real (sem tocar nos dados de áudio) — o player reproduz os mesmos samples mais rápido/agudo, dando um tom mais "infantil/robótico" à voz adulta do SAPI sem precisar de nenhuma biblioteca de DSP (não havia `ffmpeg` disponível no ambiente). O texto de cada narração precisa bater com `tutorial_content.dart` — documentado no topo dos dois arquivos; se o texto de um slide mudar, o script precisa rodar de novo pra esse slide.

**Arte nova:** `assets/images/mascot_tutorial.png` — mascote de olhos abertos (gerada por IA a partir de prompt do usuário), usada só na `TutorialScreen` (o resto do app continua usando `assets/images/mascot.png`, olhos fechados — ver entrada "Mascote placeholder" acima). Não integrada a `MascotImage`/`MascotExpression` (é uma pose semanticamente diferente — "explicando", não um resultado de partida — usar um `Image.asset` direto em `tutorial_screen.dart` evitou forçar essa pose num enum que não fazia sentido pra ela).

**Achado real corrigido durante a implementação:** o primeiro toque de "pular digitação" (`_TypewriterText.didUpdateWidget` chamando `_complete()` síncrono) quebrava com `setState() called during build` — `didUpdateWidget` roda durante o build do widget pai (`_TutorialScreenState`) quando ele reconstrói com `skip: true`, e `_complete()` chamava `widget.onComplete` (que dá `setState` no pai) nesse exato momento. Corrigido adiando `widget.onComplete()` pra `WidgetsBinding.instance.addPostFrameCallback` — resolve tanto esse caminho quanto o do `Timer` (que não tinha o bug, mas ganhou o mesmo adiamento por consistência).

**Como aplicar:** `flutter analyze` limpo; `flutter test` com **236 specs** passando — `test/screens/tutorial_flow_test.dart` reescrito do zero pro fluxo paginado (7 casos: conceito geral aparece só na 1ª vez, 1º/2º toque no botão primário, "Pular", completar todos os slides, mundo tocado depois da intro já vista, mundo já visto não mostra nada, botão "?" reabre só as regras do mundo); `test/screens/no_overflow_test.dart` ganhou uma varredura de **cada slide individual** (conceito geral + os 3 mundos, 17 slides × 3 tamanhos = 51 casos) — cada slide isolado (`slides: [slide]`) com o texto todo revelado na hora (pior caso de altura/largura), seguindo o mesmo padrão de varredura já usado pras 12 fases do Mundo 3. Ao adicionar um Mundo 4 (ou mais slides a um Mundo existente), lembrar de rodar `tool/generate_tutorial_narration.ps1` de novo pra gerar a narração das chaves novas.

---

## 2026-09-09 — PWA com marca própria (ícones/cores/nome) — `web/` deixa de ser o template genérico do Flutter

**Decisão:** o app vai rodar como PWA na feira (planos de conectar a um Firebase depois, ver entrada seguinte) — a pasta `web/` (gerada pelo `flutter create` padrão, nunca customizada) ganhou identidade: `web/manifest.json` (`name`/`short_name` → "Debuga o Mascote", `background_color` → `AppColors.background` `#393939`, `theme_color` → `AppColors.purpleDark` `#2A1650`, descrição real), `web/index.html` (`<title>`, meta description, `theme-color`, `apple-mobile-web-app-title`). Ícones (`web/favicon.png`, `web/icons/Icon-{192,512}.png`, `Icon-maskable-{192,512}.png`) gerados a partir de `assets/images/mascot.png` via um script Python one-off (`Pillow`, não comitado — mascote centralizado sobre fundo `purpleDark`, versões maskable com mais respiro pro corte circular de alguns launchers).

**Por quê:** pedido explícito do usuário — evitar a tela de instalação genérica azul do Flutter quando o PWA for instalado num celular na feira.

**Como aplicar:** se a arte do mascote mudar, os ícones precisam ser regerados manualmente (script não ficou no repositório por ser um utilitário de uma vez só — se isso mudar com frequência no futuro, vale promover pra `tool/generate_pwa_icons.py`, mesmo espírito de `tool/generate_sfx.py`).

---

## 2026-09-09 — Recapitulação de fim de Mundo + decisão de rumo do projeto (login por dispositivo, Firebase, Placar do Dia)

**Decisão (recapitulação, implementada nesta entrada):** ao terminar a última fase pendente de um Mundo — e só na primeira vez que aquele Mundo fica 100% completo —, uma tela de recapitulação (reaproveitando `TutorialScreen`, com `finalLabel` novo: "Continuar"/"Concluir" em vez de "Jogar", já que não há próxima fase pra jogar direto) aparece antes de voltar para a Seleção de Fases, ligando o que foi aprendido naquele mundo ao próximo. Conteúdo em `worldRecapSlides` (`lib/widgets/tutorial_content.dart`), narração em `assets/audio/tutorial/recap{N}_0.wav` (`tool/generate_tutorial_narration.ps1` estendido com as 3 chaves novas). Controlado por `Onboarding.hasSeenRecap(worldNumber)`/`markRecapSeen` (novo, mesmo padrão de `hasSeen`/`markSeen`) — replay da última fase de um Mundo já recapitulado não mostra de novo.

`Progress` ganhou `isWorldCompleted(Iterable<String> levelIds)` (reaproveitado por `WorldSelectScreen._isWorldUnlocked`, que antes duplicava esse `.every(...)` inline). Nos 3 `_goToResultScreen` (`gameplay_screen.dart`, `conveyor_gameplay_screen.dart`, `code_puzzle_gameplay_screen.dart`), o cálculo de "o Mundo acabou de ficar completo agora" é feito comparando `isWorldCompleted` **antes** e **depois** de `Progress.recordWin` — replay de uma fase já concluída nunca reaciona a recapitulação, só a conclusão real da última fase pendente.

**Por quê:** pedido explícito do usuário, de um brainstorm de ideias pedagógicas — ligar os 3 mundos numa progressão clara ("você aprendeu X, agora vem Y").

**Decisão de rumo do projeto (registrada aqui, implementação nas próximas entradas):** durante essa mesma conversa o usuário confirmou que o app pode deixar de ser só uma peça pontual da feira ("já mudar o mindset agora"), e detalhou o Placar do Dia: pontuação cumulativa entre fases jogadas (mundo mais difícil vale mais, resolver mais rápido rende mais pontos — **nunca mostrado como tempo/cronômetro na UI**, pra não parecer punição de quem joga mais devagar), e só aparece no placar quem responder uma pesquisa opcional (nome, idade, "já programou antes?"). Depois de uma primeira rodada de perguntas (placar 100% local + Firebase "no futuro"), o usuário revisou e pediu Firebase **já**: um "login" por dispositivo (na prática, Firebase Auth anônimo — UID estável por instalação/navegador, sem tela de login visível, jogar sem cadastro continua funcionando de boa) + Firestore guardando o placar e, quando a pessoa preencher a pesquisa, dado mínimo de dispositivo (plataforma + navegador). O usuário vai criar o projeto Firebase e rodar `flutterfire configure` (não é algo que dá pra fazer por ele — exige login na conta Google dele). Plano detalhado (arquitetura de `lib/data/`, `DeviceIdentity`, `LeaderboardRepository`/`FirebaseLeaderboardRepository`, `SurveyScreen`/`LeaderboardScreen`, persistência local de `Progress`/`Onboarding` via `shared_preferences` sem quebrar a suíte de testes síncrona, e um botão "Sou um novo jogador" necessário pro tablet compartilhado do estande) documentado em `C:\Users\XProcess\.claude\plans\jazzy-hatching-newt.md` — consultar esse arquivo antes de implementar as próximas partes.

**Como aplicar (recapitulação):** `flutter analyze` limpo; `flutter test` com **247 specs** passando — `test/screens/tutorial_flow_test.dart` ganhou 2 casos jogando a última fase de verdade (Mundo 1: derrota outras 11 fases via `Progress.recordWin` direto, joga só a 12ª pela UI); `test/screens/no_overflow_test.dart` cobre os 3 slides de recapitulação na varredura por slide que já existia.

---

## 2026-09-10 — Cadastro real (email/senha + Google): `AppAuth`, gate ao fim da Trilha 1, `signInWithProvider` em vez de `google_sign_in`

**Decisão:** implementado o cadastro/login pedido pelo usuário — nome/email/senha, com login Google — via Firebase Auth. Duas decisões técnicas concretas, uma delas simplificando bastante o plano original:

1. **Sem o pacote `google_sign_in`.** O plano original prevendo esse pacote esbarrou num achado real durante o planejamento: a partir da v7, o login Google na Web só pode ser disparado pelo botão do próprio Google (Google Identity Services), não por um botão do Design System do jogo — o usuário chegou a aceitar essa restrição explicitamente. Só que, investigando a API do `firebase_auth` (já instalado) durante a implementação, `signInWithProvider`/`linkWithProvider` (com `GoogleAuthProvider()`) se mostraram um caminho **universal** — funcionam em Web (popup do próprio Firebase JS SDK, sem precisar de nenhum botão renderizado pelo Google), Android e iOS (fluxo nativo), tudo com uma única chamada, sem branch por plataforma. Resultado: **nenhum pacote novo** (`google_sign_in` foi removido do pubspec depois de ter sido adicionado), e o botão "Continuar com Google" é o mesmo botão do Design System em qualquer plataforma — uma entrega melhor do que o combinado, sem abrir mão de nada que o usuário pediu.
2. **Cadastro/login sempre tentam linkar a conta anônima primeiro.** `lib/data/firebase_auth_service.dart` (`FirebaseAuthService implements AuthService`, `lib/data/auth_service.dart`): `registerWithEmail`/`signInWithGoogle` chamam `_ensureAnonymousUser()` (garante uma sessão anônima — `FirebaseDeviceIdentity` só cria uma quando o Placar é aberto, então um jogador que nunca abriu o Placar ainda não tem `currentUser`) e depois `current.linkWithCredential(...)`/`current.linkWithProvider(GoogleAuthProvider())` — preserva o UID que já pode ter dados no Firestore. Se o link falhar com `credential-already-in-use`/`provider-already-linked`/`email-already-in-use` (a pessoa já tem conta Google de um aparelho/sessão anterior), cai para `FirebaseAuth.instance.signInWithProvider(provider)` — um novo popup/fluxo nativo pra essa conta pré-existente, em vez de tentar extrair a credencial do erro (não confiável nas versões recentes do SDK, achado da revisão de plano). `signInWithEmail` (login numa conta já existente) não tenta linkar — é `signInWithEmailAndPassword` direto.

**`AppAuth.instance`** (`lib/data/app_auth.dart`) — singleton, mesmo padrão de `Leaderboard`/`AppSounds`: `hasAccount`/`displayName` (getters, sempre com `try/catch` retornando `false`/`null` se o Firebase não estiver disponível — nunca derruba a UI), `registerWithEmail`/`signInWithEmail`/`signInWithGoogle`, `@visibleForTesting set service`/`resetForTest()`.

**`RegisterScreen`** (`lib/screens/register_screen.dart`) — um modo `register`/`login` alternável (link "Já tem conta? Entrar"), campos via `LabeledTextField` (novo, `lib/widgets/labeled_text_field_widget.dart`, extraído da decoração que já existia em `SurveyScreen` — 2º uso, subiu pra `lib/widgets/`). Botão primário "Criar conta"/"Entrar" (`PrimaryPillButton`), separador "ou", botão secundário "Continuar com Google" (`HardShadowBox`, mesmo padrão visual de outros botões do jogo, sem nenhum ícone de marca — não valia inventar um logo do Google). `mandatory: true` (gate) tira o botão de fechar (`PopScope(canPop: false)`); `mandatory: false` (Configurações) tem um `IconActionButton` de voltar normal.

**Nota de resiliência (achado da revisão de plano, evita um soft-lock real):** `.claude/memory/decisions.md` já documentava o princípio "se o Firebase não estiver disponível, o jogo continua 100% jogável" pro Placar. Um gate obrigatório sem nenhuma saída contradiria isso na prática (internet caindo no estande = jogador preso numa tela tentando falar com um backend fora do ar). Por isso `RegisterScreen`, mesmo em modo `mandatory`, sempre tem um link discreto no rodapé — "Continuar sem conta por enquanto" — que chama `onDone()` sem exigir sucesso de nada. Enfraquece um pouco a palavra "obrigatório" (na prática é "fortemente pedido, sempre com uma saída de emergência"), decisão deliberada pra nunca travar o app físico do estande.

**Gate em si**: os 3 Gameplay screens (`gameplay_screen.dart`, `conveyor_gameplay_screen.dart`, `code_puzzle_gameplay_screen.dart`) ganharam um método `_returnToLevelSelect(BuildContext, bool worldJustCompleted)`, chamado nos 2 lugares que antes faziam `popUntil` direto (com/sem Recapitulação) — se `worldJustCompleted && _level.world == tracks.first.worlds.last.number && !AppAuth.instance.hasAccount`, empurra `RegisterScreen(mandatory: true)` antes do `popUntil`. Como `tracks.first.worlds.last` é hoje o Mundo 3, só `code_puzzle_gameplay_screen.dart` realmente dispara isso na prática hoje — replicado nos 3 pra continuar correto se a ordem/composição da Trilha 1 mudar no futuro.

**Cadastro voluntário**: `SettingsDialog` (`lib/widgets/settings_dialog_widget.dart`) ganhou uma seção "Conta" — sem conta, um link "Criar conta" abre `RegisterScreen(mandatory: false, ...)`; com conta, mostra "Conectado como `<nome ou e-mail>`".

**Atualização (mesmo dia) — Google habilitado, iOS deixou de estar fora de escopo:** o usuário habilitou "Google" como provedor em Firebase Console → Authentication → Sign-in method e baixou `google-services.json`/`GoogleService-Info.plist` manualmente. Reaproveitei rodando `flutterfire configure` de novo (mais confiável que copiar à mão — já mantém `lib/firebase_options.dart` em sincronia) para o Android, e copiei o `GoogleService-Info.plist` do usuário pra `ios/Runner/GoogleService-Info.plist` (esse arquivo o `flutterfire configure` não gera sozinho neste ambiente Windows sem Xcode). `android/app/google-services.json` agora tem `oauth_client` de verdade (antes vazio). `ios/Runner/Info.plist` ganhou `CFBundleURLTypes` com o `REVERSED_CLIENT_ID` do plist (`com.googleusercontent.apps.823859588989-id8d3221aim3gaq2mijikmvriisisi49`) — exigido pelo login Google no iOS.

**SHA-1/SHA-256 do Android** já registrados nesta sessão via `firebase apps:android:sha:create` (CLI, sem precisar do usuário) — fingerprints do keystore de debug (`keytool -list -v -keystore ~/.android/debug.keystore`). Se o app for assinado com outro keystore (release), esse fingerprint novo também precisa ser registrado do mesmo jeito.

**Único passo de iOS que ainda falta, e só dá pra fazer num Mac com Xcode**: `ios/Runner/GoogleService-Info.plist` existe no disco, mas não está registrado no projeto Xcode (`project.pbxproj`) — sem isso, o Xcode não inclui o arquivo no bundle final do app. Ao abrir `ios/Runner.xcworkspace` no Xcode pela 1ª vez (num Mac), arrastar `GoogleService-Info.plist` pro target "Runner" (marcando "Copy items if needed" e o target Runner) resolve — passo padrão de qualquer app FlutterFire no iOS, não específico deste projeto. Sem esse passo, o app iOS continua funcionando (email/senha inclusive), só o login Google no iOS não.

**Por quê:** pedido explícito do usuário — cadastro obrigatório só ao terminar a Trilha 1, mas opcional antes; Google Sign-In implementado junto com email/senha, não depois.

**Como aplicar:** `flutter analyze` limpo; suíte inteira passando (288 specs) — novo `test/helpers/fake_auth_service.dart` (mesmo padrão de `fake_leaderboard_repository.dart`), `test/screens/register_screen_test.dart` (formulário, alternância, erro inline, Google, mandatory vs voluntário), `test/screens/register_gate_test.dart` (joga de verdade até a última fase do Mundo 3 — com/sem conta), `settings_dialog_test.dart`/`no_overflow_test.dart` atualizados. Quando o Firebase entrar em algum fluxo novo que precise saber "tem conta", usar `AppAuth.instance.hasAccount`/`displayName` — nunca acessar `FirebaseAuth.instance` direto fora de `lib/data/`.

---

## 2026-09-10 — UI da Seleção de Mundo (topo + card de Trilha) melhorada — UI Engineer + UX Reviewer

**Decisão:** pedido explícito do usuário pra melhorar a UI de 3 partes de `WorldSelectScreen` que estavam visualmente planas — delegado ao agente **UI Engineer**, depois revisado pelo **UX Reviewer** (fluxo padrão do projeto, `.claude/docs/AGENTS_WORKFLOW.md`), com 2 achados reais corrigidos na sequência.

**Implementado pelo UI Engineer** (só `lib/screens/world_select_screen.dart`, nenhum widget/token novo):
1. **Cabeçalho**: botão "Voltar" continua cinza neutro; os botões de Troféu (Placar) e Configurações passaram de `grayButton` pra `AppColors.purple`/`purpleShadow` (mesmo par já usado no botão "?" de tutorial noutras telas) — agrupa visualmente as 2 ações utilitárias, diferenciando do botão de navegação.
2. **Eyebrow + título**: selo circular decorativo (`HardShadowBox`, ícone de estrela) ao lado de "DEBUGA O MASCOTE"/"Escolha o mundo", que antes era só texto empilhado.
3. **Card de Trilha** (`_buildTrackSection`): trocou de `Container` com borda simples pra `HardShadowBox` (sombra dura) + selo numerado circular + `GameTrack.subtitle` exibido (campo que já existia no modelo, nunca tinha aparecido em lugar nenhum) — dá ao card peso de "seção".

**2 achados reais do UX Reviewer, corrigidos na hora:**
1. **Card de Trilha jogável parecia tocável, mas não tinha `onTap`/feedback nenhum** — a versão `comingSoon` do mesmo card tem `GestureDetector` + `SnackBar` explicando "em breve"; a versão jogável (sem `comingSoon`) não tinha nada, mas visualmente ficou com a MESMA linguagem de "isto é tocável" (`HardShadowBox` + borda `yellowNeon` + selo amarelo) usada nos elementos realmente tocáveis da tela (`IconActionButton`, `ZigzagMapNode`) — inconsistência real entre os 2 estados do mesmo componente, e `yellowNeon` é a cor que a própria tela usa pra dizer "toque aqui" (nós do mapa logo abaixo). Corrigido trocando `yellowNeon`/`purpleDark` por `purple`/`white` (borda + selo numerado) no card jogável — mesma cor de marca dos botões utilitários do cabeçalho, sem reaproveitar a cor reservada pra "isto é tocável".
2. **Selo decorativo do topo (eyebrow+título) também reaproveitava `yellowNeon`** — mesmo problema: círculo amarelo-neon com sombra dura, idêntico em cor/forma/sombra aos nós tocáveis do mapa, mas sem nenhuma ação. Corrigido trocando pra `purple`/`purpleShadow` (mesmo par já usado nos botões do cabeçalho e agora no card de Trilha).

Contraste do `subtitle` da trilha (branco 65% de opacidade sobre `panel`) e área de toque dos botões recoloridos foram checados pelo UX Reviewer e confirmados OK (≈6.9:1 e ≈5.2-5.8:1, acima do mínimo AA de 4.5:1 — `.claude/rules/design.md`).

**Por quê:** pedido explícito do usuário pra melhorar a UI; os 2 achados de affordance (elementos parecendo tocáveis sem ser) são exatamente o tipo de problema que o UX Reviewer existe pra pegar antes de considerar pronto.

**Como aplicar:** `flutter analyze` limpo; suíte inteira (283 specs) passando sem precisar atualizar nenhum teste — o texto/formato que os testes procuram (`'TRILHA N - NOME'`, `'EM BREVE'`, ordem dos `IconActionButton`) não mudou, só cor/sombra. Depois disso, ajuste adicional a pedido do usuário: espaço entre o título "Escolha o mundo" e o card da 1ª Trilha aumentado de 8 pra 24px (mais respiro).

---

## 2026-09-10 — Placar do Dia exige conta; nome não é mais digitado, vem do login

**Decisão:** pedido explícito do usuário — pra aparecer no Placar do Dia, o jogador precisa estar **logado** (não mais "qualquer um digita um nome"). `SurveyScreen` perdeu o campo "Seu nome" — agora só pergunta idade e "já programou antes?" (2 perguntas, não 3), e usa `AppAuth.instance.displayName` (nome de cadastro ou e-mail, se não tiver nome) como `LeaderboardEntry.name`. Um texto novo na tela confirma pra que nome vai enviar ("...você vai aparecer no Placar de hoje como 'Fulano'"), já que o jogador não digita mais esse dado — precisa saber o que vai aparecer.

**Gate de login no convite do Placar** (`LeaderboardScreen._JoinCard`): antes ia direto pra `SurveyScreen`; agora checa `AppAuth.instance.hasAccount` primeiro —
- **Com conta**: abre `SurveyScreen` direto, botão "Aparecer no Placar".
- **Sem conta**: abre `RegisterScreen(mandatory: false, onDone: () { fecha o cadastro; abre a SurveyScreen })` — mesmo padrão de cadastro voluntário já usado em `SettingsDialog`. Botão muda pra "Entrar e aparecer no Placar", e o texto do card explica ("Entre com sua conta pra aparecer no Placar com seu nome.").

**Por quê:** pedido explícito do usuário — vincular a entrada do Placar à identidade real da conta (email/senha ou Google) em vez de um nome digitado à mão, que qualquer um podia inventar/repetir.

**Como aplicar:** `flutter analyze` limpo; suíte inteira passando (`test/screens/leaderboard_flow_test.dart` reescrito — cobre os 2 caminhos do convite, com e sem conta, incluindo o login completo via Google fake até cair na Pesquisa). `SurveyScreen` não valida mais nome nenhum — se algum dia essa tela puder ser aberta sem conta (não deveria, hoje só chega lá vindo do gate), `AppAuth.instance.displayName` cai pro fallback `'Jogador'` em vez de quebrar.

---

## 2026-09-10 — `dependency_overrides: firebase_core_web: 3.10.0` — trava temporária por bug real do pacote

**Decisão:** `flutter run -d chrome`/`flutter build web` pararam de compilar com `Error: The method 'isA' isn't defined for the type 'Object'` dentro de `firebase_core_web-3.11.0/lib/src/firebase_core_web.dart` (`e.isA<JSObject>()` num `catch (e)`). Confirmado via pesquisa (issue [flutterfire#18611](https://github.com/firebase/flutterfire/issues/18611), PR [flutterfire#18612](https://github.com/firebase/flutterfire/pull/18612)): `Object.isA<T>()` só existe a partir do **Dart 3.12** — este projeto usa Dart 3.11.3 (o que `flutter --version` mostra neste ambiente). É um **bug real do `firebase_core_web` 3.11.0** (lançado 2026-08-24), já corrigido no repositório do Flutterfire (merge em 2026-08-26), mas **sem nenhum release novo publicado no pub.dev ainda** nesta data (confirmado direto na API do pub.dev). `pubspec.yaml` ganhou:
```yaml
dependency_overrides:
  firebase_core_web: 3.10.0
```
Trava a versão anterior (sem o bug) até sair um patch novo — `firebase_core: ^4.14.0` continua pedindo `firebase_core_web: ^3.11.0`, então o override é deliberadamente "abaixo" da faixa declarada (aceitável aqui: a mudança entre 3.10.0→3.11.0 foi só esse trecho de tratamento de erro, não API pública nova que o `firebase_core` 4.14.0 dependesse).

**Por quê:** bloqueava `flutter run -d chrome`/`flutter build web` por completo — Web é a plataforma principal do projeto pra feira.

**Como aplicar:** `flutter pub get` limpo (mostra `firebase_core_web 3.10.0 (overridden)`); `flutter build web` compila sem erro; `flutter analyze`/`flutter test` continuam limpos (o bug era só de compilação web, não afetava `flutter test`, que roda em VM). **Remover este `dependency_overrides`** assim que uma versão nova de `firebase_core_web` (>3.11.0) for publicada com o fix — testar `flutter pub upgrade firebase_core_web` (ou só apagar o override e rodar `flutter pub get`) de vez em quando pra ver se já dá pra tirar.

---

## 2026-09-10 — Perfil + progresso do jogador sincronizados com o Firestore (`ProgressSync`)

**Decisão:** todo jogador — anônimo ou cadastrado — agora tem um documento `players/{uid}` no Firestore com identidade básica (`uid`, `isAnonymous`, `email`, `displayName`, `platform`, `createdAt`, `lastSeenAt`) **e** o progresso do jogo (estrelas/blocos por fase, pontuação de sessão, se já enviou pro Placar). Antes só existia um documento `players/{uid}` quando o jogador respondia a Pesquisa (nome/idade/"já programou"); agora ele existe desde a 1ª vez que o app abre (mesmo sem o jogador tocar em nada), e os dois conjuntos de campos coexistem no mesmo documento via `SetOptions(merge: true)`.

**Nova classe `lib/data/progress_sync.dart` (`ProgressSync.instance`)** — mesma família de `Leaderboard`/`AppAuth`, mas sem abstração de repositório (não há fake local pra progresso, diferente do Placar): fala direto com `FirebaseAuth`/`FirebaseFirestore`, sempre com `try/catch` silencioso (nunca lança nem trava a UI) e um `if (!_firebaseAvailable) return;` de guarda no início de cada método (`Firebase.apps.isNotEmpty`, mesmo padrão de `Leaderboard._defaultRepository`). Dois métodos:
- **`hydrate()`** — chamado 1x no boot (`main.dart`, fire-and-forget logo após `Firebase.initializeApp`, **sem** `await` pra não atrasar o primeiro frame) e de novo depois de qualquer login bem-sucedido (`RegisterScreen._runAuthAction`, esse sim com `await` antes de `onDone()`). Garante uma identidade (`FirebaseDeviceIdentity`, login anônimo se preciso), lê `players/{uid}`, e se existir, chama `Progress.instance.restore(...)` (novo método em `lib/models/progress.dart`) pra repor o estado local. Sempre termina gravando a presença desta sessão (plataforma/último acesso), mesmo que o documento não existisse ainda ou o jogador não jogue nada.
- **`syncNow()`** — fire-and-forget, chamado depois de qualquer mutação real em `Progress.instance`: `recordWin`/`addSessionPoints` (nos 3 Gameplay screens, logo após o bloco de vitória) e `markSubmittedToLeaderboard` (`SurveyScreen`).

**`Progress` ganhou 2 membros novos, ainda 100% Dart puro** (sem Firebase/Flutter, ver `.claude/rules/architecture.md` — toda a integração mora em `ProgressSync`, não no model): `byLevelId` (getter somente-leitura, `Map.unmodifiable`) pra serializar, e `restore({byLevelId, sessionScore, hasSubmittedToLeaderboard})` pra repor tudo de uma vez (substitui, não soma — comportamento certo tanto no boot quanto num "trocou de conta" via login).

**UID preservado ao cadastrar — sem migração especial**: como `FirebaseAuthService` sempre linka a conta anônima primeiro (ver entrada "Cadastro real" acima), o progresso de um jogador anônimo continua no mesmo `players/{uid}` depois que ele cria conta — o documento só ganha `email`/`displayName`/`isAnonymous: false` a mais. Só no caso raro de logar numa conta **pré-existente de outro aparelho** (fallback `credential-already-in-use` → `signInWithProvider`) é que o UID muda de verdade — por isso `RegisterScreen` chama `hydrate()` de novo depois de qualquer login, pra carregar o progresso certo daquele UID (mesmo que isso troque o que estava em memória nesta sessão).

**Regra do Firestore ajustada**: `players/{uid}` tinha `allow read: if false` (só a Pesquisa escrevia, ninguém lia de volta). Agora é `allow read, write: if request.auth != null && request.auth.uid == uid` — o próprio dono pode ler seu documento (`hydrate()` depende disso), mas ninguém mais lê o documento de outro jogador (idade/"já programou" continuam privados). Publicado via `firebase deploy --only firestore:rules`.

**Por quê:** pedido explícito do usuário — salvar no Firebase as informações por usuário (anônimo ou cadastrado), incluindo o progresso do jogo, não só o que a Pesquisa já cobria.

**Como aplicar:** `flutter analyze` limpo; suíte inteira passando (`test/models/progress_test.dart` novo, cobrindo `byLevelId`/`restore`; nenhum teste de tela precisou de fake novo — `ProgressSync` já verificado como no-op seguro em ambiente de teste, mesmo `Firebase.apps.isNotEmpty` de `Leaderboard`). `ProgressSync` não tem fake/abstração de repositório como `Leaderboard` — se um teste algum dia precisar verificar uma chamada de sync específica, considerar extrair uma interface então; hoje nenhum teste depende disso. Onboarding (`hasSeen`/`hasSeenIntro`/recap) **não** foi incluído nessa sincronização — continua só de sessão, decisão deliberada pra manter o escopo desta rodada em "perfil + progresso do jogo" como pedido.

---

## 2026-09-10 — Trilhas estilo Duolingo: `GameTrack`/`tracks`, seção de Trilha dentro da própria `WorldSelectScreen`

**Decisão:** introduzido um nível de agrupamento acima de Mundo — `GameTrack` (`lib/models/game_track.dart`: `number`, `name`, `subtitle`, `comingSoon`, `worlds: List<GameWorld>`) e a lista `tracks`. **Escopo deliberadamente pequeno, pedido explícito do usuário ("só reestruturar por enquanto")**: a Trilha 1 ("Fundamentos") reaproveita os 3 mundos já existentes sem nenhuma mudança de conteúdo (`worlds: worlds`, a mesma lista global de sempre); a Trilha 2 entra como `comingSoon: true, worlds: const []` — mesmo padrão que `GameWorld.comingSoon` já usava. `isTrackCompleted(GameTrack)` (também em `game_track.dart`) checa se todos os mundos da trilha estão 100% completos (`Progress.instance.isWorldCompleted` por mundo) — usado pelo gate de cadastro (ver entrada "Cadastro real" abaixo).

**Correção de rumo no mesmo dia**: a 1ª versão desta feature criou uma tela própria (`TrackSelectScreen`) entre a Splash e `WorldSelectScreen`, com `WorldSelectScreen` recebendo `required GameTrack track`. O usuário testou e pediu explicitamente pra **não ser uma tela própria** — trilha devia aparecer como uma seção dentro da própria tela de mundos: um card "TRILHA N - NOME" e, logo abaixo dele, o mapa dos mundos daquela trilha; a Trilha 2 (sem mundos ainda) só como um card "EM BREVE". Reestruturado assim: `TrackSelectScreen` foi **excluída** (sem uso nenhum sobrando); `WorldSelectScreen` voltou a ser a tela raiz (`const WorldSelectScreen()`, sem parâmetro), e seu `build()` itera `tracks`, montando por trilha um `Container` (card) + (`if (!track.comingSoon)`) um `ZigzagMap` dos `track.worlds` logo abaixo — tudo dentro do mesmo `SingleChildScrollView`. O conceito geral de programação (`programmingConceptSlides`) voltou a ser disparado do jeito que já funcionava antes desta feature (1ª vez que qualquer mundo é tocado, `WorldSelectScreen._enterWorld`, `!Onboarding.instance.hasSeenIntro` combinado com `worldTutorials[world.number]` via `tutorialSlidesFor(worldNumber, {required includeIntro})`) — não há mais um gatilho "de trilha" separado, já que não existe mais uma tela/toque de "entrar na trilha".

**`ZigzagMap` continua extraído** em `lib/widgets/zigzag_map_widget.dart` (as antigas `_WorldMapPath`/`_WorldMapNode`/`_DashedPathPainter`, privadas a `world_select_screen.dart`, viraram um widget genérico — rótulo/ícone/bloqueado/`comingSoon`/tocável já resolvidos por quem chama, sem conhecer `GameWorld`/`GameTrack`) — mesmo sem uma 2ª tela consumidora agora, vale como widget correto (`WorldSelectScreen` instancia um `ZigzagMap` por trilha jogável).

**Sem arte nova de trilha nesta rodada** — o card de trilha é só texto (sem ícone/imagem própria), diferente dos nós de mundo que já tinham `assets/images/world{N}_icon.png`.

**Por quê:** pedido explícito do usuário, depois de ver a 1ª versão (tela própria de trilhas) rodando — trilha é uma seção visual dentro da tela de mundos, não uma etapa de navegação a mais.

**Como aplicar:** `flutter analyze` limpo; suíte inteira passando — `test/screens/tutorial_flow_test.dart` voltou a testar o fluxo combinado (como era antes desta feature); `test/screens/track_select_screen_test.dart` excluído; `WorldSelectScreen()` (sem parâmetro) em todos os testes que a instanciam; `world_select_screen_test.dart` atualizado pra esperar exatamente 1 badge "EM BREVE" na tela (o card da Trilha 2), não zero. Quando a Trilha 2 ganhar mundos de verdade: (1) trocar `comingSoon: true, worlds: const []` por mundos reais em `tracks[1]`; (2) se fizer sentido reexplicar algum conceito novo específico daquela trilha, decidir então como encaixar isso no fluxo de tutorial (hoje só existe 1 intro geral, compartilhada por todos os mundos/trilhas).

---

## 2026-09-10 — Narração do tutorial: voz neural via `edge-tts` (Python), não mais SAPI+pitch nem WinRT/OneCore

**Decisão:** `tool/generate_tutorial_narration.ps1` (SAPI/`System.Speech`, voz "Microsoft Maria Desktop" + hack de pitch +22% pra soar mais infantil/robótica) foi **substituído** por `tool/generate_tutorial_narration.py`, que gera os mesmos 20 arquivos de narração via `edge-tts` (biblioteca Python, voz neural `pt-BR-FranciscaNeural` — mesmo motor de TTS neural usado pelas vozes "Online (Natural)" do Windows 11/Microsoft Edge). Saída passou de `.wav` para `.mp3` (formato nativo do serviço) — `lib/widgets/tutorial_content.dart` (`_introNarrationAsset`/`_worldNarrationAsset`/`_recapNarrationAsset`) e o comentário de `AppSounds.playNarration` foram atualizados para `.mp3`; `audioplayers` toca os dois formatos sem diferença de código. Sem hack de pitch/velocidade — a voz neural já soa natural no rate padrão.

**Caminho tentado antes e descartado (registrado para não repetir a mesma investigação):** a 1ª tentativa foi trocar só o motor de síntese, mantendo tudo em PowerShell, usando a API WinRT (`Windows.Media.SpeechSynthesis.SpeechSynthesizer`) para acessar a voz OneCore "Microsoft Maria" (mais natural que a "Desktop" do SAPI, só que registrada numa hive de registro diferente — `Speech_OneCore`, não `Speech` — que `System.Speech` não enxerga). Essa via **funcionou de forma isolada** (um `SpeechSynthesizer` novo, sintetizando 1-3 frases numa sessão interativa, sempre produzia áudio válido), mas **falhou de forma intermitente dentro do script completo real** (`New-Object Windows.Media.SpeechSynthesis.SpeechSynthesizer` ocasionalmente retornava `$null` sem lançar exceção, gerando `.wav` de 0 bytes silenciosamente ou erros de "método em valor nulo" em cascata) — sintoma clássico de ativação COM/WinRT instável a partir do PowerShell (`AllVoices` também nunca enumerou corretamente nesse ambiente, sempre `Count: 0`, mesmo com vozes instaladas de verdade). Depois de confirmar essa flakiness de forma reproduzível (mesma máquina, mesmo script, resultados diferentes em execuções consecutivas), a via foi abandonada em favor do `edge-tts` — mesmo padrão de ferramenta em Python já usado no projeto (`tool/generate_sfx.py`), sem nenhuma dependência de COM/WinRT, só precisa de internet no momento de gerar (não em runtime do app).

**Por quê:** pedido explícito do usuário ("voz mais humana"); a via Python é estritamente mais confiável que WinRT/PowerShell pra este caso de uso, e o resultado (voz neural) é pelo menos tão natural quanto a OneCore que se tentou originalmente.

**Como aplicar:** rodar `pip install edge-tts` (uma vez) + `python tool/generate_tutorial_narration.py` sempre que o texto de um slide mudar em `tutorial_content.dart` — mesmo fluxo de antes, só o comando muda. Se um Mundo/Trilha futuro precisar de narração nova, adicionar a chave em `SLIDES` (`generate_tutorial_narration.py`) e rodar de novo — não precisa tocar em `AppSounds`/`tutorial_content.dart` além de referenciar o novo `.mp3`.

---

## 2026-09-10 — Pontuação por fase reduzida (1000→300)

**Decisão:** os valores de `computeScore` (`lib/game/scoring.dart`, Mundos 1/2) e `computeCodePuzzleScore` (`lib/game/code_puzzle_scoring.dart`, Mundo 3) foram reduzidos, mantendo os mesmos limiares de estrela: base 1000→300, penalidade -150→-50 por bloco extra (Mundos 1/2) e -300→-100 por tentativa extra (Mundo 3), piso 100→50. `leaderboard_scoring.dart` (pontuação de sessão do Placar do Dia — base 300/500/800 por mundo + bônus de rapidez) não muda, é uma fórmula independente.

**Por quê:** pedido explícito do usuário — os números de "PONTOS" na tela de Vitória/Resultado (até 1000) foram vistos como grandes demais pra um mini-jogo de estande.

**Como aplicar:** `test/game/scoring_test.dart`/`test/game/code_puzzle_checker_test.dart` atualizados com os números novos; `.claude/docs/GAME_DESIGN.md` (seções "Pontuação e estrelas" dos Mundos 1/2 e 3) documentado antes/junto do código, seguindo a disciplina já usada pra `computeScore`/"Enquanto"/etc.

---

## 2026-09-10 — Firebase ligado: `FirebaseDeviceIdentity`/`FirebaseLeaderboardRepository`, `Leaderboard` escolhe Firebase quando disponível

**Decisão:** implementada a Parte 4 do plano (`C:\Users\XProcess\.claude\plans\jazzy-hatching-newt.md`) que dependia do usuário criar o projeto Firebase e rodar `flutterfire configure` — feito nesta entrada (`flutterfire configure -p debugaomascote --platforms=web,android,ios -y`, conta `ladiesiincode@gmail.com`, projeto `debugaomascote`). Gerados `lib/firebase_options.dart` (valores reais, não mais hipotéticos) e `android/app/google-services.json` (`applicationId`/`package_name` já batiam: `com.example.debuga_o_mascote`; iOS `PRODUCT_BUNDLE_IDENTIFIER` também já batia: `com.example.debugaOMascote` — nenhum ajuste de identificador necessário).

- **`pubspec.yaml`**: `firebase_core: ^4.14.0`, `firebase_auth: ^6.6.1`, `cloud_firestore: ^6.9.0` (via `flutter pub add`, versões resolvidas automaticamente para o SDK do projeto).
- **`lib/main.dart`**: `main()` virou `async`, com `WidgetsFlutterBinding.ensureInitialized()` + `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` dentro de um `try/catch` silencioso — mesma filosofia de `AppSounds`/plano original: sem projeto configurado para a plataforma ou sem internet no boot, o jogo continua 100% jogável, só o Placar via Firebase fica indisponível.
- **`lib/data/device_identity.dart`** (abstração, `Future<String?> currentUserId()`) + **`lib/data/firebase_device_identity.dart`** (`FirebaseDeviceIdentity`, implementação real: `FirebaseAuth.instance.signInAnonymously()`, UID cacheado em memória após a 1ª resolução — nenhuma tela de login, exatamente como desenhado no plano).
- **`lib/data/firebase_leaderboard_repository.dart`** (`FirebaseLeaderboardRepository implements LeaderboardRepository`): `players/{uid}` (perfil da pesquisa, só o dono escreve) + `scores` (um documento por envio — histórico completo, não só o mais recente por jogador, pra reconstruir o ranking do dia). `topToday` filtra por `submittedAt >= início do dia` (Firestore exige `orderBy` no mesmo campo do filtro de desigualdade) e ordena por pontos no cliente depois (poucos documentos por dia, custo desprezível). Todo o repositório engole exceções (`try/catch` retornando `[]`/silenciando `submit`) — mesma regra de nunca deixar infraestrutura derrubar o jogo.
- **`lib/data/leaderboard.dart`**: `Leaderboard._defaultRepository()` agora escolhe `FirebaseLeaderboardRepository` quando `Firebase.apps.isNotEmpty` (inicialização bem-sucedida em `main.dart`), senão cai para `LocalLeaderboardRepository` (mesmo de antes) — nenhuma tela mudou, exatamente a promessa da entrada anterior ("Quando o Firebase entrar, só `FirebaseLeaderboardRepository`/`lib/data/leaderboard.dart` mudam").
- **`firestore.rules`** (novo, na raiz) + **`.firebaserc`** (`{"projects": {"default": "debugaomascote"}}`) + `firebase.json` ganhou a chave `"firestore": {"rules": "firestore.rules"}` ao lado da chave `"flutter"` que o `flutterfire configure` já tinha criado (chaves top-level distintas, mesmo arquivo). Regras: `players/{uid}` sem leitura nenhuma (idade/"já programou antes" nunca saem pro cliente, só o organizador olha via console — mesma decisão de design do Placar já registrada), escrita só pelo próprio dono; `scores/{scoreId}` leitura pública (é o ranking), criação só pelo próprio dono (`request.resource.data.uid == request.auth.uid`), sem update/delete (histórico imutável).

**Pendência que só o usuário pode resolver (2 passos no console, confirmado por checagem via `firebase firestore:databases:list`/`firebase auth:export` nesta sessão — ambos retornaram "não habilitado" para o projeto `debugaomascote`):**
1. **Ativar o provedor Anônimo** em Firebase Console → Authentication → Sign-in method → Anonymous → Enable.
2. **Criar o banco Firestore** em Firebase Console → Firestore Database → Create database (modo produção, qualquer região — `nam5`/`southamerica-east1` são razoáveis). Depois de criado, publicar `firestore.rules` com `firebase deploy --only firestore:rules --project debugaomascote` (não rodado ainda nesta sessão — sem banco criado, o deploy falha).

Sem esses 2 passos, `FirebaseDeviceIdentity.currentUserId()`/`FirebaseLeaderboardRepository` engolem o erro e devolvem `null`/`[]` silenciosamente — o app continua funcionando, só o Placar fica vazio/a pesquisa não salva, até o usuário terminar a configuração no console.

**Por quê:** pedido explícito do usuário, retomando a Parte 4 do plano que ficara pendente de `flutterfire configure`.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com as 263 specs continuando a passar (nenhum teste chama `Leaderboard.instance` sem antes injetar um fake `repository`, então `_defaultRepository()`/`Firebase.apps` nunca são exercitados na suíte). Depois que o usuário completar os 2 passos do console, rodar `firebase deploy --only firestore:rules --project debugaomascote` e testar de ponta a ponta: preencher a Pesquisa, ver a entrada aparecer em `scores` no console do Firestore, reabrir o app noutro aparelho/navegador e confirmar que o Placar mostra a mesma entrada.

---

## 2026-09-09 — Placar do Dia: pontuação de sessão, `lib/data/` local (Firebase depois), Pesquisa e tela de ranking

**Decisão:** implementadas as Partes 3 e 4 do plano (`C:\Users\XProcess\.claude\plans\jazzy-hatching-newt.md`), com **armazenamento local** por enquanto — o Firebase (login anônimo por dispositivo, Firestore) fica pra quando o usuário criar o projeto e rodar `flutterfire configure` (entrada anterior). A abstração já nasce pronta pra essa troca.

1. **Pontuação de sessão** — regra documentada em `.claude/docs/GAME_DESIGN.md` ("Placar do Dia — pontuação de sessão") **antes** do código, seguindo a convenção do projeto. `lib/game/leaderboard_scoring.dart` (`computeSessionPoints`): `basePorMundo[world] + max(0, 200 - segundosGastos)`, mundo mais difícil vale mais base, resolver rápido rende até 200 de bônus — **nunca exibido como tempo na UI**, só como o número final de pontos (pedido explícito do usuário, evitar sensação de punição). Cada Gameplay (`GameplayScreen`/`ConveyorGameplayScreen`/`CodePuzzleGameplayScreen`) ganhou um `Stopwatch` (`_levelStopwatch`, campo `final ... = Stopwatch()..start()`, nunca reiniciado entre tentativas) e soma pontos à sessão (`Progress.addSessionPoints`) só quando a fase é vencida **pela primeira vez** (`!Progress.isCompleted(id)` checado antes de `recordWin` — replay não farma pontos).
2. **`lib/data/` — nova camada de infraestrutura**, mesmo papel de `lib/audio/` (`.claude/rules/architecture.md` atualizado com a linha nova). `LeaderboardRepository` (abstrato: `topToday`/`submit`) + `LocalLeaderboardRepository` (implementação real de hoje, lista JSON em `shared_preferences` — pacote novo, ver abaixo) + `Leaderboard` (singleton `Leaderboard.instance`, mesmo padrão de `AppSounds.instance`: resolve a implementação real só na 1ª chamada, `@visibleForTesting set repository`/`resetForTest`). `lib/models/leaderboard_entry.dart` (`LeaderboardEntry`: nome, idade, "já programou", pontos, data — Dart puro, `toJson`/`fromJson`).
3. **Pacote novo: `shared_preferences`** — primeira persistência real do projeto (a decisão de 2026-09-04 "Persistência de progresso: a definir" continua em aberto pra `Progress`/`Onboarding` em si, que seguem só em memória; o Placar é o primeiro dado que sobrevive a fechar o app).
4. **`SurveyScreen`** (`lib/screens/survey_screen.dart`) — formulário simples (não paginado como o Tutorial, só 3 campos): Nome (`TextField`), Idade (`TextField` numérico), "Você já programou antes?" (2 pills Sim/Não, `_YesNoOption` privado). Botão "Ver meu Placar" só habilita com os 3 campos preenchidos; ao confirmar, monta um `LeaderboardEntry` com `Progress.instance.sessionScore`, chama `Leaderboard.instance.submit`, marca `Progress.markSubmittedToLeaderboard()` e navega (`pushReplacement`) pro `LeaderboardScreen`. Primeiro uso de `TextField` no projeto — decoração local (`_fieldDecoration`, fundo `panel`, borda `yellowNeon` no foco), sem promover pra um widget de tema compartilhado ainda (só usado nesta tela).
5. **`LeaderboardScreen`** (`lib/screens/leaderboard_screen.dart`) — lista as entradas de hoje (`Leaderboard.instance.topToday()`, `FutureBuilder`), ordenadas da maior pontuação pra menor, mostrando só **Nome + Pontos** (idade/resposta da pesquisa ficam guardadas no registro mas não aparecem publicamente — criança com idade exposta numa tela pública não é uma boa prática). Ver o ranking é sempre público; se `Progress.instance.sessionScore > 0` e o jogador ainda não enviou nesta sessão (`!hasSubmittedToLeaderboard`), um card "Você fez N pontos! Quer aparecer no Placar?" leva pra `SurveyScreen`. Aberta por um ícone de troféu novo (`AppIcons.trophy`) no cabeçalho da Seleção de Mundo, entre o botão voltar e o de configurações.
6. **`Progress` ganhou 3 campos de sessão** (não persistidos ainda, junto do resto de `Progress`): `sessionScore`/`addSessionPoints`, `hasSubmittedToLeaderboard`/`markSubmittedToLeaderboard` — todos limpos em `reset()`.

**Por quê:** pedidos explícitos do usuário, detalhados em duas rodadas de perguntas (ver entrada anterior) — pontuação que recompensa velocidade sem parecer punitiva, ranking gated por uma pesquisa curta.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com **263 specs** passando — `test/game/leaderboard_scoring_test.dart` (fórmula pura), `test/screens/leaderboard_flow_test.dart` (6 casos: ícone de troféu abre o Placar, sem pontuação não mostra o convite, com pontuação mostra e leva pra pesquisa, botão só habilita com os 3 campos, enviar registra e navega, ranking ordena por pontuação), `test/helpers/fake_leaderboard_repository.dart` (mesmo padrão de `FakeSoundPlayer`, injetado via `Leaderboard.instance.repository =`). `no_overflow_test.dart` ganhou as 2 telas novas. Quando o Firebase entrar, só `FirebaseLeaderboardRepository`/`lib/data/leaderboard.dart` mudam — nenhuma tela precisa ser tocada.

---

## 2026-09-10 — `LeaderboardScreen` ganha ilustração da abelha (estado vazio) e ranking com selos por posição — UI Engineer

**Decisão:** pedido explícito do usuário pra deixar o Placar do Dia (`lib/screens/leaderboard_screen.dart`) "mais legal", visualmente monótono até então (cabeçalho só texto, estado vazio só uma frase, linhas de ranking idênticas entre si). Nenhum widget novo em `lib/widgets/`, nenhum token de cor novo — só reorganização visual dentro da própria tela:

1. **Novo asset**: `assets/images/leaderboard_bee.png` (personagem chibi de abelha/bug fornecido pelo usuário, mesmo espírito de arte do Mascote/ícones de Mundo), já registrado em `pubspec.yaml`. Usado **só** no estado vazio ("Ninguém no Placar ainda hoje. Seja o primeiro!") — extraído para `_EmptyLeaderboard` (privado à tela), com a abelha flutuando via `Bobbing` (widget já existente, reaproveitado sem mudança) acima do texto. Decisão deliberada de **não** repetir a abelha no cabeçalho/`_JoinCard` — reservada pro momento mais vazio da tela, que é onde mais se beneficia de uma ilustração (mesmo raciocínio já usado por este agente ao decidir não competir por atenção visual em telas com múltiplos elementos).
2. **Cabeçalho ganhou o mesmo selo decorativo já padronizado em `WorldSelectScreen`** (`HardShadowBox` circular, ícone — aqui `AppIcons.trophy`, coerente com o tema da tela — em `purple`/`purpleShadow`, **não** `yellowNeon`) ao lado do eyebrow "DEBUGA O MASCOTE"/título "Placar do Dia". Reaproveita um padrão visual que já existe em outra tela em vez de inventar um novo, e evita o mesmo erro que o UX Reviewer já tinha corrigido em `WorldSelectScreen` (selo decorativo não pode competir por `yellowNeon` com elementos que representam destaque real).
3. **`_JoinCard`**: pequeno selo circular (`yellowNeon`, ícone de estrela) ao lado do texto "Você fez N pontos!" — reforça visualmente a pontuação já destacada em `yellowNeon`, não introduz uso novo da cor em algo sem relação com resultado real.
4. **`_RankRow`**: as 3 primeiras posições ganham um selo numerado circular colorido (1º `yellowNeon`, 2º `lilac`, 3º `purple`, texto de contraste `purpleDark`/`white`) e uma borda de 2px na mesma cor ao redor da linha inteira — as demais posições mantêm um selo circular neutro (`grayButton`/`lilac`, sem borda). `yellowNeon` só aparece no 1º lugar — é o único "resultado de destaque" real da lista, mesmo critério já aplicado nos itens 2-3 acima.
5. Shadows das `HardShadowBox` novas/reescritas passaram a usar o helper `AppShadows.hard(...)` (já usado em `WorldSelectScreen`) em vez de `BoxShadow` literal inline, por consistência com o padrão mais recente do projeto — comportamento visual idêntico ao de antes (mesmo offset/cor).

**Textos/formatos que os testes procuram e que NÃO mudaram** (nenhum ajuste necessário em `test/screens/leaderboard_flow_test.dart`): botões `'Aparecer no Placar'`/`'Entrar e aparecer no Placar'`, texto do estado vazio `'Ninguém no Placar ainda hoje.\nSeja o primeiro!'` (o teste procura por `find.textContaining('Ninguém no Placar ainda hoje')`, que continua batendo), `_RankRow` continua mostrando nome + pontos (só ganhou o selo numerado visual, o texto em si não mudou).

**Por quê:** pedido explícito do usuário ("deixar mais legal", com um personagem novo fornecido por ele).

**Como aplicar:** `flutter analyze` limpo; suíte inteira (283 specs) passando, confirmado depois pela revisão — nenhum texto/estrutura que os testes procuravam mudou de verdade. Se o Placar ganhar mais posições de destaque no futuro (ex.: top 10 com cores extras), reavaliar se vale extrair `_RankRow`/o selo numerado para `lib/widgets/` — hoje é usado só nesta tela, então ficou privado.

---

## 2026-09-10 — `LeaderboardScreen`: 2 achados reais de UX Reviewer corrigidos (contraste do selo padrão, borda decorativa sem `onTap`)

**Decisão:** revisão do UX Reviewer sobre a entrega acima (selos numerados do ranking) encontrou 2 problemas reais, corrigidos na hora em `_RankRow`:

1. **Contraste insuficiente no selo padrão (4º lugar em diante)**: `_badgeTextColor` usava `AppColors.lilac` sobre `AppColors.grayButton`, medindo ≈3.44:1 — abaixo do mínimo AA (4.5:1) exigido por `.claude/rules/design.md` ("alto contraste sempre — estande iluminado"). Trocado para `AppColors.white`, que sobe pra ≈8.9:1. Os 3 primeiros lugares (fundo `yellowNeon`/`lilac`/`purple`, mais claros/saturados) já tinham contraste adequado e não mudaram.
2. **Borda decorativa nos top-3 imitava affordance de toque sem ter `onTap`**: a `HardShadowBox` de `_RankRow` tinha `border: isTopThree ? Border.all(color: _badgeColor, width: 2) : null` — combinado com a sombra dura do `HardShadowBox`, essa borda colorida reproduz a mesma linguagem visual usada em elementos tocáveis do app (mesmo padrão de erro já corrigido antes em `WorldSelectScreen`, ver entrada acima) — mas `_RankRow` não tem nenhum `onTap`. Removida a borda inteira (e a variável `isTopThree`, que ficou sem uso) — a distinção do top-3 continua clara pelo selo numerado colorido, sem precisar da borda.

**Por quê:** achados reais da revisão desta mesma etapa — pequenos e localizados, corrigidos na hora em vez de virar item de Roadmap.

**Como aplicar:** `flutter analyze` limpo; `flutter test` com as 283 specs continuando a passar (nenhum teste dependia da borda ou da cor exata do texto do selo — `.claude/rules/testing.md` já orienta a nunca testar cor/pixel exato). Se uma tela nova precisar destacar um item de lista sem ação de toque, preferir cor de preenchimento/selo a borda+sombra — essa combinação é reservada para elementos realmente tocáveis.
