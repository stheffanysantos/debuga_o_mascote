import '../../models/leaderboard_entry.dart';

/// Abstração sobre "onde o Placar Geral mora" — mesmo espírito de
/// `SoundPlayer` (`lib/core/audio/sound_player.dart`): permite um fake nos
/// testes e trocar a implementação local por uma no Firebase sem mudar
/// nenhuma tela. Ver `.claude/memory/decisions.md`.
///
/// Sem recorte de dia (pedido explícito do usuário) — `submit` faz
/// upsert por jogador (1 entrada por pessoa, atualizada a cada vitória via
/// `LeaderboardSyncService`, não um histórico por envio).
abstract class LeaderboardRepository {
  /// Quem ainda não zerou o jogo (`gameCompleted == false`), ordenados da
  /// maior pontuação para a menor.
  Future<List<LeaderboardEntry>> topOverall({int limit = 20});

  /// Quem já zerou o jogo (`gameCompleted == true`), ordenados por quem
  /// terminou primeiro.
  Future<List<LeaderboardEntry>> completedGame({int limit = 20});

  Future<void> submit(LeaderboardEntry entry);
}
