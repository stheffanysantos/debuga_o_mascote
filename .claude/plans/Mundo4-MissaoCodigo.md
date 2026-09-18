# Mundo 4 — "Missão de Código" + Introdução de Trilha (Libug)

> **Este arquivo é só planejamento.** Nada aqui foi implementado — pedido explícito do usuário: escrever o plano completo (Mundo 4 + Introdução de Trilha) para revisão/commit, com a implementação de verdade ficando para uma sessão futura. Ver `.claude/memory/decisions.md` para os itens desta mesma sessão que **foram** implementados de verdade (redução de pontuação do Placar).

## Contexto

O Mundo 4 atual ("Decisões em Bloco", `WorldGameType.blockProgram`, `BlockProgramLevel`/`BlockProgramExecutor`) foi implementado ainda nesta sessão (esmaecimento progressivo — chips de "Seu Programa" mostrando código real, prefixo travado). O usuário testou e decidiu ir numa direção completamente diferente: cada fase ganha uma histórinha curta e uma sequência de perguntas de múltipla escolha (A/B/C/D) sobre código; cada resposta certa avança o Mascote 1 passo à frente num caminho **linear simples** (sem parede/virar — confirmado explicitamente com o usuário, não é o grid 6×6 dos Mundos 1-3). As opções de resposta podem ser código (texto) ou os ícones de bloco que o "Seu Programa" já usa nos outros mundos (Andar/Virar/Repetir etc.), reaproveitados visualmente — sem inventar assets novos.

Junto disso, o usuário pediu uma feature separada: ao terminar uma Trilha (ou tocar por 1ª vez no 1º Mundo da trilha seguinte), a Libug (abelha-guia, já estabelecida em `WelcomeView`) explica o tema da próxima Trilha, numa tela dedicada.

## Parte A — Mundo 4: "Missão de Código"

### A.1 Decisão de design principal — sem "Falha" por fase

Diferente do Mundo atual, aqui **não existe conceito de perder uma fase**: o jogador responde até acertar (mesmo padrão já usado pelos Mundos 5/6/7 — Preveja a Saída/Complete o Código/Modo Debug, onde uma resposta errada só soma 1 tentativa e deixa escolher de novo). A fase termina quando todas as N perguntas da sequência são respondidas corretamente (o Mascote chega ao fim do caminho). Isso elimina a necessidade de uma `FailureView`/estado de derrota — só existe o veredito de vitória ao final da sequência, reaproveitando **`CodePuzzleResultView`** (`lib/features/result/presentation/code_puzzle_result_view.dart`, já genérica: `won`/`attempts`/`stars`/`points`/`explanationText`/`onReplaySameLevel`).

### A.2 Modelo novo — `lib/models/code_quest_level.dart`

```dart
class CodeQuestLevel implements GameLevel {
  final String id;          // 'world4_levelN'
  final int world;          // 4
  final int number;         // 1-12
  final String title;
  final String story;       // histórinha curta (1-3 frases), sempre visível no topo da Gameplay
  final List<CodeQuestQuestion> questions; // 1 pergunta = 1 passo no caminho
  const CodeQuestLevel({...});
}

enum CodeQuestAnswerKind { code, blockIcon }

class CodeQuestQuestion {
  final String prompt;             // a pergunta em si
  final List<CodeLine> code;       // trecho de código de contexto (pode ser vazio)
  final CodeQuestAnswerKind answerKind;
  final List<String> codeOptions;      // 2-4 opções, só quando answerKind == code
  final List<BlockType> blockOptions;  // 2-4 opções, só quando answerKind == blockIcon (reaproveita BlockType do motor maze, lib/models/block.dart)
  final int correctOptionIndex;
  final String explanation;        // feedback educativo, sempre mostrado ao confirmar
  const CodeQuestQuestion({...});
}
```

Reaproveita `CodeLine` (`lib/models/code_line.dart`) já usado pelos Mundos 5/6/7. `blockOptions: List<BlockType>` reaproveita o enum do motor `maze` (`lib/models/block.dart`) **só como fonte de ícone/rótulo visual** (via `styleForBlock`/`BlockChipStyle`, `lib/widgets/block_chip_style.dart`) — nenhuma dependência do motor de execução do labirinto, só do estilo visual já pronto (ícone+cor+label de "Andar"/"Virar ←"/"Virar →"/"Repetir").

12 fases (`world4Levels`) reescritas do zero — histórinha + 3-5 perguntas cada, misturando `answerKind` (código puro nas fases iniciais, misturando com ícones de bloco a partir de onde fizer sentido pedagógico — ex. "qual desses comandos faria o Mascote virar?").

### A.3 Motor novo (Dart puro) — `lib/game/code_quest_progress.dart`

Sem tabuleiro/grid — só um cursor de progresso dentro da sequência de perguntas da fase atual:

```dart
class CodeQuestCursor {
  final int currentQuestionIndex;   // 0-based; == questions.length quando a fase termina
  final int totalAttempts;          // soma de tentativas (certas+erradas) em toda a fase — usado na pontuação
  const CodeQuestCursor({...});
  factory CodeQuestCursor.fromStart() => const CodeQuestCursor(currentQuestionIndex: 0, totalAttempts: 0);
}

enum CodeQuestAnswerOutcome { correct, wrong }

CodeQuestAnswerOutcome checkCodeQuestAnswer(CodeQuestQuestion question, int selectedIndex) =>
    selectedIndex == question.correctOptionIndex ? CodeQuestAnswerOutcome.correct : CodeQuestAnswerOutcome.wrong;

CodeQuestCursor advanceCodeQuestCursor(CodeQuestCursor cursor, CodeQuestAnswerOutcome outcome) {
  final attempts = cursor.totalAttempts + 1;
  if (outcome == CodeQuestAnswerOutcome.correct) {
    return CodeQuestCursor(currentQuestionIndex: cursor.currentQuestionIndex + 1, totalAttempts: attempts);
  }
  return cursor.copyWith(totalAttempts: attempts);
}

bool isCodeQuestComplete(CodeQuestCursor cursor, CodeQuestLevel level) =>
    cursor.currentQuestionIndex >= level.questions.length;
```

Testável isoladamente (Dart puro, sem Flutter/Riverpod — `.claude/rules/architecture.md`).

### A.4 Pontuação

Reaproveita **`computeCodePuzzleScore(attempts:)`** (`lib/game/code_puzzle_scoring.dart`) — mesma fórmula "por tentativas" dos Mundos 5/6/7, sem inventar uma 3ª fórmula. Como aqui há N perguntas por fase (não 1 veredito único), usa `cursor.totalAttempts` (soma de tentativas de todas as perguntas da fase) como o `attempts` de entrada — decisão a documentar explicitamente no código (a fase toda conta como "1 problema resolvido com X tentativas no total").

### A.5 `WorldGameType` novo

`WorldGameType.codeQuest` substitui `WorldGameType.blockProgram` na entrada do Mundo 4 em `worlds` (`lib/models/level.dart`). Nome do Mundo sugerido: **"Missão de Código"** (subtítulo: algo como "Ajude o Mascote a avançar respondendo sobre código") — confirmar/ajustar o nome na hora de implementar, não é uma decisão travada por este plano.

### A.6 UI — `lib/features/code_quest/presentation/{gameplay,stage_select}/`

Mesmo molde exato de `predict_output`/`complete_code` (`ConsumerWidget` sem `GlobalKey` — não há fila rolável aqui, é mais simples):

- **Card "HISTÓRIA"**: `level.story`, sempre visível no topo (mesmo papel do card "PROBLEMA" do Mundo 4 atual).
- **Caminho linear**: fila horizontal de N círculos pequenos (1 por pergunta) — precedente visual direto em `BlockProgramGameplayView._buildNumbers`/`_buildNumberChip` (fichas circulares, item atual pulsando/destacado, itens já passados esmaecidos). Aqui, o círculo do `currentQuestionIndex` mostra o Mascote (`MascotImage`, tamanho pequeno) em vez de um número; os já respondidos ficam marcados (✓ ou esmaecidos); os futuros ficam neutros. Sem grid, sem parede — só avanço linear.
- **Pergunta atual**: `prompt` + (se `code.isNotEmpty`) bloco de código via `RichText(highlightCodeLine(...))` (`lib/widgets/code_syntax_highlight.dart`, já usado pelos Mundos 5/6/7).
- **Opções A/B/C/D**:
  - `answerKind == code`: `SelectableLineTile` (`lib/widgets/selectable_line_tile_widget.dart`) com `label: '${String.fromCharCode(97+index)})'` — **mesmo padrão exato** já usado em `PredictOutputGameplayView._buildOption` (gera "a)", "b)", "c)", "d)" automaticamente).
  - `answerKind == blockIcon`: mesmo `SelectableLineTile`, `child` mostrando `styleForBlock(Block(type)).icon(24)` + rótulo do bloco (`styleForBlock(...).label`), reaproveitando ícone+cor já existentes sem precisar de nenhum asset novo.
- Botão `PrimaryPillButton('Confirmar')`, habilitado só com uma opção selecionada — mesmo padrão de Mundo 5/6.
- Ao confirmar: se `wrong`, mostra a `explanation` inline (mesmo lugar/estilo que Mundo 5/6 já usam) e deixa tentar de novo (não avança o caminho); se `correct`, avança o caminho (anima o Mascote 1 passo) e passa para a próxima pergunta, ou — se era a última — mostra `CodePuzzleResultView(won: true, ...)`.
- `GameplayHeader(trailingChipText: 'Passo ${cursor.currentQuestionIndex + 1} / ${level.questions.length}')`.

### A.7 Limpeza (arquivos que ficam órfãos)

Ao substituir por completo (sem manter os dois mundos simultaneamente, conforme confirmado com o usuário): excluir (não só desconectar) `lib/models/block_program_level.dart`, `lib/models/block_program_block.dart`, `lib/game/block_program_executor.dart`, `lib/widgets/block_program_chip_style.dart`, `lib/features/block_program/` (pasta inteira), e os testes correspondentes (`test/game/block_program_*`, `test/features/block_program/`) — mesmo padrão já usado 2× nesta sessão ao substituir mecânicas de mundo por completo (Esteira→Encruzilhada, Oficina de Blocos→Caça-Moedas→Desenho no Tabuleiro).

### A.8 Testes a escrever (mesmo padrão dos outros mundos)

- `test/game/code_quest_progress_test.dart` — motor Dart puro (`checkCodeQuestAnswer`/`advanceCodeQuestCursor`/`isCodeQuestComplete`).
- `test/game/code_quest_catalog_test.dart` — as 12 fases têm ids únicos/estáveis, `number` sequencial, e cada pergunta tem `correctOptionIndex` dentro dos limites das opções.
- `test/features/code_quest/code_quest_flow_test.dart` — fim a fim: responde uma sequência (acertando e errando de propósito 1x) até vencer a fase, confirma `CodePuzzleResultView(won: true)` com `attempts`/pontuação corretos.

### A.9 Tutorial/Recapitulação (`lib/widgets/tutorial_content.dart`)

`worldTutorials[4]`/`worldRecapSlides[4]` reescritos do zero para explicar a mecânica nova (história + perguntas + avanço no caminho) — os textos atuais (sobre Total/Contador/`forEachNumber`) ficam completamente errados para a mecânica nova.

---

## Parte B — Introdução de Trilha (Libug explica o tema)

### B.1 Design confirmado com o usuário

- **Personagem**: sempre a Libug (já estabelecida como guia em `WelcomeView`) — sem inventar personalidade nova para Bit/Chip/Loopy.
- **Trilha 1** ("Lógica em Apuros"): a intro sobre "lógica" aparece numa **tela separada, depois do Boas-vindas** (`WelcomeView`) — não dentro dele.
- **Trilhas 2+**: a intro aparece **na primeira ocasião que acontecer** entre (a) terminar a última fase do último Mundo da trilha anterior, ou (b) tocar por 1ª vez no 1º Mundo daquela trilha na Seleção de Mundo — o que vier primeiro; a outra rota vira no-op (já viu).

### B.2 Conteúdo — `lib/widgets/tutorial_content.dart`

Novo `Map<int, TrackTutorial> trackIntroSlides` (mesmo formato de `worldTutorials`/`worldRecapSlides` — `TutorialSlide`s com `imageAsset: 'assets/images/leaderboard_bee.png'`, texto da Libug se apresentando/explicando o tema):
- Trilha 1 → tema "lógica" (sequência, decisão).
- Trilha 2 → tema "construir soluções em blocos, resolvendo problemas de verdade".
- Trilha 3 → tema "ler, completar e depurar código de verdade".

### B.3 Persistência — `OnboardingState`/`OnboardingNotifier`

Novo por trilha, mesmo padrão de `hasSeen`/`hasSeenRecap`:
```dart
bool hasSeenTrackIntro(int trackNumber);
void markTrackIntroSeen(int trackNumber);
```
Persistido via `OnboardingRepository`/`SharedPreferencesOnboardingRepository` (já existe, ver `.claude/memory/decisions.md`, entrada "Bug real corrigido: boas-vindas reaparecendo").

### B.4 Gatilho (a) — fim da trilha anterior

`RecordLevelWinUseCase` já detecta `worldJustCompleted`/`isGameCompleted` comparando antes/depois de `recordWin` (`lib/core/progress/record_level_win_usecase.dart`). Estender com `trackJustCompleted: int?` (o número da trilha que **acabou de** ficar 100% completa nesta vitória, ou `null`):

```dart
final trackBefore = _trackContaining(world); // GameTrack? — usa `tracks`
final wasTrackCompleted = trackBefore != null && isTrackCompleted(trackBefore);
// ... recordWin ...
final isTrackCompletedNow = trackBefore != null && isTrackCompleted(trackBefore);
final trackJustCompleted = (!wasTrackCompleted && isTrackCompletedNow) ? trackBefore!.number : null;
```
Adicionar `trackJustCompleted` ao `RecordLevelWinResult`. Cada mundo já propaga `worldJustCompleted` do resultado do use case para seu próprio `*VictoryData`/`*ResultData` (5 arquivos: maze, code_quest [antigo block_program], predict_output, complete_code, code_puzzle) — replicar o mesmo campo `trackJustCompleted` nesses 5 lugares (mecânico, mesmo padrão já usado 5× para `worldJustCompleted`).

Em cada `_onVictoryPrimaryAction`-equivalente (depois do check de recapitulação de Mundo, que já existe): se `data.trackJustCompleted != null` e `data.trackJustCompleted! < tracks.length` (não é a última trilha) e `!onboarding.hasSeenTrackIntro(data.trackJustCompleted! + 1)`, mostrar `TutorialView(slides: trackIntroSlides[data.trackJustCompleted! + 1])`, marcar como visto, **depois** voltar pra Seleção de Fases (mesma ordem de composição já usada para recap→gate de cadastro).

### B.5 Gatilho (b) — tocar no 1º Mundo de uma trilha

Em `WorldSelectView._enterWorld` (ou equivalente): se `world == track.worlds.first && !onboarding.hasSeenTrackIntro(track.number)`, mostrar a intro da trilha **antes** do tutorial do Mundo (que já pode aparecer na mesma sequência, se também for a 1ª vez desse Mundo) — mesma composição sequencial que `WelcomeView`→tutorial de Mundo já usa hoje.

### B.6 Trilha 1 — tela separada após o Boas-vindas

Em `WelcomeView.onFinish` (ou o callback que hoje navega direto pra `WorldSelectView`): inserir a intro da Trilha 1 no meio, se `!onboarding.hasSeenTrackIntro(1)` — sempre verdade na 1ª execução (`WelcomeView` só aparece 1x mesmo). Fluxo: Boas-vindas → Intro Trilha 1 (Libug, tema "lógica") → Seleção de Mundo.

### B.7 Testes

`test/core/onboarding/onboarding_notifier_test.dart` ganha casos de `hasSeenTrackIntro`/`markTrackIntroSeen`. Testes de fluxo (`welcome_flow_test`/`world_select_screen_test`/os *_flow_test de cada mundo) ganham casos cobrindo os 2 gatilhos.

---

## Investigação feita nesta sessão (para contexto de quem for implementar)

Ao planejar a Parte C (fora deste arquivo — ver `.claude/memory/decisions.md`), consultei os dados reais do Firestore (`scores`, leitura pública, sem credenciais) e confirmei: hoje existem só 5 documentos, todos no esquema uid-keyed, com `gameCompleted` correto — **não há mais duplicação entre "Placar Geral" e "Zeraram o Jogo"** (a suspeita de documentos órfãos antigos, registrada numa decisão de 2026-09-17, já não se aplica — foram removidos em algum momento anterior a esta sessão). Os 3 jogadores que já zeraram o jogo têm pontuação entre 46.122 e 47.025 — confirma o problema de escala que motivou a Parte C (redução de pontuação), já implementada.
