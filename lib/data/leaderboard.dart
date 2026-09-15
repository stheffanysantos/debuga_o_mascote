import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/leaderboard_entry.dart';
import 'firebase_device_identity.dart';
import 'firebase_leaderboard_repository.dart';
import 'leaderboard_repository.dart';
import 'local_leaderboard_repository.dart';

/// Instância única e compartilhada do Placar do Dia (`Leaderboard.instance`)
/// — mesmo padrão de `AppSounds.instance`: resolve a implementação real só
/// na 1ª chamada, nunca na construção do singleton, e expõe um setter
/// `@visibleForTesting` pra trocar por um fake nos testes.
class Leaderboard {
  Leaderboard._();

  static final Leaderboard instance = Leaderboard._();

  LeaderboardRepository? _repository;

  @visibleForTesting
  set repository(LeaderboardRepository value) => _repository = value;

  LeaderboardRepository get _resolvedRepository => _repository ??= _defaultRepository();

  /// Firebase configurado e inicializado com sucesso (ver `main.dart`) →
  /// Firestore, compartilhado entre aparelhos. Caso contrário (sem projeto
  /// configurado para esta plataforma, sem internet no boot) → cai para o
  /// armazenamento local do aparelho, sem quebrar o Placar.
  LeaderboardRepository _defaultRepository() {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseLeaderboardRepository(FirebaseDeviceIdentity());
      }
    } catch (_) {
      // Plugin do Firebase indisponível nesta plataforma/ambiente de teste.
    }
    return LocalLeaderboardRepository();
  }

  Future<List<LeaderboardEntry>> topToday({int limit = 20}) => _resolvedRepository.topToday(limit: limit);

  Future<void> submit(LeaderboardEntry entry) => _resolvedRepository.submit(entry);

  /// Só para testes — volta a resolver a implementação real na próxima
  /// chamada.
  @visibleForTesting
  void resetForTest() => _repository = null;
}
