import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../device_identity.dart';
import 'firestore_progress_repository.dart';
import 'progress_state.dart';

part 'progress_repository.g.dart';

/// Abstração sobre onde o progresso do jogador é persistido — mesmo
/// espírito de `LeaderboardRepository`/`SoundPlayer`: permite um fake nos
/// testes. `fetch()` devolve `null` quando não há dado salvo ou a
/// infraestrutura está indisponível (nunca lança) — nesse caso o jogo
/// continua com o `ProgressState` vazio padrão.
abstract class ProgressRepository {
  Future<ProgressState?> fetch();
  Future<void> save(ProgressState state);
}

@Riverpod(keepAlive: true)
ProgressRepository progressRepository(Ref ref) => FirestoreProgressRepository(ref.watch(deviceIdentityProvider));
