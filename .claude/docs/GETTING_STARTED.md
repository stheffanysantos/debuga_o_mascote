# Getting Started — Debuga o Mascote

## Requisitos
- Flutter SDK instalado (`flutter doctor` sem erros bloqueantes).
- Nenhuma dependência de backend/rede — o app é standalone.

## Rodar o projeto
```
flutter pub get
flutter run
```

## Rodar os testes
```
flutter test
```
Cobre tanto os widget tests de `test/screens/` quanto os unit tests do motor de jogo em `test/game/` (ver `.claude/rules/testing.md`).

## Analisar o código
```
flutter analyze
```

## Onde começar a ler
1. `CLAUDE.md` (raiz) — visão geral e convenções.
2. `.claude/docs/GAME_DESIGN.md` — regras do jogo.
3. `.claude/docs/ARCHITECTURE.md` e `.claude/docs/FOLDER_STRUCTURE.md` — como o código é organizado.
4. `.claude/docs/NAVIGATION_FLOW.md` — as 5 telas e como se conectam.
