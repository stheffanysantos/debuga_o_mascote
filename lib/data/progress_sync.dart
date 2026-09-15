import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/progress.dart';
import 'device_identity.dart';
import 'firebase_device_identity.dart';

/// Sincroniza `Progress.instance` com um documento `players/{uid}` no
/// Firestore — perfil básico (anônimo ou cadastrado) + progresso do jogo
/// (estrelas/blocos por fase, pontuação de sessão). O mesmo UID é
/// preservado ao cadastrar (`FirebaseAuthService` sempre linka a conta
/// anônima primeiro, ver `.claude/memory/decisions.md`), então o progresso
/// de um jogador anônimo continua o mesmo depois que ele cria conta — sem
/// nenhuma migração especial.
///
/// Mesmo princípio de resiliência de `FirebaseLeaderboardRepository`: sem
/// Firebase inicializado, ou qualquer erro de rede, `hydrate()`/`syncNow()`
/// engolem o problema silenciosamente — o jogo continua 100% jogável, só
/// sem sincronizar. `Progress` em si (`lib/models/progress.dart`) continua
/// Dart puro; toda a integração com Firebase mora aqui.
class ProgressSync {
  ProgressSync._();

  static final ProgressSync instance = ProgressSync._();

  DeviceIdentity? _identity;

  @visibleForTesting
  set identity(DeviceIdentity value) => _identity = value;

  DeviceIdentity get _resolvedIdentity => _identity ??= FirebaseDeviceIdentity();

  bool get _firebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Chamado uma vez no boot do app (`main.dart`, depois do
  /// `Firebase.initializeApp`) e de novo depois de qualquer login bem
  /// sucedido (`RegisterScreen`/`AppAuth`) — garante uma identidade (login
  /// anônimo se preciso), carrega o progresso salvo daquele UID (se
  /// existir) e restaura `Progress.instance`. Também grava a presença desta
  /// sessão (plataforma/último acesso) mesmo que o jogador não jogue nada.
  Future<void> hydrate() async {
    if (!_firebaseAvailable) return;
    try {
      final uid = await _resolvedIdentity.currentUserId();
      if (uid == null) return;
      final snapshot = await FirebaseFirestore.instance.collection('players').doc(uid).get();
      final data = snapshot.data();
      if (data != null) {
        final rawProgress = (data['progress'] as Map<String, dynamic>?) ?? const {};
        final byLevelId = {
          for (final entry in rawProgress.entries)
            entry.key: LevelProgress(
              stars: (entry.value['stars'] as num).toInt(),
              bestBlocks: (entry.value['bestBlocks'] as num).toInt(),
            ),
        };
        Progress.instance.restore(
          byLevelId: byLevelId,
          sessionScore: (data['sessionScore'] as num?)?.toInt() ?? 0,
          hasSubmittedToLeaderboard: data['hasSubmittedToLeaderboard'] as bool? ?? false,
        );
      }
      await _write(uid);
    } catch (_) {
      // Sem internet/erro qualquer — segue com o progresso local (zerado ou
      // o que já estava em memória), sem travar o app.
    }
  }

  /// Fire-and-forget — chamado depois de qualquer mutação em
  /// `Progress.instance` (`recordWin`, `addSessionPoints`,
  /// `markSubmittedToLeaderboard`). Nunca lança nem bloqueia a UI.
  void syncNow() {
    if (!_firebaseAvailable) return;
    unawaited(_syncNow());
  }

  Future<void> _syncNow() async {
    try {
      final uid = await _resolvedIdentity.currentUserId();
      if (uid == null) return;
      await _write(uid);
    } catch (_) {
      // Idem — falha de rede aqui nunca deve aparecer pro jogador.
    }
  }

  Future<void> _write(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    final progress = Progress.instance.byLevelId;
    await FirebaseFirestore.instance.collection('players').doc(uid).set({
      'uid': uid,
      'isAnonymous': user?.isAnonymous ?? true,
      'email': user?.email,
      'displayName': user?.displayName,
      'platform': _platformName(),
      'createdAt': user?.metadata.creationTime?.toIso8601String(),
      'lastSeenAt': DateTime.now().toIso8601String(),
      'progress': {
        for (final entry in progress.entries) entry.key: {'stars': entry.value.stars, 'bestBlocks': entry.value.bestBlocks},
      },
      'sessionScore': Progress.instance.sessionScore,
      'hasSubmittedToLeaderboard': Progress.instance.hasSubmittedToLeaderboard,
    }, SetOptions(merge: true));
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

  /// Só para testes — volta a resolver a identidade real na próxima chamada.
  @visibleForTesting
  void resetForTest() => _identity = null;
}
