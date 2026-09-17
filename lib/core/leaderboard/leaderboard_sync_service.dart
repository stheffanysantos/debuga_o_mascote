import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/leaderboard_entry.dart';
import '../auth/auth_providers.dart';
import '../progress/progress_notifier.dart';
import 'leaderboard_providers.dart';

part 'leaderboard_sync_service.g.dart';

/// Reenvia a entrada do jogador no Placar Geral com o estado atual —
/// chamado uma vez pela `SurveyView` (1ª resposta da pesquisa) e depois
/// automaticamente a cada vitória nova (`RecordLevelWinUseCase`), sem o
/// jogador precisar reabrir a tela do Placar. Só faz sentido chamar quando
/// `ProgressState.hasSubmittedToLeaderboard` já é `true` (ou está prestes a
/// virar, no caso do 1º envio) — `resync()` não faz nada se não for o caso,
/// pra `RecordLevelWinUseCase` poder chamar incondicionalmente a cada
/// vitória sem checar antes. Ver `.claude/memory/decisions.md`.
class LeaderboardSyncService {
  LeaderboardSyncService(this._ref);

  final Ref _ref;

  Future<void> resync() async {
    final progress = _ref.read(progressNotifierProvider);
    if (!progress.hasSubmittedToLeaderboard) return;
    final auth = _ref.read(authServiceProvider);
    if (!auth.hasAccount) return;
    final entry = LeaderboardEntry(
      // Nome de exibição escolhido em `ProfileEditView` (`username`) tem
      // prioridade sobre o nome/e-mail da conta — o jogador pode preferir
      // aparecer no Placar com um apelido em vez do e-mail de login.
      name: progress.username ?? auth.displayName ?? 'Jogador',
      age: progress.surveyAge ?? 0,
      hasProgrammedBefore: progress.surveyHasProgrammedBefore ?? false,
      score: progress.sessionScore,
      updatedAt: DateTime.now(),
      gameCompleted: progress.gameCompleted,
      completedAt: progress.gameCompletedAt,
      avatarId: progress.displayAvatarId,
    );
    await _ref.read(leaderboardRepositoryProvider).submit(entry);
  }
}

@riverpod
LeaderboardSyncService leaderboardSyncService(Ref ref) => LeaderboardSyncService(ref);
