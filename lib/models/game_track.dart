import 'level.dart';

/// Uma Trilha agrupa ~3 Mundos, no estilo "seções" de apps de fases
/// (ex. Duolingo) — exibida como mapa em zigue-zague, um nível acima da
/// Seleção de Mundo. Ver `.claude/memory/decisions.md`.
class GameTrack {
  final int number;

  /// Título grande mostrado na Seleção de Trilha (ex.: "Lógica em Apuros").
  final String name;

  /// Frase curta descrevendo a trilha, mostrada abaixo do título.
  final String subtitle;

  /// `true` enquanto a trilha ainda não tem mundos de verdade — aparece
  /// como "EM BREVE" e não é tocável, independente de progresso.
  final bool comingSoon;

  final List<GameWorld> worlds;

  const GameTrack({
    required this.number,
    required this.name,
    required this.subtitle,
    required this.comingSoon,
    required this.worlds,
  });
}

/// A Trilha 1 tem os Mundos 1, 2 e 3 (sequência, decisão e leitura de
/// código — "Preveja a Saída" é a ponte antes da Trilha 2, pedido explícito
/// do usuário); a Trilha 2 tem os Mundos 4 e 5 ("Complete o Código" e "Modo
/// Debug", ambos manipulando código de verdade). Ver
/// `.claude/memory/decisions.md`. Trilhas futuras sem mundos ainda entram
/// como `comingSoon: true`, `worlds: []` (mesmo padrão já usado por
/// `GameWorld.comingSoon`).
final tracks = <GameTrack>[
  GameTrack(
    number: 1,
    name: 'Lógica em Apuros',
    subtitle: 'Sequência, decisão e leitura de código',
    comingSoon: false,
    worlds: [worlds[0], worlds[1], worlds[2]],
  ),
  GameTrack(
    number: 2,
    name: 'Modo Programador',
    subtitle: 'Complete e depure código de verdade',
    comingSoon: false,
    worlds: [worlds[3], worlds[4]],
  ),
];
