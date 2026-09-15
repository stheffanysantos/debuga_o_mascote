# Design System — Debuga o Mascote

Fonte de verdade visual. Consultar antes de criar qualquer tela/widget novo — se um componente equivalente já existe, reutilizar/estender em vez de duplicar.

## Estilo geral
Casual e fofo, flat design, cantos arredondados, sombras suaves, alto contraste (o jogo roda num estande iluminado), interface pensada para toque — botões grandes.

## Paleta

| Token | Valor | Uso |
|---|---|---|
| `background` | `#393939` | Fundo geral das telas |
| `panel` | `#2b2b2b` | Painéis, cards, área "Seu programa" |
| `purpleDark` | `#2a1650` | Fundo da tela de Vitória, detalhes escuros |
| `purple` | `#6d3df5` | Cor primária de marca, botões Virar, paredes |
| `lilac` | `#b48cff` | Botão Andar, acentos secundários |
| `yellowNeon` | `#e8ff2a` | Ação primária (Play, Jogar, Repetir, alvo pulsante) |
| `white` | `#FFFFFF` | Texto sobre fundo escuro |

Zero hardcode de `Color(0x...)` fora do arquivo de tema central — ver `.claude/rules/design.md`.

## Tipografia
Fonte **Nunito**, pesos **800** (ExtraBold) e **900** (Black) para títulos/números de destaque (contador de blocos, estrelas, "Mandou bem!"). Pesos mais leves para texto de apoio, mas sempre Nunito.

## Mascote
Personagem chibi roxo/lilás, óculos redondos grandes, cabelo roxo escuro bagunçado, moletom amarelo-limão com `</>` no peito, marquinha `</>` amarela perto da cabeça, tênis roxo/branco.

3 expressões obrigatórias (assets separados ou variações do mesmo sprite):
- **Neutro** — estado padrão/gameplay.
- **Comemorando** — tela de Vitória.
- **Confuso** — tela de Tentativa Falha (com balão "?").

## Inventário de componentes
Atualizar esta tabela sempre que um widget reutilizável (usado por 2+ telas) for criado em `lib/widgets/`.

| Componente | Onde é usado | Descrição |
|---|---|---|
| `HardShadowBox` | base de quase todos os botões/cards | Container com sombra dura (offset sólido, sem blur) — estilo skeuomórfico do design |
| `PrimaryPillButton` | Splash, Gameplay, Vitória, Falha | Botão pill amarelo de ação primária, com pulso opcional |
| `PulseTap` | Splash (via `PrimaryPillButton`), Seleção de Mundo (nó de mundo jogável, via `ZigzagMap`), Seleção de Fases (fase atual), Gameplay do Mundo 1 (alvo), Gameplay do Mundo 2 (próximo item da esteira) | Pulsação em loop, com toque opcional |
| `IconActionButton` | Splash (configurações), Seleção de Mundo (voltar, troféu, configurações), Seleção de Fases (voltar + "?" de tutorial), Gameplay, Vitória, Falha, `CodePuzzleResultScreen`, `SettingsDialog` (fechar) | Botão quadrado de ícone com sombra dura (voltar, menu, reiniciar, configurações, fechar) |
| `ZigzagMap` | Seleção de Mundo (`WorldSelectScreen`) — um `ZigzagMap` por seção de `GameTrack` não-`comingSoon`, com um nó por `GameWorld` daquela trilha | Mapa em zigue-zague genérico — nós circulares (`ZigzagMapNode`: rótulo, ícone, bloqueado/`comingSoon`/tocável, já resolvidos por quem chama) ligados por uma trilha pontilhada; extraído de dentro de `WorldSelectScreen` pra ficar reaproveitável (hoje usado 1x por trilha jogável na mesma tela) |
| `CommandButton` | Gameplay (Mundo 1 e 2) | Botão de comando (ícone + rótulo) da área de blocos — rótulo dentro de `FittedBox(fit: scaleDown)` para caber tanto rótulos curtos (Mundo 1: "Andar") quanto mais longos (Mundo 2: "Se Amarelo → A") sem estourar a célula. `border: Border?` opcional — usado no Mundo 2 pra diferenciar "Enquanto" (com contorno) de "Se" (sem), quando os dois têm a mesma cor de fundo |
| `CommandButtonGrid` | Gameplay (Mundo 1: 4 colunas; Mundo 2: 5 colunas) | Grade compacta de `CommandButton`s — largura da célula sempre derivada do espaço real, altura com teto (`maxCellHeight`, padrão 72, telas reduzem pra 68) para não gerar botões grandes demais (achado do usuário: a árvore de `Row`s manual do Mundo 2 antes disso deixava só 1-2 comandos visíveis por linha) |
| `ProgramBlockChip` | Gameplay (Mundo 1 e 2, Seu Programa), Falha (card de Dica), Gameplay do Mundo 3 (banco de linhas/sequência montada de `reorder`), `CodePuzzleResultScreen` (Dica de `reorder` perdido) | Chip removível ou só exibição — no Mundo 1/2 rótulo/cores vêm de `styleForBlock`/`styleForBeltBlock` (um Bloco); no Mundo 3, `CodePuzzleGameplayScreen` passa o texto da `CodeLine` direto como `label` (sem arquivo de estilo próprio, só 2 combinações fixas de cor: banco = `lilac`/`purpleDark`, sequência montada = `purple`/`white`) |
| `ProgramChipGrid` | Gameplay (Mundo 1 e 2, área "Seu Programa", `crossAxisCount: 4`), card "DICA" (`FailureScreen`, `CodePuzzleResultScreen`, `crossAxisCount: 2` — card com padding próprio, célula mais estreita) | Organiza os `ProgramBlockChip`s em colunas de largura fixa (`crossAxisCount`) — usa `Wrap` por baixo (não `GridView`) para cada chip manter sua própria altura (rótulos longos do Mundo 2 quebram em 2+ linhas sem estourar a célula). Achado do usuário: os chips ficavam grandes/desorganizados num `Wrap` de largura livre |
| `StarRow` | Seleção de Fases, `CodePuzzleResultScreen` (`won: true`) | Fileira de 3 estrelas (acesas/apagadas) |
| `StageSelectGrid` | Seleção de Fases (`LevelSelectScreen`, `ConveyorStageSelectScreen`, `CodePuzzleStageSelectScreen`) | Grade de fases (3/4 colunas) dirigida por `StageTileData`/`StageStatus` — desacoplada do `Level` do labirinto, reaproveitada pela Seleção de Fases dos 3 mundos |
| `StatCard` | Vitória, `CodePuzzleResultScreen` (`won: true`, "PONTOS"/"TENTATIVAS") | Card de estatística com rótulo + valor de destaque |
| `MascotImage` | Splash, Gameplay (Mundo 1), Vitória, Falha, `CodePuzzleResultScreen` | Arte real do mascote (`assets/images/mascot.png`, fundo transparente) — só a expressão neutra existe por enquanto (ver `.claude/memory/decisions.md`). Não aparece na Gameplay do Mundo 2 (esteira) nem do Mundo 3 (puzzles de código, sem mascote/tabuleiro — ver `.claude/docs/GAME_DESIGN.md`) |
| `DirectionArrow` | Gameplay (Mundo 1) | Indicador de direção do mascote na célula |
| `DottedBackground` | Splash, Seleção de Fases, Vitória, Falha, `CodePuzzleResultScreen` | Textura de fundo pontilhada |
| `BlinkingDot` | Splash | Pontinho piscando do selo "LICODE" |
| `Bobbing` | Splash, Vitória, `CodePuzzleResultScreen` (`won: true`), `LeaderboardScreen` (abelha do estado vazio) | Flutuação vertical em loop |
| `ConfettiOverlay` | Vitória, `CodePuzzleResultScreen` (`won: true`) | Camada de confete caindo em loop, autocontida (`AnimationController` próprio) — extraída de `VictoryScreen` (era `_ConfettiPainter` inline) para não duplicar a animação |
| `GameplayHeader` | Gameplay (Mundo 1, 2 e 3) | Cabeçalho da Gameplay — voltar, "FASE N"+título, `trailingChipText` opcional (texto livre; `null` esconde o chip). Extraído de `GameplayScreen`/`ConveyorGameplayScreen` (eram idênticos — achado do Code Reviewer na Etapa 2); generalizado de `blocksUsed`/`maxBlocks` fixos para `trailingChipText` na Etapa 3 para caber "Tentativa N" do Mundo 3 (ver `.claude/memory/decisions.md`) |
| `SettingsDialog` | Seleção de Mundo (botão de engrenagem, `AppIcons.settings`) | Dialog modal de Configurações — hoje só um `Switch` (cores do tema) para "Som", ligado a `AppSounds.instance.muted`. Único controle de som do app — `MuteButton` (que existia na Splash/Gameplay/Vitória/Falha/`CodePuzzleResultScreen`) foi removido de todo lugar e excluído do projeto; o botão de configurações em si saiu da Splash e mora só na Seleção de Mundo agora (ver `.claude/memory/decisions.md`) |

## Estados visuais por tela
Ver `.claude/docs/NAVIGATION_FLOW.md` para a descrição completa das telas. Regras transversais:
- Botão de ação primária (Jogar/Play/Próxima fase/Repetir) sempre em `yellowNeon`, com destaque de pulso quando aplicável (menu, fase atual, alvo/item da esteira).
- Seleção de Mundo: mapa em zigue-zague (`_WorldMapPath`) — um nó circular por mundo (imagem ilustrada `assets/images/world{N}_icon.png`, gerada por IA, ver `.claude/memory/decisions.md`, anel amarelo se jogável/cinza se bloqueado) + rótulo "MUNDO N / NOME" abaixo, ligados por uma trilha pontilhada (`CustomPainter`, `AppColors.grayDashedBorder`). Sem subtítulo/pill de dificuldade/estrelas — informação reduzida de propósito. Mundo jogável = anel amarelo + pulso (`PulseTap`); bloqueado por progresso = badge de cadeado sobreposto + imagem/texto em escala de cinza; `comingSoon` = badge "EM BREVE" + mesmo tratamento cinza.
- Fases bloqueadas: cinza + cadeado. Fases concluídas: roxo + 0–3 estrelas. Fase atual: amarelo pulsando.
- Durante a Execução, o bloco atual do Programa fica visualmente destacado (Mundo 1 e 2).
- `VictoryScreen`/`FailureScreen` são genéricas entre motores de jogo (Mundo 1/2 — não conhecem `Level`/`ConveyorLevel`, nem navegam sozinhas) — quem as constrói (`GameplayScreen`/`ConveyorGameplayScreen`) monta os mesmos dados (`levelNumber`/`blocksUsed`/`maxBlocks`/`optimalBlocks` na Vitória; `levelNumber`/`attempt`/`reasonText`/`maxBlocks`/`hintChips` na Falha) a partir do resultado real da Execução do motor correspondente. Ver `.claude/memory/decisions.md`.
- O Mundo 3 não reaproveita `VictoryScreen`/`FailureScreen` (não tem "blocos usados vs. ótimo", resultado é binário por tentativas) — usa `CodePuzzleResultScreen`, uma tela só parametrizada por `won: bool`, com o mesmo vocabulário visual (fundo roxo escuro + confete quando `won`, mascote confuso + título não-punitivo quando não) — ver `.claude/memory/decisions.md`.
- Tutorial (`TutorialScreen`, `lib/screens/tutorial_screen.dart`): tela cheia por slide (não modal) — mascote de olhos abertos (`assets/images/mascot_tutorial.png`, arte diferente da usada no resto do app) + título opcional + corpo em efeito de máquina de escrever (`_TypewriterText`) + bolinhas de progresso + botão primário ("Próximo"/`finalLabel` customizável no último slide — "Jogar" no tutorial de um Mundo, "Continuar"/"Concluir" na recapitulação de fim de Mundo) + "Pular" no topo. Narração por slide toca via `AppSounds.instance.playNarration` quando o asset existe (`assets/audio/tutorial/`, gerado por `tool/generate_tutorial_narration.ps1`). Slides gerais de "o que é programar" (`programmingConceptSlides`) aparecem uma única vez, antes do 1º Mundo tocado; a mesma tela é reaproveitada para a recapitulação de fim de Mundo (`worldRecapSlides`, uma vez por Mundo — ver `.claude/memory/decisions.md`).
- Placar do Dia (`LeaderboardScreen`) e Pesquisa (`SurveyScreen`): ranking (Nome + Pontos, sem idade/resposta da pesquisa) sempre visível a partir do troféu na Seleção de Mundo; aparecer nele exige responder a pesquisa curta (3 campos: `TextField` de nome, `TextField` numérico de idade, pills Sim/Não "já programou antes?" — primeiro uso de `TextField` no projeto, decoração local em `SurveyScreen`, fundo `panel`/foco `yellowNeon`). Estado vazio do Placar usa a abelha chibi (`assets/images/leaderboard_bee.png`, arte fornecida pelo usuário) flutuando (`Bobbing`); as 3 primeiras posições do ranking ganham um selo numerado colorido (1º `yellowNeon`, 2º `lilac`, 3º `purple`) + borda da mesma cor na linha — só o 1º lugar reaproveita `yellowNeon` (destaque de resultado real, não decoração solta). Ver `.claude/memory/decisions.md`.
