import 'level.dart';
import 'progress.dart';

/// Uma Trilha agrupa ~3 Mundos, no estilo "seções" de apps de fases
/// (ex. Duolingo) — exibida como mapa em zigue-zague, um nível acima da
/// Seleção de Mundo. Ver `.claude/memory/decisions.md`.
class GameTrack {
  final int number;

  /// Título grande mostrado na Seleção de Trilha (ex.: "Fundamentos").
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

/// A Trilha 1 reaproveita os 3 Mundos já existentes (`worlds`,
/// `lib/models/level.dart`) sem nenhuma mudança de conteúdo — só a
/// reestruturação de "3 mundos soltos" pra "3 mundos dentro de uma trilha".
/// Trilhas futuras entram aqui como `comingSoon: true`, sem mundos ainda
/// (mesmo padrão já usado por `GameWorld.comingSoon`).
final tracks = <GameTrack>[
  GameTrack(
    number: 1,
    name: 'Fundamentos',
    subtitle: 'Sequência, decisão e leitura de código',
    comingSoon: false,
    worlds: worlds,
  ),
  const GameTrack(
    number: 2,
    name: 'Em breve',
    subtitle: 'Novos desafios chegando',
    comingSoon: true,
    worlds: [],
  ),
];

/// Trilha inteira completa — todos os seus Mundos com 100% das fases
/// concluídas. Usado para saber quando exigir cadastro (ver
/// `.claude/memory/decisions.md`).
bool isTrackCompleted(GameTrack track) =>
    track.worlds.every((w) => Progress.instance.isWorldCompleted(w.levels.map((l) => l.id)));
