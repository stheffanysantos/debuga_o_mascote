# CLAUDE.md — Debuga o Mascote

## 1. Visão do Produto

Mini-jogo educativo de lógica de programação em Flutter (celular e tablet), para o estande da LiCode em feira de tecnologia. Estilo casual e fofo, flat design, alto contraste (ambiente iluminado de estande), interface pensada para toque.

O jogador monta uma sequência de comandos (**Programa**) para guiar o **Mascote** por um labirinto em grade 6×6 (**Tabuleiro**) até um **Alvo** `</>`. Regras completas do jogo: `.claude/docs/GAME_DESIGN.md`.

### Princípios de produto
- Sem instrução prévia: um visitante do estande que nunca viu o jogo precisa entender o que fazer só olhando a tela.
- Sessões curtas, feedback imediato e celebração forte na vitória — é a experiência que fica na cabeça de quem passou pelo estande.
- Falha nunca é punitiva: sempre com motivo claro e uma dica de correção.

## 2. Stack Técnica

Ver `.claude/memory/tech-stack.md` para a tabela completa e o porquê de cada escolha. Resumo:
- Flutter (celular/tablet/web), Firebase (Auth anônimo/email/Google + Firestore) para Placar do Dia e progresso.
- Gerenciamento de estado: Riverpod 2.x + MVVM + Clean Architecture pragmática (com `riverpod_generator`/`freezed`) — ver `.claude/memory/decisions.md`, entrada de 2026-09-16.
- Fonte Nunito (Google Fonts), pesos 800/900.

## 3. Arquitetura

```
lib/models/    Level, Block, LevelProgress, GameTrack — entidades de domínio, Dart puro
lib/game/      motores de execução por mundo (interpretador do Programa) — Dart puro
lib/core/      infraestrutura transversal via provider (progress/onboarding/auth/leaderboard/audio)
lib/widgets/   componentes de Design System reutilizados por 2+ features
lib/theme/     paleta, tipografia, tokens
lib/features/  um diretório por mundo/tela, cada um com presentation/{view,view_model,state}
```

Regra de dependência: `models/`/`game/` nunca importam Flutter nem Riverpod; `features/`/`widgets/` dependem de `models/`/`game/`/`core/`/`theme/`, nunca o contrário; nenhuma regra de jogo vive dentro de um `Widget`/ViewModel. Detalhes: `.claude/rules/architecture.md` e `.claude/docs/ARCHITECTURE.md`.

## 4. Estrutura de Diretórios

Ver `.claude/docs/FOLDER_STRUCTURE.md` para a árvore completa de `lib/`.

## 5. Convenções de Nomenclatura

Ver `.claude/rules/naming.md`. Resumo: arquivos `snake_case.dart` com sufixo por tipo (`_view.dart`, `_view_model.dart`, `_state.dart`, `_widget.dart`, `_repository.dart`, `_test.dart`); classes `PascalCase`.

## 6. Design System

Ver `.claude/rules/design.md` (normativo — zero hardcode) e `.claude/memory/design-system.md` (paleta, tipografia, inventário de componentes, expressões do Mascote). Ação primária sempre em amarelo neon (`yellowNeon`).

## 7. As 5 Telas

Splash/Menu → Seleção de Fases → Gameplay → Vitória/Tentativa Falha. Fluxo completo e detalhe de cada tela: `.claude/docs/NAVIGATION_FLOW.md`.

## 8. Como Gerar Código

Use os comandos em `.claude/commands/`:
- `/generate-screen` — tela nova.
- `/generate-level` — fase nova (valida solubilidade dentro do `maxBlocks`).
- `/generate-widget` — componente reutilizável novo.
- `/review-ui` — checklist de UI/UX numa tela existente.

Para decisões que exigem profundidade, delegue aos agentes de `.claude/agents/` — ver `.claude/docs/AGENTS_WORKFLOW.md` para quando usar qual.

## 9. Como Escrever Testes

Ver `.claude/rules/testing.md`. Resumo: `flutter_test` para tudo — unit tests do motor de jogo (`lib/game/`) e widget tests das telas. Toda fase nova precisa de um teste provando que é solucionável (`.claude/reviews/checklist-level.md`).

## 10. Commits

Ver `.claude/rules/git-workflow.md`. Sem hooks automáticos (ver `.claude/memory/decisions.md`) — rodar `flutter analyze`/`flutter test` e conferir `.claude/reviews/code-review-checklist.md` antes de commitar é responsabilidade de quem commita.

## 11. Como Evitar Código Duplicado

Antes de criar um widget ou uma regra de jogo nova, consultar `.claude/memory/design-system.md` (componentes) e `.claude/docs/GAME_DESIGN.md` (regras) — se algo equivalente já existe, estender em vez de duplicar.

## 12. Qualidade — o que a IA nunca deve gerar aqui

- Cor/tipografia/espaçamento hardcoded fora de `lib/theme/`.
- Regra de jogo (colisão, vitória, expansão de `Repetir`) dentro de um `Widget`.
- `lib/models/` ou `lib/game/` importando `package:flutter/...` ou `package:flutter_riverpod/...`.
- GetX, Riverpod, Provider ou qualquer pacote de state management sem antes atualizar `.claude/memory/decisions.md` com o porquê da mudança.
- Hooks Python/scripts de bloqueio automático em `.claude/settings.json` (decisão deliberada, ver `.claude/memory/decisions.md`) — sem confirmar com o usuário antes.

## 13. Estrutura de IA do Projeto

```
.claude/
  settings.json     # sem hooks — permissões apenas
  agents/           # 4 subagentes especializados (game logic, UI, UX, code review)
  commands/         # slash commands (/generate-screen, /generate-level, /generate-widget, /review-ui)
  memory/           # memória persistente (decisões, glossário, design system, stack)
  plans/            # MVP e roadmap
  rules/            # regras obrigatórias por tema
  reviews/          # checklists por tipo de artefato
  templates/        # esqueletos de código Dart
  docs/             # documentação viva
```

Ver `.claude/docs/AGENTS_WORKFLOW.md` para como os agentes colaboram, e `.claude/docs/README.md` para o índice da documentação.

> **Nota de origem**: esta estrutura de `.claude/` é inspirada na organização usada no projeto `xp_servico` (GetX + Clean Architecture, hooks Python), simplificada aqui para o porte real deste projeto — um mini-jogo standalone de estande, sem backend, sem sincronização, sem equipe grande. Ver `.claude/memory/decisions.md` para o porquê de cada corte.

## 14. Memória Persistente — imports automáticos

@.claude/memory/decisions.md
@.claude/memory/domain-glossary.md
