# Checklist — Revisão Final de Código

- [ ] `flutter analyze` limpo.
- [ ] `flutter test` passando (unit tests de `lib/game/` + widget tests de telas alteradas).
- [ ] `lib/game/` e `lib/models/` não importam `package:flutter/...` (ver `.claude/rules/architecture.md`).
- [ ] Nenhuma regra de jogo implementada dentro de um `Widget`.
- [ ] Zero hardcode de cor/tipografia/espaçamento fora de `lib/theme/` (ver `.claude/rules/design.md`).
- [ ] Nomenclatura de arquivos/classes segue `.claude/rules/naming.md`.
- [ ] Componente novo (se houver) checado contra duplicação em `.claude/memory/design-system.md` e, se compartilhado, adicionado ao inventário.
- [ ] Mudança de regra de jogo (se houver) refletida em `.claude/docs/GAME_DESIGN.md` antes do código.
- [ ] Decisão arquitetural relevante (se houver) registrada em `.claude/memory/decisions.md`.
