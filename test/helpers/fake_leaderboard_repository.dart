import 'package:debuga_o_mascote/data/leaderboard_repository.dart';
import 'package:debuga_o_mascote/models/leaderboard_entry.dart';

/// [LeaderboardRepository] de teste — guarda tudo em memória, sem tocar o
/// `shared_preferences` real (mesmo espírito de `FakeSoundPlayer`).
class FakeLeaderboardRepository implements LeaderboardRepository {
  final List<LeaderboardEntry> entries = [];

  @override
  Future<void> submit(LeaderboardEntry entry) async => entries.add(entry);

  @override
  Future<List<LeaderboardEntry>> topToday({int limit = 20}) async {
    final now = DateTime.now();
    final today = entries.where((e) => e.isFromSameDayAs(now)).toList()..sort((a, b) => b.score.compareTo(a.score));
    return today.take(limit).toList();
  }
}
