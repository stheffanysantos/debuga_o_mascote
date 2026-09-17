# Fluxo de Navegação — Debuga o Mascote

As telas do jogo (`.claude/plans/MVP.md`) e como se conectam. Ver
`.claude/plans/Mundos.md` para a arquitetura dos 5 Mundos
(cada um um mini-jogo de lógica diferente, agrupados em 2 Trilhas — Trilha 1:
Mundos 1-3; Trilha 2: Mundos 4-5) — todos com motor implementado e jogáveis.

```
SplashScreen
   │ toca "JOGAR"
   ▼
WorldSelectScreen ── uma seção por GameTrack: card "TRILHA N - NOME" + mapa
   │                 (ZigzagMap) dos Mundos daquela trilha logo abaixo
   │ toca um Mundo (WorldGameType decide a rota/tela — ver tabela abaixo)
   ▼
<StageSelectScreen do motor>(world) ──── volta (botão voltar) ──► WorldSelectScreen
   │ toca fase │ volta
   ▼           └─► WorldSelectScreen (popUntil, mesma instância)
<GameplayScreen do motor>(level)
   │ resultado (execução passo a passo nos Mundos 1/2; "Confirmar" — veredito
   │ único, sem passo a passo — nos Mundos 3/4/5)
   ├─ Vitória/Acertou ──► VictoryScreen (Mundos 1/2) ou CodePuzzleResultScreen(won: true) (Mundos 3/4/5)
   │                      onPrimaryAction: popUntil(rota) + push da próxima fase do mesmo mundo, se houver
   └─ Falha/Errou ──────► FailureScreen (Mundos 1/2) ou CodePuzzleResultScreen(won: false) (Mundos 3/4/5)
                          "Tentar de novo" (pop, mesma fase) │ "Menu" (popUntil(rota))
```

| Mundo | `WorldGameType` | Seleção de Fases | Gameplay | Resultado |
|---|---|---|---|---|
| 1 — Labirinto | `maze` | `LevelSelectScreen` | `GameplayScreen` | `VictoryScreen`/`FailureScreen` |
| 2 — Esteira de Bugs | `conveyor` | `ConveyorStageSelectScreen` | `ConveyorGameplayScreen` | `VictoryScreen`/`FailureScreen` |
| 3 — Preveja a Saída | `predictOutput` | `PredictOutputStageSelectScreen` | `PredictOutputGameplayScreen` | `CodePuzzleResultScreen` |
| 4 — Complete o Código | `completeCode` | `CompleteCodeStageSelectScreen` | `CompleteCodeGameplayScreen` | `CodePuzzleResultScreen` |
| 5 — Modo Debug | `codePuzzle` | `CodePuzzleStageSelectScreen` | `CodePuzzleGameplayScreen` | `CodePuzzleResultScreen` |

Na 1ª vez que `WorldSelectScreen` recebe o toque num Mundo jogável (linha
"toca Mundo N" acima), uma `TutorialScreen` (tela cheia, paginada) é
empurrada **antes** de
`LevelSelectScreen`/`ConveyorStageSelectScreen`/`CodePuzzleStageSelectScreen`
— ela mostra primeiro os slides gerais de "o que é programar"
(`programmingConceptSlides`) **só na primeiríssima vez** (`!Onboarding.instance.hasSeenIntro`,
visto uma única vez em qualquer Mundo), seguidos dos slides "como jogar"
daquele Mundo (`worldTutorials[world.number]`) — só ao terminar os slides
(ou tocar "Pular") a navegação acontece de fato
(`Onboarding.instance.hasSeen`/`markSeen`/`markIntroSeen`, ver seção
"Detalhe por tela" abaixo e `.claude/memory/decisions.md`). Nas próximas
vezes, o toque no Mundo pula direto para a Seleção de Fases, como no
diagrama.

**Gate de cadastro ao terminar a Trilha 1**: quando o Mundo que acabou de fechar 100%
agora é o último de `tracks.first.worlds` (hoje o Mundo 3, "Preveja a Saída" —
os Mundos 4/5 moram na Trilha 2, ver `.claude/memory/decisions.md`) — depois da
Recapitulação, se ela aparecer — cada `_returnToLevelSelect` (dentro de
`_goToResultScreen` dos 3 Gameplay screens) checa `!AppAuth.instance.hasAccount`
e, se for o caso, empurra `RegisterScreen(mandatory: true)` antes de
`popUntil`. `RegisterScreen` sempre tem uma saída ("Continuar sem conta por
enquanto") mesmo em modo obrigatório, pra nunca travar o app se o Firebase
estiver indisponível — ver `.claude/memory/decisions.md`. Cadastro
voluntário a qualquer momento antes disso: `SettingsView` → "Criar conta"
→ `RegisterScreen(mandatory: false)`.

`popUntil(levelSelectRouteName)`/`popUntil(conveyorLevelSelectRouteName)`/
`popUntil(predictOutputStageSelectRouteName)`/`popUntil(completeCodeStageSelectRouteName)`/
`popUntil(codePuzzleStageSelectRouteName)` reaproveita a mesma instância da
Seleção de Fases do mundo certo já na pilha (em vez de empilhar uma nova) —
ela recalcula o status das fases a partir de `Progress.instance` sempre que
reconstrói. `VictoryScreen`/`FailureScreen` são genéricas entre motores de
labirinto/esteira — não conhecem `Level`/`ConveyorLevel` nem decidem
navegação sozinhas; `GameplayScreen` (Mundo 1) e `ConveyorGameplayScreen`
(Mundo 2) montam os mesmos parâmetros (`levelNumber`, `blocksUsed`,
`maxBlocks`, `optimalBlocks`/`reasonText`+`hintChips`) a partir de tipos
diferentes e passam `onPrimaryAction`/`onBackToMenu` com a navegação certa
para o mundo de origem. Os Mundos 3/4/5 **não** reaproveitam essas duas
telas — o resultado de um puzzle de veredito único é binário, sem "quase
certo" (blocos usados vs. ótimo não existe ali) — usam uma tela própria,
`CodePuzzleResultScreen`, parametrizada por `won: bool` em vez de duas
telas separadas (ver `.claude/memory/decisions.md`).

## Detalhe por tela
- **Splash/Menu**: logo, mascote flutuando, botão Jogar pulsando, selo LiCode. Sem botão de configurações (saiu daqui, ver Seleção de Mundo abaixo — pedido explícito do usuário, ver `.claude/memory/decisions.md`). Sem lógica de jogo.
- **Seleção de Mundo (`WorldSelectScreen`)**: cabeçalho com botão voltar (esquerda) e, à direita, um ícone de troféu (`AppIcons.trophy`, abre o `LeaderboardScreen` — Placar do Dia, ver abaixo) seguido do botão de configurações (engrenagem, `AppIcons.settings`) — abre a `SettingsView` (`Navigator.push`, tela cheia, ver abaixo). Abaixo, uma lista de seções — uma por `GameTrack` (`tracks`, `lib/models/game_track.dart`): um card "TRILHA N - NOME" e, se a trilha não for `comingSoon`, o mapa em zigue-zague (`ZigzagMap`, `lib/widgets/zigzag_map_widget.dart`) dos mundos daquela trilha logo abaixo do card (um nó por `GameWorld`). Trilha 1 ("Fundamentos") tem os Mundos 1-3 (sequência, decisão e leitura de código); Trilha 2 ("Avançado") tem os Mundos 4-5 (completar e depurar código de verdade, mais difíceis), que só desbloqueiam quando a Trilha 1 inteira está completa (mesma regra de bloqueio sequencial usada entre mundos, um nível acima — ver `.claude/memory/decisions.md`). Cada nó de mundo mostra a imagem ilustrada e o rótulo "MUNDO N / NOME" — sem subtítulo/pill de dificuldade/estrelas (informação reduzida de propósito). Estados: jogável → tocável, amarelo pulsando (`PulseTap`); "bloqueado por progresso" (mundo/trilha anterior não concluído) → cadeado + opacidade reduzida. `_openWorld` decide a tela de Seleção de Fases pelo `WorldGameType` do mundo tocado. Uma flag de debug (`_debugUnlockAllWorlds`, ver `world_select_screen.dart`) ignora a trava de progresso (mundo e trilha) para facilitar teste antes da feira.
- **Boas-vindas (`WelcomeView`)**: tela cheia paginada mostrada uma única vez, ao tocar "JOGAR" na Splash pela 1ª vez (`OnboardingState.seenWelcome == false`) — 3 slides (`welcomeSlides`, Libug se apresenta nos 2 primeiros, Lili no último) explicando o jogo, terminando numa escolha de conta (criar conta/entrar/jogar sem conta) em vez de um botão de continuar (`TutorialView.finalActionsBuilder`). Substitui o antigo "conceito geral de programação" que existia dentro do fluxo de tutorial por Mundo — ver `.claude/memory/decisions.md`.
- **Tutorial (`TutorialView`)**: tela cheia paginada (`lib/features/tutorial/presentation/tutorial_view.dart`) — cada slide mostra uma arte (`TutorialSlide.imageAsset`, o Mascote por padrão) um título opcional e um corpo de texto revelado letra a letra (efeito de máquina de escrever, `_TypewriterText`); um toque no botão primário revela o texto todo na hora se ainda estiver "digitando", ou avança pro próximo slide se já estiver completo (rótulo "Próximo", vira "Jogar"/`finalLabel` no último). Um botão "Pular" no topo sai direto do tutorial a qualquer momento. Se existir, a narração em áudio do slide toca junto (`AppSounds.playNarration`, arquivos em `assets/audio/tutorial/`, gerados por `tool/generate_tutorial_narration.py`). Na 1ª vez que o jogador toca um mundo jogável (`OnboardingNotifier.hasSeen(world.number) == false`), `WorldSelectView` empurra a `TutorialView` daquele mundo (`worldTutorials[worldNumber]`, via `tutorialSlidesFor`) em vez de navegar direto. Terminar os slides (ou tocar "Pular") marca `markSeen(world.number)`, fecha a tela e só então abre a Seleção de Fases. Nas próximas vezes que aquele mundo é tocado, navega direto, sem tutorial. Cada Seleção de Fases tem um botão "?" (`AppIcons.help`) no cabeçalho, ao lado do botão voltar, que reabre a `TutorialView` daquele mundo a qualquer momento, e `onFinish` aqui só fecha a tela, sem navegar de novo (já está na tela certa).
- **Configurações (`SettingsView`)**: tela cheia (`Navigator.push`, substituiu o antigo `SettingsDialog`) aberta pelo botão de engrenagem da Seleção de Mundo — círculo de avatar (o personagem escolhido pelo jogador, `ProgressState.avatarId`) no topo, com um lápis sobreposto (só visível com conta) que abre a `ProfileEditView` (edita nome de usuário e escolhe o personagem num carrossel de `CharacterAvatar`, mostrado também no Placar Geral); toggle "Som" (`Switch` ligado a `mutedProvider`); seção "Conta" (criar conta/conectado como); e, com conta, um link "Sair da conta" no fim da tela. Ver `.claude/memory/decisions.md`.
- **Seleção de Fases (Mundo 1, `LevelSelectScreen`)**: as fases de `world.levels` (3 colunas, via `StageSelectGrid`); concluída = roxo + estrelas (tocável, permite rejogar), atual = amarelo pulsando (a primeira ainda não concluída), bloqueada = cinza + cadeado (todas depois da atual). Contador de estrelas totais no topo (`Progress.instance.totalStars(...)`). Botão voltar volta para a Seleção de Mundo.
- **Seleção de Fases (Mundos 2-5)**: mesma estrutura/mesmo `StageSelectGrid` de `LevelSelectScreen`, cada uma sobre a lista de fases do seu mundo — `ConveyorStageSelectScreen`/`world2Levels` (rota `conveyorLevelSelectRouteName`), `PredictOutputStageSelectScreen`/`world3Levels` (rota `predictOutputStageSelectRouteName`), `CompleteCodeStageSelectScreen`/`world4Levels` (rota `completeCodeStageSelectRouteName`), `CodePuzzleStageSelectScreen`/`world5Levels` (rota `codePuzzleStageSelectRouteName`).
- **Gameplay (Mundo 1, `GameplayScreen`)**: topo (voltar, "FASE N" + título da fase, `GameplayHeader.trailingChipText` com blocos usados/`maxBlocks`). Abaixo de 700px de largura (celular): tabuleiro em cima, "Seu Programa" + 4 botões de comando + Play embaixo, tudo empilhado com scroll. A partir de 700px (tablet): tabuleiro (maior) à esquerda, "Seu Programa" + comandos + Play à direita, lado a lado, sem precisar rolar (ver `.claude/memory/decisions.md`, entrada de 2026-09-09). Cada passo real de Andar/Virar toca um som (`AppSounds.instance.walk()/turn()`), Play toca `run()`. Ao final da execução, navega **direto** para Vitória ou Falha (sem modal/overlay intermediário no tabuleiro) — só uma pausa curta (`_resultPause`, 500ms) para o jogador ver onde o mascote parou antes da troca de tela.
- **Gameplay (Mundo 2, `ConveyorGameplayScreen`)**: mesmo cabeçalho (voltar, "FASE N" + título, `trailingChipText` com blocos usados/`maxBlocks`). No lugar do tabuleiro, um painel "esteira": fila horizontal rolável de Itens (`level.itemQueue`), o próximo item a classificar em destaque (borda + pulso, mesmo motivo visual do alvo do Mundo 1), e duas Caixas ("Caixa A" amarela / "Caixa B" roxa) abaixo, para o mapeamento cor→caixa ficar óbvio sem instrução prévia. "Seu Programa" + 3 comandos ("Se Amarelo → A" / "Se Roxo → B" — lado a lado — e "Repetir 3×" em largura cheia, para caber rótulos mais longos que os do Mundo 1 sem apertar) + Play. Um som por item classificado (`AppSounds.instance.turn()`, reaproveitado). Layout sempre empilhado (celular e tablet) — o layout lado a lado de tablet do Mundo 1 não foi replicado aqui nesta etapa (ver `.claude/plans/Roadmap.md`).
- **Gameplay (Mundo 3, `PredictOutputGameplayScreen`)**: mesmo cabeçalho, `trailingChipText` mostra "Tentativa N". Um card "LEIA O CÓDIGO" (só leitura, com destaque de sintaxe via `highlightCodeLine`), a pergunta da fase, e 2-3 opções tocáveis (`SelectableLineTile`). "Confirmar" checa `selectedOptionIndex == correctOptionIndex` e navega **direto** para `CodePuzzleResultScreen` — sem passo a passo a esperar. Layout sempre empilhado.
- **Gameplay (Mundo 4, `CompleteCodeGameplayScreen`)**: mesmo cabeçalho, `trailingChipText` mostra "Tentativa N". Um card "COMPLETE O CÓDIGO" mostra o trecho inteiro, com a linha de `blankLineIndex` substituída por um placeholder tracejado ("?") que vira uma prévia (destacada) do texto da opção assim que ela é tocada. Abaixo, 2-3 linhas candidatas tocáveis (`SelectableLineTile`, com destaque de sintaxe). "Confirmar" e navegação idênticos ao Mundo 3.
- **Gameplay (Mundo 5, `CodePuzzleGameplayScreen`)**: mesmo cabeçalho (voltar, "FASE N" + título), mas o `trailingChipText` mostra "Tentativa N" (a que está prestes a rodar, começa em 1) em vez de blocos — este mundo não tem conceito de "blocos". Sem tabuleiro/execução passo a passo: o conteúdo central alterna pelo `CodePuzzleType` da fase — `reorder` mostra um "banco" de linhas embaralhadas (tocar adiciona a "Sua sequência"; tocar de novo na sequência remove — mesmo padrão de tap-para-montar dos outros mundos); `findBug` mostra o código inteiro já na ordem certa, com destaque de sintaxe simples (`highlightCodeLine`) e cada linha tocável (`SelectableLineTile`) para selecionar a que tem o erro. Um botão "Confirmar" (`PrimaryPillButton`) roda `checkReorder`/`checkFindBug` (`lib/game/code_puzzle_checker.dart`) e navega **direto** para `CodePuzzleResultScreen` — sem pausa de animação (não há passo a passo a esperar). Layout sempre empilhado (celular e tablet, mesmo bônus não aplicado do Mundo 2 — ver `.claude/plans/Roadmap.md`).
- **Vitória (Mundos 1 e 2, `VictoryScreen`)**: fundo roxo escuro, confetes (`ConfettiOverlay`), estrelas animadas (reais, calculadas), mascote comemorando, cards de Pontos e Blocos usados/`maxBlocks` (reais). Chime + vibração ao abrir (`AppSounds.instance.victory()`). Genérica entre motores (ver acima).
- **Tentativa Falha (Mundos 1 e 2, `FailureScreen`)**: motivo real da falha (Mundo 1: bateu na parede/saiu do tabuleiro vs. não chegou ao alvo; Mundo 2: item classificado na caixa errada vs. sobraram itens na esteira), mascote confuso, card de Dica com o `hintProgram` real da fase (chips já montados por quem chama a tela). Som suave + vibração ao abrir (`AppSounds.instance.failure()`), deliberadamente não-punitivo. Genérica entre motores (ver acima).
- **Resultado (Mundos 3, 4 e 5, `CodePuzzleResultScreen`)**: uma tela só, parametrizada por `won: bool` (ver `.claude/memory/decisions.md`). Quando `won`: mesmo visual de `VictoryScreen` (fundo roxo escuro, `ConfettiOverlay`, mascote comemorando, `StarRow`, cards "PONTOS"/"TENTATIVAS"). Quando não: mesmo visual de `FailureScreen` (mascote confuso, título não-punitivo "Quase lá!"). A `explanationText` (sempre presente nos Mundos 3/4; em fases `findBug` do Mundo 5) aparece num card "COMO FUNCIONA" **sempre** (ganhou ou perdeu); em fases `reorder` do Mundo 5 perdidas, um card "DICA" mostra a ordem certa (`correctOrderChips`). `AppSounds.instance.victory()/.failure()` ao abrir, conforme `won`.
- **Recapitulação de fim de Mundo**: ao vencer a última fase pendente de um Mundo (`hasNext == false` nos 3 `_goToResultScreen`), se o Mundo acabou de ficar 100% completo **agora** (`Progress.isWorldCompleted`, comparado antes/depois de `recordWin`) e a recapitulação daquele Mundo ainda não foi vista (`Onboarding.hasSeenRecap`), a `TutorialScreen` é empurrada de novo — dessa vez com `worldRecapSlides[worldNumber]` (`tutorial_content.dart`) e `finalLabel: 'Continuar'`/`'Concluir'` em vez de "Jogar" — antes de voltar para a Seleção de Fases. Replays da última fase de um Mundo já recapitulado não mostram de novo.
- **Placar do Dia (`LeaderboardScreen`)**: aberto pelo ícone de troféu da Seleção de Mundo. Mostra o ranking de hoje (`Leaderboard.instance.topToday()`, Nome + Pontos, maior pontuação primeiro) — ver o ranking é sempre público. Se `Progress.instance.sessionScore > 0` (o jogador já concluiu alguma fase nesta sessão) e ele ainda não enviou (`!hasSubmittedToLeaderboard`), um card de convite leva pra `SurveyScreen`. **Pesquisa (`SurveyScreen`)**: 3 perguntas (nome, idade, "já programou antes?") — botão "Ver meu Placar" só habilita completo; ao confirmar, registra um `LeaderboardEntry` (via `Leaderboard.instance.submit`, hoje local em `shared_preferences` — Firebase é o próximo passo planejado, ver `.claude/memory/decisions.md`) e volta (`pushReplacement`) pro `LeaderboardScreen`, já mostrando a entrada nova.

Atualizar este arquivo sempre que uma transição mudar ou uma tela nova entrar no fluxo (ver `.claude/plans/Roadmap.md` para telas futuras, ex. layout de tablet não muda o fluxo, só o layout).
