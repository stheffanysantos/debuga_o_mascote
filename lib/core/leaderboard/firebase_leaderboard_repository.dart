import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/leaderboard_entry.dart';
import '../device_identity.dart';
import 'leaderboard_repository.dart';

/// Implementação real do Placar Geral via Firestore — substitui
/// `LocalLeaderboardRepository` quando o Firebase está configurado (ver
/// `leaderboard_providers.dart`), permitindo aparelhos diferentes
/// contribuírem para o mesmo Placar. Nunca lança para quem chama: qualquer
/// falha (regra do Firestore, sem internet) é engolida e tratada como
/// "Placar indisponível agora" — o jogo em si nunca depende disto.
///
/// Coleção `scores/{uid}` — **um documento por jogador** (chave = UID do
/// Firebase Auth, não um ID automático), atualizado a cada vitória via
/// `LeaderboardSyncService` (não um histórico por envio, que criaria uma
/// linha nova a cada sincronização). Perfil mínimo da pesquisa (nome,
/// idade, "já programou antes?") fica dentro do mesmo documento — não há
/// mais uma coleção `players` separada só pra isso (o perfil/progresso do
/// jogador em si continua em `players/{uid}`, ver
/// `FirestoreProgressRepository`).
class FirebaseLeaderboardRepository implements LeaderboardRepository {
  FirebaseLeaderboardRepository(this._deviceIdentity, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final DeviceIdentity _deviceIdentity;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _scores => _firestore.collection('scores');

  // Poucos jogadores esperados (jogo de estande) — busca a coleção inteira
  // e filtra/ordena no cliente, mesmo padrão simples já usado antes (evita
  // precisar de um índice composto do Firestore pra "gameCompleted == X
  // ordenado por Y").
  Future<List<LeaderboardEntry>> _fetchAll() async {
    final snapshot = await _scores.get();
    return snapshot.docs.map((doc) => LeaderboardEntry.fromJson(doc.data())).toList();
  }

  @override
  Future<List<LeaderboardEntry>> topOverall({int limit = 20}) async {
    try {
      final entries = (await _fetchAll()).where((e) => !e.gameCompleted).toList()..sort((a, b) => b.score.compareTo(a.score));
      return entries.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<LeaderboardEntry>> completedGame({int limit = 20}) async {
    try {
      final entries = (await _fetchAll()).where((e) => e.gameCompleted).toList()
        ..sort((a, b) => (a.completedAt ?? a.updatedAt).compareTo(b.completedAt ?? b.updatedAt));
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
      await _scores.doc(uid).set({...entry.toJson(), 'uid': uid}, SetOptions(merge: true));
    } catch (_) {
      // Sem internet/Firestore indisponível — a UI já trata "não enviou"
      // sem travar a sessão (ver SurveyView).
    }
  }
}
