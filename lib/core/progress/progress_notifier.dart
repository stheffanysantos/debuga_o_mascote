import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/progress.dart';
import 'progress_repository.dart';
import 'progress_state.dart';

part 'progress_notifier.g.dart';

/// Progresso do jogador — vive em memória durante a sessão, mas é
/// sincronizado com o Firestore por `ProgressRepository`. `build()` devolve
/// um `ProgressState` vazio **sincronamente** e dispara a hidratação como
/// `Future` fire-and-forget (`_hydrate`) — o jogo é 100% jogável antes/sem
/// hidratação (resiliência de estande: sem internet no evento é um caso
/// real). Ver `.claude/memory/decisions.md`.
///
/// `keepAlive: true` — é o progresso do jogador inteiro, não pode ser
/// descartado/reiniciado só porque nenhuma tela está observando no
/// momento (o padrão de `@riverpod` sem essa flag é `autoDispose`).
@Riverpod(keepAlive: true)
class ProgressNotifier extends _$ProgressNotifier {
  // `Ref.mounted` não existe na versão de riverpod deste projeto (2.x) —
  // `onDispose` é o jeito disponível aqui de saber se ainda é seguro tocar
  // em `state` depois de um `await` (mesmo espírito do `if (!mounted)
  // return` que as telas já faziam antes da migração).
  bool _disposed = false;

  @override
  ProgressState build() {
    ref.onDispose(() => _disposed = true);
    Future.microtask(_hydrate);
    return const ProgressState();
  }

  /// Chamado de novo depois de qualquer login bem-sucedido
  /// (`RegisterScreen._runAuthAction`) — na maioria dos casos é o mesmo UID
  /// anônimo de antes (linkado, progresso já é o mesmo), mas se a conta já
  /// existia noutro aparelho/sessão, isso puxa o progresso de verdade
  /// daquela conta.
  Future<void> rehydrate() => _hydrate();

  Future<void> _hydrate() async {
    final saved = await ref.read(progressRepositoryProvider).fetch();
    if (_disposed) return;
    // `mergedWith`, não substituição direta — no boot, `state` ainda é o
    // `ProgressState()` vazio de `build()`, então mesclar equivale a
    // simplesmente adotar `saved` (comportamento idêntico a antes). Depois
    // de um login numa conta com progresso salvo de **outro** aparelho
    // (`rehydrate`), `state` pode já ter progresso local de jogar sem conta
    // neste aparelho — mesclar preserva os dois lados em vez de descartar o
    // que foi jogado localmente (achado real do usuário, ver
    // `.claude/memory/decisions.md`).
    if (saved != null) state = state.mergedWith(saved);
    // Grava a presença desta sessão (plataforma/último acesso) mesmo que o
    // jogador não jogue nada — mesmo comportamento do antigo
    // `ProgressSync.hydrate()`.
    _syncNow();
  }

  /// Chamado pela tela de Gameplay só quando a fase acabou de ser vencida
  /// pela primeira vez (`!isCompleted(levelId)` checado **antes** de
  /// `recordWin`) — replay de fase já concluída nunca soma de novo.
  void addSessionPoints(int points) {
    state = state.copyWith(sessionScore: state.sessionScore + points);
    _syncNow();
  }

  /// Chamado pela `SurveyView` na 1ª vez que o jogador responde a pesquisa.
  /// Guarda `age`/`hasProgrammedBefore` (não só `hasSubmittedToLeaderboard`)
  /// pra `LeaderboardSyncService` poder reenviar a entrada do Placar Geral
  /// sozinho a cada vitória nova, sem precisar pedir de novo.
  void submitToLeaderboard({required int age, required bool hasProgrammedBefore}) {
    state = state.copyWith(hasSubmittedToLeaderboard: true, surveyAge: age, surveyHasProgrammedBefore: hasProgrammedBefore);
    _syncNow();
  }

  /// Chamado só na transição "ainda não tinha zerado → zerou agora"
  /// (`RecordLevelWinUseCase`, comparando `isGameCompleted()` antes/depois de
  /// `recordWin`) — nunca sobrescreve `gameCompletedAt` numa chamada
  /// repetida (replay de fase depois de já ter zerado).
  void markGameCompleted() {
    if (state.gameCompleted) return;
    state = state.copyWith(gameCompleted: true, gameCompletedAt: DateTime.now());
    _syncNow();
  }

  /// Registra o resultado de uma vitória, mantendo o melhor resultado já
  /// obtido (mais estrelas, menos blocos, mais pontos) se a fase já tinha
  /// sido vencida.
  void recordWin(String levelId, {required int stars, required int blocksUsed, required int points}) {
    final current = state.byLevelId[levelId];
    final merged = current == null
        ? LevelProgress(stars: stars, bestBlocks: blocksUsed, bestPoints: points)
        : LevelProgress(
            stars: stars > current.stars ? stars : current.stars,
            bestBlocks: blocksUsed < current.bestBlocks ? blocksUsed : current.bestBlocks,
            bestPoints: points > current.bestPoints ? points : current.bestPoints,
          );
    state = state.copyWith(byLevelId: {...state.byLevelId, levelId: merged});
    _syncNow();
  }

  /// Chamados por `ProfileEditView` ao salvar — nome de exibição e avatar
  /// escolhidos pelo jogador, mostrados no Placar Geral via
  /// `LeaderboardSyncService`/`LeaderboardEntry`.
  void setUsername(String username) {
    state = state.copyWith(username: username);
    _syncNow();
  }

  void setAvatarId(String avatarId) {
    state = state.copyWith(avatarId: avatarId);
    _syncNow();
  }

  /// Chamado depois de `AuthService.signOut()` (botão "Sair", ver
  /// `SettingsView`) — zera o progresso local e hidrata de novo. Depois de
  /// um `signOut()`, o Firebase já não tem `currentUser`, então a próxima
  /// sincronização cria/usa uma sessão anônima **nova**, sem histórico —
  /// exatamente o comportamento certo pro estande ("Sou um novo jogador"):
  /// o progresso da conta que saiu continua salvo com segurança no Firestore
  /// dela, só não fica mais visível neste aparelho até logar de novo.
  void resetForNewPlayer() {
    state = const ProgressState();
    Future.microtask(_hydrate);
  }

  void _syncNow() => unawaited(ref.read(progressRepositoryProvider).save(state));
}
