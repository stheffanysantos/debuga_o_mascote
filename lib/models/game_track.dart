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

/// A Trilha 1 tem os Mundos 1 e 2 (sequência e decisão, sem código de
/// verdade); a Trilha 2 (nova, "ponte" pedida pelo usuário — o salto direto
/// da Trilha 1 pra sintaxe de código real era grande demais pro público-
/// alvo) tem os Mundos 3 e 4 (programação em blocos visuais, sem sintaxe,
/// resolvendo problemas numéricos reais); a Trilha 3 (era Trilha 2) tem os
/// Mundos 5, 6 e 7 ("Preveja a Saída", "Complete o Código" e "Modo Debug",
/// todos manipulando código de verdade). Ver `.claude/memory/decisions.md`.
/// Trilhas futuras sem mundos ainda entram como `comingSoon: true`,
/// `worlds: []` (mesmo padrão já usado por `GameWorld.comingSoon`).
final tracks = <GameTrack>[
  GameTrack(
    number: 1,
    name: 'Lógica em Apuros',
    subtitle: 'Sequência e decisão',
    comingSoon: false,
    worlds: [worlds[0], worlds[1]],
  ),
  GameTrack(
    number: 2,
    name: 'Construtores de Lógica',
    subtitle: 'Programação em blocos, resolvendo problemas de verdade',
    comingSoon: false,
    worlds: [worlds[2], worlds[3]],
  ),
  GameTrack(
    number: 3,
    name: 'Modo Programador',
    subtitle: 'Leia, complete e depure código de verdade',
    comingSoon: false,
    worlds: [worlds[4], worlds[5], worlds[6]],
  ),
];
