import 'package:debuga_o_mascote/core/leaderboard/leaderboard_repository.dart';
import 'package:debuga_o_mascote/models/leaderboard_entry.dart';

/// [LeaderboardRepository] de teste — guarda tudo em memória, sem tocar o
/// `shared_preferences`/Firestore real (mesmo espírito de `FakeSoundPlayer`).
/// `submit` faz upsert por nome (mesma simplificação de
/// `LocalLeaderboardRepository` — sem UID de verdade em teste, o nome já
/// basta pra distinguir jogadores nos cenários testados).
class FakeLeaderboardRepository implements LeaderboardRepository {
  final List<LeaderboardEntry> entries = [];

  @override
  Future<void> submit(LeaderboardEntry entry) async {
    entries.removeWhere((e) => e.name == entry.name);
    entries.add(entry);
  }

  @override
  Future<List<LeaderboardEntry>> topOverall({int limit = 20}) async {
    final overall = entries.where((e) => !e.gameCompleted).toList()..sort((a, b) => b.score.compareTo(a.score));
    return overall.take(limit).toList();
  }

  @override
  Future<List<LeaderboardEntry>> completedGame({int limit = 20}) async {
    final completed = entries.where((e) => e.gameCompleted).toList()
      ..sort((a, b) => (a.completedAt ?? a.updatedAt).compareTo(b.completedAt ?? b.updatedAt));
    return completed.take(limit).toList();
  }
}
