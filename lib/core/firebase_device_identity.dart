import 'package:firebase_auth/firebase_auth.dart';

import 'device_identity.dart';

/// Implementação real: login anônimo do Firebase Auth, sem nenhuma tela —
/// `signInAnonymously()` cria (ou recupera) um UID estável para este
/// aparelho/navegador, só na 1ª vez (sem sessão nenhuma ainda). Depois
/// disso, `currentUserId()` **sempre** reflete `FirebaseAuth.instance.currentUser`
/// ao vivo, sem cachear o UID — se cacheasse (como uma versão anterior
/// fazia), o UID continuaria "preso" no anônimo mesmo depois de um login
/// bem-sucedido (`registerWithEmail`/`signInWithEmail`/`signInWithGoogle`
/// trocam o usuário atual pro UID da conta) — todo `fetch()`/`save()` de
/// progresso continuaria lendo/escrevendo no documento anônimo errado,
/// nunca no da conta de verdade. Achado real do usuário: progresso jogado
/// antes de logar "sumia" depois do login — na verdade estava sendo salvo
/// sempre no mesmo UID anônimo cacheado, nunca no UID da conta. Ver
/// `.claude/memory/decisions.md`.
class FirebaseDeviceIdentity implements DeviceIdentity {
  @override
  Future<String?> currentUserId() async {
    try {
      final auth = FirebaseAuth.instance;
      final existing = auth.currentUser;
      if (existing != null) return existing.uid;
      final credential = await auth.signInAnonymously();
      return credential.user?.uid;
    } catch (_) {
      return null;
    }
  }
}
