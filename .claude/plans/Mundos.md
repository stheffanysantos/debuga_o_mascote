# 3 Mundos = 3 mini-jogos de lógica diferentes

## Contexto

O pedido original era só "3 mundos, dificuldade crescente" no mesmo jogo de labirinto — mas o usuário corrigiu: cada mundo deve ser um **jogo diferente** de lógica de programação, não uma variação de dificuldade do mesmo labirinto:

- **Mundo 1 — Labirinto** (já existe, sem mudança de regra): grid, Andar/Virar/Repetir.
- **Mundo 2 — Esteira com condicional** (novo): itens chegam numa esteira, o jogador monta um programa com blocos "Se [cor] → Caixa" + Repetir para separar tudo certo. Introduz decisão (`if`) além de sequência/loop.
- **Mundo 3 — "Modo Mimo"** (novo, inspirado no app real Mimo de ensino de código): puzzles com código de verdade — **reordenar linhas de código embaralhadas** e **achar a linha com bug** num trecho com destaque de sintaxe. Sem grid, sem mascote andando — é o mundo mais "código de verdade" do jogo, o que conecta bem com o nome "Debuga o Mascote".

Isso é um escopo bem maior que o originalmente pensado: 2 motores de jogo novos, não só fases novas no motor existente. Decisão combinada com o usuário: **planejar a arquitetura dos 3 mundos inteira agora, mas construir em etapas separadas** — este documento cobre a arquitetura completa; a implementação desta rodada cobre só a **Etapa 1** (infraestrutura de Mundo + Mundo 1 rejogável através dela). Etapas 2 e 3 (os motores novos) ficam detalhadas aqui para execução em sessões seguintes.

> **Status:** Etapa 1 concluída (`flutter analyze`/`flutter test` limpos — ver `.claude/memory/decisions.md`, entradas de 2026-09-05). Etapas 2 e 3 têm arquivo próprio cada, prontos para retomar direto numa sessão nova: `.claude/plans/Etapa2-Esteira.md` (Mundo 2) e `.claude/plans/Etapa3-ModoDebug.md` (Mundo 3).

Desbloqueio de mundo (confirmado com o usuário): regra real é **sequencial** (Mundo 2 abre só depois de completar as 12 fases do Mundo 1; Mundo 3 depois do Mundo 2) — igual à lógica já usada entre fases dentro de um mundo. Por enquanto, para facilitar teste, uma flag local `_debugUnlockAllWorlds = true` ignora essa trava (comentário explícito, fácil reverter para `false` antes da feira). Independente da flag, um mundo cujo motor ainda não foi construído (Mundo 2/3 na Etapa 1) aparece como **"EM BREVE"**, não tocável — conceito diferente de "bloqueado por progresso".

## Arquitetura geral (vale para as 3 etapas)

- `GameWorld` (`lib/models/level.dart`) ganha um campo `WorldGameType gameType` (`maze` | `conveyor` | `codePuzzle`) e `bool comingSoon`. `WorldSelectScreen` decide o destino da navegação e o visual (bloqueado/em breve/jogável) a partir desses dois campos + `Progress`.
- **`StageSelectGrid`** (novo widget compartilhado, extraído da grade/tile de `lib/screens/level_select_screen.dart:20-249` de hoje): recebe só `List<{number, status, stars}>` + `onTap(index)` — desacoplado do `Level` do labirinto. As 3 telas de "selecionar fase" (`LevelSelectScreen` para Mundo 1, e as novas telas de Mundo 2/3) usam esse widget, cada uma só calculando sua própria lista de status a partir de `Progress.instance` — elimina duplicar a grade/tile 3x. Sobe para `lib/widgets/`, entra no inventário do Design System.
- **`Progress`** (`lib/models/progress.dart`) não muda de forma — continua `Map<String, LevelProgress>` por `id` global (`world2_stageN`, `world3_stageN` mantêm os ids únicos). Mundo 3 (sem "blocos usados") reaproveita `bestBlocks` com o sentido de "tentativas" — documentar isso no arquivo.
- Cada motor é dono do seu par model+executor, no mesmo espírito de `lib/models/level.dart` + `lib/game/program_executor.dart` de hoje (Dart puro, sem Flutter, testável com `flutter_test` — ver `.claude/rules/testing.md`).

## Etapa 1 — Infraestrutura de Mundo (implementar agora)

Mesmo escopo de arquivos do plano anterior, com os ajustes acima:

1. **`lib/models/level.dart`**: adicionar `WorldGameType` (enum) e `GameWorld { number, name, subtitle, difficultyLabel, gameType, comingSoon, levels }` — para Mundo 1, `levels: world1Levels` (sem mudança nas 12 fases existentes); Mundo 2/3 entram com `levels: const []`, `gameType: conveyor/codePuzzle`, `comingSoon: true`. `final worlds = <GameWorld>[...]`.
2. **`lib/widgets/stage_select_grid_widget.dart`** (novo): `StageStatus` enum (`done`/`current`/`locked`), `StageTileData`, `StageSelectGrid` — extraído de `_LevelEntry`/`_LevelTile`/`GridView.builder` de `level_select_screen.dart`.
3. **`lib/screens/world_select_screen.dart`** (novo): lista os 3 `GameWorld`s (`_WorldCard` privado, mesmo espírito visual de `_LevelTile`), com estado done/current-jogável/bloqueado-por-progresso/em-breve; `_isWorldUnlocked` com a flag `_debugUnlockAllWorlds` comentada. Tap num mundo jogável e não "em breve" → `Navigator.push` com `RouteSettings(name: levelSelectRouteName)` para `LevelSelectScreen(world: world)` (só Mundo 1 é tocável nesta etapa).
4. **`lib/screens/splash_screen.dart`**: "JOGAR" empurra `WorldSelectScreen` em vez de `LevelSelectScreen` diretamente.
5. **`lib/screens/level_select_screen.dart`**: recebe `required GameWorld world`; usa `world.levels`/`world.number`/`world.name`; troca a grade/tile interna por `StageSelectGrid`.
6. **`lib/screens/gameplay_screen.dart`**: `_goToResultScreen` resolve a próxima fase via `worlds.firstWhere((w) => w.number == _level.world).levels` em vez de `world1Levels` fixo.
7. **Docs**: `.claude/docs/NAVIGATION_FLOW.md` (inserir `WorldSelectScreen`), `.claude/docs/GAME_DESIGN.md` (nova seção "Mundo 1 — Labirinto" com o conteúdo atual, mais um resumo dos Mundos 2/3 como "planejado, ver Etapas 2/3 abaixo"), `.claude/memory/domain-glossary.md` (redefinir "Mundo" para os 3 mundos/motores), `.claude/docs/FOLDER_STRUCTURE.md`, `.claude/memory/design-system.md` (novo `StageSelectGrid` no inventário), `.claude/memory/decisions.md` (registrar o pivô "1 motor com dificuldade crescente" → "3 motores diferentes", a flag de debug, e o reaproveitamento de `bestBlocks` como "tentativas" no Mundo 3).
8. **Testes**: generalizar `test/game/level_catalog_test.dart` só para Mundo 1 (sem mudança de fundo, já que Mundo 2/3 não têm fases ainda); `test/screens/no_overflow_test.dart` ganha `WorldSelectScreen` e `LevelSelectScreen(world: worlds.first)`; novo `test/screens/world_select_screen_test.dart` (mostra os 3 mundos; Mundo 2/3 aparecem "EM BREVE" e não navegam ao toque; tocar Mundo 1 navega para `LevelSelectScreen` mostrando "MUNDO 1").

## Etapa 2 — Motor "Esteira" (Mundo 2, sessão futura)

- **Modelos** (`lib/models/`): `BeltItemColor { yellow, purple }`; `BeltBlockType { ifYellowToBinA, ifPurpleToBinB, repeat }` + `BeltBlock` (mesma forma de `Block`); `ConveyorLevel { id, number, title, itemQueue: List<BeltItemColor>, maxBlocks, optimalBlocks, hintProgram: List<BeltBlock> }` (mesma forma de `Level`).
- **Motor** (`lib/game/belt_executor.dart`): mesmo formato de `ProgramExecutor` — `expand` (repeat vira N passos), `applyStep` (bloco não bate com a cor do item atual da fila → equivalente a colisão), `evaluateFinal` (fila não processada até o fim → falha).
- **Telas**: `ConveyorStageSelectScreen` (usa `StageSelectGrid`) + `ConveyorGameplayScreen` (visual de esteira + caixas nas laterais, mesmo padrão de "Seu Programa" + botões de comando + Play do `GameplayScreen` atual).
- **Resultado**: como a pontuação é a mesma fórmula (`computeScore`, blocos usados vs. `optimalBlocks`), vale a pena um pequeno refactor para desacoplar `VictoryScreen`/`FailureScreen` do `Level` do labirinto (hoje acessam `level.number`/`level.maxBlocks`/`level.hintProgram` diretamente) para um formato genérico (`levelNumber`, `maxBlocks`, `hintChips: List<ChipData>`, texto de motivo de falha) — permitindo que Mundo 1 e Mundo 2 compartilhem as mesmas telas de Vitória/Falha.
- 12 fases + teste nos moldes de `level_catalog_test.dart` (hintProgram processa a fila inteira sem erro).

## Etapa 3 — Motor "Código" (Mundo 3, sessão futura)

- **Modelos** (`lib/models/code_puzzle_level.dart`): `CodePuzzleType { reorder, findBug }`; `CodeLine { text }`; `CodePuzzleLevel { id, number, title, type, correctOrder (reorder) | codeWithBug + buggyLineIndex + bugExplanation (findBug) }`.
- **Motor** (`lib/game/code_puzzle_checker.dart`): funções puras, sem máquina de passos (é um único "veredito", não uma execução passo a passo) — `checkReorder(attempt, correct)` e `checkFindBug(tappedIndex, buggyIndex)`.
- **Telas**: `CodePuzzleStageSelectScreen` (usa `StageSelectGrid`) + `CodePuzzleGameplayScreen` (alterna UI por `type`: montar linhas tocando em ordem — reaproveitando o padrão tap-para-montar/tap-para-remover do `ProgramBlockChip` de hoje — ou tocar na linha com bug, com destaque de sintaxe simples via `AppColors`/`RichText`, sem pacote novo). Resultado é essencialmente binário (acertou/errou), então ganha telas de resultado próprias e mais simples (`CodePuzzleVictoryScreen`/`CodePuzzleFailureScreen`), reaproveitando átomos visuais já existentes (`MascotImage`, `DottedBackground`, `PrimaryPillButton`) — vale extrair o `_ConfettiPainter` de `victory_screen.dart` para um widget `ConfettiOverlay` compartilhado em vez de duplicar.
- Estrelas por tentativas (1ª tentativa = 3, 2ª = 2, demais = 1) em vez de blocos — nova função `computeCodePuzzleScore({attempts})` em `lib/game/code_puzzle_scoring.dart`, documentada em `GAME_DESIGN.md`.
- 12 fases (mix de `reorder`/`findBug`) + testes unitários dos checkers e widget tests da tela.

Cada etapa fecha pelo fluxo de agentes de `.claude/docs/AGENTS_WORKFLOW.md` (Game Logic Engineer → UI Engineer → UX Reviewer → Code Reviewer) e `flutter analyze`/`flutter test` antes de considerar pronta.

## Verificação (Etapa 1, o que será feito nesta rodada)
- `flutter test`: as 12 fases do Mundo 1 continuam solucionáveis; as 6 telas (Splash, Seleção de Mundo, Seleção de Fases, Gameplay, Vitória, Falha) sem overflow nos 3 tamanhos; novo teste de `WorldSelectScreen` (3 mundos, Mundo 1 tocável, Mundo 2/3 "EM BREVE" e não navegáveis).
- `flutter analyze` sem warnings novos.
- Rodar o app e navegar manualmente: Splash → JOGAR → Seleção de Mundo (Mundo 1 jogável, 2/3 "EM BREVE") → Mundo 1 → Seleção de Fases → jogar uma fase → Vitória/Falha → confirmar que o fluxo de "próxima fase"/"tentar de novo"/"menu" continua funcionando como hoje.
