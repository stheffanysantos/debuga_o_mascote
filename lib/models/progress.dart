/// Progresso do jogador numa fase: melhores estrelas e menor contagem de
/// blocos já alcançados nela.
class LevelProgress {
  final int stars;
  final int bestBlocks;

  const LevelProgress({required this.stars, required this.bestBlocks});
}

/// Progresso do jogador — vive em memória durante a sessão, mas é
/// sincronizado com o Firestore (`players/{uid}`, anônimo ou cadastrado) por
/// `lib/data/progress_sync.dart`, que chama `restore` no boot e lê `byLevelId`
/// depois de cada mutação. `Progress` em si continua Dart puro (sem
/// `package:flutter`/Firebase) — ver `.claude/rules/architecture.md` e
/// `.claude/memory/decisions.md`.
///
/// Instância única e compartilhada (`Progress.instance`) para as telas
/// lerem/escreverem sem precisar de um pacote de state management — ver
/// `.claude/rules/architecture.md`.
class Progress {
  Progress._();

  static final Progress instance = Progress._();

  final Map<String, LevelProgress> _byLevelId = {};
  int _sessionScore = 0;

  /// Pontuação acumulada nesta sessão para o Placar do Dia — separada do
  /// "PONTOS" por fase (`LevelProgress` não guarda isso). Só cresce quando
  /// `addSessionPoints` é chamado por uma fase concluída pela 1ª vez (ver
  /// `.claude/docs/GAME_DESIGN.md`, "Placar do Dia").
  int get sessionScore => _sessionScore;

  /// Chamado pela tela de Gameplay só quando a fase acabou de ser vencida
  /// pela primeira vez (`!isCompleted(levelId)` checado **antes** de
  /// `recordWin`) — replay de fase já concluída nunca soma de novo.
  void addSessionPoints(int points) => _sessionScore += points;

  bool _submittedToLeaderboard = false;

  /// `true` depois que o jogador já enviou a pontuação desta sessão pro
  /// Placar (`SurveyScreen`) — usado por `LeaderboardScreen` pra esconder o
  /// convite "Quer aparecer no Placar?" depois de já ter respondido.
  bool get hasSubmittedToLeaderboard => _submittedToLeaderboard;

  void markSubmittedToLeaderboard() => _submittedToLeaderboard = true;

  /// Cópia somente-leitura de todo o progresso por fase — usado por
  /// `lib/data/progress_sync.dart` pra serializar pro Firestore.
  Map<String, LevelProgress> get byLevelId => Map.unmodifiable(_byLevelId);

  LevelProgress? forLevel(String levelId) => _byLevelId[levelId];

  bool isCompleted(String levelId) => _byLevelId.containsKey(levelId);

  int starsFor(String levelId) => _byLevelId[levelId]?.stars ?? 0;

  /// Registra o resultado de uma vitória, mantendo o melhor resultado já
  /// obtido (mais estrelas, menos blocos) se a fase já tinha sido vencida.
  void recordWin(String levelId, {required int stars, required int blocksUsed}) {
    final current = _byLevelId[levelId];
    if (current == null) {
      _byLevelId[levelId] = LevelProgress(stars: stars, bestBlocks: blocksUsed);
      return;
    }
    _byLevelId[levelId] = LevelProgress(
      stars: stars > current.stars ? stars : current.stars,
      bestBlocks: blocksUsed < current.bestBlocks ? blocksUsed : current.bestBlocks,
    );
  }

  int totalStars(Iterable<String> levelIds) {
    return levelIds.fold(0, (sum, id) => sum + starsFor(id));
  }

  /// `true` quando toda fase de `levelIds` já foi concluída — usado tanto
  /// para destravar o próximo Mundo (`WorldSelectScreen._isWorldUnlocked`)
  /// quanto para decidir se acabou de completar o Mundo atual pela primeira
  /// vez (recapitulação de fim de mundo, ver `.claude/memory/decisions.md`).
  bool isWorldCompleted(Iterable<String> levelIds) => levelIds.every(isCompleted);

  /// Só para testes — volta ao estado inicial (nenhuma fase concluída).
  void reset() {
    _byLevelId.clear();
    _sessionScore = 0;
    _submittedToLeaderboard = false;
  }

  /// Substitui todo o estado de uma vez — chamado por
  /// `ProgressSync.hydrate()` (boot do app, ou depois de logar numa conta)
  /// pra restaurar o progresso salvo no Firestore. Nunca chamado por
  /// telas/gameplay diretamente.
  void restore({
    required Map<String, LevelProgress> byLevelId,
    required int sessionScore,
    required bool hasSubmittedToLeaderboard,
  }) {
    _byLevelId
      ..clear()
      ..addAll(byLevelId);
    _sessionScore = sessionScore;
    _submittedToLeaderboard = hasSubmittedToLeaderboard;
  }
}
