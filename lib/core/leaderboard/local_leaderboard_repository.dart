import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/leaderboard_entry.dart';
import 'leaderboard_repository.dart';

/// Fallback local (sem Firebase configurado/disponível): guarda o Placar
/// inteiro como uma lista JSON no `shared_preferences` do aparelho — cada
/// aparelho tem seu próprio Placar nesse modo. Uma entrada por jogador
/// (identificado pelo `name`, já que não há UID de verdade sem Firebase
/// Auth) — `submit` substitui a entrada existente com o mesmo nome em vez
/// de acrescentar, mesmo espírito de upsert de `FirebaseLeaderboardRepository`
/// (ver `.claude/memory/decisions.md`).
class LocalLeaderboardRepository implements LeaderboardRepository {
  static const _storageKey = 'leaderboard_entries';

  @override
  Future<List<LeaderboardEntry>> topOverall({int limit = 20}) async {
    final all = await _readAll();
    final entries = all.where((e) => !e.gameCompleted).toList()..sort((a, b) => b.score.compareTo(a.score));
    return entries.take(limit).toList();
  }

  @override
  Future<List<LeaderboardEntry>> completedGame({int limit = 20}) async {
    final all = await _readAll();
    final entries = all.where((e) => e.gameCompleted).toList()
      ..sort((a, b) => (a.completedAt ?? a.updatedAt).compareTo(b.completedAt ?? b.updatedAt));
    return entries.take(limit).toList();
  }

  @override
  Future<void> submit(LeaderboardEntry entry) async {
    final all = await _readAll();
    all.removeWhere((e) => e.name == entry.name);
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
