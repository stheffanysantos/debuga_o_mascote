# Regra: Design / Zero Hardcode

Fonte de verdade de valores: `.claude/memory/design-system.md` e `lib/theme/`.

## Proibido
- `Color(0xFF...)` ou `Colors.*` direto fora de `lib/theme/`.
- `TextStyle(fontSize: N, fontWeight: ...)` literal fora de `lib/theme/` — usar um `TextTheme`/constantes nomeadas (ex.: `AppText.title`, `AppText.counter`).
- `EdgeInsets`/tamanhos de botão mágicos repetidos em várias telas — extrair para `lib/theme/` se usado 2+ vezes.

## Obrigatório
- Toda cor nova usada em 2+ lugares vira um token em `lib/theme/` com o mesmo nome usado em `.claude/memory/design-system.md` (`background`, `panel`, `purpleDark`, `purple`, `lilac`, `yellowNeon`, `white`).
- Fonte sempre Nunito (Google Fonts), pesos 800/900 para títulos e números de destaque.
- Todo botão de ação primária usa `yellowNeon`.
- Componente usado por 2+ telas sobe para `lib/widgets/` e entra na tabela de inventário de `.claude/memory/design-system.md` na mesma alteração.
- Alto contraste sempre — o app roda num estande iluminado, não assumir ambiente escuro/controlado.
