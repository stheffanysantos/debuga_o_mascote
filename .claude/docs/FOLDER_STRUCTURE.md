# Estrutura de Diretórios — Debuga o Mascote

Arquitetura Riverpod + MVVM + Clean Architecture pragmática — ver `.claude/rules/architecture.md` e `.claude/memory/decisions.md` (entrada de 2026-09-16) para o porquê.

```
lib/
  main.dart                        # entry point — Firebase.initializeApp, ProviderContainer/UncontrolledProviderScope, MaterialApp
  models/                          # entidades de domínio, Dart puro (sem Flutter, sem Riverpod)
    block.dart                     # BlockType, Block
    game_level.dart                 # GameLevel — interface mínima (id) implementada por Level, ConveyorLevel, PredictOutputLevel, CompleteCodeLevel e CodePuzzleLevel
    level.dart                     # FacingDirection, GridPosition, Level, world1Levels (12 fases), demoLevel, WorldGameType, GameWorld, worlds (5 mundos)
    game_track.dart                 # GameTrack, tracks (Trilha 1 = Mundos 1-3, Trilha 2 = Mundos 4-5) — dado puro; isTrackCompleted mora em ProgressState (core/progress/), não aqui
    belt_item.dart                  # BeltItemColor (Mundo 2)
    belt_block.dart                 # BeltBlockType, BeltBlock (Mundo 2)
    conveyor_level.dart             # ConveyorLevel, world2Levels (12 fases, Mundo 2)
    code_line.dart                   # CodeLine — linha de código como texto simples, reaproveitada pelos Mundos 3/4/5
    predict_output_level.dart       # PredictOutputLevel, world3Levels (12 fases, Mundo 3 "Preveja a Saída")
    complete_code_level.dart        # CompleteCodeLevel, world4Levels (12 fases, Mundo 4 "Complete o Código")
    code_puzzle_level.dart          # CodePuzzleType, CodePuzzleLevel, world5Levels (12 fases, Mundo 5 "Modo Debug")
    progress.dart                  # LevelProgress — classe de dado pura; estado do jogador em si mora em core/progress/ProgressState
    leaderboard_entry.dart          # LeaderboardEntry (nome, idade, já programou, pontos, data, avatarId) — registro do Placar Geral, Dart puro
    character_avatar.dart           # CharacterAvatar, characterAvatars, avatarById — personagens selecionáveis como foto de perfil (Lili, Libug)
  game/                            # motores de execução, Dart puro (sem Flutter, sem Riverpod)
    game_result.dart               # GameOutcome, GameResult (Mundo 1)
    program_executor.dart          # GameCursor, ExecutionStep, StepOutcome, ProgramExecutor (Mundo 1)
    belt_executor.dart              # BeltCursor, BeltExecutionStep, BeltStepOutcome, BeltOutcome, BeltExecutor (Mundo 2)
    scoring.dart                   # ScoreResult, computeScore (estrelas/pontos a partir de blocksUsed vs. optimalBlocks — reaproveitado por Mundo 1 e 2)
    code_puzzle_checker.dart        # checkReorder, checkFindBug — veredito único do Mundo 5, sem passo a passo
    code_puzzle_scoring.dart        # computeCodePuzzleScore — estrelas/pontos a partir de tentativas até acertar, reaproveitado pelos Mundos 3/4/5 (todos "veredito único")
    leaderboard_scoring.dart        # computeSessionPoints — pontuação do Placar do Dia (base por mundo + bônus de rapidez oculto), separada do "PONTOS" por fase acima

  core/                            # infraestrutura transversal, exposta via provider (@Riverpod(keepAlive: true))
    device_identity.dart            # interface DeviceIdentity (UID anônimo do aparelho)
    firebase_device_identity.dart   # implementação real — FirebaseAuth.instance.signInAnonymously()
    progress/
      progress_state.dart           # @freezed ProgressState (byLevelId, sessionScore, hasSubmittedToLeaderboard) — isCompleted/starsFor/isWorldCompleted/isTrackCompleted moram aqui
      progress_repository.dart      # interface ProgressRepository (fetch/save)
      firestore_progress_repository.dart # implementação real — players/{uid} no Firestore
      progress_notifier.dart        # ProgressNotifier (@riverpod, keepAlive) — hidrata fire-and-forget no build(), recordWin/addSessionPoints/markSubmittedToLeaderboard/rehydrate
      record_level_win_usecase.dart # RecordLevelWinUseCase — único use case do app: registra vitória + soma pontos de sessão só na 1ª vez + detecta mundo/trilha recém-completos; reaproveitado sem mudança pelos 5 mundos
    onboarding/
      onboarding_state.dart         # @freezed OnboardingState (seenWorldNumbers, seenRecapWorldNumbers, seenIntro)
      onboarding_notifier.dart      # OnboardingNotifier (@riverpod, keepAlive) — markSeen/markIntroSeen/markRecapSeen
    auth/
      auth_service.dart             # interface AuthService — permite fake nos testes
      firebase_auth_service.dart    # implementação real via Firebase Auth (email/senha + Google, sempre tenta linkar a conta anônima primeiro)
      auth_providers.dart           # authServiceProvider
    leaderboard/
      leaderboard_repository.dart   # interface LeaderboardRepository — permite fake nos testes
      local_leaderboard_repository.dart # implementação local (shared_preferences) — fallback quando o Firebase não está disponível
      firebase_leaderboard_repository.dart # implementação real via Firestore (players/{uid} + scores)
      leaderboard_providers.dart    # leaderboardRepositoryProvider — escolhe Firebase ou local automaticamente
    audio/
      sound_player.dart             # interface SoundPlayer — permite fake nos testes
      audioplayers_sound_player.dart # implementação real (package:audioplayers)
      audio_providers.dart          # soundPlayerProvider, mutedProvider (Muted notifier), appSoundsProvider (AppSoundsService — walk/turn/run/victory/failure/playNarration)

  features/                        # um diretório por mundo de jogo ou tela transversal
    maze/presentation/{gameplay,stage_select}/          # Mundo 1 (labirinto) — vertical de referência da migração
    conveyor/presentation/{gameplay,stage_select}/       # Mundo 2 (esteira)
    predict_output/presentation/{gameplay,stage_select}/ # Mundo 3 (Preveja a Saída) — "veredito único"
    complete_code/presentation/{gameplay,stage_select}/  # Mundo 4 (Complete o Código) — "veredito único"
    code_puzzle/presentation/{gameplay,stage_select}/    # Mundo 5 (Modo Debug) — "veredito único", reorder/findBug
    result/presentation/
      victory_view.dart             # genérica entre Mundo 1/2 — recebe levelNumber/blocksUsed/maxBlocks/optimalBlocks/hasNext + onPrimaryAction (não navega sozinha)
      failure_view.dart             # genérica entre Mundo 1/2 — recebe levelNumber/attempt/reasonText/maxBlocks/hintChips + onBackToMenu (não navega sozinha)
      code_puzzle_result_view.dart  # genérica entre Mundo 3/4/5 (veredito único) — uma tela só, parametrizada por won: bool
    world_select/presentation/world_select_view.dart     # Seleção de Mundo — sem ViewModel; uma seção por GameTrack, roteia por WorldGameType
    tutorial/presentation/tutorial_view.dart              # tela cheia paginada (slides + narração); ConsumerStatefulWidget com estado local (índice do slide, máquina de escrever) — não é estado de app, não ganhou ViewModel
    leaderboard/presentation/{leaderboard_view.dart, leaderboard_view_model.dart} # LeaderboardViewModel é AsyncNotifier<List<LeaderboardEntry>> — sem _state.dart próprio (AsyncValue já cobre loading/data/erro)
    auth/presentation/register/{register_view.dart, register_view_model.dart, register_state.dart} # formulário com estado real (modo, envio, erro) — TextEditingControllers ficam na View
    survey/presentation/survey_view.dart                  # pesquisa opcional (idade, já programou) — sem ViewModel, único ponto de orquestração é um _submit() de disparo único
    splash/presentation/splash_view.dart                  # sem ViewModel
    welcome/presentation/welcome_view.dart                 # boas-vindas de 1ª execução (3 slides + escolha de conta) — embrulha TutorialView com finalActionsBuilder
    settings/presentation/{settings_view.dart, profile_edit_view.dart} # SettingsView (tela cheia, substituiu o antigo SettingsDialog) e ProfileEditView (nome de usuário + carrossel de CharacterAvatar) — sem ViewModel em nenhuma das duas

  widgets/                          # Design System, reutilizado por 2+ features
    code_syntax_highlight.dart       # highlightCodeLine — destaque de sintaxe simples (regex de palavras-chave), reaproveitado pelos Mundos 3/4/5
    selectable_line_tile_widget.dart # SelectableLineTile — linha/opção tocável com destaque de seleção, reaproveitado pelos Mundos 3/4/5
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
    zigzag_map_widget.dart          # ZigzagMap, ZigzagMapNode — mapa em zigue-zague genérico (nós ligados por trilha pontilhada), usado por WorldSelectView (um por seção de GameTrack)
    labeled_text_field_widget.dart  # LabeledTextField — rótulo + TextField estilizado, usado por SurveyView e RegisterView
    mascot_image_widget.dart        # arte real (assets/images/mascot.png) — ver .claude/memory/decisions.md
    character_avatar_widget.dart    # CharacterAvatarCircle — círculo com a arte de um CharacterAvatar, usado por SettingsView, ProfileEditView e _RankRow (Placar Geral)
    tutorial_content.dart           # TutorialSlide, welcomeSlides, worldTutorials, tutorialSlidesFor — conteúdo/composição dos slides consumidos por TutorialView
    gameplay_header_widget.dart     # cabeçalho da Gameplay (voltar, FASE N, trailingChipText opcional) — reaproveitado pelos mundos com passo a passo
    confetti_overlay_widget.dart    # ConfettiOverlay — animação de confete autocontida, extraída de VictoryView; reaproveitada por CodePuzzleResultView
    direction_arrow_widget.dart
    dotted_background_widget.dart
    blinking_dot_widget.dart
    bobbing_widget.dart
    stage_select_grid_widget.dart   # grade de fases desacoplada do Level do labirinto — reaproveitada pelas 5 StageSelectView

  theme/
    app_colors.dart                 # tokens da paleta (.claude/memory/design-system.md)
    app_text.dart                   # AppText.style/eyebrow — Nunito via google_fonts
    app_shadows.dart                 # sombras "duras" (offset sólido) reutilizadas nos botões/cards
    app_icons.dart                  # ícones do design como SVG inline (flutter_svg), inclui volumeOn/volumeOff
    app_theme.dart                  # ThemeData usando os tokens acima

tool/
  generate_sfx.py                   # gera os 5 .wav de assets/audio/ por síntese (placeholder, ver .claude/memory/decisions.md)
  generate_tutorial_narration.py    # gera assets/audio/tutorial/*.mp3 via edge-tts (voz neural pt-BR-FranciscaNeural), ver .claude/memory/decisions.md

test/
  widget_test.dart                  # smoke test da Splash (via DebugaOMascoteApp/main.dart)
  helpers/
    test_container.dart             # createTestContainer({overrides})/wrapForTest(container, child) — container Riverpod de teste, já com FakeSoundPlayer
    fake_sound_player.dart          # SoundPlayer de teste
    fake_leaderboard_repository.dart # LeaderboardRepository de teste
    fake_auth_service.dart          # AuthService de teste
  core/progress/
    progress_notifier_test.dart     # unit tests de ProgressNotifier via ProviderContainer (recordWin, sessão, hidratação)
  game/
    program_executor_test.dart      # unit tests do motor de jogo do Mundo 1 (expand/applyStep/evaluateFinal)
    belt_executor_test.dart          # unit tests do motor de jogo do Mundo 2 (expand/applyStep/evaluateFinal)
    scoring_test.dart                # unit tests de computeScore
    level_catalog_test.dart          # as 12 fases de world1Levels são solucionáveis (hintProgram)
    conveyor_level_catalog_test.dart # as 12 fases de world2Levels são solucionáveis (hintProgram)
    predict_output_catalog_test.dart # as 12 fases de world3Levels têm dados consistentes (Mundo 3)
    complete_code_catalog_test.dart  # as 12 fases de world4Levels têm dados consistentes (Mundo 4)
    code_puzzle_checker_test.dart    # unit tests de checkReorder/checkFindBug (Mundo 5)
    code_puzzle_catalog_test.dart    # as 12 fases de world5Levels têm dados consistentes (reorder/findBug)
    leaderboard_scoring_test.dart   # unit tests de computeSessionPoints (Placar do Dia)
  audio/
    app_sounds_test.dart            # mute e roteamento de som/haptic, via FakeSoundPlayer + ProviderContainer
  features/
    maze/gameplay_flow_test.dart            # Mundo 1: joga de verdade (vitória e derrota) e confirma navegação/conteúdo real
    maze/gameplay_tablet_layout_test.dart   # confirma que o tabuleiro do Mundo 1 cresce (layout lado a lado) acima do breakpoint de tablet
    conveyor/conveyor_flow_test.dart         # Mundo 2: mesmo espírito de gameplay_flow_test.dart
    predict_output/predict_output_flow_test.dart # Mundo 3: mesmo espírito, veredito único
    complete_code/complete_code_flow_test.dart   # Mundo 4: mesmo espírito, veredito único
    code_puzzle/code_puzzle_flow_test.dart       # Mundo 5: reorder e findBug, acerto e erro
  screens/                          # telas transversais (sem mundo próprio) — nome do diretório é histórico, não reflete mais lib/screens/ (removido)
    no_overflow_test.dart           # todas as telas em 3 tamanhos de tela (celular pequeno/grande, tablet), sem overflow
    world_select_screen_test.dart   # Seleção de Mundo — mostra os 5 mundos com nome, nenhum "EM BREVE"; cada mundo (já visto, ver Onboarding) navega para sua Seleção de Fases
    tutorial_flow_test.dart         # TutorialView — 1ª vez mostra o slide geral de "o que é programar" antes do mundo; "Próximo" 1º toque revela o texto/2º avança; "Pular"/completar todos os slides navegam e marcam Onboarding; mundo já visto navega direto; botão "?" reabre só os slides daquele mundo
    settings_flow_test.dart         # SettingsView — botão de configurações da Seleção de Mundo abre a tela, toggle de Som, seção "Conta" (criar conta/conectado como/"Sair da conta"), lápis de editar avatar só com conta, ProfileEditView (nome de usuário + carrossel de personagens)
    leaderboard_flow_test.dart      # Placar do Dia + Pesquisa — troféu abre o Placar, convite condicional a sessionScore, formulário só habilita completo, enviar registra e navega, ranking ordena por pontuação
    register_screen_test.dart       # RegisterView — alternar cadastro/login, validação de campos, erro inline, Google, mandatory (sem fechar, com "Continuar sem conta")
    register_gate_test.dart         # Gate de cadastro ao terminar a Trilha 1 — joga de verdade até a última fase do Mundo 3 ("Preveja a Saída", último da Trilha 1); sem conta mostra RegisterView mandatory (com saída); com conta não mostra nada
```

Esta árvore reflete o estado real do código depois da migração para Riverpod + MVVM (2026-09-16, ver `.claude/memory/decisions.md`) — atualizar este arquivo sempre que uma pasta/arquivo novo de `lib/` for criado. Arquivos gerados (`*.g.dart`, `*.freezed.dart`) não são listados aqui — vivem sempre ao lado do arquivo fonte que os gera.
