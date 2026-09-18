import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

/// Implementação real de `AuthService` via Firebase Auth. Cadastro/login
/// sempre tentam primeiro **linkar** a conta anônima já existente
/// (`FirebaseDeviceIdentity`/`signInAnonymously`) — preserva o mesmo UID que
/// já pode ter dados no Firestore (Placar do Dia). Nunca lança para quem
/// chama: qualquer falha (credencial errada, sem internet, Firebase não
/// inicializado) vira uma `String?` de erro em pt-BR — mesmo princípio de
/// nunca deixar infraestrutura derrubar o jogo já usado em
/// `FirebaseLeaderboardRepository`.
///
/// Quando o login troca de UID de verdade (linkar falha e cai pra uma conta
/// pré-existente de outro aparelho, `signInWithGoogle`; ou login direto por
/// e-mail/senha, `signInWithEmail`), o documento `players/{uid}` da sessão
/// anônima abandonada é apagado antes da troca (`_deleteOrphanedAnonymousDoc`)
/// — pedido explícito do usuário, pra não acumular UID de sessão sem uso no
/// Firestore. Ver `.claude/memory/decisions.md`.
class FirebaseAuthService implements AuthService {
  @override
  bool get hasAccount {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user != null && !user.isAnonymous;
    } catch (_) {
      return false;
    }
  }

  @override
  String? get displayName {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) return null;
      return user.displayName ?? user.email;
    } catch (_) {
      return null;
    }
  }

  /// Garante uma sessão anônima antes de linkar — `FirebaseDeviceIdentity`
  /// só cria essa sessão quando o Placar/Pesquisa é acessado, então um
  /// jogador que nunca abriu o Placar ainda não tem `currentUser` nenhum
  /// no momento do cadastro.
  Future<User> _ensureAnonymousUser() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) return current;
    final credential = await FirebaseAuth.instance.signInAnonymously();
    return credential.user!;
  }

  @override
  Future<String?> registerWithEmail({required String name, required String email, required String password}) async {
    try {
      final current = await _ensureAnonymousUser();
      final credential = EmailAuthProvider.credential(email: email, password: password);
      final result = await current.linkWithCredential(credential);
      await result.user?.updateDisplayName(name);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Esse e-mail já tem cadastro. Toque em "Entrar" com sua senha, ou entre com Google se foi assim que você criou a conta.';
      }
      return _friendlyMessage(e);
    } catch (_) {
      return 'Não foi possível criar a conta agora. Tente de novo.';
    }
  }

  @override
  Future<String?> signInWithEmail({required String email, required String password}) async {
    // Se havia uma sessão anônima (jogou sem conta neste aparelho antes de
    // logar numa conta já existente), esse UID vai ficar órfão no Firestore
    // depois do login — apaga **antes** de trocar de sessão, enquanto ainda
    // é o próprio dono do documento (as regras do Firestore só deixam um
    // UID apagar o seu próprio `players/{uid}`; depois de logar, o app já
    // é outro UID e não teria mais permissão). Ver `.claude/memory/decisions.md`.
    final anonymousUid = _currentAnonymousUidOrNull();
    if (anonymousUid != null) await _deleteOrphanedAnonymousDoc(anonymousUid);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e);
    } catch (_) {
      return 'Não foi possível entrar agora. Tente de novo.';
    }
  }

  @override
  Future<String?> signInWithGoogle() async {
    // `signInWithProvider`/`linkWithProvider` (GoogleAuthProvider) é o
    // método universal do firebase_auth — funciona em Web (popup), Android
    // e iOS (fluxo nativo), sem precisar do pacote `google_sign_in` nem de
    // nenhum botão especial por plataforma (ver `.claude/memory/decisions.md`).
    final provider = GoogleAuthProvider();
    try {
      final current = await _ensureAnonymousUser();
      await current.linkWithProvider(provider);
      return null;
    } on FirebaseAuthException catch (e) {
      // A pessoa já tem conta Google vinculada a outro UID (aparelho/sessão
      // anterior) — troca de identidade pra essa conta pré-existente em vez
      // de tentar recuperar a credencial do erro (não confiável nas versões
      // recentes do SDK).
      if (e.code == 'credential-already-in-use' || e.code == 'provider-already-linked' || e.code == 'email-already-in-use') {
        // Mesmo motivo do `signInWithEmail` acima — apaga o UID anônimo
        // órfão **antes** de trocar de sessão (senão perde a permissão de
        // apagá-lo). O progresso local em memória não se perde com isso —
        // já vai ser mesclado/regravado sob o UID novo pelo
        // `ProgressNotifier.rehydrate()` chamado depois deste login.
        final anonymousUid = _currentAnonymousUidOrNull();
        if (anonymousUid != null) await _deleteOrphanedAnonymousDoc(anonymousUid);
        try {
          await FirebaseAuth.instance.signInWithProvider(provider);
          return null;
        } on FirebaseAuthException catch (e2) {
          return _friendlyMessage(e2);
        }
      }
      return _friendlyMessage(e);
    } catch (_) {
      return 'Não foi possível entrar com Google agora. Tente de novo.';
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Nunca deve travar o fluxo de "próximo jogador" no estande.
    }
  }

  String? _currentAnonymousUidOrNull() {
    final user = FirebaseAuth.instance.currentUser;
    return (user != null && user.isAnonymous) ? user.uid : null;
  }

  /// Apaga `players/{uid}` da sessão anônima que está sendo abandonada —
  /// pedido explícito do usuário, pra não acumular documento de conta sem
  /// uso no Firestore. Só `players/{uid}` (não `scores/{uid}`, cujas regras
  /// já proíbem delete de propósito — histórico do Placar é imutável, ver
  /// `firestore.rules`). Best-effort: qualquer falha (sem internet, regra
  /// negando por já ter trocado de sessão, etc.) é engolida — limpeza nunca
  /// pode travar um login de verdade.
  Future<void> _deleteOrphanedAnonymousDoc(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('players').doc(uid).delete();
    } catch (_) {
      // Best-effort — ver comentário acima.
    }
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Escolha uma senha mais forte (pelo menos 6 caracteres).';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Senha incorreta.';
      case 'user-not-found':
        return 'Não encontramos uma conta com esse e-mail.';
      case 'network-request-failed':
        return 'Sem conexão com a internet agora.';
      case 'popup-closed-by-user':
      case 'canceled':
        return 'Login cancelado.';
      default:
        return 'Algo deu errado. Tente de novo.';
    }
  }
}
