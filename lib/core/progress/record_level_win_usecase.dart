import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../game/leaderboard_scoring.dart';
import '../../game/scoring.dart';
import '../../models/level.dart';
import '../leaderboard/leaderboard_sync_service.dart';
import 'progress_notifier.dart';

part 'record_level_win_usecase.g.dart';

/// Resultado de [RecordLevelWinUseCase] — só o que o chamador precisa saber
/// pra decidir navegação (recapitulação de fim de Mundo, gate de cadastro).
class RecordLevelWinResult {
  final bool worldJustCompleted;

  const RecordLevelWinResult({required this.worldJustCompleted});
}

/// Único caso de uso de verdade desta migração (ver
/// `C:\Users\XProcess\.claude\plans\encapsulated-whistling-peach.md`, seção
/// 3) — encapsula a orquestração que os 5 motores de Gameplay duplicavam:
/// registrar a vitória (`ProgressNotifier.recordWin`), somar pontos de
/// sessão só na 1ª vez que a fase é vencida, e calcular se o Mundo acabou de
/// ficar 100% completo agora (comparando antes/depois de `recordWin`).
/// `blocksUsedOrAttempts`/`score` são genéricos entre motores — Mundos 1/2
/// contam blocos (`computeScore`), Mundos 3/4/5 contam tentativas
/// (`computeCodePuzzleScore`), mas os dois devolvem o mesmo `ScoreResult`.
class RecordLevelWinUseCase {
  RecordLevelWinUseCase(this._ref);

  final Ref _ref;

  RecordLevelWinResult call({
    required String levelId,
    required GameWorld world,
    required ScoreResult score,
    required int blocksUsedOrAttempts,
    required int elapsedSeconds,
  }) {
    final progressNotifier = _ref.read(progressNotifierProvider.notifier);
    final progressBefore = _ref.read(progressNotifierProvider);
    final levelIds = world.levels.map((l) => l.id);
    // Calculado antes de `recordWin` marcar esta fase como concluída — só
    // assim dá pra saber se o Mundo/o jogo acabou de ficar 100% completo
    // agora (e não já estava antes, num replay).
    final wasWorldCompleteBefore = progressBefore.isWorldCompleted(levelIds);
    final wasGameCompleteBefore = progressBefore.isGameCompleted();
    final isFirstWin = !progressBefore.isCompleted(levelId);

    progressNotifier.recordWin(levelId, stars: score.stars, blocksUsed: blocksUsedOrAttempts, points: score.points);
    if (isFirstWin) {
      progressNotifier.addSessionPoints(computeSessionPoints(worldNumber: world.number, elapsedSeconds: elapsedSeconds));
    }

    final progressAfter = _ref.read(progressNotifierProvider);
    final worldJustCompleted = !wasWorldCompleteBefore && progressAfter.isWorldCompleted(levelIds);
    // "Zerar o jogo" (100% das 2 Trilhas) tira o jogador do Placar Geral e
    // coloca na lista separada de quem zerou — pedido explícito do usuário,
    // ver `.claude/memory/decisions.md`.
    if (!wasGameCompleteBefore && progressAfter.isGameCompleted()) {
      progressNotifier.markGameCompleted();
    }
    // Reenvia a entrada do Placar Geral com o estado atual — não faz nada se
    // o jogador nunca respondeu a pesquisa (`resync` checa isso sozinho).
    // Fire-and-forget: nunca deve atrasar a navegação de resultado da fase.
    unawaited(_ref.read(leaderboardSyncServiceProvider).resync());

    return RecordLevelWinResult(worldJustCompleted: worldJustCompleted);
  }
}

@riverpod
RecordLevelWinUseCase recordLevelWinUseCase(Ref ref) => RecordLevelWinUseCase(ref);
