# Checklist — Tela (Screen)

- [ ] `StatefulWidget`, sem regra de jogo dentro (colisão/vitória/expansão de `Repetir` vivem em `lib/game/`).
- [ ] Zero hardcode de cor/tipografia/espaçamento — tudo via `lib/theme/`.
- [ ] Ação primária (se existir) usa `yellowNeon`.
- [ ] Botões grandes o suficiente para toque em estande (sem áreas de toque apertadas).
- [ ] Componentes visuais repetidos entre telas foram checados contra `.claude/memory/design-system.md` antes de duplicar.
- [ ] Widget test cobrindo o caminho feliz de renderização.
- [ ] `flutter analyze` sem warnings novos.
- [ ] Se a tela participa do fluxo das 5 telas, `.claude/docs/NAVIGATION_FLOW.md` reflete a transição correta.
