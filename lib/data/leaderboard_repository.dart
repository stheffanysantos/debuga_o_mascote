import '../models/leaderboard_entry.dart';

/// Abstração sobre "onde o Placar do Dia mora" — mesmo espírito de
/// `SoundPlayer` (`lib/audio/sound_player.dart`): permite um fake nos
/// testes e, no futuro, trocar a implementação local (`LocalLeaderboardRepository`)
/// por uma no Firebase sem mudar nenhuma tela. Ver
/// `.claude/memory/decisions.md`.
abstract class LeaderboardRepository {
  /// Entradas de hoje, ordenadas da maior pontuação para a menor.
  Future<List<LeaderboardEntry>> topToday({int limit = 20});

  Future<void> submit(LeaderboardEntry entry);
}
