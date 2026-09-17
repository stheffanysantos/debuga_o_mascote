# Regra: Nomenclatura

## Imports
- Import absoluto (`package:debuga_o_mascote/...`) para qualquer coisa fora do arquivo atual, exceto `part`/`part of` — usado hoje pelos arquivos gerados de `@freezed`/`@riverpod` (`*.freezed.dart`, `*.g.dart`), sempre comitados junto do arquivo fonte (ver `.claude/rules/git-workflow.md`).

## Arquivos
- Sempre `snake_case.dart`.
- Sufixo reflete o tipo — ver tabela abaixo. O motor de jogo e as entidades de domínio não têm sufixo fixo (ex.: `program_executor.dart`, `level.dart`) — nome descritivo do que fazem/representam.

## Classes

| Camada | Sufixo de arquivo | Padrão de classe | Exemplo |
|---|---|---|---|
| Entidade de domínio (`models/`) | sem sufixo | `PascalCase` | `level.dart` → `Level`, `LevelProgress` |
| Motor de jogo (`game/`) | sem sufixo fixo, descritivo | `PascalCase` | `program_executor.dart` → `ProgramExecutor` |
| View (apresentação) | `_view.dart` | `PascalCase` + `View` | `gameplay_view.dart` → `GameplayView` |
| ViewModel (apresentação) | `_view_model.dart` | `PascalCase` + `ViewModel`, `@riverpod` | `gameplay_view_model.dart` → `GameplayViewModel` |
| Estado (apresentação) | `_state.dart` | `PascalCase` + `State`, `@freezed` | `gameplay_state.dart` → `GameplayState` |
| Efeito/sinal de navegação | mora junto do `_state.dart` | `PascalCase` + `Effect`, `@freezed sealed` | `GameplayEffect` |
| Estado transversal (`core/`) | `_notifier.dart` | `PascalCase` + `Notifier`, `@riverpod` (`keepAlive: true`) | `progress_notifier.dart` → `ProgressNotifier` |
| Dado do estado transversal | `_state.dart` | `PascalCase` + `State`, `@freezed` | `progress_state.dart` → `ProgressState` |
| Repositório (interface/impl) | `_repository.dart` | `PascalCase` + `Repository` | `firebase_leaderboard_repository.dart` → `FirebaseLeaderboardRepository` |
| Use case (raro — só onde há duplicação real entre features) | `_usecase.dart` | `PascalCase` + `UseCase` | `record_level_win_usecase.dart` → `RecordLevelWinUseCase` |
| Widget de Design System (`widgets/`) | `_widget.dart` | `PascalCase`, sem prefixo obrigatório — nome único e descritivo | `hard_shadow_box_widget.dart` → `HardShadowBox` |
| Enum | sem sufixo fixo | `PascalCase`, valores `camelCase` | `BlockType { walk, turnLeft, turnRight, repeat }` |

Telas triviais sem lógica de orquestração (`WorldSelectView`, `SplashView`, `StageSelectView` de cada mundo, `SurveyView`) **não ganham `_view_model.dart`/`_state.dart`** — são `ConsumerWidget`/`ConsumerStatefulWidget` lendo `ref.watch(...)` direto no `build()`. Ver `.claude/rules/architecture.md`, "Quando dar ViewModel a uma tela".

## Fases (`Level`)
- `id` estável e único (ex.: `world1_level3`), nunca reaproveitado mesmo se a fase for removida/reordenada — evita corromper o progresso salvo (`ProgressState`, sincronizado com o Firestore).
