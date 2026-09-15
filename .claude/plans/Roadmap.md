# Roadmap — Debuga o Mascote

Itens fora do escopo do MVP (`.claude/plans/MVP.md`), na ordem aproximada de prioridade após a feira.

## Curto prazo
- ~~**Layout de tablet**~~ — concluído em 2026-09-09: `GameplayScreen` (Mundo 1) alterna entre layout empilhado (celular) e lado a lado (tablet, ≥700px de largura) via `LayoutBuilder`. Ver `.claude/memory/decisions.md`. **Pendente**: `ConveyorGameplayScreen` (Mundo 2, adicionada em 2026-09-09) e `CodePuzzleGameplayScreen` (Mundo 3, adicionada em 2026-09-09) ainda usam só o layout empilhado em qualquer largura — replicar o mesmo padrão lado a lado (Mundo 2: esteira à esquerda, "Seu Programa"/comandos/Play à direita; Mundo 3: banco de linhas/código à esquerda, "Sua sequência"/Confirmar à direita) ficou fora do escopo das Etapas 2/3 por tempo, não é bloqueante (as telas não estouram em tablet, só não aproveitam a largura extra).
- ~~**Sons e haptics**~~ — concluído em 2026-09-08: `lib/audio/` (`AppSounds`), pacote `audioplayers`, SFX sintetizado (`tool/generate_sfx.py`), botão de mute na Splash/Gameplay/Vitória/Falha. Ver `.claude/memory/decisions.md`.
- **Decisão de persistência**: fechar se/como salvar `Progress` localmente (ver `.claude/memory/decisions.md`).
- **Remover o `dependency_overrides: firebase_core_web: 3.10.0`** (ver `.claude/memory/decisions.md`) assim que sair uma versão nova do pacote com o fix de [flutterfire#18611](https://github.com/firebase/flutterfire/issues/18611) publicada no pub.dev — de vez em quando rodar `flutter pub upgrade firebase_core_web` (ou remover o override e `flutter pub get`) pra checar.
- **Login Google no iOS — falta o passo no Xcode**: `ios/Runner/GoogleService-Info.plist` já existe no repo e `Info.plist` já tem o `CFBundleURLTypes` certo (ver `.claude/memory/decisions.md`, entrada "Cadastro real"), mas o arquivo ainda não está registrado no projeto Xcode (`project.pbxproj`) — isso só dá pra fazer num Mac com Xcode instalado (não neste ambiente Windows). Ao abrir `ios/Runner.xcworkspace` no Xcode pela 1ª vez, arrastar `GoogleService-Info.plist` pro target "Runner" ("Copy items if needed" marcado). Sem isso, o app iOS funciona normalmente (email/senha incluído) — só o login Google no iOS específico fica indisponível.

## Médio prazo
- **Mais mundos**: novas 12 fases por mundo, dificuldade crescente (tabuleiros maiores, mais paredes).
- **Novos comandos**: candidatos a avaliar — `Se Parede à Frente`, `Enquanto`, variável de contagem livre em vez de fixa em 3×. Qualquer comando novo exige atualizar `.claude/docs/GAME_DESIGN.md` e `.claude/memory/domain-glossary.md` antes de implementar.

## Não priorizado / avaliar depois
- Editor de fases dentro do próprio app (hoje fases são dados estáticos criados via `/generate-level`).
