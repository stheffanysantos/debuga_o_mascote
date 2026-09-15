# Stack Técnica — Debuga o Mascote

| Peça | Escolha | Por quê |
|---|---|---|
| Framework | Flutter (projeto criado via `flutter create`, sem flavors) | Alvo é celular e tablet no estande da LiCode; um só codebase. |
| Linguagem | Dart | Padrão Flutter. |
| Gerenciamento de estado | `setState` em `StatefulWidget` | Ver decisão em `.claude/memory/decisions.md` — 5 telas, escopo pequeno, GetX/Riverpod seriam complexidade desnecessária. |
| Lógica de jogo | Interpretador próprio em `lib/game/`, puro Dart (sem import de Flutter) | Permite testar a execução do Programa (unit test) sem precisar de widget test. |
| Fonte | Google Fonts — Nunito (pesos 800/900), via pacote `google_fonts` | Definido no resumo visual do projeto. |
| Ícones | `flutter_svg`, com os `<path>` do design embutidos como SVG inline em `lib/theme/app_icons.dart` | Fidelidade visual exata aos ícones do Claude Design, sem depender de um icon font genérico. |
| Persistência de progresso | **A definir** (candidato: `shared_preferences`) | Ver `.claude/memory/decisions.md` — não há login nem backend; só precisa guardar estrelas/melhor contagem localmente. |
| Backend/rede | Nenhum | App standalone de estande, sem conectividade necessária. |
| Testes | `flutter_test` para tudo (widget tests das telas e unit tests do motor de jogo) | Evita adicionar `package:test` como dependência extra — `flutter_test` já cobre `test()`/`expect()` para lógica pura. Ver `.claude/rules/testing.md`. |

Nenhuma dependência além do padrão (`cupertino_icons`, `flutter_lints`) foi adicionada ainda além do necessário para fonte/persistência acima — atualizar esta tabela ao adicionar um pacote novo ao `pubspec.yaml`.
