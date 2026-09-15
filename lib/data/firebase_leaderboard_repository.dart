import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/leaderboard_entry.dart';
import 'device_identity.dart';
import 'leaderboard_repository.dart';

/// Implementação real do Placar do Dia via Firestore — substitui
/// `LocalLeaderboardRepository` quando o Firebase está configurado (ver
/// `lib/data/leaderboard.dart`), permitindo aparelhos diferentes
/// contribuírem para o mesmo Placar. Nunca lança para quem chama: qualquer
/// falha (regra do Firestore, sem internet) é engolida e tratada como
/// "Placar indisponível agora" — o jogo em si nunca depende disto.
///
/// Coleções:
/// - `players/{uid}` — perfil mínimo de quem respondeu a pesquisa (nome,
///   idade, "já programou antes?", dados de dispositivo), indexado pelo UID
///   anônimo do Firebase Auth.
/// - `scores` — um documento por envio (histórico completo, não só o mais
///   recente por jogador), usado para montar o ranking do dia.
class FirebaseLeaderboardRepository implements LeaderboardRepository {
  FirebaseLeaderboardRepository(this._deviceIdentity, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final DeviceIdentity _deviceIdentity;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _scores => _firestore.collection('scores');
  CollectionReference<Map<String, dynamic>> get _players => _firestore.collection('players');

  @override
  Future<List<LeaderboardEntry>> topToday({int limit = 20}) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final snapshot = await _scores
          .where('submittedAt', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .orderBy('submittedAt')
          .get();
      final entries = snapshot.docs.map((doc) => LeaderboardEntry.fromJson(doc.data())).toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      return entries.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> submit(LeaderboardEntry entry) async {
    try {
      final uid = await _deviceIdentity.currentUserId();
      if (uid == null) return;
      await _players.doc(uid).set({
        'name': entry.name,
        'age': entry.age,
        'hasProgrammedBefore': entry.hasProgrammedBefore,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      await _scores.add({...entry.toJson(), 'uid': uid});
    } catch (_) {
      // Sem internet/Firestore indisponível — a UI já trata "não enviou"
      // sem travar a sessão (ver SurveyScreen).
    }
  }
}
