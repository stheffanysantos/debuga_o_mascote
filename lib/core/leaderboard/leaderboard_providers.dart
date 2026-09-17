import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../device_identity.dart';
import 'firebase_leaderboard_repository.dart';
import 'leaderboard_repository.dart';
import 'local_leaderboard_repository.dart';

part 'leaderboard_providers.g.dart';

/// Firebase configurado e inicializado com sucesso (ver `main.dart`) →
/// Firestore, compartilhado entre aparelhos. Caso contrário (sem projeto
/// configurado para esta plataforma, sem internet no boot) → cai para o
/// armazenamento local do aparelho, sem quebrar o Placar.
@Riverpod(keepAlive: true)
LeaderboardRepository leaderboardRepository(Ref ref) {
  try {
    if (Firebase.apps.isNotEmpty) {
      return FirebaseLeaderboardRepository(ref.watch(deviceIdentityProvider));
    }
  } catch (_) {
    // Plugin do Firebase indisponível nesta plataforma/ambiente de teste.
  }
  return LocalLeaderboardRepository();
}
