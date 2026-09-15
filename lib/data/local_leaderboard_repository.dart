import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/leaderboard_entry.dart';
import 'leaderboard_repository.dart';

/// Implementação real de hoje: guarda o Placar inteiro (todos os dias, sem
/// limite de tempo) como uma lista JSON no `shared_preferences` do
/// aparelho — cada aparelho tem seu próprio Placar (decisão explícita do
/// usuário, ver `.claude/memory/decisions.md`; um backend compartilhado via
/// Firebase é o próximo passo planejado).
class LocalLeaderboardRepository implements LeaderboardRepository {
  static const _storageKey = 'leaderboard_entries';

  @override
  Future<List<LeaderboardEntry>> topToday({int limit = 20}) async {
    final all = await _readAll();
    final now = DateTime.now();
    final today = all.where((e) => e.isFromSameDayAs(now)).toList()..sort((a, b) => b.score.compareTo(a.score));
    return today.take(limit).toList();
  }

  @override
  Future<void> submit(LeaderboardEntry entry) async {
    final all = await _readAll();
    all.add(entry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<List<LeaderboardEntry>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((json) => LeaderboardEntry.fromJson(json as Map<String, dynamic>)).toList();
  }
}
