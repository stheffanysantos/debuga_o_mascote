import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../models/progress.dart';
import '../device_identity.dart';
import 'progress_repository.dart';
import 'progress_state.dart';

/// Implementação real de [ProgressRepository] via Firestore
/// (`players/{uid}`) — perfil básico (anônimo ou cadastrado) + progresso do
/// jogo (estrelas/blocos por fase, pontuação de sessão). O mesmo UID é
/// preservado ao cadastrar (`FirebaseAuthService` sempre linka a conta
/// anônima primeiro, ver `.claude/memory/decisions.md`), então o progresso
/// de um jogador anônimo continua o mesmo depois que ele cria conta — sem
/// nenhuma migração especial.
///
/// Mesmo princípio de resiliência de `FirebaseLeaderboardRepository`: sem
/// Firebase inicializado, ou qualquer erro de rede, `fetch()`/`save()`
/// engolem o problema silenciosamente — o jogo continua 100% jogável, só
/// sem sincronizar.
class FirestoreProgressRepository implements ProgressRepository {
  FirestoreProgressRepository(this._deviceIdentity);

  final DeviceIdentity _deviceIdentity;

  bool get _firebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ProgressState?> fetch() async {
    if (!_firebaseAvailable) return null;
    try {
      final uid = await _deviceIdentity.currentUserId();
      if (uid == null) return null;
      final snapshot = await FirebaseFirestore.instance.collection('players').doc(uid).get();
      final data = snapshot.data();
      if (data == null) return null;
      final rawProgress = (data['progress'] as Map<String, dynamic>?) ?? const {};
      final byLevelId = {
        for (final entry in rawProgress.entries)
          entry.key: LevelProgress(
            stars: (entry.value['stars'] as num).toInt(),
            bestBlocks: (entry.value['bestBlocks'] as num).toInt(),
            // Documentos salvos antes do desbloqueio por pontos (2026-09-17)
            // não têm este campo — 0 é um valor seguro (só faz o total de
            // pontos do Mundo começar do zero de novo, não quebra nada).
            bestPoints: (entry.value['bestPoints'] as num?)?.toInt() ?? 0,
          ),
      };
      return ProgressState(
        byLevelId: byLevelId,
        sessionScore: (data['sessionScore'] as num?)?.toInt() ?? 0,
        hasSubmittedToLeaderboard: data['hasSubmittedToLeaderboard'] as bool? ?? false,
        // Fallback pros campos legados `age`/`hasProgrammedBefore` — quem
        // respondeu a Pesquisa **antes** do Placar Geral (2026-09-17) tem
        // `hasSubmittedToLeaderboard: true` mas nunca teve `surveyAge`/
        // `surveyHasProgrammedBefore` escritos (não existiam ainda); sem
        // este fallback, `LeaderboardSyncService.resync()` reenviaria
        // `age: 0`/`hasProgrammedBefore: false` errados pra essas contas.
        // Achado real do usuário, ver `.claude/memory/decisions.md`.
        surveyAge: (data['surveyAge'] as num?)?.toInt() ?? (data['age'] as num?)?.toInt(),
        surveyHasProgrammedBefore: data['surveyHasProgrammedBefore'] as bool? ?? data['hasProgrammedBefore'] as bool?,
        gameCompleted: data['gameCompleted'] as bool? ?? false,
        gameCompletedAt: data['gameCompletedAt'] != null ? DateTime.parse(data['gameCompletedAt'] as String) : null,
        username: data['username'] as String?,
        avatarId: data['avatarId'] as String?,
      );
    } catch (_) {
      // Sem internet/erro qualquer — segue com o progresso local (zerado ou
      // o que já estava em memória), sem travar o app.
      return null;
    }
  }

  @override
  Future<void> save(ProgressState state) async {
    if (!_firebaseAvailable) return;
    try {
      final uid = await _deviceIdentity.currentUserId();
      if (uid == null) return;
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('players').doc(uid).set({
        'uid': uid,
        'isAnonymous': user?.isAnonymous ?? true,
        'email': user?.email,
        'displayName': user?.displayName,
        'platform': _platformName(),
        'createdAt': user?.metadata.creationTime?.toIso8601String(),
        'lastSeenAt': DateTime.now().toIso8601String(),
        'progress': {
          for (final entry in state.byLevelId.entries)
            entry.key: {'stars': entry.value.stars, 'bestBlocks': entry.value.bestBlocks, 'bestPoints': entry.value.bestPoints},
        },
        'sessionScore': state.sessionScore,
        'hasSubmittedToLeaderboard': state.hasSubmittedToLeaderboard,
        'surveyAge': state.surveyAge,
        'surveyHasProgrammedBefore': state.surveyHasProgrammedBefore,
        'gameCompleted': state.gameCompleted,
        'gameCompletedAt': state.gameCompletedAt?.toIso8601String(),
        'username': state.username,
        'avatarId': state.avatarId,
      }, SetOptions(merge: true));
    } catch (_) {
      // Idem — falha de rede aqui nunca deve aparecer pro jogador.
    }
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      default:
        return 'unknown';
    }
  }
}
