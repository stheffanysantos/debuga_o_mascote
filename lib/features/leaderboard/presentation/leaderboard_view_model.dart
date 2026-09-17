import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/leaderboard/leaderboard_providers.dart';
import '../../../models/leaderboard_entry.dart';

part 'leaderboard_view_model.g.dart';

/// As duas listas do Placar (`LeaderboardView` alterna entre elas por
/// abas) — quem ainda não zerou o jogo, e quem já zerou.
typedef LeaderboardData = ({List<LeaderboardEntry> overall, List<LeaderboardEntry> completedGame});

/// Carrega o Placar Geral — estado async real (ver plano de migração, §4:
/// "leaderboard ganha ViewModel de verdade"). Sem `LeaderboardState`
/// próprio: `AsyncValue<LeaderboardData>` já modela loading/data/erro
/// sozinho, embrulhar isso numa classe `@freezed` só duplicaria o que o
/// riverpod_generator já gera de graça para um `build()` que devolve
/// `Future<T>`. `autoDispose` (padrão) é o comportamento certo — o ranking é
/// só desta tela, não precisa sobreviver depois que ela fecha.
@riverpod
class LeaderboardViewModel extends _$LeaderboardViewModel {
  @override
  Future<LeaderboardData> build() async {
    final repository = ref.read(leaderboardRepositoryProvider);
    final overall = await repository.topOverall();
    final completedGame = await repository.completedGame();
    return (overall: overall, completedGame: completedGame);
  }
}
