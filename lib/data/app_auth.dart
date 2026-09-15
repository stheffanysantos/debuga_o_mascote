import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'firebase_auth_service.dart';

/// Instância única e compartilhada do cadastro/login (`AppAuth.instance`) —
/// mesmo padrão de `Leaderboard.instance`/`AppSounds.instance`: resolve a
/// implementação real só na 1ª chamada, expõe um setter
/// `@visibleForTesting` pra trocar por um fake nos testes.
class AppAuth {
  AppAuth._();

  static final AppAuth instance = AppAuth._();

  AuthService? _service;

  @visibleForTesting
  set service(AuthService value) => _service = value;

  AuthService get _resolved => _service ??= FirebaseAuthService();

  bool get hasAccount => _resolved.hasAccount;

  String? get displayName => _resolved.displayName;

  Future<String?> registerWithEmail({required String name, required String email, required String password}) =>
      _resolved.registerWithEmail(name: name, email: email, password: password);

  Future<String?> signInWithEmail({required String email, required String password}) =>
      _resolved.signInWithEmail(email: email, password: password);

  Future<String?> signInWithGoogle() => _resolved.signInWithGoogle();

  /// Só para testes — volta a resolver a implementação real na próxima
  /// chamada.
  @visibleForTesting
  void resetForTest() => _service = null;
}
