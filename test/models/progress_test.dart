import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/models/progress.dart';

/// `Progress` (`lib/models/progress.dart`) — unit tests focados em
/// `byLevelId`/`restore`, usados por `ProgressSync`
/// (`lib/data/progress_sync.dart`) pra sincronizar com o Firestore. O resto
/// do comportamento de `Progress` já é coberto indiretamente pelos testes
/// de fluxo das telas (`test/screens/*_flow_test.dart`).
void main() {
  setUp(() => Progress.instance.reset());

  test('byLevelId é uma cópia somente-leitura do progresso por fase', () {
    Progress.instance.recordWin('fase1', stars: 3, blocksUsed: 5);
    Progress.instance.recordWin('fase2', stars: 2, blocksUsed: 8);

    final snapshot = Progress.instance.byLevelId;

    expect(snapshot.length, 2);
    expect(snapshot['fase1']!.stars, 3);
    expect(snapshot['fase2']!.bestBlocks, 8);
    expect(() => snapshot['fase3'] = const LevelProgress(stars: 1, bestBlocks: 1), throwsUnsupportedError);
  });

  test('restore substitui todo o estado de uma vez (usado por ProgressSync.hydrate)', () {
    Progress.instance.recordWin('fase-local', stars: 1, blocksUsed: 10);
    Progress.instance.addSessionPoints(50);

    Progress.instance.restore(
      byLevelId: {'fase-nuvem': const LevelProgress(stars: 3, bestBlocks: 2)},
      sessionScore: 300,
      hasSubmittedToLeaderboard: true,
    );

    expect(Progress.instance.isCompleted('fase-local'), isFalse, reason: 'restore substitui, não soma, o estado anterior');
    expect(Progress.instance.isCompleted('fase-nuvem'), isTrue);
    expect(Progress.instance.starsFor('fase-nuvem'), 3);
    expect(Progress.instance.sessionScore, 300);
    expect(Progress.instance.hasSubmittedToLeaderboard, isTrue);
  });
}
