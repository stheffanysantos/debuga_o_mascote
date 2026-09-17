import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/progress/progress_notifier.dart';
import 'package:debuga_o_mascote/core/progress/progress_repository.dart';
import 'package:debuga_o_mascote/core/progress/progress_state.dart';
import 'package:debuga_o_mascote/models/progress.dart';

/// `ProgressNotifier` (`lib/core/progress/progress_notifier.dart`) —
/// substitui `test/models/progress_test.dart` (a classe `Progress` foi
/// removida na migração pra Riverpod, ver
/// `C:\Users\XProcess\.claude\plans\encapsulated-whistling-peach.md`).
/// Construído via `ProviderContainer` puro — sem pump de widget, ainda
/// rápido como um unit test de verdade.
class _FakeProgressRepository implements ProgressRepository {
  ProgressState? seeded;
  ProgressState? lastSaved;

  @override
  Future<ProgressState?> fetch() async => seeded;

  @override
  Future<void> save(ProgressState state) async => lastSaved = state;
}

void main() {
  test('recordWin mantém o melhor resultado (mais estrelas, menos blocos, mais pontos) numa fase já vencida', () async {
    final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(_FakeProgressRepository())]);
    addTearDown(container.dispose);
    final notifier = container.read(progressNotifierProvider.notifier);

    notifier.recordWin('fase1', stars: 2, blocksUsed: 8, points: 150);
    notifier.recordWin('fase1', stars: 3, blocksUsed: 5, points: 300); // melhor resultado — substitui
    notifier.recordWin('fase1', stars: 1, blocksUsed: 10, points: 50); // pior resultado — não regride

    final progress = container.read(progressNotifierProvider);
    expect(progress.starsFor('fase1'), 3);
    expect(progress.forLevel('fase1')!.bestBlocks, 5);
    expect(progress.forLevel('fase1')!.bestPoints, 300);
  });

  test('addSessionPoints soma à pontuação de sessão', () {
    final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(_FakeProgressRepository())]);
    addTearDown(container.dispose);
    final notifier = container.read(progressNotifierProvider.notifier);

    notifier.addSessionPoints(100);
    notifier.addSessionPoints(50);

    expect(container.read(progressNotifierProvider).sessionScore, 150);
  });

  test('submitToLeaderboard marca hasSubmittedToLeaderboard e guarda idade/resposta', () {
    final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(_FakeProgressRepository())]);
    addTearDown(container.dispose);
    final notifier = container.read(progressNotifierProvider.notifier);

    expect(container.read(progressNotifierProvider).hasSubmittedToLeaderboard, isFalse);
    notifier.submitToLeaderboard(age: 10, hasProgrammedBefore: true);
    final progress = container.read(progressNotifierProvider);
    expect(progress.hasSubmittedToLeaderboard, isTrue);
    expect(progress.surveyAge, 10);
    expect(progress.surveyHasProgrammedBefore, isTrue);
  });

  test('markGameCompleted marca gameCompleted uma vez só, sem sobrescrever gameCompletedAt numa 2ª chamada', () async {
    final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(_FakeProgressRepository())]);
    addTearDown(container.dispose);
    final notifier = container.read(progressNotifierProvider.notifier);

    expect(container.read(progressNotifierProvider).gameCompleted, isFalse);
    notifier.markGameCompleted();
    final firstCompletedAt = container.read(progressNotifierProvider).gameCompletedAt;
    expect(container.read(progressNotifierProvider).gameCompleted, isTrue);
    expect(firstCompletedAt, isNotNull);

    await Future<void>.delayed(const Duration(milliseconds: 5));
    notifier.markGameCompleted();
    expect(container.read(progressNotifierProvider).gameCompletedAt, firstCompletedAt, reason: 'não deve reescrever a data de quem já tinha zerado');
  });

  test('toda mutação sincroniza o estado atual com o ProgressRepository', () {
    final repo = _FakeProgressRepository();
    final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    final notifier = container.read(progressNotifierProvider.notifier);

    notifier.recordWin('fase1', stars: 3, blocksUsed: 2, points: 300);

    expect(repo.lastSaved, isNotNull);
    expect(repo.lastSaved!.starsFor('fase1'), 3);
  });

  test('build() hidrata a partir do ProgressRepository (equivalente ao antigo Progress.restore)', () async {
    final repo = _FakeProgressRepository()
      ..seeded = ProgressState(byLevelId: {'fase-nuvem': const LevelProgress(stars: 3, bestBlocks: 2, bestPoints: 300)}, sessionScore: 300, hasSubmittedToLeaderboard: true);
    final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);

    // `build()` já dispara a hidratação (fire-and-forget) no primeiro read
    // — espera o microtask/Future completarem antes de checar o estado.
    container.read(progressNotifierProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final progress = container.read(progressNotifierProvider);
    expect(progress.isCompleted('fase-nuvem'), isTrue);
    expect(progress.starsFor('fase-nuvem'), 3);
    expect(progress.sessionScore, 300);
    expect(progress.hasSubmittedToLeaderboard, isTrue);
  });

  test('isWorldCompleted/totalStars/totalPoints — comportamento puro de ProgressState', () {
    const state = ProgressState(byLevelId: {
      'a': LevelProgress(stars: 3, bestBlocks: 1, bestPoints: 300),
      'b': LevelProgress(stars: 2, bestBlocks: 1, bestPoints: 200),
    });

    expect(state.totalStars(['a', 'b']), 5);
    expect(state.totalPoints(['a', 'b']), 500);
    expect(state.totalPoints(['a', 'b', 'c']), 500, reason: 'fase não jogada conta 0, não quebra');
    expect(state.isWorldCompleted(['a', 'b']), isTrue);
    expect(state.isWorldCompleted(['a', 'b', 'c']), isFalse);
  });

  test('mergedWith mantém o melhor resultado por fase, a maior pontuação de sessão e OR de hasSubmittedToLeaderboard', () {
    // Progresso local (jogado sem conta neste aparelho, antes do login).
    const local = ProgressState(
      byLevelId: {
        'fase1': LevelProgress(stars: 3, bestBlocks: 2, bestPoints: 300), // só jogada aqui
        'fase2': LevelProgress(stars: 1, bestBlocks: 8, bestPoints: 100), // pior que a da conta
      },
      sessionScore: 450,
      hasSubmittedToLeaderboard: false,
    );
    // Progresso salvo na conta (jogado antes, em outro aparelho).
    const fromAccount = ProgressState(
      byLevelId: {
        'fase2': LevelProgress(stars: 3, bestBlocks: 3, bestPoints: 300), // melhor que a local
        'fase3': LevelProgress(stars: 2, bestBlocks: 5, bestPoints: 200), // só jogada na conta
      },
      sessionScore: 300,
      hasSubmittedToLeaderboard: true,
    );

    final merged = local.mergedWith(fromAccount);

    expect(merged.forLevel('fase1')!.stars, 3, reason: 'jogada só localmente — preservada, não perdida');
    expect(merged.forLevel('fase2')!.stars, 3, reason: 'melhor resultado entre os dois lados vence');
    expect(merged.forLevel('fase2')!.bestPoints, 300);
    expect(merged.forLevel('fase3')!.stars, 2, reason: 'jogada só na conta — preservada');
    expect(merged.sessionScore, 450, reason: 'maior das duas pontuações de sessão, nunca soma');
    expect(merged.hasSubmittedToLeaderboard, isTrue, reason: 'true de qualquer um dos dois lados já basta');
  });

  test('_hydrate mescla (não substitui) quando já há progresso local ao logar numa conta de outro aparelho', () async {
    // Progresso salvo na conta (outro aparelho) — fase2 nunca jogada aqui.
    final repo = _FakeProgressRepository()..seeded = const ProgressState(byLevelId: {'fase2': LevelProgress(stars: 3, bestBlocks: 1, bestPoints: 300)});
    final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    final notifier = container.read(progressNotifierProvider.notifier);

    // Espera a 1ª hidratação (no boot, sem conta) terminar.
    container.read(progressNotifierProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    // Jogador joga sem conta neste aparelho, antes de logar.
    notifier.recordWin('fase1', stars: 2, blocksUsed: 5, points: 150);
    expect(container.read(progressNotifierProvider).isCompleted('fase1'), isTrue);

    // Login numa conta com progresso próprio de outro aparelho —
    // `rehydrate()` busca `fase2` de novo e não pode descartar `fase1`.
    await notifier.rehydrate();

    final progress = container.read(progressNotifierProvider);
    expect(progress.isCompleted('fase1'), isTrue, reason: 'progresso jogado sem conta neste aparelho não pode se perder');
    expect(progress.isCompleted('fase2'), isTrue, reason: 'progresso da conta (outro aparelho) também precisa aparecer');
  });

  test('setUsername/setAvatarId guardam a escolha do jogador; displayAvatarId cai no padrão sem avatar escolhido', () {
    final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(_FakeProgressRepository())]);
    addTearDown(container.dispose);
    final notifier = container.read(progressNotifierProvider.notifier);

    expect(container.read(progressNotifierProvider).username, isNull);
    expect(container.read(progressNotifierProvider).displayAvatarId, 'lili', reason: 'padrão do jogo antes de escolher');

    notifier.setUsername('Capitã Debug');
    notifier.setAvatarId('libug');

    final progress = container.read(progressNotifierProvider);
    expect(progress.username, 'Capitã Debug');
    expect(progress.avatarId, 'libug');
    expect(progress.displayAvatarId, 'libug');
  });

  test('mergedWith preserva username/avatarId já escolhidos deste lado, cai pro do outro lado se ainda não escolheu', () {
    const withProfile = ProgressState(username: 'Capitã Debug', avatarId: 'libug');
    const withoutProfile = ProgressState();

    expect(withProfile.mergedWith(withoutProfile).username, 'Capitã Debug');
    expect(withProfile.mergedWith(withoutProfile).avatarId, 'libug');
    expect(withoutProfile.mergedWith(withProfile).username, 'Capitã Debug', reason: 'cai pro do outro lado quando este ainda não escolheu');
    expect(withoutProfile.mergedWith(withProfile).avatarId, 'libug');
  });
}
