import 'package:firebase_auth/firebase_auth.dart';

import 'device_identity.dart';

/// Implementação real: login anônimo do Firebase Auth, sem nenhuma tela —
/// `signInAnonymously()` cria (ou recupera) um UID estável para este
/// aparelho/navegador. O UID é cacheado em memória depois da 1ª resolução
/// bem-sucedida desta sessão.
class FirebaseDeviceIdentity implements DeviceIdentity {
  String? _cachedUid;

  @override
  Future<String?> currentUserId() async {
    if (_cachedUid != null) return _cachedUid;
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      _cachedUid = user?.uid;
      return _cachedUid;
    } catch (_) {
      return null;
    }
  }
}
