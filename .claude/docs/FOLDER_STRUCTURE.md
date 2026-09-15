# Estrutura de Diretórios — Debuga o Mascote

```
lib/
  main.dart                        # entry point, MaterialApp, AppTheme.theme
  models/
    block.dart                     # BlockType, Block
    game_level.dart                 # GameLevel — interface mínima (id) implementada por Level, ConveyorLevel e CodePuzzleLevel
    level.dart                     # FacingDirection, GridPosition, Level, world1Levels (12 fases), demoLevel, WorldGameType, GameWorld, worlds (3 mundos)
    game_track.dart                 # GameTrack, tracks (Trilha 1 reaproveita `worlds`, Trilha 2 comingSoon), isTrackCompleted
    belt_item.dart                  # BeltItemColor (Mundo 2)
    belt_block.dart                 # BeltBlockType, BeltBlock (Mundo 2)
    conveyor_level.dart             # ConveyorLevel, world2Levels (12 fases, Mundo 2)
    code_puzzle_level.dart          # CodePuzzleType, CodeLine, CodePuzzleLevel, world3Levels (12 fases, Mundo 3)
    progress.dart                  # LevelProgress, Progress (singleton em memória — dura só a sessão); sessionScore/addSessionPoints e hasSubmittedToLeaderboard/markSubmittedToLeaderboard são pro Placar do Dia
    onboarding.dart                 # Onboarding (singleton em memória) — hasSeen/markSeen(worldNumber) controla a TutorialScreen "como jogar" de cada Mundo; hasSeenIntro/markIntroSeen controla o slide geral de "o que é programar" (mostrado uma única vez, ao entrar numa Trilha); hasSeenRecap/markRecapSeen controla a recapitulação de fim de Mundo
    leaderboard_entry.dart          # LeaderboardEntry (nome, idade, já programou, pontos, data) — registro do Placar do Dia, Dart puro
  game/
    game_result.dart               # GameOutcome, GameResult (Mundo 1)
    program_executor.dart          # GameCursor, ExecutionStep, StepOutcome, ProgramExecutor (Mundo 1)
    belt_executor.dart              # BeltCursor, BeltExecutionStep, BeltStepOutcome, BeltOutcome, BeltExecutor (Mundo 2)
    scoring.dart                   # ScoreResult, computeScore (estrelas/pontos a partir de blocksUsed vs. optimalBlocks — reaproveitado por Mundo 1 e 2)
    code_puzzle_checker.dart        # checkReorder, checkFindBug — veredito único do Mundo 3, sem passo a passo
    code_puzzle_scoring.dart        # computeCodePuzzleScore — estrelas/pontos do Mundo 3 a partir de tentativas até acertar
    leaderboard_scoring.dart        # computeSessionPoints — pontuação do Placar do Dia (base por mundo + bônus de rapidez oculto), separada do "PONTOS" por fase acima
  screens/
    splash_screen.dart              # "JOGAR" navega para WorldSelectScreen
    world_select_screen.dart        # Seleção de Mundo — uma seção por GameTrack (tracks, lib/models/game_track.dart): card "TRILHA N - NOME" + ZigzagMap dos seus mundos (trilha comingSoon = só o card); roteia por WorldGameType
    level_select_screen.dart        # Seleção de Fases do Mundo 1 (maze) — deriva status (feito/atual/bloqueado) de world.levels + Progress.instance
    gameplay_screen.dart            # Gameplay do Mundo 1 — recebe o Level a jogar, motor + animação passo a passo; layout empilhado (celular) ou lado a lado (tablet, ≥700px)
    conveyor_stage_select_screen.dart # Seleção de Fases do Mundo 2 (conveyor) — mesmo papel de level_select_screen.dart, sobre world2Levels
    conveyor_gameplay_screen.dart   # Gameplay do Mundo 2 — esteira de Itens + 2 Caixas, motor BeltExecutor
    code_puzzle_stage_select_screen.dart # Seleção de Fases do Mundo 3 (codePuzzle) — mesmo papel de level_select_screen.dart, sobre world3Levels
    code_puzzle_gameplay_screen.dart # Gameplay do Mundo 3 — alterna reorder/findBug pelo CodePuzzleType da fase, sem passo a passo (Confirmar = veredito único)
    code_puzzle_result_screen.dart  # tela de Resultado do Mundo 3 — uma tela só, parametrizada por won: bool (não reaproveita Victory/FailureScreen)
    victory_screen.dart             # genérica entre motores (Mundo 1/2) — recebe levelNumber/blocksUsed/maxBlocks/optimalBlocks/hasNext + onPrimaryAction (não navega sozinha)
    failure_screen.dart             # genérica entre motores (Mundo 1/2) — recebe levelNumber/attempt/reasonText/maxBlocks/hintChips + onBackToMenu (não navega sozinha)
    tutorial_screen.dart            # TutorialScreen — tela cheia paginada (slides + "Próximo"/finalLabel/"Pular"), texto em efeito de máquina de escrever, narração por slide; recebe slides/narrationAssets prontos (tutorial_content.dart) + onFinish (não navega/grava Onboarding sozinha); reaproveitada também pela recapitulação de fim de Mundo
    survey_screen.dart              # SurveyScreen — pesquisa opcional (nome, idade, já programou) pra aparecer no Placar do Dia
    leaderboard_screen.dart         # LeaderboardScreen — ranking de hoje (Nome + Pontos), convite pra SurveyScreen quando há sessionScore não enviado
    register_screen.dart            # RegisterScreen — cadastro/login (nome/email/senha) + Google via AppAuth.instance; mandatory:true (gate de fim de Trilha 1) sem botão de fechar, mas sempre com saída "Continuar sem conta por enquanto"
  widgets/
    hard_shadow_box_widget.dart
    primary_pill_button_widget.dart
    pulse_tap_widget.dart
    icon_action_button_widget.dart
    command_button_widget.dart
    command_button_grid_widget.dart # CommandButtonGrid — grade compacta de CommandButtons (Mundo 1: 4 colunas; Mundo 2: 3)
    program_block_chip_widget.dart
    program_chip_grid_widget.dart   # ProgramChipGrid — organiza os chips de "Seu Programa" em colunas de largura fixa (Wrap, não GridView)
    block_chip_style.dart           # styleForBlock — única fonte de rótulo/cor por BlockType (Mundo 1)
    belt_block_chip_style.dart      # styleForBeltBlock — única fonte de rótulo/cor por BeltBlockType (Mundo 2)
    star_row_widget.dart
    stat_card_widget.dart
    zigzag_map_widget.dart          # ZigzagMap, ZigzagMapNode — mapa em zigue-zague genérico (nós ligados por trilha pontilhada), usado por WorldSelectScreen (um por seção de GameTrack)
    labeled_text_field_widget.dart  # LabeledTextField — rótulo + TextField estilizado, usado por SurveyScreen e RegisterScreen
    mascot_image_widget.dart        # arte real (assets/images/mascot.png) — ver .claude/memory/decisions.md
    settings_dialog_widget.dart     # SettingsDialog — dialog modal de Configurações (toggle de Som), aberto pelo botão de engrenagem da Seleção de Mundo
    tutorial_content.dart           # TutorialSlide, programmingConceptSlides, worldTutorials, tutorialSlidesFor — conteúdo/composição dos slides consumidos por TutorialScreen (lib/screens/tutorial_screen.dart)
    gameplay_header_widget.dart     # cabeçalho da Gameplay (voltar, FASE N, trailingChipText opcional) — reaproveitado pelos 3 mundos
    confetti_overlay_widget.dart    # ConfettiOverlay — animação de confete autocontida, extraída de VictoryScreen; reaproveitada por CodePuzzleResultScreen
    direction_arrow_widget.dart
    dotted_background_widget.dart
    blinking_dot_widget.dart
    bobbing_widget.dart
    stage_select_grid_widget.dart   # grade de fases desacoplada do Level do labirinto — reaproveitada por LevelSelectScreen, ConveyorStageSelectScreen e CodePuzzleStageSelectScreen
  theme/
    app_colors.dart                 # tokens da paleta (.claude/memory/design-system.md)
    app_text.dart                   # AppText.style/eyebrow — Nunito via google_fonts
    app_shadows.dart                 # sombras "duras" (offset sólido) reutilizadas nos botões/cards
    app_icons.dart                  # ícones do design como SVG inline (flutter_svg), inclui volumeOn/volumeOff
    app_theme.dart                  # ThemeData usando os tokens acima
  audio/
    sound_player.dart               # interface SoundPlayer — permite fake nos testes
    audioplayers_sound_player.dart  # implementação real (package:audioplayers)
    app_sounds.dart                 # AppSounds.instance — sons + HapticFeedback, mute de sessão
  data/
    leaderboard_repository.dart     # interface LeaderboardRepository — permite fake nos testes
    local_leaderboard_repository.dart # implementação local (package:shared_preferences, lista JSON) — fallback quando o Firebase não está disponível
    device_identity.dart            # interface DeviceIdentity (UID anônimo do aparelho)
    firebase_device_identity.dart   # implementação real — FirebaseAuth.instance.signInAnonymously()
    firebase_leaderboard_repository.dart # implementação real via Firestore (players/{uid} + scores) — usada quando Firebase.apps.isNotEmpty
    leaderboard.dart                # Leaderboard.instance — escolhe Firebase (Firestore) ou local automaticamente, mesmo padrão de AppSounds.instance
    auth_service.dart               # interface AuthService (cadastro/login real) — permite fake nos testes
    firebase_auth_service.dart      # implementação real via Firebase Auth (email/senha + Google, sempre tenta linkar a conta anônima primeiro)
    app_auth.dart                   # AppAuth.instance — mesmo padrão de Leaderboard.instance/AppSounds.instance
    progress_sync.dart              # ProgressSync.instance — sincroniza Progress.instance com players/{uid} no Firestore (perfil + estrelas/blocos por fase), hydrate() no boot e depois de login, syncNow() fire-and-forget depois de cada mutação

tool/
  generate_sfx.py                   # gera os 5 .wav de assets/audio/ por síntese (placeholder, ver .claude/memory/decisions.md)
  generate_tutorial_narration.py    # gera assets/audio/tutorial/*.mp3 via edge-tts (voz neural pt-BR-FranciscaNeural), ver .claude/memory/decisions.md

test/
  widget_test.dart                  # smoke test da Splash
  models/
    progress_test.dart              # unit tests de Progress.byLevelId/restore (usados por ProgressSync)
  game/
    program_executor_test.dart      # unit tests do motor de jogo do Mundo 1 (expand/applyStep/evaluateFinal)
    belt_executor_test.dart          # unit tests do motor de jogo do Mundo 2 (expand/applyStep/evaluateFinal)
    scoring_test.dart                # unit tests de computeScore
    level_catalog_test.dart          # as 12 fases de world1Levels são solucionáveis (hintProgram)
    conveyor_level_catalog_test.dart # as 12 fases de world2Levels são solucionáveis (hintProgram)
    code_puzzle_checker_test.dart    # unit tests de checkReorder/checkFindBug (Mundo 3)
    code_puzzle_catalog_test.dart    # as 12 fases de world3Levels têm dados consistentes (reorder/findBug)
    leaderboard_scoring_test.dart   # unit tests de computeSessionPoints (Placar do Dia)
  audio/
    app_sounds_test.dart            # mute e roteamento de som/haptic, via FakeSoundPlayer
  helpers/
    fake_sound_player.dart          # SoundPlayer de teste, reaproveitado pelos testes de tela
    fake_leaderboard_repository.dart # LeaderboardRepository de teste, mesmo padrão de fake_sound_player.dart
    fake_auth_service.dart          # AuthService de teste, mesmo padrão de fake_sound_player.dart
  screens/
    no_overflow_test.dart           # as telas (Mundo 1, 2 e 3) em 3 tamanhos de tela (celular pequeno/grande, tablet), sem overflow
    gameplay_flow_test.dart         # Mundo 1: joga de verdade (vitória e derrota) e confirma navegação/conteúdo real
    conveyor_flow_test.dart          # Mundo 2: mesmo espírito de gameplay_flow_test.dart, para ConveyorGameplayScreen
    code_puzzle_flow_test.dart       # Mundo 3: mesmo espírito de gameplay_flow_test.dart, para CodePuzzleGameplayScreen (reorder e findBug, acerto e erro)
    gameplay_tablet_layout_test.dart # confirma que o tabuleiro do Mundo 1 cresce (layout lado a lado) acima do breakpoint de tablet
    world_select_screen_test.dart   # Seleção de Mundo — mostra o card da Trilha 1 + mundos e o card "EM BREVE" da Trilha 2; Mundo 1/2/3 (já vistos, ver Onboarding) navegam para suas Seleções de Fases
    tutorial_flow_test.dart         # TutorialScreen — 1ª vez mostra o slide geral de "o que é programar" antes do mundo; "Próximo" 1º toque revela o texto/2º avança; "Pular"/completar todos os slides navegam e marcam Onboarding; mundo já visto navega direto; botão "?" reabre só os slides daquele mundo
    settings_dialog_test.dart       # SettingsDialog — botão de configurações da Seleção de Mundo abre o dialog, toggle de Som reflete/altera AppSounds.instance.muted; seção "Conta" (criar conta / conectado como)
    leaderboard_flow_test.dart      # Placar do Dia + Pesquisa — troféu abre o Placar, convite condicional a sessionScore, formulário só habilita completo, enviar registra e navega, ranking ordena por pontuação
    register_screen_test.dart       # RegisterScreen — alternar cadastro/login, validação de campos, erro inline, Google, mandatory (sem fechar, com "Continuar sem conta")
    register_gate_test.dart         # Gate de cadastro ao terminar a Trilha 1 — joga de verdade até a última fase do Mundo 3; sem conta mostra RegisterScreen mandatory (com saída); com conta não mostra nada
```

Esta árvore reflete o estado real do código (implementado a partir do design do Claude Design) — atualizar este arquivo sempre que uma pasta/arquivo novo de `lib/` for criado.
