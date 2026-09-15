# Regra: Nomenclatura

## Imports
- Import absoluto (`package:debuga_o_mascote/...`) para qualquer coisa fora do arquivo atual, exceto `part`/`part of` (raro neste projeto, sem `freezed`/`build_runner` por enquanto).

## Arquivos
- Sempre `snake_case.dart`.
- Sufixo reflete o tipo: `_screen.dart`, `_widget.dart`, `_model.dart`, `_test.dart`. O motor de jogo não tem sufixo fixo (ex.: `program_executor.dart`, `board.dart`) — nome descritivo do que faz.

## Classes

| Tipo | Padrão | Exemplo |
|---|---|---|
| Model | `PascalCase`, sem sufixo | `Level`, `Block`, `Program`, `Progress` |
| Screen | `PascalCase` + `Screen` | `SplashScreen`, `LevelSelectScreen`, `GameplayScreen`, `VictoryScreen`, `FailureScreen` |
| Widget de tela | `PascalCase`, descritivo | `LevelCard`, `CommandButton`, `ProgramBlock` |
| Widget de Design System | `PascalCase`, sem prefixo obrigatório (projeto pequeno) — mas nome único e descritivo | `AppPrimaryButton`, `StarRow` |
| Motor de jogo | `PascalCase`, descritivo | `ProgramExecutor`, `Board`, `GameResult` |
| Enum | `PascalCase`, valores `camelCase` | `BlockType { walk, turnLeft, turnRight, repeat }` |

## Fases (`Level`)
- `id` estável e único (ex.: `world1_level3`), nunca reaproveitado mesmo se a fase for removida/reordenada — evita corromper `Progress` salvo.
