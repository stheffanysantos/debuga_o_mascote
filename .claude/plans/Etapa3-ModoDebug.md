# Etapa 3 — Motor "Código" (Mundo 3, "Modo Debug")

## Como usar este arquivo

Quando for continuar, abra o Claude Code neste projeto e mande algo como:

> Leia `.claude/plans/Etapa3-ModoDebug.md` e implemente a Etapa 3 descrita nele.

Isso é tudo que precisa dizer — este arquivo tem o contexto e o escopo completos para o Claude pegar do zero, sem precisar da conversa anterior.

## Contexto

Este projeto está migrando de "1 mundo" para "3 mundos = 3 mini-jogos de lógica diferentes" (ver `.claude/plans/Mundos.md` para a arquitetura completa e o porquê da decisão, e `.claude/memory/decisions.md`, entrada "2026-09-05 — 3 mundos = 3 motores de jogo diferentes").

- **Etapa 1 (já implementada e commitada)**: infraestrutura de mundo — `GameWorld`/`WorldGameType`/`worlds` em `lib/models/level.dart`, a tela `lib/screens/world_select_screen.dart` (Seleção de Mundo, entre Splash e Seleção de Fases), e o widget compartilhado `lib/widgets/stage_select_grid_widget.dart`. Mundo 1 (labirinto) jogável com as 12 fases de sempre.
- **Etapa 2** (`.claude/plans/Etapa2-Esteira.md`): dá motor ao Mundo 2 ("Esteira de Bugs"). Pode já estar implementada ou não quando você começar esta etapa — **confira antes de começar**: rode `flutter test` e veja se `test/game/conveyor_level_catalog_test.dart` (ou nome equivalente) existe e passa, e se `worlds[1].comingSoon` já é `false` em `lib/models/level.dart`. Esta Etapa 3 não depende do motor do Mundo 2 para funcionar — só depende da infraestrutura da Etapa 1 (`GameWorld`, `WorldSelectScreen`, `StageSelectGrid`) — mas é bom saber em que pé o resto do projeto está antes de mexer.
- **Esta etapa (Etapa 3)**: dar motor de verdade ao Mundo 3 — "Modo Debug", inspirado no app real Mimo de ensino de código. Depois dela, Mundo 3 deixa de ser `comingSoon` e vira jogável, com 12 fases.

### O jogo do Mundo 3

Diferente dos Mundos 1 e 2 (que são "montar um programa e rodar passo a passo"), o Mundo 3 é feito de **puzzles de veredito único** — sem execução passo a passo, sem tabuleiro, sem esteira. Cada fase é de um destes 2 tipos:

- **Reordenar linhas** (`CodePuzzleType.reorder`): o jogador vê um código real (Dart/pseudocódigo simples) com as linhas embaralhadas, mostradas como chips tocáveis — igual à mecânica de montar o Programa nos outros mundos (tocar para adicionar à sequência montada, tocar de novo para remover). Ao apertar "Confirmar", compara a ordem montada com a ordem correta da fase.
- **Achar o bug** (`CodePuzzleType.findBug`): o jogador vê o código inteiro, já na ordem certa, com destaque de sintaxe simples (2–3 cores fixas via `AppColors`, sem parser de verdade — palavras-chave numa cor, resto noutra). Toca na linha que acha que tem o erro e aperta "Confirmar".

Não existe "quase certo" aqui — ou acertou ou errou (sem conceito de "blocos usados vs. ótimo"). Estrelas são por **tentativas**: acertou na 1ª tentativa = 3 estrelas; na 2ª = 2; da 3ª em diante = 1. Isso é diferente da fórmula de `computeScore` (`lib/game/scoring.dart`, usada pelos Mundos 1 e 2) — ver seção "Modelos" abaixo sobre `bestBlocks` reaproveitado como "tentativas".

## Escopo desta etapa

### 1. Modelos novos (Dart puro, sem `package:flutter/...` — ver `.claude/rules/architecture.md`)

- `lib/models/code_puzzle_level.dart`:
  - `enum CodePuzzleType { reorder, findBug }`
  - `class CodeLine { final String text; const CodeLine(this.text); }` — uma linha de código como texto simples (sem tokens/AST; a coloração de sintaxe é decisão de UI, ver seção Telas).
  - `class CodePuzzleLevel`: `id`, `world` (sempre `3`), `number` (1–12), `title`.
    - Para `type == reorder`: `correctOrder: List<CodeLine>` (a ordem certa; a UI embaralha na hora de montar a fase, não guarde uma ordem embaralhada fixa no modelo).
    - Para `type == findBug`: `codeWithBug: List<CodeLine>` (código completo, já na ordem certa, com 1 linha errada) + `buggyLineIndex: int` (índice 0-based da linha errada) + `bugExplanation: String` (frase curta explicando o erro, mostrada depois do resultado — equivalente à "Dica" dos outros mundos, mas mostrada sempre, não só na falha).
  - `final world3Levels = <CodePuzzleLevel>[...]` com as 12 fases — sugestão de progressão: comece com `reorder` (mais fácil de entender sem instrução prévia — o jogador já sabe montar sequências tocando, dos outros mundos) e misture `findBug` a partir da metade, com trechos de código cada vez um pouco mais longos/sutis.
- Em `lib/models/level.dart`: atualizar a entrada do Mundo 3 em `worlds` — trocar `comingSoon: true`/`levels: const []` por `comingSoon: false`. Mesma observação da Etapa 2 sobre generalizar `GameWorld.levels` para não ficar preso ao `Level` do labirinto — se a Etapa 2 já tiver resolvido isso, siga o mesmo padrão adotado lá; se não, resolva aqui (ambas as etapas precisam da mesma generalização, então vale conferir se uma das duas sessões já não fez esse trabalho antes de fazer de novo).

### 2. "Motor" (Dart puro): `lib/game/code_puzzle_checker.dart`

Mais simples que os outros dois motores — não tem passo a passo, é um único veredito:
- `bool checkReorder(List<CodeLine> attempt, List<CodeLine> correct)` — compara texto linha a linha, na ordem.
- `bool checkFindBug(int tappedLineIndex, int buggyLineIndex)` — comparação direta.
- Uma função de pontuação nova, `lib/game/code_puzzle_scoring.dart`: `computeCodePuzzleScore({required int attempts})` retornando o mesmo formato de `ScoreResult` (`lib/game/scoring.dart`) — 3 estrelas na 1ª tentativa, 2 na 2ª, 1 da 3ª em diante. Documentar em `GAME_DESIGN.md` antes de implementar.
- Sobre `Progress` (`lib/models/progress.dart`): `Progress.recordWin(id, stars, blocksUsed)` já existe e é reaproveitado passando `blocksUsed: attempts` — o nome do parâmetro fica semanticamente "errado" para este mundo, mas evita mudar a API pública de `Progress` por causa de só um motor. Deixe um comentário no ponto de chamada explicando esse reaproveitamento. Se, ao implementar, isso incomodar demais, é aceitável generalizar `Progress`/`LevelProgress` (ex. renomear `bestBlocks` para algo mais neutro tipo `bestMetric`) — decida ao chegar lá e registre a escolha em `.claude/memory/decisions.md`.

### 3. Telas

- `lib/screens/code_puzzle_stage_select_screen.dart`: mesmo papel de `lib/screens/level_select_screen.dart`, mas para `world3Levels` — reaproveita `StageSelectGrid` (`lib/widgets/stage_select_grid_widget.dart`) do mesmo jeito que as outras.
- `lib/screens/code_puzzle_gameplay_screen.dart`: alterna o conteúdo central por `level.type`:
  - `reorder`: linhas embaralhadas como chips tocáveis (pode reaproveitar bastante de `ProgramBlockChip`/o padrão tap-para-montar de `GameplayScreen._addBlock`/`_removeBlockAt`, adaptado para texto de código em vez de ícone+rótulo de bloco) + botão "Confirmar" (reaproveitar `PrimaryPillButton`).
  - `findBug`: lista de linhas com destaque de sintaxe simples via `RichText`/`TextSpan` com 2–3 cores fixas de `AppColors` (ex.: uma cor para palavras-chave tipo `if`/`for`/`return`, cor padrão pro resto — sem pacote novo, sem parser real, um regex simples de palavras-chave já basta) — tocar numa linha a seleciona (destaque visual), + botão "Confirmar".
- **Resultado**: como não há "blocos usados/`maxBlocks`", este mundo não se encaixa bem no formato de `VictoryScreen`/`FailureScreen` mesmo se a Etapa 2 já os tiver generalizado (que lida com "blocos vs. ótimo", não com "tentativas"). Crie telas de resultado próprias e mais simples: `lib/screens/code_puzzle_result_screen.dart` (uma tela só, parametrizada por `won: bool`, em vez de duas como os outros mundos, já que o resultado é binário) — reaproveitando átomos visuais existentes (`MascotImage` com as expressões `celebrating`/`confused`, `DottedBackground`, `PrimaryPillButton`, `StatCard` se fizer sentido pra mostrar "tentativas"). Vale extrair o `_ConfettiPainter` de `lib/screens/victory_screen.dart` para um widget `ConfettiOverlay` compartilhado em vez de duplicar o código da animação.

### 4. Documentação (mesma disciplina das etapas anteriores)

- `.claude/docs/GAME_DESIGN.md`: nova seção "## Mundo 3 — Modo Debug" descrevendo as regras acima (os 2 tipos de puzzle, condição de vitória/derrota, fórmula de estrelas por tentativa) **antes** de codar o motor.
- `.claude/memory/domain-glossary.md`: novos termos ("Linha de código", "Reordenar", "Achar o Bug", "Tentativa"), atualizar a entrada "Mundo" para tirar o `comingSoon` do Mundo 3.
- `.claude/docs/NAVIGATION_FLOW.md`, `.claude/docs/FOLDER_STRUCTURE.md`, `.claude/memory/design-system.md` (`ConfettiOverlay` novo no inventário), `.claude/memory/decisions.md` (nova entrada registrando as escolhas concretas — especialmente o reaproveitamento ou não de `bestBlocks`/`Progress`, e a tela de resultado única vs. duas).

### 5. Testes

- `test/game/code_puzzle_checker_test.dart`: `checkReorder`/`checkFindBug` com casos certos/errados.
- `test/game/code_puzzle_catalog_test.dart` (nos moldes de `test/game/level_catalog_test.dart`): as 12 fases de `world3Levels` têm dados consistentes — para `reorder`, `correctOrder` não vazio; para `findBug`, `buggyLineIndex` dentro dos limites de `codeWithBug` e `bugExplanation` não vazio; ids únicos e estáveis; `number` sequencial 1–12.
- `test/screens/no_overflow_test.dart`: adicionar as telas novas ao mapa de telas testadas.
- Um teste de fluxo real por tipo de puzzle (`test/screens/code_puzzle_flow_test.dart`, no espírito de `test/screens/gameplay_flow_test.dart`): monta a ordem certa num `reorder` → confirma vitória; toca a linha certa num `findBug` → confirma vitória; erra em ambos → confirma tela de derrota com a explicação certa.

## Ordem de execução recomendada

Mesmo fluxo de agentes de `.claude/docs/AGENTS_WORKFLOW.md`:

1. **Game Logic Engineer**: modelos (`CodePuzzleType`, `CodeLine`, `CodePuzzleLevel`, `world3Levels` com as 12 fases), `code_puzzle_checker.dart`, `code_puzzle_scoring.dart`, `GAME_DESIGN.md`/`domain-glossary.md`, testes de motor/catálogo.
2. **UI Engineer**: telas novas (incluindo o destaque de sintaxe simples), `ConfettiOverlay` extraído, `design-system.md`/`NAVIGATION_FLOW.md`, testes de tela.
3. **UX Reviewer**: é claro, sem instrução prévia, que num puzzle "tocar para montar" e no outro é "tocar para escolher"? A explicação do bug depois de errar/acertar é legível pra alguém sem experiência prévia de código?
4. **Code Reviewer**: `flutter analyze` + `flutter test` (suite inteira) + checklist final — rode você mesmo (ou peça ao Claude) esses dois comandos ao final, não confie só no relato de um agente sem acesso a shell.

## Verificação final

- `flutter analyze` sem issues.
- `flutter test` com a suíte inteira passando (Mundos 1 e 2 continuam intactos).
- Rodar o app e jogar manualmente: Seleção de Mundo → Mundo 3 (agora jogável, sem "EM BREVE") → Seleção de Fases do Mundo 3 → jogar uma fase de cada tipo (`reorder` e `findBug`) → ver o resultado (vitória/derrota) com a explicação certa.
